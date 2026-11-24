import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/employee/employee_profile_dto.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/employee/membership_dto.dart';

/// Perfil laboral del colaborador. Lo usan `auth` (tras el login), `attendance` y `workorders`.
class EmployeeApi {
  final ApiClient client;

  const EmployeeApi({required this.client});

  /// [token]: tras el login aún no está guardado, porque la sede se pide antes de guardar.
  Future<EmployeeProfileDto> getByMembership(
    String membershipId, {
    String? token,
  }) async {
    final Map<String, dynamic> json = await client.get(
      '/api/v1/hr/employees/membership/$membershipId',
      headers: token == null ? null : {'Authorization': 'Bearer $token'},
    );
    return EmployeeProfileDto.fromJson(json);
  }

  /// Exige `iam:members:read`, que el Asesor no tiene (H11).
  Future<List<EmployeeProfileDto>> getByBranch(String branchId) async {
    final List list = await client.get('/api/v1/hr/employees/branch/$branchId');
    return list
        .map((e) => EmployeeProfileDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Membresías del taller, para obtener el nombre (`employeeName`) de los colaboradores. Exige
  /// `iam:members:read` (docs/api/iam.md).
  Future<List<MembershipDto>> getMemberships() async {
    final List list = await client.get('/api/v1/memberships');
    return list
        .map((e) => MembershipDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
