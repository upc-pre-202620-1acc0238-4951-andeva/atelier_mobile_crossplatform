import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/branch/branch_dto.dart';

/// Sedes del taller. Lo usan `auth` (elegir sede) y `attendance`.
class BranchApi {
  final ApiClient client;

  const BranchApi({required this.client});

  Future<List<BranchDto>> getAll() async {
    final List jsons = await client.get('/api/v1/branches');
    return jsons.map((e) => BranchDto.fromJson(e)).toList();
  }
}
