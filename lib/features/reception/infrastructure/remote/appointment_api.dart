import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/appointment_dto.dart';

/// Citas de docs/api/crm.md. Agendar, confirmar, reprogramar y cancelar no tienen historia móvil.
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

  /// Devuelve la cita; la orden en borrador se crea después, de forma asíncrona (H10).
  Future<AppointmentDto> arrive(String id) async {
    final Map<String, dynamic> json = await client.post(
      '/api/v1/appointments/$id/arrive',
    );
    return AppointmentDto.fromJson(json);
  }
}
