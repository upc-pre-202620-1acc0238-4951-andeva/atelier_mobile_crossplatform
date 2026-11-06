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
  String get placeholderSignedOut => 'Inicio de sesión';

  @override
  String get placeholderBranchChoice => 'Elegir sede';

  @override
  String get placeholderSignedIn => 'Sesión iniciada';
}
