import 'package:atelier_mobile_crossplatform/features/cashier/presentation/checkout/work_order_checkout_screen.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/dailycash/daily_cash_screen.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/vouchers/vouchers_screen.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';

/// Destinos de `cashier`: Caja del día, Comprobantes SUNAT y "Cobrar y entregar" de una orden (US37–US39).
/// Series fiscales (US42) queda excluida.
void registerCashierRoutes() {
  AppNavigator.register(
    AppRoute.dailyCash,
    (context, args) => DailyCashScreen(showBack: args is bool ? args : null),
  );
  AppNavigator.register(
    AppRoute.vouchers,
    (context, args) => const VouchersScreen(),
  );
  AppNavigator.register(
    AppRoute.workOrderCheckout,
    (context, args) => WorkOrderCheckoutScreen(workOrderId: args as String),
  );
}
