import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/get_device_pending_operation_count_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/sign_in_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/auth_repository.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/login/login_screen.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/login/login_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/login/login_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

Widget _host(Widget child, {bool dark = false}) => MaterialApp(
  theme: dark ? AtelierTheme.dark : AtelierTheme.light,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('es'),
  home: child,
);

Widget _content(LoginUiState state) => LoginContent(
  state: state,
  onEmailChange: (_) {},
  onPasswordChange: (_) {},
  onPasswordVisibleChange: (_) {},
  onSubmit: () {},
  onHaveInvitation: () {},
);

void main() {
  group('LoginContent', () {
    testWidgets('estado inicial: textos de Android, sin enlace de recuperar contraseña', (tester) async {
      for (final dark in [false, true]) {
        await tester.pumpWidget(_host(_content(const LoginUiState()), dark: dark));
        await tester.pumpAndSettle();

        expect(find.text('Inicia sesión'), findsOneWidget);
        expect(find.text('Con el correo institucional de tu taller.'), findsOneWidget);
        expect(find.text('Correo institucional'), findsOneWidget);
        expect(find.text('Contraseña'), findsOneWidget);
        expect(find.text('Iniciar sesión'), findsOneWidget);
        expect(find.text('o'), findsOneWidget);
        expect(find.text('Tengo un enlace de invitación'), findsOneWidget);
        // US05 queda fuera: ni el enlace ni su texto.
        expect(find.textContaining('Olvidaste'), findsNothing);
      }
    });

    testWidgets('con correo y contraseña válidos el botón principal se habilita', (tester) async {
      await tester.pumpWidget(_host(_content(const LoginUiState(email: 'a@taller.pe', password: 'x'))));
      await tester.pumpAndSettle();
      expect(const LoginUiState(email: 'a@taller.pe', password: 'x').canSubmit, isTrue);
      expect(const LoginUiState(email: 'no-es-correo', password: 'x').canSubmit, isFalse);
      expect(const LoginUiState(email: 'a@taller.pe').canSubmit, isFalse);
    });

    testWidgets('cargando: el botón muestra progreso y no admite otro envío', (tester) async {
      await tester.pumpWidget(
        _host(_content(const LoginUiState(email: 'a@taller.pe', password: 'x', isLoading: true))),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(const LoginUiState(email: 'a@taller.pe', password: 'x', isLoading: true).canSubmit, isFalse);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('error: muestra el mensaje del backend tal cual', (tester) async {
      await tester.pumpWidget(
        _host(
          _content(
            const LoginUiState(
              email: 'a@taller.pe',
              password: 'x',
              error: UiText.dynamic('Correo o contraseña incorrectos.'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
    });

    testWidgets('avisos: correo verificado, contraseña actualizada y pendientes del teléfono', (tester) async {
      await tester.pumpWidget(
        _host(
          _content(const LoginUiState(emailVerified: true, passwordReset: true, devicePendingCount: 2)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Correo verificado. Ya puedes iniciar sesión.'), findsOneWidget);
      expect(find.text('Contraseña actualizada. Ya puedes iniciar sesión.'), findsOneWidget);
      expect(find.textContaining('2 operaciones pendientes'), findsOneWidget);
    });
  });

  group('LoginViewModel', () {
    late _MockAuthRepository repository;

    LoginViewModel viewModel({LoginArgs? args}) {
      when(() => repository.devicePendingOperationCount()).thenAnswer((_) async => 0);
      return LoginViewModel(
        signInUseCase: SignInUseCase(repository: repository),
        getDevicePendingCountUseCase: GetDevicePendingOperationCountUseCase(repository: repository),
        args: args,
      );
    }

    setUp(() => repository = _MockAuthRepository());

    test('el correo recién verificado llega precargado y con su aviso', () {
      final vm = viewModel(args: const LoginArgs(verifiedEmail: 'a@taller.pe'));
      expect(vm.state.email, 'a@taller.pe');
      expect(vm.state.emailVerified, isTrue);
      vm.dispose();
    });

    test('EMAIL_NOT_VERIFIED lleva a la pantalla del código, sin error en pantalla', () async {
      when(() => repository.signIn(any(), any())).thenThrow(
        const ApiException(httpStatus: 403, code: 'EMAIL_NOT_VERIFIED', message: 'Verifica tu correo.'),
      );
      final vm = viewModel()
        ..onEmailChange(' a@taller.pe ')
        ..onPasswordChange('secreta');

      await vm.onSubmit();

      expect(vm.state.unverifiedEmail, 'a@taller.pe');
      expect(vm.state.error, isNull);
      expect(vm.state.isLoading, isFalse);
      vm.onVerificationHandled();
      expect(vm.state.unverifiedEmail, isNull);
      vm.dispose();
    });

    test('otro error del backend muestra su mensaje y libera el botón', () async {
      when(() => repository.signIn(any(), any())).thenThrow(
        const ApiException(httpStatus: 401, code: 'BAD_CREDENTIALS', message: 'Credenciales inválidas.'),
      );
      final vm = viewModel()
        ..onEmailChange('a@taller.pe')
        ..onPasswordChange('mala');

      await vm.onSubmit();

      expect((vm.state.error as DynamicUiText).value, 'Credenciales inválidas.');
      expect(vm.state.isLoading, isFalse);
      vm.dispose();
    });

    test('editar un campo limpia el error', () async {
      when(() => repository.signIn(any(), any())).thenThrow(
        const ApiException(httpStatus: 401, code: 'X', message: 'Mal.'),
      );
      final vm = viewModel()
        ..onEmailChange('a@taller.pe')
        ..onPasswordChange('mala');
      await vm.onSubmit();
      expect(vm.state.error, isNotNull);

      vm.onPasswordChange('otra');
      expect(vm.state.error, isNull);
      vm.dispose();
    });
  });
}
