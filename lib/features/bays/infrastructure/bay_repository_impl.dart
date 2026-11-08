import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/cache_metadata_dao.dart';
import 'package:atelier_mobile_crossplatform/core/domain/missing_branch_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/bay_board.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/bay_repository.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/work_bay.dart';
import 'package:atelier_mobile_crossplatform/features/bays/infrastructure/local/bay_dao.dart';
import 'package:atelier_mobile_crossplatform/features/bays/infrastructure/local/bay_mappers.dart';
import 'package:atelier_mobile_crossplatform/features/bays/infrastructure/remote/work_bay_api.dart';
import 'package:atelier_mobile_crossplatform/features/bays/infrastructure/remote/work_bay_request_dtos.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/local/work_order_dao.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/local/work_order_mappers.dart';
import 'package:drift/drift.dart';

/// Singleton: reasignar un mecánico recarga los detalles de cualquier tablero que se esté observando.
class BayRepositoryImpl implements BayRepository {
  final WorkBayApi api;
  final BayDao bayDao;
  final WorkOrderDao workOrderDao;
  final CacheMetadataDao cacheMetadataDao;
  final WorkOrderRepository workOrders;
  final SessionManager session;
  final DateTime Function() now;

  /// Sube con cada mecánico reasignado: los detalles leídos antes ya no valen.
  int _mechanicVersion = 0;
  final _mechanicChanges = StreamController<void>.broadcast();

  BayRepositoryImpl({
    required this.api,
    required this.bayDao,
    required this.workOrderDao,
    required this.cacheMetadataDao,
    required this.workOrders,
    required this.session,
    this.now = DateTime.now,
  });

  @override
  Future<void> refreshBranchBays() async {
    final current = await session.getSession();
    if (current == null) throw StateError('Sin sesión');
    final branchId = current.branchId;
    if (branchId == null) throw const MissingBranchException();
    final timestamp = now().millisecondsSinceEpoch;
    final rows = (await api.getBays(branchId))
        .map((dto) => dto.toCompanion(branchId, timestamp))
        .toList();
    await bayDao.replaceBranch(branchId, rows);
    await cacheMetadataDao.upsert(
      CacheMetadataCompanion(
        scope: Value(bayCacheScope(branchId)),
        lastSyncedAt: Value(timestamp),
        recordCount: Value(rows.length),
      ),
    );
  }

  @override
  Future<bool> canReadBoard() async {
    return (await session.getSession())?.has(Permission.baysRead) ?? false;
  }

  @override
  Stream<List<BayBoardItem>> observeBoard() {
    return session.switchOn<String?, List<BayBoardItem>>(
      (current) => current?.branchId,
      (branchId) =>
          branchId == null ? Stream.value(const []) : _board(branchId),
    );
  }

  /// La caché sale enseguida; el detalle de cada orden se lee una vez por suscripción y uno que falla
  /// no se reintenta hasta la siguiente (como Android).
  Stream<List<BayBoardItem>> _board(String branchId) {
    return Stream.multi((controller) {
      List<WorkBay>? bays;
      Map<String, WorkOrder>? orders;
      final details = <String, List<TaskDetail>>{};
      final requested = <String>{};
      var version = _mechanicVersion;
      var closed = false;

      void emit() {
        final currentBays = bays;
        final currentOrders = orders;
        if (closed || currentBays == null || currentOrders == null) return;
        final at = now();
        controller.add([
          for (final bay in currentBays)
            BayBoardItem(
              bay: bay,
              occupant: _occupant(bay, currentOrders, details, at),
            ),
        ]);
      }

      void loadDetails() {
        if (version != _mechanicVersion) {
          version = _mechanicVersion;
          requested.clear();
          details.clear();
        }
        final ids = {...?bays?.map((b) => b.currentWorkOrderId).nonNulls};
        requested.removeWhere((id) => !ids.contains(id));
        details.removeWhere((id, _) => !ids.contains(id));
        for (final id in ids) {
          if (!requested.add(id)) continue;
          final askedAt = version;
          workOrders.getDetail(WorkOrderId(id)).then(
            (detail) {
              if (closed || askedAt != version || !requested.contains(id)) {
                return;
              }
              details[id] = detail.tasks;
              emit();
            },
            // Un detalle ilegible o sin red no tumba el tablero: queda sin mecánicos ni tiempo.
            onError: (Object _) {},
          );
        }
      }

      final subscriptions = [
        bayDao.watchBranch(branchId).listen((rows) {
          bays = rows.map((row) => row.toDomain()).toList();
          loadDetails();
          emit();
        }, onError: controller.addError),
        workOrders.observeBranchWorkOrders().listen((list) {
          orders = {for (final order in list) order.id.value: order};
          emit();
        }, onError: controller.addError),
        _mechanicChanges.stream.listen((_) {
          loadDetails();
          emit();
        }),
      ];
      controller.onCancel = () async {
        closed = true;
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
      };
    });
  }

  BayOccupant? _occupant(
    WorkBay bay,
    Map<String, WorkOrder> orders,
    Map<String, List<TaskDetail>> details,
    DateTime at,
  ) {
    final workOrderId = bay.currentWorkOrderId;
    if (workOrderId == null) return null;
    final order = orders[workOrderId];
    final tasks = details[workOrderId];
    return BayOccupant(
      workOrderId: workOrderId,
      internalNumber: order?.internalNumber,
      plate: order?.plate,
      mechanicIds: [
        ...{...?tasks?.map((task) => task.mechanicId).nonNulls},
      ],
      laborElapsed: tasks == null ? null : laborElapsed(tasks, at),
    );
  }

  @override
  Future<void> reassignBay(String workOrderId, String bayId) async {
    final dto = await api.reassignBay(
      workOrderId,
      AssignWorkBayRequestDto(bayId: bayId),
    );
    await workOrderDao.saveHeader(dto.toEntity(now().millisecondsSinceEpoch));
    try {
      await refreshBranchBays();
    } catch (_) {
      // Cortesía: la reasignación ya se hizo; el sondeo traerá las bahías.
    }
  }

  @override
  Future<void> reassignMechanic(String taskId, String mechanicId) async {
    await api.reassignMechanic(
      taskId,
      AssignTaskMechanicRequestDto(mechanicId: mechanicId),
    );
    _mechanicVersion++;
    _mechanicChanges.add(null);
  }
}
