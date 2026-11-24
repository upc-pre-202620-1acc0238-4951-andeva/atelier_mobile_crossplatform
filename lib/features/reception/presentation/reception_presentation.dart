import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/affiliate_customer_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/cancel_appointment_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/confirm_appointment_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/create_appointment_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/find_vehicle_by_plate_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/get_customer_vehicles_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/lookup_affiliation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/mark_appointment_arrived_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/observe_appointments_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/observe_customers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/observe_workshop_vehicles_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/refresh_appointments_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/refresh_customers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/register_company_customer_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/register_individual_customer_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/register_vehicle_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/reschedule_appointment_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/search_customers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/update_customer_contact_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/presentation/affiliation/affiliation_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/reception/presentation/navigation/reception_nav_graph.dart';
import 'package:atelier_mobile_crossplatform/features/reception/presentation/register/register_customer_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/reception/presentation/search/vehicle_search_view_model.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';

/// ViewModels y destinos de `reception` (buscar vehículo y citas, afiliar por correo, registrar cliente).
void setupReceptionPresentation() {
  registerReceptionRoutes();

  getIt.registerFactory<VehicleSearchViewModel>(
    () => VehicleSearchViewModel(
      observeSession: getIt<ObserveSessionUseCase>(),
      findVehicleByPlate: getIt<FindVehicleByPlateUseCase>(),
      searchCustomers: getIt<SearchCustomersUseCase>(),
      getCustomerVehicles: getIt<GetCustomerVehiclesUseCase>(),
      refreshAppointments: getIt<RefreshAppointmentsUseCase>(),
      observeAppointments: getIt<ObserveAppointmentsUseCase>(),
      markArrived: getIt<MarkAppointmentArrivedUseCase>(),
      refreshCustomers: getIt<RefreshCustomersUseCase>(),
      observeCustomers: getIt<ObserveCustomersUseCase>(),
      observeWorkshopVehicles: getIt<ObserveWorkshopVehiclesUseCase>(),
      connectivity: getIt<ConnectivityObserver>(),
      createAppointment: getIt<CreateAppointmentUseCase>(),
      confirmAppointment: getIt<ConfirmAppointmentUseCase>(),
      rescheduleAppointment: getIt<RescheduleAppointmentUseCase>(),
      cancelAppointment: getIt<CancelAppointmentUseCase>(),
      updateCustomerContact: getIt<UpdateCustomerContactUseCase>(),
    ),
  );
  getIt.registerFactory<AffiliationViewModel>(
    () => AffiliationViewModel(
      observeSession: getIt<ObserveSessionUseCase>(),
      lookupAffiliation: getIt<LookupAffiliationUseCase>(),
      affiliateCustomer: getIt<AffiliateCustomerUseCase>(),
      connectivity: getIt<ConnectivityObserver>(),
    ),
  );
  getIt.registerFactoryParam<RegisterCustomerViewModel, RegisterCustomerArgs?, void>(
    (args, _) => RegisterCustomerViewModel(
      observeSession: getIt<ObserveSessionUseCase>(),
      registerIndividual: getIt<RegisterIndividualCustomerUseCase>(),
      registerCompany: getIt<RegisterCompanyCustomerUseCase>(),
      registerVehicle: getIt<RegisterVehicleUseCase>(),
      args: args,
      connectivity: getIt<ConnectivityObserver>(),
    ),
  );
}
