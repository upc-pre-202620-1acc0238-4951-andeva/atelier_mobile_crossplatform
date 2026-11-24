import 'package:flutter/material.dart';

/// Destinos con nombre de la app (equivalen a las `*Route` de Navigation Compose de Android).
/// Cada feature registra los suyos en su `setup<Feature>Presentation()` con [AppNavigator.register];
/// así ninguna feature importa las pantallas de otra (se resuelven al navegar).
///
/// Argumentos: `String` para rutas de un solo id; clase `*Args` de este archivo cuando hay varios.
enum AppRoute {
  // raíces de la app (solo las construye `AppRoot`)
  authGraph, // grafo sin sesión: login → registro → verificar correo
  mainShell, // Session? (la sesión de arranque): pestañas + barra flotante
  // auth
  login, // LoginArgs?
  register, // RegisterArgs?
  verifyEmail, // VerifyEmailArgs
  branchSelection,
  // attendance
  attendanceHome, // FloorHub (raíz de la pestaña Turno)
  attendanceDetail, // AttendanceScreen (mi asistencia)
  // main
  adminDashboard,
  adminAttendance,
  notifications,
  pendingOperations,
  profile,
  // tasks
  myTasks,
  taskDetail, // TaskDetailArgs
  // reception
  vehicleSearch,
  affiliation,
  registerCustomer, // RegisterCustomerArgs?
  // workorders
  workOrders,
  workOrderDetail, // String workOrderId
  openWorkOrder, // OpenWorkOrderArgs
  intakeGallery, // String workOrderId
  proposalsPanel, // String workOrderId
  reportFinding, // String workOrderId
  servicesCatalog,
  // inventory
  partsCatalog,
  skuScanner,
  partDetail, // String partId
  suppliers,
  purchaseOrders,
  purchaseOrderDetail, // String purchaseOrderId
  inventoryValuation,
  // diagnostics
  diagnosticsHub, // DiagnosticsHubArgs?
  vehicleFaults, // VehicleArgs
  aiHealthReport, // VehicleArgs
  // cashier
  dailyCash,
  // reports
  reports,
}

class LoginArgs {
  final String? verifiedEmail;
  final bool passwordReset;

  const LoginArgs({this.verifiedEmail, this.passwordReset = false});
}

class RegisterArgs {
  final String? token;

  const RegisterArgs({this.token});
}

class VerifyEmailArgs {
  final String email;

  const VerifyEmailArgs(this.email);
}

class TaskDetailArgs {
  final String workOrderId;
  final String taskId;

  const TaskDetailArgs({required this.workOrderId, required this.taskId});
}

class RegisterCustomerArgs {
  final String? email;
  final String? plate;
  final String? customerId;
  final String? customerName;

  const RegisterCustomerArgs({this.email, this.plate, this.customerId, this.customerName});
}

class OpenWorkOrderArgs {
  final String vehicleId;
  final String customerId;
  final String? workOrderId;

  const OpenWorkOrderArgs({required this.vehicleId, required this.customerId, this.workOrderId});
}

class DiagnosticsHubArgs {
  final String? initialVehicleId;

  const DiagnosticsHubArgs({this.initialVehicleId});
}

class VehicleArgs {
  final String vehicleId;
  final String? plate;

  const VehicleArgs({required this.vehicleId, this.plate});
}

typedef AppRouteBuilder = Widget Function(BuildContext context, Object? args);

abstract final class AppNavigator {
  static final Map<AppRoute, AppRouteBuilder> _builders = {};

  /// Cada feature registra aquí sus pantallas (una vez, al arrancar).
  static void register(AppRoute route, AppRouteBuilder builder) => _builders[route] = builder;

  static bool isRegistered(AppRoute route) => _builders.containsKey(route);

  /// El widget de la pantalla, p. ej. para las raíces de pestaña de `MainShell`.
  static Widget build(BuildContext context, AppRoute route, [Object? args]) {
    final builder = _builders[route];
    if (builder == null) {
      throw StateError('Destino sin registrar: $route');
    }
    return builder(context, args);
  }

  static Route<T> routeOf<T>(AppRoute route, [Object? args]) {
    return MaterialPageRoute<T>(
      settings: RouteSettings(name: route.name, arguments: args),
      builder: (context) => build(context, route, args),
    );
  }

  /// Empuja el destino en el `Navigator` más cercano.
  static Future<T?> push<T>(BuildContext context, AppRoute route, [Object? args]) {
    return Navigator.of(context).push<T>(routeOf<T>(route, args));
  }

  /// Reemplaza toda la pila por el destino (login ↔ app, elegir sede → inicio).
  static Future<T?> pushAndClear<T>(BuildContext context, AppRoute route, [Object? args]) {
    return Navigator.of(context).pushAndRemoveUntil<T>(routeOf<T>(route, args), (_) => false);
  }

  static Future<T?> pushReplacement<T, R>(BuildContext context, AppRoute route, [Object? args]) {
    return Navigator.of(context).pushReplacement<T, R>(routeOf<T>(route, args));
  }
}
