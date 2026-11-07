import 'package:atelier_mobile_crossplatform/features/reception/domain/customer.dart';

/// `EngineType` de docs/api/README.md §8.
enum EngineType {
  gasoline('GASOLINE'),
  diesel('DIESEL'),
  electric('ELECTRIC'),
  hybrid('HYBRID');

  final String value;
  const EngineType(this.value);

  static EngineType? fromString(String? raw) {
    for (final type in values) {
      if (type.value == raw) return type;
    }
    return null;
  }
}

/// Vehículo (`VehicleResource`). [currentOwnerId] es el cliente titular; puede faltar.
class Vehicle {
  final String id;
  final String plate;
  final String? vin;
  final String brand;
  final String model;
  final int? year;
  final EngineType? engineType;
  final String? currentOwnerId;
  final int? currentMileage;

  const Vehicle({
    required this.id,
    required this.plate,
    this.vin,
    required this.brand,
    required this.model,
    this.year,
    this.engineType,
    this.currentOwnerId,
    this.currentMileage,
  });
}

/// Resultado de buscar por placa (US11 E1): [owner] es `null` si no se pudo leer al titular.
class VehicleWithOwner {
  final Vehicle vehicle;
  final Customer? owner;

  const VehicleWithOwner({required this.vehicle, this.owner});
}

/// Alta de vehículo (US11 E2, US44 E2): `CreateVehicleResource`, con el cliente titular.
class NewVehicle {
  final String plate;
  final String brand;
  final String model;
  final EngineType engineType;
  final String? customerId;
  final String? vin;
  final int? year;

  const NewVehicle({
    required this.plate,
    required this.brand,
    required this.model,
    required this.engineType,
    this.customerId,
    this.vin,
    this.year,
  });
}
