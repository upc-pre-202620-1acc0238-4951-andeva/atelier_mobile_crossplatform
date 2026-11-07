class CreateVehicleRequestDto {
  final String plate;
  final String brand;
  final String model;
  final String engineType;
  final String? customerId;
  final String? vin;
  final int? year;

  const CreateVehicleRequestDto({
    required this.plate,
    required this.brand,
    required this.model,
    required this.engineType,
    this.customerId,
    this.vin,
    this.year,
  });

  Map<String, dynamic> toJson() => {
    'plate': plate,
    'brand': brand,
    'model': model,
    'engineType': engineType,
    if (customerId != null) 'customerId': customerId,
    if (vin != null) 'vin': vin,
    if (year != null) 'year': year,
  };
}
