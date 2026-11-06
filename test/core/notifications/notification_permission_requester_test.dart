import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/device_token_registrar.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/notification_permission_requester.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRegistrar extends Mock implements DeviceTokenRegistrar {}

void main() {
  late _MockRegistrar registrar;

  setUp(() {
    registrar = _MockRegistrar();
    when(() => registrar.registerCurrentToken()).thenAnswer((_) async {});
  });

  NotificationPermissionRequester requester({required bool granted}) {
    return NotificationPermissionRequester(
      registrar: registrar,
      requestSystemPermission: () async => granted,
    );
  }

  test('concedido: registra el token', () async {
    expect(await requester(granted: true).request(), isTrue);
    verify(() => registrar.registerCurrentToken()).called(1);
  });

  test('negado: no registra', () async {
    expect(await requester(granted: false).request(), isFalse);
    verifyNever(() => registrar.registerCurrentToken());
  });

  test('un fallo al registrar no cambia el resultado', () async {
    when(
      () => registrar.registerCurrentToken(),
    ).thenThrow(const NetworkException());

    expect(await requester(granted: true).request(), isTrue);
  });
}
