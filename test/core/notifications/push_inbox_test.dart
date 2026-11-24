import 'package:atelier_mobile_crossplatform/core/notifications/push_inbox.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/push_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late PushInbox inbox;
  final clock = DateTime.utc(2026, 11, 20, 15);

  setUp(() => inbox = PushInbox(now: () => clock));

  test('record guarda el aviso con su canal y sin leer', () {
    inbox.record('Tarea', 'Te asignaron', const TaskDetailDestination('w', 't'));

    final record = inbox.history.single;
    expect(record.title, 'Tarea');
    expect(record.body, 'Te asignaron');
    expect(record.channel, PushChannel.tasks);
    expect(record.read, isFalse);
    expect(record.receivedAt, clock);
    expect(record.destination, const TaskDetailDestination('w', 't'));
  });

  test('sin título o cuerpo en el push quedan null y vacío', () {
    inbox.record('  ', null, const LowStockAlertsDestination('i1'));

    expect(inbox.history.single.title, isNull);
    expect(inbox.history.single.body, '');
    expect(inbox.history.single.channel, PushChannel.inventory);
  });

  test('el más reciente va primero y se conservan 50', () {
    for (var i = 0; i < 55; i++) {
      inbox.record('t$i', '', const ClockInDestination('s'));
    }

    expect(inbox.history, hasLength(PushInbox.maxHistory));
    expect(inbox.history.first.title, 't54');
    expect(inbox.history.last.title, 't5');
  });

  test('markRead y markAllRead', () {
    inbox.record('a', '', const MyAttendanceDestination('1'));
    inbox.record('b', '', const MyAttendanceDestination('2'));
    final newest = inbox.history.first.id;

    inbox.markRead(newest);
    expect(inbox.history.map((r) => r.read), [true, false]);

    inbox.markAllRead();
    expect(inbox.history.every((r) => r.read), isTrue);
  });

  test('clear borra historial y destino pendiente, y avisa', () {
    inbox.record('a', '', const MyAttendanceDestination('1'));
    inbox.post(const ClockInDestination('s'));
    var notified = 0;
    inbox.addListener(() => notified++);

    inbox.clear();

    expect(inbox.history, isEmpty);
    expect(inbox.pending, isNull);
    expect(notified, 1);
  });

  test('consume sigue devolviendo el destino una sola vez', () {
    inbox.post(const ClockInDestination('s'));

    expect(inbox.consume(), const ClockInDestination('s'));
    expect(inbox.consume(), isNull);
  });
}
