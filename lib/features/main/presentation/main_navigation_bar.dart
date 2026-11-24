import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_navigation_bar.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/main_shell_controller.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/main_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/navigation/main_tab.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Barra flotante de la sesión. Solo se dibuja sobre la pantalla principal de una pestaña: los detalles
/// se empujan al Navigator raíz y la cubren. El último slot, "Módulos", no navega: abre la hoja universal
/// de módulos ([MainShellController.onOpenModules]) y muestra el contador de operaciones pendientes. El
/// botón circular de la derecha expone la acción principal que habilitan los permisos.
class MainNavigationBar extends StatelessWidget {
  final MainUiState state;
  final bool modulesOpen;
  final MainShellController controller;

  const MainNavigationBar({
    super.key,
    required this.state,
    required this.modulesOpen,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final tabIndex = state.selectedIndex;
    if (tabIndex < 0) return const SizedBox.shrink();

    final items = <AtelierNavItem>[
      for (var index = 0; index < state.tabs.length; index++)
        AtelierNavItem(
          label: state.tabs[index].label(strings),
          icon: state.tabs[index].icon,
          vectorIcon: state.tabs[index].vectorIcon,
          badge: !state.showModules && index == state.tabs.length - 1 ? state.pendingCount : 0,
        ),
      if (state.showModules)
        AtelierNavItem(
          label: strings.mainTabModules,
          icon: Icons.grid_view_outlined,
          badge: state.pendingCount,
        ),
    ];
    final modulesIndex = state.showModules ? items.length - 1 : -1;

    final AtelierBarAction? barAction = switch (state.primaryAction) {
      BarPrimaryAction.receiveVehicle => AtelierBarAction(
        label: strings.barActionReceive,
        description: strings.todayReceiveVehicle,
        icon: Icons.directions_car_outlined,
        onClick: () => controller.openBarAction(BarPrimaryAction.receiveVehicle),
      ),
      BarPrimaryAction.newAppointment => AtelierBarAction(
        label: strings.barActionAppointment,
        description: strings.barActionAppointmentDesc,
        icon: Icons.event_available_outlined,
        onClick: () => controller.openBarAction(BarPrimaryAction.newAppointment),
      ),
      BarPrimaryAction.collectPayment => AtelierBarAction(
        label: strings.barActionCollect,
        description: strings.barActionCollectDesc,
        icon: Icons.payments_outlined,
        onClick: () => controller.openBarAction(BarPrimaryAction.collectPayment),
      ),
      BarPrimaryAction.scanSku => AtelierBarAction(
        label: strings.barActionScan,
        description: strings.barActionScanDesc,
        icon: Icons.qr_code_scanner_outlined,
        onClick: () => controller.openBarAction(BarPrimaryAction.scanSku),
      ),
      BarPrimaryAction.myTasks => AtelierBarAction(
        label: strings.barActionTasks,
        description: strings.barActionTasksDesc,
        icon: Icons.assignment_turned_in_outlined,
        onClick: () => controller.openBarAction(BarPrimaryAction.myTasks),
      ),
      BarPrimaryAction.none => null,
    };

    return AtelierNavigationBar(
      items: items,
      selectedIndex: modulesOpen && modulesIndex >= 0 ? modulesIndex : tabIndex,
      onSelect: (index) {
        if (index == modulesIndex) {
          controller.onOpenModules?.call();
        } else if (index != tabIndex) {
          controller.navigateToTab(state.tabs[index]);
        }
      },
      action: barAction,
    );
  }
}
