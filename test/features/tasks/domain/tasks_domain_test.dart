import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/evidence_kind.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/hold_reason.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/invalid_task_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/labor_time.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/part_option.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/pause_reason.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TaskId', () {
    test('valida ids no vacíos', () {
      expect(const TaskId('123').isValid, isTrue);
      expect(const TaskId('').isValid, isFalse);
      expect(const TaskId('   ').isValid, isFalse);
    });
  });

  group('TaskStatus', () {
    test('mapea cadenas correctamente', () {
      expect(TaskStatus.fromString('PENDING'), TaskStatus.pending);
      expect(TaskStatus.fromString('ASSIGNED'), TaskStatus.assigned);
      expect(TaskStatus.fromString('IN_PROGRESS'), TaskStatus.inProgress);
      expect(TaskStatus.fromString('ON_HOLD'), TaskStatus.onHold);
      expect(TaskStatus.fromString('COMPLETED'), TaskStatus.completed);
      expect(TaskStatus.fromString('CANCELLED'), TaskStatus.cancelled);
      expect(TaskStatus.fromString('UNKNOWN'), isNull);
      expect(TaskStatus.fromString(null), isNull);
    });
  });

  group('HoldReason', () {
    test('identifica pausas del mecánico frente a suspensiones', () {
      expect(HoldReason.breakTime.isMechanicPause, isTrue);
      expect(HoldReason.endOfShift.isMechanicPause, isTrue);
      expect(HoldReason.defectivePart.isMechanicPause, isFalse);
      expect(HoldReason.waitingParts.isMechanicPause, isFalse);
      expect(HoldReason.waitingForParts.isMechanicPause, isFalse);

      expect(HoldReason.fromString('BREAK'), HoldReason.breakTime);
      expect(HoldReason.fromString('END_OF_SHIFT'), HoldReason.endOfShift);
      expect(HoldReason.fromString('DEFECTIVE_PART'), HoldReason.defectivePart);
      expect(HoldReason.fromString(null), isNull);
    });
  });

  group('PauseReason', () {
    test('valores aceptados por la API', () {
      expect(PauseReason.breakTime.value, 'BREAK');
      expect(PauseReason.endOfShift.value, 'END_OF_SHIFT');
    });
  });

  group('EvidenceKind', () {
    test('formatea la descripción con prefijo obligatorio', () {
      expect(EvidenceKind.disassembly.describe(null), 'Desmontaje');
      expect(EvidenceKind.disassembly.describe(''), 'Desmontaje');
      expect(EvidenceKind.disassembly.describe('   '), 'Desmontaje');
      expect(
        EvidenceKind.disassembly.describe('Faro roto'),
        'Desmontaje: Faro roto',
      );
      expect(
        EvidenceKind.assembly.describe('Pieza nueva instalada'),
        'Montaje: Pieza nueva instalada',
      );
    });
  });

  group('LaborTime', () {
    test('calcula segundos efectivos y horas redondeadas a 2 decimales', () {
      final started = DateTime.utc(2026, 11, 6, 8, 0, 0);
      final now = DateTime.utc(2026, 11, 6, 10, 30, 0); // 2.5 hours = 9000 seconds
      const pausedSeconds = 1800; // 30 minutes paused

      final effective = LaborTime.effectiveSeconds(started, pausedSeconds, now);
      expect(effective, 7200); // 2 hours

      final hours = LaborTime.suggestedHours(started, pausedSeconds, now);
      expect(hours, 2.0);

      // No puede ser negativo
      final futurePaused = LaborTime.effectiveSeconds(started, 20000, now);
      expect(futurePaused, 0);
    });
  });

  group('TaskValidation', () {
    test('valida horas, notas, motivo faltante y cantidades', () {
      expect(TaskValidation.isLaborHours(0.0), isTrue);
      expect(TaskValidation.isLaborHours(1.5), isTrue);
      expect(TaskValidation.isLaborHours(-0.1), isFalse);

      expect(TaskValidation.isNotes(null), isTrue);
      expect(TaskValidation.isNotes('OK'), isTrue);
      expect(TaskValidation.isNotes('a' * 1000), isTrue);
      expect(TaskValidation.isNotes('a' * 1001), isFalse);

      expect(TaskValidation.isMissingItem(''), isFalse);
      expect(TaskValidation.isMissingItem('   '), isFalse);
      expect(TaskValidation.isMissingItem('Filtro de aceite'), isTrue);
      expect(TaskValidation.isMissingItem('a' * 500), isTrue);
      expect(TaskValidation.isMissingItem('a' * 501), isFalse);

      expect(TaskValidation.isEvidenceDescription('a' * 500), isTrue);
      expect(TaskValidation.isEvidenceDescription('a' * 501), isFalse);

      expect(TaskValidation.isQuantity(1.0), isTrue);
      expect(TaskValidation.isQuantity(0.0), isFalse);
      expect(TaskValidation.isQuantity(-1.0), isFalse);
    });
  });

  group('PartOption', () {
    test('disponible solo si stock > 0', () {
      const available = PartOption(
        id: 'p1',
        name: 'Pastillas',
        totalStock: 5.0,
      );
      expect(available.isAvailable, isTrue);

      const outOfStock = PartOption(
        id: 'p2',
        name: 'Disco',
        totalStock: 0.0,
      );
      expect(outOfStock.isAvailable, isFalse);
    });
  });

  group('Task and TaskDetail flags', () {
    test('isPausedByMechanic, isSuspended, hasPendingSuspension', () {
      const task = Task(
        id: TaskId('t1'),
        workOrderId: 'wo1',
        vehicleId: 'v1',
        description: 'Cambio de aceite',
        status: TaskStatus.onHold,
        holdReason: HoldReason.breakTime,
        pendingSuspensionReason: 'Esperando filtro',
        totalPausedSeconds: 300,
      );
      expect(task.isPausedByMechanic, isTrue);
      expect(task.isSuspended, isFalse);
      expect(task.hasPendingSuspension, isTrue);

      const suspendedTask = Task(
        id: TaskId('t2'),
        workOrderId: 'wo1',
        vehicleId: 'v1',
        description: 'Cambio de embrague',
        status: TaskStatus.onHold,
        holdReason: HoldReason.defectivePart,
        totalPausedSeconds: 0,
      );
      expect(suspendedTask.isPausedByMechanic, isFalse);
      expect(suspendedTask.isSuspended, isTrue);
      expect(suspendedTask.hasPendingSuspension, isFalse);

      final detail = TaskDetail(
        id: const TaskId('t1'),
        workOrderId: 'wo1',
        status: TaskStatus.onHold,
        holdReason: HoldReason.endOfShift,
        description: 'Detalle',
        totalPausedSeconds: 100,
        price: Money.of('150.00', Money.pen),
      );
      expect(detail.isPausedByMechanic, isTrue);
      expect(detail.isSuspended, isFalse);
    });

    test('InvalidTaskInputException toString', () {
      expect(
        const InvalidTaskInputException('actualLaborHours').toString(),
        'InvalidTaskInputException: actualLaborHours',
      );
    });
  });
}
