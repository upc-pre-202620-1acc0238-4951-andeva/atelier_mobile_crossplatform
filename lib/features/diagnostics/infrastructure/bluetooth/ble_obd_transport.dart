import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_errors.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_transport.dart';
import 'package:universal_ble/universal_ble.dart';

/// Par de características con el que se habla con el ELM327.
class BleObdChannel {
  final String service;
  final String notify;
  final String write;
  final bool withoutResponse;

  const BleObdChannel({
    required this.service,
    required this.notify,
    required this.write,
    required this.withoutResponse,
  });
}

/// ELM327 por BLE con `universal_ble` (Android e iOS). **Sin comprobar:** no se ha probado con un adaptador
/// real (H40). Se escribe en trozos de 20 bytes, el mínimo que admite cualquier MTU: un comando ELM327 cabe
/// de sobra, y sin negociar el MTU se evita un paso que depende de cada clon.
class BleObdTransport implements ObdTransport {
  static const _connectTimeout = Duration(seconds: 15);
  static const _writeChunk = 20;

  /// Lo habitual en los ELM327 BLE, según 04 §4; cualquier otro con notify y write sirve igual.
  static final _knownServices = [
    BleUuidParser.string('FFE0'),
    BleUuidParser.string('FFF0'),
  ];

  final _incoming = StreamController<String>.broadcast();
  StreamSubscription<Uint8List>? _values;
  StreamSubscription<bool>? _connection;
  String? _deviceId;
  BleObdChannel? _channel;

  @override
  Stream<String> get incoming => _incoming.stream;

  /// `null` si ningún servicio tiene una característica para recibir y otra para escribir.
  static BleObdChannel? selectChannel(List<BleService> services) {
    final ordered = [
      for (final known in _knownServices)
        ...services.where((service) => service.uuid == known),
      ...services.where((service) => !_knownServices.contains(service.uuid)),
    ];
    for (final service in ordered) {
      final notify = service.characteristics.where(
        (c) => c.properties.contains(CharacteristicProperty.notify),
      );
      final write = service.characteristics.where(
        (c) =>
            c.properties.contains(CharacteristicProperty.write) ||
            c.properties.contains(CharacteristicProperty.writeWithoutResponse),
      );
      if (notify.isEmpty || write.isEmpty) continue;
      return BleObdChannel(
        service: service.uuid,
        notify: notify.first.uuid,
        write: write.first.uuid,
        withoutResponse: !write.first.properties.contains(
          CharacteristicProperty.write,
        ),
      );
    }
    return null;
  }

  static List<Uint8List> chunks(List<int> bytes, [int size = _writeChunk]) {
    return [
      for (var i = 0; i < bytes.length; i += size)
        Uint8List.fromList(
          bytes.sublist(i, i + size < bytes.length ? i + size : bytes.length),
        ),
    ];
  }

  @override
  Future<void> connect(String address) async {
    await _ensureAvailable();
    try {
      await UniversalBle.connect(address, timeout: _connectTimeout);
      final channel = selectChannel(
        await UniversalBle.discoverServices(address),
      );
      if (channel == null) throw const ObdAdapterUnreachableException();
      _deviceId = address;
      _channel = channel;
      _values = UniversalBle.characteristicValueStream(
        address,
        channel.notify,
      ).listen((value) {
        _incoming.add(ascii.decode(value, allowInvalid: true));
      });
      _connection = UniversalBle.connectionStream(address).listen((connected) {
        if (!connected) _incoming.addError(const ObdConnectionLostException());
      });
      await UniversalBle.subscribeNotifications(
        address,
        channel.service,
        channel.notify,
      );
    } on Exception {
      await disconnect();
      await _safeDisconnect(address);
      throw const ObdAdapterUnreachableException();
    }
  }

  /// Sin permiso, `connect` fallaría con un error que no dice cuál es el problema.
  Future<void> _ensureAvailable() async {
    if (!await UniversalBle.hasPermissions()) {
      throw const BluetoothPermissionDeniedException();
    }
    final state = await UniversalBle.getBluetoothAvailabilityState();
    if (state == AvailabilityState.poweredOff ||
        state == AvailabilityState.unsupported) {
      throw const BluetoothDisabledException();
    }
    if (state == AvailabilityState.unauthorized) {
      throw const BluetoothPermissionDeniedException();
    }
  }

  @override
  Future<void> send(String command) async {
    final deviceId = _deviceId;
    final channel = _channel;
    if (deviceId == null || channel == null) {
      throw const ObdConnectionLostException();
    }
    try {
      for (final chunk in chunks(ascii.encode('$command\r'))) {
        await UniversalBle.write(
          deviceId,
          channel.service,
          channel.write,
          chunk,
          withoutResponse: channel.withoutResponse,
        );
      }
    } on Exception {
      throw const ObdConnectionLostException();
    }
  }

  @override
  Future<void> disconnect() async {
    final deviceId = _deviceId;
    _deviceId = null;
    _channel = null;
    // Primero se dejan de escuchar: cerrar a propósito no es una caída.
    await _connection?.cancel();
    await _values?.cancel();
    _connection = null;
    _values = null;
    if (deviceId != null) await _safeDisconnect(deviceId);
  }

  Future<void> _safeDisconnect(String deviceId) async {
    try {
      await UniversalBle.disconnect(deviceId);
    } on Exception {
      // Ya se da por cerrado.
    }
  }
}

/// Lo que se ve por BLE durante [window]. `shortcut:` todo dispositivo con nombre, sin filtrar por servicio
/// porque muchos clones no lo anuncian; afinar con un adaptador real.
Future<List<ObdAdapter>> scanBleAdapters({
  Duration window = const Duration(seconds: 4),
}) async {
  final state = await UniversalBle.getBluetoothAvailabilityState();
  if (state == AvailabilityState.poweredOff ||
      state == AvailabilityState.unsupported) {
    throw const BluetoothDisabledException();
  }
  final found = <String, ObdAdapter>{};
  final subscription = UniversalBle.scanStream.listen((device) {
    final name = device.name;
    if (name == null || name.isEmpty) return;
    found[device.deviceId] = ObdAdapter(
      name: name,
      address: device.deviceId,
      kind: ObdAdapterKind.ble,
    );
  });
  try {
    await UniversalBle.startScan();
    await Future<void>.delayed(window);
    await UniversalBle.stopScan();
  } finally {
    await subscription.cancel();
  }
  return found.values.toList();
}
