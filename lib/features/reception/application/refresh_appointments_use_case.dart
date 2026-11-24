import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_repository.dart';

/// Recarga la agenda de la sede para un día de Lima (`yyyy-MM-dd`) o, con [to], para el rango
/// [date]–[to]. Sin red lanza `NetworkException` y la caché sigue visible en
/// `ObserveAppointmentsUseCase`.
class RefreshAppointmentsUseCase {
  final ReceptionRepository repository;

  const RefreshAppointmentsUseCase({required this.repository});

  Future<void> execute(String date, {String? to}) {
    if (to == null || to == date) return repository.refreshAppointments(date);
    return repository.refreshAppointmentsRange(date, to);
  }
}
