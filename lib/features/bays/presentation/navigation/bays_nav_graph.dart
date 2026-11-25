import 'package:atelier_mobile_crossplatform/features/bays/presentation/bays_screen.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';

/// Destinos de `bays`: el tablero, siempre empujado con Atrás.
void registerBaysRoutes() {
  AppNavigator.register(AppRoute.bays, (context, args) => const BaysScreen());
}
