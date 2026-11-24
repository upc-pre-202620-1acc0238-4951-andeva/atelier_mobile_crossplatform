import 'package:atelier_mobile_crossplatform/features/cashier/presentation/dailycash/daily_cash_screen.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';

/// Destinos de `cashier` (equivale a `cashierNavGraph`). Solo "Caja del día": comprobantes (US37), cobro y
/// entrega (US38/US39) y series (US42) están fuera de alcance y no tienen destino.
///
/// [AppRoute.dailyCash] es la raíz de la pestaña "Caja". Argumento opcional `bool` (el `showDailyCashBack` de
/// Android): `true` fuerza la barra con Atrás y `false` la cabecera de pestaña; sin él, la pantalla lo decide
/// según pueda o no volver.
void registerCashierRoutes() {
  AppNavigator.register(
    AppRoute.dailyCash,
    (context, args) => DailyCashScreen(showBack: args is bool ? args : null),
  );
}
