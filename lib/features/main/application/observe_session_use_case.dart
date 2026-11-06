import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/main/domain/session_repository.dart';

class ObserveSessionUseCase {
  final SessionRepository repository;

  const ObserveSessionUseCase({required this.repository});

  Stream<Session?> execute() => repository.watchSession();
}
