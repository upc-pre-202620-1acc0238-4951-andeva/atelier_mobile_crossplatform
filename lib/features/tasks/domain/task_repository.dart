import 'dart:io';

import 'package:atelier_mobile_crossplatform/features/tasks/domain/part_option.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/pause_reason.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/pending_evidence.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_product.dart';
import 'package:decimal/decimal.dart';

abstract class TaskRepository {
  Stream<List<Task>> observeMyTasks();

  Stream<Task?> observeTask(TaskId id);

  Future<void> refreshMyTasks();

  Future<TaskDetail> getDetail(TaskId id);

  Future<TaskDetail> start(TaskId id);

  Future<TaskDetail> pause(TaskId id, PauseReason reason);

  Future<TaskDetail> requestSuspension(
    TaskId id,
    String missingItemDescription, {
    String? inventoryItemId,
  });

  Future<TaskDetail> approveSuspension(TaskId id);

  Future<TaskDetail> rejectSuspension(TaskId id);

  Future<TaskDetail> resume(TaskId id);

  Future<TaskDetail> complete(
    TaskId id,
    Decimal actualLaborHours, {
    String? notes,
  });

  Future<void> attachEvidence(
    TaskId id,
    String workOrderId,
    File photo,
    String description,
  );

  Stream<List<PendingEvidence>> observePendingEvidence(TaskId id);

  Future<List<PartOption>> searchParts(String query);

  Future<TaskProduct> addPart(TaskId id, String productId, Decimal quantity);

  Future<TaskDetail> updatePartQuantity(
    TaskId id,
    String productId,
    Decimal quantity,
  );

  Future<void> removePart(TaskId id, String productId);
}
