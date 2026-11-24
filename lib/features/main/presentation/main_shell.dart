import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_navigation_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/main_navigation_bar.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/main_shell_controller.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/main_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/more/modules_sheet.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/navigation/main_tab.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';

// Alto de la cápsula, margen inferior y holgura bajo el contenido (`AtelierNavigationBar` + 8 dp de `AppNavHost`).
const double _barHeight = 64;
const double _barMargin = 12;
const double _barGap = 8;

/// Sesión iniciada: las raíces de pestaña en un `IndexedStack`-equivalente (conservan su estado) y la barra
/// flotante encima. Equivale a `MainNavigation` + `MainNavigationBar` + `isTabRoot` de Android.
///
/// Los detalles se empujan al Navigator raíz y cubren la barra: esta solo se ve mientras el shell es la
/// pantalla de arriba. Una pestaña se construye al visitarla por primera vez, con `AppNavigator.build`.
class MainShell extends StatefulWidget {
  /// La sesión de arranque, para tener las pestañas desde el primer cuadro.
  final Session? initialSession;

  /// Solo para pruebas: si no se pasa, el shell crea el suyo con `get_it` y lo libera.
  final MainViewModel? viewModel;

  const MainShell({super.key, this.initialSession, this.viewModel});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late final MainViewModel _viewModel =
      widget.viewModel ?? getIt<MainViewModel>(param1: widget.initialSession);
  late final MainShellController _controller;
  final Set<MainTab> _visited = {};
  bool _modulesOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = MainShellController(
      viewModel: _viewModel,
      rootNavigator: () => Navigator.of(context, rootNavigator: true),
    )..onOpenModules = _openModules;
    MainShellController.current = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    if (widget.viewModel == null) _viewModel.dispose();
    super.dispose();
  }

  Future<void> _openModules() async {
    if (_modulesOpen) return;
    setState(() => _modulesOpen = true);
    await showAtelierSheetBuilder<void>(
      context: context,
      builder: (sheetContext) => ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) => ModulesSheet(
          session: _viewModel.state.session,
          pendingSync: _viewModel.state.pendingCount,
          onOpen: (destination) {
            Navigator.of(sheetContext).pop();
            _controller.navigateToModule(destination);
          },
        ),
      ),
    );
    if (mounted) setState(() => _modulesOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).scaffoldBackgroundColor;
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final state = _viewModel.state;
        final selected = state.selected;
        if (selected == null) return ColoredBox(color: background);
        _visited.add(selected);
        // La barra flota sobre el contenido: no reserva alto. Publica el que tapa y las raíces de pestaña lo
        // suman al final de su lista con `floatingBarPadding()`.
        final inset = _barHeight + _barMargin + MediaQuery.paddingOf(context).bottom + _barGap;
        return PopScope(
          // Atrás en una pestaña que no es la de inicio vuelve a la de inicio; en esa, sale de la app.
          canPop: selected == state.tabs.first,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _viewModel.select(state.tabs.first);
          },
          child: MainShellScope(
            controller: _controller,
            child: Material(
              color: background,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FloatingBarInset(
                    value: inset,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        for (final tab in state.tabs)
                          if (_visited.contains(tab))
                            _TabPane(
                              key: ValueKey(tab),
                              selected: tab == selected,
                              child: Builder(builder: (context) => AppNavigator.build(context, tab.route)),
                            ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: MainNavigationBar(state: state, modulesOpen: _modulesOpen, controller: _controller),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Una raíz de pestaña: sigue viva fuera de la vista (conserva su estado) y entra con un fundido de 120 ms.
class _TabPane extends StatefulWidget {
  final bool selected;
  final Widget child;

  const _TabPane({super.key, required this.selected, required this.child});

  @override
  State<_TabPane> createState() => _TabPaneState();
}

class _TabPaneState extends State<_TabPane> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
    value: 1,
  );

  @override
  void didUpdateWidget(_TabPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !oldWidget.selected) {
      if (rememberReducedMotion(context)) {
        _controller.value = 1;
      } else {
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: !widget.selected,
      child: TickerMode(
        enabled: widget.selected,
        child: FadeTransition(opacity: _controller, child: widget.child),
      ),
    );
  }
}
