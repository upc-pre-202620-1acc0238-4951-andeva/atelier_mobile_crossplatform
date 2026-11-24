import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/appointment_dto.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/cancel_appointment_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/reschedule_appointment_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/schedule_appointment_request_dto.dart';

/// Citas de docs/api/crm.md.
class AppointmentApi {
  final ApiClient client;

  const AppointmentApi({required this.client});

  /// [date] es el día de Lima (`yyyy-MM-dd`).
  Future<List<AppointmentDto>> getAppointments(
    String branchId,
    String date,
  ) async {
    final List list = await client.get(
      '/api/v1/appointments',
      query: {'branchId': branchId, 'date': date},
    );
    return list
        .map((e) => AppointmentDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AppointmentDto> schedule(ScheduleAppointmentRequestDto body) async {
    final Map<String, dynamic> json = await client.post(
      '/api/v1/appointments',
      body: body.toJson(),
    );
    return AppointmentDto.fromJson(json);
  }

  Future<AppointmentDto> confirm(String id) async {
    final Map<String, dynamic> json = await client.post(
      '/api/v1/appointments/$id/confirm',
    );
    return AppointmentDto.fromJson(json);
  }

  Future<AppointmentDto> reschedule(
    String id,
    RescheduleAppointmentRequestDto body,
  ) async {
    final Map<String, dynamic> json = await client.post(
      '/api/v1/appointments/$id/reschedule',
      body: body.toJson(),
    );
    return AppointmentDto.fromJson(json);
  }

  Future<AppointmentDto> cancel(
    String id,
    CancelAppointmentRequestDto body,
  ) async {
    final Map<String, dynamic> json = await client.post(
      '/api/v1/appointments/$id/cancel',
      body: body.toJson(),
    );
    return AppointmentDto.fromJson(json);
  }

  /// Devuelve la cita; la orden en borrador se crea después, de forma asíncrona (H10).
  Future<AppointmentDto> arrive(String id) async {
    final Map<String, dynamic> json = await client.post(
      '/api/v1/appointments/$id/arrive',
    );
    return AppointmentDto.fromJson(json);
  }
}
