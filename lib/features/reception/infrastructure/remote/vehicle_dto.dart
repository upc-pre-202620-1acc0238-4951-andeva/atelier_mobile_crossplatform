class VehicleDto {
  final String id;
  final String plate;
  final String? vin;
  final String brand;
  final String model;
  final int? year;
  final String? engineType;
  final String? currentOwnerId;
  final int? currentMileage;

  const VehicleDto({
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

  factory VehicleDto.fromJson(Map<String, dynamic> json) {
    return VehicleDto(
      id: json['id'] as String,
      plate: json['plate'] as String,
      vin: json['vin'] as String?,
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: (json['year'] as num?)?.toInt(),
      engineType: json['engineType'] as String?,
      currentOwnerId: json['currentOwnerId'] as String?,
      currentMileage: (json['currentMileage'] as num?)?.toInt(),
    );
  }
}
