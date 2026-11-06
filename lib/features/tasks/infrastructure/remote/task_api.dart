import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/add_task_product_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/assigned_task_dto.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/attach_task_evidence_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/complete_task_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/hold_task_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/pause_task_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/task_product_dto.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/update_task_product_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/work_order_task_dto.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/work_order_task_image_dto.dart';

class TaskApi {
  final ApiClient client;

  const TaskApi({required this.client});

  Future<List<AssignedTaskDto>> getMyTasks() async {
    final List list = await client.get('/api/v1/tasks/my');
    return list
        .map((e) => AssignedTaskDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<WorkOrderTaskDto> getTask(String taskId) async {
    final Map<String, dynamic> json = await client.get('/api/v1/tasks/$taskId');
    return WorkOrderTaskDto.fromJson(json);
  }

  Future<WorkOrderTaskDto> start(String taskId) async {
    final Map<String, dynamic> json =
        await client.post('/api/v1/tasks/$taskId/start');
    return WorkOrderTaskDto.fromJson(json);
  }

  Future<WorkOrderTaskDto> pause(
    String taskId,
    PauseTaskRequestDto body,
  ) async {
    final Map<String, dynamic> json = await client.post(
      '/api/v1/tasks/$taskId/pause',
      body: body.toJson(),
    );
    return WorkOrderTaskDto.fromJson(json);
  }

  Future<WorkOrderTaskDto> requestHold(
    String taskId,
    HoldTaskRequestDto body,
  ) async {
    final Map<String, dynamic> json = await client.post(
      '/api/v1/tasks/$taskId/hold',
      body: body.toJson(),
    );
    return WorkOrderTaskDto.fromJson(json);
  }

  Future<WorkOrderTaskDto> approveHold(String taskId) async {
    final Map<String, dynamic> json =
        await client.post('/api/v1/tasks/$taskId/hold/approve');
    return WorkOrderTaskDto.fromJson(json);
  }

  Future<WorkOrderTaskDto> rejectHold(String taskId) async {
    final Map<String, dynamic> json =
        await client.post('/api/v1/tasks/$taskId/hold/reject');
    return WorkOrderTaskDto.fromJson(json);
  }

  Future<WorkOrderTaskDto> resume(String taskId) async {
    final Map<String, dynamic> json =
        await client.post('/api/v1/tasks/$taskId/resume');
    return WorkOrderTaskDto.fromJson(json);
  }

  Future<WorkOrderTaskDto> complete(
    String taskId,
    CompleteTaskRequestDto body,
  ) async {
    final Map<String, dynamic> json = await client.post(
      '/api/v1/tasks/$taskId/complete',
      body: body.toJson(),
    );
    return WorkOrderTaskDto.fromJson(json);
  }

  Future<WorkOrderTaskImageDto> attachEvidence(
    String taskId,
    AttachTaskEvidenceRequestDto body,
  ) async {
    final Map<String, dynamic> json = await client.post(
      '/api/v1/tasks/$taskId/evidence-images',
      body: body.toJson(),
    );
    return WorkOrderTaskImageDto.fromJson(json);
  }

  Future<TaskProductDto> addProduct(
    String taskId,
    AddTaskProductRequestDto body,
  ) async {
    final Map<String, dynamic> json = await client.post(
      '/api/v1/tasks/$taskId/products',
      body: body.toJson(),
    );
    return TaskProductDto.fromJson(json);
  }

  Future<TaskProductDto> updateProduct(
    String taskId,
    String productId,
    UpdateTaskProductRequestDto body,
  ) async {
    final Map<String, dynamic> json = await client.put(
      '/api/v1/tasks/$taskId/products/$productId',
      body: body.toJson(),
    );
    return TaskProductDto.fromJson(json);
  }

  Future<void> removeProduct(String taskId, String productId) async {
    await client.delete('/api/v1/tasks/$taskId/products/$productId');
  }
}
