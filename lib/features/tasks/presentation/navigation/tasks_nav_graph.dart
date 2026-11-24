import 'package:atelier_mobile_crossplatform/features/tasks/presentation/detail/task_detail_screen.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/mytasks/my_tasks_screen.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';

/// Destinos de la feature de tareas del mecánico (EP06). Equivale a `tasksNavGraph` de Android:
/// [AppRoute.myTasks] es la bandeja (US26; raíz de la pestaña "Tareas" o pantalla con Atrás según cómo se llegue) y
/// [AppRoute.taskDetail] el detalle (US27, US33), con [TaskDetailArgs].
void registerTasksRoutes() {
  AppNavigator.register(AppRoute.myTasks, (context, args) => const MyTasksScreen());
  AppNavigator.register(
    AppRoute.taskDetail,
    (context, args) => TaskDetailScreen(args: args as TaskDetailArgs),
  );
}
