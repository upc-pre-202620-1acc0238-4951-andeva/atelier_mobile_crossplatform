import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/branch_option.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/invitation_preview.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/branch/branch_selection_screen.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/branch/branch_selection_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/register/register_screen.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/register/register_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/verifyemail/verify_email_screen.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/verifyemail/verify_email_ui_state.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
  theme: AtelierTheme.light,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('es'),
  home: child,
);

BranchSelectionContent _branch(BranchSelectionUiState state) => BranchSelectionContent(
  state: state,
  onSelect: (_) {},
  onContinue: () {},
  onSkip: () {},
  onRetry: () {},
);

RegisterContent _register(RegisterUiState state) => RegisterContent(
  state: state,
  onBack: () {},
  onLinkChange: (_) {},
  onValidateLink: () {},
  onFirstNameChange: (_) {},
  onLastNameChange: (_) {},
  onPasswordChange: (_) {},
  onConfirmPasswordChange: (_) {},
  onPasswordVisibleChange: (_) {},
  onConfirmVisibleChange: (_) {},
  onSubmit: () {},
);

void main() {
  group('Elegir sede', () {
    const branches = [
      BranchOption(id: '1', name: 'Sede San Isidro', geofenceRadiusMeters: 50),
      BranchOption(id: '2', name: 'Sede Ate', geofenceRadiusMeters: null),
    ];

    testWidgets('cargado: sedes, marca de asignada, radio y botón con la sede elegida', (tester) async {
      await tester.pumpWidget(
        _host(_branch(const BranchSelectionUiState(isLoading: false, branches: branches, selectedId: '1', assignedBranchId: '1'))),
      );
      await tester.pumpAndSettle();

      expect(find.text('Elige tu sede'), findsOneWidget);
      expect(find.text('Sede San Isidro'), findsOneWidget);
      expect(find.text('Sede Ate'), findsOneWidget);
      expect(find.text('Sucursal asignada para tu jornada · Marcación en un radio de 50 m'), findsOneWidget);
      expect(find.text('Continuar en Sede San Isidro'), findsOneWidget);
      expect(find.text('Elegir después'), findsOneWidget);
    });

    testWidgets('cargando: filas esqueleto y botón sin sede', (tester) async {
      await tester.pumpWidget(_host(_branch(const BranchSelectionUiState())));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Continuar'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('vacío: dice que el taller no tiene sedes', (tester) async {
      await tester.pumpWidget(_host(_branch(const BranchSelectionUiState(isLoading: false))));
      await tester.pumpAndSettle();

      expect(
        find.text('Tu taller aún no tiene sedes activas. Pide al administrador que cree una y vuelve a entrar.'),
        findsOneWidget,
      );
    });

    testWidgets('error: mensaje del backend y Reintentar', (tester) async {
      await tester.pumpWidget(
        _host(_branch(const BranchSelectionUiState(isLoading: false, error: UiText.dynamic('No se pudieron cargar las sedes.')))),
      );
      await tester.pumpAndSettle();

      expect(find.text('No se pudieron cargar las sedes.'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });
  });

  group('Registro por invitación', () {
    testWidgets('paso del enlace: pide pegarlo y Continuar queda deshabilitado', (tester) async {
      await tester.pumpWidget(_host(_register(const RegisterUiState())));
      await tester.pumpAndSettle();

      expect(find.text('Pega tu enlace'), findsOneWidget);
      expect(find.text('Enlace de invitación'), findsOneWidget);
      expect(find.text('Continuar'), findsOneWidget);
      expect(const RegisterUiState().canValidate, isFalse);
      expect(const RegisterUiState(linkInput: 'abc').canValidate, isTrue);
    });

    testWidgets('formulario: taller, rol invitado y reglas de contraseña', (tester) async {
      await tester.pumpWidget(
        _host(
          _register(
            const RegisterUiState(
              step: RegisterStep.form,
              invitation: InvitationPreview(email: 'a@taller.pe', tenantName: 'Taller Suárez', roleName: 'Mecánico'),
              password: 'Taller123',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Taller Suárez'), findsOneWidget);
      expect(find.text('Te invitaron a'), findsOneWidget);
      expect(find.text('Rol: Mecánico'), findsOneWidget);
      expect(find.text('Al menos 8 caracteres'), findsOneWidget);
      expect(find.text('Una letra mayúscula'), findsOneWidget);
      expect(find.text('Coincide con la confirmación'), findsOneWidget);
      expect(find.text('Completar registro'), findsOneWidget);
    });

    testWidgets('vencida: aviso y volver a iniciar sesión', (tester) async {
      await tester.pumpWidget(
        _host(_register(const RegisterUiState(step: RegisterStep.gone, problem: InvitationProblem.expired))),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Esta invitación venció.'), findsNWidgets(2)); // cabecera y aviso
      expect(find.textContaining('Pide una nueva al administrador de tu taller.'), findsOneWidget);
      expect(find.text('Volver a iniciar sesión'), findsOneWidget);
    });

    test('las reglas de contraseña y el envío', () {
      const ok = RegisterUiState(
        step: RegisterStep.form,
        firstName: 'Ana',
        lastName: 'Pérez',
        password: 'Taller123',
        confirmPassword: 'Taller123',
      );
      expect(ok.canSubmit, isTrue);
      expect(ok.copyWith(password: 'taller123', confirmPassword: 'taller123').canSubmit, isFalse); // sin mayúscula
      expect(ok.copyWith(confirmPassword: 'otra').canSubmit, isFalse);
      expect(ok.copyWith(password: 'Ta1', confirmPassword: 'Ta1').canSubmit, isFalse); // muy corta
    });
  });

  group('Verificar correo', () {
    testWidgets('código a medias: correo enmascarado, reenvío en cuenta regresiva y verificar deshabilitado', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          VerifyEmailContent(
            state: const VerifyEmailUiState(email: 'andres@taller.pe', code: '482', resendSecondsLeft: 42, expiresSecondsLeft: 582),
            onBack: () {},
            onCodeChange: (_) {},
            onVerify: () {},
            onResend: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Lo enviamos a a•••••@taller.pe'), findsOneWidget);
      expect(find.text('Reenviar en 0:42'), findsOneWidget);
      expect(find.textContaining('09:42'), findsOneWidget);
      expect(const VerifyEmailUiState(email: 'a@b.pe', code: '482').canSubmit, isFalse);
      expect(const VerifyEmailUiState(email: 'a@b.pe', code: '482170').canSubmit, isTrue);
    });

    testWidgets('error y código vencido', (tester) async {
      await tester.pumpWidget(
        _host(
          VerifyEmailContent(
            state: const VerifyEmailUiState(
              email: 'andres@taller.pe',
              code: '482170',
              error: UiText.dynamic('El código es incorrecto o venció.'),
              resendSecondsLeft: 0,
              expiresSecondsLeft: 0,
            ),
            onBack: () {},
            onCodeChange: (_) {},
            onVerify: () {},
            onResend: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('El código es incorrecto o venció.'), findsOneWidget);
      expect(find.text('El código venció. Pide uno nuevo.'), findsOneWidget);
      expect(find.text('Reenviar código'), findsOneWidget);
    });

    test('formatClock', () {
      expect(formatClock(582, pad: true), '09:42');
      expect(formatClock(42, pad: false), '0:42');
    });
  });
}
