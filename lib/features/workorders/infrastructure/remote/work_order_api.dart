import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/work_order_task_dto.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/remote/work_order_dto.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/remote/work_order_reference_dtos.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/remote/work_order_request_dtos.dart';

/// Órdenes de trabajo de docs/api/operations.md (sin bahía, entrega ni pago: paso 9).
class WorkOrderApi {
  static const _base = '/api/v1/work-orders';

  final ApiClient client;

  const WorkOrderApi({required this.client});

  Future<List<WorkOrderDto>> getWorkOrders(String branchId) async {
    final List list = await client.get(_base, query: {'branchId': branchId});
    return list
        .map((e) => WorkOrderDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<WorkOrderDto> getWorkOrder(String id) async {
    final Map<String, dynamic> json = await client.get('$_base/$id');
    return WorkOrderDto.fromJson(json);
  }

  Future<WorkOrderDto> create(CreateWorkOrderRequestDto body) async {
    final Map<String, dynamic> json = await client.post(
      _base,
      body: body.toJson(),
    );
    return WorkOrderDto.fromJson(json);
  }

  Future<WorkOrderDto> update(String id, UpdateWorkOrderRequestDto body) async {
    final Map<String, dynamic> json = await client.put(
      '$_base/$id',
      body: body.toJson(),
    );
    return WorkOrderDto.fromJson(json);
  }

  Future<WorkOrderTaskDto> addTask(
    String id,
    CreateWorkOrderTaskRequestDto body,
  ) async {
    final Map<String, dynamic> json = await client.post(
      '$_base/$id/tasks',
      body: body.toJson(),
    );
    return WorkOrderTaskDto.fromJson(json);
  }

  Future<WorkOrderTaskDto> updateTask(
    String taskId,
    UpdateWorkOrderTaskRequestDto body,
  ) async {
    final Map<String, dynamic> json = await client.put(
      '/api/v1/tasks/$taskId',
      body: body.toJson(),
    );
    return WorkOrderTaskDto.fromJson(json);
  }

  Future<WorkOrderImageDto> attachIntakeImage(
    String id,
    AttachImageRequestDto body,
  ) async {
    final Map<String, dynamic> json = await client.post(
      '$_base/$id/intake-images',
      body: body.toJson(),
    );
    return WorkOrderImageDto.fromJson(json);
  }

  Future<TaskProposalDto> submitProposal(
    String id,
    SubmitProposalRequestDto body,
  ) async {
    final Map<String, dynamic> json = await client.post(
      '$_base/$id/proposals',
      body: body.toJson(),
    );
    return TaskProposalDto.fromJson(json);
  }

  Future<EmailSentDto> notifyProposal(String id, String proposalId) async {
    final Map<String, dynamic> json = await client.post(
      '$_base/$id/proposals/$proposalId/notify',
    );
    return EmailSentDto.fromJson(json);
  }

  Future<WorkOrderTaskDto> approveProposal(
    String id,
    String proposalId,
    ApproveProposalRequestDto body,
  ) async {
    final Map<String, dynamic> json = await client.post(
      '$_base/$id/proposals/$proposalId/approve',
      body: body.toJson(),
    );
    return WorkOrderTaskDto.fromJson(json);
  }

  Future<TaskProposalDto> rejectProposal(
    String id,
    String proposalId,
    RejectProposalRequestDto body,
  ) async {
    final Map<String, dynamic> json = await client.post(
      '$_base/$id/proposals/$proposalId/reject',
      body: body.toJson(),
    );
    return TaskProposalDto.fromJson(json);
  }

  Future<ApiFile> getQuotationPdf(String id) {
    return client.getBytes('$_base/$id/quotation/pdf');
  }

  Future<EmailSentDto> sendQuotation(String id) async {
    final Map<String, dynamic> json = await client.post(
      '$_base/$id/quotation/send',
    );
    return EmailSentDto.fromJson(json);
  }

  Future<WorkOrderDto> approveQuotation(String id) =>
      _action(id, 'quotation/approve');

  Future<WorkOrderDto> rejectQuotation(String id, ReasonRequestDto body) {
    return _action(id, 'quotation/reject', body: body.toJson());
  }

  Future<WorkOrderDto> start(String id) => _action(id, 'start');

  Future<WorkOrderDto> complete(String id) => _action(id, 'complete');

  Future<WorkOrderDto> cancel(String id, ReasonRequestDto body) {
    return _action(id, 'cancel', body: body.toJson());
  }

  Future<List<PartMovementDto>> getPartMovements(String id) async {
    final List list = await client.get('$_base/$id/part-movements');
    return list
        .map((e) => PartMovementDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<WorkOrderProfitabilityDto> getProfitability(String id) async {
    final Map<String, dynamic> json = await client.get(
      '$_base/$id/profitability',
    );
    return WorkOrderProfitabilityDto.fromJson(json);
  }

  Future<WorkOrderDto> _action(
    String id,
    String action, {
    Map<String, dynamic>? body,
  }) async {
    final Map<String, dynamic> json = await client.post(
      '$_base/$id/$action',
      body: body,
    );
    return WorkOrderDto.fromJson(json);
  }
}
