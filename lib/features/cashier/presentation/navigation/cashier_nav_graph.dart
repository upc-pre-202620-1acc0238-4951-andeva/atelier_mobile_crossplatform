import 'package:atelier_mobile_crossplatform/features/cashier/presentation/checkout/work_order_checkout_screen.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/dailycash/daily_cash_screen.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/vouchers/vouchers_screen.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';

/// Destinos de `cashier`: Caja del día, Comprobantes SUNAT y Facturación de orden (US37).
/// Series fiscales (US42) y los pasos de cobro/entrega (US38/US39) quedan excluidos.
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
