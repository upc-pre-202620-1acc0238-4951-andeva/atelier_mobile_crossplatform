import 'package:atelier_mobile_crossplatform/core/domain/notification_record.dart';
import 'package:atelier_mobile_crossplatform/core/domain/push_destination.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/push_inbox.dart';
import 'package:atelier_mobile_crossplatform/features/main/domain/push_destination_repository.dart';

class PushDestinationRepositoryImpl implements PushDestinationRepository {
  final PushInbox inbox;

  const PushDestinationRepositoryImpl({required this.inbox});

  @override
  Stream<PushDestination?> watchPending() => _watch(() => inbox.pending);

  @override
  PushDestination? consume() => inbox.consume();

  @override
  Stream<List<NotificationRecord>> watchHistory() => _watch(() => inbox.history);

  @override
  void open(String id) {
    final record = inbox.history.where((item) => item.id == id).firstOrNull;
    if (record == null) return;
    inbox.markRead(id);
    final destination = record.destination;
    if (destination != null) inbox.post(destination);
  }

  @override
  void markAllRead() => inbox.markAllRead();

  Stream<T> _watch<T>(T Function() read) {
    return Stream.multi((controller) {
      void emit() => controller.add(read());

      inbox.addListener(emit);
      controller.onCancel = () => inbox.removeListener(emit);
      emit();
    });
  }
}
