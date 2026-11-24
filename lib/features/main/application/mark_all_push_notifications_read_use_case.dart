import 'package:atelier_mobile_crossplatform/features/main/domain/push_destination_repository.dart';

class MarkAllPushNotificationsReadUseCase {
  final PushDestinationRepository repository;

  const MarkAllPushNotificationsReadUseCase({required this.repository});

  void execute() => repository.markAllRead();
}
