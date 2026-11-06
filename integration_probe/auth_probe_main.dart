import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/sign_in_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/sign_out_use_case.dart';
import 'package:flutter/material.dart';

/// Prueba del paso 2 contra el backend real. No se publica y las credenciales no se versionan:
/// flutter run -t integration_probe/auth_probe_main.dart --dart-define-from-file=config/dev.json
///   --dart-define=PROBE_EMAIL=... --dart-define=PROBE_PASSWORD=...
const _email = String.fromEnvironment('PROBE_EMAIL');
const _password = String.fromEnvironment('PROBE_PASSWORD');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  final session = getIt<SessionManager>();
  try {
    await getIt<SignInUseCase>().execute(_email, _password);
    final current = await session.getSession();
    debugPrint(
      'PROBE sesión user=${current?.userId} permisos=${current?.permissions.length} '
      'plan=${current?.plan?.tier} sede=${current?.branchId} '
      'elegirSede=${current?.needsBranchChoice}',
    );
    await getIt<SignOutUseCase>().execute();
    debugPrint('PROBE salida sesión=${await session.getSession()}');
  } on Exception catch (e) {
    debugPrint('PROBE falló: $e');
  }
  runApp(const MaterialApp(home: Scaffold(body: Text('PROBE terminado'))));
}
