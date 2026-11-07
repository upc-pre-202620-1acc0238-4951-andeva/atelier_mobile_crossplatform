import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_repository.dart';

/// Recarga la agenda de la sede para un día de Lima (`yyyy-MM-dd`). Sin red lanza
/// `NetworkException` y la caché sigue visible en `ObserveAppointmentsUseCase`.
class RefreshAppointmentsUseCase {
  final ReceptionRepository repository;

  const RefreshAppointmentsUseCase({required this.repository});

  Future<void> execute(String date) => repository.refreshAppointments(date);
}
