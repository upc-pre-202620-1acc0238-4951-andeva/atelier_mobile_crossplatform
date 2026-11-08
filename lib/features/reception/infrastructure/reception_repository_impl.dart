import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/cache_metadata_dao.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/business_time.dart';
import 'package:atelier_mobile_crossplatform/core/domain/missing_branch_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/affiliation_lookup.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/appointment.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/customer.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_repository.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_validation.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/vehicle.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/local/appointment_dao.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/local/customer_dao.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/local/reception_mappers.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/local/vehicle_dao.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/reception_cache_policy.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/affiliate_customer_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/appointment_api.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/create_company_customer_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/create_individual_customer_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/create_vehicle_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/customer_api.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/customer_dto.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/vehicle_api.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/vehicle_dto.dart';
import 'package:drift/drift.dart';

/// Offline-first para leer (06 §4): lo que llega del backend se guarda y la UI observa Drift.
/// Altas, afiliación y llegada son en línea (06 §2).
class ReceptionRepositoryImpl implements ReceptionRepository {
  final CustomerApi customerApi;
  final VehicleApi vehicleApi;
  final AppointmentApi appointmentApi;
  final CustomerDao customerDao;
  final VehicleDao vehicleDao;
  final AppointmentDao appointmentDao;
  final CacheMetadataDao cacheMetadataDao;
  final SessionManager session;
  final DateTime Function() now;

  const ReceptionRepositoryImpl({
    required this.customerApi,
    required this.vehicleApi,
    required this.appointmentApi,
    required this.customerDao,
    required this.vehicleDao,
    required this.appointmentDao,
    required this.cacheMetadataDao,
    required this.session,
    this.now = DateTime.now,
  });

  @override
  Future<VehicleWithOwner?> findVehicleByPlate(String plate) async {
    final normalized = ReceptionValidation.normalizePlate(plate);
    try {
      final vehicle = await _saveVehicle(
        await vehicleApi.getByPlate(normalized),
      );
      final ownerId = vehicle.currentOwnerId;
      return VehicleWithOwner(
        vehicle: vehicle,
        owner: ownerId == null ? null : await _ownerOf(ownerId),
      );
    } on ApiException catch (e) {
      if (e.httpStatus == 404) return null; // Primer ingreso (US11 E2).
      rethrow;
    } on NetworkException {
      final cached = await _cachedByPlate(normalized);
      if (cached == null) rethrow;
      return cached;
    }
  }

  @override
  Stream<Vehicle?> observeVehicle(String id) {
    return vehicleDao.watchById(id).map((row) => row?.toDomain());
  }

  @override
  Stream<Customer?> observeCustomer(String id) {
    return customerDao.watchById(id).map((row) => row?.toDomain());
  }

  @override
  Future<List<Customer>> searchCustomers(String query) async {
    final text = query.trim();
    try {
      final dtos = await customerApi.search(text.isEmpty ? null : text);
      return [for (final dto in dtos) await _saveCustomer(dto)];
    } on NetworkException {
      if (text.isEmpty) rethrow;
      final rows = await customerDao.search(text);
      return rows.map((row) => row.toDomain()).toList();
    }
  }

  @override
  Future<List<Vehicle>> getCustomerVehicles(String customerId) async {
    final dtos = await customerApi.getVehicles(customerId);
    return [for (final dto in dtos) await _saveVehicle(dto)];
  }

  @override
  Future<Customer> getCustomer(String id) async {
    return _saveCustomer(await customerApi.getCustomer(id));
  }

  @override
  Future<Customer> registerIndividual(NewIndividualCustomer customer) async {
    final dto = await customerApi.createIndividual(
      CreateIndividualCustomerRequestDto(
        firstName: customer.firstName.trim(),
        lastName: customer.lastName.trim(),
        taxId: customer.taxId.trim(),
        email: _blankToNull(customer.email),
        phone: _blankToNull(customer.phone),
      ),
    );
    return _saveCustomer(dto);
  }

  @override
  Future<Customer> registerCompany(NewCompanyCustomer customer) async {
    final dto = await customerApi.createCompany(
      CreateCompanyCustomerRequestDto(
        companyName: customer.companyName.trim(),
        taxId: customer.taxId.trim(),
        email: _blankToNull(customer.email),
        phone: _blankToNull(customer.phone),
      ),
    );
    return _saveCustomer(dto);
  }

  @override
  Future<Vehicle> registerVehicle(NewVehicle vehicle) async {
    final dto = await vehicleApi.create(
      CreateVehicleRequestDto(
        plate: ReceptionValidation.normalizePlate(vehicle.plate),
        brand: vehicle.brand.trim(),
        model: vehicle.model.trim(),
        engineType: vehicle.engineType.value,
        customerId: vehicle.customerId,
        vin: _blankToNull(vehicle.vin),
        year: vehicle.year,
      ),
    );
    return _saveVehicle(dto);
  }

  @override
  Future<AffiliationLookup> lookupAffiliation(String email) async {
    final dto = await customerApi.lookupAffiliation(email.trim());
    return dto.toDomain(now().millisecondsSinceEpoch);
  }

  @override
  Future<Customer> affiliate(
    String email,
    String taxId, {
    String? phone,
  }) async {
    final customer = await _saveCustomer(
      await customerApi.affiliate(
        AffiliateCustomerRequestDto(
          email: email.trim(),
          taxId: taxId.trim(),
          phone: _blankToNull(phone),
        ),
      ),
    );
    try {
      await getCustomerVehicles(customer.id);
    } on ApiException {
      // Ya quedó afiliado: los vehículos llegarán la próxima vez que se lean.
    } on NetworkException {
      // Igual.
    }
    return customer;
  }

  @override
  Future<void> refreshAppointments(String date) async {
    final current = await session.getSession();
    if (current == null) throw StateError('Sin sesión');
    final branchId = current.branchId;
    if (branchId == null) throw const MissingBranchException();
    if (!current.has(Permission.appointmentsRead)) return;

    final timestamp = now().millisecondsSinceEpoch;
    final dtos = await appointmentApi.getAppointments(branchId, date);
    final rows = dtos.map((dto) => dto.toEntity(timestamp)).toList();
    final (from, to) = _dayRange(date);
    await appointmentDao.replaceDay(branchId, from, to, rows);
    await cacheMetadataDao.upsert(
      CacheMetadataCompanion(
        scope: Value(ReceptionCachePolicy.appointmentsScope(branchId, date)),
        lastSyncedAt: Value(timestamp),
        recordCount: Value(rows.length),
      ),
    );
    await _enrich(
      vehicleIds: rows.map((row) => row.vehicleId),
      customerIds: rows.map((row) => row.customerId),
      session: current,
    );
  }

  @override
  Stream<List<Appointment>> observeAppointments(String date) {
    final (from, to) = _dayRange(date);
    return session.switchOn<String?, List<Appointment>>(
      (current) => current?.branchId,
      (branchId) {
        if (branchId == null) return Stream.value(const []);
        return appointmentDao
            .watchDay(branchId, from, to)
            .map(
              (rows) => rows
                  .map(
                    (row) => row.appointment.toDomain(
                      plate: row.plate,
                      customerName: row.customerName,
                    ),
                  )
                  .toList(),
            );
      },
    );
  }

  @override
  Future<Appointment> markArrived(String id) async {
    final dto = await appointmentApi.arrive(id);
    final row = dto.toEntity(now().millisecondsSinceEpoch);
    await appointmentDao.upsert(row);
    return row.toDomain();
  }

  Future<Vehicle> _saveVehicle(VehicleDto dto) async {
    final timestamp = now().millisecondsSinceEpoch;
    final row = dto.toEntity(timestamp);
    await vehicleDao.saveFromServer(row.toCompanion(false));
    await _touch(ReceptionCachePolicy.vehicleScope(dto.id), timestamp);
    return row.toDomain();
  }

  Future<Customer> _saveCustomer(CustomerDto dto) async {
    final timestamp = now().millisecondsSinceEpoch;
    final row = dto.toEntity(timestamp);
    await customerDao.upsert(row);
    await _touch(ReceptionCachePolicy.customerScope(dto.id), timestamp);
    return row.toDomain();
  }

  /// Placa y nombre para la agenda: solo lo que falta o venció, y solo con permiso para leerlo. Nunca
  /// hace fallar la recarga que lo pidió.
  Future<void> _enrich({
    required Iterable<String> vehicleIds,
    required Iterable<String> customerIds,
    required Session session,
  }) async {
    if (session.has(Permission.vehiclesRead)) {
      for (final id in vehicleIds.toSet()) {
        if (await _isStale(
          ReceptionCachePolicy.vehicleScope(id),
          ReceptionCachePolicy.vehiclesTtlMillis,
        )) {
          await _bestEffort(() async {
            await _saveVehicle(await vehicleApi.getVehicle(id));
          });
        }
      }
    }
    if (session.has(Permission.customersRead)) {
      for (final id in customerIds.toSet()) {
        if (await _isStale(
          ReceptionCachePolicy.customerScope(id),
          ReceptionCachePolicy.customersTtlMillis,
        )) {
          await _bestEffort(() async {
            await _saveCustomer(await customerApi.getCustomer(id));
          });
        }
      }
    }
  }

  Future<void> _bestEffort(Future<void> Function() call) async {
    try {
      await call();
    } on ApiException {
      // Se sigue con la caché.
    } on NetworkException {
      // Igual.
    }
  }

  Future<bool> _isStale(String scope, int ttlMillis) async {
    final entry = await cacheMetadataDao.get(scope);
    if (entry == null) return true;
    return now().millisecondsSinceEpoch - entry.lastSyncedAt >= ttlMillis;
  }

  Future<void> _touch(String scope, int timestamp) {
    return cacheMetadataDao.upsert(
      CacheMetadataCompanion(
        scope: Value(scope),
        lastSyncedAt: Value(timestamp),
        recordCount: const Value(1),
      ),
    );
  }

  /// El titular desde la red; si no se puede leer (sin permiso, sin red), el de la caché o `null`.
  Future<Customer?> _ownerOf(String customerId) async {
    try {
      return await _saveCustomer(await customerApi.getCustomer(customerId));
    } on ApiException {
      return (await customerDao.findById(customerId))?.toDomain();
    } on NetworkException {
      return (await customerDao.findById(customerId))?.toDomain();
    }
  }

  Future<VehicleWithOwner?> _cachedByPlate(String plate) async {
    final vehicle = (await vehicleDao.findByPlate(plate))?.toDomain();
    if (vehicle == null) return null;
    final ownerId = vehicle.currentOwnerId;
    return VehicleWithOwner(
      vehicle: vehicle,
      owner: ownerId == null
          ? null
          : (await customerDao.findById(ownerId))?.toDomain(),
    );
  }

  (int, int) _dayRange(String date) {
    return (
      BusinessTime.startOfDay(date).millisecondsSinceEpoch,
      BusinessTime.startOfDay(BusinessTime.addDays(date, 1))
          .millisecondsSinceEpoch,
    );
  }

  String? _blankToNull(String? value) {
    final text = value?.trim();
    return text == null || text.isEmpty ? null : text;
  }
}
