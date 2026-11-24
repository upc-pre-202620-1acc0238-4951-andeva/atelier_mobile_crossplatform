import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_pending_operation_count_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/main_shell.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/main_view_model.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';

/// Shell de `main` (barra flotante, pestañas y "Módulos"). Las pantallas de `main` (dashboard, asistencia de
/// sede, notificaciones, perfil y pendientes) las registra `setupMainPresentation`.
void setupMainShellPresentation() {
  getIt.registerFactoryParam<MainViewModel, Session?, void>(
    (session, _) => MainViewModel(
      observeSessionUseCase: getIt<ObserveSessionUseCase>(),
      observePendingCountUseCase: getIt<ObservePendingOperationCountUseCase>(),
      initialSession: session,
    ),
  );
  AppNavigator.register(
    AppRoute.mainShell,
    (context, args) => MainShell(initialSession: args as Session?),
  );
}
