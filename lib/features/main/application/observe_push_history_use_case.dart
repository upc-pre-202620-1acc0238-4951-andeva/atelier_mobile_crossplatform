import 'package:atelier_mobile_crossplatform/core/domain/notification_record.dart';
import 'package:atelier_mobile_crossplatform/features/main/domain/push_destination_repository.dart';

class ObservePushHistoryUseCase {
  final PushDestinationRepository repository;

  const ObservePushHistoryUseCase({required this.repository});

  Stream<List<NotificationRecord>> execute() => repository.watchHistory();
}
