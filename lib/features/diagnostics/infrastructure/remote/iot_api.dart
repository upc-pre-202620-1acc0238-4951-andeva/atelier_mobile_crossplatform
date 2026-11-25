import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/remote/converted_appointment_dto.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/remote/iot_dtos.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/remote/latest_telemetry_dto.dart';

/// IoT de docs/api/iot.md que usa la app (US16–US21, US43 E1). `generate-async` queda sin usar: no hay
/// endpoint para consultar el trabajo (H21). De la telemetría remota se usa `latest` (US18); `history` no. El PDF de flota (US43 E2) es del paso 9.
class IotApi {
  static const _base = '/api/v1/iot';

  final ApiClient client;

  const IotApi({required this.client});

  Future<List<ObdDeviceDto>> getDevices({String? status}) async {
    final List list = await client.get(
      '$_base/devices',
      query: status == null ? null : {'status': status},
    );
    return list
        .map((e) => ObdDeviceDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// US18, lectura remota. 404 si el vehículo no tiene lecturas.
  Future<LatestTelemetryDto> getLatestTelemetry(String vehicleId) async {
    return LatestTelemetryDto.fromJson(await client.get('$_base/telemetry/vehicle/$vehicleId/latest'));
  }

  /// 409 si el identificador ya existe o se superó la cuota.
  Future<ObdDeviceDto> registerDevice({
    required String deviceIdentifier,
    required String connectionType,
    String? hardwareModel,
    String? firmwareVersion,
  }) async {
    return ObdDeviceDto.fromJson(
      await client.post(
        '$_base/devices',
        body: {
          'deviceIdentifier': deviceIdentifier,
          'connectionType': connectionType,
          'hardwareModel': ?hardwareModel,
          'firmwareVersion': ?firmwareVersion,
        },
      ),
    );
  }

  Future<ObdDeviceDto> updateDeviceStatus(String id, String status) async {
    return ObdDeviceDto.fromJson(
      await client.patch('$_base/devices/$id/status', body: {'status': status}),
    );
  }

  /// 404 = el vehículo no tiene escáner instalado.
  Future<DeviceInstallationDto> getActiveInstallation(String vehicleId) async {
    return DeviceInstallationDto.fromJson(
      await client.get('$_base/installations/vehicle/$vehicleId/active'),
    );
  }

  /// 409 si el dispositivo o el vehículo ya tienen una instalación activa.
  Future<DeviceInstallationDto> install({
    required String deviceId,
    required String vehicleId,
    int? currentOdometerKm,
  }) async {
    return DeviceInstallationDto.fromJson(
      await client.post(
        '$_base/installations/install',
        body: {
          'deviceId': deviceId,
          'vehicleId': vehicleId,
          'currentOdometerKm': currentOdometerKm ?? 0,
        },
      ),
    );
  }

  /// Sin `uninstalledAt` el backend usa su hora.
  Future<DeviceInstallationDto> uninstall(
    String id, {
    int? finalOdometerKm,
  }) async {
    return DeviceInstallationDto.fromJson(
      await client.post(
        '$_base/installations/$id/uninstall',
        body: {'finalOdometerKm': finalOdometerKm ?? 0},
      ),
    );
  }

  /// Si el vehículo ya tiene ese DTC activo devuelve esa falla (R3 de 06 §7).
  Future<VehicleFaultDto> registerFault(RegisterFaultRequestDto body) async {
    return VehicleFaultDto.fromJson(
      await client.post('$_base/faults', body: body.toJson()),
    );
  }

  Future<List<VehicleFaultDto>> getActiveFaults(String vehicleId) async {
    final List list = await client.get(
      '$_base/faults/vehicle/$vehicleId/active',
    );
    return list
        .map((e) => VehicleFaultDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Resolver dos veces responde 200.
  Future<VehicleFaultDto> resolveFault(String id) async {
    return VehicleFaultDto.fromJson(
      await client.post('$_base/faults/$id/resolve'),
    );
  }

  /// 202. Lecturas repetidas (vehículo + `timestamp`) se ignoran; 404 sin instalación activa (H16).
  Future<void> ingestTelemetry(Map<String, dynamic> body) async {
    await client.post('$_base/telemetry/batch', body: body);
  }

  /// 201. 422 `ERR_INSUFFICIENT_TELEMETRY`, 403 cuota o plan, 502 IA no disponible.
  Future<HealthReportCreatedDto> generateHealthReport(
    String vehicleId, {
    required int daysToAnalyze,
    bool? includeResolvedDtcHistory,
  }) async {
    return HealthReportCreatedDto.fromJson(
      await client.post(
        '$_base/health-reports/generate?vehicleId=$vehicleId',
        body: {
          'daysToAnalyze': daysToAnalyze,
          'includeResolvedDtcHistory': ?includeResolvedDtcHistory,
        },
      ),
    );
  }

  /// 404 = sin informes previos.
  Future<HealthReportCreatedDto> getLatestHealthReport(String vehicleId) async {
    return HealthReportCreatedDto.fromJson(
      await client.get(
        '$_base/health-reports/latest',
        query: {'vehicleId': vehicleId},
      ),
    );
  }

  Future<HealthReportDetailDto> getHealthReport(String reportId) async {
    return HealthReportDetailDto.fromJson(
      await client.get('$_base/health-reports/$reportId'),
    );
  }

  Future<ApiFile> getHealthReportPdf(String reportId) {
    return client.getBytes('$_base/health-reports/$reportId/pdf');
  }

  Future<List<PredictiveAlertDto>> getTenantAlerts() async {
    final List list = await client.get('$_base/alerts/tenant');
    return list
        .map((e) => PredictiveAlertDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<PredictiveAlertDto>> getVehicleAlerts(String vehicleId) async {
    final List list = await client.get('$_base/alerts/vehicle/$vehicleId');
    return list
        .map((e) => PredictiveAlertDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PredictiveAlertDto> acknowledgeAlert(String id) async {
    return PredictiveAlertDto.fromJson(
      await client.patch(
        '$_base/alerts/$id/acknowledge',
        body: const <String, Object?>{},
      ),
    );
  }

  /// El cuerpo es opcional: sede, fecha y hora, duración y motivo acordados con el cliente. Sin
  /// `scheduledAt` el backend elige la fecha.
  Future<ConvertedAppointmentDto> convertAlertToAppointment(
    String id, {
    String? branchId,
    String? scheduledAt,
    int? estimatedDurationMinutes,
    String? reason,
  }) async {
    return ConvertedAppointmentDto.fromJson(
      await client.post(
        '$_base/alerts/$id/convert-to-appointment',
        body: {
          'branchId': ?branchId,
          'scheduledAt': ?scheduledAt,
          'estimatedDurationMinutes': ?estimatedDurationMinutes,
          'reason': ?reason,
        },
      ),
    );
  }
}
