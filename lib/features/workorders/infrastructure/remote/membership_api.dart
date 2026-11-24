import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/remote/work_order_reference_dtos.dart';

/// Membresías del taller de docs/api/iam.md. Dan nombre a los colaboradores que
/// `EmployeeApi.getByBranch` identifica solo por cargo. Exige `iam:members:read`.
class MembershipApi {
  final ApiClient client;

  const MembershipApi({required this.client});

  Future<List<MembershipDto>> getMemberships() async {
    final List list = await client.get('/api/v1/memberships');
    return list
        .map((e) => MembershipDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
