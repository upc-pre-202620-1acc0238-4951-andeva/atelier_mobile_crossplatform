import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/cache_metadata_dao.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/affiliate_customer_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/find_vehicle_by_plate_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/get_customer_vehicles_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/lookup_affiliation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/mark_appointment_arrived_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/observe_appointments_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/observe_customer_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/observe_vehicle_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/refresh_appointments_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/register_company_customer_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/register_individual_customer_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/register_vehicle_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/search_customers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_repository.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/local/appointment_dao.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/local/customer_dao.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/local/vehicle_dao.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/reception_repository_impl.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/appointment_api.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/customer_api.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/vehicle_api.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';

void setupReceptionDependencies() {
  getIt.registerLazySingleton<CustomerDao>(
    () => getIt<AppDatabase>().customerDao,
  );
  getIt.registerLazySingleton<VehicleDao>(
    () => getIt<AppDatabase>().vehicleDao,
  );
  getIt.registerLazySingleton<AppointmentDao>(
    () => getIt<AppDatabase>().appointmentDao,
  );

  getIt.registerLazySingleton<CustomerApi>(
    () => CustomerApi(client: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<VehicleApi>(
    () => VehicleApi(client: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<AppointmentApi>(
    () => AppointmentApi(client: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<ReceptionRepository>(
    () => ReceptionRepositoryImpl(
      customerApi: getIt<CustomerApi>(),
      vehicleApi: getIt<VehicleApi>(),
      appointmentApi: getIt<AppointmentApi>(),
      customerDao: getIt<CustomerDao>(),
      vehicleDao: getIt<VehicleDao>(),
      appointmentDao: getIt<AppointmentDao>(),
      cacheMetadataDao: getIt<CacheMetadataDao>(),
      session: getIt<SessionManager>(),
    ),
  );

  getIt.registerLazySingleton<FindVehicleByPlateUseCase>(
    () => FindVehicleByPlateUseCase(repository: getIt<ReceptionRepository>()),
  );
  getIt.registerLazySingleton<SearchCustomersUseCase>(
    () => SearchCustomersUseCase(repository: getIt<ReceptionRepository>()),
  );
  getIt.registerLazySingleton<GetCustomerVehiclesUseCase>(
    () => GetCustomerVehiclesUseCase(repository: getIt<ReceptionRepository>()),
  );
  getIt.registerLazySingleton<ObserveCustomerUseCase>(
    () => ObserveCustomerUseCase(repository: getIt<ReceptionRepository>()),
  );
  getIt.registerLazySingleton<ObserveVehicleUseCase>(
    () => ObserveVehicleUseCase(repository: getIt<ReceptionRepository>()),
  );
  getIt.registerLazySingleton<RegisterIndividualCustomerUseCase>(
    () => RegisterIndividualCustomerUseCase(
      repository: getIt<ReceptionRepository>(),
    ),
  );
  getIt.registerLazySingleton<RegisterCompanyCustomerUseCase>(
    () => RegisterCompanyCustomerUseCase(
      repository: getIt<ReceptionRepository>(),
    ),
  );
  getIt.registerLazySingleton<RegisterVehicleUseCase>(
    () => RegisterVehicleUseCase(repository: getIt<ReceptionRepository>()),
  );
  getIt.registerLazySingleton<LookupAffiliationUseCase>(
    () => LookupAffiliationUseCase(repository: getIt<ReceptionRepository>()),
  );
  getIt.registerLazySingleton<AffiliateCustomerUseCase>(
    () => AffiliateCustomerUseCase(repository: getIt<ReceptionRepository>()),
  );
  getIt.registerLazySingleton<RefreshAppointmentsUseCase>(
    () => RefreshAppointmentsUseCase(repository: getIt<ReceptionRepository>()),
  );
  getIt.registerLazySingleton<ObserveAppointmentsUseCase>(
    () => ObserveAppointmentsUseCase(repository: getIt<ReceptionRepository>()),
  );
  getIt.registerLazySingleton<MarkAppointmentArrivedUseCase>(
    () => MarkAppointmentArrivedUseCase(
      receptionRepository: getIt<ReceptionRepository>(),
      workOrderRepository: getIt<WorkOrderRepository>(),
    ),
  );
}
