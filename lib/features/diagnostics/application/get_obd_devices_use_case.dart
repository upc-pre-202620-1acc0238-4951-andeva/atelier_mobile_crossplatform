import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_repository.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_device.dart';

class GetObdDevicesUseCase {
  final DiagnosticsRepository repository;

  const GetObdDevicesUseCase({required this.repository});

  Future<List<ObdDevice>> execute({DeviceStatus? status = DeviceStatus.active}) {
    return repository.getDevices(status: status);
  }
}
