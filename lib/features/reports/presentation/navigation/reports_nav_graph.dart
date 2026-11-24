import 'package:atelier_mobile_crossplatform/features/reports/presentation/reports_screen.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';

/// Destinos de `reports` (equivale a `reportsNavGraph`): el flujo de caja del taller, siempre empujado con Atrás.
void registerReportsRoutes() {
  AppNavigator.register(AppRoute.reports, (context, args) => const ReportsScreen());
}
