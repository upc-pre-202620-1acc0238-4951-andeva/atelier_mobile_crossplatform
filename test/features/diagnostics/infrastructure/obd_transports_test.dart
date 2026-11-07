import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_errors.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/bluetooth/ble_obd_transport.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/bluetooth/bluetooth_obd_adapter_provider.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/bluetooth/spp_obd_transport.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal_ble/universal_ble.dart';

BleCharacteristic characteristic(
  String uuid,
  List<CharacteristicProperty> properties,
) {
  return BleCharacteristic(uuid, properties, const []);
}

ObdAdapter classic(String name, String address) {
  return ObdAdapter(name: name, address: address, kind: ObdAdapterKind.classic);
}

ObdAdapter ble(String name, String address) {
  return ObdAdapter(name: name, address: address, kind: ObdAdapterKind.ble);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BLE', () {
    test('FFE0 con una sola característica para todo', () {
      final channel = BleObdTransport.selectChannel([
        BleService('1800', [
          characteristic('2A00', [CharacteristicProperty.read]),
        ]),
        BleService('FFE0', [
          characteristic('FFE1', [
            CharacteristicProperty.notify,
            CharacteristicProperty.write,
            CharacteristicProperty.writeWithoutResponse,
          ]),
        ]),
      ])!;

      expect(channel.service, BleUuidParser.string('FFE0'));
      expect(channel.notify, BleUuidParser.string('FFE1'));
      expect(channel.write, BleUuidParser.string('FFE1'));
      expect(channel.withoutResponse, isFalse);
    });

    test('FFF0 separa recibir y escribir; sin respuesta si no hay otra', () {
      final channel = BleObdTransport.selectChannel([
        BleService('FFF0', [
          characteristic('FFF1', [CharacteristicProperty.notify]),
          characteristic('FFF2', [CharacteristicProperty.writeWithoutResponse]),
        ]),
      ])!;

      expect(channel.notify, BleUuidParser.string('FFF1'));
      expect(channel.write, BleUuidParser.string('FFF2'));
      expect(channel.withoutResponse, isTrue);
    });

    test('un servicio conocido gana a uno anterior que también sirve', () {
      final channel = BleObdTransport.selectChannel([
        BleService('ABCD', [
          characteristic('ABC1', [
            CharacteristicProperty.notify,
            CharacteristicProperty.write,
          ]),
        ]),
        BleService('FFE0', [
          characteristic('FFE1', [
            CharacteristicProperty.notify,
            CharacteristicProperty.write,
          ]),
        ]),
      ])!;

      expect(channel.service, BleUuidParser.string('FFE0'));
    });

    test('sin notify y write en un mismo servicio no hay canal', () {
      expect(
        BleObdTransport.selectChannel([
          BleService('1800', [
            characteristic('2A00', [CharacteristicProperty.read]),
          ]),
          BleService('FFF0', [
            characteristic('FFF1', [CharacteristicProperty.notify]),
          ]),
        ]),
        isNull,
      );
    });

    test('escribe en trozos', () {
      final parts = BleObdTransport.chunks(List.filled(45, 1));

      expect(parts.map((part) => part.length), [20, 20, 5]);
      expect(BleObdTransport.chunks(const [1, 2]).single, [1, 2]);
    });
  });

  group('SPP', () {
    const channel = MethodChannel(SppObdTransport.methodChannelName);
    final calls = <MethodCall>[];
    Object? Function(MethodCall call)? respond;

    setUp(() {
      calls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            return respond?.call(call);
          });
    });

    tearDown(() {
      respond = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    void failWith(String code) {
      respond = (_) => throw PlatformException(code: code);
    }

    test('los códigos del puente se traducen a excepciones del dominio', () async {
      const transport = SppObdTransport();

      failWith('PERMISSION_DENIED');
      await expectLater(
        transport.connect('AA'),
        throwsA(isA<BluetoothPermissionDeniedException>()),
      );
      failWith('BLUETOOTH_DISABLED');
      await expectLater(
        transport.connect('AA'),
        throwsA(isA<BluetoothDisabledException>()),
      );
      failWith('UNREACHABLE');
      await expectLater(
        transport.connect('AA'),
        throwsA(isA<ObdAdapterUnreachableException>()),
      );
      failWith('INVALID_ADDRESS');
      await expectLater(
        transport.connect('AA'),
        throwsA(
          isA<InvalidDiagnosticsInputException>().having(
            (e) => e.field,
            'field',
            'address',
          ),
        ),
      );
    });

    test('enviar termina el comando en CR y una falla es conexión perdida', () async {
      const transport = SppObdTransport();

      await transport.send('0105');
      expect(calls.single.arguments, {'command': '0105\r'});

      failWith('CONNECTION_LOST');
      await expectLater(
        transport.send('0105'),
        throwsA(isA<ObdConnectionLostException>()),
      );
    });

    test('emparejados con su tipo', () async {
      respond = (_) => [
        {'name': 'ELM327', 'address': 'AA', 'type': 'classic'},
        {'name': 'iCar', 'address': 'BB', 'type': 'ble'},
      ];

      final adapters = await const SppObdTransport().bondedAdapters();

      expect(adapters.map((a) => a.kind), [
        ObdAdapterKind.classic,
        ObdAdapterKind.ble,
      ]);
    });
  });

  group('lista de adaptadores', () {
    test('Android une emparejados y BLE, sin repetir y por nombre', () async {
      final provider = BluetoothObdAdapterProvider(
        bonded: () async => [classic('Viejo', 'AA')],
        canScan: () async => true,
        scan: () async => [ble('Viejo', 'AA'), ble('Azul', 'BB')],
      );

      final adapters = await provider.pairedAdapters();

      expect(adapters.map((a) => a.address), ['BB', 'AA']);
      expect(adapters.last.kind, ObdAdapterKind.classic);
    });

    test('Android sin permiso de escaneo no escanea', () async {
      var scans = 0;
      final provider = BluetoothObdAdapterProvider(
        bonded: () async => [classic('ELM', 'AA')],
        canScan: () async => false,
        scan: () async {
          scans++;
          return const [];
        },
      );

      expect(await provider.pairedAdapters(), hasLength(1));
      expect(scans, 0);
    });

    test('Android: un escaneo fallido no tumba los emparejados', () async {
      final provider = BluetoothObdAdapterProvider(
        bonded: () async => [classic('ELM', 'AA')],
        canScan: () async => true,
        scan: () async => throw const BluetoothDisabledException(),
      );

      expect(await provider.pairedAdapters(), hasLength(1));
    });

    test('Android: sin permiso para conectar sube el error', () async {
      final provider = BluetoothObdAdapterProvider(
        bonded: () async => throw const BluetoothPermissionDeniedException(),
        canScan: () async => true,
        scan: () async => const [],
      );

      await expectLater(
        provider.pairedAdapters(),
        throwsA(isA<BluetoothPermissionDeniedException>()),
      );
    });

    test('iOS sin permiso avisa; con permiso solo escanea', () async {
      await expectLater(
        BluetoothObdAdapterProvider(
          bonded: null,
          canScan: () async => false,
          scan: () async => const [],
        ).pairedAdapters(),
        throwsA(isA<BluetoothPermissionDeniedException>()),
      );

      final adapters = await BluetoothObdAdapterProvider(
        bonded: null,
        canScan: () async => true,
        scan: () async => [ble('iCar', 'uuid')],
      ).pairedAdapters();
      expect(adapters.single.address, 'uuid');
    });
  });
}
