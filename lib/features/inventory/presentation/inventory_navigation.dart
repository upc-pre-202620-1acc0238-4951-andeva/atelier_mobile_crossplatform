import 'package:atelier_mobile_crossplatform/features/main/presentation/main_shell_controller.dart';
import 'package:flutter/material.dart';

/// Atrás de las pantallas de inventario (`popBackStack` de Android). Un detalle empujado se cierra; la raíz de
/// una pestaña (Stock, Compras) no tiene a dónde volver en el Navigator, así que regresa a la pestaña de inicio,
/// como el botón Atrás del sistema en el shell.
VoidCallback inventoryBack(BuildContext context) {
  return () {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.maybePop();
      return;
    }
    final shell = MainShellController.maybeOf(context);
    if (shell != null && shell.tabs.isNotEmpty) shell.navigateToTab(shell.tabs.first);
  };
}
