import 'package:atelier_mobile_crossplatform/core/notifications/push_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  PushDestination? route(String type, [Map<String, String> extra = const {}]) {
    return PushRouter.route({'type': type, ...extra});
  }

  const task = {'workOrderId': 'wo1', 'taskId': 't1'};

  test('los diez tipos de la tabla abren su pantalla', () {
    const detail = TaskDetailDestination('wo1', 't1');
    expect(route('TASK_ASSIGNED', task), detail);
    expect(route('TASK_PAUSED', task), detail);
    expect(route('TASK_RESUMED', task), detail);
    expect(
      route('TASK_SUSPENSION_REQUESTED', task),
      const TaskSuspensionReviewDestination('wo1', 't1'),
    );
    expect(
      route('TASK_PART_CHARGED', task),
      const TaskProductsDestination('wo1', 't1'),
    );
    expect(
      route('WORK_ORDER_COMPLETED', {'workOrderId': 'wo1'}),
      const WorkOrderDetailDestination('wo1'),
    );
    expect(
      route('LOW_STOCK', {
        'itemId': 'i1',
        'currentStock': '9',
        'minimumStock': '10',
      }),
      const LowStockAlertsDestination('i1'),
    );
    expect(
      route('OVERTIME_RECORDED', {
        'attendanceId': 'a1',
        'membershipId': 'm1',
        'overtimeMinutes': '45',
      }),
      const CollaboratorAttendanceDestination('a1', 'm1'),
    );
    expect(
      route('JUSTIFICATION_REVIEWED', {
        'attendanceId': 'a1',
        'verdict': 'APPROVED',
      }),
      const MyAttendanceDestination('a1'),
    );
    expect(
      route('SHIFT_REMINDER', {'shiftId': 's1', 'startTime': '08:00:00'}),
      const ClockInDestination('s1'),
    );
  });

  test('tipo desconocido, sin ids o con ids vacíos se ignora sin fallar', () {
    expect(route('NEW_TYPE_FROM_BACKEND', task), isNull);
    expect(route('TASK_ASSIGNED', {'workOrderId': 'wo1'}), isNull);
    expect(route('LOW_STOCK', {'itemId': '  '}), isNull);
    expect(PushRouter.route(const {}), isNull);
  });

  test('tipos distintos con los mismos ids no son iguales', () {
    expect(
      const TaskDetailDestination('wo1', 't1'),
      isNot(const TaskProductsDestination('wo1', 't1')),
    );
  });

  test('cada destino va a su canal', () {
    expect(
      PushRouter.channelFor(const WorkOrderDetailDestination('wo1')),
      PushChannel.tasks,
    );
    expect(
      PushRouter.channelFor(const LowStockAlertsDestination('i1')),
      PushChannel.inventory,
    );
    expect(
      PushRouter.channelFor(const ClockInDestination('s1')),
      PushChannel.attendance,
    );
  });
}
