import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/auth_deep_link_inbox.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/push_inbox.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/push_router.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/main_shell_controller.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/navigation/main_tab.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_nav_host_view_model.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';

export 'package:atelier_mobile_crossplatform/navigation/root_navigator.dart';

/// Equivale a `AppNavHost`: grafo sin sesión (login, registro, verificar correo), elegir sede o `MainShell`,
/// según la sesión. Un cambio de sesión (login, logout o sesión vencida) limpia la pila. Abre los push y
/// avisa de los enlaces de invitación recibidos con la sesión ya iniciada.
///
/// Los detalles se apilan en el Navigator raíz, encima de esta pantalla, y cubren la barra flotante.
class AppRoot extends StatefulWidget {
  final SessionManager session;
  final PushInbox? pushInbox;
  final AuthDeepLinkInbox? authDeepLinks;

  const AppRoot({
    super.key,
    required this.session,
    this.pushInbox,
    this.authDeepLinks,
  });

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  late final AppNavHostViewModel _viewModel = AppNavHostViewModel(
    sessionManager: widget.session,
    pushInbox: widget.pushInbox,
    authDeepLinks: widget.authDeepLinks,
  );

  /// Qué pantalla raíz se está mostrando; al cambiar, se descarta todo lo apilado encima.
  Object? _shownRoot;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    _viewModel.dispose();
    super.dispose();
  }

  static Object? _rootOf(SessionState state) => switch (state) {
    SessionLoading() => null,
    SessionSignedOut() => #signedOut,
    SessionSignedIn(needsBranchChoice: true) => #branchChoice,
    SessionSignedIn() => #signedIn,
  };

  void _onChanged() {
    final root = _rootOf(_viewModel.sessionState);
    if (root != null) {
      // Login, logout o sesión vencida: se cambia de grafo limpiando la pila.
      if (_shownRoot != null && _shownRoot != root) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
      _shownRoot = root;
    }
    if (_viewModel.hasReadyPush) {
      final destination = _viewModel.consumePush();
      // Después del cuadro: con un arranque desde el push, el shell aún no está montado.
      if (destination != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _openPush(destination);
        });
      }
    }
    if (_viewModel.hasReadyDeepLink) {
      final link = _viewModel.consumeAuthDeepLink();
      if (link != null) {
        // Con sesión no se acepta una invitación: se avisa.
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).authDeeplinkSignedInWarning,
            ),
          ),
        );
      }
    }
  }

  /// Abre la pantalla de un push. La revisión de suspensión (US29) abre la tarea; la alerta de stock mínimo
  /// (US34) abre la bandeja de alertas.
  void _openPush(PushDestination destination) {
    final shell = MainShellController.current;
    void open(AppRoute route, {MainTab? tab, Object? args}) {
      if (shell != null) {
        shell.openRoute(route, tab: tab, args: args);
      } else {
        Navigator.of(context).push(AppNavigator.routeOf(route, args));
      }
    }

    switch (destination) {
      case TaskDetailDestination(:final workOrderId, :final taskId) ||
          TaskProductsDestination(:final workOrderId, :final taskId):
        open(
          AppRoute.taskDetail,
          args: TaskDetailArgs(workOrderId: workOrderId, taskId: taskId),
        );
      case WorkOrderDetailDestination(:final workOrderId):
        open(AppRoute.workOrderDetail, args: workOrderId);
      case CollaboratorAttendanceDestination():
        open(AppRoute.adminAttendance, tab: MainTab.team);
      case MyAttendanceDestination() || ClockInDestination():
        open(AppRoute.attendanceHome, tab: MainTab.shift);
      case TaskSuspensionReviewDestination(:final workOrderId, :final taskId):
        open(
          AppRoute.taskDetail,
          args: TaskDetailArgs(workOrderId: workOrderId, taskId: taskId),
        );
      case LowStockAlertsDestination():
        open(AppRoute.stockAlerts);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final background = Theme.of(context).scaffoldBackgroundColor;
        return switch (_viewModel.sessionState) {
          SessionLoading() => ColoredBox(color: background),
          SessionSignedOut() => AppNavigator.build(context, AppRoute.authGraph),
          SessionSignedIn(needsBranchChoice: true) => AppNavigator.build(
            context,
            AppRoute.branchSelection,
          ),
          SessionSignedIn() => AppNavigator.build(
            context,
            AppRoute.mainShell,
            _viewModel.session,
          ),
        };
      },
    );
  }
}
