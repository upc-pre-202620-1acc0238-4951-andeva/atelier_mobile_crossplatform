import 'package:atelier_mobile_crossplatform/core/domain/push_destination.dart';
import 'package:atelier_mobile_crossplatform/features/main/domain/push_destination_repository.dart';

class ObservePushDestinationUseCase {
  final PushDestinationRepository repository;

  const ObservePushDestinationUseCase({required this.repository});

  Stream<PushDestination?> execute() => repository.watchPending();
}
