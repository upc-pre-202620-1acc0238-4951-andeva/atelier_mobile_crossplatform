import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/customer_dto.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/vehicle_dto.dart';

/// Respuesta de `GET /customers/affiliation-lookup`.
class AffiliationLookupDto {
  final CustomerDto? workshopCustomer;
  final PlatformAccountDto? platformAccount;
  final List<VehicleDto>? vehicles;
  final String? nextStep;

  const AffiliationLookupDto({
    this.workshopCustomer,
    this.platformAccount,
    this.vehicles,
    this.nextStep,
  });

  factory AffiliationLookupDto.fromJson(Map<String, dynamic> json) {
    final customer = json['workshopCustomer'] as Map<String, dynamic>?;
    final account = json['platformAccount'] as Map<String, dynamic>?;
    return AffiliationLookupDto(
      workshopCustomer: customer == null
          ? null
          : CustomerDto.fromJson(customer),
      platformAccount: account == null
          ? null
          : PlatformAccountDto.fromJson(account),
      vehicles: (json['vehicles'] as List?)
          ?.map((e) => VehicleDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextStep: json['nextStep'] as String?,
    );
  }
}

class PlatformAccountDto {
  final String userId;
  final String email;
  final String? fullName;
  final String? status;

  const PlatformAccountDto({
    required this.userId,
    required this.email,
    this.fullName,
    this.status,
  });

  factory PlatformAccountDto.fromJson(Map<String, dynamic> json) {
    return PlatformAccountDto(
      userId: json['userId'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String?,
      status: json['status'] as String?,
    );
  }
}
