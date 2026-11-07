import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/create_vehicle_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/vehicle_dto.dart';

class VehicleApi {
  final ApiClient client;

  const VehicleApi({required this.client});

  Future<VehicleDto> getVehicle(String id) async {
    final Map<String, dynamic> json = await client.get('/api/v1/vehicles/$id');
    return VehicleDto.fromJson(json);
  }

  /// La placa la escribe el usuario: se codifica para que no altere la ruta.
  Future<VehicleDto> getByPlate(String plate) async {
    final Map<String, dynamic> json = await client.get(
      '/api/v1/vehicles/by-plate/${Uri.encodeComponent(plate)}',
    );
    return VehicleDto.fromJson(json);
  }

  Future<VehicleDto> create(CreateVehicleRequestDto body) async {
    final Map<String, dynamic> json = await client.post(
      '/api/v1/vehicles',
      body: body.toJson(),
    );
    return VehicleDto.fromJson(json);
  }
}
