import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/proposal.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_references.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/detail/work_order_detail_screen.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/detail/work_order_detail_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/finding/report_finding_screen.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/finding/report_finding_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/intake/intake_gallery_screen.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/intake/intake_gallery_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/list/work_orders_screen.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/list/work_orders_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/open/open_work_order_screen.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/open/open_work_order_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/proposals/proposals_panel_screen.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/proposals/proposals_panel_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/services/services_catalog_screen.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/services/services_catalog_ui_state.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _loadSatoshi() async {
  final loader = FontLoader('Satoshi');
  for (final file in ['regular', 'medium', 'bold', 'black']) {
    loader.addFont(rootBundle.load('assets/fonts/satoshi_$file.otf'));
  }
  await loader.load();
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(390 * 3, 3000 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AtelierTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: child,
    ),
  );
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _teardown(WidgetTester tester) => tester.pumpWidget(const SizedBox());

const _sampleOrder = WorkOrder(
  id: WorkOrderId('wo1'),
  internalNumber: 1042,
  branchId: 'b1',
  vehicleId: 'v1',
  customerId: 'c1',
  bayName: 'Bahía 2',
  status: WorkOrderStatus.inProgress,
  diagnosticSummary: 'Ruido al frenar.',
  mileageIn: 84500,
  plate: 'BKR418',
  customerName: 'Rosa Quispe Mamani',
);

const _sampleService = ServiceOption(
  id: 's1',
  name: 'Cambio de pastillas',
  basePrice: null,
  estimatedMinutes: 60,
);

void main() {
  setUpAll(_loadSatoshi);

  group('WorkOrdersContent', () {
    testWidgets('cargado, vacío y error', (tester) async {
      await _pump(
        tester,
        WorkOrdersContent(
          state: WorkOrdersUiState(isLoaded: true, orders: const [_sampleOrder]),
          onRefresh: () async {},
          onOpenOrder: (_) {},
          onOpenNotifications: () {},
          onOpenSync: () {},
          onStatusFilterChange: (_) {},
          onQueryChange: (_) {},
        ),
      );
      expect(find.text('Rosa Quispe Mamani'), findsOneWidget);
      expect(find.text('En curso'), findsNWidgets(2));

      await _pump(
        tester,
        WorkOrdersContent(
          state: const WorkOrdersUiState(isLoaded: true),
          onRefresh: () async {},
          onOpenOrder: (_) {},
          onOpenNotifications: () {},
          onOpenSync: () {},
          onStatusFilterChange: (_) {},
          onQueryChange: (_) {},
        ),
      );
      expect(find.text('No hay órdenes abiertas.'), findsOneWidget);

      await _pump(
        tester,
        WorkOrdersContent(
          state: const WorkOrdersUiState(isLoaded: true, error: UiText.dynamic('Fallo de red')),
          onRefresh: () async {},
          onOpenOrder: (_) {},
          onOpenNotifications: () {},
          onOpenSync: () {},
          onStatusFilterChange: (_) {},
          onQueryChange: (_) {},
        ),
      );
      expect(find.text('Fallo de red'), findsOneWidget);
      await _teardown(tester);
    });
  });

  group('WorkOrderDetailContent', () {
    final detail = WorkOrderDetail(
      workOrder: _sampleOrder,
      tasks: [
        TaskDetail(
          id: TaskId('t1'),
          workOrderId: 'wo1',
          serviceName: 'Cambio de pastillas',
          mechanicName: 'Andrés Vílchez',
          status: TaskStatus.assigned,
          description: 'Cambio de pastillas',
          price: Money.of('180.00', Money.pen),
          totalPausedSeconds: 0,
        ),
      ],
      proposals: const [
        Proposal(
          id: 'p1',
          workOrderId: 'wo1',
          description: 'Disco rayado',
          severity: ProposalSeverity.critical,
          status: ProposalStatus.pendingReview,
        ),
      ],
      intakeImages: const [],
    );

    testWidgets('cargado sin historias excluidas (US29/US35/US36/US37-39/US40)', (tester) async {
      await _pump(
        tester,
        WorkOrderDetailContent(
          state: WorkOrderDetailUiState(
            isLoading: false,
            detail: detail,
            services: const [_sampleService],
            canUpdateWorkOrder: true,
            canReadQuotation: true,
            canSendQuotation: true,
            canReadPartMovements: true,
            canResolveProposals: true,
            canOpenObd: true,
          ),
          actions: const WorkOrderDetailActions(),
        ),
      );

      expect(find.text('Rosa Quispe Mamani'), findsOneWidget);
      expect(find.text('Cambio de pastillas'), findsOneWidget);
      expect(find.text('Eliminar tarea'), findsOneWidget);
      expect(find.text('Movimientos de repuestos'), findsOneWidget);
      expect(find.text('Diagnóstico OBD-II'), findsOneWidget);
      // Excluidas: rentabilidad (US35), liquidación IGV (US36), cobro (US37-39), reanudar suspensión (US29)
      expect(find.text('Rentabilidad'), findsNothing);
      expect(find.text('IGV 18 %'), findsNothing);
      expect(find.text('Cobrar y entregar'), findsNothing);
      expect(find.text('Reanudar tarea'), findsNothing);
      await _teardown(tester);
    });

    testWidgets('error cuando no hay detalle', (tester) async {
      await _pump(
        tester,
        WorkOrderDetailContent(
          state: const WorkOrderDetailUiState(isLoading: false, error: UiText.dynamic('No cargó')),
          actions: const WorkOrderDetailActions(),
        ),
      );
      expect(find.text('No cargó'), findsOneWidget);
      await _teardown(tester);
    });
  });

  group('OpenWorkOrder / ReportFinding / IntakeGallery / Proposals / Services', () {
    testWidgets('OpenWorkOrderContent cargado y sin permiso', (tester) async {
      await _pump(
        tester,
        OpenWorkOrderContent(
          state: const OpenWorkOrderUiState(
            canCreate: true,
            isLoadingCatalog: false,
            services: [_sampleService],
          ),
          onBack: () {},
          onMileageChange: (_) {},
          onFuelChange: (_) {},
          onReasonChange: (_) {},
          onToggleService: (_) {},
          onMechanicChange: (_) {},
          onRetryCatalog: () {},
          onSubmit: () {},
        ),
      );
      expect(find.text('Abrir orden'), findsNWidgets(2));
      expect(find.text('Cambio de pastillas'), findsOneWidget);
      await _teardown(tester);
    });

    testWidgets('ReportFindingContent, IntakeGalleryContent, ProposalsPanelContent, ServicesCatalogContent', (
      tester,
    ) async {
      await _pump(
        tester,
        ReportFindingContent(
          state: const ReportFindingUiState(canCreate: true, isLoadingServices: false),
          onBack: () {},
          onDescriptionChange: (_) {},
          onSeverityChange: (_) {},
          onServiceChange: (_) {},
          onTakePhoto: () {},
          onRetryServices: () {},
          onSubmit: () {},
        ),
      );
      expect(find.text('Reportar hallazgo'), findsOneWidget);

      await _pump(
        tester,
        IntakeGalleryContent(
          state: const IntakeGalleryUiState(canRead: true, canUpload: true, isLoading: false),
          onBack: () {},
          onDone: () {},
          onOpenProposals: () {},
          onNoteChange: (_) {},
          onCapture: (_) {},
        ),
      );
      expect(find.text('Fotos de recepción'), findsOneWidget);

      await _pump(
        tester,
        ProposalsPanelContent(
          state: const ProposalsPanelUiState(isLoading: false, canReport: true),
          actions: const ProposalsPanelActions(),
          onSelectProposal: (_) {},
        ),
      );
      expect(find.text('Esta orden no tiene propuestas.'), findsOneWidget);

      await _pump(
        tester,
        ServicesCatalogContent(
          state: const ServicesCatalogUiState(
            isLoading: false,
            canRead: true,
            canManage: true,
            services: [_sampleService],
          ),
          onBack: () {},
          onRefresh: () async {},
          onSearchQueryChange: (_) {},
          onOpenCreate: () {},
          onOpenEdit: (_) {},
          onOpenDelete: (_) {},
        ),
      );
      expect(find.text('Servicios del taller'), findsOneWidget);
      expect(find.text('Cambio de pastillas'), findsOneWidget);
      await _teardown(tester);
    });
  });
}
