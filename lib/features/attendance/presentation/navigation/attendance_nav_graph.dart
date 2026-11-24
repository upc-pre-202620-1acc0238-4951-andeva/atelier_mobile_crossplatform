import 'package:atelier_mobile_crossplatform/features/attendance/presentation/attendance_screen.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/presentation/dashboard/floor_hub_screen.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';

/// Destinos de la feature de asistencia y del hub modular de piso/mostrador (Segmento 2). Equivale a
/// `attendanceNavGraph` de Android: [AppRoute.attendanceHome] es la raíz de la pestaña "Turno" y
/// [AppRoute.attendanceDetail] la pantalla de mi asistencia.
///
/// Argumentos de [AppRoute.attendanceDetail]: `true` la embebe sin barra superior (la pestaña "Mi asistencia" de
/// "Equipo"); nada o `false`, pantalla completa con Atrás.
void registerAttendanceRoutes() {
  AppNavigator.register(AppRoute.attendanceHome, (context, args) => const FloorHubScreen());
  AppNavigator.register(
    AppRoute.attendanceDetail,
    (context, args) => AttendanceScreen(embedded: args == true),
  );
}
