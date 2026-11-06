import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_repository.dart';

/// Al abrir Asistencia: perfil laboral, sedes, turno e historial (red → Drift). Sin red sigue la caché.
class RefreshAttendanceUseCase {
  final AttendanceRepository repository;

  const RefreshAttendanceUseCase({required this.repository});

  Future<void> execute() => repository.refresh();
}
