import 'dart:developer';

import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_errors.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_link.dart';

/// Android: emparejados por el puente SPP más, de mejor esfuerzo, lo que se vea por BLE. El escaneo nunca pide
/// permisos y su fallo no tumba la lista: `startScan` pediría ubicación en Android ≤ 11. iOS ([bonded] `null`)
/// no tiene lista de emparejados (H41): solo escaneo, y sin permiso no hay nada que mostrar.
class BluetoothObdAdapterProvider implements ObdAdapterProvider {
  final Future<List<ObdAdapter>> Function()? bonded;
  final Future<List<ObdAdapter>> Function() scan;
  final Future<bool> Function() canScan;

  const BluetoothObdAdapterProvider({
    required this.bonded,
    required this.scan,
    required this.canScan,
  });

  @override
  Future<List<ObdAdapter>> pairedAdapters() async {
    final bondedDevices = bonded;
    if (bondedDevices == null) {
      if (!await canScan()) throw const BluetoothPermissionDeniedException();
      return _sorted(await scan());
    }
    return _sorted([...await bondedDevices(), ...await _scanBestEffort()]);
  }

  Future<List<ObdAdapter>> _scanBestEffort() async {
    try {
      return await canScan() ? await scan() : const [];
    } on Exception catch (e) {
      log('Sin escaneo BLE: $e', name: 'BluetoothObdAdapterProvider');
      return const [];
    }
  }

  /// Un emparejado que además se ve por BLE conserva el tipo con el que se emparejó.
  List<ObdAdapter> _sorted(List<ObdAdapter> adapters) {
    final byAddress = <String, ObdAdapter>{};
    for (final adapter in adapters) {
      byAddress.putIfAbsent(adapter.address, () => adapter);
    }
    return byAddress.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  }
}
