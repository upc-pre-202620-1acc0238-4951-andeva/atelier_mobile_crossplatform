import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/affiliation_lookup.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/appointment.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/customer.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/vehicle.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/affiliation_lookup_dto.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/appointment_dto.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/customer_dto.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/vehicle_dto.dart';

// Se guarda con `toCompanion(false)`: escribe los nulos, así un `upsert` borra lo que el backend
// dejó de enviar. Con `toColumns` los nulos quedarían ausentes y el valor viejo seguiría ahí.

extension CustomerDtoMapper on CustomerDto {
  CustomerEntity toEntity(int syncedAt) {
    final fullName = [firstName, lastName].nonNulls.join(' ').trim();
    return CustomerEntity(
      id: id,
      type: type ?? '',
      displayName:
          displayName ?? (fullName.isEmpty ? companyName ?? '' : fullName),
      taxId: taxId,
      email: email,
      phone: phone,
      status: status ?? '',
      syncedAt: syncedAt,
    );
  }
}

extension CustomerEntityMapper on CustomerEntity {
  Customer toDomain() {
    return Customer(
      id: id,
      type: CustomerType.fromString(type),
      displayName: displayName,
      taxId: taxId,
      email: email,
      phone: phone,
      status: status.isEmpty ? null : status,
    );
  }
}

extension VehicleDtoMapper on VehicleDto {
  VehicleEntity toEntity(int syncedAt) {
    return VehicleEntity(
      id: id,
      plate: plate,
      vin: vin,
      brand: brand ?? '',
      model: model ?? '',
      year: year,
      engineType: engineType,
      currentOwnerId: currentOwnerId,
      currentMileage: currentMileage,
      syncedAt: syncedAt,
    );
  }
}

extension VehicleEntityMapper on VehicleEntity {
  Vehicle toDomain() {
    return Vehicle(
      id: id,
      plate: plate,
      vin: vin,
      brand: brand,
      model: model,
      year: year,
      engineType: EngineType.fromString(engineType),
      currentOwnerId: currentOwnerId,
      currentMileage: currentMileage,
    );
  }
}

extension AppointmentDtoMapper on AppointmentDto {
  AppointmentEntity toEntity(int syncedAt) {
    return AppointmentEntity(
      id: id,
      branchId: branchId,
      customerId: customerId,
      vehicleId: vehicleId,
      scheduledAt: DateTime.parse(scheduledAt).millisecondsSinceEpoch,
      estimatedDurationMinutes: estimatedDurationMinutes,
      reason: reason,
      status: status ?? '',
      syncedAt: syncedAt,
    );
  }
}

extension AppointmentEntityMapper on AppointmentEntity {
  Appointment toDomain({String? plate, String? customerName}) {
    return Appointment(
      id: id,
      branchId: branchId,
      customerId: customerId,
      vehicleId: vehicleId,
      scheduledAt: DateTime.fromMillisecondsSinceEpoch(
        scheduledAt,
        isUtc: true,
      ),
      estimatedDurationMinutes: estimatedDurationMinutes,
      reason: reason,
      status: AppointmentStatus.fromString(status),
      plate: plate,
      customerName: customerName,
    );
  }
}

extension AffiliationLookupDtoMapper on AffiliationLookupDto {
  AffiliationLookup toDomain(int syncedAt) {
    final account = platformAccount;
    return AffiliationLookup(
      workshopCustomer: workshopCustomer?.toEntity(syncedAt).toDomain(),
      platformAccount: account == null
          ? null
          : PlatformAccount(
              userId: account.userId,
              email: account.email,
              fullName: account.fullName,
              status: account.status,
            ),
      vehicles: (vehicles ?? [])
          .map((e) => e.toEntity(syncedAt).toDomain())
          .toList(),
      nextStep: AffiliationStep.fromString(nextStep),
    );
  }
}
