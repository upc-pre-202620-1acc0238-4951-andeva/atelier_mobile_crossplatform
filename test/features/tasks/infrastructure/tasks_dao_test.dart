import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('TaskDao', () {
    test('replaceMine guarda tareas y preserva detalle del mismo estado', () async {
      final dao = database.taskDao;

      // Inserción inicial
      await dao.replaceMine([
        const TasksCompanion(
          id: Value('t1'),
          workOrderId: Value('wo1'),
          vehicleId: Value('v1'),
          status: Value('IN_PROGRESS'),
          description: Value('Tarea 1'),
          totalPausedSeconds: Value(0),
          syncedAt: Value(1000),
        ),
      ]);

      // Enriquecer detalle
      await dao.mergeDetail(
        id: 't1',
        status: 'IN_PROGRESS',
        description: 'Tarea 1 modificada',
        serviceName: 'Alineamiento',
        mechanicId: 'm1',
        totalPausedSeconds: 50,
        syncedAt: 1500,
      );

      final before = await dao.findById('t1');
      expect(before?.serviceName, 'Alineamiento');
      expect(before?.mechanicId, 'm1');

      // Segunda recarga: el backend aún no envía serviceName, debe preservarse
      await dao.replaceMine([
        const TasksCompanion(
          id: Value('t1'),
          workOrderId: Value('wo1'),
          vehicleId: Value('v1'),
          status: Value('IN_PROGRESS'),
          description: Value('Tarea 1 desde backend'),
          totalPausedSeconds: Value(50),
          syncedAt: Value(2000),
        ),
      ]);

      final after = await dao.findById('t1');
      expect(after?.serviceName, 'Alineamiento');
      expect(after?.mechanicId, 'm1');
      expect(after?.description, 'Tarea 1 desde backend');

      await dao.deleteById('t1');
      expect(await dao.findById('t1'), isNull);
    });

    group('replaceMine, como TaskDaoTest de Android', () {
      TasksCompanion row(String id, String status, {String? holdReason}) {
        return TasksCompanion(
          id: Value(id),
          workOrderId: const Value('wo1'),
          vehicleId: const Value('v1'),
          status: Value(status),
          description: const Value(''),
          holdReason: holdReason == null
              ? const Value.absent()
              : Value(holdReason),
          totalPausedSeconds: const Value(0),
          syncedAt: const Value(0),
        );
      }

      Future<void> saveDetail(String id, String status) async {
        await database.taskDao.mergeDetail(
          id: id,
          status: status,
          description: '',
          serviceName: 'Frenos',
          mechanicId: 'u1',
          holdReason: 'BREAK',
          missingItemDescription: 'Pastillas',
          pendingSuspensionReason: 'Falta repuesto',
          totalPausedSeconds: 0,
          syncedAt: 1,
        );
      }

      test('conserva el detalle y descarta lo de pausa si cambió el estado', () async {
        final dao = database.taskDao;
        await dao.replaceMine([row('t1', 'ON_HOLD'), row('t2', 'ON_HOLD')]);
        await saveDetail('t1', 'ON_HOLD');
        await saveDetail('t2', 'ON_HOLD');

        await dao.replaceMine([row('t1', 'ON_HOLD'), row('t2', 'IN_PROGRESS')]);

        final kept = (await dao.findById('t1'))!;
        expect(kept.serviceName, 'Frenos');
        expect(kept.mechanicId, 'u1');
        expect(kept.holdReason, 'BREAK');
        expect(kept.missingItemDescription, 'Pastillas');
        expect(kept.pendingSuspensionReason, 'Falta repuesto');

        final changed = (await dao.findById('t2'))!;
        expect(changed.serviceName, 'Frenos');
        expect(changed.mechanicId, 'u1');
        expect(changed.holdReason, isNull);
        expect(changed.missingItemDescription, isNull);
        expect(changed.pendingSuspensionReason, isNull);
      });

      test('un motivo que venga en la recarga gana al guardado', () async {
        final dao = database.taskDao;
        await dao.replaceMine([row('t1', 'ON_HOLD'), row('t2', 'ON_HOLD')]);
        await saveDetail('t1', 'ON_HOLD');
        await saveDetail('t2', 'ON_HOLD');

        await dao.replaceMine([
          row('t1', 'ON_HOLD', holdReason: 'DEFECTIVE_PART'),
          row('t2', 'IN_PROGRESS', holdReason: 'DEFECTIVE_PART'),
        ]);

        expect((await dao.findById('t1'))!.holdReason, 'DEFECTIVE_PART');
        expect((await dao.findById('t2'))!.holdReason, 'DEFECTIVE_PART');
      });

      test('borra lo que ya no está asignado y mergeDetail devuelve 0', () async {
        final dao = database.taskDao;
        await dao.replaceMine([row('t1', 'ASSIGNED'), row('t2', 'ASSIGNED')]);

        await dao.replaceMine([row('t2', 'ASSIGNED')]);

        final rows = await dao.observeAll().first;
        expect(rows.map((r) => r.task.id), ['t2']);
        expect(
          await dao.mergeDetail(
            id: 't1',
            status: 'IN_PROGRESS',
            description: '',
            totalPausedSeconds: 0,
            syncedAt: 1,
          ),
          0,
        );
      });
    });

    test('observeAll ordena por estado (IN_PROGRESS, ON_HOLD, resto) y une refs', () async {
      final taskDao = database.taskDao;
      final vehicleDao = database.vehicleDao;
      final bayDao = database.bayDao;

      // Vehículo y Bahía
      await vehicleDao.saveFromServer(
        const VehiclesCompanion(
          id: Value('v1'),
          plate: Value('ABC-123'),
          brand: Value('Toyota'),
          model: Value('Corolla'),
          syncedAt: Value(1000),
        ),
      );
      await bayDao.replaceBranch('b1', [
        const BaysCompanion(
          id: Value('bay1'),
          branchId: Value('b1'),
          name: Value('Elevador 1'),
          bayType: Value('LIFT'),
          status: Value('OCCUPIED'),
          syncedAt: Value(1000),
        ),
      ]);

      // 3 tareas: COMPLETED, ON_HOLD, IN_PROGRESS
      await taskDao.replaceMine([
        const TasksCompanion(
          id: Value('t_completed'),
          workOrderId: Value('wo1'),
          workOrderNumber: Value(10),
          vehicleId: Value('v1'),
          bayId: Value('bay1'),
          status: Value('COMPLETED'),
          description: Value('Completada'),
          totalPausedSeconds: Value(0),
          syncedAt: Value(1000),
        ),
        const TasksCompanion(
          id: Value('t_hold'),
          workOrderId: Value('wo1'),
          workOrderNumber: Value(20),
          vehicleId: Value('v1'),
          bayId: Value('bay1'),
          status: Value('ON_HOLD'),
          description: Value('En pausa'),
          totalPausedSeconds: Value(0),
          syncedAt: Value(1000),
        ),
        const TasksCompanion(
          id: Value('t_progress'),
          workOrderId: Value('wo1'),
          workOrderNumber: Value(30),
          vehicleId: Value('v1'),
          bayId: Value('bay1'),
          status: Value('IN_PROGRESS'),
          description: Value('En curso'),
          totalPausedSeconds: Value(0),
          syncedAt: Value(1000),
        ),
      ]);

      final all = await taskDao.observeAll().first;
      expect(all.length, 3);
      expect(all[0].task.id, 't_progress');
      expect(all[0].plate, 'ABC-123');
      expect(all[0].bayName, 'Elevador 1');

      expect(all[1].task.id, 't_hold');
      expect(all[2].task.id, 't_completed');

      final single = await taskDao.observeById('t_progress').first;
      expect(single?.task.id, 't_progress');
      expect(single?.plate, 'ABC-123');
    });
  });

  group('VehicleDao y BayDao', () {
    test('VehicleDao previene duplicados de placa borrando registro previo', () async {
      final dao = database.vehicleDao;
      await dao.saveFromServer(
        const VehiclesCompanion(
          id: Value('v1'),
          plate: Value('XYZ-789'),
          brand: Value('Honda'),
          model: Value('Civic'),
          syncedAt: Value(1000),
        ),
      );

      // Reasignación de placa a nuevo id
      await dao.saveFromServer(
        const VehiclesCompanion(
          id: Value('v2'),
          plate: Value('XYZ-789'),
          brand: Value('Honda'),
          model: Value('Civic New'),
          syncedAt: Value(2000),
        ),
      );

      expect(await dao.findById('v1'), isNull);
      final v2 = await dao.findByPlate('XYZ-789');
      expect(v2?.id, 'v2');
      expect(v2?.model, 'Civic New');
    });

    test('BayDao replaceBranch reemplaza solo la sede indicada', () async {
      final dao = database.bayDao;
      await dao.replaceBranch('branchA', [
        const BaysCompanion(
          id: Value('bayA1'),
          branchId: Value('branchA'),
          name: Value('Bahía A1'),
          bayType: Value('LIFT'),
          status: Value('AVAILABLE'),
          syncedAt: Value(1000),
        ),
      ]);
      await dao.replaceBranch('branchB', [
        const BaysCompanion(
          id: Value('bayB1'),
          branchId: Value('branchB'),
          name: Value('Bahía B1'),
          bayType: Value('LIFT'),
          status: Value('AVAILABLE'),
          syncedAt: Value(1000),
        ),
      ]);

      expect((await dao.findById('bayA1'))?.name, 'Bahía A1');
      expect((await dao.findById('bayB1'))?.name, 'Bahía B1');

      // Reemplazar branchA con lista vacía
      await dao.replaceBranch('branchA', []);
      expect(await dao.findById('bayA1'), isNull);
      expect((await dao.findById('bayB1'))?.name, 'Bahía B1');
    });
  });
}
