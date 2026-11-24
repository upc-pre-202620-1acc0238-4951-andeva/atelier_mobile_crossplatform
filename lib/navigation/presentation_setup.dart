import 'package:atelier_mobile_crossplatform/features/attendance/presentation/attendance_presentation.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/auth_presentation.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/cashier_presentation.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/diagnostics_presentation.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/inventory_presentation.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/main_presentation.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/main_shell_presentation.dart';
import 'package:atelier_mobile_crossplatform/features/reception/presentation/reception_presentation.dart';
import 'package:atelier_mobile_crossplatform/features/reports/presentation/reports_presentation.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/tasks_presentation.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/workorders_presentation.dart';

/// Registra los ViewModels (`registerFactory`) y los destinos (`AppNavigator.register`) de la capa de
/// presentación. Solo la UI lo llama, después de `setupDependencies()`: el worker no tiene pantallas.
///
/// Un `setup<Feature>Presentation()` por feature, en `lib/features/<f>/presentation/<f>_presentation.dart`.
void setupPresentation() {
  setupAuthPresentation();
  setupMainShellPresentation();
  setupMainPresentation();
  setupAttendancePresentation();
  setupTasksPresentation();
  setupReceptionPresentation();
  setupWorkOrdersPresentation();
  setupInventoryPresentation();
  setupDiagnosticsPresentation();
  setupReportsPresentation();
  setupCashierPresentation();
}
