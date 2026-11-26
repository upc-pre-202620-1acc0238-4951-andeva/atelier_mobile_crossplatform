import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/tenant/tenant_dtos.dart';

/// Perfil corporativo y fiscal del taller en sesión (`docs/api/iam.md`, US42).
class TenantApi {
  static const _path = '/api/v1/tenants/current';

  final ApiClient client;

  const TenantApi({required this.client});

  Future<TenantDto> getCurrent() async {
    final Map<String, dynamic> json = await client.get(_path);
    return TenantDto.fromJson(json);
  }

  Future<TenantDto> updateCurrent(UpdateTenantProfileRequestDto body) async {
    final Map<String, dynamic> json = await client.put(_path, body: body.toJson());
    return TenantDto.fromJson(json);
  }
}
