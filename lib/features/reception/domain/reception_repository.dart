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

  /// Cartera de clientes sincronizada en la caché `customers`, ordenada por nombre.
  Stream<List<Customer>> observeCustomers();

  /// Padrón de vehículos de la caché `vehicles` con su titular, si también está en `customers`.
  Stream<List<VehicleWithOwner>> observeWorkshopVehicles();

  /// Recarga la cartera de clientes (`GET /customers`, por páginas) sin lecturas N+1 de vehículos.
  /// Sin [force], no hace nada si la última recarga es reciente (15 min). Sin `crm:customers:read`
  /// no hace nada.
  Future<void> refreshCustomers({bool force = false});

  /// Trae a la caché los vehículos y clientes faltantes o vencidos que citas u órdenes referencian.
  /// Nunca falla: sigue con la caché.
  Future<void> enrichReferences(
    Iterable<String> vehicleIds,
    Iterable<String> customerIds,
  );

  /// En línea; lo deja en la caché `customers`. La usa caja para sugerir el comprobante (H27).
  Future<Customer> getCustomer(String id);

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

  /// Como [refreshAppointments], para los días de Lima [from]–[to] (ambos incluidos, `yyyy-MM-dd`).
  /// `docs/api` solo documenta `date`: se pide día por día (hasta [maxRangeDays] días).
  Future<void> refreshAppointmentsRange(String from, String to);

  Stream<List<Appointment>> observeAppointmentsRange(String from, String to);

  /// `POST /appointments/{id}/arrive`: devuelve la cita (la orden llega después, H10).
  Future<Appointment> markArrived(String id);

  /// `POST /appointments`: agenda una cita en la sede de la sesión (`crm:appointments:create`). En
  /// línea. [scheduledAt] se envía en UTC.
  Future<Appointment> createAppointment({
    required String customerId,
    required String vehicleId,
    required DateTime scheduledAt,
    int? estimatedDurationMinutes,
    String? reason,
  });

  /// `POST /appointments/{id}/confirm`: confirma una cita pendiente. En línea.
  Future<Appointment> confirmAppointment(String id);

  /// `POST /appointments/{id}/reschedule`: reprograma una cita. En línea.
  Future<Appointment> rescheduleAppointment(String id, DateTime newScheduledAt);

  /// `POST /appointments/{id}/cancel`: cancela una cita con motivo. En línea.
  Future<Appointment> cancelAppointment(String id, String cancellationReason);

  /// `PUT /customers/{id}/contact`: actualiza correo y teléfono (`crm:customers:update`). En línea.
  Future<Customer> updateCustomerContact(
    String id, {
    String? email,
    String? phone,
  });

  /// Tope de días de un rango de agenda.
  static const maxRangeDays = 31;
}
