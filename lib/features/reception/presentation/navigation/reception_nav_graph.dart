import 'package:atelier_mobile_crossplatform/features/reception/presentation/affiliation/affiliation_screen.dart';
import 'package:atelier_mobile_crossplatform/features/reception/presentation/register/register_customer_screen.dart';
import 'package:atelier_mobile_crossplatform/features/reception/presentation/search/vehicle_search_screen.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';

/// Destinos de recepción (equivale a `receptionNavGraph` de Android). [AppRoute.vehicleSearch] es la raíz de la
/// pestaña "Recepción": US11 (buscar por placa o documento, citas) y, desde ahí, US44 (afiliar por correo) y el alta
/// presencial de cliente y vehículo ([AppRoute.registerCustomer], con `RegisterCustomerArgs?`).
void registerReceptionRoutes() {
  AppNavigator.register(AppRoute.vehicleSearch, (context, args) => const VehicleSearchScreen());
  AppNavigator.register(AppRoute.affiliation, (context, args) => const AffiliationScreen());
  AppNavigator.register(
    AppRoute.registerCustomer,
    (context, args) => RegisterCustomerScreen(args: args as RegisterCustomerArgs?),
  );
}
