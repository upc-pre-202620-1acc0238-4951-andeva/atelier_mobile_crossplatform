import 'package:atelier_mobile_crossplatform/core/domain/push_destination.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/push_inbox.dart';
import 'package:atelier_mobile_crossplatform/features/main/domain/push_destination_repository.dart';

class PushDestinationRepositoryImpl implements PushDestinationRepository {
  final PushInbox inbox;

  const PushDestinationRepositoryImpl({required this.inbox});

  @override
  Stream<PushDestination?> watchPending() {
    return Stream.multi((controller) {
      void emit() => controller.add(inbox.pending);

      inbox.addListener(emit);
      controller.onCancel = () => inbox.removeListener(emit);
      emit();
    });
  }

  @override
  PushDestination? consume() => inbox.consume();
}
