import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/forgot_password_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/reset_password_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/auth_repository.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/forgot/forgot_password_screen.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/forgot/forgot_password_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/forgot/forgot_password_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/reset/reset_password_screen.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/reset/reset_password_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/reset/reset_password_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

Widget _host(Widget child) => MaterialApp(
  theme: AtelierTheme.light,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('es'),
  home: child,
);

void main() {
  late _MockAuthRepository repository;

  setUp(() => repository = _MockAuthRepository());

  group('US05 E1 — solicitar el enlace', () {
    ForgotPasswordViewModel create() =>
        ForgotPasswordViewModel(forgotPasswordUseCase: ForgotPasswordUseCase(repository: repository));

    test('con un correo válido envía y muestra la confirmación genérica', () async {
      when(() => repository.forgotPassword(any())).thenAnswer((_) async => 'ok');
      final vm = create();

      expect(vm.state.canSubmit, isFalse);
      vm.onEmailChange(' andres@taller.pe ');
      expect(vm.state.canSubmit, isTrue);
      await vm.onSubmit();

      verify(() => repository.forgotPassword(' andres@taller.pe ')).called(1);
      expect(vm.state.sent, isTrue);
      expect(vm.state.isLoading, isFalse);

      vm.onRequestAgain();
      expect(vm.state.sent, isFalse);
      vm.dispose();
    });

    test('sin red muestra el error y no confirma', () async {
      when(() => repository.forgotPassword(any())).thenThrow(const NetworkException());
      final vm = create()..onEmailChange('andres@taller.pe');

      await vm.onSubmit();

      expect(vm.state.sent, isFalse);
      expect(vm.state.error, isNotNull);
      vm.onEmailChange('otro@taller.pe');
      expect(vm.state.error, isNull);
      vm.dispose();
    });

    testWidgets('pantalla: formulario y luego "Revisa tu correo" con "Ya tengo el enlace"', (tester) async {
      var haveToken = 0;
      Widget content(ForgotPasswordUiState state) => _host(
        ForgotPasswordContent(
          state: state,
          onBack: () {},
          onEmailChange: (_) {},
          onSubmit: () {},
          onHaveToken: () => haveToken++,
          onRequestAgain: () {},
        ),
      );

      await tester.pumpWidget(content(const ForgotPasswordUiState()));
      await tester.pumpAndSettle();
      expect(find.text('Recupera tu contraseña'), findsWidgets);
      expect(find.text('Enviar enlace'), findsOneWidget);
      expect(find.text('Correo institucional'), findsOneWidget);

      await tester.pumpWidget(content(const ForgotPasswordUiState(email: 'a@taller.pe', sent: true)));
      await tester.pumpAndSettle();
      expect(find.text('Revisa tu correo'), findsOneWidget);
      expect(find.text('Pedir otro enlace'), findsOneWidget);
      await tester.tap(find.text('Ya tengo el enlace'));
      expect(haveToken, 1);
    });
  });

  group('US05 E2 — token expirado o adulterado', () {
    ResetPasswordViewModel create({ResetPasswordArgs? args}) => ResetPasswordViewModel(
      resetPasswordUseCase: ResetPasswordUseCase(repository: repository),
      args: args,
    );

    void fillPasswords(ResetPasswordViewModel vm) {
      vm
        ..onPasswordChange('Taller123')
        ..onConfirmationChange('Taller123');
    }

    test('el enlace del correo llega precargado y se envía solo el token', () async {
      when(() => repository.resetPassword(any(), any())).thenAnswer((_) async => 'ok');
      final vm = create(
        args: const ResetPasswordArgs(token: 'https://atelier.andeva.tech/auth/reset-password?token=abc%2B1'),
      );
      fillPasswords(vm);

      expect(vm.state.canSubmit, isTrue);
      await vm.onSubmit();

      verify(() => repository.resetPassword('abc+1', 'Taller123')).called(1);
      expect(vm.state.done, isTrue);
      vm.dispose();
    });

    test('un enlace sin token, reglas sin cumplir o contraseñas distintas no se envían', () async {
      final vm = create()
        ..onTokenChange('https://atelier.andeva.tech/auth/reset-password?token=')
        ..onPasswordChange('Taller123')
        ..onConfirmationChange('Taller123');
      expect(vm.state.hasValidExtractedToken, isFalse);
      expect(vm.state.canSubmit, isFalse);

      vm
        ..onTokenChange('abc')
        ..onPasswordChange('taller123');
      expect(vm.state.hasUppercase, isFalse);
      expect(vm.state.canSubmit, isFalse);

      vm
        ..onPasswordChange('Taller123')
        ..onConfirmationChange('Taller124');
      expect(vm.state.passwordsMatch, isFalse);
      expect(vm.state.canSubmit, isFalse);
      verifyNever(() => repository.resetPassword(any(), any()));
      vm.dispose();
    });

    for (final status in [400, 404]) {
      test('un $status marca el enlace como vencido y pide uno nuevo', () async {
        when(() => repository.resetPassword(any(), any())).thenThrow(
          ApiException(httpStatus: status, code: 'X', message: 'Token inválido'),
        );
        final vm = create()..onTokenChange('vencido');
        fillPasswords(vm);

        await vm.onSubmit();

        expect(vm.state.tokenInvalid, isTrue);
        expect(vm.state.done, isFalse);
        expect(vm.state.error, isNull);
        vm.onTokenChange('nuevo');
        expect(vm.state.tokenInvalid, isFalse);
        vm.dispose();
      });
    }

    test('otro error muestra el mensaje del backend', () async {
      when(() => repository.resetPassword(any(), any())).thenThrow(
        const ApiException(httpStatus: 500, code: 'X', message: 'Falló'),
      );
      final vm = create()..onTokenChange('abc');
      fillPasswords(vm);

      await vm.onSubmit();

      expect(vm.state.tokenInvalid, isFalse);
      expect(vm.state.error, isNotNull);
      vm.dispose();
    });

    testWidgets('pantalla: enlace vencido muestra el aviso y "Pedir un enlace nuevo"', (tester) async {
      var requested = 0;
      await tester.pumpWidget(
        _host(
          ResetPasswordContent(
            state: const ResetPasswordUiState(token: 'abc', tokenInvalid: true),
            onBack: () {},
            onTokenChange: (_) {},
            onPasswordChange: (_) {},
            onConfirmationChange: (_) {},
            onPasswordVisibleChange: (_) {},
            onConfirmationVisibleChange: (_) {},
            onSubmit: () {},
            onRequestNewLink: () => requested++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('El enlace venció o no es válido. Pide uno nuevo.'), findsOneWidget);
      expect(find.text('Enlace o código'), findsOneWidget);
      expect(find.text('Cambiar contraseña'), findsOneWidget);
      await tester.tap(find.text('Pedir un enlace nuevo'));
      expect(requested, 1);
    });

    testWidgets('pantalla: con contraseña escrita, Atrás pide confirmar el descarte', (tester) async {
      var backs = 0;
      await tester.pumpWidget(
        _host(
          ResetPasswordContent(
            state: const ResetPasswordUiState(token: 'abc', password: 'Taller1'),
            onBack: () => backs++,
            onTokenChange: (_) {},
            onPasswordChange: (_) {},
            onConfirmationChange: (_) {},
            onPasswordVisibleChange: (_) {},
            onConfirmationVisibleChange: (_) {},
            onSubmit: () {},
            onRequestNewLink: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_outlined));
      await tester.pumpAndSettle();
      expect(find.text('¿Descartar cambios?'), findsOneWidget);
      expect(backs, 0);

      await tester.tap(find.text('Descartar'));
      await tester.pumpAndSettle();
      expect(backs, 1);
    });
  });
}
