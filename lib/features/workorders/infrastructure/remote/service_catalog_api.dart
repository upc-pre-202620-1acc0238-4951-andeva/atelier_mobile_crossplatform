import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/remote/work_order_reference_dtos.dart';

/// Catálogo de servicios del taller (`operations:services:read` / `operations:services:manage`).
class ServiceCatalogApi {
  final ApiClient client;

  const ServiceCatalogApi({required this.client});

  Future<List<ServiceDto>> getServices() async {
    final List list = await client.get('/api/v1/services');
    return list
        .map((e) => ServiceDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ServiceDto> createService(ServiceRequestDto body) async {
    final Map<String, dynamic> json = await client.post(
      '/api/v1/services',
      body: body.toJson(),
    );
    return ServiceDto.fromJson(json);
  }

  Future<ServiceDto> updateService(
    String serviceId,
    ServiceRequestDto body,
  ) async {
    final Map<String, dynamic> json = await client.put(
      '/api/v1/services/$serviceId',
      body: body.toJson(),
    );
    return ServiceDto.fromJson(json);
  }

  Future<void> deleteService(String serviceId) async {
    await client.delete('/api/v1/services/$serviceId');
  }
}
