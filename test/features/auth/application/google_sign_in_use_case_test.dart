import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/google_sign_in_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/auth_errors.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/auth_repository.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/google_id_token_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements AuthRepository {}

class _FakeProvider implements GoogleIdTokenProvider {
  final GoogleIdTokenResult result;

  const _FakeProvider(this.result);

  @override
  Future<GoogleIdTokenResult> request() async => result;
}

void main() {
  late _MockRepository repository;

  setUp(() => repository = _MockRepository());

  GoogleSignInUseCase useCase(GoogleIdTokenResult result) {
    return GoogleSignInUseCase(
      provider: _FakeProvider(result),
      repository: repository,
    );
  }

  test('con token entra', () async {
    when(() => repository.signInWithGoogle('t')).thenAnswer((_) async {});

    expect(
      await useCase(const GoogleIdToken('t')).execute(),
      GoogleSignInOutcome.signedIn,
    );
    verify(() => repository.signInWithGoogle('t')).called(1);
  });

  test('sin token no llama al backend', () async {
    expect(
      await useCase(const GoogleIdTokenCancelled()).execute(),
      GoogleSignInOutcome.cancelled,
    );
    expect(
      await useCase(const GoogleIdTokenNotConfigured()).execute(),
      GoogleSignInOutcome.notConfigured,
    );
    expect(
      await useCase(const GoogleIdTokenFailed()).execute(),
      GoogleSignInOutcome.providerFailed,
    );
    verifyNever(() => repository.signInWithGoogle(any()));
  });

  test(
    'un error del backend sube, para que llegue a la pantalla OTP',
    () async {
      when(() => repository.signInWithGoogle('t')).thenThrow(
        const ApiException(
          httpStatus: 403,
          code: emailNotVerifiedCode,
          message: 'Sin verificar',
        ),
      );

      await expectLater(
        useCase(const GoogleIdToken('t')).execute(),
        throwsA(isA<ApiException>()),
      );
    },
  );
}
