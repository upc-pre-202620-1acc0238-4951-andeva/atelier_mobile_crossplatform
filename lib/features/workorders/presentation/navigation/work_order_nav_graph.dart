import 'package:atelier_mobile_crossplatform/features/workorders/presentation/detail/work_order_detail_screen.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/finding/report_finding_screen.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/intake/intake_gallery_screen.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/list/work_orders_screen.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/open/open_work_order_screen.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/proposals/proposals_panel_screen.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/services/services_catalog_screen.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';

/// Destinos de órdenes de trabajo (equivale a `workOrderNavGraph`).
void registerWorkOrderRoutes() {
  AppNavigator.register(
    AppRoute.openWorkOrder,
    (context, args) => OpenWorkOrderScreen(args: args as OpenWorkOrderArgs),
  );
  AppNavigator.register(AppRoute.workOrders, (context, args) => const WorkOrdersScreen());
  AppNavigator.register(
    AppRoute.workOrderDetail,
    (context, args) => WorkOrderDetailScreen(workOrderId: args as String),
  );
  AppNavigator.register(
    AppRoute.intakeGallery,
    (context, args) => IntakeGalleryScreen(workOrderId: args as String),
  );
  AppNavigator.register(
    AppRoute.proposalsPanel,
    (context, args) => ProposalsPanelScreen(workOrderId: args as String),
  );
  AppNavigator.register(
    AppRoute.reportFinding,
    (context, args) => ReportFindingScreen(workOrderId: args as String),
  );
  AppNavigator.register(
    AppRoute.servicesCatalog,
    (context, args) => const ServicesCatalogScreen(),
  );
}
