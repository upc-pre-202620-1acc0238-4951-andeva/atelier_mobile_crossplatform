import 'package:atelier_mobile_crossplatform/core/notifications/auth_deep_link_inbox.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/branch/branch_selection_screen.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/forgot/forgot_password_screen.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/login/login_screen.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/register/register_screen.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/reset/reset_password_screen.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/verifyemail/verify_email_screen.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';

/// Registra los destinos de `auth` (equivale a `authNavGraph` y `branchSelectionDestination` de Android),
/// incluida la recuperación de contraseña (US05). Al iniciar sesión o aceptar la invitación no se navega
/// desde aquí: `AppRoot` cambia de grafo cuando `SessionManager` guarda la sesión.
void registerAuthDestinations({AuthDeepLinkInbox? Function()? deepLinks}) {
  AppNavigator.register(
    AppRoute.authGraph,
    (context, args) => AuthNavGraph(deepLinks: deepLinks?.call()),
  );
  AppNavigator.register(
    AppRoute.login,
    (context, args) => LoginScreen(
      args: args as LoginArgs?,
      onHaveInvitation: () => AppNavigator.push(context, AppRoute.register, const RegisterArgs()),
      onVerifyEmail: (email) => AppNavigator.push(context, AppRoute.verifyEmail, VerifyEmailArgs(email)),
      onForgotPassword: () => AppNavigator.push(context, AppRoute.forgotPassword),
    ),
  );
  AppNavigator.register(
    AppRoute.forgotPassword,
    (context, args) => ForgotPasswordScreen(
      onBack: () => Navigator.of(context).maybePop(),
      onHaveToken: () => AppNavigator.push(context, AppRoute.resetPassword, const ResetPasswordArgs()),
    ),
  );
  AppNavigator.register(
    AppRoute.resetPassword,
    (context, args) => ResetPasswordScreen(
      args: args as ResetPasswordArgs?,
      // `pop` y no `maybePop`: la pantalla ya confirmó descartar lo escrito.
      onBack: () {
        final navigator = Navigator.of(context);
        if (navigator.canPop()) navigator.pop();
      },
      onRequestNewLink: () {
        // Vuelve a la solicitud sin apilar otra copia.
        final navigator = Navigator.of(context);
        var found = false;
        navigator.popUntil((route) {
          if (route.settings.name == AppRoute.forgotPassword.name) found = true;
          return found || route.isFirst;
        });
        if (!found) AppNavigator.push(context, AppRoute.forgotPassword);
      },
      // Vuelve al login (que reemplaza al anterior) con el aviso de contraseña actualizada.
      onDone: () {
        if (!context.mounted) return;
        AppNavigator.pushAndClear(context, AppRoute.login, const LoginArgs(passwordReset: true));
      },
    ),
  );
  AppNavigator.register(
    AppRoute.register,
    (context, args) => RegisterScreen(
      args: args as RegisterArgs?,
      onBack: () => Navigator.of(context).maybePop(),
    ),
  );
  AppNavigator.register(AppRoute.verifyEmail, (context, args) {
    final email = (args as VerifyEmailArgs).email;
    return VerifyEmailScreen(
      email: email,
      onBack: () => Navigator.of(context).maybePop(),
      // Vuelve al login (que reemplaza al anterior) con el correo ya cargado y el aviso de verificado.
      onVerified: (verified) {
        if (!context.mounted) return;
        AppNavigator.pushAndClear(context, AppRoute.login, LoginArgs(verifiedEmail: verified));
      },
    );
  });
  // Ya con sesión: `AppRoot` la muestra cuando `needsBranchChoice`; "Módulos" la empuja para cambiar de sede.
  // En ambos casos, al terminar solo se cierra si hay a dónde volver (la raíz cambia sola con la sesión).
  AppNavigator.register(
    AppRoute.branchSelection,
    (context, args) => BranchSelectionScreen(
      onDone: () {
        if (!context.mounted) return;
        final navigator = Navigator.of(context);
        if (navigator.canPop()) navigator.pop();
      },
    ),
  );
}

/// Grafo sin sesión: login → registro por invitación → verificar correo, y login → recuperar → nueva
/// contraseña (US05). Es un `Navigator` propio, así el cambio de sesión lo descarta entero (como el
/// `navigation<AuthNavGraphRoute>` de Android). Consume los enlaces del correo: con uno pendiente abre el
/// registro o el restablecimiento con su token.
class AuthNavGraph extends StatefulWidget {
  final AuthDeepLinkInbox? deepLinks;

  const AuthNavGraph({super.key, this.deepLinks});

  @override
  State<AuthNavGraph> createState() => _AuthNavGraphState();
}

class _AuthNavGraphState extends State<AuthNavGraph> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final _observer = _CanPopObserver(_onStackChanged);
  bool _canPop = false;

  @override
  void initState() {
    super.initState();
    widget.deepLinks?.addListener(_consumeDeepLink);
    WidgetsBinding.instance.addPostFrameCallback((_) => _consumeDeepLink());
  }

  @override
  void dispose() {
    widget.deepLinks?.removeListener(_consumeDeepLink);
    super.dispose();
  }

  void _onStackChanged() {
    final canPop = _navigatorKey.currentState?.canPop() ?? false;
    if (canPop != _canPop && mounted) setState(() => _canPop = canPop);
  }

  void _consumeDeepLink() {
    final navigator = _navigatorKey.currentState;
    if (!mounted || navigator == null) return;
    final link = widget.deepLinks?.consume();
    if (link == null) return;
    // Un solo flujo a la vez: el enlace nuevo reemplaza lo que hubiera abierto.
    navigator.popUntil((route) => route.isFirst);
    switch (link) {
      case ResetPasswordDeepLink(:final token):
        navigator.push(AppNavigator.routeOf(AppRoute.resetPassword, ResetPasswordArgs(token: token)));
      case AcceptInvitationDeepLink(:final token):
        navigator.push(AppNavigator.routeOf(AppRoute.register, RegisterArgs(token: token)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigatorPopHandler(
      enabled: _canPop,
      onPopWithResult: (_) => _navigatorKey.currentState?.maybePop(),
      child: Navigator(
        key: _navigatorKey,
        observers: [_observer],
        onGenerateInitialRoutes: (navigator, initialRoute) => [
          AppNavigator.routeOf(AppRoute.login, const LoginArgs()),
        ],
      ),
    );
  }
}

class _CanPopObserver extends NavigatorObserver {
  final VoidCallback onChanged;

  _CanPopObserver(this.onChanged);

  void _notify() => WidgetsBinding.instance.addPostFrameCallback((_) => onChanged());

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _notify();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _notify();

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) => _notify();

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) => _notify();
}
