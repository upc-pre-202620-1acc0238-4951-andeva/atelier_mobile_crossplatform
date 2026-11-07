import 'package:atelier_mobile_crossplatform/features/reception/domain/appointment.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_repository.dart';

class ObserveAppointmentsUseCase {
  final ReceptionRepository repository;

  const ObserveAppointmentsUseCase({required this.repository});

  Stream<List<Appointment>> execute(String date) {
    return repository.observeAppointments(date);
  }
}
