import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('es')];

  /// Nombre de la app
  ///
  /// In es, this message translates to:
  /// **'Atelier'**
  String get appTitle;

  /// Operación de la cola que agotó sus reintentos
  ///
  /// In es, this message translates to:
  /// **'No se pudo sincronizar'**
  String get syncFailedMaxAttempts;

  /// Falta la configuración de Supabase
  ///
  /// In es, this message translates to:
  /// **'Falta configurar el almacenamiento de fotos'**
  String get errorStorageNotConfigured;

  /// Supabase rechazó la subida
  ///
  /// In es, this message translates to:
  /// **'No se pudo subir la foto'**
  String get errorStorageUploadFailed;

  /// Foto en cola cuyo archivo local ya no existe
  ///
  /// In es, this message translates to:
  /// **'La foto ya no está en el teléfono'**
  String get errorPendingPhotoMissing;

  /// Canal de notificaciones de Android
  ///
  /// In es, this message translates to:
  /// **'Tareas'**
  String get notificationChannelTasks;

  /// Canal de notificaciones de Android
  ///
  /// In es, this message translates to:
  /// **'Asistencia'**
  String get notificationChannelAttendance;

  /// Canal de notificaciones de Android
  ///
  /// In es, this message translates to:
  /// **'Inventario'**
  String get notificationChannelInventory;

  /// Canal de notificaciones de Android
  ///
  /// In es, this message translates to:
  /// **'Diagnóstico'**
  String get notificationChannelDiagnostics;

  /// Notificación fija mientras dura la lectura en vivo
  ///
  /// In es, this message translates to:
  /// **'Diagnóstico OBD-II en curso'**
  String get diagnosticsSessionNotificationTitle;

  /// Marcador hasta que exista la pantalla de login
  ///
  /// In es, this message translates to:
  /// **'Inicio de sesión'**
  String get placeholderSignedOut;

  /// Marcador hasta que exista la pantalla A5b
  ///
  /// In es, this message translates to:
  /// **'Elegir sede'**
  String get placeholderBranchChoice;

  /// Marcador hasta que exista el paso 3
  ///
  /// In es, this message translates to:
  /// **'Sesión iniciada'**
  String get placeholderSignedIn;

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'Atelier Workshop'**
  String get appName;

  /// No description provided for @errorRequiresConnection.
  ///
  /// In es, this message translates to:
  /// **'Requiere conexión'**
  String get errorRequiresConnection;

  /// No description provided for @errorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error. Inténtalo de nuevo.'**
  String get errorGeneric;

  /// No description provided for @errorDeviceClock.
  ///
  /// In es, this message translates to:
  /// **'Revisa la hora de tu teléfono'**
  String get errorDeviceClock;

  /// No description provided for @commonBack.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get commonBack;

  /// No description provided for @commonRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get commonRetry;

  /// No description provided for @plateA11y.
  ///
  /// In es, this message translates to:
  /// **'placa {p1}'**
  String plateA11y(String p1);

  /// No description provided for @sectionWithCount.
  ///
  /// In es, this message translates to:
  /// **'{p1} · {p2}'**
  String sectionWithCount(String p1, int p2);

  /// No description provided for @stateOfflineNoCache.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión y sin datos guardados'**
  String get stateOfflineNoCache;

  /// No description provided for @authEmailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo institucional'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get authPasswordLabel;

  /// No description provided for @authConfirmPassword.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get authConfirmPassword;

  /// No description provided for @authShowPassword.
  ///
  /// In es, this message translates to:
  /// **'Mostrar contraseña'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In es, this message translates to:
  /// **'Ocultar contraseña'**
  String get authHidePassword;

  /// No description provided for @authFirstName.
  ///
  /// In es, this message translates to:
  /// **'Nombres'**
  String get authFirstName;

  /// No description provided for @authLastName.
  ///
  /// In es, this message translates to:
  /// **'Apellidos'**
  String get authLastName;

  /// No description provided for @authLoginTitle.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Con el correo institucional de tu taller.'**
  String get authLoginSubtitle;

  /// No description provided for @authLoginAction.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get authLoginAction;

  /// No description provided for @authForgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get authForgotPassword;

  /// No description provided for @authOr.
  ///
  /// In es, this message translates to:
  /// **'o'**
  String get authOr;

  /// No description provided for @authHaveInvitation.
  ///
  /// In es, this message translates to:
  /// **'Tengo un enlace de invitación'**
  String get authHaveInvitation;

  /// No description provided for @authEmailVerified.
  ///
  /// In es, this message translates to:
  /// **'Correo verificado. Ya puedes iniciar sesión.'**
  String get authEmailVerified;

  /// No description provided for @authRegisterTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear tu cuenta'**
  String get authRegisterTitle;

  /// No description provided for @authLinkTitle.
  ///
  /// In es, this message translates to:
  /// **'Pega tu enlace'**
  String get authLinkTitle;

  /// No description provided for @authLinkBody.
  ///
  /// In es, this message translates to:
  /// **'Usa el enlace del correo con el que te invitó el administrador de tu taller.'**
  String get authLinkBody;

  /// No description provided for @authLinkLabel.
  ///
  /// In es, this message translates to:
  /// **'Enlace de invitación'**
  String get authLinkLabel;

  /// No description provided for @authLinkPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Pega el enlace o el código'**
  String get authLinkPlaceholder;

  /// No description provided for @authContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get authContinue;

  /// No description provided for @authInvitedTo.
  ///
  /// In es, this message translates to:
  /// **'Te invitaron a'**
  String get authInvitedTo;

  /// No description provided for @authInvitedRole.
  ///
  /// In es, this message translates to:
  /// **'Rol: {p1}'**
  String authInvitedRole(String p1);

  /// No description provided for @authRuleLength.
  ///
  /// In es, this message translates to:
  /// **'Al menos 8 caracteres'**
  String get authRuleLength;

  /// No description provided for @authRuleUppercase.
  ///
  /// In es, this message translates to:
  /// **'Una letra mayúscula'**
  String get authRuleUppercase;

  /// No description provided for @authRuleMatch.
  ///
  /// In es, this message translates to:
  /// **'Coincide con la confirmación'**
  String get authRuleMatch;

  /// No description provided for @authRuleMet.
  ///
  /// In es, this message translates to:
  /// **'Cumplido'**
  String get authRuleMet;

  /// No description provided for @authRulePending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get authRulePending;

  /// No description provided for @authCompleteRegistration.
  ///
  /// In es, this message translates to:
  /// **'Completar registro'**
  String get authCompleteRegistration;

  /// No description provided for @authInvitationExpiredTitle.
  ///
  /// In es, this message translates to:
  /// **'Esta invitación venció.'**
  String get authInvitationExpiredTitle;

  /// No description provided for @authInvitationExpiredBody.
  ///
  /// In es, this message translates to:
  /// **'Pide una nueva al administrador de tu taller.'**
  String get authInvitationExpiredBody;

  /// No description provided for @authInvitationGoneTitle.
  ///
  /// In es, this message translates to:
  /// **'Esta invitación ya no es válida.'**
  String get authInvitationGoneTitle;

  /// No description provided for @authInvitationGoneBody.
  ///
  /// In es, this message translates to:
  /// **'Fue revocada o el enlace está incompleto. Pide una nueva al administrador de tu taller.'**
  String get authInvitationGoneBody;

  /// No description provided for @authBackToLogin.
  ///
  /// In es, this message translates to:
  /// **'Volver a iniciar sesión'**
  String get authBackToLogin;

  /// No description provided for @authVerifyTitle.
  ///
  /// In es, this message translates to:
  /// **'Verifica tu correo'**
  String get authVerifyTitle;

  /// No description provided for @authOtpTitle.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el código'**
  String get authOtpTitle;

  /// No description provided for @authOtpSentTo.
  ///
  /// In es, this message translates to:
  /// **'Lo enviamos a {p1}'**
  String authOtpSentTo(String p1);

  /// No description provided for @authOtpLabel.
  ///
  /// In es, this message translates to:
  /// **'Código de verificación de {p1} dígitos'**
  String authOtpLabel(int p1);

  /// No description provided for @authOtpProgress.
  ///
  /// In es, this message translates to:
  /// **'{p1} de {p2} dígitos'**
  String authOtpProgress(int p1, int p2);

  /// No description provided for @authOtpExpiresIn.
  ///
  /// In es, this message translates to:
  /// **'Vence en {p1}'**
  String authOtpExpiresIn(String p1);

  /// No description provided for @authOtpExpired.
  ///
  /// In es, this message translates to:
  /// **'El código venció. Pide uno nuevo.'**
  String get authOtpExpired;

  /// No description provided for @authOtpResent.
  ///
  /// In es, this message translates to:
  /// **'Te enviamos un código nuevo.'**
  String get authOtpResent;

  /// No description provided for @authResend.
  ///
  /// In es, this message translates to:
  /// **'Reenviar código'**
  String get authResend;

  /// No description provided for @authResendIn.
  ///
  /// In es, this message translates to:
  /// **'Reenviar en {p1}'**
  String authResendIn(String p1);

  /// No description provided for @authVerifyAction.
  ///
  /// In es, this message translates to:
  /// **'Verificar código'**
  String get authVerifyAction;

  /// No description provided for @authForgotTitle.
  ///
  /// In es, this message translates to:
  /// **'Recupera tu contraseña'**
  String get authForgotTitle;

  /// No description provided for @authForgotBody.
  ///
  /// In es, this message translates to:
  /// **'Escribe el correo de tu cuenta y te enviaremos un enlace para crear una contraseña nueva. El enlace vence en 2 horas.'**
  String get authForgotBody;

  /// No description provided for @authForgotAction.
  ///
  /// In es, this message translates to:
  /// **'Enviar enlace'**
  String get authForgotAction;

  /// No description provided for @authForgotSentTitle.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu correo'**
  String get authForgotSentTitle;

  /// No description provided for @authForgotSent.
  ///
  /// In es, this message translates to:
  /// **'Si el correo pertenece a una cuenta, te enviamos un enlace para restablecer la contraseña.'**
  String get authForgotSent;

  /// No description provided for @authHaveToken.
  ///
  /// In es, this message translates to:
  /// **'Ya tengo el enlace'**
  String get authHaveToken;

  /// No description provided for @authRequestAgain.
  ///
  /// In es, this message translates to:
  /// **'Pedir otro enlace'**
  String get authRequestAgain;

  /// No description provided for @authResetTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña'**
  String get authResetTitle;

  /// No description provided for @authResetBody.
  ///
  /// In es, this message translates to:
  /// **'Pega el enlace del correo, o solo el código que trae, y elige tu contraseña nueva.'**
  String get authResetBody;

  /// No description provided for @authResetTokenLabel.
  ///
  /// In es, this message translates to:
  /// **'Enlace o código'**
  String get authResetTokenLabel;

  /// No description provided for @authResetHint.
  ///
  /// In es, this message translates to:
  /// **'El enlace vence 2 horas después de pedirlo y solo sirve una vez.'**
  String get authResetHint;

  /// No description provided for @authResetAction.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get authResetAction;

  /// No description provided for @authResetInvalid.
  ///
  /// In es, this message translates to:
  /// **'El enlace venció o no es válido. Pide uno nuevo.'**
  String get authResetInvalid;

  /// No description provided for @authResetRequestNew.
  ///
  /// In es, this message translates to:
  /// **'Pedir un enlace nuevo'**
  String get authResetRequestNew;

  /// No description provided for @authPasswordUpdated.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actualizada. Ya puedes iniciar sesión.'**
  String get authPasswordUpdated;

  /// No description provided for @attendanceTitle.
  ///
  /// In es, this message translates to:
  /// **'Asistencia'**
  String get attendanceTitle;

  /// No description provided for @attendanceToday.
  ///
  /// In es, this message translates to:
  /// **'Mi jornada de hoy'**
  String get attendanceToday;

  /// No description provided for @attendanceNotClockedIn.
  ///
  /// In es, this message translates to:
  /// **'Todavía no has marcado tu ingreso.'**
  String get attendanceNotClockedIn;

  /// No description provided for @attendanceClockInPending.
  ///
  /// In es, this message translates to:
  /// **'Ingreso guardado. Se sincronizará cuando vuelva la conexión.'**
  String get attendanceClockInPending;

  /// No description provided for @attendanceClockOutPending.
  ///
  /// In es, this message translates to:
  /// **'Salida guardada. Se sincronizará cuando vuelva la conexión.'**
  String get attendanceClockOutPending;

  /// No description provided for @attendanceCapturedAt.
  ///
  /// In es, this message translates to:
  /// **'Hora registrada en el dispositivo: {p1}'**
  String attendanceCapturedAt(String p1);

  /// No description provided for @attendanceClockedInAt.
  ///
  /// In es, this message translates to:
  /// **'Ingreso: {p1}'**
  String attendanceClockedInAt(String p1);

  /// No description provided for @attendanceCompletedAt.
  ///
  /// In es, this message translates to:
  /// **'Jornada finalizada: {p1}'**
  String attendanceCompletedAt(String p1);

  /// No description provided for @attendanceClockOutAt.
  ///
  /// In es, this message translates to:
  /// **'Salida: {p1}'**
  String attendanceClockOutAt(String p1);

  /// No description provided for @attendanceDistance.
  ///
  /// In es, this message translates to:
  /// **'Distancia estimada a la sede: {p1} m'**
  String attendanceDistance(int p1);

  /// No description provided for @attendanceWorkedMinutes.
  ///
  /// In es, this message translates to:
  /// **'Tiempo trabajado: {p1} min'**
  String attendanceWorkedMinutes(int p1);

  /// No description provided for @attendanceRegularMinutes.
  ///
  /// In es, this message translates to:
  /// **'Tiempo regular: {p1} min'**
  String attendanceRegularMinutes(int p1);

  /// No description provided for @attendanceOvertimeMinutes.
  ///
  /// In es, this message translates to:
  /// **'Sobretiempo: {p1} min'**
  String attendanceOvertimeMinutes(int p1);

  /// No description provided for @attendanceClockIn.
  ///
  /// In es, this message translates to:
  /// **'Marcar ingreso'**
  String get attendanceClockIn;

  /// No description provided for @attendanceClockOut.
  ///
  /// In es, this message translates to:
  /// **'Marcar salida'**
  String get attendanceClockOut;

  /// No description provided for @attendanceRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get attendanceRefresh;

  /// No description provided for @attendanceRefreshing.
  ///
  /// In es, this message translates to:
  /// **'Actualizando asistencia…'**
  String get attendanceRefreshing;

  /// No description provided for @attendanceMyShift.
  ///
  /// In es, this message translates to:
  /// **'Mi turno'**
  String get attendanceMyShift;

  /// No description provided for @attendanceNoShift.
  ///
  /// In es, this message translates to:
  /// **'No tienes un turno asignado. Contacta al administrador de tu taller.'**
  String get attendanceNoShift;

  /// No description provided for @attendanceShiftHours.
  ///
  /// In es, this message translates to:
  /// **'Horario: {p1} – {p2}'**
  String attendanceShiftHours(String p1, String p2);

  /// No description provided for @attendanceGracePeriod.
  ///
  /// In es, this message translates to:
  /// **'Tolerancia: {p1} minutos'**
  String attendanceGracePeriod(int p1);

  /// No description provided for @attendanceBranchUnavailable.
  ///
  /// In es, this message translates to:
  /// **'Sede no disponible en caché'**
  String get attendanceBranchUnavailable;

  /// No description provided for @attendanceWorkDay.
  ///
  /// In es, this message translates to:
  /// **'Laborable'**
  String get attendanceWorkDay;

  /// No description provided for @attendanceRestDay.
  ///
  /// In es, this message translates to:
  /// **'Descanso'**
  String get attendanceRestDay;

  /// No description provided for @attendanceHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial de asistencia'**
  String get attendanceHistory;

  /// No description provided for @attendanceHistoryEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay asistencias en el historial disponible.'**
  String get attendanceHistoryEmpty;

  /// No description provided for @attendanceStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado: {p1}'**
  String attendanceStatus(String p1);

  /// No description provided for @attendanceStatusUnknown.
  ///
  /// In es, this message translates to:
  /// **'Sin clasificar'**
  String get attendanceStatusUnknown;

  /// No description provided for @attendanceStatusOnTime.
  ///
  /// In es, this message translates to:
  /// **'A tiempo'**
  String get attendanceStatusOnTime;

  /// No description provided for @attendanceStatusLate.
  ///
  /// In es, this message translates to:
  /// **'Tardanza'**
  String get attendanceStatusLate;

  /// No description provided for @attendanceStatusExcused.
  ///
  /// In es, this message translates to:
  /// **'Justificada'**
  String get attendanceStatusExcused;

  /// No description provided for @attendanceStatusAbsent.
  ///
  /// In es, this message translates to:
  /// **'Ausencia'**
  String get attendanceStatusAbsent;

  /// No description provided for @attendanceJustificationReason.
  ///
  /// In es, this message translates to:
  /// **'Motivo enviado: {p1}'**
  String attendanceJustificationReason(String p1);

  /// No description provided for @attendanceJustificationStatus.
  ///
  /// In es, this message translates to:
  /// **'Descargo: {p1}'**
  String attendanceJustificationStatus(String p1);

  /// No description provided for @attendanceJustificationPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente de revisión'**
  String get attendanceJustificationPending;

  /// No description provided for @attendanceJustificationApproved.
  ///
  /// In es, this message translates to:
  /// **'Aprobado'**
  String get attendanceJustificationApproved;

  /// No description provided for @attendanceJustificationRejected.
  ///
  /// In es, this message translates to:
  /// **'Rechazado'**
  String get attendanceJustificationRejected;

  /// No description provided for @attendanceJustify.
  ///
  /// In es, this message translates to:
  /// **'Presentar descargo'**
  String get attendanceJustify;

  /// No description provided for @attendanceJustificationTitle.
  ///
  /// In es, this message translates to:
  /// **'Justificar asistencia'**
  String get attendanceJustificationTitle;

  /// No description provided for @attendanceJustificationHelp.
  ///
  /// In es, this message translates to:
  /// **'Explica el motivo de la tardanza o ausencia. El administrador revisará el descargo.'**
  String get attendanceJustificationHelp;

  /// No description provided for @attendanceJustificationLabel.
  ///
  /// In es, this message translates to:
  /// **'Motivo'**
  String get attendanceJustificationLabel;

  /// No description provided for @attendanceJustificationSend.
  ///
  /// In es, this message translates to:
  /// **'Enviar descargo'**
  String get attendanceJustificationSend;

  /// No description provided for @attendanceCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get attendanceCancel;

  /// No description provided for @attendanceLocationUnavailable.
  ///
  /// In es, this message translates to:
  /// **'No se pudo obtener la ubicación actual. Activa la ubicación del dispositivo e inténtalo de nuevo.'**
  String get attendanceLocationUnavailable;

  /// No description provided for @attendanceLocationInaccurate.
  ///
  /// In es, this message translates to:
  /// **'La ubicación tiene una precisión de aproximadamente {p1} m. Sal a un lugar abierto e inténtalo otra vez; se requiere una precisión de 50 m o mejor.'**
  String attendanceLocationInaccurate(int p1);

  /// No description provided for @attendanceJustificationInvalid.
  ///
  /// In es, this message translates to:
  /// **'Escribe un motivo de descargo de hasta 500 caracteres.'**
  String get attendanceJustificationInvalid;

  /// No description provided for @attendanceLocationPermissionRequired.
  ///
  /// In es, this message translates to:
  /// **'Para marcar el ingreso, permite el acceso a la ubicación precisa en los permisos de la aplicación.'**
  String get attendanceLocationPermissionRequired;

  /// No description provided for @attendanceMockLocationWarning.
  ///
  /// In es, this message translates to:
  /// **'El dispositivo reporta una ubicación simulada. El backend decide si puede aceptar la marcación.'**
  String get attendanceMockLocationWarning;

  /// No description provided for @attendanceOutsideGeofenceWarning.
  ///
  /// In es, this message translates to:
  /// **'Estás aproximadamente a {p1} m de la sede, fuera de la geocerca. El backend validará la marcación.'**
  String attendanceOutsideGeofenceWarning(int p1);

  /// No description provided for @attendancePermissionClockIn.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta no tiene permiso para marcar ingreso.'**
  String get attendancePermissionClockIn;

  /// No description provided for @attendancePermissionClockOut.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta no tiene permiso para marcar salida.'**
  String get attendancePermissionClockOut;

  /// No description provided for @attendancePermissionJustification.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta no tiene permiso para presentar descargos.'**
  String get attendancePermissionJustification;

  /// No description provided for @attendanceMissingAssignment.
  ///
  /// In es, this message translates to:
  /// **'No tienes sede o turno asignado. Contacta al administrador del taller.'**
  String get attendanceMissingAssignment;

  /// No description provided for @attendanceClockInRecorded.
  ///
  /// In es, this message translates to:
  /// **'Ingreso registrado correctamente.'**
  String get attendanceClockInRecorded;

  /// No description provided for @attendanceClockInQueued.
  ///
  /// In es, this message translates to:
  /// **'Ingreso guardado sin conexión; se enviará automáticamente al recuperar señal.'**
  String get attendanceClockInQueued;

  /// No description provided for @attendanceClockOutRecorded.
  ///
  /// In es, this message translates to:
  /// **'Salida registrada correctamente.'**
  String get attendanceClockOutRecorded;

  /// No description provided for @attendanceClockOutQueued.
  ///
  /// In es, this message translates to:
  /// **'Salida guardada sin conexión; se enviará automáticamente al recuperar señal.'**
  String get attendanceClockOutQueued;

  /// No description provided for @attendanceJustificationRecorded.
  ///
  /// In es, this message translates to:
  /// **'Descargo enviado correctamente.'**
  String get attendanceJustificationRecorded;

  /// No description provided for @attendanceJustificationQueued.
  ///
  /// In es, this message translates to:
  /// **'Descargo guardado sin conexión; se enviará automáticamente al recuperar señal.'**
  String get attendanceJustificationQueued;

  /// No description provided for @attendanceAlreadyQueued.
  ///
  /// In es, this message translates to:
  /// **'Esta acción ya está pendiente o falló. Revísala en Pendientes de sincronizar.'**
  String get attendanceAlreadyQueued;

  /// No description provided for @dayMonday.
  ///
  /// In es, this message translates to:
  /// **'Lunes'**
  String get dayMonday;

  /// No description provided for @dayTuesday.
  ///
  /// In es, this message translates to:
  /// **'Martes'**
  String get dayTuesday;

  /// No description provided for @dayWednesday.
  ///
  /// In es, this message translates to:
  /// **'Miércoles'**
  String get dayWednesday;

  /// No description provided for @dayThursday.
  ///
  /// In es, this message translates to:
  /// **'Jueves'**
  String get dayThursday;

  /// No description provided for @dayFriday.
  ///
  /// In es, this message translates to:
  /// **'Viernes'**
  String get dayFriday;

  /// No description provided for @daySaturday.
  ///
  /// In es, this message translates to:
  /// **'Sábado'**
  String get daySaturday;

  /// No description provided for @daySunday.
  ///
  /// In es, this message translates to:
  /// **'Domingo'**
  String get daySunday;

  /// No description provided for @branchTitle.
  ///
  /// In es, this message translates to:
  /// **'Elige tu sede'**
  String get branchTitle;

  /// No description provided for @branchSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta no tiene una sede asignada. Elige en cuál vas a trabajar.'**
  String get branchSubtitle;

  /// No description provided for @branchGeofence.
  ///
  /// In es, this message translates to:
  /// **'Marcación en un radio de {p1} m'**
  String branchGeofence(int p1);

  /// No description provided for @branchContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get branchContinue;

  /// No description provided for @branchContinueIn.
  ///
  /// In es, this message translates to:
  /// **'Continuar en {p1}'**
  String branchContinueIn(String p1);

  /// No description provided for @branchLater.
  ///
  /// In es, this message translates to:
  /// **'Elegir después'**
  String get branchLater;

  /// No description provided for @branchRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get branchRetry;

  /// No description provided for @branchLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando sedes'**
  String get branchLoading;

  /// No description provided for @branchEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu taller aún no tiene sedes activas.'**
  String get branchEmptyTitle;

  /// No description provided for @branchEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Pide al administrador que cree una y vuelve a entrar.'**
  String get branchEmptyBody;

  /// No description provided for @receptionInvalidInput.
  ///
  /// In es, this message translates to:
  /// **'Revisa los datos marcados.'**
  String get receptionInvalidInput;

  /// No description provided for @receptionFieldEmail.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un correo válido.'**
  String get receptionFieldEmail;

  /// No description provided for @receptionFieldTaxIdPerson.
  ///
  /// In es, this message translates to:
  /// **'El documento debe tener entre 8 y 20 caracteres.'**
  String get receptionFieldTaxIdPerson;

  /// No description provided for @receptionFieldTaxIdCompany.
  ///
  /// In es, this message translates to:
  /// **'El RUC debe tener entre 11 y 20 caracteres.'**
  String get receptionFieldTaxIdCompany;

  /// No description provided for @receptionFieldPhone.
  ///
  /// In es, this message translates to:
  /// **'Máximo 20 caracteres.'**
  String get receptionFieldPhone;

  /// No description provided for @receptionFieldFirstName.
  ///
  /// In es, this message translates to:
  /// **'Ingresa los nombres (máximo 100 caracteres).'**
  String get receptionFieldFirstName;

  /// No description provided for @receptionFieldLastName.
  ///
  /// In es, this message translates to:
  /// **'Ingresa los apellidos (máximo 100 caracteres).'**
  String get receptionFieldLastName;

  /// No description provided for @receptionFieldCompanyName.
  ///
  /// In es, this message translates to:
  /// **'Ingresa la razón social (máximo 150 caracteres).'**
  String get receptionFieldCompanyName;

  /// No description provided for @receptionFieldPlate.
  ///
  /// In es, this message translates to:
  /// **'Ingresa la placa (máximo 15 caracteres).'**
  String get receptionFieldPlate;

  /// No description provided for @receptionFieldBrand.
  ///
  /// In es, this message translates to:
  /// **'Ingresa la marca (máximo 50 caracteres).'**
  String get receptionFieldBrand;

  /// No description provided for @receptionFieldModel.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el modelo (máximo 50 caracteres).'**
  String get receptionFieldModel;

  /// No description provided for @receptionFieldVin.
  ///
  /// In es, this message translates to:
  /// **'Máximo 17 caracteres.'**
  String get receptionFieldVin;

  /// No description provided for @receptionFieldYear.
  ///
  /// In es, this message translates to:
  /// **'El año debe ser 1950 o posterior.'**
  String get receptionFieldYear;

  /// No description provided for @receptionNoPermission.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil no tiene permiso para esta acción.'**
  String get receptionNoPermission;

  /// No description provided for @affiliationTitle.
  ///
  /// In es, this message translates to:
  /// **'Afiliar cliente'**
  String get affiliationTitle;

  /// No description provided for @affiliationSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Busca el correo del conductor para ver si ya usa Atelier.'**
  String get affiliationSubtitle;

  /// No description provided for @affiliationEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo del conductor'**
  String get affiliationEmail;

  /// No description provided for @affiliationSearch.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get affiliationSearch;

  /// No description provided for @affiliationAlreadyTitle.
  ///
  /// In es, this message translates to:
  /// **'Ya es cliente del taller.'**
  String get affiliationAlreadyTitle;

  /// No description provided for @affiliationAlreadyBody.
  ///
  /// In es, this message translates to:
  /// **'{p1} ya está afiliado. No hace falta registrarlo otra vez.'**
  String affiliationAlreadyBody(String p1);

  /// No description provided for @affiliationFoundTitle.
  ///
  /// In es, this message translates to:
  /// **'Cuenta de Atelier encontrada.'**
  String get affiliationFoundTitle;

  /// No description provided for @affiliationFoundBody.
  ///
  /// In es, this message translates to:
  /// **'{p1} tiene {p2} vehículo(s) registrado(s). Pide su documento para afiliarlo.'**
  String affiliationFoundBody(String p1, int p2);

  /// No description provided for @affiliationNotFoundTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin cuenta en Atelier.'**
  String get affiliationNotFoundTitle;

  /// No description provided for @affiliationNotFoundBody.
  ///
  /// In es, this message translates to:
  /// **'Registra al cliente y su vehículo en el taller.'**
  String get affiliationNotFoundBody;

  /// No description provided for @affiliationTaxId.
  ///
  /// In es, this message translates to:
  /// **'Documento (DNI)'**
  String get affiliationTaxId;

  /// No description provided for @affiliationPhone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono (opcional)'**
  String get affiliationPhone;

  /// No description provided for @affiliationSubmit.
  ///
  /// In es, this message translates to:
  /// **'Afiliar al taller'**
  String get affiliationSubmit;

  /// No description provided for @affiliationRegisterWalkIn.
  ///
  /// In es, this message translates to:
  /// **'Registrar cliente presencial'**
  String get affiliationRegisterWalkIn;

  /// No description provided for @affiliationDone.
  ///
  /// In es, this message translates to:
  /// **'Cliente afiliado: {p1}'**
  String affiliationDone(String p1);

  /// No description provided for @registerCustomerTitle.
  ///
  /// In es, this message translates to:
  /// **'Registrar cliente'**
  String get registerCustomerTitle;

  /// No description provided for @registerCustomerIndividual.
  ///
  /// In es, this message translates to:
  /// **'Persona'**
  String get registerCustomerIndividual;

  /// No description provided for @registerCustomerCompany.
  ///
  /// In es, this message translates to:
  /// **'Empresa'**
  String get registerCustomerCompany;

  /// No description provided for @registerCustomerSectionCustomer.
  ///
  /// In es, this message translates to:
  /// **'Cliente'**
  String get registerCustomerSectionCustomer;

  /// No description provided for @registerCustomerSectionVehicle.
  ///
  /// In es, this message translates to:
  /// **'Vehículo'**
  String get registerCustomerSectionVehicle;

  /// No description provided for @registerCustomerFirstName.
  ///
  /// In es, this message translates to:
  /// **'Nombres'**
  String get registerCustomerFirstName;

  /// No description provided for @registerCustomerLastName.
  ///
  /// In es, this message translates to:
  /// **'Apellidos'**
  String get registerCustomerLastName;

  /// No description provided for @registerCustomerCompanyName.
  ///
  /// In es, this message translates to:
  /// **'Razón social'**
  String get registerCustomerCompanyName;

  /// No description provided for @registerCustomerTaxIdPerson.
  ///
  /// In es, this message translates to:
  /// **'Documento (DNI)'**
  String get registerCustomerTaxIdPerson;

  /// No description provided for @registerCustomerTaxIdCompany.
  ///
  /// In es, this message translates to:
  /// **'RUC'**
  String get registerCustomerTaxIdCompany;

  /// No description provided for @registerCustomerEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico (opcional)'**
  String get registerCustomerEmail;

  /// No description provided for @registerCustomerPhone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get registerCustomerPhone;

  /// No description provided for @registerVehiclePlate.
  ///
  /// In es, this message translates to:
  /// **'Placa'**
  String get registerVehiclePlate;

  /// No description provided for @registerVehicleBrand.
  ///
  /// In es, this message translates to:
  /// **'Marca'**
  String get registerVehicleBrand;

  /// No description provided for @registerVehicleModel.
  ///
  /// In es, this message translates to:
  /// **'Modelo'**
  String get registerVehicleModel;

  /// No description provided for @registerVehicleEngine.
  ///
  /// In es, this message translates to:
  /// **'Motor'**
  String get registerVehicleEngine;

  /// No description provided for @registerVehicleVin.
  ///
  /// In es, this message translates to:
  /// **'VIN (opcional)'**
  String get registerVehicleVin;

  /// No description provided for @registerVehicleYear.
  ///
  /// In es, this message translates to:
  /// **'Año'**
  String get registerVehicleYear;

  /// No description provided for @engineGasoline.
  ///
  /// In es, this message translates to:
  /// **'Gasolina'**
  String get engineGasoline;

  /// No description provided for @engineDiesel.
  ///
  /// In es, this message translates to:
  /// **'Diésel'**
  String get engineDiesel;

  /// No description provided for @engineElectric.
  ///
  /// In es, this message translates to:
  /// **'Eléctrico'**
  String get engineElectric;

  /// No description provided for @engineHybrid.
  ///
  /// In es, this message translates to:
  /// **'Híbrido'**
  String get engineHybrid;

  /// No description provided for @registerCustomerSubmit.
  ///
  /// In es, this message translates to:
  /// **'Registrar cliente y vehículo'**
  String get registerCustomerSubmit;

  /// No description provided for @registerCustomerRetryVehicle.
  ///
  /// In es, this message translates to:
  /// **'Registrar vehículo'**
  String get registerCustomerRetryVehicle;

  /// No description provided for @registerCustomerSavedPendingVehicle.
  ///
  /// In es, this message translates to:
  /// **'El cliente ya se guardó. Falta registrar el vehículo.'**
  String get registerCustomerSavedPendingVehicle;

  /// No description provided for @searchTitle.
  ///
  /// In es, this message translates to:
  /// **'Recepción'**
  String get searchTitle;

  /// No description provided for @searchSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Busca la unidad por placa o al cliente por documento.'**
  String get searchSubtitle;

  /// No description provided for @searchModePlate.
  ///
  /// In es, this message translates to:
  /// **'Placa'**
  String get searchModePlate;

  /// No description provided for @searchModeDocument.
  ///
  /// In es, this message translates to:
  /// **'DNI / RUC'**
  String get searchModeDocument;

  /// No description provided for @searchFieldPlate.
  ///
  /// In es, this message translates to:
  /// **'Placa del vehículo'**
  String get searchFieldPlate;

  /// No description provided for @searchFieldDocument.
  ///
  /// In es, this message translates to:
  /// **'Documento del cliente'**
  String get searchFieldDocument;

  /// No description provided for @searchSubmit.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get searchSubmit;

  /// No description provided for @searchVehicleOwner.
  ///
  /// In es, this message translates to:
  /// **'Titular: {p1}'**
  String searchVehicleOwner(String p1);

  /// No description provided for @searchVehicleNoOwner.
  ///
  /// In es, this message translates to:
  /// **'Sin titular registrado'**
  String get searchVehicleNoOwner;

  /// No description provided for @searchNotFoundTitle.
  ///
  /// In es, this message translates to:
  /// **'Vehículo no registrado.'**
  String get searchNotFoundTitle;

  /// No description provided for @searchNotFoundBody.
  ///
  /// In es, this message translates to:
  /// **'Es un primer ingreso. Registra al cliente y su vehículo, o afilia su cuenta de Atelier.'**
  String get searchNotFoundBody;

  /// No description provided for @searchCustomersEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay clientes con ese documento.'**
  String get searchCustomersEmpty;

  /// No description provided for @searchCustomersTitle.
  ///
  /// In es, this message translates to:
  /// **'Clientes encontrados'**
  String get searchCustomersTitle;

  /// No description provided for @searchCustomerVehiclesTitle.
  ///
  /// In es, this message translates to:
  /// **'Vehículos de {p1}'**
  String searchCustomerVehiclesTitle(String p1);

  /// No description provided for @searchLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando…'**
  String get searchLoading;

  /// No description provided for @searchCustomerVehiclesEmpty.
  ///
  /// In es, this message translates to:
  /// **'Este cliente no tiene vehículos.'**
  String get searchCustomerVehiclesEmpty;

  /// No description provided for @searchRegister.
  ///
  /// In es, this message translates to:
  /// **'Registrar cliente y vehículo'**
  String get searchRegister;

  /// No description provided for @searchAffiliate.
  ///
  /// In es, this message translates to:
  /// **'Afiliar por correo'**
  String get searchAffiliate;

  /// No description provided for @searchAppointmentsTitle.
  ///
  /// In es, this message translates to:
  /// **'Citas de hoy'**
  String get searchAppointmentsTitle;

  /// No description provided for @searchAppointmentsEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay citas para hoy.'**
  String get searchAppointmentsEmpty;

  /// No description provided for @searchAppointmentsRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar citas'**
  String get searchAppointmentsRefresh;

  /// No description provided for @searchAppointmentLine.
  ///
  /// In es, this message translates to:
  /// **'{p1} · {p2}'**
  String searchAppointmentLine(String p1, String p2);

  /// No description provided for @searchAppointmentUnknownPlate.
  ///
  /// In es, this message translates to:
  /// **'Placa sin cargar'**
  String get searchAppointmentUnknownPlate;

  /// No description provided for @searchAppointmentArrived.
  ///
  /// In es, this message translates to:
  /// **'Marcar llegada'**
  String get searchAppointmentArrived;

  /// No description provided for @appointmentStatusPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get appointmentStatusPending;

  /// No description provided for @appointmentStatusConfirmed.
  ///
  /// In es, this message translates to:
  /// **'Confirmada'**
  String get appointmentStatusConfirmed;

  /// No description provided for @appointmentStatusArrived.
  ///
  /// In es, this message translates to:
  /// **'Llegó'**
  String get appointmentStatusArrived;

  /// No description provided for @appointmentStatusCanceled.
  ///
  /// In es, this message translates to:
  /// **'Cancelada'**
  String get appointmentStatusCanceled;

  /// No description provided for @searchStartService.
  ///
  /// In es, this message translates to:
  /// **'Iniciar atención'**
  String get searchStartService;

  /// No description provided for @searchCompleteOrder.
  ///
  /// In es, this message translates to:
  /// **'Completar orden'**
  String get searchCompleteOrder;

  /// No description provided for @searchArrivalReady.
  ///
  /// In es, this message translates to:
  /// **'Llegada registrada. La orden en borrador ya está lista.'**
  String get searchArrivalReady;

  /// No description provided for @searchArrivalPending.
  ///
  /// In es, this message translates to:
  /// **'Llegada registrada. La orden se está creando: actualiza en unos segundos.'**
  String get searchArrivalPending;

  /// No description provided for @workorderInvalidInput.
  ///
  /// In es, this message translates to:
  /// **'Revisa los datos marcados.'**
  String get workorderInvalidInput;

  /// No description provided for @openOrderTitle.
  ///
  /// In es, this message translates to:
  /// **'Abrir orden'**
  String get openOrderTitle;

  /// No description provided for @openOrderDraftNotice.
  ///
  /// In es, this message translates to:
  /// **'Este vehículo ya tiene una orden en borrador. Completa sus datos de ingreso.'**
  String get openOrderDraftNotice;

  /// No description provided for @openOrderSavedPendingTasks.
  ///
  /// In es, this message translates to:
  /// **'La orden ya se abrió. Faltan agregar algunas faenas.'**
  String get openOrderSavedPendingTasks;

  /// No description provided for @openOrderMileage.
  ///
  /// In es, this message translates to:
  /// **'Kilometraje (km)'**
  String get openOrderMileage;

  /// No description provided for @openOrderFieldMileage.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el kilometraje como un número.'**
  String get openOrderFieldMileage;

  /// No description provided for @openOrderFuel.
  ///
  /// In es, this message translates to:
  /// **'Nivel de combustible'**
  String get openOrderFuel;

  /// No description provided for @fuelReserve.
  ///
  /// In es, this message translates to:
  /// **'Reserva'**
  String get fuelReserve;

  /// No description provided for @fuelQuarter.
  ///
  /// In es, this message translates to:
  /// **'1/4'**
  String get fuelQuarter;

  /// No description provided for @fuelHalf.
  ///
  /// In es, this message translates to:
  /// **'1/2'**
  String get fuelHalf;

  /// No description provided for @fuelThreeQuarters.
  ///
  /// In es, this message translates to:
  /// **'3/4'**
  String get fuelThreeQuarters;

  /// No description provided for @fuelFull.
  ///
  /// In es, this message translates to:
  /// **'Lleno'**
  String get fuelFull;

  /// No description provided for @openOrderReason.
  ///
  /// In es, this message translates to:
  /// **'Motivo de ingreso'**
  String get openOrderReason;

  /// No description provided for @openOrderFieldReason.
  ///
  /// In es, this message translates to:
  /// **'El motivo es demasiado largo (máximo 2000 caracteres).'**
  String get openOrderFieldReason;

  /// No description provided for @openOrderTasks.
  ///
  /// In es, this message translates to:
  /// **'Faenas iniciales'**
  String get openOrderTasks;

  /// No description provided for @openOrderTasksEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay servicios para elegir. Puedes abrir la orden sin faenas.'**
  String get openOrderTasksEmpty;

  /// No description provided for @openOrderTaskAdded.
  ///
  /// In es, this message translates to:
  /// **'{p1} (agregada)'**
  String openOrderTaskAdded(String p1);

  /// No description provided for @openOrderMechanic.
  ///
  /// In es, this message translates to:
  /// **'Asignar a (opcional)'**
  String get openOrderMechanic;

  /// No description provided for @openOrderMechanicNone.
  ///
  /// In es, this message translates to:
  /// **'Sin asignar'**
  String get openOrderMechanicNone;

  /// No description provided for @openOrderMechanicFallback.
  ///
  /// In es, this message translates to:
  /// **'Colaborador {p1}'**
  String openOrderMechanicFallback(String p1);

  /// No description provided for @openOrderSubmit.
  ///
  /// In es, this message translates to:
  /// **'Abrir orden'**
  String get openOrderSubmit;

  /// No description provided for @openOrderRetryTasks.
  ///
  /// In es, this message translates to:
  /// **'Agregar faenas pendientes'**
  String get openOrderRetryTasks;

  /// No description provided for @galleryTitle.
  ///
  /// In es, this message translates to:
  /// **'Fotos de recepción'**
  String get galleryTitle;

  /// No description provided for @gallerySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Toca un panel para fotografiarlo. Las fotos se guardan aunque no haya señal.'**
  String get gallerySubtitle;

  /// No description provided for @galleryNote.
  ///
  /// In es, this message translates to:
  /// **'Nota del daño (opcional)'**
  String get galleryNote;

  /// No description provided for @galleryCameraDenied.
  ///
  /// In es, this message translates to:
  /// **'Sin permiso de cámara no se pueden tomar fotos.'**
  String get galleryCameraDenied;

  /// No description provided for @galleryTakePhoto.
  ///
  /// In es, this message translates to:
  /// **'Tomar foto: {p1}'**
  String galleryTakePhoto(String p1);

  /// No description provided for @galleryAngleFront.
  ///
  /// In es, this message translates to:
  /// **'Frente'**
  String get galleryAngleFront;

  /// No description provided for @galleryAngleRear.
  ///
  /// In es, this message translates to:
  /// **'Trasera'**
  String get galleryAngleRear;

  /// No description provided for @galleryAngleLeft.
  ///
  /// In es, this message translates to:
  /// **'Lateral izquierdo'**
  String get galleryAngleLeft;

  /// No description provided for @galleryAngleRight.
  ///
  /// In es, this message translates to:
  /// **'Lateral derecho'**
  String get galleryAngleRight;

  /// No description provided for @galleryAngleRoof.
  ///
  /// In es, this message translates to:
  /// **'Techo'**
  String get galleryAngleRoof;

  /// No description provided for @galleryAngleDashboard.
  ///
  /// In es, this message translates to:
  /// **'Tablero'**
  String get galleryAngleDashboard;

  /// No description provided for @galleryAngleOther.
  ///
  /// In es, this message translates to:
  /// **'Otra foto'**
  String get galleryAngleOther;

  /// No description provided for @galleryOther.
  ///
  /// In es, this message translates to:
  /// **'Otras fotos'**
  String get galleryOther;

  /// No description provided for @galleryAddOther.
  ///
  /// In es, this message translates to:
  /// **'Agregar otra foto'**
  String get galleryAddOther;

  /// No description provided for @galleryStatusUploaded.
  ///
  /// In es, this message translates to:
  /// **'Subida'**
  String get galleryStatusUploaded;

  /// No description provided for @galleryStatusQueued.
  ///
  /// In es, this message translates to:
  /// **'En cola'**
  String get galleryStatusQueued;

  /// No description provided for @galleryStatusFailed.
  ///
  /// In es, this message translates to:
  /// **'Falló'**
  String get galleryStatusFailed;

  /// No description provided for @galleryDone.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get galleryDone;

  /// No description provided for @severityLow.
  ///
  /// In es, this message translates to:
  /// **'Baja'**
  String get severityLow;

  /// No description provided for @severityMedium.
  ///
  /// In es, this message translates to:
  /// **'Media'**
  String get severityMedium;

  /// No description provided for @severityHigh.
  ///
  /// In es, this message translates to:
  /// **'Alta'**
  String get severityHigh;

  /// No description provided for @severityCritical.
  ///
  /// In es, this message translates to:
  /// **'Crítica'**
  String get severityCritical;

  /// No description provided for @proposalStatusPending.
  ///
  /// In es, this message translates to:
  /// **'En revisión'**
  String get proposalStatusPending;

  /// No description provided for @proposalStatusApproved.
  ///
  /// In es, this message translates to:
  /// **'Aprobada'**
  String get proposalStatusApproved;

  /// No description provided for @proposalStatusRejected.
  ///
  /// In es, this message translates to:
  /// **'Rechazada'**
  String get proposalStatusRejected;

  /// No description provided for @findingTitle.
  ///
  /// In es, this message translates to:
  /// **'Reportar hallazgo'**
  String get findingTitle;

  /// No description provided for @findingSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Describe el imprevisto que encontraste y adjunta una foto como prueba.'**
  String get findingSubtitle;

  /// No description provided for @findingSaved.
  ///
  /// In es, this message translates to:
  /// **'Hallazgo guardado. Se enviará a supervisión en cuanto haya señal.'**
  String get findingSaved;

  /// No description provided for @findingSeverity.
  ///
  /// In es, this message translates to:
  /// **'Severidad'**
  String get findingSeverity;

  /// No description provided for @findingDescription.
  ///
  /// In es, this message translates to:
  /// **'Descripción técnica'**
  String get findingDescription;

  /// No description provided for @findingFieldDescription.
  ///
  /// In es, this message translates to:
  /// **'Ingresa la descripción (máximo 2000 caracteres).'**
  String get findingFieldDescription;

  /// No description provided for @findingPhoto.
  ///
  /// In es, this message translates to:
  /// **'Foto del hallazgo'**
  String get findingPhoto;

  /// No description provided for @findingTakePhoto.
  ///
  /// In es, this message translates to:
  /// **'Tomar foto'**
  String get findingTakePhoto;

  /// No description provided for @findingChangePhoto.
  ///
  /// In es, this message translates to:
  /// **'Cambiar foto'**
  String get findingChangePhoto;

  /// No description provided for @findingPhotoRequired.
  ///
  /// In es, this message translates to:
  /// **'La foto es obligatoria para enviar el hallazgo.'**
  String get findingPhotoRequired;

  /// No description provided for @findingService.
  ///
  /// In es, this message translates to:
  /// **'Servicio sugerido (opcional)'**
  String get findingService;

  /// No description provided for @findingServiceNone.
  ///
  /// In es, this message translates to:
  /// **'Sin sugerencia'**
  String get findingServiceNone;

  /// No description provided for @findingPendingTitle.
  ///
  /// In es, this message translates to:
  /// **'Pendientes de envío'**
  String get findingPendingTitle;

  /// No description provided for @findingSubmit.
  ///
  /// In es, this message translates to:
  /// **'Enviar hallazgo'**
  String get findingSubmit;

  /// No description provided for @proposalsTitle.
  ///
  /// In es, this message translates to:
  /// **'Propuestas'**
  String get proposalsTitle;

  /// No description provided for @proposalsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Notifica al cliente cada hallazgo y registra si lo aprobó o no.'**
  String get proposalsSubtitle;

  /// No description provided for @proposalsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Esta orden no tiene propuestas.'**
  String get proposalsEmpty;

  /// No description provided for @proposalsReport.
  ///
  /// In es, this message translates to:
  /// **'Reportar hallazgo'**
  String get proposalsReport;

  /// No description provided for @proposalsNotify.
  ///
  /// In es, this message translates to:
  /// **'Enviar al cliente por correo'**
  String get proposalsNotify;

  /// No description provided for @proposalsApprove.
  ///
  /// In es, this message translates to:
  /// **'Aprobar y crear tarea'**
  String get proposalsApprove;

  /// No description provided for @proposalsReject.
  ///
  /// In es, this message translates to:
  /// **'Registrar rechazo'**
  String get proposalsReject;

  /// No description provided for @proposalsNotified.
  ///
  /// In es, this message translates to:
  /// **'Correo enviado a {p1}.'**
  String proposalsNotified(String p1);

  /// No description provided for @proposalsApproved.
  ///
  /// In es, this message translates to:
  /// **'Propuesta aprobada. Se creó la tarea en la orden.'**
  String get proposalsApproved;

  /// No description provided for @proposalsRejected.
  ///
  /// In es, this message translates to:
  /// **'Propuesta rechazada.'**
  String get proposalsRejected;

  /// No description provided for @proposalsCustomerNotes.
  ///
  /// In es, this message translates to:
  /// **'Observaciones del cliente: {p1}'**
  String proposalsCustomerNotes(String p1);

  /// No description provided for @proposalsRecommendedService.
  ///
  /// In es, this message translates to:
  /// **'Servicio recomendado: {p1}'**
  String proposalsRecommendedService(String p1);

  /// No description provided for @proposalsService.
  ///
  /// In es, this message translates to:
  /// **'Servicio de la tarea'**
  String get proposalsService;

  /// No description provided for @proposalsFinalPrice.
  ///
  /// In es, this message translates to:
  /// **'Tarifa del servicio (sin IGV)'**
  String get proposalsFinalPrice;

  /// No description provided for @proposalsPriceFromCatalog.
  ///
  /// In es, this message translates to:
  /// **'Tarifa consolidada del catálogo de servicios (sin IGV).'**
  String get proposalsPriceFromCatalog;

  /// No description provided for @proposalsLaborHours.
  ///
  /// In es, this message translates to:
  /// **'Horas estimadas'**
  String get proposalsLaborHours;

  /// No description provided for @proposalsMechanic.
  ///
  /// In es, this message translates to:
  /// **'Mecánico responsable (opcional)'**
  String get proposalsMechanic;

  /// No description provided for @proposalsMechanicUnassigned.
  ///
  /// In es, this message translates to:
  /// **'Sin asignar'**
  String get proposalsMechanicUnassigned;

  /// No description provided for @proposalsNotesOptional.
  ///
  /// In es, this message translates to:
  /// **'Observaciones (opcional)'**
  String get proposalsNotesOptional;

  /// No description provided for @proposalsCustomerNotesLabel.
  ///
  /// In es, this message translates to:
  /// **'Observaciones del cliente'**
  String get proposalsCustomerNotesLabel;

  /// No description provided for @proposalsFieldService.
  ///
  /// In es, this message translates to:
  /// **'Elige un servicio para la tarea.'**
  String get proposalsFieldService;

  /// No description provided for @proposalsFieldAmount.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un número de 0 en adelante.'**
  String get proposalsFieldAmount;

  /// No description provided for @proposalsFieldNotes.
  ///
  /// In es, this message translates to:
  /// **'Escribe las observaciones (máximo 1000 caracteres).'**
  String get proposalsFieldNotes;

  /// No description provided for @proposalsConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get proposalsConfirm;

  /// No description provided for @proposalsCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get proposalsCancel;

  /// No description provided for @galleryProposals.
  ///
  /// In es, this message translates to:
  /// **'Propuestas de la orden'**
  String get galleryProposals;

  /// No description provided for @attendanceLocating.
  ///
  /// In es, this message translates to:
  /// **'Obteniendo ubicación…'**
  String get attendanceLocating;

  /// No description provided for @attendanceRefreshingShort.
  ///
  /// In es, this message translates to:
  /// **'Actualizando'**
  String get attendanceRefreshingShort;

  /// No description provided for @attendancePendingBadge.
  ///
  /// In es, this message translates to:
  /// **'Pendiente de sincronizar'**
  String get attendancePendingBadge;

  /// No description provided for @attendanceCompletedBadge.
  ///
  /// In es, this message translates to:
  /// **'Jornada finalizada'**
  String get attendanceCompletedBadge;

  /// No description provided for @attendanceActiveBadge.
  ///
  /// In es, this message translates to:
  /// **'Jornada activa'**
  String get attendanceActiveBadge;

  /// No description provided for @attendanceReadyBadge.
  ///
  /// In es, this message translates to:
  /// **'Listo para marcar'**
  String get attendanceReadyBadge;

  /// No description provided for @attendanceGeofenceTitle.
  ///
  /// In es, this message translates to:
  /// **'Geocerca del taller'**
  String get attendanceGeofenceTitle;

  /// No description provided for @attendanceGeofenceRadius.
  ///
  /// In es, this message translates to:
  /// **'Radio permitido: {p1} m'**
  String attendanceGeofenceRadius(int p1);

  /// No description provided for @attendanceGeofenceNoBranch.
  ///
  /// In es, this message translates to:
  /// **'La sede no está disponible en caché.'**
  String get attendanceGeofenceNoBranch;

  /// No description provided for @attendanceRetryLocation.
  ///
  /// In es, this message translates to:
  /// **'Actualizar GPS'**
  String get attendanceRetryLocation;

  /// No description provided for @attendanceDistanceValue.
  ///
  /// In es, this message translates to:
  /// **'{p1} m'**
  String attendanceDistanceValue(int p1);

  /// No description provided for @attendanceDistanceFromBranch.
  ///
  /// In es, this message translates to:
  /// **'del centro del taller'**
  String get attendanceDistanceFromBranch;

  /// No description provided for @attendanceGpsUnavailableShort.
  ///
  /// In es, this message translates to:
  /// **'Sin GPS'**
  String get attendanceGpsUnavailableShort;

  /// No description provided for @attendanceMockShort.
  ///
  /// In es, this message translates to:
  /// **'GPS simulado'**
  String get attendanceMockShort;

  /// No description provided for @attendanceGpsReady.
  ///
  /// In es, this message translates to:
  /// **'GPS disponible'**
  String get attendanceGpsReady;

  /// No description provided for @attendanceInsideGeofence.
  ///
  /// In es, this message translates to:
  /// **'Dentro del perímetro'**
  String get attendanceInsideGeofence;

  /// No description provided for @attendanceOutsideGeofence.
  ///
  /// In es, this message translates to:
  /// **'Fuera del perímetro'**
  String get attendanceOutsideGeofence;

  /// No description provided for @attendanceGraceLabel.
  ///
  /// In es, this message translates to:
  /// **'Tolerancia de ingreso'**
  String get attendanceGraceLabel;

  /// No description provided for @attendanceBranchLabel.
  ///
  /// In es, this message translates to:
  /// **'Sede asignada'**
  String get attendanceBranchLabel;

  /// No description provided for @attendanceNoShiftShort.
  ///
  /// In es, this message translates to:
  /// **'Sin turno asignado'**
  String get attendanceNoShiftShort;

  /// No description provided for @attendanceWeeklySchedule.
  ///
  /// In es, this message translates to:
  /// **'Semana laboral'**
  String get attendanceWeeklySchedule;

  /// No description provided for @attendanceMapRadius.
  ///
  /// In es, this message translates to:
  /// **'Vista esquemática · radio {p1} m'**
  String attendanceMapRadius(int p1);

  /// No description provided for @attendanceMapNoData.
  ///
  /// In es, this message translates to:
  /// **'Vista esquemática · la sede aparecerá al cargar los datos'**
  String get attendanceMapNoData;

  /// No description provided for @tasksTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis tareas'**
  String get tasksTitle;

  /// No description provided for @tasksSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Faenas asignadas en bahía, por prioridad.'**
  String get tasksSubtitle;

  /// No description provided for @tasksEmpty.
  ///
  /// In es, this message translates to:
  /// **'No tienes tareas asignadas.'**
  String get tasksEmpty;

  /// No description provided for @tasksNoPermission.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil no tiene permiso para ver tareas.'**
  String get tasksNoPermission;

  /// No description provided for @tasksCacheNotice.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión: mostrando las tareas guardadas.'**
  String get tasksCacheNotice;

  /// No description provided for @tasksRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get tasksRefresh;

  /// No description provided for @taskStatusAssigned.
  ///
  /// In es, this message translates to:
  /// **'Asignada'**
  String get taskStatusAssigned;

  /// No description provided for @taskStatusInProgress.
  ///
  /// In es, this message translates to:
  /// **'En curso'**
  String get taskStatusInProgress;

  /// No description provided for @taskStatusOnHold.
  ///
  /// In es, this message translates to:
  /// **'En pausa'**
  String get taskStatusOnHold;

  /// No description provided for @taskStatusSuspended.
  ///
  /// In es, this message translates to:
  /// **'Suspendida'**
  String get taskStatusSuspended;

  /// No description provided for @taskStatusCompleted.
  ///
  /// In es, this message translates to:
  /// **'Completada'**
  String get taskStatusCompleted;

  /// No description provided for @taskStatusCancelled.
  ///
  /// In es, this message translates to:
  /// **'Cancelada'**
  String get taskStatusCancelled;

  /// No description provided for @taskStatusPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get taskStatusPending;

  /// No description provided for @taskSuspensionPending.
  ///
  /// In es, this message translates to:
  /// **'Suspensión por aprobar'**
  String get taskSuspensionPending;

  /// No description provided for @taskCardPlate.
  ///
  /// In es, this message translates to:
  /// **'Placa {p1}'**
  String taskCardPlate(String p1);

  /// No description provided for @taskCardBay.
  ///
  /// In es, this message translates to:
  /// **'Bahía {p1}'**
  String taskCardBay(String p1);

  /// No description provided for @taskCardWorkOrder.
  ///
  /// In es, this message translates to:
  /// **'OT #{p1}'**
  String taskCardWorkOrder(int p1);

  /// No description provided for @taskCardEstimated.
  ///
  /// In es, this message translates to:
  /// **'{p1} h estimadas'**
  String taskCardEstimated(String p1);

  /// No description provided for @taskCardNoPlate.
  ///
  /// In es, this message translates to:
  /// **'Vehículo sin placa en caché'**
  String get taskCardNoPlate;

  /// No description provided for @taskDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle de tarea'**
  String get taskDetailTitle;

  /// No description provided for @taskInvalidInput.
  ///
  /// In es, this message translates to:
  /// **'Revisa los datos marcados.'**
  String get taskInvalidInput;

  /// No description provided for @taskTimerLabel.
  ///
  /// In es, this message translates to:
  /// **'Labor efectiva'**
  String get taskTimerLabel;

  /// No description provided for @taskTimerPausedTotal.
  ///
  /// In es, this message translates to:
  /// **'En pausa acumulada: {p1}'**
  String taskTimerPausedTotal(String p1);

  /// No description provided for @taskStart.
  ///
  /// In es, this message translates to:
  /// **'Iniciar faena'**
  String get taskStart;

  /// No description provided for @taskResume.
  ///
  /// In es, this message translates to:
  /// **'Reanudar'**
  String get taskResume;

  /// No description provided for @taskPause.
  ///
  /// In es, this message translates to:
  /// **'Pausar'**
  String get taskPause;

  /// No description provided for @taskComplete.
  ///
  /// In es, this message translates to:
  /// **'Terminar tarea'**
  String get taskComplete;

  /// No description provided for @taskStarted.
  ///
  /// In es, this message translates to:
  /// **'Faena en curso.'**
  String get taskStarted;

  /// No description provided for @taskPaused.
  ///
  /// In es, this message translates to:
  /// **'Tarea en pausa.'**
  String get taskPaused;

  /// No description provided for @taskSuspendedNotice.
  ///
  /// In es, this message translates to:
  /// **'Tarea suspendida: solo un supervisor puede levantarla.'**
  String get taskSuspendedNotice;

  /// No description provided for @taskPauseTitle.
  ///
  /// In es, this message translates to:
  /// **'Pausar tarea'**
  String get taskPauseTitle;

  /// No description provided for @taskPauseBody.
  ///
  /// In es, this message translates to:
  /// **'Elige el motivo de la pausa.'**
  String get taskPauseBody;

  /// No description provided for @taskPauseBreak.
  ///
  /// In es, this message translates to:
  /// **'Refrigerio'**
  String get taskPauseBreak;

  /// No description provided for @taskPauseEndOfShift.
  ///
  /// In es, this message translates to:
  /// **'Fin de turno'**
  String get taskPauseEndOfShift;

  /// No description provided for @taskCompleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Terminar tarea'**
  String get taskCompleteTitle;

  /// No description provided for @taskCompleteBody.
  ///
  /// In es, this message translates to:
  /// **'Confirma las horas efectivas trabajadas. Puedes corregir la sugerencia del cronómetro.'**
  String get taskCompleteBody;

  /// No description provided for @taskCompleteHours.
  ///
  /// In es, this message translates to:
  /// **'Horas efectivas'**
  String get taskCompleteHours;

  /// No description provided for @taskCompleteNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas (opcional)'**
  String get taskCompleteNotes;

  /// No description provided for @taskCompleteConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar cierre'**
  String get taskCompleteConfirm;

  /// No description provided for @taskCompletedNotice.
  ///
  /// In es, this message translates to:
  /// **'Tarea cerrada. Sale de tus tareas pendientes.'**
  String get taskCompletedNotice;

  /// No description provided for @taskFieldHours.
  ///
  /// In es, this message translates to:
  /// **'Escribe un número de horas mayor o igual a 0.'**
  String get taskFieldHours;

  /// No description provided for @taskFieldNotes.
  ///
  /// In es, this message translates to:
  /// **'Máximo 1000 caracteres.'**
  String get taskFieldNotes;

  /// No description provided for @catalogTitle.
  ///
  /// In es, this message translates to:
  /// **'Repuestos'**
  String get catalogTitle;

  /// No description provided for @catalogSearchLabel.
  ///
  /// In es, this message translates to:
  /// **'Buscar repuesto'**
  String get catalogSearchLabel;

  /// No description provided for @catalogSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Nombre o SKU'**
  String get catalogSearchHint;

  /// No description provided for @catalogNoPermission.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil no tiene permiso para ver el catálogo.'**
  String get catalogNoPermission;

  /// No description provided for @catalogCacheNotice.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión: mostrando el catálogo guardado.'**
  String get catalogCacheNotice;

  /// No description provided for @catalogEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay repuestos en el catálogo.'**
  String get catalogEmpty;

  /// No description provided for @catalogEmptyFiltered.
  ///
  /// In es, this message translates to:
  /// **'Ningún repuesto coincide con la búsqueda.'**
  String get catalogEmptyFiltered;

  /// No description provided for @catalogClearFilters.
  ///
  /// In es, this message translates to:
  /// **'Quitar filtros'**
  String get catalogClearFilters;

  /// No description provided for @categoryLubricants.
  ///
  /// In es, this message translates to:
  /// **'Lubricantes'**
  String get categoryLubricants;

  /// No description provided for @categoryBrakes.
  ///
  /// In es, this message translates to:
  /// **'Frenos'**
  String get categoryBrakes;

  /// No description provided for @categorySuspension.
  ///
  /// In es, this message translates to:
  /// **'Suspensión'**
  String get categorySuspension;

  /// No description provided for @categoryEngine.
  ///
  /// In es, this message translates to:
  /// **'Motor'**
  String get categoryEngine;

  /// No description provided for @categoryElectrical.
  ///
  /// In es, this message translates to:
  /// **'Eléctrico'**
  String get categoryElectrical;

  /// No description provided for @categoryTires.
  ///
  /// In es, this message translates to:
  /// **'Llantas'**
  String get categoryTires;

  /// No description provided for @categoryFilters.
  ///
  /// In es, this message translates to:
  /// **'Filtros'**
  String get categoryFilters;

  /// No description provided for @categoryBodywork.
  ///
  /// In es, this message translates to:
  /// **'Carrocería'**
  String get categoryBodywork;

  /// No description provided for @categoryAccessories.
  ///
  /// In es, this message translates to:
  /// **'Accesorios'**
  String get categoryAccessories;

  /// No description provided for @stockOut.
  ///
  /// In es, this message translates to:
  /// **'Agotado'**
  String get stockOut;

  /// No description provided for @stockLow.
  ///
  /// In es, this message translates to:
  /// **'Stock mínimo'**
  String get stockLow;

  /// No description provided for @stockOk.
  ///
  /// In es, this message translates to:
  /// **'Disponible'**
  String get stockOk;

  /// No description provided for @partSku.
  ///
  /// In es, this message translates to:
  /// **'SKU {p1}'**
  String partSku(String p1);

  /// No description provided for @partBrand.
  ///
  /// In es, this message translates to:
  /// **'Marca {p1}'**
  String partBrand(String p1);

  /// No description provided for @partStock.
  ///
  /// In es, this message translates to:
  /// **'Stock: {p1}'**
  String partStock(String p1);

  /// No description provided for @partPrice.
  ///
  /// In es, this message translates to:
  /// **'{p1} sin IGV'**
  String partPrice(String p1);

  /// No description provided for @partDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle de repuesto'**
  String get partDetailTitle;

  /// No description provided for @batchesTitle.
  ///
  /// In es, this message translates to:
  /// **'Lotes en orden FIFO'**
  String get batchesTitle;

  /// No description provided for @batchesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'El descargo consume primero el lote más antiguo con saldo.'**
  String get batchesSubtitle;

  /// No description provided for @batchesEmpty.
  ///
  /// In es, this message translates to:
  /// **'Este repuesto no tiene lotes registrados.'**
  String get batchesEmpty;

  /// No description provided for @batchesNoPermission.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil no tiene permiso para ver los lotes.'**
  String get batchesNoPermission;

  /// No description provided for @batchesCacheNotice.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión: mostrando los lotes guardados.'**
  String get batchesCacheNotice;

  /// No description provided for @batchNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente en salir'**
  String get batchNext;

  /// No description provided for @batchWaiting.
  ///
  /// In es, this message translates to:
  /// **'Con saldo'**
  String get batchWaiting;

  /// No description provided for @batchDepleted.
  ///
  /// In es, this message translates to:
  /// **'Agotado'**
  String get batchDepleted;

  /// No description provided for @batchNumber.
  ///
  /// In es, this message translates to:
  /// **'Lote {p1}'**
  String batchNumber(String p1);

  /// No description provided for @batchArrival.
  ///
  /// In es, this message translates to:
  /// **'Ingresó el {p1}'**
  String batchArrival(String p1);

  /// No description provided for @batchRemaining.
  ///
  /// In es, this message translates to:
  /// **'Saldo: {p1}'**
  String batchRemaining(String p1);

  /// No description provided for @batchUnitCost.
  ///
  /// In es, this message translates to:
  /// **'Costo unitario: {p1}'**
  String batchUnitCost(String p1);

  /// No description provided for @taskPartsTitle.
  ///
  /// In es, this message translates to:
  /// **'Repuestos de la tarea'**
  String get taskPartsTitle;

  /// No description provided for @taskPartsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay repuestos imputados.'**
  String get taskPartsEmpty;

  /// No description provided for @taskPartsOnlineOnly.
  ///
  /// In es, this message translates to:
  /// **'Los repuestos imputados se consultan con conexión.'**
  String get taskPartsOnlineOnly;

  /// No description provided for @taskTimerUnknownHint.
  ///
  /// In es, this message translates to:
  /// **'El tiempo al pausar no está disponible en este teléfono.'**
  String get taskTimerUnknownHint;

  /// No description provided for @taskPartsCharge.
  ///
  /// In es, this message translates to:
  /// **'Imputar repuesto'**
  String get taskPartsCharge;

  /// No description provided for @taskPartUnnamed.
  ///
  /// In es, this message translates to:
  /// **'Repuesto sin nombre'**
  String get taskPartUnnamed;

  /// No description provided for @taskPartQuantity.
  ///
  /// In es, this message translates to:
  /// **'Cantidad: {p1}'**
  String taskPartQuantity(String p1);

  /// No description provided for @taskPartUnitPrice.
  ///
  /// In es, this message translates to:
  /// **'Unitario: {p1}'**
  String taskPartUnitPrice(String p1);

  /// No description provided for @taskPartTotal.
  ///
  /// In es, this message translates to:
  /// **'Total: {p1}'**
  String taskPartTotal(String p1);

  /// No description provided for @taskPartEdit.
  ///
  /// In es, this message translates to:
  /// **'Corregir cantidad'**
  String get taskPartEdit;

  /// No description provided for @taskPartReturn.
  ///
  /// In es, this message translates to:
  /// **'Devolver a inventario'**
  String get taskPartReturn;

  /// No description provided for @taskPartCharged.
  ///
  /// In es, this message translates to:
  /// **'Repuesto imputado: el stock bajó por lotes FIFO.'**
  String get taskPartCharged;

  /// No description provided for @taskPartUpdated.
  ///
  /// In es, this message translates to:
  /// **'Cantidad actualizada.'**
  String get taskPartUpdated;

  /// No description provided for @taskPartReturned.
  ///
  /// In es, this message translates to:
  /// **'Repuesto devuelto al lote de origen.'**
  String get taskPartReturned;

  /// No description provided for @taskFieldQuantity.
  ///
  /// In es, this message translates to:
  /// **'Escribe una cantidad mayor a 0.'**
  String get taskFieldQuantity;

  /// No description provided for @chargeTitle.
  ///
  /// In es, this message translates to:
  /// **'Imputar repuesto'**
  String get chargeTitle;

  /// No description provided for @chargeSelectPartPrompt.
  ///
  /// In es, this message translates to:
  /// **'Repuestos disponibles en almacén:'**
  String get chargeSelectPartPrompt;

  /// No description provided for @chargeChangePartBtn.
  ///
  /// In es, this message translates to:
  /// **'Cambiar repuesto seleccionado'**
  String get chargeChangePartBtn;

  /// No description provided for @chargeQuantity.
  ///
  /// In es, this message translates to:
  /// **'Cantidad'**
  String get chargeQuantity;

  /// No description provided for @chargeConfirm.
  ///
  /// In es, this message translates to:
  /// **'Imputar a la tarea'**
  String get chargeConfirm;

  /// No description provided for @editPartTitle.
  ///
  /// In es, this message translates to:
  /// **'Corregir cantidad'**
  String get editPartTitle;

  /// No description provided for @editPartBody.
  ///
  /// In es, this message translates to:
  /// **'El backend recalcula el costo de la orden con la nueva cantidad.'**
  String get editPartBody;

  /// No description provided for @editPartConfirm.
  ///
  /// In es, this message translates to:
  /// **'Guardar cantidad'**
  String get editPartConfirm;

  /// No description provided for @returnTitle.
  ///
  /// In es, this message translates to:
  /// **'Devolver a inventario'**
  String get returnTitle;

  /// No description provided for @returnBody.
  ///
  /// In es, this message translates to:
  /// **'Las unidades vuelven al lote del que salieron y se rebaja el costo imputado en la orden.'**
  String get returnBody;

  /// No description provided for @returnConfirm.
  ///
  /// In es, this message translates to:
  /// **'Devolver repuesto'**
  String get returnConfirm;

  /// No description provided for @mainTabHome.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get mainTabHome;

  /// No description provided for @mainTabTasks.
  ///
  /// In es, this message translates to:
  /// **'Tareas'**
  String get mainTabTasks;

  /// No description provided for @mainTabOrders.
  ///
  /// In es, this message translates to:
  /// **'Órdenes'**
  String get mainTabOrders;

  /// No description provided for @mainTabReception.
  ///
  /// In es, this message translates to:
  /// **'Recepción'**
  String get mainTabReception;

  /// No description provided for @mainTabObd.
  ///
  /// In es, this message translates to:
  /// **'OBD-II'**
  String get mainTabObd;

  /// No description provided for @mainTabStock.
  ///
  /// In es, this message translates to:
  /// **'Stock'**
  String get mainTabStock;

  /// No description provided for @mainTabProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get mainTabProfile;

  /// No description provided for @mainTabSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get mainTabSettings;

  /// No description provided for @mainTabMore.
  ///
  /// In es, this message translates to:
  /// **'Más'**
  String get mainTabMore;

  /// No description provided for @mainTabToday.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get mainTabToday;

  /// No description provided for @mainTabTeam.
  ///
  /// In es, this message translates to:
  /// **'Equipo'**
  String get mainTabTeam;

  /// No description provided for @mainObdTitle.
  ///
  /// In es, this message translates to:
  /// **'Escáneres OBD-II'**
  String get mainObdTitle;

  /// No description provided for @mainObdSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Enciende tu escáner OBD-II y acércalo al teléfono.'**
  String get mainObdSubtitle;

  /// No description provided for @profileSignOut.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get profileSignOut;

  /// No description provided for @profileSignOutTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cerrar sesión?'**
  String get profileSignOutTitle;

  /// No description provided for @profileSignOutMessage.
  ///
  /// In es, this message translates to:
  /// **'Los registros pendientes de sincronizar se conservan cifrados en el teléfono.'**
  String get profileSignOutMessage;

  /// No description provided for @profileVersion.
  ///
  /// In es, this message translates to:
  /// **'Atelier Workshop Mobile · versión {p1}'**
  String profileVersion(String p1);

  /// No description provided for @profileSectionAccount.
  ///
  /// In es, this message translates to:
  /// **'Mi cuenta y taller'**
  String get profileSectionAccount;

  /// No description provided for @profileSectionOps.
  ///
  /// In es, this message translates to:
  /// **'Operaciones y sincronización'**
  String get profileSectionOps;

  /// No description provided for @profileSectionSession.
  ///
  /// In es, this message translates to:
  /// **'Seguridad y sesión'**
  String get profileSectionSession;

  /// No description provided for @profileSupportBtn.
  ///
  /// In es, this message translates to:
  /// **'Habla con soporte técnico Atelier'**
  String get profileSupportBtn;

  /// No description provided for @profileSupportToast.
  ///
  /// In es, this message translates to:
  /// **'Canal directo de soporte Atelier disponible vía WhatsApp o correo oficial.'**
  String get profileSupportToast;

  /// No description provided for @profileItemPersonalData.
  ///
  /// In es, this message translates to:
  /// **'Datos personales y rol'**
  String get profileItemPersonalData;

  /// No description provided for @profileItemBranchShift.
  ///
  /// In es, this message translates to:
  /// **'Sede activa y turno'**
  String get profileItemBranchShift;

  /// No description provided for @profileItemPlan.
  ///
  /// In es, this message translates to:
  /// **'Plan y módulos contratados'**
  String get profileItemPlan;

  /// No description provided for @profilePlanFormat.
  ///
  /// In es, this message translates to:
  /// **'Plan {p1}'**
  String profilePlanFormat(String p1);

  /// No description provided for @profileItemSync.
  ///
  /// In es, this message translates to:
  /// **'Cola de sincronización offline'**
  String get profileItemSync;

  /// No description provided for @profileItemNotifications.
  ///
  /// In es, this message translates to:
  /// **'Bandeja de notificaciones'**
  String get profileItemNotifications;

  /// No description provided for @profileItemPermissions.
  ///
  /// In es, this message translates to:
  /// **'Permisos de acceso de tu rol'**
  String get profileItemPermissions;

  /// No description provided for @profileSyncUpToDate.
  ///
  /// In es, this message translates to:
  /// **'Todo sincronizado con el servidor'**
  String get profileSyncUpToDate;

  /// No description provided for @profilePermissionsCount.
  ///
  /// In es, this message translates to:
  /// **'{p1} permisos operativos asignados'**
  String profilePermissionsCount(int p1);

  /// No description provided for @commonCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @profilePendingCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{{count} registro pendiente de sincronizar} other{{count} registros pendientes de sincronizar}}'**
  String profilePendingCount(int count);

  /// No description provided for @ordersTitle.
  ///
  /// In es, this message translates to:
  /// **'Órdenes de la sede'**
  String get ordersTitle;

  /// No description provided for @ordersSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Órdenes de trabajo abiertas. Entra a una para ver sus tareas.'**
  String get ordersSubtitle;

  /// No description provided for @ordersEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay órdenes abiertas.'**
  String get ordersEmpty;

  /// No description provided for @ordersNoPermission.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil no tiene permiso para ver órdenes.'**
  String get ordersNoPermission;

  /// No description provided for @ordersCacheNotice.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión: mostrando las órdenes guardadas.'**
  String get ordersCacheNotice;

  /// No description provided for @ordersNoNumber.
  ///
  /// In es, this message translates to:
  /// **'Orden sin número'**
  String get ordersNoNumber;

  /// No description provided for @ordersTotal.
  ///
  /// In es, this message translates to:
  /// **'Total: {p1}'**
  String ordersTotal(String p1);

  /// No description provided for @orderDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle de orden'**
  String get orderDetailTitle;

  /// No description provided for @orderTasksTitle.
  ///
  /// In es, this message translates to:
  /// **'Tareas de la orden'**
  String get orderTasksTitle;

  /// No description provided for @orderTasksEmpty.
  ///
  /// In es, this message translates to:
  /// **'Esta orden aún no tiene tareas.'**
  String get orderTasksEmpty;

  /// No description provided for @orderTaskMechanic.
  ///
  /// In es, this message translates to:
  /// **'Mecánico: {p1}'**
  String orderTaskMechanic(String p1);

  /// No description provided for @orderTaskParts.
  ///
  /// In es, this message translates to:
  /// **'Repuestos imputados: {p1}'**
  String orderTaskParts(int p1);

  /// No description provided for @orderStatusDraft.
  ///
  /// In es, this message translates to:
  /// **'Borrador'**
  String get orderStatusDraft;

  /// No description provided for @orderStatusInProgress.
  ///
  /// In es, this message translates to:
  /// **'En curso'**
  String get orderStatusInProgress;

  /// No description provided for @orderStatusCompleted.
  ///
  /// In es, this message translates to:
  /// **'Completada'**
  String get orderStatusCompleted;

  /// No description provided for @orderStatusPaid.
  ///
  /// In es, this message translates to:
  /// **'Pagada'**
  String get orderStatusPaid;

  /// No description provided for @orderStatusCanceled.
  ///
  /// In es, this message translates to:
  /// **'Cancelada'**
  String get orderStatusCanceled;

  /// No description provided for @orderStatusUnknown.
  ///
  /// In es, this message translates to:
  /// **'Sin estado'**
  String get orderStatusUnknown;

  /// No description provided for @orderCodeFormat.
  ///
  /// In es, this message translates to:
  /// **'OT-{p1}'**
  String orderCodeFormat(String p1);

  /// No description provided for @orderStatusWaitingCustomer.
  ///
  /// In es, this message translates to:
  /// **'Esperando al cliente'**
  String get orderStatusWaitingCustomer;

  /// No description provided for @orderTaskLabor.
  ///
  /// In es, this message translates to:
  /// **'Mano de obra'**
  String get orderTaskLabor;

  /// No description provided for @orderTaskHours.
  ///
  /// In es, this message translates to:
  /// **'{p1} h'**
  String orderTaskHours(int p1);

  /// No description provided for @orderTaskMinutes.
  ///
  /// In es, this message translates to:
  /// **'{p1} min'**
  String orderTaskMinutes(int p1);

  /// No description provided for @orderTaskHoursMinutes.
  ///
  /// In es, this message translates to:
  /// **'{p1} h {p2} min'**
  String orderTaskHoursMinutes(int p1, int p2);

  /// No description provided for @orderPartLineDetail.
  ///
  /// In es, this message translates to:
  /// **'{p1} × {p2}'**
  String orderPartLineDetail(String p1, String p2);

  /// No description provided for @orderAddPart.
  ///
  /// In es, this message translates to:
  /// **'Agregar repuesto'**
  String get orderAddPart;

  /// No description provided for @orderAddTask.
  ///
  /// In es, this message translates to:
  /// **'Agregar tarea'**
  String get orderAddTask;

  /// No description provided for @orderEditLabor.
  ///
  /// In es, this message translates to:
  /// **'Editar mano de obra'**
  String get orderEditLabor;

  /// No description provided for @orderOpenTaskDetail.
  ///
  /// In es, this message translates to:
  /// **'Abrir cronómetro y tarea'**
  String get orderOpenTaskDetail;

  /// No description provided for @orderAddTaskTitle.
  ///
  /// In es, this message translates to:
  /// **'Agregar tarea'**
  String get orderAddTaskTitle;

  /// No description provided for @orderAddTaskService.
  ///
  /// In es, this message translates to:
  /// **'Servicio'**
  String get orderAddTaskService;

  /// No description provided for @orderAddTaskDescription.
  ///
  /// In es, this message translates to:
  /// **'Descripción de la tarea'**
  String get orderAddTaskDescription;

  /// No description provided for @orderAddTaskPrice.
  ///
  /// In es, this message translates to:
  /// **'Mano de obra sin IGV'**
  String get orderAddTaskPrice;

  /// No description provided for @orderAddTaskConfirm.
  ///
  /// In es, this message translates to:
  /// **'Agregar a la orden'**
  String get orderAddTaskConfirm;

  /// No description provided for @orderEditLaborTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar mano de obra'**
  String get orderEditLaborTitle;

  /// No description provided for @orderEditLaborConfirm.
  ///
  /// In es, this message translates to:
  /// **'Guardar precio'**
  String get orderEditLaborConfirm;

  /// No description provided for @orderFieldService.
  ///
  /// In es, this message translates to:
  /// **'Elige un servicio del catálogo.'**
  String get orderFieldService;

  /// No description provided for @orderFieldDescription.
  ///
  /// In es, this message translates to:
  /// **'Escribe la descripción de la tarea.'**
  String get orderFieldDescription;

  /// No description provided for @orderFieldPrice.
  ///
  /// In es, this message translates to:
  /// **'Escribe un monto mayor o igual a 0.'**
  String get orderFieldPrice;

  /// No description provided for @orderTaskAdded.
  ///
  /// In es, this message translates to:
  /// **'Tarea agregada y totales recalculados.'**
  String get orderTaskAdded;

  /// No description provided for @orderTaskUpdated.
  ///
  /// In es, this message translates to:
  /// **'Mano de obra actualizada y totales recalculados.'**
  String get orderTaskUpdated;

  /// No description provided for @orderDeleteTask.
  ///
  /// In es, this message translates to:
  /// **'Eliminar tarea'**
  String get orderDeleteTask;

  /// No description provided for @orderDeleteTaskTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar tarea de la orden'**
  String get orderDeleteTaskTitle;

  /// No description provided for @orderDeleteTaskBody.
  ///
  /// In es, this message translates to:
  /// **'Se quitará \"{p1}\" de la orden y se recalcularán los totales.'**
  String orderDeleteTaskBody(String p1);

  /// No description provided for @orderDeleteTaskHasParts.
  ///
  /// In es, this message translates to:
  /// **'Esta tarea tiene repuestos imputados. Retira primero los repuestos antes de eliminarla.'**
  String get orderDeleteTaskHasParts;

  /// No description provided for @orderDeleteTaskConfirm.
  ///
  /// In es, this message translates to:
  /// **'Eliminar tarea'**
  String get orderDeleteTaskConfirm;

  /// No description provided for @orderTaskDeleted.
  ///
  /// In es, this message translates to:
  /// **'Tarea eliminada y totales recalculados.'**
  String get orderTaskDeleted;

  /// No description provided for @servicesTitle.
  ///
  /// In es, this message translates to:
  /// **'Servicios del taller'**
  String get servicesTitle;

  /// No description provided for @servicesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Mano de obra estándar y tarifas base (sin IGV)'**
  String get servicesSubtitle;

  /// No description provided for @servicesSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar servicio…'**
  String get servicesSearchHint;

  /// No description provided for @servicesEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay servicios registrados en el catálogo del taller.'**
  String get servicesEmpty;

  /// No description provided for @servicesEmptySearch.
  ///
  /// In es, this message translates to:
  /// **'No encontramos servicios con ese nombre.'**
  String get servicesEmptySearch;

  /// No description provided for @servicesAdd.
  ///
  /// In es, this message translates to:
  /// **'Nuevo servicio'**
  String get servicesAdd;

  /// No description provided for @servicesNewTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo servicio'**
  String get servicesNewTitle;

  /// No description provided for @servicesEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar servicio'**
  String get servicesEditTitle;

  /// No description provided for @servicesSaveCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear servicio'**
  String get servicesSaveCreate;

  /// No description provided for @servicesSaveEdit.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get servicesSaveEdit;

  /// No description provided for @servicesNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del servicio'**
  String get servicesNameLabel;

  /// No description provided for @servicesNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Afinamiento de motor'**
  String get servicesNameHint;

  /// No description provided for @servicesPriceLabel.
  ///
  /// In es, this message translates to:
  /// **'Tarifa base sin IGV (S/)'**
  String get servicesPriceLabel;

  /// No description provided for @servicesPriceHint.
  ///
  /// In es, this message translates to:
  /// **'120.00'**
  String get servicesPriceHint;

  /// No description provided for @servicesDurationLabel.
  ///
  /// In es, this message translates to:
  /// **'Duración estimada (minutos)'**
  String get servicesDurationLabel;

  /// No description provided for @servicesDurationHint.
  ///
  /// In es, this message translates to:
  /// **'45'**
  String get servicesDurationHint;

  /// No description provided for @servicesFieldName.
  ///
  /// In es, this message translates to:
  /// **'Escribe el nombre del servicio (máximo 150 caracteres).'**
  String get servicesFieldName;

  /// No description provided for @servicesFieldPrice.
  ///
  /// In es, this message translates to:
  /// **'Escribe una tarifa mayor a 0.'**
  String get servicesFieldPrice;

  /// No description provided for @servicesFieldDuration.
  ///
  /// In es, this message translates to:
  /// **'Escribe una duración en minutos mayor a 0.'**
  String get servicesFieldDuration;

  /// No description provided for @servicesDurationMin.
  ///
  /// In es, this message translates to:
  /// **'{p1} min'**
  String servicesDurationMin(int p1);

  /// No description provided for @servicesDeleteAction.
  ///
  /// In es, this message translates to:
  /// **'Eliminar servicio'**
  String get servicesDeleteAction;

  /// No description provided for @servicesDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar servicio'**
  String get servicesDeleteTitle;

  /// No description provided for @servicesDeleteBody.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que deseas eliminar \"{p1}\" del catálogo? Solo se puede eliminar si no tiene tareas registradas en órdenes de trabajo.'**
  String servicesDeleteBody(String p1);

  /// No description provided for @servicesDeleteConfirm.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get servicesDeleteConfirm;

  /// No description provided for @servicesCreatedNotice.
  ///
  /// In es, this message translates to:
  /// **'Servicio agregado al catálogo.'**
  String get servicesCreatedNotice;

  /// No description provided for @servicesUpdatedNotice.
  ///
  /// In es, this message translates to:
  /// **'Servicio actualizado.'**
  String get servicesUpdatedNotice;

  /// No description provided for @servicesDeletedNotice.
  ///
  /// In es, this message translates to:
  /// **'Servicio eliminado del catálogo.'**
  String get servicesDeletedNotice;

  /// No description provided for @servicesReadonlyHint.
  ///
  /// In es, this message translates to:
  /// **'Solo puedes consultar el catálogo. Para editar tarifas necesitas permiso de gestión de servicios.'**
  String get servicesReadonlyHint;

  /// No description provided for @quotationSubtotal.
  ///
  /// In es, this message translates to:
  /// **'Subtotal'**
  String get quotationSubtotal;

  /// No description provided for @quotationIgv.
  ///
  /// In es, this message translates to:
  /// **'IGV 18 %'**
  String get quotationIgv;

  /// No description provided for @quotationTotal.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get quotationTotal;

  /// No description provided for @quotationGeneratePdf.
  ///
  /// In es, this message translates to:
  /// **'Generar proforma'**
  String get quotationGeneratePdf;

  /// No description provided for @quotationSharePdf.
  ///
  /// In es, this message translates to:
  /// **'Compartir proforma PDF'**
  String get quotationSharePdf;

  /// No description provided for @quotationSendEmail.
  ///
  /// In es, this message translates to:
  /// **'Enviar proforma por correo'**
  String get quotationSendEmail;

  /// No description provided for @quotationPdfReady.
  ///
  /// In es, this message translates to:
  /// **'Proforma generada y lista para compartir.'**
  String get quotationPdfReady;

  /// No description provided for @quotationSentNotice.
  ///
  /// In es, this message translates to:
  /// **'Proforma enviada a {p1}.'**
  String quotationSentNotice(String p1);

  /// No description provided for @quotationShareChooser.
  ///
  /// In es, this message translates to:
  /// **'Compartir proforma'**
  String get quotationShareChooser;

  /// No description provided for @quotationNoPdfApp.
  ///
  /// In es, this message translates to:
  /// **'No hay una aplicación instalada para abrir o compartir el PDF.'**
  String get quotationNoPdfApp;

  /// No description provided for @quotationCustomerQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Qué respondió el cliente?'**
  String get quotationCustomerQuestion;

  /// No description provided for @quotationApproveAction.
  ///
  /// In es, this message translates to:
  /// **'Aceptó. Iniciar trabajos'**
  String get quotationApproveAction;

  /// No description provided for @quotationRejectAction.
  ///
  /// In es, this message translates to:
  /// **'Rechazó. Cancelar orden'**
  String get quotationRejectAction;

  /// No description provided for @quotationApprovedNotice.
  ///
  /// In es, this message translates to:
  /// **'Orden en progreso. Los técnicos ya pueden empezar.'**
  String get quotationApprovedNotice;

  /// No description provided for @quotationRejectedNotice.
  ///
  /// In es, this message translates to:
  /// **'Orden cancelada. Los repuestos reservados volvieron al inventario.'**
  String get quotationRejectedNotice;

  /// No description provided for @quotationRejectTitle.
  ///
  /// In es, this message translates to:
  /// **'Cancelar la orden'**
  String get quotationRejectTitle;

  /// No description provided for @quotationRejectBody.
  ///
  /// In es, this message translates to:
  /// **'Los repuestos reservados volverán al inventario.'**
  String get quotationRejectBody;

  /// No description provided for @quotationRejectReasonLabel.
  ///
  /// In es, this message translates to:
  /// **'Motivo del rechazo'**
  String get quotationRejectReasonLabel;

  /// No description provided for @quotationRejectReasonHint.
  ///
  /// In es, this message translates to:
  /// **'Precio fuera de presupuesto'**
  String get quotationRejectReasonHint;

  /// No description provided for @quotationRejectFieldError.
  ///
  /// In es, this message translates to:
  /// **'Escribe el motivo del rechazo (máximo 1000 caracteres).'**
  String get quotationRejectFieldError;

  /// No description provided for @quotationRejectConfirm.
  ///
  /// In es, this message translates to:
  /// **'Cancelar orden'**
  String get quotationRejectConfirm;

  /// No description provided for @quotationRejectBack.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get quotationRejectBack;

  /// No description provided for @orderOpenProposals.
  ///
  /// In es, this message translates to:
  /// **'Ver propuestas de hallazgos'**
  String get orderOpenProposals;

  /// No description provided for @orderOpenGallery.
  ///
  /// In es, this message translates to:
  /// **'Ver fotos de recepción'**
  String get orderOpenGallery;

  /// No description provided for @orderIntakeIncompleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Datos de ingreso pendientes'**
  String get orderIntakeIncompleteTitle;

  /// No description provided for @orderIntakeIncompleteBody.
  ///
  /// In es, this message translates to:
  /// **'El odómetro actual o la recepción de patio no han sido completados para esta orden.'**
  String get orderIntakeIncompleteBody;

  /// No description provided for @orderCompleteIntakeBtn.
  ///
  /// In es, this message translates to:
  /// **'Completar odómetro e ingreso'**
  String get orderCompleteIntakeBtn;

  /// No description provided for @ordersNewBtn.
  ///
  /// In es, this message translates to:
  /// **'Nueva orden'**
  String get ordersNewBtn;

  /// No description provided for @ordersNewSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva orden de trabajo'**
  String get ordersNewSheetTitle;

  /// No description provided for @ordersNewSheetSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una cita programada para hoy o realiza un ingreso presencial.'**
  String get ordersNewSheetSubtitle;

  /// No description provided for @ordersNewByAppointmentSection.
  ///
  /// In es, this message translates to:
  /// **'Citas agendadas para hoy'**
  String get ordersNewByAppointmentSection;

  /// No description provided for @ordersNewAppointmentArriveCta.
  ///
  /// In es, this message translates to:
  /// **'Marcar llegada y abrir orden'**
  String get ordersNewAppointmentArriveCta;

  /// No description provided for @ordersNewNoAppointments.
  ///
  /// In es, this message translates to:
  /// **'No hay citas agendadas para el día de hoy.'**
  String get ordersNewNoAppointments;

  /// No description provided for @ordersNewWalkInSection.
  ///
  /// In es, this message translates to:
  /// **'Ingreso presencial sin cita'**
  String get ordersNewWalkInSection;

  /// No description provided for @ordersNewWalkInTitle.
  ///
  /// In es, this message translates to:
  /// **'Ingreso directo en patio'**
  String get ordersNewWalkInTitle;

  /// No description provided for @ordersNewWalkInDesc.
  ///
  /// In es, this message translates to:
  /// **'Consultar placa o DNI para registrar recepción y abrir orden'**
  String get ordersNewWalkInDesc;

  /// No description provided for @ordersNewWalkInCta.
  ///
  /// In es, this message translates to:
  /// **'Consultar placa en recepción'**
  String get ordersNewWalkInCta;

  /// No description provided for @ordersCompleteDraftCta.
  ///
  /// In es, this message translates to:
  /// **'Completar ingreso'**
  String get ordersCompleteDraftCta;

  /// No description provided for @attendanceOutsideGeofenceBlocked.
  ///
  /// In es, this message translates to:
  /// **'No puedes marcar fuera de la geocerca: estás a {p1} m de la sede y el radio permitido es {p2} m.'**
  String attendanceOutsideGeofenceBlocked(int p1, int p2);

  /// No description provided for @attendanceMockLocationBlocked.
  ///
  /// In es, this message translates to:
  /// **'No se permite marcar con una ubicación simulada. Desactiva la aplicación de ubicación ficticia e inténtalo de nuevo.'**
  String get attendanceMockLocationBlocked;

  /// No description provided for @attendanceBranchGeofenceUnavailable.
  ///
  /// In es, this message translates to:
  /// **'No se pudo validar la geocerca de tu sede porque no está disponible sin conexión. Conéctate y actualiza la información antes de marcar.'**
  String get attendanceBranchGeofenceUnavailable;

  /// No description provided for @attendanceSelectedDayHours.
  ///
  /// In es, this message translates to:
  /// **'Horario asignado: {p1} – {p2}'**
  String attendanceSelectedDayHours(String p1, String p2);

  /// No description provided for @attendanceSelectedDayRest.
  ///
  /// In es, this message translates to:
  /// **'No tienes turno asignado para este día.'**
  String get attendanceSelectedDayRest;

  /// No description provided for @attendanceClockOutConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Confirmar salida'**
  String get attendanceClockOutConfirmTitle;

  /// No description provided for @attendanceClockOutConfirmMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Deseas cerrar tu jornada laboral? El sistema registrará la hora de salida y calculará las horas regulares y el sobretiempo.'**
  String get attendanceClockOutConfirmMessage;

  /// No description provided for @attendanceClockOutConfirmAction.
  ///
  /// In es, this message translates to:
  /// **'Confirmar salida'**
  String get attendanceClockOutConfirmAction;

  /// No description provided for @branchAssignedBadge.
  ///
  /// In es, this message translates to:
  /// **'Sucursal asignada para tu jornada'**
  String get branchAssignedBadge;

  /// No description provided for @receptionTabCounter.
  ///
  /// In es, this message translates to:
  /// **'Recepción'**
  String get receptionTabCounter;

  /// No description provided for @receptionTabCustomersCount.
  ///
  /// In es, this message translates to:
  /// **'Clientes ({p1})'**
  String receptionTabCustomersCount(int p1);

  /// No description provided for @receptionTabVehiclesCount.
  ///
  /// In es, this message translates to:
  /// **'Vehículos ({p1})'**
  String receptionTabVehiclesCount(int p1);

  /// No description provided for @receptionQuickWalkIn.
  ///
  /// In es, this message translates to:
  /// **'Ingreso presencial'**
  String get receptionQuickWalkIn;

  /// No description provided for @receptionCustomersDirectoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Cartera de clientes del taller'**
  String get receptionCustomersDirectoryTitle;

  /// No description provided for @receptionNewCustomerBtn.
  ///
  /// In es, this message translates to:
  /// **'Nuevo cliente'**
  String get receptionNewCustomerBtn;

  /// No description provided for @receptionCustomersFilterLabel.
  ///
  /// In es, this message translates to:
  /// **'Filtrar por nombre, DNI/RUC, teléfono o correo'**
  String get receptionCustomersFilterLabel;

  /// No description provided for @receptionCustomersEmptyDirectory.
  ///
  /// In es, this message translates to:
  /// **'No hay clientes registrados con ese filtro.'**
  String get receptionCustomersEmptyDirectory;

  /// No description provided for @receptionRefreshDirectory.
  ///
  /// In es, this message translates to:
  /// **'Actualizar cartera'**
  String get receptionRefreshDirectory;

  /// No description provided for @receptionVehiclesDirectoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Vehículos registrados en el taller'**
  String get receptionVehiclesDirectoryTitle;

  /// No description provided for @receptionNewVehicleBtn.
  ///
  /// In es, this message translates to:
  /// **'Nuevo vehículo'**
  String get receptionNewVehicleBtn;

  /// No description provided for @receptionVehiclesFilterLabel.
  ///
  /// In es, this message translates to:
  /// **'Filtrar por placa, marca, modelo o propietario'**
  String get receptionVehiclesFilterLabel;

  /// No description provided for @receptionVehiclesEmptyDirectory.
  ///
  /// In es, this message translates to:
  /// **'No hay vehículos registrados con ese filtro.'**
  String get receptionVehiclesEmptyDirectory;

  /// No description provided for @receptionVehicleMileageKm.
  ///
  /// In es, this message translates to:
  /// **'Odómetro: {p1} km'**
  String receptionVehicleMileageKm(int p1);

  /// No description provided for @receptionAddVehicleToCustomer.
  ///
  /// In es, this message translates to:
  /// **'Agregar vehículo al cliente'**
  String get receptionAddVehicleToCustomer;

  /// No description provided for @registerVehicleForCustomerTitle.
  ///
  /// In es, this message translates to:
  /// **'Agregar vehículo a cliente'**
  String get registerVehicleForCustomerTitle;

  /// No description provided for @registerVehicleForCustomerBanner.
  ///
  /// In es, this message translates to:
  /// **'Propietario seleccionado: {p1}'**
  String registerVehicleForCustomerBanner(String p1);

  /// No description provided for @openOrderQuickReasonGeneral.
  ///
  /// In es, this message translates to:
  /// **'Ingreso presencial / Revisión general'**
  String get openOrderQuickReasonGeneral;

  /// No description provided for @openOrderQuickReasonPreventive.
  ///
  /// In es, this message translates to:
  /// **'Mantenimiento preventivo'**
  String get openOrderQuickReasonPreventive;

  /// No description provided for @quotationLaborSubtotal.
  ///
  /// In es, this message translates to:
  /// **'Subtotal mano de obra'**
  String get quotationLaborSubtotal;

  /// No description provided for @quotationPartsSubtotal.
  ///
  /// In es, this message translates to:
  /// **'Subtotal repuestos'**
  String get quotationPartsSubtotal;

  /// No description provided for @quotationPdfPreviewTitle.
  ///
  /// In es, this message translates to:
  /// **'Proforma digital (PDF)'**
  String get quotationPdfPreviewTitle;

  /// No description provided for @quotationPdfPageDesc.
  ///
  /// In es, this message translates to:
  /// **'Página {p1} de la proforma'**
  String quotationPdfPageDesc(int p1);

  /// No description provided for @quotationPdfClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar vista previa'**
  String get quotationPdfClose;

  /// No description provided for @orderIntakePhotosBadge.
  ///
  /// In es, this message translates to:
  /// **'{p1} fotos en patio'**
  String orderIntakePhotosBadge(int p1);

  /// No description provided for @orderAssignBayTitle.
  ///
  /// In es, this message translates to:
  /// **'Asignar bahía de trabajo'**
  String get orderAssignBayTitle;

  /// No description provided for @orderAssignBaySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una bahía libre para la intervención técnica del vehículo.'**
  String get orderAssignBaySubtitle;

  /// No description provided for @orderBayCurrent.
  ///
  /// In es, this message translates to:
  /// **'Bahía actual'**
  String get orderBayCurrent;

  /// No description provided for @orderAssignToBay.
  ///
  /// In es, this message translates to:
  /// **'Asignar a {p1}'**
  String orderAssignToBay(String p1);

  /// No description provided for @orderAssignBayBtn.
  ///
  /// In es, this message translates to:
  /// **'Asignar bahía de trabajo'**
  String get orderAssignBayBtn;

  /// No description provided for @orderChangeBayBtn.
  ///
  /// In es, this message translates to:
  /// **'Bahía: {p1} (Cambiar)'**
  String orderChangeBayBtn(String p1);

  /// No description provided for @orderBayAssignedNotice.
  ///
  /// In es, this message translates to:
  /// **'Orden asignada a {p1} para intervención técnica.'**
  String orderBayAssignedNotice(String p1);

  /// No description provided for @orderTaskMechanicLabel.
  ///
  /// In es, this message translates to:
  /// **'Mecánico asignado'**
  String get orderTaskMechanicLabel;

  /// No description provided for @orderAssignMechanicBtn.
  ///
  /// In es, this message translates to:
  /// **'Asignar mecánico'**
  String get orderAssignMechanicBtn;

  /// No description provided for @orderReassignMechanicBtn.
  ///
  /// In es, this message translates to:
  /// **'Reasignar mecánico'**
  String get orderReassignMechanicBtn;

  /// No description provided for @orderMechanicUnassigned.
  ///
  /// In es, this message translates to:
  /// **'Sin mecánico asignado'**
  String get orderMechanicUnassigned;

  /// No description provided for @orderAssignMechanicTitle.
  ///
  /// In es, this message translates to:
  /// **'Asignar mecánico a la tarea'**
  String get orderAssignMechanicTitle;

  /// No description provided for @orderAssignMechanicSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Selecciona el especialista técnico para la tarea «{p1}».'**
  String orderAssignMechanicSubtitle(String p1);

  /// No description provided for @orderMechanicsEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay mecánicos disponibles en la sede.'**
  String get orderMechanicsEmpty;

  /// No description provided for @orderMechanicCurrent.
  ///
  /// In es, this message translates to:
  /// **'Asignado actualmente'**
  String get orderMechanicCurrent;

  /// No description provided for @orderMechanicAssignedNotice.
  ///
  /// In es, this message translates to:
  /// **'Mecánico {p1} asignado a la tarea.'**
  String orderMechanicAssignedNotice(String p1);

  /// No description provided for @orderAddTaskMechanic.
  ///
  /// In es, this message translates to:
  /// **'Mecánico responsable (opcional)'**
  String get orderAddTaskMechanic;

  /// No description provided for @orderMechanicRoleDefault.
  ///
  /// In es, this message translates to:
  /// **'Técnico automotriz'**
  String get orderMechanicRoleDefault;

  /// No description provided for @baysTitle.
  ///
  /// In es, this message translates to:
  /// **'Bahías de trabajo'**
  String get baysTitle;

  /// No description provided for @baysNoPermission.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil no tiene permiso para consultar las bahías.'**
  String get baysNoPermission;

  /// No description provided for @baysFilterAll.
  ///
  /// In es, this message translates to:
  /// **'Todas ({p1})'**
  String baysFilterAll(int p1);

  /// No description provided for @baysFilterAvailable.
  ///
  /// In es, this message translates to:
  /// **'Libres ({p1})'**
  String baysFilterAvailable(int p1);

  /// No description provided for @baysFilterOccupied.
  ///
  /// In es, this message translates to:
  /// **'Ocupadas ({p1})'**
  String baysFilterOccupied(int p1);

  /// No description provided for @baysEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay bahías registradas para este filtro.'**
  String get baysEmpty;

  /// No description provided for @baysRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get baysRefresh;

  /// No description provided for @baysSelectOrderPrompt.
  ///
  /// In es, this message translates to:
  /// **'Elige la orden de trabajo que ingresará a esta bahía:'**
  String get baysSelectOrderPrompt;

  /// No description provided for @baysAssignOrderBtn.
  ///
  /// In es, this message translates to:
  /// **'Ingresar orden a esta bahía'**
  String get baysAssignOrderBtn;

  /// No description provided for @baysNewBtn.
  ///
  /// In es, this message translates to:
  /// **'Nueva bahía'**
  String get baysNewBtn;

  /// No description provided for @baysCreateDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Registrar bahía física'**
  String get baysCreateDialogTitle;

  /// No description provided for @baysNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la bahía'**
  String get baysNameLabel;

  /// No description provided for @baysNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Elevador 3, Bahía Rápida 2'**
  String get baysNameHint;

  /// No description provided for @baysTypeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tipo de instalación'**
  String get baysTypeLabel;

  /// No description provided for @baysCreateConfirm.
  ///
  /// In es, this message translates to:
  /// **'Registrar bahía'**
  String get baysCreateConfirm;

  /// No description provided for @baysCreatedNotice.
  ///
  /// In es, this message translates to:
  /// **'Bahía {p1} registrada exitosamente.'**
  String baysCreatedNotice(String p1);

  /// No description provided for @bayTypeLift.
  ///
  /// In es, this message translates to:
  /// **'Elevador hidráulico'**
  String get bayTypeLift;

  /// No description provided for @bayTypeMechanicalLift.
  ///
  /// In es, this message translates to:
  /// **'Elevador mecánico'**
  String get bayTypeMechanicalLift;

  /// No description provided for @bayTypeDiagnosticPit.
  ///
  /// In es, this message translates to:
  /// **'Fosa de diagnóstico'**
  String get bayTypeDiagnosticPit;

  /// No description provided for @bayTypeWashBay.
  ///
  /// In es, this message translates to:
  /// **'Bahía de lavado'**
  String get bayTypeWashBay;

  /// No description provided for @bayTypeAlignment.
  ///
  /// In es, this message translates to:
  /// **'Estación de alineación'**
  String get bayTypeAlignment;

  /// No description provided for @bayTypePaintBooth.
  ///
  /// In es, this message translates to:
  /// **'Cabina de pintura'**
  String get bayTypePaintBooth;

  /// No description provided for @bayStatusAvailable.
  ///
  /// In es, this message translates to:
  /// **'Libre'**
  String get bayStatusAvailable;

  /// No description provided for @bayStatusOccupied.
  ///
  /// In es, this message translates to:
  /// **'Ocupada'**
  String get bayStatusOccupied;

  /// No description provided for @bayStatusMaintenance.
  ///
  /// In es, this message translates to:
  /// **'Mantenimiento'**
  String get bayStatusMaintenance;

  /// No description provided for @obdInventorySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Inventario de escáneres OBD-II registrados en el taller y su estado operativo.'**
  String get obdInventorySubtitle;

  /// No description provided for @obdRegisterBtn.
  ///
  /// In es, this message translates to:
  /// **'Registrar escáner OBD-II'**
  String get obdRegisterBtn;

  /// No description provided for @obdFilterAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get obdFilterAll;

  /// No description provided for @obdFilterActive.
  ///
  /// In es, this message translates to:
  /// **'Activos'**
  String get obdFilterActive;

  /// No description provided for @obdFilterInactive.
  ///
  /// In es, this message translates to:
  /// **'Inactivos'**
  String get obdFilterInactive;

  /// No description provided for @obdEmptyList.
  ///
  /// In es, this message translates to:
  /// **'No hay escáneres OBD-II registrados con este filtro.'**
  String get obdEmptyList;

  /// No description provided for @obdRegisterDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Registrar escáner OBD-II'**
  String get obdRegisterDialogTitle;

  /// No description provided for @obdFieldIdentifier.
  ///
  /// In es, this message translates to:
  /// **'Identificador / MAC / Serie'**
  String get obdFieldIdentifier;

  /// No description provided for @obdFieldConnectionType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de conexión'**
  String get obdFieldConnectionType;

  /// No description provided for @obdFieldModel.
  ///
  /// In es, this message translates to:
  /// **'Modelo de hardware'**
  String get obdFieldModel;

  /// No description provided for @obdFieldFirmware.
  ///
  /// In es, this message translates to:
  /// **'Versión de firmware'**
  String get obdFieldFirmware;

  /// No description provided for @obdRegisterConfirm.
  ///
  /// In es, this message translates to:
  /// **'Registrar dispositivo'**
  String get obdRegisterConfirm;

  /// No description provided for @obdChangeStatusPrompt.
  ///
  /// In es, this message translates to:
  /// **'Selecciona el nuevo estado operativo del escáner:'**
  String get obdChangeStatusPrompt;

  /// No description provided for @obdChangeStatusBtn.
  ///
  /// In es, this message translates to:
  /// **'Cambiar estado'**
  String get obdChangeStatusBtn;

  /// No description provided for @obdStatusActive.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get obdStatusActive;

  /// No description provided for @obdStatusInactive.
  ///
  /// In es, this message translates to:
  /// **'Inactivo'**
  String get obdStatusInactive;

  /// No description provided for @obdStatusLost.
  ///
  /// In es, this message translates to:
  /// **'Extraviado'**
  String get obdStatusLost;

  /// No description provided for @obdStatusBroken.
  ///
  /// In es, this message translates to:
  /// **'Averiado'**
  String get obdStatusBroken;

  /// No description provided for @obdRegisteredNotice.
  ///
  /// In es, this message translates to:
  /// **'Escáner {p1} registrado en el inventario del taller.'**
  String obdRegisteredNotice(String p1);

  /// No description provided for @obdStatusUpdatedNotice.
  ///
  /// In es, this message translates to:
  /// **'Estado de {p1} actualizado.'**
  String obdStatusUpdatedNotice(String p1);

  /// No description provided for @obdConnectedVehicle.
  ///
  /// In es, this message translates to:
  /// **'Conectado a vehículo'**
  String get obdConnectedVehicle;

  /// No description provided for @obdConnectedVehicleFormat.
  ///
  /// In es, this message translates to:
  /// **'{p1} · {p2}'**
  String obdConnectedVehicleFormat(String p1, String p2);

  /// No description provided for @obdConnectedOwnerFormat.
  ///
  /// In es, this message translates to:
  /// **'Titular: {p1}'**
  String obdConnectedOwnerFormat(String p1);

  /// No description provided for @obdNotConnected.
  ///
  /// In es, this message translates to:
  /// **'Sin vehículo asignado'**
  String get obdNotConnected;

  /// No description provided for @obdInstallBtn.
  ///
  /// In es, this message translates to:
  /// **'Vincular'**
  String get obdInstallBtn;

  /// No description provided for @obdUninstallBtn.
  ///
  /// In es, this message translates to:
  /// **'Desvincular'**
  String get obdUninstallBtn;

  /// No description provided for @obdInstallDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Vincular escáner a vehículo'**
  String get obdInstallDialogTitle;

  /// No description provided for @obdInstallSelectPrompt.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un vehículo del padrón del taller:'**
  String get obdInstallSelectPrompt;

  /// No description provided for @obdUninstallConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Desvincular escáner'**
  String get obdUninstallConfirmTitle;

  /// No description provided for @obdUninstallConfirmPrompt.
  ///
  /// In es, this message translates to:
  /// **'¿Confirmas desvincular este escáner de {p1}?'**
  String obdUninstallConfirmPrompt(String p1);

  /// No description provided for @obdInstallSuccess.
  ///
  /// In es, this message translates to:
  /// **'Escáner vinculado a {p1}.'**
  String obdInstallSuccess(String p1);

  /// No description provided for @obdUninstallSuccess.
  ///
  /// In es, this message translates to:
  /// **'Escáner desvinculado con éxito.'**
  String get obdUninstallSuccess;

  /// No description provided for @syncQueueTitle.
  ///
  /// In es, this message translates to:
  /// **'Sincronización offline'**
  String get syncQueueTitle;

  /// No description provided for @syncQueueSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Registros capturados en el teléfono pendientes de envío al servidor.'**
  String get syncQueueSubtitle;

  /// No description provided for @syncStatusOnline.
  ///
  /// In es, this message translates to:
  /// **'Conectado: la sincronización automática está activa.'**
  String get syncStatusOnline;

  /// No description provided for @syncStatusOffline.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión: los registros se enviarán en cuanto vuelva la red.'**
  String get syncStatusOffline;

  /// No description provided for @syncRequestedNotice.
  ///
  /// In es, this message translates to:
  /// **'Sincronización iniciada en segundo plano.'**
  String get syncRequestedNotice;

  /// No description provided for @syncNowBtn.
  ///
  /// In es, this message translates to:
  /// **'Sincronizar ahora ({p1})'**
  String syncNowBtn(int p1);

  /// No description provided for @syncEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Todo sincronizado'**
  String get syncEmptyTitle;

  /// No description provided for @syncEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'No tienes registros pendientes de envío en la cola local.'**
  String get syncEmptyBody;

  /// No description provided for @syncOpPending.
  ///
  /// In es, this message translates to:
  /// **'En cola'**
  String get syncOpPending;

  /// No description provided for @syncOpSyncing.
  ///
  /// In es, this message translates to:
  /// **'Enviando'**
  String get syncOpSyncing;

  /// No description provided for @syncOpFailed.
  ///
  /// In es, this message translates to:
  /// **'Con error'**
  String get syncOpFailed;

  /// No description provided for @syncOpMeta.
  ///
  /// In es, this message translates to:
  /// **'Creado: {p1} · Intentos: {p2}'**
  String syncOpMeta(String p1, int p2);

  /// No description provided for @syncRetryBtn.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get syncRetryBtn;

  /// No description provided for @syncDiscardBtn.
  ///
  /// In es, this message translates to:
  /// **'Descartar'**
  String get syncDiscardBtn;

  /// No description provided for @syncTypeClockIn.
  ///
  /// In es, this message translates to:
  /// **'Marcación de ingreso'**
  String get syncTypeClockIn;

  /// No description provided for @syncTypeClockOut.
  ///
  /// In es, this message translates to:
  /// **'Marcación de salida'**
  String get syncTypeClockOut;

  /// No description provided for @syncTypeJustification.
  ///
  /// In es, this message translates to:
  /// **'Justificación de asistencia'**
  String get syncTypeJustification;

  /// No description provided for @syncTypeUploadFile.
  ///
  /// In es, this message translates to:
  /// **'Subida de fotografía'**
  String get syncTypeUploadFile;

  /// No description provided for @syncTypeIntakeImage.
  ///
  /// In es, this message translates to:
  /// **'Evidencia fotográfica de recepción'**
  String get syncTypeIntakeImage;

  /// No description provided for @syncTypeTaskEvidence.
  ///
  /// In es, this message translates to:
  /// **'Evidencia de tarea técnica'**
  String get syncTypeTaskEvidence;

  /// No description provided for @syncTypeStartTask.
  ///
  /// In es, this message translates to:
  /// **'Inicio de tarea'**
  String get syncTypeStartTask;

  /// No description provided for @syncTypePauseTask.
  ///
  /// In es, this message translates to:
  /// **'Pausa de tarea'**
  String get syncTypePauseTask;

  /// No description provided for @syncTypeResumeTask.
  ///
  /// In es, this message translates to:
  /// **'Reanudación de tarea'**
  String get syncTypeResumeTask;

  /// No description provided for @syncTypeCompleteTask.
  ///
  /// In es, this message translates to:
  /// **'Cierre de tarea'**
  String get syncTypeCompleteTask;

  /// No description provided for @syncTypeTelemetry.
  ///
  /// In es, this message translates to:
  /// **'Lote de telemetría OBD-II'**
  String get syncTypeTelemetry;

  /// No description provided for @syncTypeRegisterFault.
  ///
  /// In es, this message translates to:
  /// **'Registro de falla DTC'**
  String get syncTypeRegisterFault;

  /// No description provided for @syncTypeResolveFault.
  ///
  /// In es, this message translates to:
  /// **'Resolución de falla DTC'**
  String get syncTypeResolveFault;

  /// No description provided for @notificationsTitle.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones y alertas'**
  String get notificationsTitle;

  /// No description provided for @notificationsDisabledTitle.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones desactivadas en el teléfono'**
  String get notificationsDisabledTitle;

  /// No description provided for @notificationsDisabledBody.
  ///
  /// In es, this message translates to:
  /// **'Activa el permiso de notificaciones para recibir avisos de tareas, stock y asistencia.'**
  String get notificationsDisabledBody;

  /// No description provided for @notificationsEnableBtn.
  ///
  /// In es, this message translates to:
  /// **'Activar notificaciones'**
  String get notificationsEnableBtn;

  /// No description provided for @notificationsEnabledBanner.
  ///
  /// In es, this message translates to:
  /// **'Las notificaciones push están activas para tu sesión.'**
  String get notificationsEnabledBanner;

  /// No description provided for @notificationsSyncPendingTitle.
  ///
  /// In es, this message translates to:
  /// **'{p1} registros pendientes de sincronizar'**
  String notificationsSyncPendingTitle(int p1);

  /// No description provided for @notificationsSyncPendingBody.
  ///
  /// In es, this message translates to:
  /// **'Toca para revisar o forzar la sincronización con el servidor.'**
  String get notificationsSyncPendingBody;

  /// No description provided for @notificationsSectionStock.
  ///
  /// In es, this message translates to:
  /// **'Alertas de reposición de stock ({p1})'**
  String notificationsSectionStock(int p1);

  /// No description provided for @notificationsStockDeficitLine.
  ///
  /// In es, this message translates to:
  /// **'SKU {p1} · Stock actual: {p2} (Mínimo: {p3})'**
  String notificationsStockDeficitLine(String p1, String p2, String p3);

  /// No description provided for @notificationsLowStockChip.
  ///
  /// In es, this message translates to:
  /// **'Stock bajo'**
  String get notificationsLowStockChip;

  /// No description provided for @notificationsSectionJustifications.
  ///
  /// In es, this message translates to:
  /// **'Justificaciones por revisar ({p1})'**
  String notificationsSectionJustifications(int p1);

  /// No description provided for @notificationsJustificationChip.
  ///
  /// In es, this message translates to:
  /// **'Por aprobar'**
  String get notificationsJustificationChip;

  /// No description provided for @notificationsSectionQuotations.
  ///
  /// In es, this message translates to:
  /// **'Proformas esperando al cliente ({p1})'**
  String notificationsSectionQuotations(int p1);

  /// No description provided for @notificationsSectionPush.
  ///
  /// In es, this message translates to:
  /// **'Avisos recibidos en esta sesión'**
  String get notificationsSectionPush;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In es, this message translates to:
  /// **'Marcar leídos'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin alertas pendientes'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Aquí verás los avisos push, alertas de stock mínimo y justificaciones del personal.'**
  String get notificationsEmptyBody;

  /// No description provided for @adminAttendanceTitle.
  ///
  /// In es, this message translates to:
  /// **'Asistencia y personal'**
  String get adminAttendanceTitle;

  /// No description provided for @adminAttendanceTabBranch.
  ///
  /// In es, this message translates to:
  /// **'Sede hoy ({p1})'**
  String adminAttendanceTabBranch(int p1);

  /// No description provided for @adminAttendanceTabJustifications.
  ///
  /// In es, this message translates to:
  /// **'Justificaciones ({p1})'**
  String adminAttendanceTabJustifications(int p1);

  /// No description provided for @adminAttendanceTabOwn.
  ///
  /// In es, this message translates to:
  /// **'Mi asistencia'**
  String get adminAttendanceTabOwn;

  /// No description provided for @adminAttendanceEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay registros de asistencia para mostrar hoy en esta sede.'**
  String get adminAttendanceEmpty;

  /// No description provided for @adminAttendanceJustificationLine.
  ///
  /// In es, this message translates to:
  /// **'Descargo: {p1}'**
  String adminAttendanceJustificationLine(String p1);

  /// No description provided for @adminAttendanceApproveBtn.
  ///
  /// In es, this message translates to:
  /// **'Aprobar justificación'**
  String get adminAttendanceApproveBtn;

  /// No description provided for @adminAttendanceRejectBtn.
  ///
  /// In es, this message translates to:
  /// **'Rechazar'**
  String get adminAttendanceRejectBtn;

  /// No description provided for @adminAttendanceJustificationApproved.
  ///
  /// In es, this message translates to:
  /// **'Justificación aprobada (asistencia justificada).'**
  String get adminAttendanceJustificationApproved;

  /// No description provided for @adminAttendanceJustificationRejected.
  ///
  /// In es, this message translates to:
  /// **'Justificación desestimada.'**
  String get adminAttendanceJustificationRejected;

  /// No description provided for @dashboardTitle.
  ///
  /// In es, this message translates to:
  /// **'Panel de sede'**
  String get dashboardTitle;

  /// No description provided for @dashboardSyncBadge.
  ///
  /// In es, this message translates to:
  /// **'Cola ({p1})'**
  String dashboardSyncBadge(int p1);

  /// No description provided for @dashboardAlertsBadge.
  ///
  /// In es, this message translates to:
  /// **'Alertas ({p1})'**
  String dashboardAlertsBadge(int p1);

  /// No description provided for @dashboardAlertsBtn.
  ///
  /// In es, this message translates to:
  /// **'Alertas'**
  String get dashboardAlertsBtn;

  /// No description provided for @dashboardBranchLabel.
  ///
  /// In es, this message translates to:
  /// **'Sucursal activa de la jornada'**
  String get dashboardBranchLabel;

  /// No description provided for @dashboardSelectBranchPrompt.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar sucursal asignada'**
  String get dashboardSelectBranchPrompt;

  /// No description provided for @dashboardChangeBranchBtn.
  ///
  /// In es, this message translates to:
  /// **'Sucursal'**
  String get dashboardChangeBranchBtn;

  /// No description provided for @dashboardReceptionCtaTitle.
  ///
  /// In es, this message translates to:
  /// **'Recepción de vehículos en patio'**
  String get dashboardReceptionCtaTitle;

  /// No description provided for @dashboardReceptionCtaBody.
  ///
  /// In es, this message translates to:
  /// **'Consulta por placa de rodaje o DNI/RUC, registra el odómetro, adjunta fotos de ingreso y genera la proforma digital.'**
  String get dashboardReceptionCtaBody;

  /// No description provided for @dashboardSearchPlateBtn.
  ///
  /// In es, this message translates to:
  /// **'Consultar placa'**
  String get dashboardSearchPlateBtn;

  /// No description provided for @dashboardKpiOrders.
  ///
  /// In es, this message translates to:
  /// **'Órdenes activas'**
  String get dashboardKpiOrders;

  /// No description provided for @dashboardKpiOrdersSub.
  ///
  /// In es, this message translates to:
  /// **'{p1} en proforma · {p2} en bahía'**
  String dashboardKpiOrdersSub(int p1, int p2);

  /// No description provided for @dashboardKpiDraftsChip.
  ///
  /// In es, this message translates to:
  /// **'{p1} proformas'**
  String dashboardKpiDraftsChip(int p1);

  /// No description provided for @dashboardKpiBays.
  ///
  /// In es, this message translates to:
  /// **'Bahías de trabajo'**
  String get dashboardKpiBays;

  /// No description provided for @dashboardKpiBaysSub.
  ///
  /// In es, this message translates to:
  /// **'{p1} bahías disponibles'**
  String dashboardKpiBaysSub(int p1);

  /// No description provided for @dashboardKpiCrm.
  ///
  /// In es, this message translates to:
  /// **'Clientes y vehículos'**
  String get dashboardKpiCrm;

  /// No description provided for @dashboardKpiCrmSub.
  ///
  /// In es, this message translates to:
  /// **'{p1} citas agendadas hoy'**
  String dashboardKpiCrmSub(int p1);

  /// No description provided for @dashboardKpiStock.
  ///
  /// In es, this message translates to:
  /// **'Alertas de stock'**
  String get dashboardKpiStock;

  /// No description provided for @dashboardKpiStockSub.
  ///
  /// In es, this message translates to:
  /// **'Repuestos bajo el mínimo'**
  String get dashboardKpiStockSub;

  /// No description provided for @dashboardKpiAttendance.
  ///
  /// In es, this message translates to:
  /// **'Personal en sede'**
  String get dashboardKpiAttendance;

  /// No description provided for @dashboardKpiAttendanceSub.
  ///
  /// In es, this message translates to:
  /// **'{p1} justificaciones pendientes'**
  String dashboardKpiAttendanceSub(int p1);

  /// No description provided for @dashboardKpiObd.
  ///
  /// In es, this message translates to:
  /// **'Escáneres OBD-II'**
  String get dashboardKpiObd;

  /// No description provided for @dashboardKpiObdSub.
  ///
  /// In es, this message translates to:
  /// **'Activos en inventario'**
  String get dashboardKpiObdSub;

  /// No description provided for @dashboardSectionDrafts.
  ///
  /// In es, this message translates to:
  /// **'Proformas pendientes de aprobación ({p1})'**
  String dashboardSectionDrafts(int p1);

  /// No description provided for @dashboardSectionInProgress.
  ///
  /// In es, this message translates to:
  /// **'En intervención técnica en bahía ({p1})'**
  String dashboardSectionInProgress(int p1);

  /// No description provided for @dashboardSeeAll.
  ///
  /// In es, this message translates to:
  /// **'Ver todas'**
  String get dashboardSeeAll;

  /// No description provided for @dashboardSeeBays.
  ///
  /// In es, this message translates to:
  /// **'Ver bahías'**
  String get dashboardSeeBays;

  /// No description provided for @dashboardWalkInBtn.
  ///
  /// In es, this message translates to:
  /// **'Registrar ingreso presencial'**
  String get dashboardWalkInBtn;

  /// No description provided for @dashboardOpenProformaBtn.
  ///
  /// In es, this message translates to:
  /// **'Abrir proforma'**
  String get dashboardOpenProformaBtn;

  /// No description provided for @dashboardManageOrderBtn.
  ///
  /// In es, this message translates to:
  /// **'Ver intervención'**
  String get dashboardManageOrderBtn;

  /// No description provided for @moreHubTitle.
  ///
  /// In es, this message translates to:
  /// **'Gestión del taller'**
  String get moreHubTitle;

  /// No description provided for @moreHubSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Todos los módulos operativos, administrativos y de sincronización de tu sede.'**
  String get moreHubSubtitle;

  /// No description provided for @moreSectionOperations.
  ///
  /// In es, this message translates to:
  /// **'Operaciones y recepción'**
  String get moreSectionOperations;

  /// No description provided for @moreItemBranchTitle.
  ///
  /// In es, this message translates to:
  /// **'Cambiar o confirmar sucursal'**
  String get moreItemBranchTitle;

  /// No description provided for @moreItemBranchSub.
  ///
  /// In es, this message translates to:
  /// **'Selecciona la sede asignada para tu jornada operativa'**
  String get moreItemBranchSub;

  /// No description provided for @moreItemReceptionTitle.
  ///
  /// In es, this message translates to:
  /// **'Recepción, clientes y vehículos'**
  String get moreItemReceptionTitle;

  /// No description provided for @moreItemReceptionSub.
  ///
  /// In es, this message translates to:
  /// **'Búsqueda por placa, cartera de clientes y padrón de vehículos'**
  String get moreItemReceptionSub;

  /// No description provided for @moreItemBaysSub.
  ///
  /// In es, this message translates to:
  /// **'Disponibilidad de bahías y asignación de órdenes en curso'**
  String get moreItemBaysSub;

  /// No description provided for @moreItemObdSub.
  ///
  /// In es, this message translates to:
  /// **'Consultar, registrar y actualizar el estado de los escáneres OBD-II'**
  String get moreItemObdSub;

  /// No description provided for @moreSectionInventoryHr.
  ///
  /// In es, this message translates to:
  /// **'Almacén y recursos humanos'**
  String get moreSectionInventoryHr;

  /// No description provided for @moreItemCatalogTitle.
  ///
  /// In es, this message translates to:
  /// **'Catálogo y lotes de repuestos'**
  String get moreItemCatalogTitle;

  /// No description provided for @moreItemCatalogSub.
  ///
  /// In es, this message translates to:
  /// **'Existencias por SKU, precios base y lotes FIFO'**
  String get moreItemCatalogSub;

  /// No description provided for @moreItemStockAlertsTitle.
  ///
  /// In es, this message translates to:
  /// **'Alertas de reposición'**
  String get moreItemStockAlertsTitle;

  /// No description provided for @moreItemStockAlertsSub.
  ///
  /// In es, this message translates to:
  /// **'Ítems en stock mínimo o agotados'**
  String get moreItemStockAlertsSub;

  /// No description provided for @moreItemPurchasesTitle.
  ///
  /// In es, this message translates to:
  /// **'Órdenes de compra'**
  String get moreItemPurchasesTitle;

  /// No description provided for @moreItemPurchasesSub.
  ///
  /// In es, this message translates to:
  /// **'Recepción de mercadería e ingreso al almacén'**
  String get moreItemPurchasesSub;

  /// No description provided for @moreItemValuationTitle.
  ///
  /// In es, this message translates to:
  /// **'Valorización de inventario'**
  String get moreItemValuationTitle;

  /// No description provided for @moreItemValuationSub.
  ///
  /// In es, this message translates to:
  /// **'Valor contable del stock en sede'**
  String get moreItemValuationSub;

  /// No description provided for @moreItemAttendanceSub.
  ///
  /// In es, this message translates to:
  /// **'Asistencia diaria del personal de sede, justificaciones y marcación propia'**
  String get moreItemAttendanceSub;

  /// No description provided for @moreSectionSystem.
  ///
  /// In es, this message translates to:
  /// **'Sistema, alertas y cuenta'**
  String get moreSectionSystem;

  /// No description provided for @moreItemNotificationsSub.
  ///
  /// In es, this message translates to:
  /// **'Bandeja de notificaciones push y alertas operativas'**
  String get moreItemNotificationsSub;

  /// No description provided for @moreItemSyncSub.
  ///
  /// In es, this message translates to:
  /// **'Cola de operaciones capturadas sin conexión y reintento manual'**
  String get moreItemSyncSub;

  /// No description provided for @moreItemProfileSub.
  ///
  /// In es, this message translates to:
  /// **'Datos de tu cuenta y cierre de sesión'**
  String get moreItemProfileSub;

  /// No description provided for @registerVehicleForExistingCustomer.
  ///
  /// In es, this message translates to:
  /// **'Propietario seleccionado: {p1} ({p2})'**
  String registerVehicleForExistingCustomer(String p1, String p2);

  /// No description provided for @employeeDashboardTitle.
  ///
  /// In es, this message translates to:
  /// **'Panel del colaborador'**
  String get employeeDashboardTitle;

  /// No description provided for @employeeShiftLabel.
  ///
  /// In es, this message translates to:
  /// **'Jornada laboral'**
  String get employeeShiftLabel;

  /// No description provided for @employeeShiftNotAssigned.
  ///
  /// In es, this message translates to:
  /// **'Sin turno asignado para hoy'**
  String get employeeShiftNotAssigned;

  /// No description provided for @employeeAttendanceStatusIn.
  ///
  /// In es, this message translates to:
  /// **'Jornada iniciada'**
  String get employeeAttendanceStatusIn;

  /// No description provided for @employeeAttendanceStatusOut.
  ///
  /// In es, this message translates to:
  /// **'Jornada finalizada'**
  String get employeeAttendanceStatusOut;

  /// No description provided for @employeeAttendanceStatusPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente de ingreso'**
  String get employeeAttendanceStatusPending;

  /// No description provided for @employeeClockInBtn.
  ///
  /// In es, this message translates to:
  /// **'Marcar ingreso'**
  String get employeeClockInBtn;

  /// No description provided for @employeeClockOutBtn.
  ///
  /// In es, this message translates to:
  /// **'Marcar salida'**
  String get employeeClockOutBtn;

  /// No description provided for @employeeActiveTaskSection.
  ///
  /// In es, this message translates to:
  /// **'Tarea en curso'**
  String get employeeActiveTaskSection;

  /// No description provided for @employeeNoActiveTask.
  ///
  /// In es, this message translates to:
  /// **'Sin labor activa en curso'**
  String get employeeNoActiveTask;

  /// No description provided for @employeeNoActiveTaskSub.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una tarea de tu lista para iniciar el cronómetro de patio'**
  String get employeeNoActiveTaskSub;

  /// No description provided for @employeeSeeAllTasks.
  ///
  /// In es, this message translates to:
  /// **'Ver mis tareas'**
  String get employeeSeeAllTasks;

  /// No description provided for @employeeKpiCompletedToday.
  ///
  /// In es, this message translates to:
  /// **'Completadas hoy'**
  String get employeeKpiCompletedToday;

  /// No description provided for @employeeKpiPendingTasks.
  ///
  /// In es, this message translates to:
  /// **'Por realizar'**
  String get employeeKpiPendingTasks;

  /// No description provided for @employeeKpiTotalTasks.
  ///
  /// In es, this message translates to:
  /// **'Asignadas'**
  String get employeeKpiTotalTasks;

  /// No description provided for @employeeQuickActions.
  ///
  /// In es, this message translates to:
  /// **'Operaciones de patio'**
  String get employeeQuickActions;

  /// No description provided for @employeeActionObd.
  ///
  /// In es, this message translates to:
  /// **'Escáneres OBD-II'**
  String get employeeActionObd;

  /// No description provided for @employeeActionReportFinding.
  ///
  /// In es, this message translates to:
  /// **'Reportar hallazgo'**
  String get employeeActionReportFinding;

  /// No description provided for @employeeActionViewStock.
  ///
  /// In es, this message translates to:
  /// **'Consultar repuestos'**
  String get employeeActionViewStock;

  /// No description provided for @employeeActionAttendanceDetails.
  ///
  /// In es, this message translates to:
  /// **'Ver registro de asistencia'**
  String get employeeActionAttendanceDetails;

  /// No description provided for @employeeClockOutConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Confirmar marcación de salida'**
  String get employeeClockOutConfirmTitle;

  /// No description provided for @employeeClockOutConfirmMsg.
  ///
  /// In es, this message translates to:
  /// **'¿Deseas registrar la salida de tu jornada laboral ahora?'**
  String get employeeClockOutConfirmMsg;

  /// No description provided for @employeeFindingNoOrdersTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin órdenes asignadas'**
  String get employeeFindingNoOrdersTitle;

  /// No description provided for @employeeFindingNoOrdersMessage.
  ///
  /// In es, this message translates to:
  /// **'No tienes tareas asignadas a ninguna orden de trabajo en este momento. Solo puedes reportar hallazgos técnicos en las órdenes donde tengas una tarea asignada.'**
  String get employeeFindingNoOrdersMessage;

  /// No description provided for @employeeFindingSelectOrderTitle.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar orden de trabajo'**
  String get employeeFindingSelectOrderTitle;

  /// No description provided for @employeeFindingSelectOrderSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Selecciona la orden donde detectaste el hallazgo técnico:'**
  String get employeeFindingSelectOrderSubtitle;

  /// No description provided for @employeeDialogUnderstood.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get employeeDialogUnderstood;

  /// No description provided for @todayCars.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{{count} auto} other{{count} autos}}'**
  String todayCars(int count);

  /// No description provided for @todayCaption.
  ///
  /// In es, this message translates to:
  /// **'en el taller hoy'**
  String get todayCaption;

  /// No description provided for @todayContext.
  ///
  /// In es, this message translates to:
  /// **'{p1} · {p2}'**
  String todayContext(String p1, String p2);

  /// No description provided for @todayFigureInBay.
  ///
  /// In es, this message translates to:
  /// **'en bahía'**
  String get todayFigureInBay;

  /// No description provided for @todayFigureReady.
  ///
  /// In es, this message translates to:
  /// **'listos para entregar'**
  String get todayFigureReady;

  /// No description provided for @todayFigureOnShift.
  ///
  /// In es, this message translates to:
  /// **'en turno'**
  String get todayFigureOnShift;

  /// No description provided for @todayDecisions.
  ///
  /// In es, this message translates to:
  /// **'Esperan tu decisión'**
  String get todayDecisions;

  /// No description provided for @todayOpenOrders.
  ///
  /// In es, this message translates to:
  /// **'Órdenes abiertas'**
  String get todayOpenOrders;

  /// No description provided for @todaySeeAll.
  ///
  /// In es, this message translates to:
  /// **'Ver todas'**
  String get todaySeeAll;

  /// No description provided for @todayReceiveVehicle.
  ///
  /// In es, this message translates to:
  /// **'Recibir vehículo'**
  String get todayReceiveVehicle;

  /// No description provided for @todayOrdersEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay órdenes abiertas en esta sede.'**
  String get todayOrdersEmpty;

  /// No description provided for @todayOrdersNoPermission.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta no puede ver las órdenes de la sede.'**
  String get todayOrdersNoPermission;

  /// No description provided for @todayOfflineCache.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Ves lo último que se guardó en este teléfono.'**
  String get todayOfflineCache;

  /// No description provided for @todayOrderNumber.
  ///
  /// In es, this message translates to:
  /// **'Orden #{p1}'**
  String todayOrderNumber(int p1);

  /// No description provided for @todayOrderNoNumber.
  ///
  /// In es, this message translates to:
  /// **'Orden sin número'**
  String get todayOrderNoNumber;

  /// No description provided for @todayDecisionDraft.
  ///
  /// In es, this message translates to:
  /// **'Orden sin iniciar'**
  String get todayDecisionDraft;

  /// No description provided for @todayDecisionJustification.
  ///
  /// In es, this message translates to:
  /// **'Descargo de asistencia'**
  String get todayDecisionJustification;

  /// No description provided for @todayDecisionJustificationLate.
  ///
  /// In es, this message translates to:
  /// **'Descargo por tardanza'**
  String get todayDecisionJustificationLate;

  /// No description provided for @todayDecisionJustificationAbsent.
  ///
  /// In es, this message translates to:
  /// **'Descargo por falta'**
  String get todayDecisionJustificationAbsent;

  /// No description provided for @todayCollaboratorFallback.
  ///
  /// In es, this message translates to:
  /// **'Colaborador'**
  String get todayCollaboratorFallback;

  /// No description provided for @todayJustificationApprove.
  ///
  /// In es, this message translates to:
  /// **'Aprobar descargo'**
  String get todayJustificationApprove;

  /// No description provided for @todayJustificationReject.
  ///
  /// In es, this message translates to:
  /// **'Rechazar descargo'**
  String get todayJustificationReject;

  /// No description provided for @todayJustificationApproved.
  ///
  /// In es, this message translates to:
  /// **'Aprobado'**
  String get todayJustificationApproved;

  /// No description provided for @todayJustificationRejected.
  ///
  /// In es, this message translates to:
  /// **'Rechazado'**
  String get todayJustificationRejected;

  /// No description provided for @todayJustificationNoReason.
  ///
  /// In es, this message translates to:
  /// **'Sin motivo escrito.'**
  String get todayJustificationNoReason;

  /// No description provided for @todayJustificationNoPermission.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta no puede aprobar ni rechazar descargos.'**
  String get todayJustificationNoPermission;

  /// No description provided for @todayJustificationsPartial.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{No se pudo consultar {count} día de descargos. Desliza para reintentar.} other{No se pudieron consultar {count} días de descargos. Desliza para reintentar.}}'**
  String todayJustificationsPartial(int count);

  /// No description provided for @todayDecisionSuspension.
  ///
  /// In es, this message translates to:
  /// **'Suspensión por pieza defectuosa'**
  String get todayDecisionSuspension;

  /// No description provided for @ordersPendingSuspensionChip.
  ///
  /// In es, this message translates to:
  /// **'Suspensión por revisar'**
  String get ordersPendingSuspensionChip;

  /// No description provided for @syncTypeSubmitProposal.
  ///
  /// In es, this message translates to:
  /// **'Propuesta de hallazgo técnico'**
  String get syncTypeSubmitProposal;

  /// No description provided for @authDevicePendingBanner.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{Hay {count} operación pendiente en este teléfono. Se sincronizará cuando la cuenta correspondiente inicie sesión.} other{Hay {count} operaciones pendientes en este teléfono. Se sincronizarán cuando la cuenta correspondiente inicie sesión.}}'**
  String authDevicePendingBanner(int count);

  /// No description provided for @authDeeplinkSignedInWarning.
  ///
  /// In es, this message translates to:
  /// **'Cierra sesión para usar este enlace.'**
  String get authDeeplinkSignedInWarning;

  /// No description provided for @commonDiscardChangesTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Descartar cambios?'**
  String get commonDiscardChangesTitle;

  /// No description provided for @commonDiscardChangesBody.
  ///
  /// In es, this message translates to:
  /// **'Si sales ahora se perderán los datos escritos en este formulario.'**
  String get commonDiscardChangesBody;

  /// No description provided for @commonKeepEditing.
  ///
  /// In es, this message translates to:
  /// **'Seguir editando'**
  String get commonKeepEditing;

  /// No description provided for @commonDiscardAction.
  ///
  /// In es, this message translates to:
  /// **'Descartar'**
  String get commonDiscardAction;

  /// No description provided for @commonConfirm.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get commonConfirm;

  /// No description provided for @cashierMethodCash.
  ///
  /// In es, this message translates to:
  /// **'Efectivo'**
  String get cashierMethodCash;

  /// No description provided for @cashierMethodCreditCard.
  ///
  /// In es, this message translates to:
  /// **'Tarjeta de crédito'**
  String get cashierMethodCreditCard;

  /// No description provided for @cashierMethodDebitCard.
  ///
  /// In es, this message translates to:
  /// **'Tarjeta de débito'**
  String get cashierMethodDebitCard;

  /// No description provided for @cashierMethodBankTransfer.
  ///
  /// In es, this message translates to:
  /// **'Transferencia'**
  String get cashierMethodBankTransfer;

  /// No description provided for @cashierMethodYape.
  ///
  /// In es, this message translates to:
  /// **'Yape'**
  String get cashierMethodYape;

  /// No description provided for @cashierMethodPlin.
  ///
  /// In es, this message translates to:
  /// **'Plin'**
  String get cashierMethodPlin;

  /// No description provided for @cashierMethodUnknown.
  ///
  /// In es, this message translates to:
  /// **'Otro medio'**
  String get cashierMethodUnknown;

  /// No description provided for @cashierTypeFactura.
  ///
  /// In es, this message translates to:
  /// **'Factura'**
  String get cashierTypeFactura;

  /// No description provided for @cashierTypeBoleta.
  ///
  /// In es, this message translates to:
  /// **'Boleta'**
  String get cashierTypeBoleta;

  /// No description provided for @cashierTypeCreditNote.
  ///
  /// In es, this message translates to:
  /// **'Nota de crédito'**
  String get cashierTypeCreditNote;

  /// No description provided for @cashierTypeUnknown.
  ///
  /// In es, this message translates to:
  /// **'Comprobante'**
  String get cashierTypeUnknown;

  /// No description provided for @cashierDocRuc.
  ///
  /// In es, this message translates to:
  /// **'RUC'**
  String get cashierDocRuc;

  /// No description provided for @cashierDocDni.
  ///
  /// In es, this message translates to:
  /// **'DNI'**
  String get cashierDocDni;

  /// No description provided for @cashierDocCe.
  ///
  /// In es, this message translates to:
  /// **'CE'**
  String get cashierDocCe;

  /// No description provided for @cashierDocPassport.
  ///
  /// In es, this message translates to:
  /// **'Pasaporte'**
  String get cashierDocPassport;

  /// No description provided for @cashierVstatusDraft.
  ///
  /// In es, this message translates to:
  /// **'Borrador'**
  String get cashierVstatusDraft;

  /// No description provided for @cashierVstatusIssued.
  ///
  /// In es, this message translates to:
  /// **'Emitido'**
  String get cashierVstatusIssued;

  /// No description provided for @cashierVstatusAccepted.
  ///
  /// In es, this message translates to:
  /// **'Aceptado por SUNAT'**
  String get cashierVstatusAccepted;

  /// No description provided for @cashierVstatusRejected.
  ///
  /// In es, this message translates to:
  /// **'Rechazado por SUNAT'**
  String get cashierVstatusRejected;

  /// No description provided for @cashierVstatusVoided.
  ///
  /// In es, this message translates to:
  /// **'Anulado'**
  String get cashierVstatusVoided;

  /// No description provided for @cashierVstatusUnknown.
  ///
  /// In es, this message translates to:
  /// **'Sin estado'**
  String get cashierVstatusUnknown;

  /// No description provided for @cashierPstatusPending.
  ///
  /// In es, this message translates to:
  /// **'Sin cobrar'**
  String get cashierPstatusPending;

  /// No description provided for @cashierPstatusPartial.
  ///
  /// In es, this message translates to:
  /// **'Cobro parcial'**
  String get cashierPstatusPartial;

  /// No description provided for @cashierPstatusPaid.
  ///
  /// In es, this message translates to:
  /// **'Pagado'**
  String get cashierPstatusPaid;

  /// No description provided for @cashierSubtotal.
  ///
  /// In es, this message translates to:
  /// **'Subtotal'**
  String get cashierSubtotal;

  /// No description provided for @cashierIgv.
  ///
  /// In es, this message translates to:
  /// **'IGV ({p1} %)'**
  String cashierIgv(int p1);

  /// No description provided for @cashierTotal.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get cashierTotal;

  /// No description provided for @cashierCollected.
  ///
  /// In es, this message translates to:
  /// **'Cobrado'**
  String get cashierCollected;

  /// No description provided for @cashierBalance.
  ///
  /// In es, this message translates to:
  /// **'Saldo'**
  String get cashierBalance;

  /// No description provided for @cashierVoucherName.
  ///
  /// In es, this message translates to:
  /// **'{p1} {p2}'**
  String cashierVoucherName(String p1, String p2);

  /// No description provided for @cashierErrLines.
  ///
  /// In es, this message translates to:
  /// **'Falta el nombre de alguna línea del comprobante.'**
  String get cashierErrLines;

  /// No description provided for @cashierErrTaxId.
  ///
  /// In es, this message translates to:
  /// **'Revisa el documento del cliente: la factura pide un RUC de 11 dígitos.'**
  String get cashierErrTaxId;

  /// No description provided for @cashierErrSerie.
  ///
  /// In es, this message translates to:
  /// **'La serie debe tener 4 caracteres: la factura empieza con F y la boleta con B.'**
  String get cashierErrSerie;

  /// No description provided for @cashierErrInitial.
  ///
  /// In es, this message translates to:
  /// **'El correlativo inicial no puede ser negativo.'**
  String get cashierErrInitial;

  /// No description provided for @cashierErrAmount.
  ///
  /// In es, this message translates to:
  /// **'El monto debe ser de al menos 0.01, con dos decimales como máximo, y no superar el saldo.'**
  String get cashierErrAmount;

  /// No description provided for @cashierErrReference.
  ///
  /// In es, this message translates to:
  /// **'La referencia admite hasta 100 caracteres.'**
  String get cashierErrReference;

  /// No description provided for @cashierErrStatus.
  ///
  /// In es, this message translates to:
  /// **'Este comprobante ya no admite cobros.'**
  String get cashierErrStatus;

  /// No description provided for @cashierErrInput.
  ///
  /// In es, this message translates to:
  /// **'Revisa los datos ingresados.'**
  String get cashierErrInput;

  /// No description provided for @cashierErrNoSeries.
  ///
  /// In es, this message translates to:
  /// **'La sede no tiene una serie activa para este tipo de comprobante. Actívala en Series de facturación.'**
  String get cashierErrNoSeries;

  /// No description provided for @cashierErrOutcomeUnknown.
  ///
  /// In es, this message translates to:
  /// **'No sabemos si el cobro se registró. Revisa los pagos del comprobante antes de volver a cobrar.'**
  String get cashierErrOutcomeUnknown;

  /// No description provided for @cashierErrNoBranch.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta no tiene sede asignada. Pide a un administrador que te asigne una.'**
  String get cashierErrNoBranch;

  /// No description provided for @cashierErrLegalName.
  ///
  /// In es, this message translates to:
  /// **'Ingresa la razón social o nombre completo del receptor.'**
  String get cashierErrLegalName;

  /// No description provided for @cashierErrTenantName.
  ///
  /// In es, this message translates to:
  /// **'Ingresa la razón social o nombre comercial del taller.'**
  String get cashierErrTenantName;

  /// No description provided for @cashierCheckoutTitle.
  ///
  /// In es, this message translates to:
  /// **'Cobrar y entregar'**
  String get cashierCheckoutTitle;

  /// No description provided for @cashierCheckoutNoAccess.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta no tiene acceso a cobros ni a entregas.'**
  String get cashierCheckoutNoAccess;

  /// No description provided for @cashierOrderNumber.
  ///
  /// In es, this message translates to:
  /// **'Orden {p1}'**
  String cashierOrderNumber(int p1);

  /// No description provided for @cashierStepTitle.
  ///
  /// In es, this message translates to:
  /// **'{p1}. {p2}'**
  String cashierStepTitle(int p1, String p2);

  /// No description provided for @cashierStepVoucher.
  ///
  /// In es, this message translates to:
  /// **'Comprobante'**
  String get cashierStepVoucher;

  /// No description provided for @cashierStepPayments.
  ///
  /// In es, this message translates to:
  /// **'Cobros'**
  String get cashierStepPayments;

  /// No description provided for @cashierStepExitPass.
  ///
  /// In es, this message translates to:
  /// **'Pase de salida'**
  String get cashierStepExitPass;

  /// No description provided for @cashierStepDelivery.
  ///
  /// In es, this message translates to:
  /// **'Entrega'**
  String get cashierStepDelivery;

  /// No description provided for @cashierVoucherPrepare.
  ///
  /// In es, this message translates to:
  /// **'Preparar comprobante'**
  String get cashierVoucherPrepare;

  /// No description provided for @cashierVoucherEmpty.
  ///
  /// In es, this message translates to:
  /// **'Esta orden aún no tiene comprobante.'**
  String get cashierVoucherEmpty;

  /// No description provided for @cashierVoucherNeedsCompleted.
  ///
  /// In es, this message translates to:
  /// **'La orden debe estar completada para emitir el comprobante.'**
  String get cashierVoucherNeedsCompleted;

  /// No description provided for @cashierIssueTitle.
  ///
  /// In es, this message translates to:
  /// **'Emitir comprobante'**
  String get cashierIssueTitle;

  /// No description provided for @cashierIssueType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de comprobante'**
  String get cashierIssueType;

  /// No description provided for @cashierIssueDocument.
  ///
  /// In es, this message translates to:
  /// **'Documento del cliente'**
  String get cashierIssueDocument;

  /// No description provided for @cashierIssueDocumentNumber.
  ///
  /// In es, this message translates to:
  /// **'Número de documento'**
  String get cashierIssueDocumentNumber;

  /// No description provided for @cashierIssueNameCompany.
  ///
  /// In es, this message translates to:
  /// **'Razón social'**
  String get cashierIssueNameCompany;

  /// No description provided for @cashierIssueNamePerson.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get cashierIssueNamePerson;

  /// No description provided for @cashierIssueAddress.
  ///
  /// In es, this message translates to:
  /// **'Dirección fiscal'**
  String get cashierIssueAddress;

  /// No description provided for @cashierIssueLines.
  ///
  /// In es, this message translates to:
  /// **'Detalle'**
  String get cashierIssueLines;

  /// No description provided for @cashierIssueLineName.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la línea'**
  String get cashierIssueLineName;

  /// No description provided for @cashierIssueLineNeedsName.
  ///
  /// In es, this message translates to:
  /// **'Escribe qué se cobra en esta línea.'**
  String get cashierIssueLineNeedsName;

  /// No description provided for @cashierIssueLineDetail.
  ///
  /// In es, this message translates to:
  /// **'{p1} × {p2}'**
  String cashierIssueLineDetail(String p1, String p2);

  /// No description provided for @cashierIssueDocumentError.
  ///
  /// In es, this message translates to:
  /// **'Revisa el número de documento.'**
  String get cashierIssueDocumentError;

  /// No description provided for @cashierIssueNameError.
  ///
  /// In es, this message translates to:
  /// **'Falta el nombre del cliente.'**
  String get cashierIssueNameError;

  /// No description provided for @cashierIssueIrreversible.
  ///
  /// In es, this message translates to:
  /// **'Al emitir, el comprobante se envía a SUNAT y no se puede deshacer.'**
  String get cashierIssueIrreversible;

  /// No description provided for @cashierIssueConfirm.
  ///
  /// In es, this message translates to:
  /// **'Emitir {p1} por {p2}'**
  String cashierIssueConfirm(String p1, String p2);

  /// No description provided for @cashierIssueDone.
  ///
  /// In es, this message translates to:
  /// **'Comprobante emitido.'**
  String get cashierIssueDone;

  /// No description provided for @cashierIssueAlready.
  ///
  /// In es, this message translates to:
  /// **'La orden ya tenía un comprobante vigente; no se emitió otro.'**
  String get cashierIssueAlready;

  /// No description provided for @cashierIssueDetailsPending.
  ///
  /// In es, this message translates to:
  /// **'El comprobante se emitió. Falta leer su detalle: actualiza en un momento.'**
  String get cashierIssueDetailsPending;

  /// No description provided for @cashierPaymentsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay cobros de este comprobante.'**
  String get cashierPaymentsEmpty;

  /// No description provided for @cashierPaymentsNeedsVoucher.
  ///
  /// In es, this message translates to:
  /// **'Emite el comprobante para poder cobrar.'**
  String get cashierPaymentsNeedsVoucher;

  /// No description provided for @cashierPaymentRegister.
  ///
  /// In es, this message translates to:
  /// **'Registrar cobro'**
  String get cashierPaymentRegister;

  /// No description provided for @cashierPaymentTitle.
  ///
  /// In es, this message translates to:
  /// **'Registrar cobro'**
  String get cashierPaymentTitle;

  /// No description provided for @cashierPaymentAmount.
  ///
  /// In es, this message translates to:
  /// **'Monto a cobrar'**
  String get cashierPaymentAmount;

  /// No description provided for @cashierPaymentAmountError.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un monto válido, hasta el saldo.'**
  String get cashierPaymentAmountError;

  /// No description provided for @cashierPaymentMethod.
  ///
  /// In es, this message translates to:
  /// **'Medio de pago'**
  String get cashierPaymentMethod;

  /// No description provided for @cashierPaymentReference.
  ///
  /// In es, this message translates to:
  /// **'Referencia de la operación'**
  String get cashierPaymentReference;

  /// No description provided for @cashierPaymentReferenceHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. nro. de operación o voucher'**
  String get cashierPaymentReferenceHint;

  /// No description provided for @cashierPaymentReferenceRequired.
  ///
  /// In es, this message translates to:
  /// **'Obligatoria para pagos que no son en efectivo.'**
  String get cashierPaymentReferenceRequired;

  /// No description provided for @cashierPaymentIrreversible.
  ///
  /// In es, this message translates to:
  /// **'El cobro queda registrado y no se puede deshacer.'**
  String get cashierPaymentIrreversible;

  /// No description provided for @cashierPaymentConfirm.
  ///
  /// In es, this message translates to:
  /// **'Cobrar {p1}'**
  String cashierPaymentConfirm(String p1);

  /// No description provided for @cashierPaymentDone.
  ///
  /// In es, this message translates to:
  /// **'Cobro registrado.'**
  String get cashierPaymentDone;

  /// No description provided for @cashierPaymentTime.
  ///
  /// In es, this message translates to:
  /// **'{p1} · {p2}'**
  String cashierPaymentTime(String p1, String p2);

  /// No description provided for @cashierMarkPaid.
  ///
  /// In es, this message translates to:
  /// **'Marcar orden como pagada'**
  String get cashierMarkPaid;

  /// No description provided for @cashierMarkPaidDone.
  ///
  /// In es, this message translates to:
  /// **'La orden quedó pagada.'**
  String get cashierMarkPaidDone;

  /// No description provided for @cashierExitPassDownload.
  ///
  /// In es, this message translates to:
  /// **'Descargar pase de salida'**
  String get cashierExitPassDownload;

  /// No description provided for @cashierExitPassNeedsPaid.
  ///
  /// In es, this message translates to:
  /// **'Disponible cuando la orden esté pagada.'**
  String get cashierExitPassNeedsPaid;

  /// No description provided for @cashierExitPassChooser.
  ///
  /// In es, this message translates to:
  /// **'Compartir pase de salida'**
  String get cashierExitPassChooser;

  /// No description provided for @cashierExitPassNoApp.
  ///
  /// In es, this message translates to:
  /// **'No hay una app para abrir el PDF.'**
  String get cashierExitPassNoApp;

  /// No description provided for @cashierDeliverAction.
  ///
  /// In es, this message translates to:
  /// **'Entregar vehículo'**
  String get cashierDeliverAction;

  /// No description provided for @cashierDeliverTitle.
  ///
  /// In es, this message translates to:
  /// **'Entregar vehículo'**
  String get cashierDeliverTitle;

  /// No description provided for @cashierDeliverBody.
  ///
  /// In es, this message translates to:
  /// **'Confirma que el cliente se lleva el vehículo. La bahía se libera y no se puede deshacer.'**
  String get cashierDeliverBody;

  /// No description provided for @cashierDeliverConfirm.
  ///
  /// In es, this message translates to:
  /// **'Entregar'**
  String get cashierDeliverConfirm;

  /// No description provided for @cashierDeliverNeedsPaid.
  ///
  /// In es, this message translates to:
  /// **'Disponible cuando la orden esté pagada.'**
  String get cashierDeliverNeedsPaid;

  /// No description provided for @cashierDeliverDone.
  ///
  /// In es, this message translates to:
  /// **'Vehículo entregado.'**
  String get cashierDeliverDone;

  /// No description provided for @cashierDelivered.
  ///
  /// In es, this message translates to:
  /// **'Entregado'**
  String get cashierDelivered;

  /// No description provided for @cashierDailyTitle.
  ///
  /// In es, this message translates to:
  /// **'Caja del día'**
  String get cashierDailyTitle;

  /// No description provided for @cashierDailyContext.
  ///
  /// In es, this message translates to:
  /// **'Caja de la sede · {p1}'**
  String cashierDailyContext(String p1);

  /// No description provided for @cashierDailyCaption.
  ///
  /// In es, this message translates to:
  /// **'cobrado'**
  String get cashierDailyCaption;

  /// No description provided for @cashierDailyPayments.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{cobro} other{cobros}}'**
  String cashierDailyPayments(int count);

  /// No description provided for @cashierDailyByMethod.
  ///
  /// In es, this message translates to:
  /// **'Por medio de pago'**
  String get cashierDailyByMethod;

  /// No description provided for @cashierDailyPaymentsHeader.
  ///
  /// In es, this message translates to:
  /// **'Cobros'**
  String get cashierDailyPaymentsHeader;

  /// No description provided for @cashierDailyEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay cobros registrados este día.'**
  String get cashierDailyEmpty;

  /// No description provided for @cashierDailyPrevious.
  ///
  /// In es, this message translates to:
  /// **'Día anterior'**
  String get cashierDailyPrevious;

  /// No description provided for @cashierDailyNext.
  ///
  /// In es, this message translates to:
  /// **'Día siguiente'**
  String get cashierDailyNext;

  /// No description provided for @cashierDailyToday.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get cashierDailyToday;

  /// No description provided for @cashierDailyNoAccess.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta no puede ver la caja del día.'**
  String get cashierDailyNoAccess;

  /// No description provided for @cashierSeriesTitle.
  ///
  /// In es, this message translates to:
  /// **'Series de facturación'**
  String get cashierSeriesTitle;

  /// No description provided for @cashierSeriesHint.
  ///
  /// In es, this message translates to:
  /// **'Series de la sede para emitir facturas y boletas electrónicas.'**
  String get cashierSeriesHint;

  /// No description provided for @cashierSeriesEmpty.
  ///
  /// In es, this message translates to:
  /// **'La sede aún no tiene series. Agrega una para poder emitir comprobantes.'**
  String get cashierSeriesEmpty;

  /// No description provided for @cashierSeriesAdd.
  ///
  /// In es, this message translates to:
  /// **'Agregar serie'**
  String get cashierSeriesAdd;

  /// No description provided for @cashierSeriesCorrelative.
  ///
  /// In es, this message translates to:
  /// **'Último número: {p1}'**
  String cashierSeriesCorrelative(int p1);

  /// No description provided for @cashierSeriesActive.
  ///
  /// In es, this message translates to:
  /// **'Activa'**
  String get cashierSeriesActive;

  /// No description provided for @cashierSeriesInactive.
  ///
  /// In es, this message translates to:
  /// **'Inactiva'**
  String get cashierSeriesInactive;

  /// No description provided for @cashierSeriesNewTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva serie'**
  String get cashierSeriesNewTitle;

  /// No description provided for @cashierSeriesType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de comprobante'**
  String get cashierSeriesType;

  /// No description provided for @cashierSeriesSerie.
  ///
  /// In es, this message translates to:
  /// **'Serie (4 caracteres)'**
  String get cashierSeriesSerie;

  /// No description provided for @cashierSeriesSerieError.
  ///
  /// In es, this message translates to:
  /// **'Factura: F y 3 caracteres. Boleta: B y 3 caracteres.'**
  String get cashierSeriesSerieError;

  /// No description provided for @cashierSeriesInitial.
  ///
  /// In es, this message translates to:
  /// **'Correlativo inicial (opcional)'**
  String get cashierSeriesInitial;

  /// No description provided for @cashierSeriesInitialError.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un número entero.'**
  String get cashierSeriesInitialError;

  /// No description provided for @cashierSeriesSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar serie'**
  String get cashierSeriesSave;

  /// No description provided for @cashierSeriesSaved.
  ///
  /// In es, this message translates to:
  /// **'Serie guardada.'**
  String get cashierSeriesSaved;

  /// No description provided for @cashierSeriesDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Serie {p1}'**
  String cashierSeriesDetailTitle(String p1);

  /// No description provided for @cashierSeriesDeactivate.
  ///
  /// In es, this message translates to:
  /// **'Desactivar serie'**
  String get cashierSeriesDeactivate;

  /// No description provided for @cashierSeriesActivate.
  ///
  /// In es, this message translates to:
  /// **'Activar serie'**
  String get cashierSeriesActivate;

  /// No description provided for @cashierSeriesDeactivateBody.
  ///
  /// In es, this message translates to:
  /// **'Mientras esté inactiva, la sede no podrá emitir con esta serie.'**
  String get cashierSeriesDeactivateBody;

  /// No description provided for @cashierSeriesActivateBody.
  ///
  /// In es, this message translates to:
  /// **'La sede volverá a emitir con esta serie.'**
  String get cashierSeriesActivateBody;

  /// No description provided for @cashierSeriesUpdated.
  ///
  /// In es, this message translates to:
  /// **'Serie actualizada.'**
  String get cashierSeriesUpdated;

  /// No description provided for @cashierSeriesNoAccess.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta no puede configurar series de facturación.'**
  String get cashierSeriesNoAccess;

  /// No description provided for @cashierSunatStatusAcceptedNotice.
  ///
  /// In es, this message translates to:
  /// **'Comprobante aceptado por SUNAT.'**
  String get cashierSunatStatusAcceptedNotice;

  /// No description provided for @cashierSunatStatusRejectedNotice.
  ///
  /// In es, this message translates to:
  /// **'Comprobante rechazado por SUNAT.'**
  String get cashierSunatStatusRejectedNotice;

  /// No description provided for @cashierSunatStatusPendingPseNotice.
  ///
  /// In es, this message translates to:
  /// **'Comprobante emitido y válido para cobro. El PSE del servidor opera en modo simulado y mantiene el estado Emitido sin constancia CDR.'**
  String get cashierSunatStatusPendingPseNotice;

  /// No description provided for @reportsTitle.
  ///
  /// In es, this message translates to:
  /// **'Reportes'**
  String get reportsTitle;

  /// No description provided for @reportsContext.
  ///
  /// In es, this message translates to:
  /// **'Reporte del taller'**
  String get reportsContext;

  /// No description provided for @reportsScopeNote.
  ///
  /// In es, this message translates to:
  /// **'El reporte suma todas las sedes del taller, no solo la tuya.'**
  String get reportsScopeNote;

  /// No description provided for @reportsLegendCaption.
  ///
  /// In es, this message translates to:
  /// **'cobrado en el periodo'**
  String get reportsLegendCaption;

  /// No description provided for @reportsPeriodMonth.
  ///
  /// In es, this message translates to:
  /// **'Este mes'**
  String get reportsPeriodMonth;

  /// No description provided for @reportsPeriodPreviousMonth.
  ///
  /// In es, this message translates to:
  /// **'Mes pasado'**
  String get reportsPeriodPreviousMonth;

  /// No description provided for @reportsPeriodYear.
  ///
  /// In es, this message translates to:
  /// **'Este año'**
  String get reportsPeriodYear;

  /// No description provided for @reportsPeriodRange.
  ///
  /// In es, this message translates to:
  /// **'{p1} al {p2}'**
  String reportsPeriodRange(String p1, String p2);

  /// No description provided for @reportsMovementsLabel.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{movimiento} other{movimientos}}'**
  String reportsMovementsLabel(int count);

  /// No description provided for @reportsMovementsHeader.
  ///
  /// In es, this message translates to:
  /// **'Movimientos'**
  String get reportsMovementsHeader;

  /// No description provided for @reportsMovementsEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay movimientos en este periodo.'**
  String get reportsMovementsEmpty;

  /// No description provided for @reportsMovementDetail.
  ///
  /// In es, this message translates to:
  /// **'{p1} · {p2}'**
  String reportsMovementDetail(String p1, String p2);

  /// No description provided for @reportsDownloadsHeader.
  ///
  /// In es, this message translates to:
  /// **'Descargas'**
  String get reportsDownloadsHeader;

  /// No description provided for @reportsDownloadCashflow.
  ///
  /// In es, this message translates to:
  /// **'Descargar PDF de flujo de caja'**
  String get reportsDownloadCashflow;

  /// No description provided for @reportsDownloadFleet.
  ///
  /// In es, this message translates to:
  /// **'PDF de salud de flota'**
  String get reportsDownloadFleet;

  /// No description provided for @reportsPdfChooser.
  ///
  /// In es, this message translates to:
  /// **'Compartir reporte'**
  String get reportsPdfChooser;

  /// No description provided for @reportsPdfNoApp.
  ///
  /// In es, this message translates to:
  /// **'No hay una app para abrir el PDF.'**
  String get reportsPdfNoApp;

  /// No description provided for @reportsFleetLocked.
  ///
  /// In es, this message translates to:
  /// **'La salud de flota con IA no está incluida en el plan de tu taller.'**
  String get reportsFleetLocked;

  /// No description provided for @reportsFleetTitle.
  ///
  /// In es, this message translates to:
  /// **'Salud de flota'**
  String get reportsFleetTitle;

  /// No description provided for @reportsFleetHint.
  ///
  /// In es, this message translates to:
  /// **'Elige al cliente cuyo informe quieres descargar.'**
  String get reportsFleetHint;

  /// No description provided for @reportsFleetSearch.
  ///
  /// In es, this message translates to:
  /// **'Buscar cliente por nombre o documento'**
  String get reportsFleetSearch;

  /// No description provided for @reportsFleetSearchAction.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get reportsFleetSearchAction;

  /// No description provided for @reportsFleetEmpty.
  ///
  /// In es, this message translates to:
  /// **'No encontramos clientes con esa búsqueda.'**
  String get reportsFleetEmpty;

  /// No description provided for @reportsNoAccess.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta no tiene acceso a reportes.'**
  String get reportsNoAccess;

  /// No description provided for @reportsPeriodCustom.
  ///
  /// In es, this message translates to:
  /// **'Rango'**
  String get reportsPeriodCustom;

  /// No description provided for @reportsOpenPdf.
  ///
  /// In es, this message translates to:
  /// **'Abrir PDF'**
  String get reportsOpenPdf;

  /// No description provided for @reportsSharePdf.
  ///
  /// In es, this message translates to:
  /// **'Compartir PDF'**
  String get reportsSharePdf;

  /// No description provided for @reportsFleetScopeNote.
  ///
  /// In es, this message translates to:
  /// **'Incluye todos los vehículos registrados del cliente seleccionado.'**
  String get reportsFleetScopeNote;

  /// No description provided for @reportsH31IncomeOnlyNote.
  ///
  /// In es, this message translates to:
  /// **'Muestra únicamente los cobros confirmados del periodo; egresos y cuentas por cobrar no se contabilizan en este resumen.'**
  String get reportsH31IncomeOnlyNote;

  /// No description provided for @cashierErrReason.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un motivo válido de hasta 250 caracteres.'**
  String get cashierErrReason;

  /// No description provided for @cashierErrCustomer.
  ///
  /// In es, this message translates to:
  /// **'El comprobante no tiene un cliente asociado.'**
  String get cashierErrCustomer;

  /// No description provided for @cashierDailyVouchers.
  ///
  /// In es, this message translates to:
  /// **'Comprobantes SUNAT'**
  String get cashierDailyVouchers;

  /// No description provided for @cashierDailyVouchersSub.
  ///
  /// In es, this message translates to:
  /// **'Boletas, facturas, notas de crédito y anulaciones'**
  String get cashierDailyVouchersSub;

  /// No description provided for @cashierVouchersTitle.
  ///
  /// In es, this message translates to:
  /// **'Comprobantes SUNAT'**
  String get cashierVouchersTitle;

  /// No description provided for @cashierVouchersNoAccess.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta no puede consultar comprobantes emitidos.'**
  String get cashierVouchersNoAccess;

  /// No description provided for @cashierVouchersEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay comprobantes emitidos en esta sede.'**
  String get cashierVouchersEmpty;

  /// No description provided for @cashierVouchersEmptyFiltered.
  ///
  /// In es, this message translates to:
  /// **'No hay comprobantes con este filtro.'**
  String get cashierVouchersEmptyFiltered;

  /// No description provided for @cashierVouchersFilterAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get cashierVouchersFilterAll;

  /// No description provided for @cashierVouchersFilterAccepted.
  ///
  /// In es, this message translates to:
  /// **'Aceptados'**
  String get cashierVouchersFilterAccepted;

  /// No description provided for @cashierVouchersFilterBalance.
  ///
  /// In es, this message translates to:
  /// **'Con saldo'**
  String get cashierVouchersFilterBalance;

  /// No description provided for @cashierVouchersFilterVoided.
  ///
  /// In es, this message translates to:
  /// **'Anulados'**
  String get cashierVouchersFilterVoided;

  /// No description provided for @cashierVouchersFilterCreditNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas de crédito'**
  String get cashierVouchersFilterCreditNotes;

  /// No description provided for @cashierVouchersBalanceShort.
  ///
  /// In es, this message translates to:
  /// **'Saldo {p1}'**
  String cashierVouchersBalanceShort(String p1);

  /// No description provided for @cashierVouchersSunatLabel.
  ///
  /// In es, this message translates to:
  /// **'Estado SUNAT'**
  String get cashierVouchersSunatLabel;

  /// No description provided for @cashierVouchersCdrCode.
  ///
  /// In es, this message translates to:
  /// **'CDR {p1} · {p2}'**
  String cashierVouchersCdrCode(String p1, String p2);

  /// No description provided for @cashierVouchersCustomerLabel.
  ///
  /// In es, this message translates to:
  /// **'Cliente'**
  String get cashierVouchersCustomerLabel;

  /// No description provided for @cashierVouchersIssuedAt.
  ///
  /// In es, this message translates to:
  /// **'Emitido el {p1}'**
  String cashierVouchersIssuedAt(String p1);

  /// No description provided for @cashierVouchersLinesLabel.
  ///
  /// In es, this message translates to:
  /// **'Detalle del comprobante'**
  String get cashierVouchersLinesLabel;

  /// No description provided for @cashierVouchersClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get cashierVouchersClose;

  /// No description provided for @cashierVouchersNoActions.
  ///
  /// In es, this message translates to:
  /// **'Este comprobante no admite anulaciones ni notas de crédito.'**
  String get cashierVouchersNoActions;

  /// No description provided for @cashierVoidAction.
  ///
  /// In es, this message translates to:
  /// **'Anular comprobante'**
  String get cashierVoidAction;

  /// No description provided for @cashierVoidShort.
  ///
  /// In es, this message translates to:
  /// **'Anular'**
  String get cashierVoidShort;

  /// No description provided for @cashierVoidTitle.
  ///
  /// In es, this message translates to:
  /// **'Anular {p1}'**
  String cashierVoidTitle(String p1);

  /// No description provided for @cashierVoidBody.
  ///
  /// In es, this message translates to:
  /// **'Se enviará la comunicación de baja a SUNAT (disponible dentro de los 7 días calendario). Esta acción no se puede deshacer.'**
  String get cashierVoidBody;

  /// No description provided for @cashierVoidReasonLabel.
  ///
  /// In es, this message translates to:
  /// **'Motivo de anulación'**
  String get cashierVoidReasonLabel;

  /// No description provided for @cashierVoidReasonPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Ej. Error en datos fiscales del cliente'**
  String get cashierVoidReasonPlaceholder;

  /// No description provided for @cashierVoidReasonError.
  ///
  /// In es, this message translates to:
  /// **'Escribe el motivo (máximo 250 caracteres).'**
  String get cashierVoidReasonError;

  /// No description provided for @cashierVoidConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar anulación'**
  String get cashierVoidConfirm;

  /// No description provided for @cashierVoidDone.
  ///
  /// In es, this message translates to:
  /// **'Comprobante anulado.'**
  String get cashierVoidDone;

  /// No description provided for @cashierNcAction.
  ///
  /// In es, this message translates to:
  /// **'Emitir nota de crédito'**
  String get cashierNcAction;

  /// No description provided for @cashierNcShort.
  ///
  /// In es, this message translates to:
  /// **'Nota de crédito'**
  String get cashierNcShort;

  /// No description provided for @cashierNcTitle.
  ///
  /// In es, this message translates to:
  /// **'Emitir nota de crédito'**
  String get cashierNcTitle;

  /// No description provided for @cashierNcReference.
  ///
  /// In es, this message translates to:
  /// **'Comprobante de referencia: {p1}'**
  String cashierNcReference(String p1);

  /// No description provided for @cashierNcReasonLabel.
  ///
  /// In es, this message translates to:
  /// **'Motivo de la nota de crédito'**
  String get cashierNcReasonLabel;

  /// No description provided for @cashierNcReasonPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Ej. Descuento o devolución parcial'**
  String get cashierNcReasonPlaceholder;

  /// No description provided for @cashierNcReasonError.
  ///
  /// In es, this message translates to:
  /// **'Escribe el motivo (máximo 250 caracteres).'**
  String get cashierNcReasonError;

  /// No description provided for @cashierNcAmountLabel.
  ///
  /// In es, this message translates to:
  /// **'Monto de la nota de crédito'**
  String get cashierNcAmountLabel;

  /// No description provided for @cashierNcAmountError.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un monto válido, hasta el total del comprobante.'**
  String get cashierNcAmountError;

  /// No description provided for @cashierNcIrreversible.
  ///
  /// In es, this message translates to:
  /// **'La nota de crédito se enviará a SUNAT y no se puede deshacer.'**
  String get cashierNcIrreversible;

  /// No description provided for @cashierNcConfirm.
  ///
  /// In es, this message translates to:
  /// **'Emitir nota por {p1}'**
  String cashierNcConfirm(String p1);

  /// No description provided for @cashierNcDone.
  ///
  /// In es, this message translates to:
  /// **'Nota de crédito emitida.'**
  String get cashierNcDone;

  /// No description provided for @cashierNcSerieLabel.
  ///
  /// In es, this message translates to:
  /// **'Serie de nota de crédito'**
  String get cashierNcSerieLabel;

  /// No description provided for @cashierNcSerieError.
  ///
  /// In es, this message translates to:
  /// **'Serie de 4 caracteres acorde al comprobante (F para factura, B para boleta).'**
  String get cashierNcSerieError;

  /// No description provided for @cashierDocOpenPdf.
  ///
  /// In es, this message translates to:
  /// **'Abrir PDF'**
  String get cashierDocOpenPdf;

  /// No description provided for @cashierDocSharePdf.
  ///
  /// In es, this message translates to:
  /// **'Compartir PDF'**
  String get cashierDocSharePdf;

  /// No description provided for @cashierDocShareXml.
  ///
  /// In es, this message translates to:
  /// **'Compartir XML UBL 2.1'**
  String get cashierDocShareXml;

  /// No description provided for @cashierDocShareCdr.
  ///
  /// In es, this message translates to:
  /// **'Compartir CDR SUNAT'**
  String get cashierDocShareCdr;

  /// No description provided for @cashierSunatRefreshStatus.
  ///
  /// In es, this message translates to:
  /// **'Actualizar estado SUNAT'**
  String get cashierSunatRefreshStatus;

  /// No description provided for @cashierSunatRejectedReissueHint.
  ///
  /// In es, this message translates to:
  /// **'El comprobante fue rechazado por SUNAT. Puedes corregir los datos y volver a emitir.'**
  String get cashierSunatRejectedReissueHint;

  /// No description provided for @cashierExitPassOpen.
  ///
  /// In es, this message translates to:
  /// **'Abrir pase de salida'**
  String get cashierExitPassOpen;

  /// No description provided for @cashierExitPassShare.
  ///
  /// In es, this message translates to:
  /// **'Compartir pase de salida'**
  String get cashierExitPassShare;

  /// No description provided for @cashierCheckoutH26Note.
  ///
  /// In es, this message translates to:
  /// **'El total del comprobante incluye IGV sobre cada línea y define el saldo fiscal a cobrar.'**
  String get cashierCheckoutH26Note;

  /// No description provided for @cashierCheckoutProfitability.
  ///
  /// In es, this message translates to:
  /// **'Ver margen FIFO y rentabilidad'**
  String get cashierCheckoutProfitability;

  /// No description provided for @cashierFiscalTenantSection.
  ///
  /// In es, this message translates to:
  /// **'Información fiscal del taller'**
  String get cashierFiscalTenantSection;

  /// No description provided for @cashierFiscalTenantName.
  ///
  /// In es, this message translates to:
  /// **'Nombre comercial'**
  String get cashierFiscalTenantName;

  /// No description provided for @cashierFiscalTenantLegalName.
  ///
  /// In es, this message translates to:
  /// **'Razón social'**
  String get cashierFiscalTenantLegalName;

  /// No description provided for @cashierFiscalTenantRuc.
  ///
  /// In es, this message translates to:
  /// **'RUC del emisor (11 dígitos)'**
  String get cashierFiscalTenantRuc;

  /// No description provided for @cashierFiscalTenantEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar datos fiscales'**
  String get cashierFiscalTenantEdit;

  /// No description provided for @cashierFiscalTenantSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar datos fiscales'**
  String get cashierFiscalTenantSave;

  /// No description provided for @cashierFiscalTenantSaved.
  ///
  /// In es, this message translates to:
  /// **'Datos fiscales del taller actualizados.'**
  String get cashierFiscalTenantSaved;

  /// No description provided for @cashierFiscalPseManagedTitle.
  ///
  /// In es, this message translates to:
  /// **'PSE administrado por Atelier'**
  String get cashierFiscalPseManagedTitle;

  /// No description provided for @cashierFiscalPseManagedBody.
  ///
  /// In es, this message translates to:
  /// **'La firma digital UBL 2.1 y la conexión con el Proveedor de Servicios Electrónicos (PSE) ante SUNAT están gestionadas directamente por la plataforma.'**
  String get cashierFiscalPseManagedBody;

  /// No description provided for @cashierSeriesBranchSection.
  ///
  /// In es, this message translates to:
  /// **'Series electrónicas de la sede'**
  String get cashierSeriesBranchSection;

  /// No description provided for @cashierSeriesNcHint.
  ///
  /// In es, this message translates to:
  /// **'Incluye series para Factura (F), Boleta (B) y Notas de Crédito.'**
  String get cashierSeriesNcHint;

  /// No description provided for @receptionNewAppointment.
  ///
  /// In es, this message translates to:
  /// **'Nueva cita'**
  String get receptionNewAppointment;

  /// No description provided for @receptionCreateAppointmentTitle.
  ///
  /// In es, this message translates to:
  /// **'Agendar cita'**
  String get receptionCreateAppointmentTitle;

  /// No description provided for @receptionAppointmentCustomerLabel.
  ///
  /// In es, this message translates to:
  /// **'Cliente'**
  String get receptionAppointmentCustomerLabel;

  /// No description provided for @receptionAppointmentSelectCustomer.
  ///
  /// In es, this message translates to:
  /// **'Elige un cliente'**
  String get receptionAppointmentSelectCustomer;

  /// No description provided for @receptionAppointmentVehicleLabel.
  ///
  /// In es, this message translates to:
  /// **'Vehículo'**
  String get receptionAppointmentVehicleLabel;

  /// No description provided for @receptionAppointmentSelectVehicle.
  ///
  /// In es, this message translates to:
  /// **'Elige un vehículo'**
  String get receptionAppointmentSelectVehicle;

  /// No description provided for @receptionAppointmentNoVehicles.
  ///
  /// In es, this message translates to:
  /// **'Este cliente no tiene vehículos registrados.'**
  String get receptionAppointmentNoVehicles;

  /// No description provided for @receptionAppointmentDateLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha (AAAA-MM-DD)'**
  String get receptionAppointmentDateLabel;

  /// No description provided for @receptionAppointmentTimeLabel.
  ///
  /// In es, this message translates to:
  /// **'Hora (HH:MM)'**
  String get receptionAppointmentTimeLabel;

  /// No description provided for @receptionAppointmentTodayChip.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get receptionAppointmentTodayChip;

  /// No description provided for @receptionAppointmentTomorrowChip.
  ///
  /// In es, this message translates to:
  /// **'Mañana'**
  String get receptionAppointmentTomorrowChip;

  /// No description provided for @receptionAppointmentDurationLabel.
  ///
  /// In es, this message translates to:
  /// **'Duración estimada (min)'**
  String get receptionAppointmentDurationLabel;

  /// No description provided for @receptionAppointmentReasonLabel.
  ///
  /// In es, this message translates to:
  /// **'Motivo de la cita (opcional)'**
  String get receptionAppointmentReasonLabel;

  /// No description provided for @receptionAppointmentReasonHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Mantenimiento 40,000 km o revisión de frenos'**
  String get receptionAppointmentReasonHint;

  /// No description provided for @receptionAppointmentScheduleBtn.
  ///
  /// In es, this message translates to:
  /// **'Agendar cita'**
  String get receptionAppointmentScheduleBtn;

  /// No description provided for @receptionAppointmentScheduledNotice.
  ///
  /// In es, this message translates to:
  /// **'Cita agendada correctamente.'**
  String get receptionAppointmentScheduledNotice;

  /// No description provided for @receptionAppointmentsSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'Agenda de citas'**
  String get receptionAppointmentsSectionTitle;

  /// No description provided for @receptionAppointmentsRangeToday.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get receptionAppointmentsRangeToday;

  /// No description provided for @receptionAppointmentsRangeWeek.
  ///
  /// In es, this message translates to:
  /// **'7 días'**
  String get receptionAppointmentsRangeWeek;

  /// No description provided for @receptionAppointmentsRangeMonth.
  ///
  /// In es, this message translates to:
  /// **'30 días'**
  String get receptionAppointmentsRangeMonth;

  /// No description provided for @receptionAppointmentsEmptyWeek.
  ///
  /// In es, this message translates to:
  /// **'No hay citas en los próximos 7 días.'**
  String get receptionAppointmentsEmptyWeek;

  /// No description provided for @receptionAppointmentsEmptyMonth.
  ///
  /// In es, this message translates to:
  /// **'No hay citas en los próximos 30 días.'**
  String get receptionAppointmentsEmptyMonth;

  /// No description provided for @receptionAppointmentActionsTitle.
  ///
  /// In es, this message translates to:
  /// **'Gestionar cita'**
  String get receptionAppointmentActionsTitle;

  /// No description provided for @receptionAppointmentConfirmBtn.
  ///
  /// In es, this message translates to:
  /// **'Confirmar cita'**
  String get receptionAppointmentConfirmBtn;

  /// No description provided for @receptionAppointmentConfirmedNotice.
  ///
  /// In es, this message translates to:
  /// **'Cita confirmada.'**
  String get receptionAppointmentConfirmedNotice;

  /// No description provided for @receptionAppointmentRescheduleBtn.
  ///
  /// In es, this message translates to:
  /// **'Reprogramar'**
  String get receptionAppointmentRescheduleBtn;

  /// No description provided for @receptionAppointmentRescheduleConfirm.
  ///
  /// In es, this message translates to:
  /// **'Guardar nueva fecha'**
  String get receptionAppointmentRescheduleConfirm;

  /// No description provided for @receptionAppointmentRescheduledNotice.
  ///
  /// In es, this message translates to:
  /// **'Cita reprogramada.'**
  String get receptionAppointmentRescheduledNotice;

  /// No description provided for @receptionAppointmentCancelBtn.
  ///
  /// In es, this message translates to:
  /// **'Cancelar cita'**
  String get receptionAppointmentCancelBtn;

  /// No description provided for @receptionAppointmentCancelReasonLabel.
  ///
  /// In es, this message translates to:
  /// **'Motivo de cancelación'**
  String get receptionAppointmentCancelReasonLabel;

  /// No description provided for @receptionAppointmentCancelReasonHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. El cliente reprogramará más adelante'**
  String get receptionAppointmentCancelReasonHint;

  /// No description provided for @receptionAppointmentCancelConfirm.
  ///
  /// In es, this message translates to:
  /// **'Sí, cancelar cita'**
  String get receptionAppointmentCancelConfirm;

  /// No description provided for @receptionAppointmentCanceledNotice.
  ///
  /// In es, this message translates to:
  /// **'Cita cancelada.'**
  String get receptionAppointmentCanceledNotice;

  /// No description provided for @receptionAppointmentInvalidDatetime.
  ///
  /// In es, this message translates to:
  /// **'Ingresa una fecha (AAAA-MM-DD) y hora (HH:MM) válidas.'**
  String get receptionAppointmentInvalidDatetime;

  /// No description provided for @receptionAppointmentInvalidDuration.
  ///
  /// In es, this message translates to:
  /// **'La duración mínima es de 15 minutos.'**
  String get receptionAppointmentInvalidDuration;

  /// No description provided for @receptionAppointmentInvalidCancelReason.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el motivo de cancelación (máximo 500 caracteres).'**
  String get receptionAppointmentInvalidCancelReason;

  /// No description provided for @receptionEditContactBtn.
  ///
  /// In es, this message translates to:
  /// **'Editar contacto'**
  String get receptionEditContactBtn;

  /// No description provided for @receptionEditContactTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar contacto del cliente'**
  String get receptionEditContactTitle;

  /// No description provided for @receptionEditContactEmailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get receptionEditContactEmailLabel;

  /// No description provided for @receptionEditContactPhoneLabel.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get receptionEditContactPhoneLabel;

  /// No description provided for @receptionEditContactSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar contacto'**
  String get receptionEditContactSave;

  /// No description provided for @receptionEditContactNotice.
  ///
  /// In es, this message translates to:
  /// **'Contacto actualizado.'**
  String get receptionEditContactNotice;

  /// No description provided for @affiliationVehiclesHeader.
  ///
  /// In es, this message translates to:
  /// **'Vehículos que se vincularán'**
  String get affiliationVehiclesHeader;

  /// No description provided for @affiliationSearchingLabel.
  ///
  /// In es, this message translates to:
  /// **'Buscando cuenta en Atelier…'**
  String get affiliationSearchingLabel;

  /// No description provided for @baysFilterMaintenance.
  ///
  /// In es, this message translates to:
  /// **'Mantenimiento ({p1})'**
  String baysFilterMaintenance(int p1);

  /// No description provided for @baysOccupiedSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Bahía ocupada'**
  String get baysOccupiedSheetTitle;

  /// No description provided for @baysAvailableSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Bahía libre'**
  String get baysAvailableSheetTitle;

  /// No description provided for @baysMaintenanceSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Bahía en mantenimiento'**
  String get baysMaintenanceSheetTitle;

  /// No description provided for @baysOpenOrderBtn.
  ///
  /// In es, this message translates to:
  /// **'Abrir orden de trabajo'**
  String get baysOpenOrderBtn;

  /// No description provided for @baysReleaseBtn.
  ///
  /// In es, this message translates to:
  /// **'Liberar bahía'**
  String get baysReleaseBtn;

  /// No description provided for @baysReleasedNotice.
  ///
  /// In es, this message translates to:
  /// **'Bahía {p1} liberada.'**
  String baysReleasedNotice(String p1);

  /// No description provided for @baysReassignSection.
  ///
  /// In es, this message translates to:
  /// **'Mover orden a otra bahía libre'**
  String get baysReassignSection;

  /// No description provided for @baysSetMaintenanceBtn.
  ///
  /// In es, this message translates to:
  /// **'Poner en mantenimiento'**
  String get baysSetMaintenanceBtn;

  /// No description provided for @baysMaintenanceReasonLabel.
  ///
  /// In es, this message translates to:
  /// **'Motivo del mantenimiento'**
  String get baysMaintenanceReasonLabel;

  /// No description provided for @baysMaintenanceReasonHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Calibración de elevador hidráulico'**
  String get baysMaintenanceReasonHint;

  /// No description provided for @baysMaintenanceConfirmBtn.
  ///
  /// In es, this message translates to:
  /// **'Confirmar mantenimiento'**
  String get baysMaintenanceConfirmBtn;

  /// No description provided for @baysMaintenanceNotice.
  ///
  /// In es, this message translates to:
  /// **'Bahía {p1} puesta en mantenimiento.'**
  String baysMaintenanceNotice(String p1);

  /// No description provided for @baysRestoreBtn.
  ///
  /// In es, this message translates to:
  /// **'Restaurar bahía'**
  String get baysRestoreBtn;

  /// No description provided for @baysRestoredNotice.
  ///
  /// In es, this message translates to:
  /// **'Bahía {p1} restaurada y disponible.'**
  String baysRestoredNotice(String p1);

  /// No description provided for @baysMaintenanceFieldError.
  ///
  /// In es, this message translates to:
  /// **'Escribe el motivo del mantenimiento (máximo 1000 caracteres).'**
  String get baysMaintenanceFieldError;

  /// No description provided for @ordersFilterToCollect.
  ///
  /// In es, this message translates to:
  /// **'Por cobrar'**
  String get ordersFilterToCollect;

  /// No description provided for @ordersObdDiagnosticBtn.
  ///
  /// In es, this message translates to:
  /// **'Diagnóstico OBD-II'**
  String get ordersObdDiagnosticBtn;

  /// No description provided for @diagHubTitle.
  ///
  /// In es, this message translates to:
  /// **'Diagnóstico OBD-II'**
  String get diagHubTitle;

  /// No description provided for @diagHubPlanLocked.
  ///
  /// In es, this message translates to:
  /// **'Tu plan actual no incluye telemetría ni diagnóstico OBD-II. Disponible desde el plan Pro.'**
  String get diagHubPlanLocked;

  /// No description provided for @diagHubNoPermission.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil no tiene permiso para operar el módulo de diagnóstico OBD-II.'**
  String get diagHubNoPermission;

  /// No description provided for @diagTabScanner.
  ///
  /// In es, this message translates to:
  /// **'Escáner'**
  String get diagTabScanner;

  /// No description provided for @diagTabDevices.
  ///
  /// In es, this message translates to:
  /// **'Dispositivos'**
  String get diagTabDevices;

  /// No description provided for @diagTabAlerts.
  ///
  /// In es, this message translates to:
  /// **'Alertas'**
  String get diagTabAlerts;

  /// No description provided for @diagVehicleSection.
  ///
  /// In es, this message translates to:
  /// **'Vehículo en revisión'**
  String get diagVehicleSection;

  /// No description provided for @diagVehiclePick.
  ///
  /// In es, this message translates to:
  /// **'Elegir vehículo'**
  String get diagVehiclePick;

  /// No description provided for @diagVehicleChange.
  ///
  /// In es, this message translates to:
  /// **'Cambiar'**
  String get diagVehicleChange;

  /// No description provided for @diagVehicleNone.
  ///
  /// In es, this message translates to:
  /// **'Elige un vehículo de tus tareas u órdenes para empezar.'**
  String get diagVehicleNone;

  /// No description provided for @diagVehicleSearchLabel.
  ///
  /// In es, this message translates to:
  /// **'Buscar placa o modelo'**
  String get diagVehicleSearchLabel;

  /// No description provided for @diagVehicleSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. BKL-482 o Hilux'**
  String get diagVehicleSearchHint;

  /// No description provided for @diagVehicleSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Elegir vehículo'**
  String get diagVehicleSheetTitle;

  /// No description provided for @diagVehicleEmptySearch.
  ///
  /// In es, this message translates to:
  /// **'No hay vehículos que coincidan con la búsqueda.'**
  String get diagVehicleEmptySearch;

  /// No description provided for @diagInstallationActive.
  ///
  /// In es, this message translates to:
  /// **'Escáner vinculado'**
  String get diagInstallationActive;

  /// No description provided for @diagInstallationActiveSub.
  ///
  /// In es, this message translates to:
  /// **'Listo para enviar lotes de telemetría.'**
  String get diagInstallationActiveSub;

  /// No description provided for @diagInstallationNone.
  ///
  /// In es, this message translates to:
  /// **'Sin escáner vinculado'**
  String get diagInstallationNone;

  /// No description provided for @diagInstallationNoneSub.
  ///
  /// In es, this message translates to:
  /// **'Vincula un equipo antes de capturar lecturas, o las muestras quedarán pendientes al sincronizar.'**
  String get diagInstallationNoneSub;

  /// No description provided for @diagInstallationOffline.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión: puedes escanear y guardar lecturas en el teléfono; se enviarán al volver la red.'**
  String get diagInstallationOffline;

  /// No description provided for @diagInstallationOdometerLabel.
  ///
  /// In es, this message translates to:
  /// **'Odómetro actual (km, opcional)'**
  String get diagInstallationOdometerLabel;

  /// No description provided for @diagInstallationOdometerHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. 48500'**
  String get diagInstallationOdometerHint;

  /// No description provided for @diagInstallationOdometerInvalid.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un kilometraje válido (0 o mayor).'**
  String get diagInstallationOdometerInvalid;

  /// No description provided for @diagInstallationInstallCta.
  ///
  /// In es, this message translates to:
  /// **'Vincular escáner'**
  String get diagInstallationInstallCta;

  /// No description provided for @diagInstallationUninstallCta.
  ///
  /// In es, this message translates to:
  /// **'Retirar escáner'**
  String get diagInstallationUninstallCta;

  /// No description provided for @diagInstallationChooseDevice.
  ///
  /// In es, this message translates to:
  /// **'Elige un escáner activo del taller'**
  String get diagInstallationChooseDevice;

  /// No description provided for @diagInstallationNoActiveDevices.
  ///
  /// In es, this message translates to:
  /// **'No hay escáneres activos disponibles para vincular.'**
  String get diagInstallationNoActiveDevices;

  /// No description provided for @diagBtSection.
  ///
  /// In es, this message translates to:
  /// **'Adaptador Bluetooth ELM327'**
  String get diagBtSection;

  /// No description provided for @diagBtPermissionNeeded.
  ///
  /// In es, this message translates to:
  /// **'Autoriza el acceso a Bluetooth para ver los adaptadores emparejados en este teléfono.'**
  String get diagBtPermissionNeeded;

  /// No description provided for @diagBtPermissionCta.
  ///
  /// In es, this message translates to:
  /// **'Permitir Bluetooth'**
  String get diagBtPermissionCta;

  /// No description provided for @diagBtDisabled.
  ///
  /// In es, this message translates to:
  /// **'El Bluetooth está apagado. Enciéndelo para conectar el adaptador ELM327.'**
  String get diagBtDisabled;

  /// No description provided for @diagBtRefresh.
  ///
  /// In es, this message translates to:
  /// **'Buscar emparejados'**
  String get diagBtRefresh;

  /// No description provided for @diagBtEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay adaptadores emparejados en los ajustes de Bluetooth del teléfono.'**
  String get diagBtEmpty;

  /// No description provided for @diagBtMatchedWorkshop.
  ///
  /// In es, this message translates to:
  /// **'Registrado en taller'**
  String get diagBtMatchedWorkshop;

  /// No description provided for @diagBtConnect.
  ///
  /// In es, this message translates to:
  /// **'Conectar adaptador'**
  String get diagBtConnect;

  /// No description provided for @diagBtDisconnect.
  ///
  /// In es, this message translates to:
  /// **'Desconectar'**
  String get diagBtDisconnect;

  /// No description provided for @diagBtConnectedProtocol.
  ///
  /// In es, this message translates to:
  /// **'Protocolo: {p1}'**
  String diagBtConnectedProtocol(String p1);

  /// No description provided for @diagBtConnectedVin.
  ///
  /// In es, this message translates to:
  /// **'VIN: {p1}'**
  String diagBtConnectedVin(String p1);

  /// No description provided for @diagBtStatusDisconnected.
  ///
  /// In es, this message translates to:
  /// **'Desconectado'**
  String get diagBtStatusDisconnected;

  /// No description provided for @diagBtStatusConnecting.
  ///
  /// In es, this message translates to:
  /// **'Conectando…'**
  String get diagBtStatusConnecting;

  /// No description provided for @diagBtStatusConnected.
  ///
  /// In es, this message translates to:
  /// **'Conectado'**
  String get diagBtStatusConnected;

  /// No description provided for @diagBtStatusStreaming.
  ///
  /// In es, this message translates to:
  /// **'En vivo'**
  String get diagBtStatusStreaming;

  /// No description provided for @diagBtStatusReconnecting.
  ///
  /// In es, this message translates to:
  /// **'Reconectando…'**
  String get diagBtStatusReconnecting;

  /// No description provided for @diagBtStatusLost.
  ///
  /// In es, this message translates to:
  /// **'Señal perdida'**
  String get diagBtStatusLost;

  /// No description provided for @diagBtStatusRemote.
  ///
  /// In es, this message translates to:
  /// **'Lectura remota'**
  String get diagBtStatusRemote;

  /// No description provided for @diagErrAdapterUnreachable.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir el enlace con el adaptador. Verifica que esté alimentado y dentro del alcance.'**
  String get diagErrAdapterUnreachable;

  /// No description provided for @diagErrEcuNoResponse.
  ///
  /// In es, this message translates to:
  /// **'El adaptador respondió, pero la computadora del vehículo no. Revisa el contacto en ON y la tensión del conector.'**
  String get diagErrEcuNoResponse;

  /// No description provided for @diagErrConnectionLost.
  ///
  /// In es, this message translates to:
  /// **'Se perdió la señal Bluetooth. Las lecturas guardadas no se pierden.'**
  String get diagErrConnectionLost;

  /// No description provided for @diagErrNotConnected.
  ///
  /// In es, this message translates to:
  /// **'Conecta primero un adaptador OBD-II en el escáner.'**
  String get diagErrNotConnected;

  /// No description provided for @diagActionsSection.
  ///
  /// In es, this message translates to:
  /// **'Herramientas del vehículo'**
  String get diagActionsSection;

  /// No description provided for @diagActionLiveTitle.
  ///
  /// In es, this message translates to:
  /// **'Telemetría en vivo'**
  String get diagActionLiveTitle;

  /// No description provided for @diagActionLiveSubBt.
  ///
  /// In es, this message translates to:
  /// **'Lectura de PIDs en tiempo real y captura en fosa'**
  String get diagActionLiveSubBt;

  /// No description provided for @diagActionLiveSubRemote.
  ///
  /// In es, this message translates to:
  /// **'Última lectura registrada y serie histórica'**
  String get diagActionLiveSubRemote;

  /// No description provided for @diagActionFaultsTitle.
  ///
  /// In es, this message translates to:
  /// **'Códigos de falla (DTC)'**
  String get diagActionFaultsTitle;

  /// No description provided for @diagActionFaultsSub.
  ///
  /// In es, this message translates to:
  /// **'Escanear modo 03, revisar severidad y borrar tras reparar'**
  String get diagActionFaultsSub;

  /// No description provided for @diagActionAiTitle.
  ///
  /// In es, this message translates to:
  /// **'Informe de salud con IA'**
  String get diagActionAiTitle;

  /// No description provided for @diagActionAiSub.
  ///
  /// In es, this message translates to:
  /// **'Dictamen predictivo por subsistema y descarga PDF'**
  String get diagActionAiSub;

  /// No description provided for @diagActionAiLockedSub.
  ///
  /// In es, this message translates to:
  /// **'Disponible desde el plan Max'**
  String get diagActionAiLockedSub;

  /// No description provided for @diagActionFindingTitle.
  ///
  /// In es, this message translates to:
  /// **'Reportar hallazgo en orden'**
  String get diagActionFindingTitle;

  /// No description provided for @diagActionFindingSub.
  ///
  /// In es, this message translates to:
  /// **'Propuesta con foto en la orden activa'**
  String get diagActionFindingSub;

  /// No description provided for @diagAlertsScopeTenant.
  ///
  /// In es, this message translates to:
  /// **'Todo el taller'**
  String get diagAlertsScopeTenant;

  /// No description provided for @diagAlertsScopeVehicle.
  ///
  /// In es, this message translates to:
  /// **'Este vehículo'**
  String get diagAlertsScopeVehicle;

  /// No description provided for @diagAlertsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin alertas predictivas activas.'**
  String get diagAlertsEmpty;

  /// No description provided for @diagAlertsConfidence.
  ///
  /// In es, this message translates to:
  /// **'Confianza: {p1}%'**
  String diagAlertsConfidence(int p1);

  /// No description provided for @diagAlertsAck.
  ///
  /// In es, this message translates to:
  /// **'Confirmar lectura'**
  String get diagAlertsAck;

  /// No description provided for @diagAlertsAckDone.
  ///
  /// In es, this message translates to:
  /// **'Lectura confirmada.'**
  String get diagAlertsAckDone;

  /// No description provided for @diagAlertsConvert.
  ///
  /// In es, this message translates to:
  /// **'Agendar cita'**
  String get diagAlertsConvert;

  /// No description provided for @diagAlertsConvertTitle.
  ///
  /// In es, this message translates to:
  /// **'Agendar cita por alerta'**
  String get diagAlertsConvertTitle;

  /// No description provided for @diagAlertsConvertBody.
  ///
  /// In es, this message translates to:
  /// **'Coordina la fecha y hora con el cliente antes de confirmar la cita.'**
  String get diagAlertsConvertBody;

  /// No description provided for @diagAlertsConvertConfirm.
  ///
  /// In es, this message translates to:
  /// **'Agendar cita'**
  String get diagAlertsConvertConfirm;

  /// No description provided for @diagAlertsConvertOk.
  ///
  /// In es, this message translates to:
  /// **'Cita preventiva agendada ({p1}).'**
  String diagAlertsConvertOk(String p1);

  /// No description provided for @diagAlertsConvertDateLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha (AAAA-MM-DD)'**
  String get diagAlertsConvertDateLabel;

  /// No description provided for @diagAlertsConvertTimeLabel.
  ///
  /// In es, this message translates to:
  /// **'Hora (HH:MM)'**
  String get diagAlertsConvertTimeLabel;

  /// No description provided for @diagAlertsConvertDurationLabel.
  ///
  /// In es, this message translates to:
  /// **'Duración estimada (min)'**
  String get diagAlertsConvertDurationLabel;

  /// No description provided for @diagAlertsConvertReasonLabel.
  ///
  /// In es, this message translates to:
  /// **'Motivo de la cita'**
  String get diagAlertsConvertReasonLabel;

  /// No description provided for @diagAlertsConvertToday.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get diagAlertsConvertToday;

  /// No description provided for @diagAlertsConvertTomorrow.
  ///
  /// In es, this message translates to:
  /// **'Mañana'**
  String get diagAlertsConvertTomorrow;

  /// No description provided for @diagAlertsConvertIn2Days.
  ///
  /// In es, this message translates to:
  /// **'+2 días'**
  String get diagAlertsConvertIn2Days;

  /// No description provided for @diagAlertsConvertInvalidDatetime.
  ///
  /// In es, this message translates to:
  /// **'Ingresa una fecha (AAAA-MM-DD) y hora (HH:MM) válidas y futuras.'**
  String get diagAlertsConvertInvalidDatetime;

  /// No description provided for @diagAlertsConvertInvalidDuration.
  ///
  /// In es, this message translates to:
  /// **'La duración mínima es de 15 minutos.'**
  String get diagAlertsConvertInvalidDuration;

  /// No description provided for @diagAlertStatusDispatched.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get diagAlertStatusDispatched;

  /// No description provided for @diagAlertStatusAcknowledged.
  ///
  /// In es, this message translates to:
  /// **'Revisada'**
  String get diagAlertStatusAcknowledged;

  /// No description provided for @diagAlertStatusResolved.
  ///
  /// In es, this message translates to:
  /// **'Resuelta'**
  String get diagAlertStatusResolved;

  /// No description provided for @diagAlertStatusDismissed.
  ///
  /// In es, this message translates to:
  /// **'Desestimada'**
  String get diagAlertStatusDismissed;

  /// No description provided for @diagAlertTypeOverheating.
  ///
  /// In es, this message translates to:
  /// **'Riesgo de sobrecalentamiento'**
  String get diagAlertTypeOverheating;

  /// No description provided for @diagAlertTypeBattery.
  ///
  /// In es, this message translates to:
  /// **'Riesgo en batería'**
  String get diagAlertTypeBattery;

  /// No description provided for @diagAlertTypeCatalytic.
  ///
  /// In es, this message translates to:
  /// **'Degradación del catalizador'**
  String get diagAlertTypeCatalytic;

  /// No description provided for @diagAlertTypeMisfire.
  ///
  /// In es, this message translates to:
  /// **'Falla de encendido en cilindro'**
  String get diagAlertTypeMisfire;

  /// No description provided for @diagAlertTypeBrake.
  ///
  /// In es, this message translates to:
  /// **'Desgaste de frenos'**
  String get diagAlertTypeBrake;

  /// No description provided for @diagAlertTypeOil.
  ///
  /// In es, this message translates to:
  /// **'Agotamiento de aceite'**
  String get diagAlertTypeOil;

  /// No description provided for @diagAlertTypeEmissions.
  ///
  /// In es, this message translates to:
  /// **'Falla de emisiones'**
  String get diagAlertTypeEmissions;

  /// No description provided for @diagAlertTypeGeneric.
  ///
  /// In es, this message translates to:
  /// **'Alerta predictiva'**
  String get diagAlertTypeGeneric;

  /// No description provided for @diagLiveTitle.
  ///
  /// In es, this message translates to:
  /// **'Telemetría'**
  String get diagLiveTitle;

  /// No description provided for @diagLiveNoPermission.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil no tiene permiso para leer ni capturar telemetría.'**
  String get diagLiveNoPermission;

  /// No description provided for @diagLiveSyncPending.
  ///
  /// In es, this message translates to:
  /// **'{p1} lecturas pendientes de sincronizar'**
  String diagLiveSyncPending(int p1);

  /// No description provided for @diagLiveSyncOk.
  ///
  /// In es, this message translates to:
  /// **'Lecturas sincronizadas'**
  String get diagLiveSyncOk;

  /// No description provided for @diagLiveRemoteBanner.
  ///
  /// In es, this message translates to:
  /// **'Modo lectura remota: se muestra la última telemetría enviada al servidor.'**
  String get diagLiveRemoteBanner;

  /// No description provided for @diagLiveRemoteEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay lecturas remotas registradas para este vehículo.'**
  String get diagLiveRemoteEmpty;

  /// No description provided for @diagLiveMissingPid0105.
  ///
  /// In es, this message translates to:
  /// **'Sin PID 0105 (temperatura del refrigerante): la lectura se muestra en vivo, pero no se guarda ni se envía al servidor.'**
  String get diagLiveMissingPid0105;

  /// No description provided for @diagLiveLastSample.
  ///
  /// In es, this message translates to:
  /// **'Última muestra: {p1}'**
  String diagLiveLastSample(String p1);

  /// No description provided for @diagLiveWaitingSample.
  ///
  /// In es, this message translates to:
  /// **'Esperando primera lectura del adaptador…'**
  String get diagLiveWaitingSample;

  /// No description provided for @diagLiveStart.
  ///
  /// In es, this message translates to:
  /// **'Iniciar muestreo'**
  String get diagLiveStart;

  /// No description provided for @diagLiveStop.
  ///
  /// In es, this message translates to:
  /// **'Detener'**
  String get diagLiveStop;

  /// No description provided for @diagLiveFreeze.
  ///
  /// In es, this message translates to:
  /// **'Congelar muestra'**
  String get diagLiveFreeze;

  /// No description provided for @diagLiveFaults.
  ///
  /// In es, this message translates to:
  /// **'Códigos DTC'**
  String get diagLiveFaults;

  /// No description provided for @diagLiveRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get diagLiveRefresh;

  /// No description provided for @diagLiveFrozenTitle.
  ///
  /// In es, this message translates to:
  /// **'Muestra congelada'**
  String get diagLiveFrozenTitle;

  /// No description provided for @diagLiveFrozenSaved.
  ///
  /// In es, this message translates to:
  /// **'La muestra ya quedó guardada localmente y viajará en el próximo lote.'**
  String get diagLiveFrozenSaved;

  /// No description provided for @diagLiveHistoryHeader.
  ///
  /// In es, this message translates to:
  /// **'Historial reciente'**
  String get diagLiveHistoryHeader;

  /// No description provided for @diagLiveHistorySamples.
  ///
  /// In es, this message translates to:
  /// **'{p1} muestras'**
  String diagLiveHistorySamples(int p1);

  /// No description provided for @diagPidRpm.
  ///
  /// In es, this message translates to:
  /// **'RPM motor'**
  String get diagPidRpm;

  /// No description provided for @diagPidCoolant.
  ///
  /// In es, this message translates to:
  /// **'Temp. motor'**
  String get diagPidCoolant;

  /// No description provided for @diagPidVoltage.
  ///
  /// In es, this message translates to:
  /// **'Voltaje batería'**
  String get diagPidVoltage;

  /// No description provided for @diagPidLoad.
  ///
  /// In es, this message translates to:
  /// **'Carga motor'**
  String get diagPidLoad;

  /// No description provided for @diagPidSpeed.
  ///
  /// In es, this message translates to:
  /// **'Velocidad'**
  String get diagPidSpeed;

  /// No description provided for @diagPidThrottle.
  ///
  /// In es, this message translates to:
  /// **'Acelerador'**
  String get diagPidThrottle;

  /// No description provided for @diagPidFuel.
  ///
  /// In es, this message translates to:
  /// **'Combustible'**
  String get diagPidFuel;

  /// No description provided for @diagPidUnitRpm.
  ///
  /// In es, this message translates to:
  /// **'rpm'**
  String get diagPidUnitRpm;

  /// No description provided for @diagPidUnitCelsius.
  ///
  /// In es, this message translates to:
  /// **'°C'**
  String get diagPidUnitCelsius;

  /// No description provided for @diagPidUnitVolts.
  ///
  /// In es, this message translates to:
  /// **'V'**
  String get diagPidUnitVolts;

  /// No description provided for @diagPidUnitPercent.
  ///
  /// In es, this message translates to:
  /// **'%'**
  String get diagPidUnitPercent;

  /// No description provided for @diagPidUnitKmh.
  ///
  /// In es, this message translates to:
  /// **'km/h'**
  String get diagPidUnitKmh;

  /// No description provided for @diagPidStatusNormal.
  ///
  /// In es, this message translates to:
  /// **'En rango'**
  String get diagPidStatusNormal;

  /// No description provided for @diagPidStatusOverheat.
  ///
  /// In es, this message translates to:
  /// **'Sobrecalentamiento'**
  String get diagPidStatusOverheat;

  /// No description provided for @diagPidStatusTempHigh.
  ///
  /// In es, this message translates to:
  /// **'Temperatura elevada'**
  String get diagPidStatusTempHigh;

  /// No description provided for @diagPidStatusLowVolt.
  ///
  /// In es, this message translates to:
  /// **'Voltaje bajo'**
  String get diagPidStatusLowVolt;

  /// No description provided for @diagPidStatusHighVolt.
  ///
  /// In es, this message translates to:
  /// **'Sobretensión'**
  String get diagPidStatusHighVolt;

  /// No description provided for @diagPidStatusHighRpm.
  ///
  /// In es, this message translates to:
  /// **'RPM elevadas'**
  String get diagPidStatusHighRpm;

  /// No description provided for @diagPidStatusHighLoad.
  ///
  /// In es, this message translates to:
  /// **'Carga alta'**
  String get diagPidStatusHighLoad;

  /// No description provided for @diagPidStatusLowFuel.
  ///
  /// In es, this message translates to:
  /// **'Nivel bajo'**
  String get diagPidStatusLowFuel;

  /// No description provided for @diagFaultsTitle.
  ///
  /// In es, this message translates to:
  /// **'Códigos de falla (DTC)'**
  String get diagFaultsTitle;

  /// No description provided for @diagFaultsNoPermission.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil no tiene permiso para consultar fallas electrónicas.'**
  String get diagFaultsNoPermission;

  /// No description provided for @diagFaultsCount.
  ///
  /// In es, this message translates to:
  /// **'{p1} fallas activas'**
  String diagFaultsCount(int p1);

  /// No description provided for @diagFaultsPendingSync.
  ///
  /// In es, this message translates to:
  /// **'{p1} por sincronizar'**
  String diagFaultsPendingSync(int p1);

  /// No description provided for @diagFaultsScan.
  ///
  /// In es, this message translates to:
  /// **'Escanear DTC'**
  String get diagFaultsScan;

  /// No description provided for @diagFaultsClear.
  ///
  /// In es, this message translates to:
  /// **'Borrar códigos'**
  String get diagFaultsClear;

  /// No description provided for @diagFaultsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin códigos de falla activos.'**
  String get diagFaultsEmpty;

  /// No description provided for @diagFaultsScanClean.
  ///
  /// In es, this message translates to:
  /// **'Escaneo limpio: la ECU no reportó códigos de falla.'**
  String get diagFaultsScanClean;

  /// No description provided for @diagFaultsPendingBadge.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get diagFaultsPendingBadge;

  /// No description provided for @diagFaultsSeverityCritical.
  ///
  /// In es, this message translates to:
  /// **'Crítica'**
  String get diagFaultsSeverityCritical;

  /// No description provided for @diagFaultsSeverityMedium.
  ///
  /// In es, this message translates to:
  /// **'Media'**
  String get diagFaultsSeverityMedium;

  /// No description provided for @diagFaultsSeverityLow.
  ///
  /// In es, this message translates to:
  /// **'Baja'**
  String get diagFaultsSeverityLow;

  /// No description provided for @diagFaultsFreezeHeader.
  ///
  /// In es, this message translates to:
  /// **'Cuadro congelado (Modo 02)'**
  String get diagFaultsFreezeHeader;

  /// No description provided for @diagFaultsClearTitle.
  ///
  /// In es, this message translates to:
  /// **'Borrar códigos de falla'**
  String get diagFaultsClearTitle;

  /// No description provided for @diagFaultsClearBody.
  ///
  /// In es, this message translates to:
  /// **'Se enviará el comando Modo 04 a la computadora y luego se re-leerán los códigos activos. Si la avería física persiste, el código volverá a aparecer.'**
  String get diagFaultsClearBody;

  /// No description provided for @diagFaultsClearConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar borrado'**
  String get diagFaultsClearConfirm;

  /// No description provided for @diagFaultsClearResultClean.
  ///
  /// In es, this message translates to:
  /// **'Se borraron {p1} códigos y no quedaron fallas activas.'**
  String diagFaultsClearResultClean(int p1);

  /// No description provided for @diagFaultsClearResultPersistent.
  ///
  /// In es, this message translates to:
  /// **'Se borraron {p1} códigos, pero {p2} persisten. Revisa el circuito antes de cerrar la tarea.'**
  String diagFaultsClearResultPersistent(int p1, int p2);

  /// No description provided for @diagFaultsNeedBt.
  ///
  /// In es, this message translates to:
  /// **'Conecta el adaptador Bluetooth en Escáner para leer o borrar códigos de la ECU.'**
  String get diagFaultsNeedBt;

  /// No description provided for @diagReportTitle.
  ///
  /// In es, this message translates to:
  /// **'Informe de salud IA'**
  String get diagReportTitle;

  /// No description provided for @diagReportPlanLocked.
  ///
  /// In es, this message translates to:
  /// **'Los informes de salud con IA están disponibles desde el plan Max.'**
  String get diagReportPlanLocked;

  /// No description provided for @diagReportNoPermission.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil no tiene permiso para consultar ni generar informes de salud.'**
  String get diagReportNoPermission;

  /// No description provided for @diagReportScoreLabel.
  ///
  /// In es, this message translates to:
  /// **'Puntaje de salud'**
  String get diagReportScoreLabel;

  /// No description provided for @diagReportEmpty.
  ///
  /// In es, this message translates to:
  /// **'Este vehículo aún no tiene un informe de salud emitido.'**
  String get diagReportEmpty;

  /// No description provided for @diagReportGenerate.
  ///
  /// In es, this message translates to:
  /// **'Generar informe IA'**
  String get diagReportGenerate;

  /// No description provided for @diagReportGenerateSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Generar informe de salud'**
  String get diagReportGenerateSheetTitle;

  /// No description provided for @diagReportDaysLabel.
  ///
  /// In es, this message translates to:
  /// **'Ventana de análisis'**
  String get diagReportDaysLabel;

  /// No description provided for @diagReportDaysOption.
  ///
  /// In es, this message translates to:
  /// **'{p1} días'**
  String diagReportDaysOption(int p1);

  /// No description provided for @diagReportIncludeResolved.
  ///
  /// In es, this message translates to:
  /// **'Incluir historial de DTC ya resueltos'**
  String get diagReportIncludeResolved;

  /// No description provided for @diagReportGenerating.
  ///
  /// In es, this message translates to:
  /// **'Analizando telemetría y fallas…'**
  String get diagReportGenerating;

  /// No description provided for @diagReportDownloadPdf.
  ///
  /// In es, this message translates to:
  /// **'Descargar PDF'**
  String get diagReportDownloadPdf;

  /// No description provided for @diagReportSummarySection.
  ///
  /// In es, this message translates to:
  /// **'Resumen ejecutivo'**
  String get diagReportSummarySection;

  /// No description provided for @diagReportSubsystemsSection.
  ///
  /// In es, this message translates to:
  /// **'Subsistemas evaluados'**
  String get diagReportSubsystemsSection;

  /// No description provided for @diagReportRisksSection.
  ///
  /// In es, this message translates to:
  /// **'Riesgos predictivos'**
  String get diagReportRisksSection;

  /// No description provided for @diagReportActionsSection.
  ///
  /// In es, this message translates to:
  /// **'Acciones recomendadas'**
  String get diagReportActionsSection;

  /// No description provided for @diagReportCorrelationsSection.
  ///
  /// In es, this message translates to:
  /// **'Correlación DTC y sensores'**
  String get diagReportCorrelationsSection;

  /// No description provided for @diagReportRiskDetail.
  ///
  /// In es, this message translates to:
  /// **'Probabilidad: {p1}% · Horizonte: {p2} días'**
  String diagReportRiskDetail(int p1, int p2);

  /// No description provided for @diagReportDaysAnalyzed.
  ///
  /// In es, this message translates to:
  /// **'Analizado sobre {p1} días · {p2}'**
  String diagReportDaysAnalyzed(int p1, String p2);

  /// No description provided for @diagReportInsufficientTelemetry.
  ///
  /// In es, this message translates to:
  /// **'Telemetría insuficiente: {p1} Prueba ampliar los días o escanear el vehículo en bahía.'**
  String diagReportInsufficientTelemetry(String p1);

  /// No description provided for @diagReportOpenPdf.
  ///
  /// In es, this message translates to:
  /// **'Abrir PDF'**
  String get diagReportOpenPdf;

  /// No description provided for @diagReportSharePdf.
  ///
  /// In es, this message translates to:
  /// **'Compartir PDF'**
  String get diagReportSharePdf;

  /// No description provided for @diagDeviceInvalidConnectionType.
  ///
  /// In es, this message translates to:
  /// **'Elige un tipo de conexión válido (Bluetooth, BLE, Wi-Fi o USB).'**
  String get diagDeviceInvalidConnectionType;

  /// No description provided for @diagDeviceIdentifierRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el identificador o dirección MAC del escáner.'**
  String get diagDeviceIdentifierRequired;

  /// No description provided for @diagLiveReconnect.
  ///
  /// In es, this message translates to:
  /// **'Reconectar escáner'**
  String get diagLiveReconnect;

  /// No description provided for @diagLiveOtherVehicleWarning.
  ///
  /// In es, this message translates to:
  /// **'El escáner está conectado a otro vehículo. Conéctalo a esta unidad en Escáner.'**
  String get diagLiveOtherVehicleWarning;

  /// No description provided for @diagPidIntakePressure.
  ///
  /// In es, this message translates to:
  /// **'Presión admisión'**
  String get diagPidIntakePressure;

  /// No description provided for @diagPidUnitKpa.
  ///
  /// In es, this message translates to:
  /// **'kPa'**
  String get diagPidUnitKpa;

  /// No description provided for @obdConnBluetoothBle.
  ///
  /// In es, this message translates to:
  /// **'Bluetooth BLE'**
  String get obdConnBluetoothBle;

  /// No description provided for @floorHubShiftActive.
  ///
  /// In es, this message translates to:
  /// **'En turno'**
  String get floorHubShiftActive;

  /// No description provided for @floorHubShiftPending.
  ///
  /// In es, this message translates to:
  /// **'Ingreso pendiente'**
  String get floorHubShiftPending;

  /// No description provided for @floorHubShiftClosed.
  ///
  /// In es, this message translates to:
  /// **'Jornada cerrada'**
  String get floorHubShiftClosed;

  /// No description provided for @floorHubShiftIdle.
  ///
  /// In es, this message translates to:
  /// **'Sin marcar'**
  String get floorHubShiftIdle;

  /// No description provided for @floorHubClockInCta.
  ///
  /// In es, this message translates to:
  /// **'Marcar ingreso'**
  String get floorHubClockInCta;

  /// No description provided for @floorHubClockOutCta.
  ///
  /// In es, this message translates to:
  /// **'Marcar salida'**
  String get floorHubClockOutCta;

  /// No description provided for @floorHubAttendanceDetail.
  ///
  /// In es, this message translates to:
  /// **'Ver turno y descargos'**
  String get floorHubAttendanceDetail;

  /// No description provided for @floorHubActiveTaskSection.
  ///
  /// In es, this message translates to:
  /// **'Tarea en curso'**
  String get floorHubActiveTaskSection;

  /// No description provided for @floorHubOpenTask.
  ///
  /// In es, this message translates to:
  /// **'Abrir tarea'**
  String get floorHubOpenTask;

  /// No description provided for @floorHubNoActiveTask.
  ///
  /// In es, this message translates to:
  /// **'Sin tarea iniciada. Elige una de tu lista.'**
  String get floorHubNoActiveTask;

  /// No description provided for @floorHubTasksQueueSection.
  ///
  /// In es, this message translates to:
  /// **'Mis tareas de hoy'**
  String get floorHubTasksQueueSection;

  /// No description provided for @floorHubTasksEmpty.
  ///
  /// In es, this message translates to:
  /// **'No tienes tareas asignadas por ahora.'**
  String get floorHubTasksEmpty;

  /// No description provided for @floorHubTasksLegendActive.
  ///
  /// In es, this message translates to:
  /// **'En fosa'**
  String get floorHubTasksLegendActive;

  /// No description provided for @floorHubTasksCaptionFormat.
  ///
  /// In es, this message translates to:
  /// **'{p1} pendientes · {p2} cerradas'**
  String floorHubTasksCaptionFormat(int p1, int p2);

  /// No description provided for @floorHubFigurePending.
  ///
  /// In es, this message translates to:
  /// **'pendientes'**
  String get floorHubFigurePending;

  /// No description provided for @floorHubFigureInProgress.
  ///
  /// In es, this message translates to:
  /// **'en curso'**
  String get floorHubFigureInProgress;

  /// No description provided for @floorHubFigureObd.
  ///
  /// In es, this message translates to:
  /// **'OBD activos'**
  String get floorHubFigureObd;

  /// No description provided for @floorHubQuickSection.
  ///
  /// In es, this message translates to:
  /// **'Accesos de piso'**
  String get floorHubQuickSection;

  /// No description provided for @floorHubQuickObd.
  ///
  /// In es, this message translates to:
  /// **'Diagnóstico OBD-II'**
  String get floorHubQuickObd;

  /// No description provided for @floorHubQuickObdSub.
  ///
  /// In es, this message translates to:
  /// **'Telemetría en vivo, DTC e informe IA'**
  String get floorHubQuickObdSub;

  /// No description provided for @floorHubQuickFinding.
  ///
  /// In es, this message translates to:
  /// **'Reportar hallazgo'**
  String get floorHubQuickFinding;

  /// No description provided for @floorHubQuickFindingSub.
  ///
  /// In es, this message translates to:
  /// **'Propuesta con foto en la orden activa'**
  String get floorHubQuickFindingSub;

  /// No description provided for @floorHubQuickParts.
  ///
  /// In es, this message translates to:
  /// **'Consultar repuestos'**
  String get floorHubQuickParts;

  /// No description provided for @floorHubQuickPartsSub.
  ///
  /// In es, this message translates to:
  /// **'Stock disponible por nombre o SKU'**
  String get floorHubQuickPartsSub;

  /// No description provided for @floorHubQuickBays.
  ///
  /// In es, this message translates to:
  /// **'Tablero de bahías'**
  String get floorHubQuickBays;

  /// No description provided for @floorHubQuickBaysSub.
  ///
  /// In es, this message translates to:
  /// **'Vehículos asignados por elevador'**
  String get floorHubQuickBaysSub;

  /// No description provided for @floorHubCounterCaption.
  ///
  /// In es, this message translates to:
  /// **'citas agendadas hoy'**
  String get floorHubCounterCaption;

  /// No description provided for @floorHubCounterSection.
  ///
  /// In es, this message translates to:
  /// **'Agenda de hoy'**
  String get floorHubCounterSection;

  /// No description provided for @floorHubCounterEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin citas agendadas para hoy.'**
  String get floorHubCounterEmpty;

  /// No description provided for @floorHubCounterOpenReception.
  ///
  /// In es, this message translates to:
  /// **'Buscar placa o cliente'**
  String get floorHubCounterOpenReception;

  /// No description provided for @floorHubCounterNewCustomer.
  ///
  /// In es, this message translates to:
  /// **'Registrar cliente'**
  String get floorHubCounterNewCustomer;

  /// No description provided for @floorHubFigureArrived.
  ///
  /// In es, this message translates to:
  /// **'llegaron'**
  String get floorHubFigureArrived;

  /// No description provided for @floorHubFigureWaiting.
  ///
  /// In es, this message translates to:
  /// **'por llegar'**
  String get floorHubFigureWaiting;

  /// No description provided for @floorHubFigureOrders.
  ///
  /// In es, this message translates to:
  /// **'órdenes hoy'**
  String get floorHubFigureOrders;

  /// No description provided for @floorHubStockCaption.
  ///
  /// In es, this message translates to:
  /// **'alertas de stock mínimo'**
  String get floorHubStockCaption;

  /// No description provided for @floorHubStockDecisions.
  ///
  /// In es, this message translates to:
  /// **'Requieren reposición'**
  String get floorHubStockDecisions;

  /// No description provided for @floorHubStockEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todo el catálogo está sobre el mínimo.'**
  String get floorHubStockEmpty;

  /// No description provided for @floorHubStockPosSection.
  ///
  /// In es, this message translates to:
  /// **'Órdenes de compra emitidas'**
  String get floorHubStockPosSection;

  /// No description provided for @floorHubStockPosEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin órdenes de compra pendientes de recibir.'**
  String get floorHubStockPosEmpty;

  /// No description provided for @floorHubStockOpenCatalog.
  ///
  /// In es, this message translates to:
  /// **'Abrir catálogo'**
  String get floorHubStockOpenCatalog;

  /// No description provided for @floorHubFigureOutOfStock.
  ///
  /// In es, this message translates to:
  /// **'agotados'**
  String get floorHubFigureOutOfStock;

  /// No description provided for @floorHubFigureOpenPos.
  ///
  /// In es, this message translates to:
  /// **'OC emitidas'**
  String get floorHubFigureOpenPos;

  /// No description provided for @floorHubFigureCatalog.
  ///
  /// In es, this message translates to:
  /// **'repuestos'**
  String get floorHubFigureCatalog;

  /// No description provided for @floorHubCashCaption.
  ///
  /// In es, this message translates to:
  /// **'órdenes listas para cobrar'**
  String get floorHubCashCaption;

  /// No description provided for @floorHubCashDecisions.
  ///
  /// In es, this message translates to:
  /// **'Listas para cobrar'**
  String get floorHubCashDecisions;

  /// No description provided for @floorHubCashEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay órdenes terminadas esperando cobro.'**
  String get floorHubCashEmpty;

  /// No description provided for @floorHubCashOpenDaily.
  ///
  /// In es, this message translates to:
  /// **'Ver caja del día'**
  String get floorHubCashOpenDaily;

  /// No description provided for @floorHubFigureCollected.
  ///
  /// In es, this message translates to:
  /// **'cobrado hoy'**
  String get floorHubFigureCollected;

  /// No description provided for @floorHubFigurePayments.
  ///
  /// In es, this message translates to:
  /// **'cobros hoy'**
  String get floorHubFigurePayments;

  /// No description provided for @dashboardMyShiftTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi jornada'**
  String get dashboardMyShiftTitle;

  /// No description provided for @dashboardMyShiftClockedIn.
  ///
  /// In es, this message translates to:
  /// **'En turno hoy · toca para ver horario o marcar salida'**
  String get dashboardMyShiftClockedIn;

  /// No description provided for @dashboardMyShiftNotClockedIn.
  ///
  /// In es, this message translates to:
  /// **'Sin ingreso marcado · toca para marcar asistencia'**
  String get dashboardMyShiftNotClockedIn;

  /// No description provided for @dashboardMyShiftQueued.
  ///
  /// In es, this message translates to:
  /// **'Marcación pendiente de sincronizar'**
  String get dashboardMyShiftQueued;

  /// No description provided for @dashboardMyShiftCompleted.
  ///
  /// In es, this message translates to:
  /// **'Jornada del día completada'**
  String get dashboardMyShiftCompleted;

  /// No description provided for @dashboardMyTasksTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis tareas asignadas'**
  String get dashboardMyTasksTitle;

  /// No description provided for @dashboardMyTasksSub.
  ///
  /// In es, this message translates to:
  /// **'{p1} activas · toca para abrir tu bandeja'**
  String dashboardMyTasksSub(int p1);

  /// No description provided for @attendanceGeofenceInside.
  ///
  /// In es, this message translates to:
  /// **'Dentro de geocerca ({p1} m)'**
  String attendanceGeofenceInside(int p1);

  /// No description provided for @attendanceGeofenceOutside.
  ///
  /// In es, this message translates to:
  /// **'Fuera de geocerca ({p1} m / máx. {p2} m)'**
  String attendanceGeofenceOutside(int p1, int p2);

  /// No description provided for @attendanceGeofenceMock.
  ///
  /// In es, this message translates to:
  /// **'Ubicación simulada detectada'**
  String get attendanceGeofenceMock;

  /// No description provided for @attendanceGeofencePending.
  ///
  /// In es, this message translates to:
  /// **'Sin lectura GPS todavía'**
  String get attendanceGeofencePending;

  /// No description provided for @attendanceScheduleSection.
  ///
  /// In es, this message translates to:
  /// **'Mi turno semanal'**
  String get attendanceScheduleSection;

  /// No description provided for @attendanceScheduleTolerance.
  ///
  /// In es, this message translates to:
  /// **'Tolerancia de ingreso: {p1} min'**
  String attendanceScheduleTolerance(int p1);

  /// No description provided for @attendanceScheduleWorkday.
  ///
  /// In es, this message translates to:
  /// **'Laborable'**
  String get attendanceScheduleWorkday;

  /// No description provided for @attendanceScheduleRestday.
  ///
  /// In es, this message translates to:
  /// **'Descanso'**
  String get attendanceScheduleRestday;

  /// No description provided for @attendanceHistorySection.
  ///
  /// In es, this message translates to:
  /// **'Historial de los últimos 30 días'**
  String get attendanceHistorySection;

  /// No description provided for @attendanceWorkedSummary.
  ///
  /// In es, this message translates to:
  /// **'{p1}h {p2}m trabajados'**
  String attendanceWorkedSummary(int p1, int p2);

  /// No description provided for @attendanceOvertimeSummary.
  ///
  /// In es, this message translates to:
  /// **' · +{p1}m extra'**
  String attendanceOvertimeSummary(int p1);

  /// No description provided for @attendanceJustificationSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Enviar descargo'**
  String get attendanceJustificationSheetTitle;

  /// No description provided for @attendanceJustificationFieldLabel.
  ///
  /// In es, this message translates to:
  /// **'Motivo del descargo'**
  String get attendanceJustificationFieldLabel;

  /// No description provided for @attendanceJustificationFieldHint.
  ///
  /// In es, this message translates to:
  /// **'Explica brevemente la tardanza o ausencia (máx. 500 caracteres)'**
  String get attendanceJustificationFieldHint;

  /// No description provided for @attendanceClockOutSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cerrar jornada de hoy?'**
  String get attendanceClockOutSheetTitle;

  /// No description provided for @attendanceClockOutSheetBody.
  ///
  /// In es, this message translates to:
  /// **'Se registrará tu hora de salida y se calcularán tus horas efectivas del turno.'**
  String get attendanceClockOutSheetBody;

  /// No description provided for @attendanceClockOutConfirm.
  ///
  /// In es, this message translates to:
  /// **'Sí, marcar salida'**
  String get attendanceClockOutConfirm;

  /// No description provided for @attendanceNoBranchAssigned.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes sede ni turno asignados. Pide al administrador que configure tu perfil laboral.'**
  String get attendanceNoBranchAssigned;

  /// No description provided for @inventoryPartSubtitle.
  ///
  /// In es, this message translates to:
  /// **'SKU {p1} · Stock: {p2}'**
  String inventoryPartSubtitle(String p1, String p2);

  /// No description provided for @inventoryDetailStockSection.
  ///
  /// In es, this message translates to:
  /// **'Existencias'**
  String get inventoryDetailStockSection;

  /// No description provided for @inventoryDetailStock.
  ///
  /// In es, this message translates to:
  /// **'Stock'**
  String get inventoryDetailStock;

  /// No description provided for @inventoryDetailMinimum.
  ///
  /// In es, this message translates to:
  /// **'Stock mínimo'**
  String get inventoryDetailMinimum;

  /// No description provided for @inventoryDetailPrice.
  ///
  /// In es, this message translates to:
  /// **'Precio de venta sin IGV'**
  String get inventoryDetailPrice;

  /// No description provided for @inventoryDetailCategory.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get inventoryDetailCategory;

  /// No description provided for @inventoryAlertsTitle.
  ///
  /// In es, this message translates to:
  /// **'Alertas de stock'**
  String get inventoryAlertsTitle;

  /// No description provided for @inventoryAlertsHeader.
  ///
  /// In es, this message translates to:
  /// **'Por reponer'**
  String get inventoryAlertsHeader;

  /// No description provided for @inventoryAlertsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Ningún repuesto está en su mínimo.'**
  String get inventoryAlertsEmpty;

  /// No description provided for @inventoryAlertsNoPermission.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil no tiene permiso para ver las alertas de stock.'**
  String get inventoryAlertsNoPermission;

  /// No description provided for @inventoryAlertsOffline.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión: alertas calculadas con el catálogo guardado.'**
  String get inventoryAlertsOffline;

  /// No description provided for @inventoryAlertSubtitle.
  ///
  /// In es, this message translates to:
  /// **'SKU {p1} · Stock {p2} de {p3}'**
  String inventoryAlertSubtitle(String p1, String p2, String p3);

  /// No description provided for @inventoryAlertMissing.
  ///
  /// In es, this message translates to:
  /// **'Faltan {p1}'**
  String inventoryAlertMissing(String p1);

  /// No description provided for @inventoryPoTitle.
  ///
  /// In es, this message translates to:
  /// **'Compras'**
  String get inventoryPoTitle;

  /// No description provided for @inventoryPoDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Orden de compra'**
  String get inventoryPoDetailTitle;

  /// No description provided for @inventoryPoNoPermission.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil no tiene permiso para ver las órdenes de compra.'**
  String get inventoryPoNoPermission;

  /// No description provided for @inventoryPoEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay órdenes de compra en este estado.'**
  String get inventoryPoEmpty;

  /// No description provided for @inventoryPoFilterIssued.
  ///
  /// In es, this message translates to:
  /// **'Por recibir'**
  String get inventoryPoFilterIssued;

  /// No description provided for @inventoryPoFilterReceived.
  ///
  /// In es, this message translates to:
  /// **'Recibidas'**
  String get inventoryPoFilterReceived;

  /// No description provided for @inventoryPoFilterAll.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get inventoryPoFilterAll;

  /// No description provided for @inventoryPoNumber.
  ///
  /// In es, this message translates to:
  /// **'Orden {p1}'**
  String inventoryPoNumber(String p1);

  /// No description provided for @inventoryPoNoNumber.
  ///
  /// In es, this message translates to:
  /// **'Orden sin número'**
  String get inventoryPoNoNumber;

  /// No description provided for @inventoryPoReceivedOn.
  ///
  /// In es, this message translates to:
  /// **'Recibida el {p1}'**
  String inventoryPoReceivedOn(String p1);

  /// No description provided for @inventoryPoStatusDraft.
  ///
  /// In es, this message translates to:
  /// **'Borrador'**
  String get inventoryPoStatusDraft;

  /// No description provided for @inventoryPoStatusIssued.
  ///
  /// In es, this message translates to:
  /// **'Por recibir'**
  String get inventoryPoStatusIssued;

  /// No description provided for @inventoryPoStatusReceived.
  ///
  /// In es, this message translates to:
  /// **'Recibida'**
  String get inventoryPoStatusReceived;

  /// No description provided for @inventoryPoStatusCanceled.
  ///
  /// In es, this message translates to:
  /// **'Anulada'**
  String get inventoryPoStatusCanceled;

  /// No description provided for @inventoryPoStatusUnknown.
  ///
  /// In es, this message translates to:
  /// **'Sin estado'**
  String get inventoryPoStatusUnknown;

  /// No description provided for @inventoryPoLinesHeader.
  ///
  /// In es, this message translates to:
  /// **'Repuestos pedidos'**
  String get inventoryPoLinesHeader;

  /// No description provided for @inventoryPoLineUnknown.
  ///
  /// In es, this message translates to:
  /// **'Repuesto'**
  String get inventoryPoLineUnknown;

  /// No description provided for @inventoryPoLineSubtitle.
  ///
  /// In es, this message translates to:
  /// **'{p1} × {p2}'**
  String inventoryPoLineSubtitle(String p1, String p2);

  /// No description provided for @inventoryPoLineQuantity.
  ///
  /// In es, this message translates to:
  /// **'Cantidad: {p1}'**
  String inventoryPoLineQuantity(String p1);

  /// No description provided for @inventoryPoReceiptHeader.
  ///
  /// In es, this message translates to:
  /// **'Comprobante'**
  String get inventoryPoReceiptHeader;

  /// No description provided for @inventoryPoReceiptNumber.
  ///
  /// In es, this message translates to:
  /// **'Número de comprobante'**
  String get inventoryPoReceiptNumber;

  /// No description provided for @inventoryPoReceiptDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de recepción'**
  String get inventoryPoReceiptDate;

  /// No description provided for @inventoryPoReceive.
  ///
  /// In es, this message translates to:
  /// **'Recibir orden'**
  String get inventoryPoReceive;

  /// No description provided for @inventoryPoReceiveTitle.
  ///
  /// In es, this message translates to:
  /// **'Recibir la orden'**
  String get inventoryPoReceiveTitle;

  /// No description provided for @inventoryPoReceiveBody.
  ///
  /// In es, this message translates to:
  /// **'Cada línea entra al stock como un lote nuevo. Anota el número del comprobante y toma una foto.'**
  String get inventoryPoReceiveBody;

  /// No description provided for @inventoryPoReceiveConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar recepción'**
  String get inventoryPoReceiveConfirm;

  /// No description provided for @inventoryPoPhotoTake.
  ///
  /// In es, this message translates to:
  /// **'Tomar foto del comprobante'**
  String get inventoryPoPhotoTake;

  /// No description provided for @inventoryPoPhotoRetake.
  ///
  /// In es, this message translates to:
  /// **'Volver a tomar la foto'**
  String get inventoryPoPhotoRetake;

  /// No description provided for @inventoryPoPhotoAttached.
  ///
  /// In es, this message translates to:
  /// **'Foto del comprobante lista'**
  String get inventoryPoPhotoAttached;

  /// No description provided for @inventoryPoReceivedOk.
  ///
  /// In es, this message translates to:
  /// **'Orden recibida. El stock ya subió.'**
  String get inventoryPoReceivedOk;

  /// No description provided for @inventoryPoLines.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{{count} línea} other{{count} líneas}}'**
  String inventoryPoLines(int count);

  /// No description provided for @inventoryValuationTitle.
  ///
  /// In es, this message translates to:
  /// **'Valorización'**
  String get inventoryValuationTitle;

  /// No description provided for @inventoryValuationContext.
  ///
  /// In es, this message translates to:
  /// **'Inventario'**
  String get inventoryValuationContext;

  /// No description provided for @inventoryValuationCaption.
  ///
  /// In es, this message translates to:
  /// **'Valor de los lotes con saldo, al costo'**
  String get inventoryValuationCaption;

  /// No description provided for @inventoryValuationNoPermission.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil no tiene permiso para ver la valorización.'**
  String get inventoryValuationNoPermission;

  /// No description provided for @inventoryValuationWithStock.
  ///
  /// In es, this message translates to:
  /// **'con stock'**
  String get inventoryValuationWithStock;

  /// No description provided for @inventoryValuationLow.
  ///
  /// In es, this message translates to:
  /// **'en el mínimo'**
  String get inventoryValuationLow;

  /// No description provided for @inventoryValuationOut.
  ///
  /// In es, this message translates to:
  /// **'agotados'**
  String get inventoryValuationOut;

  /// No description provided for @inventoryValuationByCategory.
  ///
  /// In es, this message translates to:
  /// **'Existencias por categoría'**
  String get inventoryValuationByCategory;

  /// No description provided for @inventoryValuationEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay repuestos con stock.'**
  String get inventoryValuationEmpty;

  /// No description provided for @inventoryValuationUncategorized.
  ///
  /// In es, this message translates to:
  /// **'Sin categoría'**
  String get inventoryValuationUncategorized;

  /// No description provided for @inventoryValuationUnits.
  ///
  /// In es, this message translates to:
  /// **'{p1} u.'**
  String inventoryValuationUnits(String p1);

  /// No description provided for @inventoryValuationParts.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{{count} repuesto} other{{count} repuestos}}'**
  String inventoryValuationParts(int count);

  /// No description provided for @invSeg2ScannerTitle.
  ///
  /// In es, this message translates to:
  /// **'Escanear SKU'**
  String get invSeg2ScannerTitle;

  /// No description provided for @invSeg2ScannerOpenDesc.
  ///
  /// In es, this message translates to:
  /// **'Escanear código de barras o QR'**
  String get invSeg2ScannerOpenDesc;

  /// No description provided for @invSeg2ScannerHint.
  ///
  /// In es, this message translates to:
  /// **'Apunta la cámara al código de barras o QR del repuesto.'**
  String get invSeg2ScannerHint;

  /// No description provided for @invSeg2ScannerPermissionTitle.
  ///
  /// In es, this message translates to:
  /// **'Permiso de cámara'**
  String get invSeg2ScannerPermissionTitle;

  /// No description provided for @invSeg2ScannerPermissionBody.
  ///
  /// In es, this message translates to:
  /// **'Necesitamos acceso a la cámara para leer códigos de barras. También puedes escribir el SKU abajo.'**
  String get invSeg2ScannerPermissionBody;

  /// No description provided for @invSeg2ScannerPermissionGrant.
  ///
  /// In es, this message translates to:
  /// **'Permitir cámara'**
  String get invSeg2ScannerPermissionGrant;

  /// No description provided for @invSeg2ScannerManualLabel.
  ///
  /// In es, this message translates to:
  /// **'Ingreso manual de SKU'**
  String get invSeg2ScannerManualLabel;

  /// No description provided for @invSeg2ScannerManualHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. BRK-001'**
  String get invSeg2ScannerManualHint;

  /// No description provided for @invSeg2ScannerSearchBtn.
  ///
  /// In es, this message translates to:
  /// **'Buscar SKU'**
  String get invSeg2ScannerSearchBtn;

  /// No description provided for @invSeg2ScannerNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró ningún repuesto con el SKU {p1}.'**
  String invSeg2ScannerNotFound(String p1);

  /// No description provided for @invSeg2ScannerInvalidSku.
  ///
  /// In es, this message translates to:
  /// **'El código {p1} no tiene formato válido de SKU (3 a 50 caracteres: A-Z, 0-9, - o _).'**
  String invSeg2ScannerInvalidSku(String p1);

  /// No description provided for @invSeg2ScannerRetry.
  ///
  /// In es, this message translates to:
  /// **'Escanear otro código'**
  String get invSeg2ScannerRetry;

  /// No description provided for @invSeg2ScannerNoPermission.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil no tiene permiso para consultar el catálogo de repuestos.'**
  String get invSeg2ScannerNoPermission;

  /// No description provided for @invSeg2SuppliersTitle.
  ///
  /// In es, this message translates to:
  /// **'Proveedores'**
  String get invSeg2SuppliersTitle;

  /// No description provided for @invSeg2SuppliersNoPermission.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil no tiene permiso para gestionar proveedores.'**
  String get invSeg2SuppliersNoPermission;

  /// No description provided for @invSeg2SuppliersSearchLabel.
  ///
  /// In es, this message translates to:
  /// **'Buscar proveedor'**
  String get invSeg2SuppliersSearchLabel;

  /// No description provided for @invSeg2SuppliersSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Razón social o RUC'**
  String get invSeg2SuppliersSearchHint;

  /// No description provided for @invSeg2SuppliersEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay proveedores registrados.'**
  String get invSeg2SuppliersEmpty;

  /// No description provided for @invSeg2SuppliersEmptyFiltered.
  ///
  /// In es, this message translates to:
  /// **'Ningún proveedor coincide con la búsqueda.'**
  String get invSeg2SuppliersEmptyFiltered;

  /// No description provided for @invSeg2SuppliersNewFab.
  ///
  /// In es, this message translates to:
  /// **'Nuevo proveedor'**
  String get invSeg2SuppliersNewFab;

  /// No description provided for @invSeg2SuppliersCreateTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo proveedor'**
  String get invSeg2SuppliersCreateTitle;

  /// No description provided for @invSeg2SuppliersEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar proveedor'**
  String get invSeg2SuppliersEditTitle;

  /// No description provided for @invSeg2SuppliersTaxIdLine.
  ///
  /// In es, this message translates to:
  /// **'RUC {p1}'**
  String invSeg2SuppliersTaxIdLine(String p1);

  /// No description provided for @invSeg2SuppliersActive.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get invSeg2SuppliersActive;

  /// No description provided for @invSeg2SuppliersInactive.
  ///
  /// In es, this message translates to:
  /// **'Inactivo'**
  String get invSeg2SuppliersInactive;

  /// No description provided for @invSeg2SupplierBusinessName.
  ///
  /// In es, this message translates to:
  /// **'Razón social'**
  String get invSeg2SupplierBusinessName;

  /// No description provided for @invSeg2SupplierTaxId.
  ///
  /// In es, this message translates to:
  /// **'RUC o documento'**
  String get invSeg2SupplierTaxId;

  /// No description provided for @invSeg2SupplierContact.
  ///
  /// In es, this message translates to:
  /// **'Persona de contacto (opcional)'**
  String get invSeg2SupplierContact;

  /// No description provided for @invSeg2SupplierPhone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono (opcional)'**
  String get invSeg2SupplierPhone;

  /// No description provided for @invSeg2SupplierEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico (opcional)'**
  String get invSeg2SupplierEmail;

  /// No description provided for @invSeg2SupplierAddress.
  ///
  /// In es, this message translates to:
  /// **'Dirección fiscal (opcional)'**
  String get invSeg2SupplierAddress;

  /// No description provided for @invSeg2SupplierActiveToggle.
  ///
  /// In es, this message translates to:
  /// **'Proveedor activo'**
  String get invSeg2SupplierActiveToggle;

  /// No description provided for @invSeg2SupplierErrName.
  ///
  /// In es, this message translates to:
  /// **'Ingresa la razón social del proveedor.'**
  String get invSeg2SupplierErrName;

  /// No description provided for @invSeg2SupplierErrTaxId.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un RUC o documento de 8 a 20 dígitos.'**
  String get invSeg2SupplierErrTaxId;

  /// No description provided for @invSeg2SupplierErrEmail.
  ///
  /// In es, this message translates to:
  /// **'El formato del correo electrónico no es válido.'**
  String get invSeg2SupplierErrEmail;

  /// No description provided for @invSeg2SupplierSaved.
  ///
  /// In es, this message translates to:
  /// **'Proveedor guardado.'**
  String get invSeg2SupplierSaved;

  /// No description provided for @invSeg2PartNewFab.
  ///
  /// In es, this message translates to:
  /// **'Nuevo repuesto'**
  String get invSeg2PartNewFab;

  /// No description provided for @invSeg2PartCreateTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo repuesto'**
  String get invSeg2PartCreateTitle;

  /// No description provided for @invSeg2PartEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar repuesto'**
  String get invSeg2PartEditTitle;

  /// No description provided for @invSeg2PartEditBtn.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get invSeg2PartEditBtn;

  /// No description provided for @invSeg2PartName.
  ///
  /// In es, this message translates to:
  /// **'Nombre del repuesto'**
  String get invSeg2PartName;

  /// No description provided for @invSeg2PartSku.
  ///
  /// In es, this message translates to:
  /// **'Código SKU'**
  String get invSeg2PartSku;

  /// No description provided for @invSeg2PartCategory.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get invSeg2PartCategory;

  /// No description provided for @invSeg2PartBasePrice.
  ///
  /// In es, this message translates to:
  /// **'Precio base sin IGV (S/)'**
  String get invSeg2PartBasePrice;

  /// No description provided for @invSeg2PartMinStock.
  ///
  /// In es, this message translates to:
  /// **'Stock mínimo'**
  String get invSeg2PartMinStock;

  /// No description provided for @invSeg2PartStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado en catálogo'**
  String get invSeg2PartStatus;

  /// No description provided for @invSeg2PartStatusActive.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get invSeg2PartStatusActive;

  /// No description provided for @invSeg2PartStatusInactive.
  ///
  /// In es, this message translates to:
  /// **'Inactivo'**
  String get invSeg2PartStatusInactive;

  /// No description provided for @invSeg2PartStatusDiscontinued.
  ///
  /// In es, this message translates to:
  /// **'Descontinuado'**
  String get invSeg2PartStatusDiscontinued;

  /// No description provided for @invSeg2PartErrName.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el nombre del repuesto.'**
  String get invSeg2PartErrName;

  /// No description provided for @invSeg2PartErrSku.
  ///
  /// In es, this message translates to:
  /// **'Usa de 3 a 50 caracteres (A-Z, 0-9, guion o guion bajo).'**
  String get invSeg2PartErrSku;

  /// No description provided for @invSeg2PartErrPrice.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un precio base igual o mayor a 0.'**
  String get invSeg2PartErrPrice;

  /// No description provided for @invSeg2PartErrMinStock.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un stock mínimo igual o mayor a 0.'**
  String get invSeg2PartErrMinStock;

  /// No description provided for @invSeg2PartSaved.
  ///
  /// In es, this message translates to:
  /// **'Repuesto guardado.'**
  String get invSeg2PartSaved;

  /// No description provided for @invSeg2BatchActionsHeader.
  ///
  /// In es, this message translates to:
  /// **'Movimientos de lote FIFO'**
  String get invSeg2BatchActionsHeader;

  /// No description provided for @invSeg2BatchReceiveBtn.
  ///
  /// In es, this message translates to:
  /// **'Ingresar lote directo'**
  String get invSeg2BatchReceiveBtn;

  /// No description provided for @invSeg2BatchDispatchBtn.
  ///
  /// In es, this message translates to:
  /// **'Despachar FIFO'**
  String get invSeg2BatchDispatchBtn;

  /// No description provided for @invSeg2BatchRestoreBtn.
  ///
  /// In es, this message translates to:
  /// **'Reintegrar lote'**
  String get invSeg2BatchRestoreBtn;

  /// No description provided for @invSeg2BatchReceiveTitle.
  ///
  /// In es, this message translates to:
  /// **'Ingreso directo de lote'**
  String get invSeg2BatchReceiveTitle;

  /// No description provided for @invSeg2BatchDispatchTitle.
  ///
  /// In es, this message translates to:
  /// **'Despacho FIFO'**
  String get invSeg2BatchDispatchTitle;

  /// No description provided for @invSeg2BatchRestoreTitle.
  ///
  /// In es, this message translates to:
  /// **'Reintegrar lote'**
  String get invSeg2BatchRestoreTitle;

  /// No description provided for @invSeg2BatchNumberLabel.
  ///
  /// In es, this message translates to:
  /// **'Número de lote'**
  String get invSeg2BatchNumberLabel;

  /// No description provided for @invSeg2BatchQuantityLabel.
  ///
  /// In es, this message translates to:
  /// **'Cantidad'**
  String get invSeg2BatchQuantityLabel;

  /// No description provided for @invSeg2BatchUnitCostLabel.
  ///
  /// In es, this message translates to:
  /// **'Costo unitario (S/)'**
  String get invSeg2BatchUnitCostLabel;

  /// No description provided for @invSeg2BatchReasonLabel.
  ///
  /// In es, this message translates to:
  /// **'Motivo del reintegro (opcional)'**
  String get invSeg2BatchReasonLabel;

  /// No description provided for @invSeg2BatchSelectLabel.
  ///
  /// In es, this message translates to:
  /// **'Lote de origen'**
  String get invSeg2BatchSelectLabel;

  /// No description provided for @invSeg2BatchSelectAuto.
  ///
  /// In es, this message translates to:
  /// **'Automático (último lote)'**
  String get invSeg2BatchSelectAuto;

  /// No description provided for @invSeg2BatchErrNumber.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el número de lote.'**
  String get invSeg2BatchErrNumber;

  /// No description provided for @invSeg2BatchErrQty.
  ///
  /// In es, this message translates to:
  /// **'La cantidad debe ser al menos 0.01.'**
  String get invSeg2BatchErrQty;

  /// No description provided for @invSeg2BatchErrCost.
  ///
  /// In es, this message translates to:
  /// **'El costo unitario debe ser igual o mayor a 0.'**
  String get invSeg2BatchErrCost;

  /// No description provided for @invSeg2BatchReceivedOk.
  ///
  /// In es, this message translates to:
  /// **'Lote ingresado al inventario.'**
  String get invSeg2BatchReceivedOk;

  /// No description provided for @invSeg2BatchDispatchedOk.
  ///
  /// In es, this message translates to:
  /// **'Despacho FIFO realizado ({p1} u.).'**
  String invSeg2BatchDispatchedOk(String p1);

  /// No description provided for @invSeg2BatchRestoredOk.
  ///
  /// In es, this message translates to:
  /// **'Stock reintegrado ({p1} u.).'**
  String invSeg2BatchRestoredOk(String p1);

  /// No description provided for @invSeg2AlertsCreatePoFab.
  ///
  /// In es, this message translates to:
  /// **'Crear orden de compra'**
  String get invSeg2AlertsCreatePoFab;

  /// No description provided for @invSeg2PartLowStockBanner.
  ///
  /// In es, this message translates to:
  /// **'Existencias bajo el stock mínimo ({p1} / mín. {p2}). Programa una orden de compra o ingresa un lote.'**
  String invSeg2PartLowStockBanner(String p1, String p2);

  /// No description provided for @invSeg2PartOpenPoBtn.
  ///
  /// In es, this message translates to:
  /// **'Ir a órdenes de compra'**
  String get invSeg2PartOpenPoBtn;

  /// No description provided for @invSeg2PoFilterDraft.
  ///
  /// In es, this message translates to:
  /// **'Borradores'**
  String get invSeg2PoFilterDraft;

  /// No description provided for @invSeg2PoFilterCanceled.
  ///
  /// In es, this message translates to:
  /// **'Anuladas'**
  String get invSeg2PoFilterCanceled;

  /// No description provided for @invSeg2PoNewFab.
  ///
  /// In es, this message translates to:
  /// **'Nueva orden'**
  String get invSeg2PoNewFab;

  /// No description provided for @invSeg2PoCreateTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva orden de compra'**
  String get invSeg2PoCreateTitle;

  /// No description provided for @invSeg2PoSelectSupplier.
  ///
  /// In es, this message translates to:
  /// **'Elige un proveedor'**
  String get invSeg2PoSelectSupplier;

  /// No description provided for @invSeg2PoNoSuppliers.
  ///
  /// In es, this message translates to:
  /// **'No hay proveedores activos. Registra uno antes de crear una orden.'**
  String get invSeg2PoNoSuppliers;

  /// No description provided for @invSeg2PoNumberOptional.
  ///
  /// In es, this message translates to:
  /// **'Número de orden (opcional)'**
  String get invSeg2PoNumberOptional;

  /// No description provided for @invSeg2PoNotesOptional.
  ///
  /// In es, this message translates to:
  /// **'Notas internas (opcional)'**
  String get invSeg2PoNotesOptional;

  /// No description provided for @invSeg2PoCreateConfirm.
  ///
  /// In es, this message translates to:
  /// **'Crear borrador'**
  String get invSeg2PoCreateConfirm;

  /// No description provided for @invSeg2PoAddLineBtn.
  ///
  /// In es, this message translates to:
  /// **'Agregar repuesto'**
  String get invSeg2PoAddLineBtn;

  /// No description provided for @invSeg2PoAddLineTitle.
  ///
  /// In es, this message translates to:
  /// **'Agregar línea a la orden'**
  String get invSeg2PoAddLineTitle;

  /// No description provided for @invSeg2PoSelectPart.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un repuesto'**
  String get invSeg2PoSelectPart;

  /// No description provided for @invSeg2PoPartSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar por nombre o SKU'**
  String get invSeg2PoPartSearchHint;

  /// No description provided for @invSeg2PoIssueBtn.
  ///
  /// In es, this message translates to:
  /// **'Emitir orden'**
  String get invSeg2PoIssueBtn;

  /// No description provided for @invSeg2PoIssueHint.
  ///
  /// In es, this message translates to:
  /// **'Agrega al menos un repuesto para poder emitir la orden al proveedor.'**
  String get invSeg2PoIssueHint;

  /// No description provided for @invSeg2PoCancelBtn.
  ///
  /// In es, this message translates to:
  /// **'Anular orden'**
  String get invSeg2PoCancelBtn;

  /// No description provided for @invSeg2PoCancelTitle.
  ///
  /// In es, this message translates to:
  /// **'Anular orden de compra'**
  String get invSeg2PoCancelTitle;

  /// No description provided for @invSeg2PoCancelBody.
  ///
  /// In es, this message translates to:
  /// **'La orden quedará anulada y no podrá recibirse.'**
  String get invSeg2PoCancelBody;

  /// No description provided for @invSeg2PoCancelReason.
  ///
  /// In es, this message translates to:
  /// **'Motivo de anulación (opcional)'**
  String get invSeg2PoCancelReason;

  /// No description provided for @invSeg2PoCancelConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar anulación'**
  String get invSeg2PoCancelConfirm;

  /// No description provided for @invSeg2PoIssuedOk.
  ///
  /// In es, this message translates to:
  /// **'Orden emitida. Ya está lista para recibir.'**
  String get invSeg2PoIssuedOk;

  /// No description provided for @invSeg2PoCanceledOk.
  ///
  /// In es, this message translates to:
  /// **'Orden de compra anulada.'**
  String get invSeg2PoCanceledOk;

  /// No description provided for @invSeg2PoLineAddedOk.
  ///
  /// In es, this message translates to:
  /// **'Repuesto agregado a la orden.'**
  String get invSeg2PoLineAddedOk;

  /// No description provided for @invSeg2PoMissingBranch.
  ///
  /// In es, this message translates to:
  /// **'Tu sesión no tiene sede asignada para crear órdenes.'**
  String get invSeg2PoMissingBranch;

  /// No description provided for @invSeg2PoInitialLineTitle.
  ///
  /// In es, this message translates to:
  /// **'Primer repuesto de la orden'**
  String get invSeg2PoInitialLineTitle;

  /// No description provided for @invSeg2PoNoParts.
  ///
  /// In es, this message translates to:
  /// **'No hay repuestos en el catálogo. Registra un repuesto antes de crear la orden de compra.'**
  String get invSeg2PoNoParts;

  /// No description provided for @invSeg2PoLowStockOnly.
  ///
  /// In es, this message translates to:
  /// **'Solo stock mínimo ({p1})'**
  String invSeg2PoLowStockOnly(int p1);

  /// No description provided for @invSeg2PoLowStockEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay repuestos con stock mínimo que coincidan.'**
  String get invSeg2PoLowStockEmpty;

  /// No description provided for @invSeg2PoGenerateLowStockBtn.
  ///
  /// In es, this message translates to:
  /// **'Generar borrador con stock mínimo ({p1})'**
  String invSeg2PoGenerateLowStockBtn(int p1);

  /// No description provided for @invSeg2PoGenerateLowStockHint.
  ///
  /// In es, this message translates to:
  /// **'Agrega todos los repuestos en o debajo del mínimo con cantidad sugerida.'**
  String get invSeg2PoGenerateLowStockHint;

  /// No description provided for @invSeg2PoPartChipLowStock.
  ///
  /// In es, this message translates to:
  /// **'{p1} ({p2}) · Stock {p3}/{p4}'**
  String invSeg2PoPartChipLowStock(String p1, String p2, String p3, String p4);

  /// No description provided for @invSeg2PoPartChipOutOfStock.
  ///
  /// In es, this message translates to:
  /// **'{p1} ({p2}) · Sin stock (mín. {p3})'**
  String invSeg2PoPartChipOutOfStock(String p1, String p2, String p3);

  /// No description provided for @invSeg2Save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get invSeg2Save;

  /// No description provided for @invSeg2Confirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get invSeg2Confirm;

  /// No description provided for @invSeg2Clear.
  ///
  /// In es, this message translates to:
  /// **'Limpiar'**
  String get invSeg2Clear;

  /// No description provided for @moreHTitle.
  ///
  /// In es, this message translates to:
  /// **'Más'**
  String get moreHTitle;

  /// No description provided for @moreHGroupWorkshop.
  ///
  /// In es, this message translates to:
  /// **'Taller'**
  String get moreHGroupWorkshop;

  /// No description provided for @moreHGroupCashier.
  ///
  /// In es, this message translates to:
  /// **'Caja y reportes'**
  String get moreHGroupCashier;

  /// No description provided for @moreHGroupStock.
  ///
  /// In es, this message translates to:
  /// **'Repuestos'**
  String get moreHGroupStock;

  /// No description provided for @moreHGroupAccount.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get moreHGroupAccount;

  /// No description provided for @moreHBranch.
  ///
  /// In es, this message translates to:
  /// **'Cambiar de sede'**
  String get moreHBranch;

  /// No description provided for @moreHBranchSub.
  ///
  /// In es, this message translates to:
  /// **'Elige la sede con la que trabajas'**
  String get moreHBranchSub;

  /// No description provided for @moreHMyAttendance.
  ///
  /// In es, this message translates to:
  /// **'Mi asistencia'**
  String get moreHMyAttendance;

  /// No description provided for @moreHMyAttendanceSub.
  ///
  /// In es, this message translates to:
  /// **'Marcación GPS, turno y descargos'**
  String get moreHMyAttendanceSub;

  /// No description provided for @moreHMyTasks.
  ///
  /// In es, this message translates to:
  /// **'Mis tareas'**
  String get moreHMyTasks;

  /// No description provided for @moreHMyTasksSub.
  ///
  /// In es, this message translates to:
  /// **'Cronómetro, evidencias y repuestos'**
  String get moreHMyTasksSub;

  /// No description provided for @moreHWorkshopTasks.
  ///
  /// In es, this message translates to:
  /// **'Tareas del taller'**
  String get moreHWorkshopTasks;

  /// No description provided for @moreHWorkshopTasksSub.
  ///
  /// In es, this message translates to:
  /// **'Faenas activas y suspensiones de la sede'**
  String get moreHWorkshopTasksSub;

  /// No description provided for @moreHOrders.
  ///
  /// In es, this message translates to:
  /// **'Órdenes de trabajo'**
  String get moreHOrders;

  /// No description provided for @moreHOrdersSub.
  ///
  /// In es, this message translates to:
  /// **'Órdenes abiertas y proformas de la sede'**
  String get moreHOrdersSub;

  /// No description provided for @moreHReception.
  ///
  /// In es, this message translates to:
  /// **'Recibir vehículo'**
  String get moreHReception;

  /// No description provided for @moreHReceptionSub.
  ///
  /// In es, this message translates to:
  /// **'Busca por placa y abre la orden'**
  String get moreHReceptionSub;

  /// No description provided for @moreHBays.
  ///
  /// In es, this message translates to:
  /// **'Bahías'**
  String get moreHBays;

  /// No description provided for @moreHBaysSub.
  ///
  /// In es, this message translates to:
  /// **'Qué auto ocupa cada bahía'**
  String get moreHBaysSub;

  /// No description provided for @moreHServices.
  ///
  /// In es, this message translates to:
  /// **'Servicios'**
  String get moreHServices;

  /// No description provided for @moreHServicesSub.
  ///
  /// In es, this message translates to:
  /// **'Catálogo de mano de obra y tarifas'**
  String get moreHServicesSub;

  /// No description provided for @moreHObd.
  ///
  /// In es, this message translates to:
  /// **'Escáneres OBD-II'**
  String get moreHObd;

  /// No description provided for @moreHObdSub.
  ///
  /// In es, this message translates to:
  /// **'Equipos de diagnóstico del taller'**
  String get moreHObdSub;

  /// No description provided for @moreHDailyCash.
  ///
  /// In es, this message translates to:
  /// **'Caja del día'**
  String get moreHDailyCash;

  /// No description provided for @moreHDailyCashSub.
  ///
  /// In es, this message translates to:
  /// **'Lo cobrado hoy en la sede'**
  String get moreHDailyCashSub;

  /// No description provided for @moreHVouchers.
  ///
  /// In es, this message translates to:
  /// **'Comprobantes SUNAT'**
  String get moreHVouchers;

  /// No description provided for @moreHVouchersSub.
  ///
  /// In es, this message translates to:
  /// **'Boletas, facturas, notas de crédito'**
  String get moreHVouchersSub;

  /// No description provided for @moreHReports.
  ///
  /// In es, this message translates to:
  /// **'Reportes'**
  String get moreHReports;

  /// No description provided for @moreHReportsSub.
  ///
  /// In es, this message translates to:
  /// **'Flujo de caja y salud de flota en PDF'**
  String get moreHReportsSub;

  /// No description provided for @moreHSeries.
  ///
  /// In es, this message translates to:
  /// **'Series de comprobantes'**
  String get moreHSeries;

  /// No description provided for @moreHSeriesSub.
  ///
  /// In es, this message translates to:
  /// **'Boletas y facturas SUNAT de la sede'**
  String get moreHSeriesSub;

  /// No description provided for @moreHParts.
  ///
  /// In es, this message translates to:
  /// **'Catálogo de repuestos'**
  String get moreHParts;

  /// No description provided for @moreHPartsSub.
  ///
  /// In es, this message translates to:
  /// **'Stock, precios y lotes'**
  String get moreHPartsSub;

  /// No description provided for @moreHAlerts.
  ///
  /// In es, this message translates to:
  /// **'Alertas de stock'**
  String get moreHAlerts;

  /// No description provided for @moreHAlertsSub.
  ///
  /// In es, this message translates to:
  /// **'Repuestos por reponer o agotados'**
  String get moreHAlertsSub;

  /// No description provided for @moreHPurchases.
  ///
  /// In es, this message translates to:
  /// **'Órdenes de compra'**
  String get moreHPurchases;

  /// No description provided for @moreHPurchasesSub.
  ///
  /// In es, this message translates to:
  /// **'Pedidos a proveedores y su recepción'**
  String get moreHPurchasesSub;

  /// No description provided for @moreHSuppliers.
  ///
  /// In es, this message translates to:
  /// **'Proveedores'**
  String get moreHSuppliers;

  /// No description provided for @moreHSuppliersSub.
  ///
  /// In es, this message translates to:
  /// **'Directorio comercial de suministros'**
  String get moreHSuppliersSub;

  /// No description provided for @moreHValuation.
  ///
  /// In es, this message translates to:
  /// **'Valorización'**
  String get moreHValuation;

  /// No description provided for @moreHValuationSub.
  ///
  /// In es, this message translates to:
  /// **'Cuánto vale el inventario'**
  String get moreHValuationSub;

  /// No description provided for @moreHNotifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get moreHNotifications;

  /// No description provided for @moreHNotificationsSub.
  ///
  /// In es, this message translates to:
  /// **'Avisos y alertas del taller'**
  String get moreHNotificationsSub;

  /// No description provided for @moreHSync.
  ///
  /// In es, this message translates to:
  /// **'Pendientes de sincronizar'**
  String get moreHSync;

  /// No description provided for @moreHSyncSub.
  ///
  /// In es, this message translates to:
  /// **'Fotos y propuestas guardadas sin red'**
  String get moreHSyncSub;

  /// No description provided for @moreHProfile.
  ///
  /// In es, this message translates to:
  /// **'Mi cuenta'**
  String get moreHProfile;

  /// No description provided for @moreHProfileSub.
  ///
  /// In es, this message translates to:
  /// **'Perfil, sede y cerrar sesión'**
  String get moreHProfileSub;

  /// No description provided for @mainTabModules.
  ///
  /// In es, this message translates to:
  /// **'Módulos'**
  String get mainTabModules;

  /// No description provided for @mainTabShift.
  ///
  /// In es, this message translates to:
  /// **'Turno'**
  String get mainTabShift;

  /// No description provided for @mainTabPurchases.
  ///
  /// In es, this message translates to:
  /// **'Compras'**
  String get mainTabPurchases;

  /// No description provided for @mainTabCash.
  ///
  /// In es, this message translates to:
  /// **'Caja'**
  String get mainTabCash;

  /// No description provided for @mainTabBays.
  ///
  /// In es, this message translates to:
  /// **'Bahías'**
  String get mainTabBays;

  /// No description provided for @barActionReceive.
  ///
  /// In es, this message translates to:
  /// **'Recibir'**
  String get barActionReceive;

  /// No description provided for @barActionAppointment.
  ///
  /// In es, this message translates to:
  /// **'Cita'**
  String get barActionAppointment;

  /// No description provided for @barActionAppointmentDesc.
  ///
  /// In es, this message translates to:
  /// **'Gestionar citas y recepción'**
  String get barActionAppointmentDesc;

  /// No description provided for @barActionCollect.
  ///
  /// In es, this message translates to:
  /// **'Cobrar'**
  String get barActionCollect;

  /// No description provided for @barActionCollectDesc.
  ///
  /// In es, this message translates to:
  /// **'Ver órdenes listas para cobrar'**
  String get barActionCollectDesc;

  /// No description provided for @barActionScan.
  ///
  /// In es, this message translates to:
  /// **'SKU'**
  String get barActionScan;

  /// No description provided for @barActionScanDesc.
  ///
  /// In es, this message translates to:
  /// **'Buscar o escanear repuesto por SKU'**
  String get barActionScanDesc;

  /// No description provided for @barActionTasks.
  ///
  /// In es, this message translates to:
  /// **'Tareas'**
  String get barActionTasks;

  /// No description provided for @barActionTasksDesc.
  ///
  /// In es, this message translates to:
  /// **'Ir a mis tareas activas'**
  String get barActionTasksDesc;

  /// No description provided for @modulesTitle.
  ///
  /// In es, this message translates to:
  /// **'Todos los módulos'**
  String get modulesTitle;

  /// No description provided for @ordersListTitle.
  ///
  /// In es, this message translates to:
  /// **'Órdenes'**
  String get ordersListTitle;

  /// No description provided for @ordersReceiveVehicle.
  ///
  /// In es, this message translates to:
  /// **'Recibir vehículo'**
  String get ordersReceiveVehicle;

  /// No description provided for @ordersSearchLabel.
  ///
  /// In es, this message translates to:
  /// **'Buscar por placa'**
  String get ordersSearchLabel;

  /// No description provided for @ordersSearchClear.
  ///
  /// In es, this message translates to:
  /// **'Borrar búsqueda'**
  String get ordersSearchClear;

  /// No description provided for @ordersFilterAll.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get ordersFilterAll;

  /// No description provided for @ordersEmptyFiltered.
  ///
  /// In es, this message translates to:
  /// **'Ninguna orden coincide con lo que buscas.'**
  String get ordersEmptyFiltered;

  /// No description provided for @ordersOrderNumber.
  ///
  /// In es, this message translates to:
  /// **'Orden #{p1}'**
  String ordersOrderNumber(int p1);

  /// No description provided for @ordersUpdatedNow.
  ///
  /// In es, this message translates to:
  /// **'Actualizado ahora'**
  String get ordersUpdatedNow;

  /// No description provided for @ordersUpdatedAgo.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{Actualizado hace {count} min} other{Actualizado hace {count} min}}'**
  String ordersUpdatedAgo(int count);

  /// No description provided for @ordersSectionDecisions.
  ///
  /// In es, this message translates to:
  /// **'Esperan tu decisión'**
  String get ordersSectionDecisions;

  /// No description provided for @ordersSectionData.
  ///
  /// In es, this message translates to:
  /// **'Datos de la orden'**
  String get ordersSectionData;

  /// No description provided for @ordersSectionProposals.
  ///
  /// In es, this message translates to:
  /// **'Propuestas por hallazgo'**
  String get ordersSectionProposals;

  /// No description provided for @ordersSectionPhotos.
  ///
  /// In es, this message translates to:
  /// **'Fotos de recepción'**
  String get ordersSectionPhotos;

  /// No description provided for @ordersSectionQuotation.
  ///
  /// In es, this message translates to:
  /// **'Proforma'**
  String get ordersSectionQuotation;

  /// No description provided for @ordersSectionCosts.
  ///
  /// In es, this message translates to:
  /// **'Costos y repuestos'**
  String get ordersSectionCosts;

  /// No description provided for @ordersSeeAll.
  ///
  /// In es, this message translates to:
  /// **'Ver todas'**
  String get ordersSeeAll;

  /// No description provided for @ordersBayLabel.
  ///
  /// In es, this message translates to:
  /// **'Bahía de trabajo'**
  String get ordersBayLabel;

  /// No description provided for @ordersBayNone.
  ///
  /// In es, this message translates to:
  /// **'Sin bahía asignada'**
  String get ordersBayNone;

  /// No description provided for @ordersBayChange.
  ///
  /// In es, this message translates to:
  /// **'Cambiar'**
  String get ordersBayChange;

  /// No description provided for @ordersBayAssign.
  ///
  /// In es, this message translates to:
  /// **'Asignar'**
  String get ordersBayAssign;

  /// No description provided for @ordersMileageLabel.
  ///
  /// In es, this message translates to:
  /// **'Kilometraje al ingreso'**
  String get ordersMileageLabel;

  /// No description provided for @ordersDiagnosticLabel.
  ///
  /// In es, this message translates to:
  /// **'Motivo de ingreso'**
  String get ordersDiagnosticLabel;

  /// No description provided for @ordersPhotosCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{{count} foto} other{{count} fotos}}'**
  String ordersPhotosCount(int count);

  /// No description provided for @ordersCheckout.
  ///
  /// In es, this message translates to:
  /// **'Cobrar y entregar'**
  String get ordersCheckout;

  /// No description provided for @ordersActionStart.
  ///
  /// In es, this message translates to:
  /// **'Iniciar orden'**
  String get ordersActionStart;

  /// No description provided for @ordersActionComplete.
  ///
  /// In es, this message translates to:
  /// **'Completar orden'**
  String get ordersActionComplete;

  /// No description provided for @ordersActionCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar orden'**
  String get ordersActionCancel;

  /// No description provided for @ordersStartedNotice.
  ///
  /// In es, this message translates to:
  /// **'Orden iniciada. Los técnicos ya pueden empezar.'**
  String get ordersStartedNotice;

  /// No description provided for @ordersCompletedNotice.
  ///
  /// In es, this message translates to:
  /// **'Orden completada. Ya se puede cobrar y entregar.'**
  String get ordersCompletedNotice;

  /// No description provided for @ordersCanceledNotice.
  ///
  /// In es, this message translates to:
  /// **'Orden cancelada. Los repuestos reservados volvieron al inventario.'**
  String get ordersCanceledNotice;

  /// No description provided for @ordersCancelTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cancelar la orden?'**
  String get ordersCancelTitle;

  /// No description provided for @ordersCancelBody.
  ///
  /// In es, this message translates to:
  /// **'Se libera la bahía y los repuestos reservados vuelven al inventario. No se puede deshacer.'**
  String get ordersCancelBody;

  /// No description provided for @ordersCancelReasonLabel.
  ///
  /// In es, this message translates to:
  /// **'Motivo de la cancelación'**
  String get ordersCancelReasonLabel;

  /// No description provided for @ordersCancelReasonHint.
  ///
  /// In es, this message translates to:
  /// **'El cliente decidió no repararlo'**
  String get ordersCancelReasonHint;

  /// No description provided for @ordersCancelFieldError.
  ///
  /// In es, this message translates to:
  /// **'Escribe el motivo de la cancelación (máximo 1000 caracteres).'**
  String get ordersCancelFieldError;

  /// No description provided for @ordersCancelConfirm.
  ///
  /// In es, this message translates to:
  /// **'Sí, cancelar orden'**
  String get ordersCancelConfirm;

  /// No description provided for @ordersDecisionSuspension.
  ///
  /// In es, this message translates to:
  /// **'Suspensión: {p1}'**
  String ordersDecisionSuspension(String p1);

  /// No description provided for @ordersDecisionProposal.
  ///
  /// In es, this message translates to:
  /// **'Propuesta: {p1}'**
  String ordersDecisionProposal(String p1);

  /// No description provided for @ordersQuotationDecisionTitle.
  ///
  /// In es, this message translates to:
  /// **'Proforma sin respuesta'**
  String get ordersQuotationDecisionTitle;

  /// No description provided for @ordersQuotationDecisionRowHint.
  ///
  /// In es, this message translates to:
  /// **'Registra lo que respondió el cliente'**
  String get ordersQuotationDecisionRowHint;

  /// No description provided for @ordersQuotationSendShort.
  ///
  /// In es, this message translates to:
  /// **'Enviar por correo'**
  String get ordersQuotationSendShort;

  /// No description provided for @ordersSuspensionTitle.
  ///
  /// In es, this message translates to:
  /// **'Suspensión por validar'**
  String get ordersSuspensionTitle;

  /// No description provided for @ordersSuspensionNoReason.
  ///
  /// In es, this message translates to:
  /// **'El mecánico no indicó el motivo.'**
  String get ordersSuspensionNoReason;

  /// No description provided for @ordersSuspensionMissingItem.
  ///
  /// In es, this message translates to:
  /// **'Falta: {p1}'**
  String ordersSuspensionMissingItem(String p1);

  /// No description provided for @ordersSuspensionApprove.
  ///
  /// In es, this message translates to:
  /// **'Aprobar suspensión'**
  String get ordersSuspensionApprove;

  /// No description provided for @ordersSuspensionReject.
  ///
  /// In es, this message translates to:
  /// **'Rechazar suspensión'**
  String get ordersSuspensionReject;

  /// No description provided for @ordersSuspensionApprovedNotice.
  ///
  /// In es, this message translates to:
  /// **'Suspensión aprobada. La tarea queda detenida hasta que llegue el repuesto.'**
  String get ordersSuspensionApprovedNotice;

  /// No description provided for @ordersSuspensionRejectedNotice.
  ///
  /// In es, this message translates to:
  /// **'Suspensión rechazada. El mecánico sigue con la tarea.'**
  String get ordersSuspensionRejectedNotice;

  /// No description provided for @ordersResumeTask.
  ///
  /// In es, this message translates to:
  /// **'Reanudar tarea'**
  String get ordersResumeTask;

  /// No description provided for @ordersTaskResumedNotice.
  ///
  /// In es, this message translates to:
  /// **'Tarea reanudada. Se avisó al mecánico.'**
  String get ordersTaskResumedNotice;

  /// No description provided for @ordersProposalsResolved.
  ///
  /// In es, this message translates to:
  /// **'Ya resueltas'**
  String get ordersProposalsResolved;

  /// No description provided for @ordersProposalSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Propuesta de hallazgo'**
  String get ordersProposalSheetTitle;

  /// No description provided for @ordersProfitabilityTitle.
  ///
  /// In es, this message translates to:
  /// **'Rentabilidad'**
  String get ordersProfitabilityTitle;

  /// No description provided for @ordersProfitabilityHint.
  ///
  /// In es, this message translates to:
  /// **'Ingreso de repuestos contra su costo'**
  String get ordersProfitabilityHint;

  /// No description provided for @ordersProfitLaborRevenue.
  ///
  /// In es, this message translates to:
  /// **'Ingreso por mano de obra'**
  String get ordersProfitLaborRevenue;

  /// No description provided for @ordersProfitPartsRevenue.
  ///
  /// In es, this message translates to:
  /// **'Ingreso por repuestos'**
  String get ordersProfitPartsRevenue;

  /// No description provided for @ordersProfitCostOfSales.
  ///
  /// In es, this message translates to:
  /// **'Costo de los repuestos'**
  String get ordersProfitCostOfSales;

  /// No description provided for @ordersProfitPartsGross.
  ///
  /// In es, this message translates to:
  /// **'Ganancia de repuestos'**
  String get ordersProfitPartsGross;

  /// No description provided for @ordersProfitSubtotal.
  ///
  /// In es, this message translates to:
  /// **'Subtotal sin IGV'**
  String get ordersProfitSubtotal;

  /// No description provided for @ordersProfitLines.
  ///
  /// In es, this message translates to:
  /// **'Por repuesto'**
  String get ordersProfitLines;

  /// No description provided for @ordersProfitLineDetail.
  ///
  /// In es, this message translates to:
  /// **'{p1} unid. · costo {p2}'**
  String ordersProfitLineDetail(String p1, String p2);

  /// No description provided for @ordersMovementsTitle.
  ///
  /// In es, this message translates to:
  /// **'Movimientos de repuestos'**
  String get ordersMovementsTitle;

  /// No description provided for @ordersMovementsHint.
  ///
  /// In es, this message translates to:
  /// **'De qué lote salió cada repuesto y cuánto volvió'**
  String get ordersMovementsHint;

  /// No description provided for @ordersMovementsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Esta orden aún no tiene repuestos imputados.'**
  String get ordersMovementsEmpty;

  /// No description provided for @ordersMovementDetail.
  ///
  /// In es, this message translates to:
  /// **'Salió {p1} · volvió {p2}'**
  String ordersMovementDetail(String p1, String p2);

  /// No description provided for @premiumSearchModePlate.
  ///
  /// In es, this message translates to:
  /// **'Placa'**
  String get premiumSearchModePlate;

  /// No description provided for @premiumSearchModeDocument.
  ///
  /// In es, this message translates to:
  /// **'DNI / RUC'**
  String get premiumSearchModeDocument;

  /// No description provided for @premiumPartStockLevel.
  ///
  /// In es, this message translates to:
  /// **'Nivel de stock'**
  String get premiumPartStockLevel;

  /// No description provided for @premiumPartStockRatio.
  ///
  /// In es, this message translates to:
  /// **'{p1} / mín. {p2}'**
  String premiumPartStockRatio(String p1, String p2);

  /// No description provided for @premiumPartStockHealthy.
  ///
  /// In es, this message translates to:
  /// **'Sobre el mínimo'**
  String get premiumPartStockHealthy;

  /// No description provided for @premiumPartStockLow.
  ///
  /// In es, this message translates to:
  /// **'En el mínimo o debajo'**
  String get premiumPartStockLow;

  /// No description provided for @premiumPartStockOut.
  ///
  /// In es, this message translates to:
  /// **'Sin existencias'**
  String get premiumPartStockOut;

  /// No description provided for @premiumValuationHealthTitle.
  ///
  /// In es, this message translates to:
  /// **'Salud del inventario'**
  String get premiumValuationHealthTitle;

  /// No description provided for @premiumValuationHealthSummary.
  ///
  /// In es, this message translates to:
  /// **'{p1} con stock · {p2} en mínimo · {p3} agotados'**
  String premiumValuationHealthSummary(int p1, int p2, int p3);

  /// No description provided for @premiumValuationCategoryMin.
  ///
  /// In es, this message translates to:
  /// **'Mínimo {p1} u.'**
  String premiumValuationCategoryMin(String p1);

  /// No description provided for @premiumCheckoutRailVoucher.
  ///
  /// In es, this message translates to:
  /// **'Comprobante'**
  String get premiumCheckoutRailVoucher;

  /// No description provided for @premiumCheckoutRailPayment.
  ///
  /// In es, this message translates to:
  /// **'Cobro'**
  String get premiumCheckoutRailPayment;

  /// No description provided for @premiumCheckoutRailPass.
  ///
  /// In es, this message translates to:
  /// **'Pase'**
  String get premiumCheckoutRailPass;

  /// No description provided for @premiumCheckoutRailDelivery.
  ///
  /// In es, this message translates to:
  /// **'Entrega'**
  String get premiumCheckoutRailDelivery;

  /// No description provided for @premiumCheckoutRailDone.
  ///
  /// In es, this message translates to:
  /// **'Flujo completado'**
  String get premiumCheckoutRailDone;

  /// No description provided for @premiumCheckoutRailStepOf.
  ///
  /// In es, this message translates to:
  /// **'Etapa {p1} de 4'**
  String premiumCheckoutRailStepOf(int p1);

  /// No description provided for @premiumDailyMethodShare.
  ///
  /// In es, this message translates to:
  /// **'{p1} %'**
  String premiumDailyMethodShare(int p1);

  /// No description provided for @pitGeofenceLocating.
  ///
  /// In es, this message translates to:
  /// **'Calibrando señal GPS…'**
  String get pitGeofenceLocating;

  /// No description provided for @pitTaskProgressLabel.
  ///
  /// In es, this message translates to:
  /// **'Avance estimado'**
  String get pitTaskProgressLabel;

  /// No description provided for @pitTaskElapsedVsEst.
  ///
  /// In es, this message translates to:
  /// **'{p1}h {p2}m / {p3} h'**
  String pitTaskElapsedVsEst(int p1, int p2, String p3);

  /// No description provided for @pitDockRunning.
  ///
  /// In es, this message translates to:
  /// **'Labor en curso'**
  String get pitDockRunning;

  /// No description provided for @pitDockPaused.
  ///
  /// In es, this message translates to:
  /// **'Labor en pausa'**
  String get pitDockPaused;

  /// No description provided for @pitDockReady.
  ///
  /// In es, this message translates to:
  /// **'Lista para iniciar'**
  String get pitDockReady;

  /// No description provided for @pitReportScoreMax.
  ///
  /// In es, this message translates to:
  /// **'/ 100'**
  String get pitReportScoreMax;

  /// No description provided for @pitReportScoreCd.
  ///
  /// In es, this message translates to:
  /// **'Puntaje de salud vehicular: {p1} de 100'**
  String pitReportScoreCd(int p1);

  /// No description provided for @todayCarsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin autos'**
  String get todayCarsEmpty;

  /// No description provided for @todayFigureReadyShort.
  ///
  /// In es, this message translates to:
  /// **'listos'**
  String get todayFigureReadyShort;

  /// No description provided for @todayLiveBayBadge.
  ///
  /// In es, this message translates to:
  /// **'En vivo'**
  String get todayLiveBayBadge;

  /// No description provided for @baysFilterAllShort.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get baysFilterAllShort;

  /// No description provided for @baysFilterAvailableShort.
  ///
  /// In es, this message translates to:
  /// **'Libres'**
  String get baysFilterAvailableShort;

  /// No description provided for @baysFilterOccupiedShort.
  ///
  /// In es, this message translates to:
  /// **'Ocupadas'**
  String get baysFilterOccupiedShort;

  /// No description provided for @baysFilterMaintenanceShort.
  ///
  /// In es, this message translates to:
  /// **'Mant.'**
  String get baysFilterMaintenanceShort;

  /// No description provided for @baysOccupancyTitle.
  ///
  /// In es, this message translates to:
  /// **'Ocupación de bahías'**
  String get baysOccupancyTitle;

  /// No description provided for @baysOccupancyFraction.
  ///
  /// In es, this message translates to:
  /// **'{p1}/{p2}'**
  String baysOccupancyFraction(int p1, int p2);

  /// No description provided for @baysOccupancyBreakdown.
  ///
  /// In es, this message translates to:
  /// **'{p1} libres · {p2} en mantenimiento'**
  String baysOccupancyBreakdown(int p1, int p2);

  /// No description provided for @syncSummaryTitle.
  ///
  /// In es, this message translates to:
  /// **'Estado de la cola'**
  String get syncSummaryTitle;

  /// No description provided for @syncSummaryCounts.
  ///
  /// In es, this message translates to:
  /// **'{p1} en cola · {p2} enviando · {p3} con error'**
  String syncSummaryCounts(int p1, int p2, int p3);

  /// No description provided for @notifSummaryTitle.
  ///
  /// In es, this message translates to:
  /// **'Requieren atención'**
  String get notifSummaryTitle;

  /// No description provided for @notifSummaryBody.
  ///
  /// In es, this message translates to:
  /// **'Revisa alertas de stock, descargos y aprobaciones pendientes.'**
  String get notifSummaryBody;

  /// No description provided for @profileAccountSummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen de cuenta'**
  String get profileAccountSummary;

  /// No description provided for @receptionSearchTitle.
  ///
  /// In es, this message translates to:
  /// **'Recibir vehículo'**
  String get receptionSearchTitle;

  /// No description provided for @receptionSearchPlatePlaceholder.
  ///
  /// In es, this message translates to:
  /// **'ABC-123'**
  String get receptionSearchPlatePlaceholder;

  /// No description provided for @receptionSearchByDocument.
  ///
  /// In es, this message translates to:
  /// **'Buscar por DNI o RUC'**
  String get receptionSearchByDocument;

  /// No description provided for @receptionSearchByPlate.
  ///
  /// In es, this message translates to:
  /// **'Buscar por placa'**
  String get receptionSearchByPlate;

  /// No description provided for @receptionSearchOfflineCache.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Buscas entre los datos guardados en este teléfono.'**
  String get receptionSearchOfflineCache;

  /// No description provided for @receptionSearchNoAccess.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil no tiene acceso a Recepción.'**
  String get receptionSearchNoAccess;

  /// No description provided for @receptionSearchNoSearchPermission.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil no puede buscar vehículos ni clientes.'**
  String get receptionSearchNoSearchPermission;

  /// No description provided for @receptionPlateNotFound.
  ///
  /// In es, this message translates to:
  /// **'No hay un vehículo con la placa {p1}.'**
  String receptionPlateNotFound(String p1);

  /// No description provided for @receptionOpenOrder.
  ///
  /// In es, this message translates to:
  /// **'Abrir orden'**
  String get receptionOpenOrder;

  /// No description provided for @receptionAddVehicle.
  ///
  /// In es, this message translates to:
  /// **'Agregar vehículo'**
  String get receptionAddVehicle;

  /// No description provided for @receptionSelected.
  ///
  /// In es, this message translates to:
  /// **'Elegido'**
  String get receptionSelected;

  /// No description provided for @receptionAppointmentNoCustomer.
  ///
  /// In es, this message translates to:
  /// **'Cliente sin cargar'**
  String get receptionAppointmentNoCustomer;

  /// No description provided for @receptionArriveTitle.
  ///
  /// In es, this message translates to:
  /// **'Registrar llegada'**
  String get receptionArriveTitle;

  /// No description provided for @receptionArriveConfirm.
  ///
  /// In es, this message translates to:
  /// **'Registrar llegada'**
  String get receptionArriveConfirm;

  /// No description provided for @receptionArriveTime.
  ///
  /// In es, this message translates to:
  /// **'Hora de la cita: {p1}'**
  String receptionArriveTime(String p1);

  /// No description provided for @receptionFormVehicleTitle.
  ///
  /// In es, this message translates to:
  /// **'Agregar vehículo'**
  String get receptionFormVehicleTitle;

  /// No description provided for @teamTitle.
  ///
  /// In es, this message translates to:
  /// **'Equipo'**
  String get teamTitle;

  /// No description provided for @teamNoPermission.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta no puede ver la asistencia del equipo.'**
  String get teamNoPermission;

  /// No description provided for @teamTabTeam.
  ///
  /// In es, this message translates to:
  /// **'Equipo'**
  String get teamTabTeam;

  /// No description provided for @teamTabMine.
  ///
  /// In es, this message translates to:
  /// **'Mi asistencia'**
  String get teamTabMine;

  /// No description provided for @teamOffline.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. La asistencia del equipo necesita red para actualizarse.'**
  String get teamOffline;

  /// No description provided for @teamLegend.
  ///
  /// In es, this message translates to:
  /// **'{p1} de {p2}'**
  String teamLegend(int p1, int p2);

  /// No description provided for @teamCaption.
  ///
  /// In es, this message translates to:
  /// **'en turno ahora'**
  String get teamCaption;

  /// No description provided for @teamFigureOnTime.
  ///
  /// In es, this message translates to:
  /// **'puntuales'**
  String get teamFigureOnTime;

  /// No description provided for @teamFigureLate.
  ///
  /// In es, this message translates to:
  /// **'tardanzas'**
  String get teamFigureLate;

  /// No description provided for @teamFigureAbsent.
  ///
  /// In es, this message translates to:
  /// **'faltas'**
  String get teamFigureAbsent;

  /// No description provided for @teamToday.
  ///
  /// In es, this message translates to:
  /// **'Asistencia de hoy'**
  String get teamToday;

  /// No description provided for @teamEmpty.
  ///
  /// In es, this message translates to:
  /// **'Nadie ha marcado asistencia hoy en esta sede.'**
  String get teamEmpty;

  /// No description provided for @teamNoClockIn.
  ///
  /// In es, this message translates to:
  /// **'Sin entrada registrada'**
  String get teamNoClockIn;

  /// No description provided for @teamClockRange.
  ///
  /// In es, this message translates to:
  /// **'Entró {p1} · salió {p2}'**
  String teamClockRange(String p1, String p2);

  /// No description provided for @teamClockInOpen.
  ///
  /// In es, this message translates to:
  /// **'Entró {p1} · en turno'**
  String teamClockInOpen(String p1);

  /// No description provided for @teamStatusOnTime.
  ///
  /// In es, this message translates to:
  /// **'Puntual'**
  String get teamStatusOnTime;

  /// No description provided for @teamStatusLate.
  ///
  /// In es, this message translates to:
  /// **'Tarde'**
  String get teamStatusLate;

  /// No description provided for @teamStatusAbsent.
  ///
  /// In es, this message translates to:
  /// **'Falta'**
  String get teamStatusAbsent;

  /// No description provided for @teamStatusExcused.
  ///
  /// In es, this message translates to:
  /// **'Justificada'**
  String get teamStatusExcused;

  /// No description provided for @baysOffline.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Ves el último tablero guardado; reasignar y crear bahías necesita red.'**
  String get baysOffline;

  /// No description provided for @baysLabor.
  ///
  /// In es, this message translates to:
  /// **'Mano de obra {p1}'**
  String baysLabor(String p1);

  /// No description provided for @baysTapToAssign.
  ///
  /// In es, this message translates to:
  /// **'Toca para ingresar una orden'**
  String get baysTapToAssign;

  /// No description provided for @baysUnavailableError.
  ///
  /// In es, this message translates to:
  /// **'Esa bahía no está libre. Elige otra.'**
  String get baysUnavailableError;

  /// No description provided for @baysNoAssignableOrders.
  ///
  /// In es, this message translates to:
  /// **'No hay órdenes activas sin bahía.'**
  String get baysNoAssignableOrders;

  /// No description provided for @baysNameError.
  ///
  /// In es, this message translates to:
  /// **'Escribe un nombre de hasta 100 caracteres.'**
  String get baysNameError;

  /// No description provided for @baysMechanicsSection.
  ///
  /// In es, this message translates to:
  /// **'Mecánicos y faenas en bahía'**
  String get baysMechanicsSection;

  /// No description provided for @notifTitle.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notifTitle;

  /// No description provided for @notifSectionAttention.
  ///
  /// In es, this message translates to:
  /// **'Piden tu atención'**
  String get notifSectionAttention;

  /// No description provided for @notifSectionReceived.
  ///
  /// In es, this message translates to:
  /// **'Avisos de esta sesión'**
  String get notifSectionReceived;

  /// No description provided for @notifEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aquí verás los avisos de tareas, stock y asistencia cuando lleguen.'**
  String get notifEmpty;

  /// No description provided for @notifUnread.
  ///
  /// In es, this message translates to:
  /// **'Nuevo'**
  String get notifUnread;

  /// No description provided for @notifDraftChip.
  ///
  /// In es, this message translates to:
  /// **'Sin iniciar'**
  String get notifDraftChip;

  /// No description provided for @notifSyncPendingBody.
  ///
  /// In es, this message translates to:
  /// **'Toca para revisarlos o reenviarlos.'**
  String get notifSyncPendingBody;

  /// No description provided for @notifSyncPending.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{{count} registro sin enviar} other{{count} registros sin enviar}}'**
  String notifSyncPending(int count);

  /// No description provided for @syncEmptyLine.
  ///
  /// In es, this message translates to:
  /// **'Todo sincronizado. No hay nada pendiente de envío.'**
  String get syncEmptyLine;

  /// No description provided for @syncDiscardWarning.
  ///
  /// In es, this message translates to:
  /// **'Si lo descartas, este registro se borra del teléfono y no llega al servidor.'**
  String get syncDiscardWarning;

  /// No description provided for @profileSectionWorkshop.
  ///
  /// In es, this message translates to:
  /// **'Mi taller'**
  String get profileSectionWorkshop;

  /// No description provided for @profileLabelWorkshop.
  ///
  /// In es, this message translates to:
  /// **'Taller'**
  String get profileLabelWorkshop;

  /// No description provided for @profileLabelBranch.
  ///
  /// In es, this message translates to:
  /// **'Sede actual'**
  String get profileLabelBranch;

  /// No description provided for @profileBranchChange.
  ///
  /// In es, this message translates to:
  /// **'Sede actual · Cambiar sede'**
  String get profileBranchChange;

  /// No description provided for @profileBranchUnknown.
  ///
  /// In es, this message translates to:
  /// **'Sin sede elegida'**
  String get profileBranchUnknown;

  /// No description provided for @profileModuleObd.
  ///
  /// In es, this message translates to:
  /// **'Escáneres OBD-II'**
  String get profileModuleObd;

  /// No description provided for @profileModuleAi.
  ///
  /// In es, this message translates to:
  /// **'Diagnóstico con IA'**
  String get profileModuleAi;

  /// No description provided for @profileModuleNone.
  ///
  /// In es, this message translates to:
  /// **'Módulos básicos'**
  String get profileModuleNone;

  /// No description provided for @profileNoUnread.
  ///
  /// In es, this message translates to:
  /// **'Sin avisos nuevos'**
  String get profileNoUnread;

  /// No description provided for @profileUnreadCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{{count} aviso sin leer} other{{count} avisos sin leer}}'**
  String profileUnreadCount(int count);

  /// No description provided for @profileSignOutSub.
  ///
  /// In es, this message translates to:
  /// **'Salir de Atelier en este teléfono'**
  String get profileSignOutSub;

  /// No description provided for @profileSignOutPlain.
  ///
  /// In es, this message translates to:
  /// **'Vas a salir de Atelier en este teléfono. Para volver a entrar necesitarás tu correo y tu contraseña.'**
  String get profileSignOutPlain;

  /// No description provided for @obdPlanLocked.
  ///
  /// In es, this message translates to:
  /// **'Los escáneres OBD-II no están incluidos en el plan de este taller.'**
  String get obdPlanLocked;

  /// No description provided for @obdNoPermission.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta no puede ver los escáneres del taller.'**
  String get obdNoPermission;

  /// No description provided for @obdOffline.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Registrar, vincular y cambiar el estado de un escáner necesita red.'**
  String get obdOffline;

  /// No description provided for @obdNoVehicles.
  ///
  /// In es, this message translates to:
  /// **'No hay vehículos del taller guardados en este teléfono.'**
  String get obdNoVehicles;

  /// No description provided for @obdVehicleHasScanner.
  ///
  /// In es, this message translates to:
  /// **'Ya tiene un escáner vinculado'**
  String get obdVehicleHasScanner;

  /// No description provided for @obdFirmwareFormat.
  ///
  /// In es, this message translates to:
  /// **'FW {p1}'**
  String obdFirmwareFormat(String p1);

  /// No description provided for @obdHintIdentifier.
  ///
  /// In es, this message translates to:
  /// **'Ej. AA:BB:CC:11:22:33'**
  String get obdHintIdentifier;

  /// No description provided for @obdHintModel.
  ///
  /// In es, this message translates to:
  /// **'Ej. ELM327 v1.5 u OBDLink MX+'**
  String get obdHintModel;

  /// No description provided for @obdHintFirmware.
  ///
  /// In es, this message translates to:
  /// **'Ej. 2.1'**
  String get obdHintFirmware;

  /// No description provided for @obdConnBluetooth.
  ///
  /// In es, this message translates to:
  /// **'Bluetooth'**
  String get obdConnBluetooth;

  /// No description provided for @obdConnWifi.
  ///
  /// In es, this message translates to:
  /// **'Wi-Fi'**
  String get obdConnWifi;

  /// No description provided for @obdConnUsb.
  ///
  /// In es, this message translates to:
  /// **'USB'**
  String get obdConnUsb;

  /// No description provided for @tasksWorkshopTitle.
  ///
  /// In es, this message translates to:
  /// **'Tareas del taller'**
  String get tasksWorkshopTitle;

  /// No description provided for @tasksWorkshopPanelCaption.
  ///
  /// In es, this message translates to:
  /// **'activas en la sede'**
  String get tasksWorkshopPanelCaption;

  /// No description provided for @tasksWorkshopEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay tareas activas en las órdenes de la sede.'**
  String get tasksWorkshopEmpty;

  /// No description provided for @tasksSeg2PanelContext.
  ///
  /// In es, this message translates to:
  /// **'Bandeja de bahía'**
  String get tasksSeg2PanelContext;

  /// No description provided for @tasksSeg2PanelCaption.
  ///
  /// In es, this message translates to:
  /// **'asignadas en tu turno'**
  String get tasksSeg2PanelCaption;

  /// No description provided for @tasksSeg2LegendCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{{count} tarea} other{{count} tareas}}'**
  String tasksSeg2LegendCount(int count);

  /// No description provided for @tasksSeg2FigurePending.
  ///
  /// In es, this message translates to:
  /// **'pendientes'**
  String get tasksSeg2FigurePending;

  /// No description provided for @tasksSeg2FigureInProgress.
  ///
  /// In es, this message translates to:
  /// **'en curso'**
  String get tasksSeg2FigureInProgress;

  /// No description provided for @tasksSeg2FigurePaused.
  ///
  /// In es, this message translates to:
  /// **'en pausa'**
  String get tasksSeg2FigurePaused;

  /// No description provided for @tasksSeg2FilterAssigned.
  ///
  /// In es, this message translates to:
  /// **'Asignadas'**
  String get tasksSeg2FilterAssigned;

  /// No description provided for @tasksSeg2FilterSuspended.
  ///
  /// In es, this message translates to:
  /// **'Suspendidas'**
  String get tasksSeg2FilterSuspended;

  /// No description provided for @tasksSeg2EmptyFiltered.
  ///
  /// In es, this message translates to:
  /// **'Ninguna tarea coincide con este filtro.'**
  String get tasksSeg2EmptyFiltered;

  /// No description provided for @tasksSeg2MetaNoPlate.
  ///
  /// In es, this message translates to:
  /// **'Sin placa'**
  String get tasksSeg2MetaNoPlate;

  /// No description provided for @tasksSeg2QuickActions.
  ///
  /// In es, this message translates to:
  /// **'Accesos rápidos'**
  String get tasksSeg2QuickActions;

  /// No description provided for @tasksSeg2ActionObd.
  ///
  /// In es, this message translates to:
  /// **'Escáner OBD-II'**
  String get tasksSeg2ActionObd;

  /// No description provided for @tasksSeg2ActionFinding.
  ///
  /// In es, this message translates to:
  /// **'Reportar hallazgo'**
  String get tasksSeg2ActionFinding;

  /// No description provided for @tasksSeg2ControlsSection.
  ///
  /// In es, this message translates to:
  /// **'Control de labor'**
  String get tasksSeg2ControlsSection;

  /// No description provided for @tasksSeg2DescriptionSection.
  ///
  /// In es, this message translates to:
  /// **'Detalle técnico'**
  String get tasksSeg2DescriptionSection;

  /// No description provided for @tasksSeg2TimerEstimated.
  ///
  /// In es, this message translates to:
  /// **'Est. {p1} h'**
  String tasksSeg2TimerEstimated(String p1);

  /// No description provided for @tasksSeg2EvidenceSection.
  ///
  /// In es, this message translates to:
  /// **'Evidencias fotográficas'**
  String get tasksSeg2EvidenceSection;

  /// No description provided for @tasksSeg2EvidenceKindLabel.
  ///
  /// In es, this message translates to:
  /// **'Momento de la foto'**
  String get tasksSeg2EvidenceKindLabel;

  /// No description provided for @tasksSeg2EvidenceDisassembly.
  ///
  /// In es, this message translates to:
  /// **'Desmontaje'**
  String get tasksSeg2EvidenceDisassembly;

  /// No description provided for @tasksSeg2EvidenceAssembly.
  ///
  /// In es, this message translates to:
  /// **'Montaje'**
  String get tasksSeg2EvidenceAssembly;

  /// No description provided for @tasksSeg2EvidenceNoteLabel.
  ///
  /// In es, this message translates to:
  /// **'Nota de evidencia (opcional)'**
  String get tasksSeg2EvidenceNoteLabel;

  /// No description provided for @tasksSeg2EvidenceNoteHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. pastilla desgastada al 10 %'**
  String get tasksSeg2EvidenceNoteHint;

  /// No description provided for @tasksSeg2EvidenceTakePhoto.
  ///
  /// In es, this message translates to:
  /// **'Tomar foto'**
  String get tasksSeg2EvidenceTakePhoto;

  /// No description provided for @tasksSeg2EvidencePickGallery.
  ///
  /// In es, this message translates to:
  /// **'Elegir de la galería'**
  String get tasksSeg2EvidencePickGallery;

  /// No description provided for @tasksSeg2EvidenceEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay fotos de desmontaje o montaje.'**
  String get tasksSeg2EvidenceEmpty;

  /// No description provided for @tasksSeg2EvidenceQueued.
  ///
  /// In es, this message translates to:
  /// **'Foto guardada. Se subirá al recuperar señal.'**
  String get tasksSeg2EvidenceQueued;

  /// No description provided for @tasksSeg2EvidenceFieldError.
  ///
  /// In es, this message translates to:
  /// **'La nota supera los 500 caracteres.'**
  String get tasksSeg2EvidenceFieldError;

  /// No description provided for @tasksSeg2SuspensionSection.
  ///
  /// In es, this message translates to:
  /// **'Suspensión de tarea'**
  String get tasksSeg2SuspensionSection;

  /// No description provided for @tasksSeg2SuspensionRequestBtn.
  ///
  /// In es, this message translates to:
  /// **'Solicitar suspensión'**
  String get tasksSeg2SuspensionRequestBtn;

  /// No description provided for @tasksSeg2SuspensionRequestTitle.
  ///
  /// In es, this message translates to:
  /// **'Solicitar suspensión'**
  String get tasksSeg2SuspensionRequestTitle;

  /// No description provided for @tasksSeg2SuspensionRequestBody.
  ///
  /// In es, this message translates to:
  /// **'Indica el repuesto faltante o defectuoso para que el supervisor valide la pausa.'**
  String get tasksSeg2SuspensionRequestBody;

  /// No description provided for @tasksSeg2SuspensionItemLabel.
  ///
  /// In es, this message translates to:
  /// **'Descripción de la pieza o motivo'**
  String get tasksSeg2SuspensionItemLabel;

  /// No description provided for @tasksSeg2SuspensionItemHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Retén de cigüeñal con fuga'**
  String get tasksSeg2SuspensionItemHint;

  /// No description provided for @tasksSeg2SuspensionItemError.
  ///
  /// In es, this message translates to:
  /// **'Describe el ítem faltante o defectuoso (máx. 500 caracteres).'**
  String get tasksSeg2SuspensionItemError;

  /// No description provided for @tasksSeg2SuspensionPartOptional.
  ///
  /// In es, this message translates to:
  /// **'Repuesto del catálogo (opcional)'**
  String get tasksSeg2SuspensionPartOptional;

  /// No description provided for @tasksSeg2SuspensionPartClear.
  ///
  /// In es, this message translates to:
  /// **'Quitar repuesto seleccionado'**
  String get tasksSeg2SuspensionPartClear;

  /// No description provided for @tasksSeg2SuspensionRequestConfirm.
  ///
  /// In es, this message translates to:
  /// **'Enviar solicitud'**
  String get tasksSeg2SuspensionRequestConfirm;

  /// No description provided for @tasksSeg2SuspensionRequestedNotice.
  ///
  /// In es, this message translates to:
  /// **'Solicitud enviada. Espera la validación del supervisor.'**
  String get tasksSeg2SuspensionRequestedNotice;

  /// No description provided for @tasksSeg2SuspensionPendingTitle.
  ///
  /// In es, this message translates to:
  /// **'Suspensión solicitada.'**
  String get tasksSeg2SuspensionPendingTitle;

  /// No description provided for @tasksSeg2SuspensionPendingBody.
  ///
  /// In es, this message translates to:
  /// **'Esperando aprobación del supervisor.'**
  String get tasksSeg2SuspensionPendingBody;

  /// No description provided for @tasksSeg2SuspensionReviewHint.
  ///
  /// In es, this message translates to:
  /// **'Toca para aprobar o rechazar la solicitud'**
  String get tasksSeg2SuspensionReviewHint;

  /// No description provided for @tasksSeg2SuspensionResumeRowTitle.
  ///
  /// In es, this message translates to:
  /// **'Suspensión activa por repuesto'**
  String get tasksSeg2SuspensionResumeRowTitle;

  /// No description provided for @tasksSeg2SuspensionResumeRowHint.
  ///
  /// In es, this message translates to:
  /// **'Toca para reanudar la tarea cuando llegue el repuesto'**
  String get tasksSeg2SuspensionResumeRowHint;

  /// No description provided for @tasksSeg2SuspensionResumeSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Levantar suspensión'**
  String get tasksSeg2SuspensionResumeSheetTitle;

  /// No description provided for @tasksSeg2SuspensionResumeSheetBody.
  ///
  /// In es, this message translates to:
  /// **'Confirma que el repuesto ya está conforme para que el mecánico reanude la labor.'**
  String get tasksSeg2SuspensionResumeSheetBody;

  /// No description provided for @tasksSeg2SuspensionRequestedAt.
  ///
  /// In es, this message translates to:
  /// **'Solicitada: {p1}'**
  String tasksSeg2SuspensionRequestedAt(String p1);

  /// No description provided for @tasksSeg2ReopenBtn.
  ///
  /// In es, this message translates to:
  /// **'Reabrir tarea'**
  String get tasksSeg2ReopenBtn;

  /// No description provided for @tasksSeg2ReopenTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Reabrir tarea cerrada?'**
  String get tasksSeg2ReopenTitle;

  /// No description provided for @tasksSeg2ReopenBody.
  ///
  /// In es, this message translates to:
  /// **'La tarea volverá a estado abierto para retrabajo de calidad.'**
  String get tasksSeg2ReopenBody;

  /// No description provided for @tasksSeg2ReopenReasonLabel.
  ///
  /// In es, this message translates to:
  /// **'Motivo de reapertura (opcional)'**
  String get tasksSeg2ReopenReasonLabel;

  /// No description provided for @tasksSeg2ReopenReasonHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Verificar ajuste de torque'**
  String get tasksSeg2ReopenReasonHint;

  /// No description provided for @tasksSeg2ReopenConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar reapertura'**
  String get tasksSeg2ReopenConfirm;

  /// No description provided for @tasksSeg2ReopenedNotice.
  ///
  /// In es, this message translates to:
  /// **'Tarea reabierta para retrabajo.'**
  String get tasksSeg2ReopenedNotice;

  /// No description provided for @tasksSeg2EvidenceNoteCounter.
  ///
  /// In es, this message translates to:
  /// **'{p1} / {p2} caracteres disponibles'**
  String tasksSeg2EvidenceNoteCounter(int p1, int p2);

  /// No description provided for @tasksSeg2EvidenceFailedSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Foto con error de envío'**
  String get tasksSeg2EvidenceFailedSheetTitle;

  /// No description provided for @tasksSeg2EvidenceFailedRetryNotice.
  ///
  /// In es, this message translates to:
  /// **'Reintento de subida encolado.'**
  String get tasksSeg2EvidenceFailedRetryNotice;

  /// No description provided for @tasksSeg2EvidenceFailedDiscardNotice.
  ///
  /// In es, this message translates to:
  /// **'Foto descartada de la cola.'**
  String get tasksSeg2EvidenceFailedDiscardNotice;

  /// No description provided for @tasksSeg2CompleteMissingAssemblyWarning.
  ///
  /// In es, this message translates to:
  /// **'Sube al menos una foto de Montaje antes de completar esta tarea.'**
  String get tasksSeg2CompleteMissingAssemblyWarning;

  /// No description provided for @tasksSeg2UnsavedExitTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Salir con nota sin guardar?'**
  String get tasksSeg2UnsavedExitTitle;

  /// No description provided for @tasksSeg2UnsavedExitBody.
  ///
  /// In es, this message translates to:
  /// **'Tienes una nota de evidencia escrita que aún no has adjuntado con una foto.'**
  String get tasksSeg2UnsavedExitBody;

  /// No description provided for @tasksSeg2UnsavedExitConfirm.
  ///
  /// In es, this message translates to:
  /// **'Salir sin guardar'**
  String get tasksSeg2UnsavedExitConfirm;

  /// No description provided for @atelierPhotoSynced.
  ///
  /// In es, this message translates to:
  /// **'Guardada'**
  String get atelierPhotoSynced;

  /// No description provided for @atelierPhotoPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get atelierPhotoPending;

  /// No description provided for @atelierPhotoFailed.
  ///
  /// In es, this message translates to:
  /// **'Falló'**
  String get atelierPhotoFailed;

  /// No description provided for @pushDefaultTitleTaskDetail.
  ///
  /// In es, this message translates to:
  /// **'Actualización de tarea'**
  String get pushDefaultTitleTaskDetail;

  /// No description provided for @pushDefaultTitleTaskSuspensionReview.
  ///
  /// In es, this message translates to:
  /// **'Pausa de tarea por revisar'**
  String get pushDefaultTitleTaskSuspensionReview;

  /// No description provided for @pushDefaultTitleTaskProducts.
  ///
  /// In es, this message translates to:
  /// **'Repuesto imputado a tarea'**
  String get pushDefaultTitleTaskProducts;

  /// No description provided for @pushDefaultTitleWorkOrderDetail.
  ///
  /// In es, this message translates to:
  /// **'Orden de trabajo actualizada'**
  String get pushDefaultTitleWorkOrderDetail;

  /// No description provided for @pushDefaultTitleLowStock.
  ///
  /// In es, this message translates to:
  /// **'Alerta de stock mínimo'**
  String get pushDefaultTitleLowStock;

  /// No description provided for @pushDefaultTitleCollaboratorAttendance.
  ///
  /// In es, this message translates to:
  /// **'Novedad de asistencia en sede'**
  String get pushDefaultTitleCollaboratorAttendance;

  /// No description provided for @pushDefaultTitleMyAttendance.
  ///
  /// In es, this message translates to:
  /// **'Justificación revisada'**
  String get pushDefaultTitleMyAttendance;

  /// No description provided for @pushDefaultTitleClockIn.
  ///
  /// In es, this message translates to:
  /// **'Recordatorio de turno'**
  String get pushDefaultTitleClockIn;

  /// No description provided for @teamCollaboratorWithId.
  ///
  /// In es, this message translates to:
  /// **'Colaborador · {p1}'**
  String teamCollaboratorWithId(String p1);

  /// No description provided for @attendanceHistoryExit.
  ///
  /// In es, this message translates to:
  /// **'Salida {p1}'**
  String attendanceHistoryExit(String p1);

  /// No description provided for @attendanceHistoryJustificationPending.
  ///
  /// In es, this message translates to:
  /// **'Descargo pendiente'**
  String get attendanceHistoryJustificationPending;

  /// No description provided for @attendanceHistoryJustificationApproved.
  ///
  /// In es, this message translates to:
  /// **'Descargo aprobado'**
  String get attendanceHistoryJustificationApproved;

  /// No description provided for @attendanceHistoryJustificationRejected.
  ///
  /// In es, this message translates to:
  /// **'Descargo rechazado'**
  String get attendanceHistoryJustificationRejected;

  /// No description provided for @attendanceHistoryStatusOnTime.
  ///
  /// In es, this message translates to:
  /// **'A tiempo'**
  String get attendanceHistoryStatusOnTime;

  /// No description provided for @attendanceHistoryStatusLate.
  ///
  /// In es, this message translates to:
  /// **'Tardanza'**
  String get attendanceHistoryStatusLate;

  /// No description provided for @attendanceHistoryStatusAbsent.
  ///
  /// In es, this message translates to:
  /// **'Ausente'**
  String get attendanceHistoryStatusAbsent;

  /// No description provided for @attendanceHistoryStatusExcused.
  ///
  /// In es, this message translates to:
  /// **'Justificado'**
  String get attendanceHistoryStatusExcused;

  /// No description provided for @attendanceHistoryStatusRegistered.
  ///
  /// In es, this message translates to:
  /// **'Registrado'**
  String get attendanceHistoryStatusRegistered;

  /// No description provided for @floorHubApptConfirmed.
  ///
  /// In es, this message translates to:
  /// **'Confirmada'**
  String get floorHubApptConfirmed;

  /// No description provided for @floorHubApptArrived.
  ///
  /// In es, this message translates to:
  /// **'Llegó'**
  String get floorHubApptArrived;

  /// No description provided for @floorHubApptCanceled.
  ///
  /// In es, this message translates to:
  /// **'Cancelada'**
  String get floorHubApptCanceled;

  /// No description provided for @floorHubApptPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get floorHubApptPending;

  /// No description provided for @floorHubTaskEstimated.
  ///
  /// In es, this message translates to:
  /// **'Est. {p1} h'**
  String floorHubTaskEstimated(String p1);

  /// No description provided for @floorHubPoFallback.
  ///
  /// In es, this message translates to:
  /// **'OC {p1}'**
  String floorHubPoFallback(String p1);

  /// No description provided for @floorHubPoSummary.
  ///
  /// In es, this message translates to:
  /// **'{p1} ítems · {p2}'**
  String floorHubPoSummary(int p1, String p2);

  /// No description provided for @floorHubPoIssued.
  ///
  /// In es, this message translates to:
  /// **'Emitida'**
  String get floorHubPoIssued;

  /// No description provided for @floorHubCashReadySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Lista para comprobante y cobro'**
  String get floorHubCashReadySubtitle;

  /// No description provided for @floorHubCashOrderNumber.
  ///
  /// In es, this message translates to:
  /// **'Orden #{p1}'**
  String floorHubCashOrderNumber(String p1);

  /// No description provided for @floorHubStockPosCaption.
  ///
  /// In es, this message translates to:
  /// **'órdenes de compra emitidas'**
  String get floorHubStockPosCaption;

  /// No description provided for @floorHubQuickObdSubNoLive.
  ///
  /// In es, this message translates to:
  /// **'Fallas DTC e informe IA'**
  String get floorHubQuickObdSubNoLive;

  /// No description provided for @invReceiveCameraDenied.
  ///
  /// In es, this message translates to:
  /// **'Sin permiso de cámara. Actívalo en los ajustes del teléfono para fotografiar el comprobante.'**
  String get invReceiveCameraDenied;

  /// No description provided for @invReceiveErrPhoto.
  ///
  /// In es, this message translates to:
  /// **'Toma la foto del comprobante para recibir la compra.'**
  String get invReceiveErrPhoto;

  /// No description provided for @invReceiveErrNumber.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el número del comprobante.'**
  String get invReceiveErrNumber;

  /// No description provided for @invReceiveErrDate.
  ///
  /// In es, this message translates to:
  /// **'La fecha debe tener el formato AAAA-MM-DD y no puede ser futura.'**
  String get invReceiveErrDate;

  /// No description provided for @invReceiveErrNotReceivable.
  ///
  /// In es, this message translates to:
  /// **'Solo se pueden recibir órdenes emitidas.'**
  String get invReceiveErrNotReceivable;

  /// No description provided for @diagReportPdfTitle.
  ///
  /// In es, this message translates to:
  /// **'Informe en PDF'**
  String get diagReportPdfTitle;

  /// No description provided for @diagReportPdfHint.
  ///
  /// In es, this message translates to:
  /// **'Semáforo de salud por subsistema, riesgos y acciones recomendadas.'**
  String get diagReportPdfHint;

  /// No description provided for @reportsFleetSelected.
  ///
  /// In es, this message translates to:
  /// **'Cliente: {name}'**
  String reportsFleetSelected(String name);

  /// No description provided for @reportsFleetClear.
  ///
  /// In es, this message translates to:
  /// **'Quitar cliente'**
  String get reportsFleetClear;

  /// No description provided for @floorHubStockAlertLine.
  ///
  /// In es, this message translates to:
  /// **'{p1} · Stock {p2} / mín. {p3}'**
  String floorHubStockAlertLine(String p1, String p2, String p3);

  /// No description provided for @floorHubStockMissing.
  ///
  /// In es, this message translates to:
  /// **'Faltan {p1}'**
  String floorHubStockMissing(String p1);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
