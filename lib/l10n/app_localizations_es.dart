// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Atelier';

  @override
  String get syncFailedMaxAttempts => 'No se pudo sincronizar';

  @override
  String get errorStorageNotConfigured =>
      'Falta configurar el almacenamiento de fotos';

  @override
  String get errorStorageUploadFailed => 'No se pudo subir la foto';

  @override
  String get errorPendingPhotoMissing => 'La foto ya no está en el teléfono';

  @override
  String get notificationChannelTasks => 'Tareas';

  @override
  String get notificationChannelAttendance => 'Asistencia';

  @override
  String get notificationChannelInventory => 'Inventario';

  @override
  String get notificationChannelDiagnostics => 'Diagnóstico';

  @override
  String get diagnosticsSessionNotificationTitle =>
      'Diagnóstico OBD-II en curso';

  @override
  String get placeholderSignedOut => 'Inicio de sesión';

  @override
  String get placeholderBranchChoice => 'Elegir sede';

  @override
  String get placeholderSignedIn => 'Sesión iniciada';

  @override
  String get appName => 'Atelier Workshop';

  @override
  String get errorRequiresConnection => 'Requiere conexión';

  @override
  String get errorGeneric => 'Ocurrió un error. Inténtalo de nuevo.';

  @override
  String get errorDeviceClock => 'Revisa la hora de tu teléfono';

  @override
  String get commonBack => 'Volver';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String plateA11y(String p1) {
    return 'placa $p1';
  }

  @override
  String sectionWithCount(String p1, int p2) {
    return '$p1 · $p2';
  }

  @override
  String get stateOfflineNoCache => 'Sin conexión y sin datos guardados';

  @override
  String get authEmailLabel => 'Correo institucional';

  @override
  String get authPasswordLabel => 'Contraseña';

  @override
  String get authConfirmPassword => 'Confirmar contraseña';

  @override
  String get authShowPassword => 'Mostrar contraseña';

  @override
  String get authHidePassword => 'Ocultar contraseña';

  @override
  String get authFirstName => 'Nombres';

  @override
  String get authLastName => 'Apellidos';

  @override
  String get authLoginTitle => 'Inicia sesión';

  @override
  String get authLoginSubtitle => 'Con el correo institucional de tu taller.';

  @override
  String get authLoginAction => 'Iniciar sesión';

  @override
  String get authForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get authOr => 'o';

  @override
  String get authHaveInvitation => 'Tengo un enlace de invitación';

  @override
  String get authEmailVerified =>
      'Correo verificado. Ya puedes iniciar sesión.';

  @override
  String get authRegisterTitle => 'Crear tu cuenta';

  @override
  String get authLinkTitle => 'Pega tu enlace';

  @override
  String get authLinkBody =>
      'Usa el enlace del correo con el que te invitó el administrador de tu taller.';

  @override
  String get authLinkLabel => 'Enlace de invitación';

  @override
  String get authLinkPlaceholder => 'Pega el enlace o el código';

  @override
  String get authContinue => 'Continuar';

  @override
  String get authInvitedTo => 'Te invitaron a';

  @override
  String authInvitedRole(String p1) {
    return 'Rol: $p1';
  }

  @override
  String get authRuleLength => 'Al menos 8 caracteres';

  @override
  String get authRuleUppercase => 'Una letra mayúscula';

  @override
  String get authRuleMatch => 'Coincide con la confirmación';

  @override
  String get authRuleMet => 'Cumplido';

  @override
  String get authRulePending => 'Pendiente';

  @override
  String get authCompleteRegistration => 'Completar registro';

  @override
  String get authInvitationExpiredTitle => 'Esta invitación venció.';

  @override
  String get authInvitationExpiredBody =>
      'Pide una nueva al administrador de tu taller.';

  @override
  String get authInvitationGoneTitle => 'Esta invitación ya no es válida.';

  @override
  String get authInvitationGoneBody =>
      'Fue revocada o el enlace está incompleto. Pide una nueva al administrador de tu taller.';

  @override
  String get authBackToLogin => 'Volver a iniciar sesión';

  @override
  String get authVerifyTitle => 'Verifica tu correo';

  @override
  String get authOtpTitle => 'Ingresa el código';

  @override
  String authOtpSentTo(String p1) {
    return 'Lo enviamos a $p1';
  }

  @override
  String authOtpLabel(int p1) {
    return 'Código de verificación de $p1 dígitos';
  }

  @override
  String authOtpProgress(int p1, int p2) {
    return '$p1 de $p2 dígitos';
  }

  @override
  String authOtpExpiresIn(String p1) {
    return 'Vence en $p1';
  }

  @override
  String get authOtpExpired => 'El código venció. Pide uno nuevo.';

  @override
  String get authOtpResent => 'Te enviamos un código nuevo.';

  @override
  String get authResend => 'Reenviar código';

  @override
  String authResendIn(String p1) {
    return 'Reenviar en $p1';
  }

  @override
  String get authVerifyAction => 'Verificar código';

  @override
  String get authForgotTitle => 'Recupera tu contraseña';

  @override
  String get authForgotBody =>
      'Escribe el correo de tu cuenta y te enviaremos un enlace para crear una contraseña nueva. El enlace vence en 2 horas.';

  @override
  String get authForgotAction => 'Enviar enlace';

  @override
  String get authForgotSentTitle => 'Revisa tu correo';

  @override
  String get authForgotSent =>
      'Si el correo pertenece a una cuenta, te enviamos un enlace para restablecer la contraseña.';

  @override
  String get authHaveToken => 'Ya tengo el enlace';

  @override
  String get authRequestAgain => 'Pedir otro enlace';

  @override
  String get authResetTitle => 'Nueva contraseña';

  @override
  String get authResetBody =>
      'Pega el enlace del correo, o solo el código que trae, y elige tu contraseña nueva.';

  @override
  String get authResetTokenLabel => 'Enlace o código';

  @override
  String get authResetHint =>
      'El enlace vence 2 horas después de pedirlo y solo sirve una vez.';

  @override
  String get authResetAction => 'Cambiar contraseña';

  @override
  String get authResetInvalid =>
      'El enlace venció o no es válido. Pide uno nuevo.';

  @override
  String get authResetRequestNew => 'Pedir un enlace nuevo';

  @override
  String get authPasswordUpdated =>
      'Contraseña actualizada. Ya puedes iniciar sesión.';

  @override
  String get attendanceTitle => 'Asistencia';

  @override
  String get attendanceToday => 'Mi jornada de hoy';

  @override
  String get attendanceNotClockedIn => 'Todavía no has marcado tu ingreso.';

  @override
  String get attendanceClockInPending =>
      'Ingreso guardado. Se sincronizará cuando vuelva la conexión.';

  @override
  String get attendanceClockOutPending =>
      'Salida guardada. Se sincronizará cuando vuelva la conexión.';

  @override
  String attendanceCapturedAt(String p1) {
    return 'Hora registrada en el dispositivo: $p1';
  }

  @override
  String attendanceClockedInAt(String p1) {
    return 'Ingreso: $p1';
  }

  @override
  String attendanceCompletedAt(String p1) {
    return 'Jornada finalizada: $p1';
  }

  @override
  String attendanceClockOutAt(String p1) {
    return 'Salida: $p1';
  }

  @override
  String attendanceDistance(int p1) {
    return 'Distancia estimada a la sede: $p1 m';
  }

  @override
  String attendanceWorkedMinutes(int p1) {
    return 'Tiempo trabajado: $p1 min';
  }

  @override
  String attendanceRegularMinutes(int p1) {
    return 'Tiempo regular: $p1 min';
  }

  @override
  String attendanceOvertimeMinutes(int p1) {
    return 'Sobretiempo: $p1 min';
  }

  @override
  String get attendanceClockIn => 'Marcar ingreso';

  @override
  String get attendanceClockOut => 'Marcar salida';

  @override
  String get attendanceRefresh => 'Actualizar';

  @override
  String get attendanceRefreshing => 'Actualizando asistencia…';

  @override
  String get attendanceMyShift => 'Mi turno';

  @override
  String get attendanceNoShift =>
      'No tienes un turno asignado. Contacta al administrador de tu taller.';

  @override
  String attendanceShiftHours(String p1, String p2) {
    return 'Horario: $p1 – $p2';
  }

  @override
  String attendanceGracePeriod(int p1) {
    return 'Tolerancia: $p1 minutos';
  }

  @override
  String get attendanceBranchUnavailable => 'Sede no disponible en caché';

  @override
  String get attendanceWorkDay => 'Laborable';

  @override
  String get attendanceRestDay => 'Descanso';

  @override
  String get attendanceHistory => 'Historial de asistencia';

  @override
  String get attendanceHistoryEmpty =>
      'Todavía no hay asistencias en el historial disponible.';

  @override
  String attendanceStatus(String p1) {
    return 'Estado: $p1';
  }

  @override
  String get attendanceStatusUnknown => 'Sin clasificar';

  @override
  String get attendanceStatusOnTime => 'A tiempo';

  @override
  String get attendanceStatusLate => 'Tardanza';

  @override
  String get attendanceStatusExcused => 'Justificada';

  @override
  String get attendanceStatusAbsent => 'Ausencia';

  @override
  String attendanceJustificationReason(String p1) {
    return 'Motivo enviado: $p1';
  }

  @override
  String attendanceJustificationStatus(String p1) {
    return 'Descargo: $p1';
  }

  @override
  String get attendanceJustificationPending => 'Pendiente de revisión';

  @override
  String get attendanceJustificationApproved => 'Aprobado';

  @override
  String get attendanceJustificationRejected => 'Rechazado';

  @override
  String get attendanceJustify => 'Presentar descargo';

  @override
  String get attendanceJustificationTitle => 'Justificar asistencia';

  @override
  String get attendanceJustificationHelp =>
      'Explica el motivo de la tardanza o ausencia. El administrador revisará el descargo.';

  @override
  String get attendanceJustificationLabel => 'Motivo';

  @override
  String get attendanceJustificationSend => 'Enviar descargo';

  @override
  String get attendanceCancel => 'Cancelar';

  @override
  String get attendanceLocationUnavailable =>
      'No se pudo obtener la ubicación actual. Activa la ubicación del dispositivo e inténtalo de nuevo.';

  @override
  String attendanceLocationInaccurate(int p1) {
    return 'La ubicación tiene una precisión de aproximadamente $p1 m. Sal a un lugar abierto e inténtalo otra vez; se requiere una precisión de 50 m o mejor.';
  }

  @override
  String get attendanceJustificationInvalid =>
      'Escribe un motivo de descargo de hasta 500 caracteres.';

  @override
  String get attendanceLocationPermissionRequired =>
      'Para marcar el ingreso, permite el acceso a la ubicación precisa en los permisos de la aplicación.';

  @override
  String get attendanceMockLocationWarning =>
      'El dispositivo reporta una ubicación simulada. El backend decide si puede aceptar la marcación.';

  @override
  String attendanceOutsideGeofenceWarning(int p1) {
    return 'Estás aproximadamente a $p1 m de la sede, fuera de la geocerca. El backend validará la marcación.';
  }

  @override
  String get attendancePermissionClockIn =>
      'Tu cuenta no tiene permiso para marcar ingreso.';

  @override
  String get attendancePermissionClockOut =>
      'Tu cuenta no tiene permiso para marcar salida.';

  @override
  String get attendancePermissionJustification =>
      'Tu cuenta no tiene permiso para presentar descargos.';

  @override
  String get attendanceMissingAssignment =>
      'No tienes sede o turno asignado. Contacta al administrador del taller.';

  @override
  String get attendanceClockInRecorded => 'Ingreso registrado correctamente.';

  @override
  String get attendanceClockInQueued =>
      'Ingreso guardado sin conexión; se enviará automáticamente al recuperar señal.';

  @override
  String get attendanceClockOutRecorded => 'Salida registrada correctamente.';

  @override
  String get attendanceClockOutQueued =>
      'Salida guardada sin conexión; se enviará automáticamente al recuperar señal.';

  @override
  String get attendanceJustificationRecorded =>
      'Descargo enviado correctamente.';

  @override
  String get attendanceJustificationQueued =>
      'Descargo guardado sin conexión; se enviará automáticamente al recuperar señal.';

  @override
  String get attendanceAlreadyQueued =>
      'Esta acción ya está pendiente o falló. Revísala en Pendientes de sincronizar.';

  @override
  String get dayMonday => 'Lunes';

  @override
  String get dayTuesday => 'Martes';

  @override
  String get dayWednesday => 'Miércoles';

  @override
  String get dayThursday => 'Jueves';

  @override
  String get dayFriday => 'Viernes';

  @override
  String get daySaturday => 'Sábado';

  @override
  String get daySunday => 'Domingo';

  @override
  String get branchTitle => 'Elige tu sede';

  @override
  String get branchSubtitle =>
      'Tu cuenta no tiene una sede asignada. Elige en cuál vas a trabajar.';

  @override
  String branchGeofence(int p1) {
    return 'Marcación en un radio de $p1 m';
  }

  @override
  String get branchContinue => 'Continuar';

  @override
  String branchContinueIn(String p1) {
    return 'Continuar en $p1';
  }

  @override
  String get branchLater => 'Elegir después';

  @override
  String get branchRetry => 'Reintentar';

  @override
  String get branchLoading => 'Cargando sedes';

  @override
  String get branchEmptyTitle => 'Tu taller aún no tiene sedes activas.';

  @override
  String get branchEmptyBody =>
      'Pide al administrador que cree una y vuelve a entrar.';

  @override
  String get receptionInvalidInput => 'Revisa los datos marcados.';

  @override
  String get receptionFieldEmail => 'Ingresa un correo válido.';

  @override
  String get receptionFieldTaxIdPerson =>
      'El documento debe tener entre 8 y 20 caracteres.';

  @override
  String get receptionFieldTaxIdCompany =>
      'El RUC debe tener entre 11 y 20 caracteres.';

  @override
  String get receptionFieldPhone => 'Máximo 20 caracteres.';

  @override
  String get receptionFieldFirstName =>
      'Ingresa los nombres (máximo 100 caracteres).';

  @override
  String get receptionFieldLastName =>
      'Ingresa los apellidos (máximo 100 caracteres).';

  @override
  String get receptionFieldCompanyName =>
      'Ingresa la razón social (máximo 150 caracteres).';

  @override
  String get receptionFieldPlate => 'Ingresa la placa (máximo 15 caracteres).';

  @override
  String get receptionFieldBrand => 'Ingresa la marca (máximo 50 caracteres).';

  @override
  String get receptionFieldModel => 'Ingresa el modelo (máximo 50 caracteres).';

  @override
  String get receptionFieldVin => 'Máximo 17 caracteres.';

  @override
  String get receptionFieldYear => 'El año debe ser 1950 o posterior.';

  @override
  String get receptionNoPermission =>
      'Tu perfil no tiene permiso para esta acción.';

  @override
  String get affiliationTitle => 'Afiliar cliente';

  @override
  String get affiliationSubtitle =>
      'Busca el correo del conductor para ver si ya usa Atelier.';

  @override
  String get affiliationEmail => 'Correo del conductor';

  @override
  String get affiliationSearch => 'Buscar';

  @override
  String get affiliationAlreadyTitle => 'Ya es cliente del taller.';

  @override
  String affiliationAlreadyBody(String p1) {
    return '$p1 ya está afiliado. No hace falta registrarlo otra vez.';
  }

  @override
  String get affiliationFoundTitle => 'Cuenta de Atelier encontrada.';

  @override
  String affiliationFoundBody(String p1, int p2) {
    return '$p1 tiene $p2 vehículo(s) registrado(s). Pide su documento para afiliarlo.';
  }

  @override
  String get affiliationNotFoundTitle => 'Sin cuenta en Atelier.';

  @override
  String get affiliationNotFoundBody =>
      'Registra al cliente y su vehículo en el taller.';

  @override
  String get affiliationTaxId => 'Documento (DNI)';

  @override
  String get affiliationPhone => 'Teléfono (opcional)';

  @override
  String get affiliationSubmit => 'Afiliar al taller';

  @override
  String get affiliationRegisterWalkIn => 'Registrar cliente presencial';

  @override
  String affiliationDone(String p1) {
    return 'Cliente afiliado: $p1';
  }

  @override
  String get registerCustomerTitle => 'Registrar cliente';

  @override
  String get registerCustomerIndividual => 'Persona';

  @override
  String get registerCustomerCompany => 'Empresa';

  @override
  String get registerCustomerSectionCustomer => 'Cliente';

  @override
  String get registerCustomerSectionVehicle => 'Vehículo';

  @override
  String get registerCustomerFirstName => 'Nombres';

  @override
  String get registerCustomerLastName => 'Apellidos';

  @override
  String get registerCustomerCompanyName => 'Razón social';

  @override
  String get registerCustomerTaxIdPerson => 'Documento (DNI)';

  @override
  String get registerCustomerTaxIdCompany => 'RUC';

  @override
  String get registerCustomerEmail => 'Correo electrónico (opcional)';

  @override
  String get registerCustomerPhone => 'Teléfono';

  @override
  String get registerVehiclePlate => 'Placa';

  @override
  String get registerVehicleBrand => 'Marca';

  @override
  String get registerVehicleModel => 'Modelo';

  @override
  String get registerVehicleEngine => 'Motor';

  @override
  String get registerVehicleVin => 'VIN (opcional)';

  @override
  String get registerVehicleYear => 'Año';

  @override
  String get engineGasoline => 'Gasolina';

  @override
  String get engineDiesel => 'Diésel';

  @override
  String get engineElectric => 'Eléctrico';

  @override
  String get engineHybrid => 'Híbrido';

  @override
  String get registerCustomerSubmit => 'Registrar cliente y vehículo';

  @override
  String get registerCustomerRetryVehicle => 'Registrar vehículo';

  @override
  String get registerCustomerSavedPendingVehicle =>
      'El cliente ya se guardó. Falta registrar el vehículo.';

  @override
  String get searchTitle => 'Recepción';

  @override
  String get searchSubtitle =>
      'Busca la unidad por placa o al cliente por documento.';

  @override
  String get searchModePlate => 'Placa';

  @override
  String get searchModeDocument => 'DNI / RUC';

  @override
  String get searchFieldPlate => 'Placa del vehículo';

  @override
  String get searchFieldDocument => 'Documento del cliente';

  @override
  String get searchSubmit => 'Buscar';

  @override
  String searchVehicleOwner(String p1) {
    return 'Titular: $p1';
  }

  @override
  String get searchVehicleNoOwner => 'Sin titular registrado';

  @override
  String get searchNotFoundTitle => 'Vehículo no registrado.';

  @override
  String get searchNotFoundBody =>
      'Es un primer ingreso. Registra al cliente y su vehículo, o afilia su cuenta de Atelier.';

  @override
  String get searchCustomersEmpty => 'No hay clientes con ese documento.';

  @override
  String get searchCustomersTitle => 'Clientes encontrados';

  @override
  String searchCustomerVehiclesTitle(String p1) {
    return 'Vehículos de $p1';
  }

  @override
  String get searchLoading => 'Cargando…';

  @override
  String get searchCustomerVehiclesEmpty => 'Este cliente no tiene vehículos.';

  @override
  String get searchRegister => 'Registrar cliente y vehículo';

  @override
  String get searchAffiliate => 'Afiliar por correo';

  @override
  String get searchAppointmentsTitle => 'Citas de hoy';

  @override
  String get searchAppointmentsEmpty => 'No hay citas para hoy.';

  @override
  String get searchAppointmentsRefresh => 'Actualizar citas';

  @override
  String searchAppointmentLine(String p1, String p2) {
    return '$p1 · $p2';
  }

  @override
  String get searchAppointmentUnknownPlate => 'Placa sin cargar';

  @override
  String get searchAppointmentArrived => 'Marcar llegada';

  @override
  String get appointmentStatusPending => 'Pendiente';

  @override
  String get appointmentStatusConfirmed => 'Confirmada';

  @override
  String get appointmentStatusArrived => 'Llegó';

  @override
  String get appointmentStatusCanceled => 'Cancelada';

  @override
  String get searchStartService => 'Iniciar atención';

  @override
  String get searchCompleteOrder => 'Completar orden';

  @override
  String get searchArrivalReady =>
      'Llegada registrada. La orden en borrador ya está lista.';

  @override
  String get searchArrivalPending =>
      'Llegada registrada. La orden se está creando: actualiza en unos segundos.';

  @override
  String get workorderInvalidInput => 'Revisa los datos marcados.';

  @override
  String get openOrderTitle => 'Abrir orden';

  @override
  String get openOrderDraftNotice =>
      'Este vehículo ya tiene una orden en borrador. Completa sus datos de ingreso.';

  @override
  String get openOrderSavedPendingTasks =>
      'La orden ya se abrió. Faltan agregar algunas faenas.';

  @override
  String get openOrderMileage => 'Kilometraje (km)';

  @override
  String get openOrderFieldMileage => 'Ingresa el kilometraje como un número.';

  @override
  String get openOrderFuel => 'Nivel de combustible';

  @override
  String get fuelReserve => 'Reserva';

  @override
  String get fuelQuarter => '1/4';

  @override
  String get fuelHalf => '1/2';

  @override
  String get fuelThreeQuarters => '3/4';

  @override
  String get fuelFull => 'Lleno';

  @override
  String get openOrderReason => 'Motivo de ingreso';

  @override
  String get openOrderFieldReason =>
      'El motivo es demasiado largo (máximo 2000 caracteres).';

  @override
  String get openOrderTasks => 'Faenas iniciales';

  @override
  String get openOrderTasksEmpty =>
      'No hay servicios para elegir. Puedes abrir la orden sin faenas.';

  @override
  String openOrderTaskAdded(String p1) {
    return '$p1 (agregada)';
  }

  @override
  String get openOrderMechanic => 'Asignar a (opcional)';

  @override
  String get openOrderMechanicNone => 'Sin asignar';

  @override
  String openOrderMechanicFallback(String p1) {
    return 'Colaborador $p1';
  }

  @override
  String get openOrderSubmit => 'Abrir orden';

  @override
  String get openOrderRetryTasks => 'Agregar faenas pendientes';

  @override
  String get galleryTitle => 'Fotos de recepción';

  @override
  String get gallerySubtitle =>
      'Toca un panel para fotografiarlo. Las fotos se guardan aunque no haya señal.';

  @override
  String get galleryNote => 'Nota del daño (opcional)';

  @override
  String get galleryCameraDenied =>
      'Sin permiso de cámara no se pueden tomar fotos.';

  @override
  String galleryTakePhoto(String p1) {
    return 'Tomar foto: $p1';
  }

  @override
  String get galleryAngleFront => 'Frente';

  @override
  String get galleryAngleRear => 'Trasera';

  @override
  String get galleryAngleLeft => 'Lateral izquierdo';

  @override
  String get galleryAngleRight => 'Lateral derecho';

  @override
  String get galleryAngleRoof => 'Techo';

  @override
  String get galleryAngleDashboard => 'Tablero';

  @override
  String get galleryAngleOther => 'Otra foto';

  @override
  String get galleryOther => 'Otras fotos';

  @override
  String get galleryAddOther => 'Agregar otra foto';

  @override
  String get galleryStatusUploaded => 'Subida';

  @override
  String get galleryStatusQueued => 'En cola';

  @override
  String get galleryStatusFailed => 'Falló';

  @override
  String get galleryDone => 'Listo';

  @override
  String get severityLow => 'Baja';

  @override
  String get severityMedium => 'Media';

  @override
  String get severityHigh => 'Alta';

  @override
  String get severityCritical => 'Crítica';

  @override
  String get proposalStatusPending => 'En revisión';

  @override
  String get proposalStatusApproved => 'Aprobada';

  @override
  String get proposalStatusRejected => 'Rechazada';

  @override
  String get findingTitle => 'Reportar hallazgo';

  @override
  String get findingSubtitle =>
      'Describe el imprevisto que encontraste y adjunta una foto como prueba.';

  @override
  String get findingSaved =>
      'Hallazgo guardado. Se enviará a supervisión en cuanto haya señal.';

  @override
  String get findingSeverity => 'Severidad';

  @override
  String get findingDescription => 'Descripción técnica';

  @override
  String get findingFieldDescription =>
      'Ingresa la descripción (máximo 2000 caracteres).';

  @override
  String get findingPhoto => 'Foto del hallazgo';

  @override
  String get findingTakePhoto => 'Tomar foto';

  @override
  String get findingChangePhoto => 'Cambiar foto';

  @override
  String get findingPhotoRequired =>
      'La foto es obligatoria para enviar el hallazgo.';

  @override
  String get findingService => 'Servicio sugerido (opcional)';

  @override
  String get findingServiceNone => 'Sin sugerencia';

  @override
  String get findingPendingTitle => 'Pendientes de envío';

  @override
  String get findingSubmit => 'Enviar hallazgo';

  @override
  String get proposalsTitle => 'Propuestas';

  @override
  String get proposalsSubtitle =>
      'Notifica al cliente cada hallazgo y registra si lo aprobó o no.';

  @override
  String get proposalsEmpty => 'Esta orden no tiene propuestas.';

  @override
  String get proposalsReport => 'Reportar hallazgo';

  @override
  String get proposalsNotify => 'Enviar al cliente por correo';

  @override
  String get proposalsApprove => 'Aprobar y crear tarea';

  @override
  String get proposalsReject => 'Registrar rechazo';

  @override
  String proposalsNotified(String p1) {
    return 'Correo enviado a $p1.';
  }

  @override
  String get proposalsApproved =>
      'Propuesta aprobada. Se creó la tarea en la orden.';

  @override
  String get proposalsRejected => 'Propuesta rechazada.';

  @override
  String proposalsCustomerNotes(String p1) {
    return 'Observaciones del cliente: $p1';
  }

  @override
  String proposalsRecommendedService(String p1) {
    return 'Servicio recomendado: $p1';
  }

  @override
  String get proposalsService => 'Servicio de la tarea';

  @override
  String get proposalsFinalPrice => 'Tarifa del servicio (sin IGV)';

  @override
  String get proposalsPriceFromCatalog =>
      'Tarifa consolidada del catálogo de servicios (sin IGV).';

  @override
  String get proposalsLaborHours => 'Horas estimadas';

  @override
  String get proposalsMechanic => 'Mecánico responsable (opcional)';

  @override
  String get proposalsMechanicUnassigned => 'Sin asignar';

  @override
  String get proposalsNotesOptional => 'Observaciones (opcional)';

  @override
  String get proposalsCustomerNotesLabel => 'Observaciones del cliente';

  @override
  String get proposalsFieldService => 'Elige un servicio para la tarea.';

  @override
  String get proposalsFieldAmount => 'Ingresa un número de 0 en adelante.';

  @override
  String get proposalsFieldNotes =>
      'Escribe las observaciones (máximo 1000 caracteres).';

  @override
  String get proposalsConfirm => 'Confirmar';

  @override
  String get proposalsCancel => 'Cancelar';

  @override
  String get galleryProposals => 'Propuestas de la orden';

  @override
  String get attendanceLocating => 'Obteniendo ubicación…';

  @override
  String get attendanceRefreshingShort => 'Actualizando';

  @override
  String get attendancePendingBadge => 'Pendiente de sincronizar';

  @override
  String get attendanceCompletedBadge => 'Jornada finalizada';

  @override
  String get attendanceActiveBadge => 'Jornada activa';

  @override
  String get attendanceReadyBadge => 'Listo para marcar';

  @override
  String get attendanceGeofenceTitle => 'Geocerca del taller';

  @override
  String attendanceGeofenceRadius(int p1) {
    return 'Radio permitido: $p1 m';
  }

  @override
  String get attendanceGeofenceNoBranch =>
      'La sede no está disponible en caché.';

  @override
  String get attendanceRetryLocation => 'Actualizar GPS';

  @override
  String attendanceDistanceValue(int p1) {
    return '$p1 m';
  }

  @override
  String get attendanceDistanceFromBranch => 'del centro del taller';

  @override
  String get attendanceGpsUnavailableShort => 'Sin GPS';

  @override
  String get attendanceMockShort => 'GPS simulado';

  @override
  String get attendanceGpsReady => 'GPS disponible';

  @override
  String get attendanceInsideGeofence => 'Dentro del perímetro';

  @override
  String get attendanceOutsideGeofence => 'Fuera del perímetro';

  @override
  String get attendanceGraceLabel => 'Tolerancia de ingreso';

  @override
  String get attendanceBranchLabel => 'Sede asignada';

  @override
  String get attendanceNoShiftShort => 'Sin turno asignado';

  @override
  String get attendanceWeeklySchedule => 'Semana laboral';

  @override
  String attendanceMapRadius(int p1) {
    return 'Vista esquemática · radio $p1 m';
  }

  @override
  String get attendanceMapNoData =>
      'Vista esquemática · la sede aparecerá al cargar los datos';

  @override
  String get tasksTitle => 'Mis tareas';

  @override
  String get tasksSubtitle => 'Faenas asignadas en bahía, por prioridad.';

  @override
  String get tasksEmpty => 'No tienes tareas asignadas.';

  @override
  String get tasksNoPermission => 'Tu perfil no tiene permiso para ver tareas.';

  @override
  String get tasksCacheNotice =>
      'Sin conexión: mostrando las tareas guardadas.';

  @override
  String get tasksRefresh => 'Actualizar';

  @override
  String get taskStatusAssigned => 'Asignada';

  @override
  String get taskStatusInProgress => 'En curso';

  @override
  String get taskStatusOnHold => 'En pausa';

  @override
  String get taskStatusSuspended => 'Suspendida';

  @override
  String get taskStatusCompleted => 'Completada';

  @override
  String get taskStatusCancelled => 'Cancelada';

  @override
  String get taskStatusPending => 'Pendiente';

  @override
  String get taskSuspensionPending => 'Suspensión por aprobar';

  @override
  String taskCardPlate(String p1) {
    return 'Placa $p1';
  }

  @override
  String taskCardBay(String p1) {
    return 'Bahía $p1';
  }

  @override
  String taskCardWorkOrder(int p1) {
    return 'OT #$p1';
  }

  @override
  String taskCardEstimated(String p1) {
    return '$p1 h estimadas';
  }

  @override
  String get taskCardNoPlate => 'Vehículo sin placa en caché';

  @override
  String get taskDetailTitle => 'Detalle de tarea';

  @override
  String get taskInvalidInput => 'Revisa los datos marcados.';

  @override
  String get taskTimerLabel => 'Labor efectiva';

  @override
  String taskTimerPausedTotal(String p1) {
    return 'En pausa acumulada: $p1';
  }

  @override
  String get taskStart => 'Iniciar faena';

  @override
  String get taskResume => 'Reanudar';

  @override
  String get taskPause => 'Pausar';

  @override
  String get taskComplete => 'Terminar tarea';

  @override
  String get taskStarted => 'Faena en curso.';

  @override
  String get taskPaused => 'Tarea en pausa.';

  @override
  String get taskSuspendedNotice =>
      'Tarea suspendida: solo un supervisor puede levantarla.';

  @override
  String get taskPauseTitle => 'Pausar tarea';

  @override
  String get taskPauseBody => 'Elige el motivo de la pausa.';

  @override
  String get taskPauseBreak => 'Refrigerio';

  @override
  String get taskPauseEndOfShift => 'Fin de turno';

  @override
  String get taskCompleteTitle => 'Terminar tarea';

  @override
  String get taskCompleteBody =>
      'Confirma las horas efectivas trabajadas. Puedes corregir la sugerencia del cronómetro.';

  @override
  String get taskCompleteHours => 'Horas efectivas';

  @override
  String get taskCompleteNotes => 'Notas (opcional)';

  @override
  String get taskCompleteConfirm => 'Confirmar cierre';

  @override
  String get taskCompletedNotice =>
      'Tarea cerrada. Sale de tus tareas pendientes.';

  @override
  String get taskFieldHours => 'Escribe un número de horas mayor o igual a 0.';

  @override
  String get taskFieldNotes => 'Máximo 1000 caracteres.';

  @override
  String get catalogTitle => 'Repuestos';

  @override
  String get catalogSearchLabel => 'Buscar repuesto';

  @override
  String get catalogSearchHint => 'Nombre o SKU';

  @override
  String get catalogNoPermission =>
      'Tu perfil no tiene permiso para ver el catálogo.';

  @override
  String get catalogCacheNotice =>
      'Sin conexión: mostrando el catálogo guardado.';

  @override
  String get catalogEmpty => 'Todavía no hay repuestos en el catálogo.';

  @override
  String get catalogEmptyFiltered =>
      'Ningún repuesto coincide con la búsqueda.';

  @override
  String get catalogClearFilters => 'Quitar filtros';

  @override
  String get categoryLubricants => 'Lubricantes';

  @override
  String get categoryBrakes => 'Frenos';

  @override
  String get categorySuspension => 'Suspensión';

  @override
  String get categoryEngine => 'Motor';

  @override
  String get categoryElectrical => 'Eléctrico';

  @override
  String get categoryTires => 'Llantas';

  @override
  String get categoryFilters => 'Filtros';

  @override
  String get categoryBodywork => 'Carrocería';

  @override
  String get categoryAccessories => 'Accesorios';

  @override
  String get stockOut => 'Agotado';

  @override
  String get stockLow => 'Stock mínimo';

  @override
  String get stockOk => 'Disponible';

  @override
  String partSku(String p1) {
    return 'SKU $p1';
  }

  @override
  String partBrand(String p1) {
    return 'Marca $p1';
  }

  @override
  String partStock(String p1) {
    return 'Stock: $p1';
  }

  @override
  String partPrice(String p1) {
    return '$p1 sin IGV';
  }

  @override
  String get partDetailTitle => 'Detalle de repuesto';

  @override
  String get batchesTitle => 'Lotes en orden FIFO';

  @override
  String get batchesSubtitle =>
      'El descargo consume primero el lote más antiguo con saldo.';

  @override
  String get batchesEmpty => 'Este repuesto no tiene lotes registrados.';

  @override
  String get batchesNoPermission =>
      'Tu perfil no tiene permiso para ver los lotes.';

  @override
  String get batchesCacheNotice =>
      'Sin conexión: mostrando los lotes guardados.';

  @override
  String get batchNext => 'Siguiente en salir';

  @override
  String get batchWaiting => 'Con saldo';

  @override
  String get batchDepleted => 'Agotado';

  @override
  String batchNumber(String p1) {
    return 'Lote $p1';
  }

  @override
  String batchArrival(String p1) {
    return 'Ingresó el $p1';
  }

  @override
  String batchRemaining(String p1) {
    return 'Saldo: $p1';
  }

  @override
  String batchUnitCost(String p1) {
    return 'Costo unitario: $p1';
  }

  @override
  String get taskPartsTitle => 'Repuestos de la tarea';

  @override
  String get taskPartsEmpty => 'Todavía no hay repuestos imputados.';

  @override
  String get taskPartsOnlineOnly =>
      'Los repuestos imputados se consultan con conexión.';

  @override
  String get taskTimerUnknownHint =>
      'El tiempo al pausar no está disponible en este teléfono.';

  @override
  String get taskPartsCharge => 'Imputar repuesto';

  @override
  String get taskPartUnnamed => 'Repuesto sin nombre';

  @override
  String taskPartQuantity(String p1) {
    return 'Cantidad: $p1';
  }

  @override
  String taskPartUnitPrice(String p1) {
    return 'Unitario: $p1';
  }

  @override
  String taskPartTotal(String p1) {
    return 'Total: $p1';
  }

  @override
  String get taskPartEdit => 'Corregir cantidad';

  @override
  String get taskPartReturn => 'Devolver a inventario';

  @override
  String get taskPartCharged =>
      'Repuesto imputado: el stock bajó por lotes FIFO.';

  @override
  String get taskPartUpdated => 'Cantidad actualizada.';

  @override
  String get taskPartReturned => 'Repuesto devuelto al lote de origen.';

  @override
  String get taskFieldQuantity => 'Escribe una cantidad mayor a 0.';

  @override
  String get chargeTitle => 'Imputar repuesto';

  @override
  String get chargeSelectPartPrompt => 'Repuestos disponibles en almacén:';

  @override
  String get chargeChangePartBtn => 'Cambiar repuesto seleccionado';

  @override
  String get chargeQuantity => 'Cantidad';

  @override
  String get chargeConfirm => 'Imputar a la tarea';

  @override
  String get editPartTitle => 'Corregir cantidad';

  @override
  String get editPartBody =>
      'El backend recalcula el costo de la orden con la nueva cantidad.';

  @override
  String get editPartConfirm => 'Guardar cantidad';

  @override
  String get returnTitle => 'Devolver a inventario';

  @override
  String get returnBody =>
      'Las unidades vuelven al lote del que salieron y se rebaja el costo imputado en la orden.';

  @override
  String get returnConfirm => 'Devolver repuesto';

  @override
  String get mainTabHome => 'Inicio';

  @override
  String get mainTabTasks => 'Tareas';

  @override
  String get mainTabOrders => 'Órdenes';

  @override
  String get mainTabReception => 'Recepción';

  @override
  String get mainTabObd => 'OBD-II';

  @override
  String get mainTabStock => 'Stock';

  @override
  String get mainTabProfile => 'Perfil';

  @override
  String get mainTabSettings => 'Ajustes';

  @override
  String get mainTabMore => 'Más';

  @override
  String get mainTabToday => 'Hoy';

  @override
  String get mainTabTeam => 'Equipo';

  @override
  String get mainObdTitle => 'Escáneres OBD-II';

  @override
  String get mainObdSubtitle =>
      'Enciende tu escáner OBD-II y acércalo al teléfono.';

  @override
  String get profileSignOut => 'Cerrar sesión';

  @override
  String get profileSignOutTitle => '¿Cerrar sesión?';

  @override
  String get profileSignOutMessage =>
      'Los registros pendientes de sincronizar se conservan cifrados en el teléfono.';

  @override
  String profileVersion(String p1) {
    return 'Atelier Workshop Mobile · versión $p1';
  }

  @override
  String get profileSectionAccount => 'Mi cuenta y taller';

  @override
  String get profileSectionOps => 'Operaciones y sincronización';

  @override
  String get profileSectionSession => 'Seguridad y sesión';

  @override
  String get profileSupportBtn => 'Habla con soporte técnico Atelier';

  @override
  String get profileSupportToast =>
      'Canal directo de soporte Atelier disponible vía WhatsApp o correo oficial.';

  @override
  String get profileItemPersonalData => 'Datos personales y rol';

  @override
  String get profileItemBranchShift => 'Sede activa y turno';

  @override
  String get profileItemPlan => 'Plan y módulos contratados';

  @override
  String profilePlanFormat(String p1) {
    return 'Plan $p1';
  }

  @override
  String get profileItemSync => 'Cola de sincronización offline';

  @override
  String get profileItemNotifications => 'Bandeja de notificaciones';

  @override
  String get profileItemPermissions => 'Permisos de acceso de tu rol';

  @override
  String get profileSyncUpToDate => 'Todo sincronizado con el servidor';

  @override
  String profilePermissionsCount(int p1) {
    return '$p1 permisos operativos asignados';
  }

  @override
  String get commonCancel => 'Cancelar';

  @override
  String profilePendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros pendientes de sincronizar',
      one: '$count registro pendiente de sincronizar',
    );
    return '$_temp0';
  }

  @override
  String get ordersTitle => 'Órdenes de la sede';

  @override
  String get ordersSubtitle =>
      'Órdenes de trabajo abiertas. Entra a una para ver sus tareas.';

  @override
  String get ordersEmpty => 'No hay órdenes abiertas.';

  @override
  String get ordersNoPermission =>
      'Tu perfil no tiene permiso para ver órdenes.';

  @override
  String get ordersCacheNotice =>
      'Sin conexión: mostrando las órdenes guardadas.';

  @override
  String get ordersNoNumber => 'Orden sin número';

  @override
  String ordersTotal(String p1) {
    return 'Total: $p1';
  }

  @override
  String get orderDetailTitle => 'Detalle de orden';

  @override
  String get orderTasksTitle => 'Tareas de la orden';

  @override
  String get orderTasksEmpty => 'Esta orden aún no tiene tareas.';

  @override
  String orderTaskMechanic(String p1) {
    return 'Mecánico: $p1';
  }

  @override
  String orderTaskParts(int p1) {
    return 'Repuestos imputados: $p1';
  }

  @override
  String get orderStatusDraft => 'Borrador';

  @override
  String get orderStatusInProgress => 'En curso';

  @override
  String get orderStatusCompleted => 'Completada';

  @override
  String get orderStatusPaid => 'Pagada';

  @override
  String get orderStatusCanceled => 'Cancelada';

  @override
  String get orderStatusUnknown => 'Sin estado';

  @override
  String orderCodeFormat(String p1) {
    return 'OT-$p1';
  }

  @override
  String get orderStatusWaitingCustomer => 'Esperando al cliente';

  @override
  String get orderTaskLabor => 'Mano de obra';

  @override
  String orderTaskHours(int p1) {
    return '$p1 h';
  }

  @override
  String orderTaskMinutes(int p1) {
    return '$p1 min';
  }

  @override
  String orderTaskHoursMinutes(int p1, int p2) {
    return '$p1 h $p2 min';
  }

  @override
  String orderPartLineDetail(String p1, String p2) {
    return '$p1 × $p2';
  }

  @override
  String get orderAddPart => 'Agregar repuesto';

  @override
  String get orderAddTask => 'Agregar tarea';

  @override
  String get orderEditLabor => 'Editar mano de obra';

  @override
  String get orderOpenTaskDetail => 'Abrir cronómetro y tarea';

  @override
  String get orderAddTaskTitle => 'Agregar tarea';

  @override
  String get orderAddTaskService => 'Servicio';

  @override
  String get orderAddTaskDescription => 'Descripción de la tarea';

  @override
  String get orderAddTaskPrice => 'Mano de obra sin IGV';

  @override
  String get orderAddTaskConfirm => 'Agregar a la orden';

  @override
  String get orderEditLaborTitle => 'Editar mano de obra';

  @override
  String get orderEditLaborConfirm => 'Guardar precio';

  @override
  String get orderFieldService => 'Elige un servicio del catálogo.';

  @override
  String get orderFieldDescription => 'Escribe la descripción de la tarea.';

  @override
  String get orderFieldPrice => 'Escribe un monto mayor o igual a 0.';

  @override
  String get orderTaskAdded => 'Tarea agregada y totales recalculados.';

  @override
  String get orderTaskUpdated =>
      'Mano de obra actualizada y totales recalculados.';

  @override
  String get orderDeleteTask => 'Eliminar tarea';

  @override
  String get orderDeleteTaskTitle => 'Eliminar tarea de la orden';

  @override
  String orderDeleteTaskBody(String p1) {
    return 'Se quitará \"$p1\" de la orden y se recalcularán los totales.';
  }

  @override
  String get orderDeleteTaskHasParts =>
      'Esta tarea tiene repuestos imputados. Retira primero los repuestos antes de eliminarla.';

  @override
  String get orderDeleteTaskConfirm => 'Eliminar tarea';

  @override
  String get orderTaskDeleted => 'Tarea eliminada y totales recalculados.';

  @override
  String get servicesTitle => 'Servicios del taller';

  @override
  String get servicesSubtitle =>
      'Mano de obra estándar y tarifas base (sin IGV)';

  @override
  String get servicesSearchHint => 'Buscar servicio…';

  @override
  String get servicesEmpty =>
      'Aún no hay servicios registrados en el catálogo del taller.';

  @override
  String get servicesEmptySearch => 'No encontramos servicios con ese nombre.';

  @override
  String get servicesAdd => 'Nuevo servicio';

  @override
  String get servicesNewTitle => 'Nuevo servicio';

  @override
  String get servicesEditTitle => 'Editar servicio';

  @override
  String get servicesSaveCreate => 'Crear servicio';

  @override
  String get servicesSaveEdit => 'Guardar cambios';

  @override
  String get servicesNameLabel => 'Nombre del servicio';

  @override
  String get servicesNameHint => 'Ej. Afinamiento de motor';

  @override
  String get servicesPriceLabel => 'Tarifa base sin IGV (S/)';

  @override
  String get servicesPriceHint => '120.00';

  @override
  String get servicesDurationLabel => 'Duración estimada (minutos)';

  @override
  String get servicesDurationHint => '45';

  @override
  String get servicesFieldName =>
      'Escribe el nombre del servicio (máximo 150 caracteres).';

  @override
  String get servicesFieldPrice => 'Escribe una tarifa mayor a 0.';

  @override
  String get servicesFieldDuration =>
      'Escribe una duración en minutos mayor a 0.';

  @override
  String servicesDurationMin(int p1) {
    return '$p1 min';
  }

  @override
  String get servicesDeleteAction => 'Eliminar servicio';

  @override
  String get servicesDeleteTitle => 'Eliminar servicio';

  @override
  String servicesDeleteBody(String p1) {
    return '¿Seguro que deseas eliminar \"$p1\" del catálogo? Solo se puede eliminar si no tiene tareas registradas en órdenes de trabajo.';
  }

  @override
  String get servicesDeleteConfirm => 'Eliminar';

  @override
  String get servicesCreatedNotice => 'Servicio agregado al catálogo.';

  @override
  String get servicesUpdatedNotice => 'Servicio actualizado.';

  @override
  String get servicesDeletedNotice => 'Servicio eliminado del catálogo.';

  @override
  String get servicesReadonlyHint =>
      'Solo puedes consultar el catálogo. Para editar tarifas necesitas permiso de gestión de servicios.';

  @override
  String get quotationSubtotal => 'Subtotal';

  @override
  String get quotationIgv => 'IGV 18 %';

  @override
  String get quotationTotal => 'Total';

  @override
  String get quotationGeneratePdf => 'Generar proforma';

  @override
  String get quotationSharePdf => 'Compartir proforma PDF';

  @override
  String get quotationSendEmail => 'Enviar proforma por correo';

  @override
  String get quotationPdfReady => 'Proforma generada y lista para compartir.';

  @override
  String quotationSentNotice(String p1) {
    return 'Proforma enviada a $p1.';
  }

  @override
  String get quotationShareChooser => 'Compartir proforma';

  @override
  String get quotationNoPdfApp =>
      'No hay una aplicación instalada para abrir o compartir el PDF.';

  @override
  String get quotationCustomerQuestion => '¿Qué respondió el cliente?';

  @override
  String get quotationApproveAction => 'Aceptó. Iniciar trabajos';

  @override
  String get quotationRejectAction => 'Rechazó. Cancelar orden';

  @override
  String get quotationApprovedNotice =>
      'Orden en progreso. Los técnicos ya pueden empezar.';

  @override
  String get quotationRejectedNotice =>
      'Orden cancelada. Los repuestos reservados volvieron al inventario.';

  @override
  String get quotationRejectTitle => 'Cancelar la orden';

  @override
  String get quotationRejectBody =>
      'Los repuestos reservados volverán al inventario.';

  @override
  String get quotationRejectReasonLabel => 'Motivo del rechazo';

  @override
  String get quotationRejectReasonHint => 'Precio fuera de presupuesto';

  @override
  String get quotationRejectFieldError =>
      'Escribe el motivo del rechazo (máximo 1000 caracteres).';

  @override
  String get quotationRejectConfirm => 'Cancelar orden';

  @override
  String get quotationRejectBack => 'Volver';

  @override
  String get orderOpenProposals => 'Ver propuestas de hallazgos';

  @override
  String get orderOpenGallery => 'Ver fotos de recepción';

  @override
  String get orderIntakeIncompleteTitle => 'Datos de ingreso pendientes';

  @override
  String get orderIntakeIncompleteBody =>
      'El odómetro actual o la recepción de patio no han sido completados para esta orden.';

  @override
  String get orderCompleteIntakeBtn => 'Completar odómetro e ingreso';

  @override
  String get ordersNewBtn => 'Nueva orden';

  @override
  String get ordersNewSheetTitle => 'Nueva orden de trabajo';

  @override
  String get ordersNewSheetSubtitle =>
      'Selecciona una cita programada para hoy o realiza un ingreso presencial.';

  @override
  String get ordersNewByAppointmentSection => 'Citas agendadas para hoy';

  @override
  String get ordersNewAppointmentArriveCta => 'Marcar llegada y abrir orden';

  @override
  String get ordersNewNoAppointments =>
      'No hay citas agendadas para el día de hoy.';

  @override
  String get ordersNewWalkInSection => 'Ingreso presencial sin cita';

  @override
  String get ordersNewWalkInTitle => 'Ingreso directo en patio';

  @override
  String get ordersNewWalkInDesc =>
      'Consultar placa o DNI para registrar recepción y abrir orden';

  @override
  String get ordersNewWalkInCta => 'Consultar placa en recepción';

  @override
  String get ordersCompleteDraftCta => 'Completar ingreso';

  @override
  String attendanceOutsideGeofenceBlocked(int p1, int p2) {
    return 'No puedes marcar fuera de la geocerca: estás a $p1 m de la sede y el radio permitido es $p2 m.';
  }

  @override
  String get attendanceMockLocationBlocked =>
      'No se permite marcar con una ubicación simulada. Desactiva la aplicación de ubicación ficticia e inténtalo de nuevo.';

  @override
  String get attendanceBranchGeofenceUnavailable =>
      'No se pudo validar la geocerca de tu sede porque no está disponible sin conexión. Conéctate y actualiza la información antes de marcar.';

  @override
  String attendanceSelectedDayHours(String p1, String p2) {
    return 'Horario asignado: $p1 – $p2';
  }

  @override
  String get attendanceSelectedDayRest =>
      'No tienes turno asignado para este día.';

  @override
  String get attendanceClockOutConfirmTitle => 'Confirmar salida';

  @override
  String get attendanceClockOutConfirmMessage =>
      '¿Deseas cerrar tu jornada laboral? El sistema registrará la hora de salida y calculará las horas regulares y el sobretiempo.';

  @override
  String get attendanceClockOutConfirmAction => 'Confirmar salida';

  @override
  String get branchAssignedBadge => 'Sucursal asignada para tu jornada';

  @override
  String get receptionTabCounter => 'Recepción';

  @override
  String receptionTabCustomersCount(int p1) {
    return 'Clientes ($p1)';
  }

  @override
  String receptionTabVehiclesCount(int p1) {
    return 'Vehículos ($p1)';
  }

  @override
  String get receptionQuickWalkIn => 'Ingreso presencial';

  @override
  String get receptionCustomersDirectoryTitle =>
      'Cartera de clientes del taller';

  @override
  String get receptionNewCustomerBtn => 'Nuevo cliente';

  @override
  String get receptionCustomersFilterLabel =>
      'Filtrar por nombre, DNI/RUC, teléfono o correo';

  @override
  String get receptionCustomersEmptyDirectory =>
      'No hay clientes registrados con ese filtro.';

  @override
  String get receptionRefreshDirectory => 'Actualizar cartera';

  @override
  String get receptionVehiclesDirectoryTitle =>
      'Vehículos registrados en el taller';

  @override
  String get receptionNewVehicleBtn => 'Nuevo vehículo';

  @override
  String get receptionVehiclesFilterLabel =>
      'Filtrar por placa, marca, modelo o propietario';

  @override
  String get receptionVehiclesEmptyDirectory =>
      'No hay vehículos registrados con ese filtro.';

  @override
  String receptionVehicleMileageKm(int p1) {
    return 'Odómetro: $p1 km';
  }

  @override
  String get receptionAddVehicleToCustomer => 'Agregar vehículo al cliente';

  @override
  String get registerVehicleForCustomerTitle => 'Agregar vehículo a cliente';

  @override
  String registerVehicleForCustomerBanner(String p1) {
    return 'Propietario seleccionado: $p1';
  }

  @override
  String get openOrderQuickReasonGeneral =>
      'Ingreso presencial / Revisión general';

  @override
  String get openOrderQuickReasonPreventive => 'Mantenimiento preventivo';

  @override
  String get quotationLaborSubtotal => 'Subtotal mano de obra';

  @override
  String get quotationPartsSubtotal => 'Subtotal repuestos';

  @override
  String get quotationPdfPreviewTitle => 'Proforma digital (PDF)';

  @override
  String quotationPdfPageDesc(int p1) {
    return 'Página $p1 de la proforma';
  }

  @override
  String get quotationPdfClose => 'Cerrar vista previa';

  @override
  String orderIntakePhotosBadge(int p1) {
    return '$p1 fotos en patio';
  }

  @override
  String get orderAssignBayTitle => 'Asignar bahía de trabajo';

  @override
  String get orderAssignBaySubtitle =>
      'Selecciona una bahía libre para la intervención técnica del vehículo.';

  @override
  String get orderBayCurrent => 'Bahía actual';

  @override
  String orderAssignToBay(String p1) {
    return 'Asignar a $p1';
  }

  @override
  String get orderAssignBayBtn => 'Asignar bahía de trabajo';

  @override
  String orderChangeBayBtn(String p1) {
    return 'Bahía: $p1 (Cambiar)';
  }

  @override
  String orderBayAssignedNotice(String p1) {
    return 'Orden asignada a $p1 para intervención técnica.';
  }

  @override
  String get orderTaskMechanicLabel => 'Mecánico asignado';

  @override
  String get orderAssignMechanicBtn => 'Asignar mecánico';

  @override
  String get orderReassignMechanicBtn => 'Reasignar mecánico';

  @override
  String get orderMechanicUnassigned => 'Sin mecánico asignado';

  @override
  String get orderAssignMechanicTitle => 'Asignar mecánico a la tarea';

  @override
  String orderAssignMechanicSubtitle(String p1) {
    return 'Selecciona el especialista técnico para la tarea «$p1».';
  }

  @override
  String get orderMechanicsEmpty => 'No hay mecánicos disponibles en la sede.';

  @override
  String get orderMechanicCurrent => 'Asignado actualmente';

  @override
  String orderMechanicAssignedNotice(String p1) {
    return 'Mecánico $p1 asignado a la tarea.';
  }

  @override
  String get orderAddTaskMechanic => 'Mecánico responsable (opcional)';

  @override
  String get orderMechanicRoleDefault => 'Técnico automotriz';

  @override
  String get baysTitle => 'Bahías de trabajo';

  @override
  String get baysNoPermission =>
      'Tu perfil no tiene permiso para consultar las bahías.';

  @override
  String baysFilterAll(int p1) {
    return 'Todas ($p1)';
  }

  @override
  String baysFilterAvailable(int p1) {
    return 'Libres ($p1)';
  }

  @override
  String baysFilterOccupied(int p1) {
    return 'Ocupadas ($p1)';
  }

  @override
  String get baysEmpty => 'No hay bahías registradas para este filtro.';

  @override
  String get baysRefresh => 'Actualizar';

  @override
  String get baysSelectOrderPrompt =>
      'Elige la orden de trabajo que ingresará a esta bahía:';

  @override
  String get baysAssignOrderBtn => 'Ingresar orden a esta bahía';

  @override
  String get baysNewBtn => 'Nueva bahía';

  @override
  String get baysCreateDialogTitle => 'Registrar bahía física';

  @override
  String get baysNameLabel => 'Nombre de la bahía';

  @override
  String get baysNameHint => 'Ej. Elevador 3, Bahía Rápida 2';

  @override
  String get baysTypeLabel => 'Tipo de instalación';

  @override
  String get baysCreateConfirm => 'Registrar bahía';

  @override
  String baysCreatedNotice(String p1) {
    return 'Bahía $p1 registrada exitosamente.';
  }

  @override
  String get bayTypeLift => 'Elevador hidráulico';

  @override
  String get bayTypeMechanicalLift => 'Elevador mecánico';

  @override
  String get bayTypeDiagnosticPit => 'Fosa de diagnóstico';

  @override
  String get bayTypeWashBay => 'Bahía de lavado';

  @override
  String get bayTypeAlignment => 'Estación de alineación';

  @override
  String get bayTypePaintBooth => 'Cabina de pintura';

  @override
  String get bayStatusAvailable => 'Libre';

  @override
  String get bayStatusOccupied => 'Ocupada';

  @override
  String get bayStatusMaintenance => 'Mantenimiento';

  @override
  String get obdInventorySubtitle =>
      'Inventario de escáneres OBD-II registrados en el taller y su estado operativo.';

  @override
  String get obdRegisterBtn => 'Registrar escáner OBD-II';

  @override
  String get obdFilterAll => 'Todos';

  @override
  String get obdFilterActive => 'Activos';

  @override
  String get obdFilterInactive => 'Inactivos';

  @override
  String get obdEmptyList =>
      'No hay escáneres OBD-II registrados con este filtro.';

  @override
  String get obdRegisterDialogTitle => 'Registrar escáner OBD-II';

  @override
  String get obdFieldIdentifier => 'Identificador / MAC / Serie';

  @override
  String get obdFieldConnectionType => 'Tipo de conexión';

  @override
  String get obdFieldModel => 'Modelo de hardware';

  @override
  String get obdFieldFirmware => 'Versión de firmware';

  @override
  String get obdRegisterConfirm => 'Registrar dispositivo';

  @override
  String get obdChangeStatusPrompt =>
      'Selecciona el nuevo estado operativo del escáner:';

  @override
  String get obdChangeStatusBtn => 'Cambiar estado';

  @override
  String get obdStatusActive => 'Activo';

  @override
  String get obdStatusInactive => 'Inactivo';

  @override
  String get obdStatusLost => 'Extraviado';

  @override
  String get obdStatusBroken => 'Averiado';

  @override
  String obdRegisteredNotice(String p1) {
    return 'Escáner $p1 registrado en el inventario del taller.';
  }

  @override
  String obdStatusUpdatedNotice(String p1) {
    return 'Estado de $p1 actualizado.';
  }

  @override
  String get obdConnectedVehicle => 'Conectado a vehículo';

  @override
  String obdConnectedVehicleFormat(String p1, String p2) {
    return '$p1 · $p2';
  }

  @override
  String obdConnectedOwnerFormat(String p1) {
    return 'Titular: $p1';
  }

  @override
  String get obdNotConnected => 'Sin vehículo asignado';

  @override
  String get obdInstallBtn => 'Vincular';

  @override
  String get obdUninstallBtn => 'Desvincular';

  @override
  String get obdInstallDialogTitle => 'Vincular escáner a vehículo';

  @override
  String get obdInstallSelectPrompt =>
      'Selecciona un vehículo del padrón del taller:';

  @override
  String get obdUninstallConfirmTitle => 'Desvincular escáner';

  @override
  String obdUninstallConfirmPrompt(String p1) {
    return '¿Confirmas desvincular este escáner de $p1?';
  }

  @override
  String obdInstallSuccess(String p1) {
    return 'Escáner vinculado a $p1.';
  }

  @override
  String get obdUninstallSuccess => 'Escáner desvinculado con éxito.';

  @override
  String get syncQueueTitle => 'Sincronización offline';

  @override
  String get syncQueueSubtitle =>
      'Registros capturados en el teléfono pendientes de envío al servidor.';

  @override
  String get syncStatusOnline =>
      'Conectado: la sincronización automática está activa.';

  @override
  String get syncStatusOffline =>
      'Sin conexión: los registros se enviarán en cuanto vuelva la red.';

  @override
  String get syncRequestedNotice => 'Sincronización iniciada en segundo plano.';

  @override
  String syncNowBtn(int p1) {
    return 'Sincronizar ahora ($p1)';
  }

  @override
  String get syncEmptyTitle => 'Todo sincronizado';

  @override
  String get syncEmptyBody =>
      'No tienes registros pendientes de envío en la cola local.';

  @override
  String get syncOpPending => 'En cola';

  @override
  String get syncOpSyncing => 'Enviando';

  @override
  String get syncOpFailed => 'Con error';

  @override
  String syncOpMeta(String p1, int p2) {
    return 'Creado: $p1 · Intentos: $p2';
  }

  @override
  String get syncRetryBtn => 'Reintentar';

  @override
  String get syncDiscardBtn => 'Descartar';

  @override
  String get syncTypeClockIn => 'Marcación de ingreso';

  @override
  String get syncTypeClockOut => 'Marcación de salida';

  @override
  String get syncTypeJustification => 'Justificación de asistencia';

  @override
  String get syncTypeUploadFile => 'Subida de fotografía';

  @override
  String get syncTypeIntakeImage => 'Evidencia fotográfica de recepción';

  @override
  String get syncTypeTaskEvidence => 'Evidencia de tarea técnica';

  @override
  String get syncTypeStartTask => 'Inicio de tarea';

  @override
  String get syncTypePauseTask => 'Pausa de tarea';

  @override
  String get syncTypeResumeTask => 'Reanudación de tarea';

  @override
  String get syncTypeCompleteTask => 'Cierre de tarea';

  @override
  String get syncTypeTelemetry => 'Lote de telemetría OBD-II';

  @override
  String get syncTypeRegisterFault => 'Registro de falla DTC';

  @override
  String get syncTypeResolveFault => 'Resolución de falla DTC';

  @override
  String get notificationsTitle => 'Notificaciones y alertas';

  @override
  String get notificationsDisabledTitle =>
      'Notificaciones desactivadas en el teléfono';

  @override
  String get notificationsDisabledBody =>
      'Activa el permiso de notificaciones para recibir avisos de tareas, stock y asistencia.';

  @override
  String get notificationsEnableBtn => 'Activar notificaciones';

  @override
  String get notificationsEnabledBanner =>
      'Las notificaciones push están activas para tu sesión.';

  @override
  String notificationsSyncPendingTitle(int p1) {
    return '$p1 registros pendientes de sincronizar';
  }

  @override
  String get notificationsSyncPendingBody =>
      'Toca para revisar o forzar la sincronización con el servidor.';

  @override
  String notificationsSectionStock(int p1) {
    return 'Alertas de reposición de stock ($p1)';
  }

  @override
  String notificationsStockDeficitLine(String p1, String p2, String p3) {
    return 'SKU $p1 · Stock actual: $p2 (Mínimo: $p3)';
  }

  @override
  String get notificationsLowStockChip => 'Stock bajo';

  @override
  String notificationsSectionJustifications(int p1) {
    return 'Justificaciones por revisar ($p1)';
  }

  @override
  String get notificationsJustificationChip => 'Por aprobar';

  @override
  String notificationsSectionQuotations(int p1) {
    return 'Proformas esperando al cliente ($p1)';
  }

  @override
  String get notificationsSectionPush => 'Avisos recibidos en esta sesión';

  @override
  String get notificationsMarkAllRead => 'Marcar leídos';

  @override
  String get notificationsEmptyTitle => 'Sin alertas pendientes';

  @override
  String get notificationsEmptyBody =>
      'Aquí verás los avisos push, alertas de stock mínimo y justificaciones del personal.';

  @override
  String get adminAttendanceTitle => 'Asistencia y personal';

  @override
  String adminAttendanceTabBranch(int p1) {
    return 'Sede hoy ($p1)';
  }

  @override
  String adminAttendanceTabJustifications(int p1) {
    return 'Justificaciones ($p1)';
  }

  @override
  String get adminAttendanceTabOwn => 'Mi asistencia';

  @override
  String get adminAttendanceEmpty =>
      'No hay registros de asistencia para mostrar hoy en esta sede.';

  @override
  String adminAttendanceJustificationLine(String p1) {
    return 'Descargo: $p1';
  }

  @override
  String get adminAttendanceApproveBtn => 'Aprobar justificación';

  @override
  String get adminAttendanceRejectBtn => 'Rechazar';

  @override
  String get adminAttendanceJustificationApproved =>
      'Justificación aprobada (asistencia justificada).';

  @override
  String get adminAttendanceJustificationRejected =>
      'Justificación desestimada.';

  @override
  String get dashboardTitle => 'Panel de sede';

  @override
  String dashboardSyncBadge(int p1) {
    return 'Cola ($p1)';
  }

  @override
  String dashboardAlertsBadge(int p1) {
    return 'Alertas ($p1)';
  }

  @override
  String get dashboardAlertsBtn => 'Alertas';

  @override
  String get dashboardBranchLabel => 'Sucursal activa de la jornada';

  @override
  String get dashboardSelectBranchPrompt => 'Seleccionar sucursal asignada';

  @override
  String get dashboardChangeBranchBtn => 'Sucursal';

  @override
  String get dashboardReceptionCtaTitle => 'Recepción de vehículos en patio';

  @override
  String get dashboardReceptionCtaBody =>
      'Consulta por placa de rodaje o DNI/RUC, registra el odómetro, adjunta fotos de ingreso y genera la proforma digital.';

  @override
  String get dashboardSearchPlateBtn => 'Consultar placa';

  @override
  String get dashboardKpiOrders => 'Órdenes activas';

  @override
  String dashboardKpiOrdersSub(int p1, int p2) {
    return '$p1 en proforma · $p2 en bahía';
  }

  @override
  String dashboardKpiDraftsChip(int p1) {
    return '$p1 proformas';
  }

  @override
  String get dashboardKpiBays => 'Bahías de trabajo';

  @override
  String dashboardKpiBaysSub(int p1) {
    return '$p1 bahías disponibles';
  }

  @override
  String get dashboardKpiCrm => 'Clientes y vehículos';

  @override
  String dashboardKpiCrmSub(int p1) {
    return '$p1 citas agendadas hoy';
  }

  @override
  String get dashboardKpiStock => 'Alertas de stock';

  @override
  String get dashboardKpiStockSub => 'Repuestos bajo el mínimo';

  @override
  String get dashboardKpiAttendance => 'Personal en sede';

  @override
  String dashboardKpiAttendanceSub(int p1) {
    return '$p1 justificaciones pendientes';
  }

  @override
  String get dashboardKpiObd => 'Escáneres OBD-II';

  @override
  String get dashboardKpiObdSub => 'Activos en inventario';

  @override
  String dashboardSectionDrafts(int p1) {
    return 'Proformas pendientes de aprobación ($p1)';
  }

  @override
  String dashboardSectionInProgress(int p1) {
    return 'En intervención técnica en bahía ($p1)';
  }

  @override
  String get dashboardSeeAll => 'Ver todas';

  @override
  String get dashboardSeeBays => 'Ver bahías';

  @override
  String get dashboardWalkInBtn => 'Registrar ingreso presencial';

  @override
  String get dashboardOpenProformaBtn => 'Abrir proforma';

  @override
  String get dashboardManageOrderBtn => 'Ver intervención';

  @override
  String get moreHubTitle => 'Gestión del taller';

  @override
  String get moreHubSubtitle =>
      'Todos los módulos operativos, administrativos y de sincronización de tu sede.';

  @override
  String get moreSectionOperations => 'Operaciones y recepción';

  @override
  String get moreItemBranchTitle => 'Cambiar o confirmar sucursal';

  @override
  String get moreItemBranchSub =>
      'Selecciona la sede asignada para tu jornada operativa';

  @override
  String get moreItemReceptionTitle => 'Recepción, clientes y vehículos';

  @override
  String get moreItemReceptionSub =>
      'Búsqueda por placa, cartera de clientes y padrón de vehículos';

  @override
  String get moreItemBaysSub =>
      'Disponibilidad de bahías y asignación de órdenes en curso';

  @override
  String get moreItemObdSub =>
      'Consultar, registrar y actualizar el estado de los escáneres OBD-II';

  @override
  String get moreSectionInventoryHr => 'Almacén y recursos humanos';

  @override
  String get moreItemCatalogTitle => 'Catálogo y lotes de repuestos';

  @override
  String get moreItemCatalogSub =>
      'Existencias por SKU, precios base y lotes FIFO';

  @override
  String get moreItemStockAlertsTitle => 'Alertas de reposición';

  @override
  String get moreItemStockAlertsSub => 'Ítems en stock mínimo o agotados';

  @override
  String get moreItemPurchasesTitle => 'Órdenes de compra';

  @override
  String get moreItemPurchasesSub =>
      'Recepción de mercadería e ingreso al almacén';

  @override
  String get moreItemValuationTitle => 'Valorización de inventario';

  @override
  String get moreItemValuationSub => 'Valor contable del stock en sede';

  @override
  String get moreItemAttendanceSub =>
      'Asistencia diaria del personal de sede, justificaciones y marcación propia';

  @override
  String get moreSectionSystem => 'Sistema, alertas y cuenta';

  @override
  String get moreItemNotificationsSub =>
      'Bandeja de notificaciones push y alertas operativas';

  @override
  String get moreItemSyncSub =>
      'Cola de operaciones capturadas sin conexión y reintento manual';

  @override
  String get moreItemProfileSub => 'Datos de tu cuenta y cierre de sesión';

  @override
  String registerVehicleForExistingCustomer(String p1, String p2) {
    return 'Propietario seleccionado: $p1 ($p2)';
  }

  @override
  String get employeeDashboardTitle => 'Panel del colaborador';

  @override
  String get employeeShiftLabel => 'Jornada laboral';

  @override
  String get employeeShiftNotAssigned => 'Sin turno asignado para hoy';

  @override
  String get employeeAttendanceStatusIn => 'Jornada iniciada';

  @override
  String get employeeAttendanceStatusOut => 'Jornada finalizada';

  @override
  String get employeeAttendanceStatusPending => 'Pendiente de ingreso';

  @override
  String get employeeClockInBtn => 'Marcar ingreso';

  @override
  String get employeeClockOutBtn => 'Marcar salida';

  @override
  String get employeeActiveTaskSection => 'Tarea en curso';

  @override
  String get employeeNoActiveTask => 'Sin labor activa en curso';

  @override
  String get employeeNoActiveTaskSub =>
      'Selecciona una tarea de tu lista para iniciar el cronómetro de patio';

  @override
  String get employeeSeeAllTasks => 'Ver mis tareas';

  @override
  String get employeeKpiCompletedToday => 'Completadas hoy';

  @override
  String get employeeKpiPendingTasks => 'Por realizar';

  @override
  String get employeeKpiTotalTasks => 'Asignadas';

  @override
  String get employeeQuickActions => 'Operaciones de patio';

  @override
  String get employeeActionObd => 'Escáneres OBD-II';

  @override
  String get employeeActionReportFinding => 'Reportar hallazgo';

  @override
  String get employeeActionViewStock => 'Consultar repuestos';

  @override
  String get employeeActionAttendanceDetails => 'Ver registro de asistencia';

  @override
  String get employeeClockOutConfirmTitle => 'Confirmar marcación de salida';

  @override
  String get employeeClockOutConfirmMsg =>
      '¿Deseas registrar la salida de tu jornada laboral ahora?';

  @override
  String get employeeFindingNoOrdersTitle => 'Sin órdenes asignadas';

  @override
  String get employeeFindingNoOrdersMessage =>
      'No tienes tareas asignadas a ninguna orden de trabajo en este momento. Solo puedes reportar hallazgos técnicos en las órdenes donde tengas una tarea asignada.';

  @override
  String get employeeFindingSelectOrderTitle => 'Seleccionar orden de trabajo';

  @override
  String get employeeFindingSelectOrderSubtitle =>
      'Selecciona la orden donde detectaste el hallazgo técnico:';

  @override
  String get employeeDialogUnderstood => 'Entendido';

  @override
  String todayCars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count autos',
      one: '$count auto',
    );
    return '$_temp0';
  }

  @override
  String get todayCaption => 'en el taller hoy';

  @override
  String todayContext(String p1, String p2) {
    return '$p1 · $p2';
  }

  @override
  String get todayFigureInBay => 'en bahía';

  @override
  String get todayFigureReady => 'listos para entregar';

  @override
  String get todayFigureOnShift => 'en turno';

  @override
  String get todayDecisions => 'Esperan tu decisión';

  @override
  String get todayOpenOrders => 'Órdenes abiertas';

  @override
  String get todaySeeAll => 'Ver todas';

  @override
  String get todayReceiveVehicle => 'Recibir vehículo';

  @override
  String get todayOrdersEmpty => 'No hay órdenes abiertas en esta sede.';

  @override
  String get todayOrdersNoPermission =>
      'Tu cuenta no puede ver las órdenes de la sede.';

  @override
  String get todayOfflineCache =>
      'Sin conexión. Ves lo último que se guardó en este teléfono.';

  @override
  String todayOrderNumber(int p1) {
    return 'Orden #$p1';
  }

  @override
  String get todayOrderNoNumber => 'Orden sin número';

  @override
  String get todayDecisionDraft => 'Orden sin iniciar';

  @override
  String get todayDecisionJustification => 'Descargo de asistencia';

  @override
  String get todayDecisionJustificationLate => 'Descargo por tardanza';

  @override
  String get todayDecisionJustificationAbsent => 'Descargo por falta';

  @override
  String get todayCollaboratorFallback => 'Colaborador';

  @override
  String get todayJustificationApprove => 'Aprobar descargo';

  @override
  String get todayJustificationReject => 'Rechazar descargo';

  @override
  String get todayJustificationApproved => 'Aprobado';

  @override
  String get todayJustificationRejected => 'Rechazado';

  @override
  String get todayJustificationNoReason => 'Sin motivo escrito.';

  @override
  String get todayJustificationNoPermission =>
      'Tu cuenta no puede aprobar ni rechazar descargos.';

  @override
  String todayJustificationsPartial(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'No se pudieron consultar $count días de descargos. Desliza para reintentar.',
      one:
          'No se pudo consultar $count día de descargos. Desliza para reintentar.',
    );
    return '$_temp0';
  }

  @override
  String get todayDecisionSuspension => 'Suspensión por pieza defectuosa';

  @override
  String get ordersPendingSuspensionChip => 'Suspensión por revisar';

  @override
  String get syncTypeSubmitProposal => 'Propuesta de hallazgo técnico';

  @override
  String authDevicePendingBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Hay $count operaciones pendientes en este teléfono. Se sincronizarán cuando la cuenta correspondiente inicie sesión.',
      one:
          'Hay $count operación pendiente en este teléfono. Se sincronizará cuando la cuenta correspondiente inicie sesión.',
    );
    return '$_temp0';
  }

  @override
  String get authDeeplinkSignedInWarning =>
      'Cierra sesión para usar este enlace.';

  @override
  String get commonDiscardChangesTitle => '¿Descartar cambios?';

  @override
  String get commonDiscardChangesBody =>
      'Si sales ahora se perderán los datos escritos en este formulario.';

  @override
  String get commonKeepEditing => 'Seguir editando';

  @override
  String get commonDiscardAction => 'Descartar';

  @override
  String get commonConfirm => 'Aceptar';

  @override
  String get cashierMethodCash => 'Efectivo';

  @override
  String get cashierMethodCreditCard => 'Tarjeta de crédito';

  @override
  String get cashierMethodDebitCard => 'Tarjeta de débito';

  @override
  String get cashierMethodBankTransfer => 'Transferencia';

  @override
  String get cashierMethodYape => 'Yape';

  @override
  String get cashierMethodPlin => 'Plin';

  @override
  String get cashierMethodUnknown => 'Otro medio';

  @override
  String get cashierTypeFactura => 'Factura';

  @override
  String get cashierTypeBoleta => 'Boleta';

  @override
  String get cashierTypeCreditNote => 'Nota de crédito';

  @override
  String get cashierTypeUnknown => 'Comprobante';

  @override
  String get cashierDocRuc => 'RUC';

  @override
  String get cashierDocDni => 'DNI';

  @override
  String get cashierDocCe => 'CE';

  @override
  String get cashierDocPassport => 'Pasaporte';

  @override
  String get cashierVstatusDraft => 'Borrador';

  @override
  String get cashierVstatusIssued => 'Emitido';

  @override
  String get cashierVstatusAccepted => 'Aceptado por SUNAT';

  @override
  String get cashierVstatusRejected => 'Rechazado por SUNAT';

  @override
  String get cashierVstatusVoided => 'Anulado';

  @override
  String get cashierVstatusUnknown => 'Sin estado';

  @override
  String get cashierPstatusPending => 'Sin cobrar';

  @override
  String get cashierPstatusPartial => 'Cobro parcial';

  @override
  String get cashierPstatusPaid => 'Pagado';

  @override
  String get cashierSubtotal => 'Subtotal';

  @override
  String cashierIgv(int p1) {
    return 'IGV ($p1 %)';
  }

  @override
  String get cashierTotal => 'Total';

  @override
  String get cashierCollected => 'Cobrado';

  @override
  String get cashierBalance => 'Saldo';

  @override
  String cashierVoucherName(String p1, String p2) {
    return '$p1 $p2';
  }

  @override
  String get cashierErrLines =>
      'Falta el nombre de alguna línea del comprobante.';

  @override
  String get cashierErrTaxId =>
      'Revisa el documento del cliente: la factura pide un RUC de 11 dígitos.';

  @override
  String get cashierErrSerie =>
      'La serie debe tener 4 caracteres: la factura empieza con F y la boleta con B.';

  @override
  String get cashierErrInitial =>
      'El correlativo inicial no puede ser negativo.';

  @override
  String get cashierErrAmount =>
      'El monto debe ser de al menos 0.01, con dos decimales como máximo, y no superar el saldo.';

  @override
  String get cashierErrReference =>
      'La referencia admite hasta 100 caracteres.';

  @override
  String get cashierErrStatus => 'Este comprobante ya no admite cobros.';

  @override
  String get cashierErrInput => 'Revisa los datos ingresados.';

  @override
  String get cashierErrNoSeries =>
      'La sede no tiene una serie activa para este tipo de comprobante. Actívala en Series de facturación.';

  @override
  String get cashierErrOutcomeUnknown =>
      'No sabemos si el cobro se registró. Revisa los pagos del comprobante antes de volver a cobrar.';

  @override
  String get cashierErrNoBranch =>
      'Tu cuenta no tiene sede asignada. Pide a un administrador que te asigne una.';

  @override
  String get cashierErrLegalName =>
      'Ingresa la razón social o nombre completo del receptor.';

  @override
  String get cashierErrTenantName =>
      'Ingresa la razón social o nombre comercial del taller.';

  @override
  String get cashierCheckoutTitle => 'Cobrar y entregar';

  @override
  String get cashierCheckoutNoAccess =>
      'Tu cuenta no tiene acceso a cobros ni a entregas.';

  @override
  String cashierOrderNumber(int p1) {
    return 'Orden $p1';
  }

  @override
  String cashierStepTitle(int p1, String p2) {
    return '$p1. $p2';
  }

  @override
  String get cashierStepVoucher => 'Comprobante';

  @override
  String get cashierStepPayments => 'Cobros';

  @override
  String get cashierStepExitPass => 'Pase de salida';

  @override
  String get cashierStepDelivery => 'Entrega';

  @override
  String get cashierVoucherPrepare => 'Preparar comprobante';

  @override
  String get cashierVoucherEmpty => 'Esta orden aún no tiene comprobante.';

  @override
  String get cashierVoucherNeedsCompleted =>
      'La orden debe estar completada para emitir el comprobante.';

  @override
  String get cashierIssueTitle => 'Emitir comprobante';

  @override
  String get cashierIssueType => 'Tipo de comprobante';

  @override
  String get cashierIssueDocument => 'Documento del cliente';

  @override
  String get cashierIssueDocumentNumber => 'Número de documento';

  @override
  String get cashierIssueNameCompany => 'Razón social';

  @override
  String get cashierIssueNamePerson => 'Nombre completo';

  @override
  String get cashierIssueAddress => 'Dirección fiscal';

  @override
  String get cashierIssueLines => 'Detalle';

  @override
  String get cashierIssueLineName => 'Nombre de la línea';

  @override
  String get cashierIssueLineNeedsName => 'Escribe qué se cobra en esta línea.';

  @override
  String cashierIssueLineDetail(String p1, String p2) {
    return '$p1 × $p2';
  }

  @override
  String get cashierIssueDocumentError => 'Revisa el número de documento.';

  @override
  String get cashierIssueNameError => 'Falta el nombre del cliente.';

  @override
  String get cashierIssueIrreversible =>
      'Al emitir, el comprobante se envía a SUNAT y no se puede deshacer.';

  @override
  String cashierIssueConfirm(String p1, String p2) {
    return 'Emitir $p1 por $p2';
  }

  @override
  String get cashierIssueDone => 'Comprobante emitido.';

  @override
  String get cashierIssueAlready =>
      'La orden ya tenía un comprobante vigente; no se emitió otro.';

  @override
  String get cashierIssueDetailsPending =>
      'El comprobante se emitió. Falta leer su detalle: actualiza en un momento.';

  @override
  String get cashierPaymentsEmpty =>
      'Todavía no hay cobros de este comprobante.';

  @override
  String get cashierPaymentsNeedsVoucher =>
      'Emite el comprobante para poder cobrar.';

  @override
  String get cashierPaymentRegister => 'Registrar cobro';

  @override
  String get cashierPaymentTitle => 'Registrar cobro';

  @override
  String get cashierPaymentAmount => 'Monto a cobrar';

  @override
  String get cashierPaymentAmountError =>
      'Ingresa un monto válido, hasta el saldo.';

  @override
  String get cashierPaymentMethod => 'Medio de pago';

  @override
  String get cashierPaymentReference => 'Referencia de la operación';

  @override
  String get cashierPaymentReferenceHint => 'Ej. nro. de operación o voucher';

  @override
  String get cashierPaymentReferenceRequired =>
      'Obligatoria para pagos que no son en efectivo.';

  @override
  String get cashierPaymentIrreversible =>
      'El cobro queda registrado y no se puede deshacer.';

  @override
  String cashierPaymentConfirm(String p1) {
    return 'Cobrar $p1';
  }

  @override
  String get cashierPaymentDone => 'Cobro registrado.';

  @override
  String cashierPaymentTime(String p1, String p2) {
    return '$p1 · $p2';
  }

  @override
  String get cashierMarkPaid => 'Marcar orden como pagada';

  @override
  String get cashierMarkPaidDone => 'La orden quedó pagada.';

  @override
  String get cashierExitPassDownload => 'Descargar pase de salida';

  @override
  String get cashierExitPassNeedsPaid =>
      'Disponible cuando la orden esté pagada.';

  @override
  String get cashierExitPassChooser => 'Compartir pase de salida';

  @override
  String get cashierExitPassNoApp => 'No hay una app para abrir el PDF.';

  @override
  String get cashierDeliverAction => 'Entregar vehículo';

  @override
  String get cashierDeliverTitle => 'Entregar vehículo';

  @override
  String get cashierDeliverBody =>
      'Confirma que el cliente se lleva el vehículo. La bahía se libera y no se puede deshacer.';

  @override
  String get cashierDeliverConfirm => 'Entregar';

  @override
  String get cashierDeliverNeedsPaid =>
      'Disponible cuando la orden esté pagada.';

  @override
  String get cashierDeliverDone => 'Vehículo entregado.';

  @override
  String get cashierDelivered => 'Entregado';

  @override
  String get cashierDailyTitle => 'Caja del día';

  @override
  String cashierDailyContext(String p1) {
    return 'Caja de la sede · $p1';
  }

  @override
  String get cashierDailyCaption => 'cobrado';

  @override
  String cashierDailyPayments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'cobros',
      one: 'cobro',
    );
    return '$_temp0';
  }

  @override
  String get cashierDailyByMethod => 'Por medio de pago';

  @override
  String get cashierDailyPaymentsHeader => 'Cobros';

  @override
  String get cashierDailyEmpty => 'No hay cobros registrados este día.';

  @override
  String get cashierDailyPrevious => 'Día anterior';

  @override
  String get cashierDailyNext => 'Día siguiente';

  @override
  String get cashierDailyToday => 'Hoy';

  @override
  String get cashierDailyNoAccess => 'Tu cuenta no puede ver la caja del día.';

  @override
  String get cashierSeriesTitle => 'Series de facturación';

  @override
  String get cashierSeriesHint =>
      'Series de la sede para emitir facturas y boletas electrónicas.';

  @override
  String get cashierSeriesEmpty =>
      'La sede aún no tiene series. Agrega una para poder emitir comprobantes.';

  @override
  String get cashierSeriesAdd => 'Agregar serie';

  @override
  String cashierSeriesCorrelative(int p1) {
    return 'Último número: $p1';
  }

  @override
  String get cashierSeriesActive => 'Activa';

  @override
  String get cashierSeriesInactive => 'Inactiva';

  @override
  String get cashierSeriesNewTitle => 'Nueva serie';

  @override
  String get cashierSeriesType => 'Tipo de comprobante';

  @override
  String get cashierSeriesSerie => 'Serie (4 caracteres)';

  @override
  String get cashierSeriesSerieError =>
      'Factura: F y 3 caracteres. Boleta: B y 3 caracteres.';

  @override
  String get cashierSeriesInitial => 'Correlativo inicial (opcional)';

  @override
  String get cashierSeriesInitialError => 'Ingresa un número entero.';

  @override
  String get cashierSeriesSave => 'Guardar serie';

  @override
  String get cashierSeriesSaved => 'Serie guardada.';

  @override
  String cashierSeriesDetailTitle(String p1) {
    return 'Serie $p1';
  }

  @override
  String get cashierSeriesDeactivate => 'Desactivar serie';

  @override
  String get cashierSeriesActivate => 'Activar serie';

  @override
  String get cashierSeriesDeactivateBody =>
      'Mientras esté inactiva, la sede no podrá emitir con esta serie.';

  @override
  String get cashierSeriesActivateBody =>
      'La sede volverá a emitir con esta serie.';

  @override
  String get cashierSeriesUpdated => 'Serie actualizada.';

  @override
  String get cashierSeriesNoAccess =>
      'Tu cuenta no puede configurar series de facturación.';

  @override
  String get cashierSunatStatusAcceptedNotice =>
      'Comprobante aceptado por SUNAT.';

  @override
  String get cashierSunatStatusRejectedNotice =>
      'Comprobante rechazado por SUNAT.';

  @override
  String get cashierSunatStatusPendingPseNotice =>
      'Comprobante emitido y válido para cobro. El PSE del servidor opera en modo simulado y mantiene el estado Emitido sin constancia CDR.';

  @override
  String get reportsTitle => 'Reportes';

  @override
  String get reportsContext => 'Reporte del taller';

  @override
  String get reportsScopeNote =>
      'El reporte suma todas las sedes del taller, no solo la tuya.';

  @override
  String get reportsLegendCaption => 'cobrado en el periodo';

  @override
  String get reportsPeriodMonth => 'Este mes';

  @override
  String get reportsPeriodPreviousMonth => 'Mes pasado';

  @override
  String get reportsPeriodYear => 'Este año';

  @override
  String reportsPeriodRange(String p1, String p2) {
    return '$p1 al $p2';
  }

  @override
  String reportsMovementsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'movimientos',
      one: 'movimiento',
    );
    return '$_temp0';
  }

  @override
  String get reportsMovementsHeader => 'Movimientos';

  @override
  String get reportsMovementsEmpty => 'No hay movimientos en este periodo.';

  @override
  String reportsMovementDetail(String p1, String p2) {
    return '$p1 · $p2';
  }

  @override
  String get reportsDownloadsHeader => 'Descargas';

  @override
  String get reportsDownloadCashflow => 'Descargar PDF de flujo de caja';

  @override
  String get reportsDownloadFleet => 'PDF de salud de flota';

  @override
  String get reportsPdfChooser => 'Compartir reporte';

  @override
  String get reportsPdfNoApp => 'No hay una app para abrir el PDF.';

  @override
  String get reportsFleetLocked =>
      'La salud de flota con IA no está incluida en el plan de tu taller.';

  @override
  String get reportsFleetTitle => 'Salud de flota';

  @override
  String get reportsFleetHint =>
      'Elige al cliente cuyo informe quieres descargar.';

  @override
  String get reportsFleetSearch => 'Buscar cliente por nombre o documento';

  @override
  String get reportsFleetSearchAction => 'Buscar';

  @override
  String get reportsFleetEmpty => 'No encontramos clientes con esa búsqueda.';

  @override
  String get reportsNoAccess => 'Tu cuenta no tiene acceso a reportes.';

  @override
  String get reportsPeriodCustom => 'Rango';

  @override
  String get reportsOpenPdf => 'Abrir PDF';

  @override
  String get reportsSharePdf => 'Compartir PDF';

  @override
  String get reportsFleetScopeNote =>
      'Incluye todos los vehículos registrados del cliente seleccionado.';

  @override
  String get reportsH31IncomeOnlyNote =>
      'Muestra únicamente los cobros confirmados del periodo; egresos y cuentas por cobrar no se contabilizan en este resumen.';

  @override
  String get cashierErrReason =>
      'Ingresa un motivo válido de hasta 250 caracteres.';

  @override
  String get cashierErrCustomer =>
      'El comprobante no tiene un cliente asociado.';

  @override
  String get cashierDailyVouchers => 'Comprobantes SUNAT';

  @override
  String get cashierDailyVouchersSub =>
      'Boletas, facturas, notas de crédito y anulaciones';

  @override
  String get cashierVouchersTitle => 'Comprobantes SUNAT';

  @override
  String get cashierVouchersNoAccess =>
      'Tu cuenta no puede consultar comprobantes emitidos.';

  @override
  String get cashierVouchersEmpty =>
      'Aún no hay comprobantes emitidos en esta sede.';

  @override
  String get cashierVouchersEmptyFiltered =>
      'No hay comprobantes con este filtro.';

  @override
  String get cashierVouchersFilterAll => 'Todos';

  @override
  String get cashierVouchersFilterAccepted => 'Aceptados';

  @override
  String get cashierVouchersFilterBalance => 'Con saldo';

  @override
  String get cashierVouchersFilterVoided => 'Anulados';

  @override
  String get cashierVouchersFilterCreditNotes => 'Notas de crédito';

  @override
  String cashierVouchersBalanceShort(String p1) {
    return 'Saldo $p1';
  }

  @override
  String get cashierVouchersSunatLabel => 'Estado SUNAT';

  @override
  String cashierVouchersCdrCode(String p1, String p2) {
    return 'CDR $p1 · $p2';
  }

  @override
  String get cashierVouchersCustomerLabel => 'Cliente';

  @override
  String cashierVouchersIssuedAt(String p1) {
    return 'Emitido el $p1';
  }

  @override
  String get cashierVouchersLinesLabel => 'Detalle del comprobante';

  @override
  String get cashierVouchersClose => 'Cerrar';

  @override
  String get cashierVouchersNoActions =>
      'Este comprobante no admite anulaciones ni notas de crédito.';

  @override
  String get cashierVoidAction => 'Anular comprobante';

  @override
  String get cashierVoidShort => 'Anular';

  @override
  String cashierVoidTitle(String p1) {
    return 'Anular $p1';
  }

  @override
  String get cashierVoidBody =>
      'Se enviará la comunicación de baja a SUNAT (disponible dentro de los 7 días calendario). Esta acción no se puede deshacer.';

  @override
  String get cashierVoidReasonLabel => 'Motivo de anulación';

  @override
  String get cashierVoidReasonPlaceholder =>
      'Ej. Error en datos fiscales del cliente';

  @override
  String get cashierVoidReasonError =>
      'Escribe el motivo (máximo 250 caracteres).';

  @override
  String get cashierVoidConfirm => 'Confirmar anulación';

  @override
  String get cashierVoidDone => 'Comprobante anulado.';

  @override
  String get cashierNcAction => 'Emitir nota de crédito';

  @override
  String get cashierNcShort => 'Nota de crédito';

  @override
  String get cashierNcTitle => 'Emitir nota de crédito';

  @override
  String cashierNcReference(String p1) {
    return 'Comprobante de referencia: $p1';
  }

  @override
  String get cashierNcReasonLabel => 'Motivo de la nota de crédito';

  @override
  String get cashierNcReasonPlaceholder => 'Ej. Descuento o devolución parcial';

  @override
  String get cashierNcReasonError =>
      'Escribe el motivo (máximo 250 caracteres).';

  @override
  String get cashierNcAmountLabel => 'Monto de la nota de crédito';

  @override
  String get cashierNcAmountError =>
      'Ingresa un monto válido, hasta el total del comprobante.';

  @override
  String get cashierNcIrreversible =>
      'La nota de crédito se enviará a SUNAT y no se puede deshacer.';

  @override
  String cashierNcConfirm(String p1) {
    return 'Emitir nota por $p1';
  }

  @override
  String get cashierNcDone => 'Nota de crédito emitida.';

  @override
  String get cashierNcSerieLabel => 'Serie de nota de crédito';

  @override
  String get cashierNcSerieError =>
      'Serie de 4 caracteres acorde al comprobante (F para factura, B para boleta).';

  @override
  String get cashierDocOpenPdf => 'Abrir PDF';

  @override
  String get cashierDocSharePdf => 'Compartir PDF';

  @override
  String get cashierDocShareXml => 'Compartir XML UBL 2.1';

  @override
  String get cashierDocShareCdr => 'Compartir CDR SUNAT';

  @override
  String get cashierSunatRefreshStatus => 'Actualizar estado SUNAT';

  @override
  String get cashierSunatRejectedReissueHint =>
      'El comprobante fue rechazado por SUNAT. Puedes corregir los datos y volver a emitir.';

  @override
  String get cashierExitPassOpen => 'Abrir pase de salida';

  @override
  String get cashierExitPassShare => 'Compartir pase de salida';

  @override
  String get cashierCheckoutH26Note =>
      'El total del comprobante incluye IGV sobre cada línea y define el saldo fiscal a cobrar.';

  @override
  String get cashierCheckoutProfitability => 'Ver margen FIFO y rentabilidad';

  @override
  String get cashierFiscalTenantSection => 'Información fiscal del taller';

  @override
  String get cashierFiscalTenantName => 'Nombre comercial';

  @override
  String get cashierFiscalTenantLegalName => 'Razón social';

  @override
  String get cashierFiscalTenantRuc => 'RUC del emisor (11 dígitos)';

  @override
  String get cashierFiscalTenantEdit => 'Editar datos fiscales';

  @override
  String get cashierFiscalTenantSave => 'Guardar datos fiscales';

  @override
  String get cashierFiscalTenantSaved =>
      'Datos fiscales del taller actualizados.';

  @override
  String get cashierFiscalPseManagedTitle => 'PSE administrado por Atelier';

  @override
  String get cashierFiscalPseManagedBody =>
      'La firma digital UBL 2.1 y la conexión con el Proveedor de Servicios Electrónicos (PSE) ante SUNAT están gestionadas directamente por la plataforma.';

  @override
  String get cashierSeriesBranchSection => 'Series electrónicas de la sede';

  @override
  String get cashierSeriesNcHint =>
      'Incluye series para Factura (F), Boleta (B) y Notas de Crédito.';

  @override
  String get receptionNewAppointment => 'Nueva cita';

  @override
  String get receptionCreateAppointmentTitle => 'Agendar cita';

  @override
  String get receptionAppointmentCustomerLabel => 'Cliente';

  @override
  String get receptionAppointmentSelectCustomer => 'Elige un cliente';

  @override
  String get receptionAppointmentVehicleLabel => 'Vehículo';

  @override
  String get receptionAppointmentSelectVehicle => 'Elige un vehículo';

  @override
  String get receptionAppointmentNoVehicles =>
      'Este cliente no tiene vehículos registrados.';

  @override
  String get receptionAppointmentDateLabel => 'Fecha (AAAA-MM-DD)';

  @override
  String get receptionAppointmentTimeLabel => 'Hora (HH:MM)';

  @override
  String get receptionAppointmentTodayChip => 'Hoy';

  @override
  String get receptionAppointmentTomorrowChip => 'Mañana';

  @override
  String get receptionAppointmentDurationLabel => 'Duración estimada (min)';

  @override
  String get receptionAppointmentReasonLabel => 'Motivo de la cita (opcional)';

  @override
  String get receptionAppointmentReasonHint =>
      'Ej. Mantenimiento 40,000 km o revisión de frenos';

  @override
  String get receptionAppointmentScheduleBtn => 'Agendar cita';

  @override
  String get receptionAppointmentScheduledNotice =>
      'Cita agendada correctamente.';

  @override
  String get receptionAppointmentsSectionTitle => 'Agenda de citas';

  @override
  String get receptionAppointmentsRangeToday => 'Hoy';

  @override
  String get receptionAppointmentsRangeWeek => '7 días';

  @override
  String get receptionAppointmentsRangeMonth => '30 días';

  @override
  String get receptionAppointmentsEmptyWeek =>
      'No hay citas en los próximos 7 días.';

  @override
  String get receptionAppointmentsEmptyMonth =>
      'No hay citas en los próximos 30 días.';

  @override
  String get receptionAppointmentActionsTitle => 'Gestionar cita';

  @override
  String get receptionAppointmentConfirmBtn => 'Confirmar cita';

  @override
  String get receptionAppointmentConfirmedNotice => 'Cita confirmada.';

  @override
  String get receptionAppointmentRescheduleBtn => 'Reprogramar';

  @override
  String get receptionAppointmentRescheduleConfirm => 'Guardar nueva fecha';

  @override
  String get receptionAppointmentRescheduledNotice => 'Cita reprogramada.';

  @override
  String get receptionAppointmentCancelBtn => 'Cancelar cita';

  @override
  String get receptionAppointmentCancelReasonLabel => 'Motivo de cancelación';

  @override
  String get receptionAppointmentCancelReasonHint =>
      'Ej. El cliente reprogramará más adelante';

  @override
  String get receptionAppointmentCancelConfirm => 'Sí, cancelar cita';

  @override
  String get receptionAppointmentCanceledNotice => 'Cita cancelada.';

  @override
  String get receptionAppointmentInvalidDatetime =>
      'Ingresa una fecha (AAAA-MM-DD) y hora (HH:MM) válidas.';

  @override
  String get receptionAppointmentInvalidDuration =>
      'La duración mínima es de 15 minutos.';

  @override
  String get receptionAppointmentInvalidCancelReason =>
      'Ingresa el motivo de cancelación (máximo 500 caracteres).';

  @override
  String get receptionEditContactBtn => 'Editar contacto';

  @override
  String get receptionEditContactTitle => 'Editar contacto del cliente';

  @override
  String get receptionEditContactEmailLabel => 'Correo electrónico';

  @override
  String get receptionEditContactPhoneLabel => 'Teléfono';

  @override
  String get receptionEditContactSave => 'Guardar contacto';

  @override
  String get receptionEditContactNotice => 'Contacto actualizado.';

  @override
  String get affiliationVehiclesHeader => 'Vehículos que se vincularán';

  @override
  String get affiliationSearchingLabel => 'Buscando cuenta en Atelier…';

  @override
  String baysFilterMaintenance(int p1) {
    return 'Mantenimiento ($p1)';
  }

  @override
  String get baysOccupiedSheetTitle => 'Bahía ocupada';

  @override
  String get baysAvailableSheetTitle => 'Bahía libre';

  @override
  String get baysMaintenanceSheetTitle => 'Bahía en mantenimiento';

  @override
  String get baysOpenOrderBtn => 'Abrir orden de trabajo';

  @override
  String get baysReleaseBtn => 'Liberar bahía';

  @override
  String baysReleasedNotice(String p1) {
    return 'Bahía $p1 liberada.';
  }

  @override
  String get baysReassignSection => 'Mover orden a otra bahía libre';

  @override
  String get baysSetMaintenanceBtn => 'Poner en mantenimiento';

  @override
  String get baysMaintenanceReasonLabel => 'Motivo del mantenimiento';

  @override
  String get baysMaintenanceReasonHint =>
      'Ej. Calibración de elevador hidráulico';

  @override
  String get baysMaintenanceConfirmBtn => 'Confirmar mantenimiento';

  @override
  String baysMaintenanceNotice(String p1) {
    return 'Bahía $p1 puesta en mantenimiento.';
  }

  @override
  String get baysRestoreBtn => 'Restaurar bahía';

  @override
  String baysRestoredNotice(String p1) {
    return 'Bahía $p1 restaurada y disponible.';
  }

  @override
  String get baysMaintenanceFieldError =>
      'Escribe el motivo del mantenimiento (máximo 1000 caracteres).';

  @override
  String get ordersFilterToCollect => 'Por cobrar';

  @override
  String get ordersObdDiagnosticBtn => 'Diagnóstico OBD-II';

  @override
  String get diagHubTitle => 'Diagnóstico OBD-II';

  @override
  String get diagHubPlanLocked =>
      'Tu plan actual no incluye telemetría ni diagnóstico OBD-II. Disponible desde el plan Pro.';

  @override
  String get diagHubNoPermission =>
      'Tu perfil no tiene permiso para operar el módulo de diagnóstico OBD-II.';

  @override
  String get diagTabScanner => 'Escáner';

  @override
  String get diagTabDevices => 'Dispositivos';

  @override
  String get diagTabAlerts => 'Alertas';

  @override
  String get diagVehicleSection => 'Vehículo en revisión';

  @override
  String get diagVehiclePick => 'Elegir vehículo';

  @override
  String get diagVehicleChange => 'Cambiar';

  @override
  String get diagVehicleNone =>
      'Elige un vehículo de tus tareas u órdenes para empezar.';

  @override
  String get diagVehicleSearchLabel => 'Buscar placa o modelo';

  @override
  String get diagVehicleSearchHint => 'Ej. BKL-482 o Hilux';

  @override
  String get diagVehicleSheetTitle => 'Elegir vehículo';

  @override
  String get diagVehicleEmptySearch =>
      'No hay vehículos que coincidan con la búsqueda.';

  @override
  String get diagInstallationActive => 'Escáner vinculado';

  @override
  String get diagInstallationActiveSub =>
      'Listo para enviar lotes de telemetría.';

  @override
  String get diagInstallationNone => 'Sin escáner vinculado';

  @override
  String get diagInstallationNoneSub =>
      'Vincula un equipo antes de capturar lecturas, o las muestras quedarán pendientes al sincronizar.';

  @override
  String get diagInstallationOffline =>
      'Sin conexión: puedes escanear y guardar lecturas en el teléfono; se enviarán al volver la red.';

  @override
  String get diagInstallationOdometerLabel => 'Odómetro actual (km, opcional)';

  @override
  String get diagInstallationOdometerHint => 'Ej. 48500';

  @override
  String get diagInstallationOdometerInvalid =>
      'Ingresa un kilometraje válido (0 o mayor).';

  @override
  String get diagInstallationInstallCta => 'Vincular escáner';

  @override
  String get diagInstallationUninstallCta => 'Retirar escáner';

  @override
  String get diagInstallationChooseDevice =>
      'Elige un escáner activo del taller';

  @override
  String get diagInstallationNoActiveDevices =>
      'No hay escáneres activos disponibles para vincular.';

  @override
  String get diagBtSection => 'Adaptador Bluetooth ELM327';

  @override
  String get diagBtPermissionNeeded =>
      'Autoriza el acceso a Bluetooth para ver los adaptadores emparejados en este teléfono.';

  @override
  String get diagBtPermissionCta => 'Permitir Bluetooth';

  @override
  String get diagBtDisabled =>
      'El Bluetooth está apagado. Enciéndelo para conectar el adaptador ELM327.';

  @override
  String get diagBtRefresh => 'Buscar emparejados';

  @override
  String get diagBtEmpty =>
      'No hay adaptadores emparejados en los ajustes de Bluetooth del teléfono.';

  @override
  String get diagBtMatchedWorkshop => 'Registrado en taller';

  @override
  String get diagBtConnect => 'Conectar adaptador';

  @override
  String get diagBtDisconnect => 'Desconectar';

  @override
  String diagBtConnectedProtocol(String p1) {
    return 'Protocolo: $p1';
  }

  @override
  String diagBtConnectedVin(String p1) {
    return 'VIN: $p1';
  }

  @override
  String get diagBtStatusDisconnected => 'Desconectado';

  @override
  String get diagBtStatusConnecting => 'Conectando…';

  @override
  String get diagBtStatusConnected => 'Conectado';

  @override
  String get diagBtStatusStreaming => 'En vivo';

  @override
  String get diagBtStatusReconnecting => 'Reconectando…';

  @override
  String get diagBtStatusLost => 'Señal perdida';

  @override
  String get diagBtStatusRemote => 'Lectura remota';

  @override
  String get diagErrAdapterUnreachable =>
      'No se pudo abrir el enlace con el adaptador. Verifica que esté alimentado y dentro del alcance.';

  @override
  String get diagErrEcuNoResponse =>
      'El adaptador respondió, pero la computadora del vehículo no. Revisa el contacto en ON y la tensión del conector.';

  @override
  String get diagErrConnectionLost =>
      'Se perdió la señal Bluetooth. Las lecturas guardadas no se pierden.';

  @override
  String get diagErrNotConnected =>
      'Conecta primero un adaptador OBD-II en el escáner.';

  @override
  String get diagActionsSection => 'Herramientas del vehículo';

  @override
  String get diagActionLiveTitle => 'Telemetría en vivo';

  @override
  String get diagActionLiveSubBt =>
      'Lectura de PIDs en tiempo real y captura en fosa';

  @override
  String get diagActionLiveSubRemote =>
      'Última lectura registrada y serie histórica';

  @override
  String get diagActionFaultsTitle => 'Códigos de falla (DTC)';

  @override
  String get diagActionFaultsSub =>
      'Escanear modo 03, revisar severidad y borrar tras reparar';

  @override
  String get diagActionAiTitle => 'Informe de salud con IA';

  @override
  String get diagActionAiSub =>
      'Dictamen predictivo por subsistema y descarga PDF';

  @override
  String get diagActionAiLockedSub => 'Disponible desde el plan Max';

  @override
  String get diagActionFindingTitle => 'Reportar hallazgo en orden';

  @override
  String get diagActionFindingSub => 'Propuesta con foto en la orden activa';

  @override
  String get diagAlertsScopeTenant => 'Todo el taller';

  @override
  String get diagAlertsScopeVehicle => 'Este vehículo';

  @override
  String get diagAlertsEmpty => 'Sin alertas predictivas activas.';

  @override
  String diagAlertsConfidence(int p1) {
    return 'Confianza: $p1%';
  }

  @override
  String get diagAlertsAck => 'Confirmar lectura';

  @override
  String get diagAlertsAckDone => 'Lectura confirmada.';

  @override
  String get diagAlertsConvert => 'Agendar cita';

  @override
  String get diagAlertsConvertTitle => 'Agendar cita por alerta';

  @override
  String get diagAlertsConvertBody =>
      'Coordina la fecha y hora con el cliente antes de confirmar la cita.';

  @override
  String get diagAlertsConvertConfirm => 'Agendar cita';

  @override
  String diagAlertsConvertOk(String p1) {
    return 'Cita preventiva agendada ($p1).';
  }

  @override
  String get diagAlertsConvertDateLabel => 'Fecha (AAAA-MM-DD)';

  @override
  String get diagAlertsConvertTimeLabel => 'Hora (HH:MM)';

  @override
  String get diagAlertsConvertDurationLabel => 'Duración estimada (min)';

  @override
  String get diagAlertsConvertReasonLabel => 'Motivo de la cita';

  @override
  String get diagAlertsConvertToday => 'Hoy';

  @override
  String get diagAlertsConvertTomorrow => 'Mañana';

  @override
  String get diagAlertsConvertIn2Days => '+2 días';

  @override
  String get diagAlertsConvertInvalidDatetime =>
      'Ingresa una fecha (AAAA-MM-DD) y hora (HH:MM) válidas y futuras.';

  @override
  String get diagAlertsConvertInvalidDuration =>
      'La duración mínima es de 15 minutos.';

  @override
  String get diagAlertStatusDispatched => 'Pendiente';

  @override
  String get diagAlertStatusAcknowledged => 'Revisada';

  @override
  String get diagAlertStatusResolved => 'Resuelta';

  @override
  String get diagAlertStatusDismissed => 'Desestimada';

  @override
  String get diagAlertTypeOverheating => 'Riesgo de sobrecalentamiento';

  @override
  String get diagAlertTypeBattery => 'Riesgo en batería';

  @override
  String get diagAlertTypeCatalytic => 'Degradación del catalizador';

  @override
  String get diagAlertTypeMisfire => 'Falla de encendido en cilindro';

  @override
  String get diagAlertTypeBrake => 'Desgaste de frenos';

  @override
  String get diagAlertTypeOil => 'Agotamiento de aceite';

  @override
  String get diagAlertTypeEmissions => 'Falla de emisiones';

  @override
  String get diagAlertTypeGeneric => 'Alerta predictiva';

  @override
  String get diagLiveTitle => 'Telemetría';

  @override
  String get diagLiveNoPermission =>
      'Tu perfil no tiene permiso para leer ni capturar telemetría.';

  @override
  String diagLiveSyncPending(int p1) {
    return '$p1 lecturas pendientes de sincronizar';
  }

  @override
  String get diagLiveSyncOk => 'Lecturas sincronizadas';

  @override
  String get diagLiveRemoteBanner =>
      'Modo lectura remota: se muestra la última telemetría enviada al servidor.';

  @override
  String get diagLiveRemoteEmpty =>
      'Aún no hay lecturas remotas registradas para este vehículo.';

  @override
  String get diagLiveMissingPid0105 =>
      'Sin PID 0105 (temperatura del refrigerante): la lectura se muestra en vivo, pero no se guarda ni se envía al servidor.';

  @override
  String diagLiveLastSample(String p1) {
    return 'Última muestra: $p1';
  }

  @override
  String get diagLiveWaitingSample =>
      'Esperando primera lectura del adaptador…';

  @override
  String get diagLiveStart => 'Iniciar muestreo';

  @override
  String get diagLiveStop => 'Detener';

  @override
  String get diagLiveFreeze => 'Congelar muestra';

  @override
  String get diagLiveFaults => 'Códigos DTC';

  @override
  String get diagLiveRefresh => 'Actualizar';

  @override
  String get diagLiveFrozenTitle => 'Muestra congelada';

  @override
  String get diagLiveFrozenSaved =>
      'La muestra ya quedó guardada localmente y viajará en el próximo lote.';

  @override
  String get diagLiveHistoryHeader => 'Historial reciente';

  @override
  String diagLiveHistorySamples(int p1) {
    return '$p1 muestras';
  }

  @override
  String get diagPidRpm => 'RPM motor';

  @override
  String get diagPidCoolant => 'Temp. motor';

  @override
  String get diagPidVoltage => 'Voltaje batería';

  @override
  String get diagPidLoad => 'Carga motor';

  @override
  String get diagPidSpeed => 'Velocidad';

  @override
  String get diagPidThrottle => 'Acelerador';

  @override
  String get diagPidFuel => 'Combustible';

  @override
  String get diagPidUnitRpm => 'rpm';

  @override
  String get diagPidUnitCelsius => '°C';

  @override
  String get diagPidUnitVolts => 'V';

  @override
  String get diagPidUnitPercent => '%';

  @override
  String get diagPidUnitKmh => 'km/h';

  @override
  String get diagPidStatusNormal => 'En rango';

  @override
  String get diagPidStatusOverheat => 'Sobrecalentamiento';

  @override
  String get diagPidStatusTempHigh => 'Temperatura elevada';

  @override
  String get diagPidStatusLowVolt => 'Voltaje bajo';

  @override
  String get diagPidStatusHighVolt => 'Sobretensión';

  @override
  String get diagPidStatusHighRpm => 'RPM elevadas';

  @override
  String get diagPidStatusHighLoad => 'Carga alta';

  @override
  String get diagPidStatusLowFuel => 'Nivel bajo';

  @override
  String get diagFaultsTitle => 'Códigos de falla (DTC)';

  @override
  String get diagFaultsNoPermission =>
      'Tu perfil no tiene permiso para consultar fallas electrónicas.';

  @override
  String diagFaultsCount(int p1) {
    return '$p1 fallas activas';
  }

  @override
  String diagFaultsPendingSync(int p1) {
    return '$p1 por sincronizar';
  }

  @override
  String get diagFaultsScan => 'Escanear DTC';

  @override
  String get diagFaultsClear => 'Borrar códigos';

  @override
  String get diagFaultsEmpty => 'Sin códigos de falla activos.';

  @override
  String get diagFaultsScanClean =>
      'Escaneo limpio: la ECU no reportó códigos de falla.';

  @override
  String get diagFaultsPendingBadge => 'Pendiente';

  @override
  String get diagFaultsSeverityCritical => 'Crítica';

  @override
  String get diagFaultsSeverityMedium => 'Media';

  @override
  String get diagFaultsSeverityLow => 'Baja';

  @override
  String get diagFaultsFreezeHeader => 'Cuadro congelado (Modo 02)';

  @override
  String get diagFaultsClearTitle => 'Borrar códigos de falla';

  @override
  String get diagFaultsClearBody =>
      'Se enviará el comando Modo 04 a la computadora y luego se re-leerán los códigos activos. Si la avería física persiste, el código volverá a aparecer.';

  @override
  String get diagFaultsClearConfirm => 'Confirmar borrado';

  @override
  String diagFaultsClearResultClean(int p1) {
    return 'Se borraron $p1 códigos y no quedaron fallas activas.';
  }

  @override
  String diagFaultsClearResultPersistent(int p1, int p2) {
    return 'Se borraron $p1 códigos, pero $p2 persisten. Revisa el circuito antes de cerrar la tarea.';
  }

  @override
  String get diagFaultsNeedBt =>
      'Conecta el adaptador Bluetooth en Escáner para leer o borrar códigos de la ECU.';

  @override
  String get diagReportTitle => 'Informe de salud IA';

  @override
  String get diagReportPlanLocked =>
      'Los informes de salud con IA están disponibles desde el plan Max.';

  @override
  String get diagReportNoPermission =>
      'Tu perfil no tiene permiso para consultar ni generar informes de salud.';

  @override
  String get diagReportScoreLabel => 'Puntaje de salud';

  @override
  String get diagReportEmpty =>
      'Este vehículo aún no tiene un informe de salud emitido.';

  @override
  String get diagReportGenerate => 'Generar informe IA';

  @override
  String get diagReportGenerateSheetTitle => 'Generar informe de salud';

  @override
  String get diagReportDaysLabel => 'Ventana de análisis';

  @override
  String diagReportDaysOption(int p1) {
    return '$p1 días';
  }

  @override
  String get diagReportIncludeResolved =>
      'Incluir historial de DTC ya resueltos';

  @override
  String get diagReportGenerating => 'Analizando telemetría y fallas…';

  @override
  String get diagReportDownloadPdf => 'Descargar PDF';

  @override
  String get diagReportSummarySection => 'Resumen ejecutivo';

  @override
  String get diagReportSubsystemsSection => 'Subsistemas evaluados';

  @override
  String get diagReportRisksSection => 'Riesgos predictivos';

  @override
  String get diagReportActionsSection => 'Acciones recomendadas';

  @override
  String get diagReportCorrelationsSection => 'Correlación DTC y sensores';

  @override
  String diagReportRiskDetail(int p1, int p2) {
    return 'Probabilidad: $p1% · Horizonte: $p2 días';
  }

  @override
  String diagReportDaysAnalyzed(int p1, String p2) {
    return 'Analizado sobre $p1 días · $p2';
  }

  @override
  String diagReportInsufficientTelemetry(String p1) {
    return 'Telemetría insuficiente: $p1 Prueba ampliar los días o escanear el vehículo en bahía.';
  }

  @override
  String get diagReportOpenPdf => 'Abrir PDF';

  @override
  String get diagReportSharePdf => 'Compartir PDF';

  @override
  String get diagDeviceInvalidConnectionType =>
      'Elige un tipo de conexión válido (Bluetooth, BLE, Wi-Fi o USB).';

  @override
  String get diagDeviceIdentifierRequired =>
      'Ingresa el identificador o dirección MAC del escáner.';

  @override
  String get diagLiveReconnect => 'Reconectar escáner';

  @override
  String get diagLiveOtherVehicleWarning =>
      'El escáner está conectado a otro vehículo. Conéctalo a esta unidad en Escáner.';

  @override
  String get diagPidIntakePressure => 'Presión admisión';

  @override
  String get diagPidUnitKpa => 'kPa';

  @override
  String get obdConnBluetoothBle => 'Bluetooth BLE';

  @override
  String get floorHubShiftActive => 'En turno';

  @override
  String get floorHubShiftPending => 'Ingreso pendiente';

  @override
  String get floorHubShiftClosed => 'Jornada cerrada';

  @override
  String get floorHubShiftIdle => 'Sin marcar';

  @override
  String get floorHubClockInCta => 'Marcar ingreso';

  @override
  String get floorHubClockOutCta => 'Marcar salida';

  @override
  String get floorHubAttendanceDetail => 'Ver turno y descargos';

  @override
  String get floorHubActiveTaskSection => 'Tarea en curso';

  @override
  String get floorHubOpenTask => 'Abrir tarea';

  @override
  String get floorHubNoActiveTask =>
      'Sin tarea iniciada. Elige una de tu lista.';

  @override
  String get floorHubTasksQueueSection => 'Mis tareas de hoy';

  @override
  String get floorHubTasksEmpty => 'No tienes tareas asignadas por ahora.';

  @override
  String get floorHubTasksLegendActive => 'En fosa';

  @override
  String floorHubTasksCaptionFormat(int p1, int p2) {
    return '$p1 pendientes · $p2 cerradas';
  }

  @override
  String get floorHubFigurePending => 'pendientes';

  @override
  String get floorHubFigureInProgress => 'en curso';

  @override
  String get floorHubFigureObd => 'OBD activos';

  @override
  String get floorHubQuickSection => 'Accesos de piso';

  @override
  String get floorHubQuickObd => 'Diagnóstico OBD-II';

  @override
  String get floorHubQuickObdSub => 'Telemetría en vivo, DTC e informe IA';

  @override
  String get floorHubQuickFinding => 'Reportar hallazgo';

  @override
  String get floorHubQuickFindingSub => 'Propuesta con foto en la orden activa';

  @override
  String get floorHubQuickParts => 'Consultar repuestos';

  @override
  String get floorHubQuickPartsSub => 'Stock disponible por nombre o SKU';

  @override
  String get floorHubQuickBays => 'Tablero de bahías';

  @override
  String get floorHubQuickBaysSub => 'Vehículos asignados por elevador';

  @override
  String get floorHubCounterCaption => 'citas agendadas hoy';

  @override
  String get floorHubCounterSection => 'Agenda de hoy';

  @override
  String get floorHubCounterEmpty => 'Sin citas agendadas para hoy.';

  @override
  String get floorHubCounterOpenReception => 'Buscar placa o cliente';

  @override
  String get floorHubCounterNewCustomer => 'Registrar cliente';

  @override
  String get floorHubFigureArrived => 'llegaron';

  @override
  String get floorHubFigureWaiting => 'por llegar';

  @override
  String get floorHubFigureOrders => 'órdenes hoy';

  @override
  String get floorHubStockCaption => 'alertas de stock mínimo';

  @override
  String get floorHubStockDecisions => 'Requieren reposición';

  @override
  String get floorHubStockEmpty => 'Todo el catálogo está sobre el mínimo.';

  @override
  String get floorHubStockPosSection => 'Órdenes de compra emitidas';

  @override
  String get floorHubStockPosEmpty =>
      'Sin órdenes de compra pendientes de recibir.';

  @override
  String get floorHubStockOpenCatalog => 'Abrir catálogo';

  @override
  String get floorHubFigureOutOfStock => 'agotados';

  @override
  String get floorHubFigureOpenPos => 'OC emitidas';

  @override
  String get floorHubFigureCatalog => 'repuestos';

  @override
  String get floorHubCashCaption => 'órdenes listas para cobrar';

  @override
  String get floorHubCashDecisions => 'Listas para cobrar';

  @override
  String get floorHubCashEmpty => 'No hay órdenes terminadas esperando cobro.';

  @override
  String get floorHubCashOpenDaily => 'Ver caja del día';

  @override
  String get floorHubFigureCollected => 'cobrado hoy';

  @override
  String get floorHubFigurePayments => 'cobros hoy';

  @override
  String get dashboardMyShiftTitle => 'Mi jornada';

  @override
  String get dashboardMyShiftClockedIn =>
      'En turno hoy · toca para ver horario o marcar salida';

  @override
  String get dashboardMyShiftNotClockedIn =>
      'Sin ingreso marcado · toca para marcar asistencia';

  @override
  String get dashboardMyShiftQueued => 'Marcación pendiente de sincronizar';

  @override
  String get dashboardMyShiftCompleted => 'Jornada del día completada';

  @override
  String get dashboardMyTasksTitle => 'Mis tareas asignadas';

  @override
  String dashboardMyTasksSub(int p1) {
    return '$p1 activas · toca para abrir tu bandeja';
  }

  @override
  String attendanceGeofenceInside(int p1) {
    return 'Dentro de geocerca ($p1 m)';
  }

  @override
  String attendanceGeofenceOutside(int p1, int p2) {
    return 'Fuera de geocerca ($p1 m / máx. $p2 m)';
  }

  @override
  String get attendanceGeofenceMock => 'Ubicación simulada detectada';

  @override
  String get attendanceGeofencePending => 'Sin lectura GPS todavía';

  @override
  String get attendanceScheduleSection => 'Mi turno semanal';

  @override
  String attendanceScheduleTolerance(int p1) {
    return 'Tolerancia de ingreso: $p1 min';
  }

  @override
  String get attendanceScheduleWorkday => 'Laborable';

  @override
  String get attendanceScheduleRestday => 'Descanso';

  @override
  String get attendanceHistorySection => 'Historial de los últimos 30 días';

  @override
  String attendanceWorkedSummary(int p1, int p2) {
    return '${p1}h ${p2}m trabajados';
  }

  @override
  String attendanceOvertimeSummary(int p1) {
    return ' · +${p1}m extra';
  }

  @override
  String get attendanceJustificationSheetTitle => 'Enviar descargo';

  @override
  String get attendanceJustificationFieldLabel => 'Motivo del descargo';

  @override
  String get attendanceJustificationFieldHint =>
      'Explica brevemente la tardanza o ausencia (máx. 500 caracteres)';

  @override
  String get attendanceClockOutSheetTitle => '¿Cerrar jornada de hoy?';

  @override
  String get attendanceClockOutSheetBody =>
      'Se registrará tu hora de salida y se calcularán tus horas efectivas del turno.';

  @override
  String get attendanceClockOutConfirm => 'Sí, marcar salida';

  @override
  String get attendanceNoBranchAssigned =>
      'Aún no tienes sede ni turno asignados. Pide al administrador que configure tu perfil laboral.';

  @override
  String inventoryPartSubtitle(String p1, String p2) {
    return 'SKU $p1 · Stock: $p2';
  }

  @override
  String get inventoryDetailStockSection => 'Existencias';

  @override
  String get inventoryDetailStock => 'Stock';

  @override
  String get inventoryDetailMinimum => 'Stock mínimo';

  @override
  String get inventoryDetailPrice => 'Precio de venta sin IGV';

  @override
  String get inventoryDetailCategory => 'Categoría';

  @override
  String get inventoryAlertsTitle => 'Alertas de stock';

  @override
  String get inventoryAlertsHeader => 'Por reponer';

  @override
  String get inventoryAlertsEmpty => 'Ningún repuesto está en su mínimo.';

  @override
  String get inventoryAlertsNoPermission =>
      'Tu perfil no tiene permiso para ver las alertas de stock.';

  @override
  String get inventoryAlertsOffline =>
      'Sin conexión: alertas calculadas con el catálogo guardado.';

  @override
  String inventoryAlertSubtitle(String p1, String p2, String p3) {
    return 'SKU $p1 · Stock $p2 de $p3';
  }

  @override
  String inventoryAlertMissing(String p1) {
    return 'Faltan $p1';
  }

  @override
  String get inventoryPoTitle => 'Compras';

  @override
  String get inventoryPoDetailTitle => 'Orden de compra';

  @override
  String get inventoryPoNoPermission =>
      'Tu perfil no tiene permiso para ver las órdenes de compra.';

  @override
  String get inventoryPoEmpty => 'No hay órdenes de compra en este estado.';

  @override
  String get inventoryPoFilterIssued => 'Por recibir';

  @override
  String get inventoryPoFilterReceived => 'Recibidas';

  @override
  String get inventoryPoFilterAll => 'Todas';

  @override
  String inventoryPoNumber(String p1) {
    return 'Orden $p1';
  }

  @override
  String get inventoryPoNoNumber => 'Orden sin número';

  @override
  String inventoryPoReceivedOn(String p1) {
    return 'Recibida el $p1';
  }

  @override
  String get inventoryPoStatusDraft => 'Borrador';

  @override
  String get inventoryPoStatusIssued => 'Por recibir';

  @override
  String get inventoryPoStatusReceived => 'Recibida';

  @override
  String get inventoryPoStatusCanceled => 'Anulada';

  @override
  String get inventoryPoStatusUnknown => 'Sin estado';

  @override
  String get inventoryPoLinesHeader => 'Repuestos pedidos';

  @override
  String get inventoryPoLineUnknown => 'Repuesto';

  @override
  String inventoryPoLineSubtitle(String p1, String p2) {
    return '$p1 × $p2';
  }

  @override
  String inventoryPoLineQuantity(String p1) {
    return 'Cantidad: $p1';
  }

  @override
  String get inventoryPoReceiptHeader => 'Comprobante';

  @override
  String get inventoryPoReceiptNumber => 'Número de comprobante';

  @override
  String get inventoryPoReceiptDate => 'Fecha de recepción';

  @override
  String get inventoryPoReceive => 'Recibir orden';

  @override
  String get inventoryPoReceiveTitle => 'Recibir la orden';

  @override
  String get inventoryPoReceiveBody =>
      'Cada línea entra al stock como un lote nuevo. Anota el número del comprobante y toma una foto.';

  @override
  String get inventoryPoReceiveConfirm => 'Confirmar recepción';

  @override
  String get inventoryPoPhotoTake => 'Tomar foto del comprobante';

  @override
  String get inventoryPoPhotoRetake => 'Volver a tomar la foto';

  @override
  String get inventoryPoPhotoAttached => 'Foto del comprobante lista';

  @override
  String get inventoryPoReceivedOk => 'Orden recibida. El stock ya subió.';

  @override
  String inventoryPoLines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count líneas',
      one: '$count línea',
    );
    return '$_temp0';
  }

  @override
  String get inventoryValuationTitle => 'Valorización';

  @override
  String get inventoryValuationContext => 'Inventario';

  @override
  String get inventoryValuationCaption =>
      'Valor de los lotes con saldo, al costo';

  @override
  String get inventoryValuationNoPermission =>
      'Tu perfil no tiene permiso para ver la valorización.';

  @override
  String get inventoryValuationWithStock => 'con stock';

  @override
  String get inventoryValuationLow => 'en el mínimo';

  @override
  String get inventoryValuationOut => 'agotados';

  @override
  String get inventoryValuationByCategory => 'Existencias por categoría';

  @override
  String get inventoryValuationEmpty => 'No hay repuestos con stock.';

  @override
  String get inventoryValuationUncategorized => 'Sin categoría';

  @override
  String inventoryValuationUnits(String p1) {
    return '$p1 u.';
  }

  @override
  String inventoryValuationParts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count repuestos',
      one: '$count repuesto',
    );
    return '$_temp0';
  }

  @override
  String get invSeg2ScannerTitle => 'Escanear SKU';

  @override
  String get invSeg2ScannerOpenDesc => 'Escanear código de barras o QR';

  @override
  String get invSeg2ScannerHint =>
      'Apunta la cámara al código de barras o QR del repuesto.';

  @override
  String get invSeg2ScannerPermissionTitle => 'Permiso de cámara';

  @override
  String get invSeg2ScannerPermissionBody =>
      'Necesitamos acceso a la cámara para leer códigos de barras. También puedes escribir el SKU abajo.';

  @override
  String get invSeg2ScannerPermissionGrant => 'Permitir cámara';

  @override
  String get invSeg2ScannerManualLabel => 'Ingreso manual de SKU';

  @override
  String get invSeg2ScannerManualHint => 'Ej. BRK-001';

  @override
  String get invSeg2ScannerSearchBtn => 'Buscar SKU';

  @override
  String invSeg2ScannerNotFound(String p1) {
    return 'No se encontró ningún repuesto con el SKU $p1.';
  }

  @override
  String invSeg2ScannerInvalidSku(String p1) {
    return 'El código $p1 no tiene formato válido de SKU (3 a 50 caracteres: A-Z, 0-9, - o _).';
  }

  @override
  String get invSeg2ScannerRetry => 'Escanear otro código';

  @override
  String get invSeg2ScannerNoPermission =>
      'Tu perfil no tiene permiso para consultar el catálogo de repuestos.';

  @override
  String get invSeg2SuppliersTitle => 'Proveedores';

  @override
  String get invSeg2SuppliersNoPermission =>
      'Tu perfil no tiene permiso para gestionar proveedores.';

  @override
  String get invSeg2SuppliersSearchLabel => 'Buscar proveedor';

  @override
  String get invSeg2SuppliersSearchHint => 'Razón social o RUC';

  @override
  String get invSeg2SuppliersEmpty => 'Todavía no hay proveedores registrados.';

  @override
  String get invSeg2SuppliersEmptyFiltered =>
      'Ningún proveedor coincide con la búsqueda.';

  @override
  String get invSeg2SuppliersNewFab => 'Nuevo proveedor';

  @override
  String get invSeg2SuppliersCreateTitle => 'Nuevo proveedor';

  @override
  String get invSeg2SuppliersEditTitle => 'Editar proveedor';

  @override
  String invSeg2SuppliersTaxIdLine(String p1) {
    return 'RUC $p1';
  }

  @override
  String get invSeg2SuppliersActive => 'Activo';

  @override
  String get invSeg2SuppliersInactive => 'Inactivo';

  @override
  String get invSeg2SupplierBusinessName => 'Razón social';

  @override
  String get invSeg2SupplierTaxId => 'RUC o documento';

  @override
  String get invSeg2SupplierContact => 'Persona de contacto (opcional)';

  @override
  String get invSeg2SupplierPhone => 'Teléfono (opcional)';

  @override
  String get invSeg2SupplierEmail => 'Correo electrónico (opcional)';

  @override
  String get invSeg2SupplierAddress => 'Dirección fiscal (opcional)';

  @override
  String get invSeg2SupplierActiveToggle => 'Proveedor activo';

  @override
  String get invSeg2SupplierErrName => 'Ingresa la razón social del proveedor.';

  @override
  String get invSeg2SupplierErrTaxId =>
      'Ingresa un RUC o documento de 8 a 20 dígitos.';

  @override
  String get invSeg2SupplierErrEmail =>
      'El formato del correo electrónico no es válido.';

  @override
  String get invSeg2SupplierSaved => 'Proveedor guardado.';

  @override
  String get invSeg2PartNewFab => 'Nuevo repuesto';

  @override
  String get invSeg2PartCreateTitle => 'Nuevo repuesto';

  @override
  String get invSeg2PartEditTitle => 'Editar repuesto';

  @override
  String get invSeg2PartEditBtn => 'Editar';

  @override
  String get invSeg2PartName => 'Nombre del repuesto';

  @override
  String get invSeg2PartSku => 'Código SKU';

  @override
  String get invSeg2PartCategory => 'Categoría';

  @override
  String get invSeg2PartBasePrice => 'Precio base sin IGV (S/)';

  @override
  String get invSeg2PartMinStock => 'Stock mínimo';

  @override
  String get invSeg2PartStatus => 'Estado en catálogo';

  @override
  String get invSeg2PartStatusActive => 'Activo';

  @override
  String get invSeg2PartStatusInactive => 'Inactivo';

  @override
  String get invSeg2PartStatusDiscontinued => 'Descontinuado';

  @override
  String get invSeg2PartErrName => 'Ingresa el nombre del repuesto.';

  @override
  String get invSeg2PartErrSku =>
      'Usa de 3 a 50 caracteres (A-Z, 0-9, guion o guion bajo).';

  @override
  String get invSeg2PartErrPrice => 'Ingresa un precio base igual o mayor a 0.';

  @override
  String get invSeg2PartErrMinStock =>
      'Ingresa un stock mínimo igual o mayor a 0.';

  @override
  String get invSeg2PartSaved => 'Repuesto guardado.';

  @override
  String get invSeg2BatchActionsHeader => 'Movimientos de lote FIFO';

  @override
  String get invSeg2BatchReceiveBtn => 'Ingresar lote directo';

  @override
  String get invSeg2BatchDispatchBtn => 'Despachar FIFO';

  @override
  String get invSeg2BatchRestoreBtn => 'Reintegrar lote';

  @override
  String get invSeg2BatchReceiveTitle => 'Ingreso directo de lote';

  @override
  String get invSeg2BatchDispatchTitle => 'Despacho FIFO';

  @override
  String get invSeg2BatchRestoreTitle => 'Reintegrar lote';

  @override
  String get invSeg2BatchNumberLabel => 'Número de lote';

  @override
  String get invSeg2BatchQuantityLabel => 'Cantidad';

  @override
  String get invSeg2BatchUnitCostLabel => 'Costo unitario (S/)';

  @override
  String get invSeg2BatchReasonLabel => 'Motivo del reintegro (opcional)';

  @override
  String get invSeg2BatchSelectLabel => 'Lote de origen';

  @override
  String get invSeg2BatchSelectAuto => 'Automático (último lote)';

  @override
  String get invSeg2BatchErrNumber => 'Ingresa el número de lote.';

  @override
  String get invSeg2BatchErrQty => 'La cantidad debe ser al menos 0.01.';

  @override
  String get invSeg2BatchErrCost =>
      'El costo unitario debe ser igual o mayor a 0.';

  @override
  String get invSeg2BatchReceivedOk => 'Lote ingresado al inventario.';

  @override
  String invSeg2BatchDispatchedOk(String p1) {
    return 'Despacho FIFO realizado ($p1 u.).';
  }

  @override
  String invSeg2BatchRestoredOk(String p1) {
    return 'Stock reintegrado ($p1 u.).';
  }

  @override
  String get invSeg2AlertsCreatePoFab => 'Crear orden de compra';

  @override
  String invSeg2PartLowStockBanner(String p1, String p2) {
    return 'Existencias bajo el stock mínimo ($p1 / mín. $p2). Programa una orden de compra o ingresa un lote.';
  }

  @override
  String get invSeg2PartOpenPoBtn => 'Ir a órdenes de compra';

  @override
  String get invSeg2PoFilterDraft => 'Borradores';

  @override
  String get invSeg2PoFilterCanceled => 'Anuladas';

  @override
  String get invSeg2PoNewFab => 'Nueva orden';

  @override
  String get invSeg2PoCreateTitle => 'Nueva orden de compra';

  @override
  String get invSeg2PoSelectSupplier => 'Elige un proveedor';

  @override
  String get invSeg2PoNoSuppliers =>
      'No hay proveedores activos. Registra uno antes de crear una orden.';

  @override
  String get invSeg2PoNumberOptional => 'Número de orden (opcional)';

  @override
  String get invSeg2PoNotesOptional => 'Notas internas (opcional)';

  @override
  String get invSeg2PoCreateConfirm => 'Crear borrador';

  @override
  String get invSeg2PoAddLineBtn => 'Agregar repuesto';

  @override
  String get invSeg2PoAddLineTitle => 'Agregar línea a la orden';

  @override
  String get invSeg2PoSelectPart => 'Selecciona un repuesto';

  @override
  String get invSeg2PoPartSearchHint => 'Buscar por nombre o SKU';

  @override
  String get invSeg2PoIssueBtn => 'Emitir orden';

  @override
  String get invSeg2PoIssueHint =>
      'Agrega al menos un repuesto para poder emitir la orden al proveedor.';

  @override
  String get invSeg2PoCancelBtn => 'Anular orden';

  @override
  String get invSeg2PoCancelTitle => 'Anular orden de compra';

  @override
  String get invSeg2PoCancelBody =>
      'La orden quedará anulada y no podrá recibirse.';

  @override
  String get invSeg2PoCancelReason => 'Motivo de anulación (opcional)';

  @override
  String get invSeg2PoCancelConfirm => 'Confirmar anulación';

  @override
  String get invSeg2PoIssuedOk => 'Orden emitida. Ya está lista para recibir.';

  @override
  String get invSeg2PoCanceledOk => 'Orden de compra anulada.';

  @override
  String get invSeg2PoLineAddedOk => 'Repuesto agregado a la orden.';

  @override
  String get invSeg2PoMissingBranch =>
      'Tu sesión no tiene sede asignada para crear órdenes.';

  @override
  String get invSeg2PoInitialLineTitle => 'Primer repuesto de la orden';

  @override
  String get invSeg2PoNoParts =>
      'No hay repuestos en el catálogo. Registra un repuesto antes de crear la orden de compra.';

  @override
  String invSeg2PoLowStockOnly(int p1) {
    return 'Solo stock mínimo ($p1)';
  }

  @override
  String get invSeg2PoLowStockEmpty =>
      'No hay repuestos con stock mínimo que coincidan.';

  @override
  String invSeg2PoGenerateLowStockBtn(int p1) {
    return 'Generar borrador con stock mínimo ($p1)';
  }

  @override
  String get invSeg2PoGenerateLowStockHint =>
      'Agrega todos los repuestos en o debajo del mínimo con cantidad sugerida.';

  @override
  String invSeg2PoPartChipLowStock(String p1, String p2, String p3, String p4) {
    return '$p1 ($p2) · Stock $p3/$p4';
  }

  @override
  String invSeg2PoPartChipOutOfStock(String p1, String p2, String p3) {
    return '$p1 ($p2) · Sin stock (mín. $p3)';
  }

  @override
  String get invSeg2Save => 'Guardar';

  @override
  String get invSeg2Confirm => 'Confirmar';

  @override
  String get invSeg2Clear => 'Limpiar';

  @override
  String get moreHTitle => 'Más';

  @override
  String get moreHGroupWorkshop => 'Taller';

  @override
  String get moreHGroupCashier => 'Caja y reportes';

  @override
  String get moreHGroupStock => 'Repuestos';

  @override
  String get moreHGroupAccount => 'Cuenta';

  @override
  String get moreHBranch => 'Cambiar de sede';

  @override
  String get moreHBranchSub => 'Elige la sede con la que trabajas';

  @override
  String get moreHMyAttendance => 'Mi asistencia';

  @override
  String get moreHMyAttendanceSub => 'Marcación GPS, turno y descargos';

  @override
  String get moreHMyTasks => 'Mis tareas';

  @override
  String get moreHMyTasksSub => 'Cronómetro, evidencias y repuestos';

  @override
  String get moreHWorkshopTasks => 'Tareas del taller';

  @override
  String get moreHWorkshopTasksSub =>
      'Faenas activas y suspensiones de la sede';

  @override
  String get moreHOrders => 'Órdenes de trabajo';

  @override
  String get moreHOrdersSub => 'Órdenes abiertas y proformas de la sede';

  @override
  String get moreHReception => 'Recibir vehículo';

  @override
  String get moreHReceptionSub => 'Busca por placa y abre la orden';

  @override
  String get moreHBays => 'Bahías';

  @override
  String get moreHBaysSub => 'Qué auto ocupa cada bahía';

  @override
  String get moreHServices => 'Servicios';

  @override
  String get moreHServicesSub => 'Catálogo de mano de obra y tarifas';

  @override
  String get moreHObd => 'Escáneres OBD-II';

  @override
  String get moreHObdSub => 'Equipos de diagnóstico del taller';

  @override
  String get moreHDailyCash => 'Caja del día';

  @override
  String get moreHDailyCashSub => 'Lo cobrado hoy en la sede';

  @override
  String get moreHVouchers => 'Comprobantes SUNAT';

  @override
  String get moreHVouchersSub => 'Boletas, facturas, notas de crédito';

  @override
  String get moreHReports => 'Reportes';

  @override
  String get moreHReportsSub => 'Flujo de caja y salud de flota en PDF';

  @override
  String get moreHSeries => 'Series de comprobantes';

  @override
  String get moreHSeriesSub => 'Boletas y facturas SUNAT de la sede';

  @override
  String get moreHParts => 'Catálogo de repuestos';

  @override
  String get moreHPartsSub => 'Stock, precios y lotes';

  @override
  String get moreHAlerts => 'Alertas de stock';

  @override
  String get moreHAlertsSub => 'Repuestos por reponer o agotados';

  @override
  String get moreHPurchases => 'Órdenes de compra';

  @override
  String get moreHPurchasesSub => 'Pedidos a proveedores y su recepción';

  @override
  String get moreHSuppliers => 'Proveedores';

  @override
  String get moreHSuppliersSub => 'Directorio comercial de suministros';

  @override
  String get moreHValuation => 'Valorización';

  @override
  String get moreHValuationSub => 'Cuánto vale el inventario';

  @override
  String get moreHNotifications => 'Notificaciones';

  @override
  String get moreHNotificationsSub => 'Avisos y alertas del taller';

  @override
  String get moreHSync => 'Pendientes de sincronizar';

  @override
  String get moreHSyncSub => 'Fotos y propuestas guardadas sin red';

  @override
  String get moreHProfile => 'Mi cuenta';

  @override
  String get moreHProfileSub => 'Perfil, sede y cerrar sesión';

  @override
  String get mainTabModules => 'Módulos';

  @override
  String get mainTabShift => 'Turno';

  @override
  String get mainTabPurchases => 'Compras';

  @override
  String get mainTabCash => 'Caja';

  @override
  String get mainTabBays => 'Bahías';

  @override
  String get barActionReceive => 'Recibir';

  @override
  String get barActionAppointment => 'Cita';

  @override
  String get barActionAppointmentDesc => 'Gestionar citas y recepción';

  @override
  String get barActionCollect => 'Cobrar';

  @override
  String get barActionCollectDesc => 'Ver órdenes listas para cobrar';

  @override
  String get barActionScan => 'SKU';

  @override
  String get barActionScanDesc => 'Buscar o escanear repuesto por SKU';

  @override
  String get barActionTasks => 'Tareas';

  @override
  String get barActionTasksDesc => 'Ir a mis tareas activas';

  @override
  String get modulesTitle => 'Todos los módulos';

  @override
  String get ordersListTitle => 'Órdenes';

  @override
  String get ordersReceiveVehicle => 'Recibir vehículo';

  @override
  String get ordersSearchLabel => 'Buscar por placa';

  @override
  String get ordersSearchClear => 'Borrar búsqueda';

  @override
  String get ordersFilterAll => 'Todas';

  @override
  String get ordersEmptyFiltered => 'Ninguna orden coincide con lo que buscas.';

  @override
  String ordersOrderNumber(int p1) {
    return 'Orden #$p1';
  }

  @override
  String get ordersUpdatedNow => 'Actualizado ahora';

  @override
  String ordersUpdatedAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Actualizado hace $count min',
      one: 'Actualizado hace $count min',
    );
    return '$_temp0';
  }

  @override
  String get ordersSectionDecisions => 'Esperan tu decisión';

  @override
  String get ordersSectionData => 'Datos de la orden';

  @override
  String get ordersSectionProposals => 'Propuestas por hallazgo';

  @override
  String get ordersSectionPhotos => 'Fotos de recepción';

  @override
  String get ordersSectionQuotation => 'Proforma';

  @override
  String get ordersSectionCosts => 'Costos y repuestos';

  @override
  String get ordersSeeAll => 'Ver todas';

  @override
  String get ordersBayLabel => 'Bahía de trabajo';

  @override
  String get ordersBayNone => 'Sin bahía asignada';

  @override
  String get ordersBayChange => 'Cambiar';

  @override
  String get ordersBayAssign => 'Asignar';

  @override
  String get ordersMileageLabel => 'Kilometraje al ingreso';

  @override
  String get ordersDiagnosticLabel => 'Motivo de ingreso';

  @override
  String ordersPhotosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos',
      one: '$count foto',
    );
    return '$_temp0';
  }

  @override
  String get ordersCheckout => 'Cobrar y entregar';

  @override
  String get ordersActionStart => 'Iniciar orden';

  @override
  String get ordersActionComplete => 'Completar orden';

  @override
  String get ordersActionCancel => 'Cancelar orden';

  @override
  String get ordersStartedNotice =>
      'Orden iniciada. Los técnicos ya pueden empezar.';

  @override
  String get ordersCompletedNotice =>
      'Orden completada. Ya se puede cobrar y entregar.';

  @override
  String get ordersCanceledNotice =>
      'Orden cancelada. Los repuestos reservados volvieron al inventario.';

  @override
  String get ordersCancelTitle => '¿Cancelar la orden?';

  @override
  String get ordersCancelBody =>
      'Se libera la bahía y los repuestos reservados vuelven al inventario. No se puede deshacer.';

  @override
  String get ordersCancelReasonLabel => 'Motivo de la cancelación';

  @override
  String get ordersCancelReasonHint => 'El cliente decidió no repararlo';

  @override
  String get ordersCancelFieldError =>
      'Escribe el motivo de la cancelación (máximo 1000 caracteres).';

  @override
  String get ordersCancelConfirm => 'Sí, cancelar orden';

  @override
  String ordersDecisionSuspension(String p1) {
    return 'Suspensión: $p1';
  }

  @override
  String ordersDecisionProposal(String p1) {
    return 'Propuesta: $p1';
  }

  @override
  String get ordersQuotationDecisionTitle => 'Proforma sin respuesta';

  @override
  String get ordersQuotationDecisionRowHint =>
      'Registra lo que respondió el cliente';

  @override
  String get ordersQuotationSendShort => 'Enviar por correo';

  @override
  String get ordersSuspensionTitle => 'Suspensión por validar';

  @override
  String get ordersSuspensionNoReason => 'El mecánico no indicó el motivo.';

  @override
  String ordersSuspensionMissingItem(String p1) {
    return 'Falta: $p1';
  }

  @override
  String get ordersSuspensionApprove => 'Aprobar suspensión';

  @override
  String get ordersSuspensionReject => 'Rechazar suspensión';

  @override
  String get ordersSuspensionApprovedNotice =>
      'Suspensión aprobada. La tarea queda detenida hasta que llegue el repuesto.';

  @override
  String get ordersSuspensionRejectedNotice =>
      'Suspensión rechazada. El mecánico sigue con la tarea.';

  @override
  String get ordersResumeTask => 'Reanudar tarea';

  @override
  String get ordersTaskResumedNotice =>
      'Tarea reanudada. Se avisó al mecánico.';

  @override
  String get ordersProposalsResolved => 'Ya resueltas';

  @override
  String get ordersProposalSheetTitle => 'Propuesta de hallazgo';

  @override
  String get ordersProfitabilityTitle => 'Rentabilidad';

  @override
  String get ordersProfitabilityHint => 'Ingreso de repuestos contra su costo';

  @override
  String get ordersProfitLaborRevenue => 'Ingreso por mano de obra';

  @override
  String get ordersProfitPartsRevenue => 'Ingreso por repuestos';

  @override
  String get ordersProfitCostOfSales => 'Costo de los repuestos';

  @override
  String get ordersProfitPartsGross => 'Ganancia de repuestos';

  @override
  String get ordersProfitSubtotal => 'Subtotal sin IGV';

  @override
  String get ordersProfitLines => 'Por repuesto';

  @override
  String ordersProfitLineDetail(String p1, String p2) {
    return '$p1 unid. · costo $p2';
  }

  @override
  String get ordersMovementsTitle => 'Movimientos de repuestos';

  @override
  String get ordersMovementsHint =>
      'De qué lote salió cada repuesto y cuánto volvió';

  @override
  String get ordersMovementsEmpty =>
      'Esta orden aún no tiene repuestos imputados.';

  @override
  String ordersMovementDetail(String p1, String p2) {
    return 'Salió $p1 · volvió $p2';
  }

  @override
  String get premiumSearchModePlate => 'Placa';

  @override
  String get premiumSearchModeDocument => 'DNI / RUC';

  @override
  String get premiumPartStockLevel => 'Nivel de stock';

  @override
  String premiumPartStockRatio(String p1, String p2) {
    return '$p1 / mín. $p2';
  }

  @override
  String get premiumPartStockHealthy => 'Sobre el mínimo';

  @override
  String get premiumPartStockLow => 'En el mínimo o debajo';

  @override
  String get premiumPartStockOut => 'Sin existencias';

  @override
  String get premiumValuationHealthTitle => 'Salud del inventario';

  @override
  String premiumValuationHealthSummary(int p1, int p2, int p3) {
    return '$p1 con stock · $p2 en mínimo · $p3 agotados';
  }

  @override
  String premiumValuationCategoryMin(String p1) {
    return 'Mínimo $p1 u.';
  }

  @override
  String get premiumCheckoutRailVoucher => 'Comprobante';

  @override
  String get premiumCheckoutRailPayment => 'Cobro';

  @override
  String get premiumCheckoutRailPass => 'Pase';

  @override
  String get premiumCheckoutRailDelivery => 'Entrega';

  @override
  String get premiumCheckoutRailDone => 'Flujo completado';

  @override
  String premiumCheckoutRailStepOf(int p1) {
    return 'Etapa $p1 de 4';
  }

  @override
  String premiumDailyMethodShare(int p1) {
    return '$p1 %';
  }

  @override
  String get pitGeofenceLocating => 'Calibrando señal GPS…';

  @override
  String get pitTaskProgressLabel => 'Avance estimado';

  @override
  String pitTaskElapsedVsEst(int p1, int p2, String p3) {
    return '${p1}h ${p2}m / $p3 h';
  }

  @override
  String get pitDockRunning => 'Labor en curso';

  @override
  String get pitDockPaused => 'Labor en pausa';

  @override
  String get pitDockReady => 'Lista para iniciar';

  @override
  String get pitReportScoreMax => '/ 100';

  @override
  String pitReportScoreCd(int p1) {
    return 'Puntaje de salud vehicular: $p1 de 100';
  }

  @override
  String get todayCarsEmpty => 'Sin autos';

  @override
  String get todayFigureReadyShort => 'listos';

  @override
  String get todayLiveBayBadge => 'En vivo';

  @override
  String get baysFilterAllShort => 'Todas';

  @override
  String get baysFilterAvailableShort => 'Libres';

  @override
  String get baysFilterOccupiedShort => 'Ocupadas';

  @override
  String get baysFilterMaintenanceShort => 'Mant.';

  @override
  String get baysOccupancyTitle => 'Ocupación de bahías';

  @override
  String baysOccupancyFraction(int p1, int p2) {
    return '$p1/$p2';
  }

  @override
  String baysOccupancyBreakdown(int p1, int p2) {
    return '$p1 libres · $p2 en mantenimiento';
  }

  @override
  String get syncSummaryTitle => 'Estado de la cola';

  @override
  String syncSummaryCounts(int p1, int p2, int p3) {
    return '$p1 en cola · $p2 enviando · $p3 con error';
  }

  @override
  String get notifSummaryTitle => 'Requieren atención';

  @override
  String get notifSummaryBody =>
      'Revisa alertas de stock, descargos y aprobaciones pendientes.';

  @override
  String get profileAccountSummary => 'Resumen de cuenta';

  @override
  String get receptionSearchTitle => 'Recibir vehículo';

  @override
  String get receptionSearchPlatePlaceholder => 'ABC-123';

  @override
  String get receptionSearchByDocument => 'Buscar por DNI o RUC';

  @override
  String get receptionSearchByPlate => 'Buscar por placa';

  @override
  String get receptionSearchOfflineCache =>
      'Sin conexión. Buscas entre los datos guardados en este teléfono.';

  @override
  String get receptionSearchNoAccess =>
      'Tu perfil no tiene acceso a Recepción.';

  @override
  String get receptionSearchNoSearchPermission =>
      'Tu perfil no puede buscar vehículos ni clientes.';

  @override
  String receptionPlateNotFound(String p1) {
    return 'No hay un vehículo con la placa $p1.';
  }

  @override
  String get receptionOpenOrder => 'Abrir orden';

  @override
  String get receptionAddVehicle => 'Agregar vehículo';

  @override
  String get receptionSelected => 'Elegido';

  @override
  String get receptionAppointmentNoCustomer => 'Cliente sin cargar';

  @override
  String get receptionArriveTitle => 'Registrar llegada';

  @override
  String get receptionArriveConfirm => 'Registrar llegada';

  @override
  String receptionArriveTime(String p1) {
    return 'Hora de la cita: $p1';
  }

  @override
  String get receptionFormVehicleTitle => 'Agregar vehículo';

  @override
  String get teamTitle => 'Equipo';

  @override
  String get teamNoPermission =>
      'Tu cuenta no puede ver la asistencia del equipo.';

  @override
  String get teamTabTeam => 'Equipo';

  @override
  String get teamTabMine => 'Mi asistencia';

  @override
  String get teamOffline =>
      'Sin conexión. La asistencia del equipo necesita red para actualizarse.';

  @override
  String teamLegend(int p1, int p2) {
    return '$p1 de $p2';
  }

  @override
  String get teamCaption => 'en turno ahora';

  @override
  String get teamFigureOnTime => 'puntuales';

  @override
  String get teamFigureLate => 'tardanzas';

  @override
  String get teamFigureAbsent => 'faltas';

  @override
  String get teamToday => 'Asistencia de hoy';

  @override
  String get teamEmpty => 'Nadie ha marcado asistencia hoy en esta sede.';

  @override
  String get teamNoClockIn => 'Sin entrada registrada';

  @override
  String teamClockRange(String p1, String p2) {
    return 'Entró $p1 · salió $p2';
  }

  @override
  String teamClockInOpen(String p1) {
    return 'Entró $p1 · en turno';
  }

  @override
  String get teamStatusOnTime => 'Puntual';

  @override
  String get teamStatusLate => 'Tarde';

  @override
  String get teamStatusAbsent => 'Falta';

  @override
  String get teamStatusExcused => 'Justificada';

  @override
  String get baysOffline =>
      'Sin conexión. Ves el último tablero guardado; reasignar y crear bahías necesita red.';

  @override
  String baysLabor(String p1) {
    return 'Mano de obra $p1';
  }

  @override
  String get baysTapToAssign => 'Toca para ingresar una orden';

  @override
  String get baysUnavailableError => 'Esa bahía no está libre. Elige otra.';

  @override
  String get baysNoAssignableOrders => 'No hay órdenes activas sin bahía.';

  @override
  String get baysNameError => 'Escribe un nombre de hasta 100 caracteres.';

  @override
  String get baysMechanicsSection => 'Mecánicos y faenas en bahía';

  @override
  String get notifTitle => 'Notificaciones';

  @override
  String get notifSectionAttention => 'Piden tu atención';

  @override
  String get notifSectionReceived => 'Avisos de esta sesión';

  @override
  String get notifEmpty =>
      'Aquí verás los avisos de tareas, stock y asistencia cuando lleguen.';

  @override
  String get notifUnread => 'Nuevo';

  @override
  String get notifDraftChip => 'Sin iniciar';

  @override
  String get notifSyncPendingBody => 'Toca para revisarlos o reenviarlos.';

  @override
  String notifSyncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros sin enviar',
      one: '$count registro sin enviar',
    );
    return '$_temp0';
  }

  @override
  String get syncEmptyLine =>
      'Todo sincronizado. No hay nada pendiente de envío.';

  @override
  String get syncDiscardWarning =>
      'Si lo descartas, este registro se borra del teléfono y no llega al servidor.';

  @override
  String get profileSectionWorkshop => 'Mi taller';

  @override
  String get profileLabelWorkshop => 'Taller';

  @override
  String get profileLabelBranch => 'Sede actual';

  @override
  String get profileBranchChange => 'Sede actual · Cambiar sede';

  @override
  String get profileBranchUnknown => 'Sin sede elegida';

  @override
  String get profileModuleObd => 'Escáneres OBD-II';

  @override
  String get profileModuleAi => 'Diagnóstico con IA';

  @override
  String get profileModuleNone => 'Módulos básicos';

  @override
  String get profileNoUnread => 'Sin avisos nuevos';

  @override
  String profileUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avisos sin leer',
      one: '$count aviso sin leer',
    );
    return '$_temp0';
  }

  @override
  String get profileSignOutSub => 'Salir de Atelier en este teléfono';

  @override
  String get profileSignOutPlain =>
      'Vas a salir de Atelier en este teléfono. Para volver a entrar necesitarás tu correo y tu contraseña.';

  @override
  String get obdPlanLocked =>
      'Los escáneres OBD-II no están incluidos en el plan de este taller.';

  @override
  String get obdNoPermission =>
      'Tu cuenta no puede ver los escáneres del taller.';

  @override
  String get obdOffline =>
      'Sin conexión. Registrar, vincular y cambiar el estado de un escáner necesita red.';

  @override
  String get obdNoVehicles =>
      'No hay vehículos del taller guardados en este teléfono.';

  @override
  String get obdVehicleHasScanner => 'Ya tiene un escáner vinculado';

  @override
  String obdFirmwareFormat(String p1) {
    return 'FW $p1';
  }

  @override
  String get obdHintIdentifier => 'Ej. AA:BB:CC:11:22:33';

  @override
  String get obdHintModel => 'Ej. ELM327 v1.5 u OBDLink MX+';

  @override
  String get obdHintFirmware => 'Ej. 2.1';

  @override
  String get obdConnBluetooth => 'Bluetooth';

  @override
  String get obdConnWifi => 'Wi-Fi';

  @override
  String get obdConnUsb => 'USB';

  @override
  String get tasksWorkshopTitle => 'Tareas del taller';

  @override
  String get tasksWorkshopPanelCaption => 'activas en la sede';

  @override
  String get tasksWorkshopEmpty =>
      'No hay tareas activas en las órdenes de la sede.';

  @override
  String get tasksSeg2PanelContext => 'Bandeja de bahía';

  @override
  String get tasksSeg2PanelCaption => 'asignadas en tu turno';

  @override
  String tasksSeg2LegendCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas',
      one: '$count tarea',
    );
    return '$_temp0';
  }

  @override
  String get tasksSeg2FigurePending => 'pendientes';

  @override
  String get tasksSeg2FigureInProgress => 'en curso';

  @override
  String get tasksSeg2FigurePaused => 'en pausa';

  @override
  String get tasksSeg2FilterAssigned => 'Asignadas';

  @override
  String get tasksSeg2FilterSuspended => 'Suspendidas';

  @override
  String get tasksSeg2EmptyFiltered =>
      'Ninguna tarea coincide con este filtro.';

  @override
  String get tasksSeg2MetaNoPlate => 'Sin placa';

  @override
  String get tasksSeg2QuickActions => 'Accesos rápidos';

  @override
  String get tasksSeg2ActionObd => 'Escáner OBD-II';

  @override
  String get tasksSeg2ActionFinding => 'Reportar hallazgo';

  @override
  String get tasksSeg2ControlsSection => 'Control de labor';

  @override
  String get tasksSeg2DescriptionSection => 'Detalle técnico';

  @override
  String tasksSeg2TimerEstimated(String p1) {
    return 'Est. $p1 h';
  }

  @override
  String get tasksSeg2EvidenceSection => 'Evidencias fotográficas';

  @override
  String get tasksSeg2EvidenceKindLabel => 'Momento de la foto';

  @override
  String get tasksSeg2EvidenceDisassembly => 'Desmontaje';

  @override
  String get tasksSeg2EvidenceAssembly => 'Montaje';

  @override
  String get tasksSeg2EvidenceNoteLabel => 'Nota de evidencia (opcional)';

  @override
  String get tasksSeg2EvidenceNoteHint => 'Ej. pastilla desgastada al 10 %';

  @override
  String get tasksSeg2EvidenceTakePhoto => 'Tomar foto';

  @override
  String get tasksSeg2EvidencePickGallery => 'Elegir de la galería';

  @override
  String get tasksSeg2EvidenceEmpty =>
      'Aún no hay fotos de desmontaje o montaje.';

  @override
  String get tasksSeg2EvidenceQueued =>
      'Foto guardada. Se subirá al recuperar señal.';

  @override
  String get tasksSeg2EvidenceFieldError =>
      'La nota supera los 500 caracteres.';

  @override
  String get tasksSeg2SuspensionSection => 'Suspensión de tarea';

  @override
  String get tasksSeg2SuspensionRequestBtn => 'Solicitar suspensión';

  @override
  String get tasksSeg2SuspensionRequestTitle => 'Solicitar suspensión';

  @override
  String get tasksSeg2SuspensionRequestBody =>
      'Indica el repuesto faltante o defectuoso para que el supervisor valide la pausa.';

  @override
  String get tasksSeg2SuspensionItemLabel => 'Descripción de la pieza o motivo';

  @override
  String get tasksSeg2SuspensionItemHint => 'Ej. Retén de cigüeñal con fuga';

  @override
  String get tasksSeg2SuspensionItemError =>
      'Describe el ítem faltante o defectuoso (máx. 500 caracteres).';

  @override
  String get tasksSeg2SuspensionPartOptional =>
      'Repuesto del catálogo (opcional)';

  @override
  String get tasksSeg2SuspensionPartClear => 'Quitar repuesto seleccionado';

  @override
  String get tasksSeg2SuspensionRequestConfirm => 'Enviar solicitud';

  @override
  String get tasksSeg2SuspensionRequestedNotice =>
      'Solicitud enviada. Espera la validación del supervisor.';

  @override
  String get tasksSeg2SuspensionPendingTitle => 'Suspensión solicitada.';

  @override
  String get tasksSeg2SuspensionPendingBody =>
      'Esperando aprobación del supervisor.';

  @override
  String get tasksSeg2SuspensionReviewHint =>
      'Toca para aprobar o rechazar la solicitud';

  @override
  String get tasksSeg2SuspensionResumeRowTitle =>
      'Suspensión activa por repuesto';

  @override
  String get tasksSeg2SuspensionResumeRowHint =>
      'Toca para reanudar la tarea cuando llegue el repuesto';

  @override
  String get tasksSeg2SuspensionResumeSheetTitle => 'Levantar suspensión';

  @override
  String get tasksSeg2SuspensionResumeSheetBody =>
      'Confirma que el repuesto ya está conforme para que el mecánico reanude la labor.';

  @override
  String tasksSeg2SuspensionRequestedAt(String p1) {
    return 'Solicitada: $p1';
  }

  @override
  String get tasksSeg2ReopenBtn => 'Reabrir tarea';

  @override
  String get tasksSeg2ReopenTitle => '¿Reabrir tarea cerrada?';

  @override
  String get tasksSeg2ReopenBody =>
      'La tarea volverá a estado abierto para retrabajo de calidad.';

  @override
  String get tasksSeg2ReopenReasonLabel => 'Motivo de reapertura (opcional)';

  @override
  String get tasksSeg2ReopenReasonHint => 'Ej. Verificar ajuste de torque';

  @override
  String get tasksSeg2ReopenConfirm => 'Confirmar reapertura';

  @override
  String get tasksSeg2ReopenedNotice => 'Tarea reabierta para retrabajo.';

  @override
  String tasksSeg2EvidenceNoteCounter(int p1, int p2) {
    return '$p1 / $p2 caracteres disponibles';
  }

  @override
  String get tasksSeg2EvidenceFailedSheetTitle => 'Foto con error de envío';

  @override
  String get tasksSeg2EvidenceFailedRetryNotice =>
      'Reintento de subida encolado.';

  @override
  String get tasksSeg2EvidenceFailedDiscardNotice =>
      'Foto descartada de la cola.';

  @override
  String get tasksSeg2CompleteMissingAssemblyWarning =>
      'Sube al menos una foto de Montaje antes de completar esta tarea.';

  @override
  String get tasksSeg2UnsavedExitTitle => '¿Salir con nota sin guardar?';

  @override
  String get tasksSeg2UnsavedExitBody =>
      'Tienes una nota de evidencia escrita que aún no has adjuntado con una foto.';

  @override
  String get tasksSeg2UnsavedExitConfirm => 'Salir sin guardar';

  @override
  String get atelierPhotoSynced => 'Guardada';

  @override
  String get atelierPhotoPending => 'Pendiente';

  @override
  String get atelierPhotoFailed => 'Falló';

  @override
  String get pushDefaultTitleTaskDetail => 'Actualización de tarea';

  @override
  String get pushDefaultTitleTaskSuspensionReview =>
      'Pausa de tarea por revisar';

  @override
  String get pushDefaultTitleTaskProducts => 'Repuesto imputado a tarea';

  @override
  String get pushDefaultTitleWorkOrderDetail => 'Orden de trabajo actualizada';

  @override
  String get pushDefaultTitleLowStock => 'Alerta de stock mínimo';

  @override
  String get pushDefaultTitleCollaboratorAttendance =>
      'Novedad de asistencia en sede';

  @override
  String get pushDefaultTitleMyAttendance => 'Justificación revisada';

  @override
  String get pushDefaultTitleClockIn => 'Recordatorio de turno';

  @override
  String teamCollaboratorWithId(String p1) {
    return 'Colaborador · $p1';
  }

  @override
  String attendanceHistoryExit(String p1) {
    return 'Salida $p1';
  }

  @override
  String get attendanceHistoryJustificationPending => 'Descargo pendiente';

  @override
  String get attendanceHistoryJustificationApproved => 'Descargo aprobado';

  @override
  String get attendanceHistoryJustificationRejected => 'Descargo rechazado';

  @override
  String get attendanceHistoryStatusOnTime => 'A tiempo';

  @override
  String get attendanceHistoryStatusLate => 'Tardanza';

  @override
  String get attendanceHistoryStatusAbsent => 'Ausente';

  @override
  String get attendanceHistoryStatusExcused => 'Justificado';

  @override
  String get attendanceHistoryStatusRegistered => 'Registrado';

  @override
  String get floorHubApptConfirmed => 'Confirmada';

  @override
  String get floorHubApptArrived => 'Llegó';

  @override
  String get floorHubApptCanceled => 'Cancelada';

  @override
  String get floorHubApptPending => 'Pendiente';

  @override
  String floorHubTaskEstimated(String p1) {
    return 'Est. $p1 h';
  }

  @override
  String floorHubPoFallback(String p1) {
    return 'OC $p1';
  }

  @override
  String floorHubPoSummary(int p1, String p2) {
    return '$p1 ítems · $p2';
  }

  @override
  String get floorHubPoIssued => 'Emitida';

  @override
  String get floorHubCashReadySubtitle => 'Lista para comprobante y cobro';

  @override
  String floorHubCashOrderNumber(String p1) {
    return 'Orden #$p1';
  }

  @override
  String get floorHubStockPosCaption => 'órdenes de compra emitidas';

  @override
  String get floorHubQuickObdSubNoLive => 'Fallas DTC e informe IA';

  @override
  String get invReceiveCameraDenied =>
      'Sin permiso de cámara. Actívalo en los ajustes del teléfono para fotografiar el comprobante.';

  @override
  String get invReceiveErrPhoto =>
      'Toma la foto del comprobante para recibir la compra.';

  @override
  String get invReceiveErrNumber => 'Ingresa el número del comprobante.';

  @override
  String get invReceiveErrDate =>
      'La fecha debe tener el formato AAAA-MM-DD y no puede ser futura.';

  @override
  String get invReceiveErrNotReceivable =>
      'Solo se pueden recibir órdenes emitidas.';

  @override
  String get diagReportPdfTitle => 'Informe en PDF';

  @override
  String get diagReportPdfHint =>
      'Semáforo de salud por subsistema, riesgos y acciones recomendadas.';

  @override
  String reportsFleetSelected(String name) {
    return 'Cliente: $name';
  }

  @override
  String get reportsFleetClear => 'Quitar cliente';

  @override
  String floorHubStockAlertLine(String p1, String p2, String p3) {
    return '$p1 · Stock $p2 / mín. $p3';
  }

  @override
  String floorHubStockMissing(String p1) {
    return 'Faltan $p1';
  }
}
