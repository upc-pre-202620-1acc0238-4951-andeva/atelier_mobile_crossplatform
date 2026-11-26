import 'dart:math' as math;

import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_grouped_card.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/icon/atelier_icons.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/navigation/main_tab.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';

/// Adónde puede ir quien abre "Módulos". `MainShellController.navigateToModule` decide la ruta de cada uno.
///
/// Incluye Series de comprobantes (US42) y Alertas de stock (US34).
enum MoreDestination {
  branch,
  myAttendance,
  myTasks,
  workOrders,
  bays,
  reception,
  services,
  dailyCash,
  vouchers,
  fiscalSeries,
  reports,
  parts,
  purchaseOrders,
  suppliers,
  valuation,
  stockAlerts,
  obd,
  notifications,
  syncQueue,
  profile;

  /// La pantalla del módulo y, si es raíz de una pestaña, esa pestaña: con ella en la barra se cambia de
  /// pestaña en vez de apilar una copia.
  (AppRoute, MainTab?) get target => switch (this) {
    branch => (AppRoute.branchSelection, null),
    myAttendance => (AppRoute.attendanceDetail, null),
    myTasks => (AppRoute.myTasks, MainTab.tasks),
    workOrders => (AppRoute.workOrders, MainTab.orders),
    bays => (AppRoute.bays, null),
    reception => (AppRoute.vehicleSearch, MainTab.reception),
    services => (AppRoute.servicesCatalog, null),
    dailyCash => (AppRoute.dailyCash, MainTab.cash),
    vouchers => (AppRoute.vouchers, null),
    fiscalSeries => (AppRoute.fiscalSeries, null),
    reports => (AppRoute.reports, null),
    parts => (AppRoute.partsCatalog, MainTab.inventory),
    purchaseOrders => (AppRoute.purchaseOrders, MainTab.purchases),
    suppliers => (AppRoute.suppliers, null),
    valuation => (AppRoute.inventoryValuation, null),
    stockAlerts => (AppRoute.stockAlerts, null),
    obd => (AppRoute.diagnosticsHub, MainTab.obd),
    notifications => (AppRoute.notifications, null),
    syncQueue => (AppRoute.pendingOperations, null),
    profile => (AppRoute.profile, null),
  };
}

const _tileColumns = 4;

enum _MoreGroup { workshop, cashier, stock, account }

class _MoreRow {
  final _MoreGroup group;
  final MoreDestination destination;
  final IconData? icon;
  final AtelierVectorIcon? vectorIcon;
  final String Function(AppLocalizations strings) title;
  final String Function(AppLocalizations strings) subtitle;

  const _MoreRow({
    required this.group,
    required this.destination,
    this.icon,
    this.vectorIcon,
    required this.title,
    required this.subtitle,
  });
}

/// Filas que la sesión puede abrir, en el orden en que se dibujan.
List<_MoreRow> _moreRows(Session s) {
  final rows = <_MoreRow>[];
  void add(
    _MoreGroup group,
    MoreDestination destination,
    IconData? icon,
    String Function(AppLocalizations) title,
    String Function(AppLocalizations) subtitle, {
    AtelierVectorIcon? vectorIcon,
  }) => rows.add(
    _MoreRow(
      group: group,
      destination: destination,
      icon: icon,
      vectorIcon: vectorIcon,
      title: title,
      subtitle: subtitle,
    ),
  );

  if (s.canSwitchBranch()) {
    add(
      _MoreGroup.workshop,
      MoreDestination.branch,
      Icons.storefront_outlined,
      (t) => t.moreHBranch,
      (t) => t.moreHBranchSub,
    );
  }
  if (s.has(Permission.attendanceClockIn) ||
      s.has(Permission.attendanceClockOut)) {
    add(
      _MoreGroup.workshop,
      MoreDestination.myAttendance,
      Icons.schedule_outlined,
      (t) => t.moreHMyAttendance,
      (t) => t.moreHMyAttendanceSub,
    );
  }
  if (s.has(Permission.tasksRead)) {
    final isOwnExecution = s.has(Permission.tasksTrackTime);
    final isWorkshopSupervision =
        s.has(Permission.workOrdersUpdate) ||
        s.has(Permission.tasksHoldValidate) ||
        s.has(Permission.baysReassign);
    if (isOwnExecution) {
      add(
        _MoreGroup.workshop,
        MoreDestination.myTasks,
        Icons.assignment_turned_in_outlined,
        (t) => t.moreHMyTasks,
        (t) => t.moreHMyTasksSub,
      );
    } else if (isWorkshopSupervision) {
      add(
        _MoreGroup.workshop,
        MoreDestination.myTasks,
        Icons.assignment_turned_in_outlined,
        (t) => t.moreHWorkshopTasks,
        (t) => t.moreHWorkshopTasksSub,
      );
    }
  }
  if (s.has(Permission.workOrdersRead) &&
      !MainTab.tabsFor(s).contains(MainTab.orders)) {
    add(
      _MoreGroup.workshop,
      MoreDestination.workOrders,
      Icons.build_outlined,
      (t) => t.moreHOrders,
      (t) => t.moreHOrdersSub,
    );
  }
  if (s.has(Permission.baysRead)) {
    add(
      _MoreGroup.workshop,
      MoreDestination.bays,
      Icons.garage_outlined,
      (t) => t.moreHBays,
      (t) => t.moreHBaysSub,
    );
  }
  if (s.has(Permission.customersRead) ||
      s.has(Permission.vehiclesRead) ||
      s.has(Permission.workOrdersCreate) ||
      s.has(Permission.appointmentsRead)) {
    add(
      _MoreGroup.workshop,
      MoreDestination.reception,
      Icons.directions_car_outlined,
      (t) => t.moreHReception,
      (t) => t.moreHReceptionSub,
    );
  }
  if (s.has(Permission.servicesRead) || s.has(Permission.servicesManage)) {
    add(
      _MoreGroup.workshop,
      MoreDestination.services,
      Icons.handyman_outlined,
      (t) => t.moreHServices,
      (t) => t.moreHServicesSub,
    );
  }
  if (s.canUseTelemetry() ||
      s.canReadTelemetry() ||
      s.canUseAiDiagnostics() ||
      s.canReadAiReports() ||
      s.has(Permission.devicesRead) ||
      s.has(Permission.devicesRegister) ||
      s.has(Permission.predictiveAlertsRead)) {
    add(
      _MoreGroup.workshop,
      MoreDestination.obd,
      null,
      (t) => t.moreHObd,
      (t) => t.moreHObdSub,
      vectorIcon: AtelierIcons.bluetoothSearching,
    );
  }
  if (s.has(Permission.invoicesRead)) {
    add(
      _MoreGroup.cashier,
      MoreDestination.dailyCash,
      Icons.payments_outlined,
      (t) => t.moreHDailyCash,
      (t) => t.moreHDailyCashSub,
    );
    add(
      _MoreGroup.cashier,
      MoreDestination.vouchers,
      Icons.receipt_long_outlined,
      (t) => t.moreHVouchers,
      (t) => t.moreHVouchersSub,
    );
  }
  if (s.has(Permission.fiscalConfigManage)) {
    add(
      _MoreGroup.cashier,
      MoreDestination.fiscalSeries,
      Icons.confirmation_number_outlined,
      (t) => t.moreHFiscalSeries,
      (t) => t.moreHFiscalSeriesSub,
    );
  }
  if (s.has(Permission.cashflowExportPdf) ||
      (s.canReadAiReports() && s.has(Permission.customersRead))) {
    add(
      _MoreGroup.cashier,
      MoreDestination.reports,
      Icons.assessment_outlined,
      (t) => t.moreHReports,
      (t) => t.moreHReportsSub,
    );
  }
  if (s.has(Permission.partsRead)) {
    add(
      _MoreGroup.stock,
      MoreDestination.parts,
      Icons.inventory_2_outlined,
      (t) => t.moreHParts,
      (t) => t.moreHPartsSub,
    );
  }
  if (s.has(Permission.purchaseOrdersRead)) {
    add(
      _MoreGroup.stock,
      MoreDestination.purchaseOrders,
      Icons.shopping_cart_outlined,
      (t) => t.moreHPurchases,
      (t) => t.moreHPurchasesSub,
    );
  }
  if (s.has(Permission.suppliersManage)) {
    add(
      _MoreGroup.stock,
      MoreDestination.suppliers,
      Icons.local_shipping_outlined,
      (t) => t.moreHSuppliers,
      (t) => t.moreHSuppliersSub,
    );
  }
  // El endpoint de valorización exige `inventory:batches:read` (docs/02); no existe un permiso de valorización.
  if (s.has(Permission.batchesRead)) {
    add(
      _MoreGroup.stock,
      MoreDestination.valuation,
      Icons.account_balance_wallet_outlined,
      (t) => t.moreHValuation,
      (t) => t.moreHValuationSub,
    );
  }
  if (s.has(Permission.alertsRead)) {
    add(
      _MoreGroup.stock,
      MoreDestination.stockAlerts,
      Icons.warning_amber_outlined,
      (t) => t.moreHStockAlerts,
      (t) => t.moreHStockAlertsSub,
    );
  }
  add(
    _MoreGroup.account,
    MoreDestination.notifications,
    Icons.notifications_outlined,
    (t) => t.moreHNotifications,
    (t) => t.moreHNotificationsSub,
  );
  add(
    _MoreGroup.account,
    MoreDestination.syncQueue,
    Icons.sync_outlined,
    (t) => t.moreHSync,
    (t) => t.moreHSyncSub,
  );
  add(
    _MoreGroup.account,
    MoreDestination.profile,
    Icons.person_outlined,
    (t) => t.moreHProfile,
    (t) => t.moreHProfileSub,
  );
  return rows;
}

String _groupTitle(AppLocalizations t, _MoreGroup group) => switch (group) {
  _MoreGroup.workshop => t.moreHGroupWorkshop,
  _MoreGroup.cashier => t.moreHGroupCashier,
  _MoreGroup.stock => t.moreHGroupStock,
  _MoreGroup.account => t.moreHGroupAccount,
};

/// Hoja de módulos, la misma de quina-webapp: sube desde abajo, se arrastra para cerrar y muestra baldosas de
/// cuatro columnas agrupadas por tarea. Cada baldosa aparece solo si la sesión tiene el permiso del endpoint
/// que la alimenta (docs/02), nunca por rol; un grupo sin baldosas no se dibuja. Al pie, la cuenta.
///
/// Se abre con `showAtelierSheetBuilder`; este widget es la hoja completa. [onOpen] recibe el módulo elegido.
class ModulesSheet extends StatelessWidget {
  final Session? session;
  final int pendingSync;
  final ValueChanged<MoreDestination> onOpen;

  const ModulesSheet({
    super.key,
    required this.session,
    required this.pendingSync,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final session = this.session;
    final rows = session == null ? const <_MoreRow>[] : _moreRows(session);
    return AtelierBottomSheet(
      title: strings.modulesTitle,
      content: _body(
        context,
        rows: rows,
        email: session?.email,
        pendingSync: pendingSync,
      ),
    );
  }

  /// Un grupo por tarea (taller, caja, repuestos) con sus baldosas, y al pie la tarjeta de cuenta.
  List<Widget> _body(
    BuildContext context, {
    required List<_MoreRow> rows,
    required String? email,
    required int pendingSync,
  }) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final body = <Widget>[];
    for (final group in _MoreGroup.values.where(
      (g) => g != _MoreGroup.account,
    )) {
      final items = rows.where((r) => r.group == group).toList();
      if (items.isEmpty) continue;
      body.add(
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            _groupTitle(strings, group),
            style: context.text.labelLarge!.copyWith(
              color: colors.inkSecondary,
            ),
          ),
        ),
      );
      for (var start = 0; start < items.length; start += _tileColumns) {
        final chunk = items.sublist(
          start,
          math.min(start + _tileColumns, items.length),
        );
        body.add(
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                for (final row in chunk)
                  Expanded(
                    child: _ModuleTile(
                      row: row,
                      onClick: () => onOpen(row.destination),
                    ),
                  ),
                for (var i = chunk.length; i < _tileColumns; i++)
                  const Spacer(),
              ],
            ),
          ),
        );
      }
    }
    final account = rows.where((r) => r.group == _MoreGroup.account).toList();
    if (account.isNotEmpty) {
      body.add(
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: AtelierGroupedCard(
            title: _groupTitle(strings, _MoreGroup.account),
            children: [
              for (var index = 0; index < account.length; index++)
                AtelierGroupedRow(
                  title: account[index].title(strings),
                  subtitle:
                      account[index].destination == MoreDestination.profile
                      ? email ?? account[index].subtitle(strings)
                      : account[index].subtitle(strings),
                  icon: account[index].icon,
                  trailingBadgeText:
                      account[index].destination == MoreDestination.syncQueue &&
                          pendingSync > 0
                      ? pendingSync.toString()
                      : null,
                  showDivider: index < account.length - 1,
                  onClick: () => onOpen(account[index].destination),
                ),
            ],
          ),
        ),
      );
    }
    return body;
  }
}

class _ModuleTile extends StatelessWidget {
  final _MoreRow row;
  final VoidCallback onClick;

  const _ModuleTile({required this.row, required this.onClick});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final icon = row.icon;
    final vector = row.vectorIcon;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 88),
      child: AtelierSurface(
        tier: SurfaceTier.card,
        shape: controlShape,
        onClick: onClick,
        contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surfaceRecessed,
              ),
              child: icon != null
                  ? Icon(icon, size: 22, color: colors.primaryText)
                  : AtelierIcon(vector!, size: 22, color: colors.primaryText),
            ),
            Text(
              row.title(strings),
              style: context.text.bodySmall!.copyWith(
                color: context.scheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
