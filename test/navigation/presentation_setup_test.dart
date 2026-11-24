import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:atelier_mobile_crossplatform/navigation/presentation_setup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => getIt.reset());

  test('setupPresentation registra todos los destinos declarados en AppRoute', () {
    setupPresentation();

    for (final route in AppRoute.values) {
      expect(
        AppNavigator.isRegistered(route),
        isTrue,
        reason: 'Falta registrar $route en presentation_setup.dart',
      );
    }
  });
}
