import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/features/bays/infrastructure/remote/work_bay_dto.dart';
import 'package:atelier_mobile_crossplatform/features/bays/infrastructure/remote/work_bay_request_dtos.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/work_order_task_dto.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/remote/work_order_dto.dart';

class WorkBayApi {
  final ApiClient client;

  const WorkBayApi({required this.client});

  Future<List<WorkBayDto>> getBays(String branchId) async {
    final List list = await client.get(
      '/api/v1/work-bays',
      query: {'branchId': branchId},
    );
    return list
        .map((e) => WorkBayDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<WorkOrderDto> reassignBay(
    String workOrderId,
    AssignWorkBayRequestDto body,
  ) async {
    final Map<String, dynamic> json = await client.put(
      '/api/v1/work-orders/$workOrderId/bay',
      body: body.toJson(),
    );
    return WorkOrderDto.fromJson(json);
  }

  Future<WorkOrderTaskDto> reassignMechanic(
    String taskId,
    AssignTaskMechanicRequestDto body,
  ) async {
    final Map<String, dynamic> json = await client.put(
      '/api/v1/tasks/$taskId/mechanic',
      body: body.toJson(),
    );
    return WorkOrderTaskDto.fromJson(json);
  }
}
