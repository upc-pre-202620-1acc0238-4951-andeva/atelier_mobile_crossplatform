import 'package:atelier_mobile_crossplatform/core/domain/notification_record.dart';
import 'package:atelier_mobile_crossplatform/core/domain/push_destination.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/mark_all_push_notifications_read_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_push_history_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/open_push_notification_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/domain/push_destination_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements PushDestinationRepository {}

void main() {
  late _MockRepository repository;

  setUp(() => repository = _MockRepository());

  test('ObservePushHistoryUseCase entrega el historial del repositorio', () {
    final records = [
      NotificationRecord(
        id: '1',
        title: 'Aviso',
        body: '',
        destination: const ClockInDestination('s1'),
        channel: PushChannel.attendance,
        receivedAt: DateTime.utc(2026, 11, 20),
      ),
    ];
    when(() => repository.watchHistory()).thenAnswer((_) => Stream.value(records));

    expect(ObservePushHistoryUseCase(repository: repository).execute(), emits(records));
  });

  test('OpenPushNotificationUseCase abre el aviso por id', () {
    OpenPushNotificationUseCase(repository: repository).execute('1');

    verify(() => repository.open('1')).called(1);
  });

  test('MarkAllPushNotificationsReadUseCase marca todo', () {
    MarkAllPushNotificationsReadUseCase(repository: repository).execute();

    verify(() => repository.markAllRead()).called(1);
  });
}
