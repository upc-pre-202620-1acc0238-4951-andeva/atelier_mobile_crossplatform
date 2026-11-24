import 'package:atelier_mobile_crossplatform/features/reception/domain/appointment.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_repository.dart';

/// Observa la agenda de un día de Lima (`yyyy-MM-dd`) o, con [to], la del rango [date]–[to].
class ObserveAppointmentsUseCase {
  final ReceptionRepository repository;

  const ObserveAppointmentsUseCase({required this.repository});

  Stream<List<Appointment>> execute(String date, {String? to}) {
    if (to == null || to == date) return repository.observeAppointments(date);
    return repository.observeAppointmentsRange(date, to);
  }
}
