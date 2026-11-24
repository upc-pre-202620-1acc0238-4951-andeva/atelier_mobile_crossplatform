import 'package:atelier_mobile_crossplatform/features/main/presentation/main_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/more/modules_sheet.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/navigation/main_tab.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';

/// Mando de `MainShell` para el resto de la app (equivale a `navigateToTab` y `navigateToModule` del
/// `NavController` de Android).
///
/// - Desde una pantalla que vive dentro de una pestaña: `MainShellController.of(context).navigateToTab(MainTab.orders)`.
/// - Desde cualquier otra (un detalle empujado al Navigator raíz, un push): `MainShellController.current`,
///   que existe mientras el shell está montado.
class MainShellController extends ChangeNotifier {
  /// El shell montado, o `null` sin sesión. Una pantalla de detalle no cuelga del shell en el árbol,
  /// por eso no puede usar [of].
  static MainShellController? current;

  final MainViewModel viewModel;
  /// El Navigator raíz, donde se apilan los detalles y se cierran al cambiar de pestaña.
  final NavigatorState Function() rootNavigator;

  /// La abre el shell; el slot "Módulos" de la barra la invoca.
  VoidCallback? onOpenModules;

  MainShellController({required this.viewModel, required this.rootNavigator}) {
    viewModel.addListener(notifyListeners);
  }

  /// El controlador del shell que contiene [context]. Falla si [context] no está dentro de una pestaña.
  static MainShellController of(BuildContext context) {
    final controller = maybeOf(context);
    assert(controller != null, 'MainShellController.of: el contexto no está dentro de MainShell.');
    return controller!;
  }

  static MainShellController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MainShellScope>()?.notifier;

  List<MainTab> get tabs => viewModel.state.tabs;

  MainTab? get selectedTab => viewModel.state.selected;

  /// Cambia de pestaña conservando el estado de cada una (scroll, búsqueda) y sin apilar copias: antes
  /// cierra los detalles que cubren la barra. `false` si la sesión no tiene esa pestaña.
  bool navigateToTab(MainTab tab) {
    if (!tabs.contains(tab)) return false;
    rootNavigator().popUntil((route) => route.isFirst);
    viewModel.select(tab);
    return true;
  }

  /// Abre [route]: si es la raíz de una pestaña de la barra ([tab]) cambia de pestaña; si no, la empuja
  /// al Navigator raíz (cubre la barra).
  void openRoute(AppRoute route, {MainTab? tab, Object? args}) {
    if (tab != null && navigateToTab(tab)) return;
    rootNavigator().push(AppNavigator.routeOf(route, args));
  }

  /// Abre un destino de la hoja de módulos (los mismos que sus baldosas).
  void navigateToModule(MoreDestination destination) {
    final (route, tab) = destination.target;
    openRoute(route, tab: tab);
  }

  /// Ejecuta la acción principal del botón circular de la barra.
  void openBarAction(BarPrimaryAction action) {
    switch (action) {
      case BarPrimaryAction.receiveVehicle || BarPrimaryAction.newAppointment:
        openRoute(AppRoute.vehicleSearch, tab: MainTab.reception);
      case BarPrimaryAction.collectPayment:
        openRoute(AppRoute.workOrders, tab: MainTab.orders);
      case BarPrimaryAction.scanSku:
        openRoute(AppRoute.skuScanner);
      case BarPrimaryAction.myTasks:
        openRoute(AppRoute.myTasks, tab: MainTab.tasks);
      case BarPrimaryAction.none:
        break;
    }
  }

  @override
  void dispose() {
    viewModel.removeListener(notifyListeners);
    if (identical(current, this)) current = null;
    super.dispose();
  }
}

/// Publica el [MainShellController] al árbol de las pestañas.
class MainShellScope extends InheritedNotifier<MainShellController> {
  const MainShellScope({super.key, required MainShellController controller, required super.child})
    : super(notifier: controller);
}
