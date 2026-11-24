import 'package:atelier_mobile_crossplatform/core/designsystem/icon/atelier_icons.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';

extension SessionOperationalDashboard on Session {
  /// `true` cuando la sesión tiene permisos de supervisión de sede o apertura/resolución de órdenes de
  /// trabajo. Quien no los tiene aterriza en `FloorHub` (pestaña Turno), adaptado a sus permisos de piso o
  /// mostrador.
  bool prefersOperationalDashboard() =>
      has(Permission.workOrdersCreate) ||
      has(Permission.quotationsApprove) ||
      has(Permission.attendanceAuditAll) ||
      has(Permission.baysAssign) ||
      has(Permission.obdDevicesRegister) ||
      has(Permission.cashflowExportPdf) ||
      has(Permission.fiscalConfigManage);
}

/// Acción principal del botón circular (64 dp) a la derecha de la barra flotante, decidida por permiso.
enum BarPrimaryAction {
  receiveVehicle,
  newAppointment,
  collectPayment,
  scanSku,
  myTasks,
  none;

  static BarPrimaryAction forSession(Session session) {
    if (session.has(Permission.workOrdersCreate)) return receiveVehicle;
    if (session.has(Permission.appointmentsCreate)) return newAppointment;
    if (session.has(Permission.invoicesIssueSunat) || session.has(Permission.paymentsCreate)) {
      return collectPayment;
    }
    if (session.has(Permission.partsManage) || session.has(Permission.purchaseOrdersCreate)) return scanSku;
    if (session.has(Permission.tasksTrackTime) &&
        session.has(Permission.tasksRead) &&
        !MainTab.tabsFor(session).contains(MainTab.tasks)) {
      return myTasks;
    }
    return none;
  }
}

/// Pestaña raíz de la barra inferior flotante. [route] es la pantalla inicial de la pestaña: la barra se
/// dibuja solo sobre estas raíces y los detalles, que se empujan al Navigator raíz, la cubren.
///
/// Bahías (US40) no existe como pestaña: su historia está fuera.
enum MainTab {
  shift(AppRoute.attendanceHome, icon: Icons.schedule_outlined),
  today(AppRoute.adminDashboard, icon: Icons.today_outlined),
  tasks(AppRoute.myTasks, vectorIcon: AtelierIcons.assignment),
  reception(AppRoute.vehicleSearch, icon: Icons.directions_car_outlined),
  orders(AppRoute.workOrders, vectorIcon: AtelierIcons.assignment),
  team(AppRoute.adminAttendance, icon: Icons.groups_outlined),
  inventory(AppRoute.partsCatalog, icon: Icons.inventory_2_outlined),
  purchases(AppRoute.purchaseOrders, icon: Icons.shopping_cart_outlined),
  cash(AppRoute.dailyCash, icon: Icons.payments_outlined),
  obd(AppRoute.diagnosticsHub, vectorIcon: AtelierIcons.bluetoothSearching);

  final AppRoute route;
  final IconData? icon;
  final AtelierVectorIcon? vectorIcon;

  const MainTab(this.route, {this.icon, this.vectorIcon});

  String label(AppLocalizations strings) => switch (this) {
    shift => strings.mainTabShift,
    today => strings.mainTabToday,
    tasks => strings.mainTabTasks,
    reception => strings.mainTabReception,
    orders => strings.mainTabOrders,
    team => strings.mainTabTeam,
    inventory => strings.mainTabStock,
    purchases => strings.mainTabPurchases,
    cash => strings.mainTabCash,
    obd => strings.mainTabObd,
  };

  static const _maxPrimaryTabs = 3;

  /// Todas las sesiones autenticadas cuentan con el slot "Módulos" al final de la cápsula (máx. 4 slots),
  /// garantizando acceso a cualquier pantalla permitida y a Cuenta/Notificaciones/Sync sin bloqueos.
  static bool hasModules(Session session) => true;

  /// Destinos de la barra estrictamente por permiso atómico (nunca por rol).
  /// Siempre incluye el destino de inicio en el índice 0 para garantizar que la barra sea visible al arrancar.
  static List<MainTab> tabsFor(Session session) {
    final result = <MainTab>[];
    void addUnique(MainTab tab) {
      if (result.length < _maxPrimaryTabs && !result.contains(tab)) result.add(tab);
    }

    if (session.prefersOperationalDashboard()) {
      addUnique(today);
      if (session.has(Permission.attendanceAuditAll)) {
        // Dueño, Administrador, Mecánico Jefe: Hoy · Órdenes · Equipo (+ Módulos)
        if (session.has(Permission.workOrdersRead)) addUnique(orders);
        addUnique(team);
      } else {
        // Asesor de Servicio u operación sin auditoría de equipo: Hoy · Recepción · Órdenes (+ Módulos)
        if (session.has(Permission.appointmentsRead) || session.has(Permission.customersRead)) {
          addUnique(reception);
        }
        if (session.has(Permission.workOrdersRead)) addUnique(orders);
      }
      return result;
    }

    // Personal de piso y mostrador (Segmento 2): siempre arranca en "Turno" (FloorHub modular)
    addUnique(shift);

    // Prioridad 1: ejecución en fosa (Técnico Mecánico)
    if (session.has(Permission.tasksTrackTime) && session.has(Permission.tasksRead)) {
      addUnique(tasks);
      if (session.canUseTelemetry()) {
        addUnique(obd);
      } else if (session.has(Permission.workOrdersRead)) {
        addUnique(orders);
      }
    }

    // Prioridad 2: mostrador / agenda (Recepcionista)
    if (session.has(Permission.appointmentsRead) || session.has(Permission.customersCreate)) {
      addUnique(reception);
      if (session.has(Permission.workOrdersRead)) addUnique(orders);
    }

    // Prioridad 3: almacén / suministros (Encargado de Inventario)
    if (session.has(Permission.partsManage) ||
        session.has(Permission.purchaseOrdersCreate) ||
        session.has(Permission.batchesReceive)) {
      if (session.has(Permission.partsRead)) addUnique(inventory);
      if (session.has(Permission.purchaseOrdersRead)) addUnique(purchases);
    }

    // Prioridad 4: caja y facturación (Cajero)
    if (session.has(Permission.invoicesIssueSunat) || session.has(Permission.paymentsCreate)) {
      if (session.has(Permission.workOrdersRead)) addUnique(orders);
      if (session.has(Permission.invoicesRead)) addUnique(cash);
    }

    // Relleno por permiso para roles híbridos o personalizados
    if (session.has(Permission.tasksRead)) addUnique(tasks);
    if (session.has(Permission.workOrdersRead)) addUnique(orders);
    if (session.has(Permission.partsRead)) addUnique(inventory);
    if (session.canUseTelemetry() || session.canReadTelemetry()) addUnique(obd);

    return result;
  }
}
