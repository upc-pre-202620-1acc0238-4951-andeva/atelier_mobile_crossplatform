import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/vehicle_dto.dart';

class VehicleApi {
  final ApiClient client;

  const VehicleApi({required this.client});

  Future<VehicleDto> getVehicle(String id) async {
    final Map<String, dynamic> json = await client.get('/api/v1/vehicles/$id');
    return VehicleDto.fromJson(json);
  }
}
