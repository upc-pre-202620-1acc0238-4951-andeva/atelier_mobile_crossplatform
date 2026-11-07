import 'package:atelier_mobile_crossplatform/features/reception/domain/affiliation_lookup.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/appointment.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/customer.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/vehicle.dart';

/// Recepción (US11, US44). Lecturas offline-first sobre `customers`, `vehicles` y `appointments`
/// (06 §4); altas, afiliación y llegada son en línea (06 §2): sin red lanzan `NetworkException`.
abstract class ReceptionRepository {
  /// `null` = primer ingreso (404). Sin red responde con la caché, si la placa ya se vio.
  Future<VehicleWithOwner?> findVehicleByPlate(String plate);

  Stream<Vehicle?> observeVehicle(String id);

  Stream<Customer?> observeCustomer(String id);

  /// Por documento o nombre. Sin red y con texto, busca en la caché `customers`.
  Future<List<Customer>> searchCustomers(String query);

  Future<List<Vehicle>> getCustomerVehicles(String customerId);

  Future<Customer> registerIndividual(NewIndividualCustomer customer);

  Future<Customer> registerCompany(NewCompanyCustomer customer);

  Future<Vehicle> registerVehicle(NewVehicle vehicle);

  Future<AffiliationLookup> lookupAffiliation(String email);

  /// El backend vincula los vehículos de la cuenta; se leen después para dejarlos en caché.
  Future<Customer> affiliate(String email, String taxId, {String? phone});

  /// Recarga la agenda de la sede de la sesión para [date] (día de Lima, `yyyy-MM-dd`) y trae placa
  /// y cliente que falten. Sin sede lanza `MissingBranchException`.
  Future<void> refreshAppointments(String date);

  Stream<List<Appointment>> observeAppointments(String date);

  /// `POST /appointments/{id}/arrive`: devuelve la cita (la orden llega después, H10).
  Future<Appointment> markArrived(String id);
}
