import 'package:atelier_mobile_crossplatform/core/domain/notification_record.dart';
import 'package:atelier_mobile_crossplatform/core/domain/push_destination.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/push_inbox.dart';
import 'package:atelier_mobile_crossplatform/features/main/infrastructure/push_destination_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('historial', _historyTests);

  late _Inbox inbox;
  late PushDestinationRepositoryImpl repository;

  setUp(() {
    inbox = _Inbox();
    repository = PushDestinationRepositoryImpl(inbox: inbox);
  });

  test('entrega un push tocado antes de suscribirse', () async {
    inbox.post(const ClockInDestination('s1'));

    expect(
      await repository.watchPending().first,
      const ClockInDestination('s1'),
    );
  });

  test('consume lo devuelve una sola vez y emite null', () async {
    final seen = <PushDestination?>[];
    final subscription = repository.watchPending().listen(seen.add);
    addTearDown(subscription.cancel);

    inbox.post(const WorkOrderDetailDestination('w1'));
    expect(repository.consume(), const WorkOrderDetailDestination('w1'));
    expect(repository.consume(), isNull);
    await pumpEventQueue();

    expect(seen, [null, const WorkOrderDetailDestination('w1'), null]);
  });

  test('cancelar deja de escuchar al inbox', () async {
    final subscription = repository.watchPending().listen((_) {});
    await subscription.cancel();

    expect(inbox.listening, isFalse);
  });

  test('los destinos se comparan por tipo e ids', () {
    expect(
      const TaskDetailDestination('w', 't'),
      const TaskDetailDestination('w', 't'),
    );
    expect(
      const TaskDetailDestination('w', 't').hashCode,
      const TaskDetailDestination('w', 't').hashCode,
    );
    expect(
      const TaskDetailDestination('w', 't'),
      isNot(const TaskDetailDestination('w', 'x')),
    );
    expect(
      const TaskDetailDestination('w', 't'),
      isNot(const TaskProductsDestination('w', 't')),
    );
  });
}

void _historyTests() {
  late PushInbox inbox;
  late PushDestinationRepositoryImpl repository;

  setUp(() {
    inbox = PushInbox();
    repository = PushDestinationRepositoryImpl(inbox: inbox);
  });

  test('watchHistory repite el valor actual y emite al llegar un aviso', () async {
    final seen = <List<NotificationRecord>>[];
    final subscription = repository.watchHistory().listen(seen.add);
    addTearDown(subscription.cancel);

    inbox.record('Aviso', 'Cuerpo', const ClockInDestination('s1'));
    await pumpEventQueue();

    expect(seen.map((list) => list.length), [0, 1]);
  });

  test('open marca leído y deja el destino pendiente', () {
    inbox.record('Aviso', '', const WorkOrderDetailDestination('w1'));
    final id = inbox.history.single.id;

    repository.open(id);

    expect(inbox.history.single.read, isTrue);
    expect(repository.consume(), const WorkOrderDetailDestination('w1'));
  });

  test('open con un id desconocido no hace nada', () {
    repository.open('missing');

    expect(inbox.pending, isNull);
  });

  test('markAllRead marca todo', () {
    inbox.record('a', '', const ClockInDestination('s'));
    inbox.record('b', '', const ClockInDestination('s'));

    repository.markAllRead();

    expect(inbox.history.every((record) => record.read), isTrue);
  });
}

class _Inbox extends PushInbox {
  bool get listening => hasListeners;
}
