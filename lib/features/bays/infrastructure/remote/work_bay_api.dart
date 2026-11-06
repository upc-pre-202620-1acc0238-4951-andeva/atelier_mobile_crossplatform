import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/features/bays/infrastructure/remote/work_bay_dto.dart';

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
}
