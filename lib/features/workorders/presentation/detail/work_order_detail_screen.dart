import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_navigation_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_plate.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/document_intents.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/money_format.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/state_sheet_host.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/part_option.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_product.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/proposal.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_audit.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_references.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/components/proposal_labels.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/detail/components/quotation_summary_section.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/detail/components/work_order_detail_dialogs.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/detail/work_order_detail_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/detail/work_order_detail_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/work_order_labels.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';

/// Ficha de una orden de trabajo: identidad en el panel, decisiones en ámbar, ciclo de vida, tareas con su
/// desglose (US22–23), propuestas por hallazgo (US14–15), fotos de recepción (US13), proforma (US24–25) y
/// movimientos de repuestos (US33 E2).
///
/// Sin las secciones de historias excluidas: suspensiones (US29), rentabilidad (US35), liquidación (US36),
/// cobro y entrega (US37–US39) y bahías (US40).
class WorkOrderDetailScreen extends StatefulWidget {
  final String workOrderId;

  const WorkOrderDetailScreen({super.key, required this.workOrderId});

  @override
  State<WorkOrderDetailScreen> createState() => _WorkOrderDetailScreenState();
}

class _WorkOrderDetailScreenState extends State<WorkOrderDetailScreen> {
  late final WorkOrderDetailViewModel viewModel = getIt<WorkOrderDetailViewModel>(
    param1: widget.workOrderId,
  );
  final AtelierHaptics _haptics = rememberAtelierHaptics();
  Object? _lastNotice;
  Object? _lastError;

  @override
  void initState() {
    super.initState();
    viewModel.addListener(_feedback);
  }

  void _feedback() {
    final state = viewModel.state;
    if (state.notice != null && !identical(state.notice, _lastNotice)) _haptics.confirm();
    if (state.error != null && !identical(state.error, _lastError)) _haptics.reject();
    _lastNotice = state.notice;
    _lastError = state.error;
  }

  @override
  void dispose() {
    viewModel.removeListener(_feedback);
    viewModel.dispose();
    super.dispose();
  }

  Future<void> _pushAndRefresh(AppRoute route, [Object? args]) async {
    await AppNavigator.push(context, route, args);
    if (!mounted) return;
    final s = viewModel.state;
    if (s.detail != null && !s.isLoading && !s.isBusy) {
      viewModel.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    final strings = AppLocalizations.of(context);
    final actions = WorkOrderDetailActions(
      onBack: () => Navigator.of(context).maybePop(),
      onRetry: vm.load,
      onCompleteIntake: (vehicleId, customerId, orderId) => _pushAndRefresh(
        AppRoute.openWorkOrder,
        OpenWorkOrderArgs(vehicleId: vehicleId, customerId: customerId, workOrderId: orderId),
      ),
      onOpenCheckout: () => _pushAndRefresh(AppRoute.workOrderCheckout, vm.workOrderId),
      onOpenObd: (vehicleId, plate) =>
          _pushAndRefresh(AppRoute.diagnosticsHub, DiagnosticsHubArgs(initialVehicleId: vehicleId)),
      onOpenTask: (orderId, taskId) =>
          _pushAndRefresh(AppRoute.taskDetail, TaskDetailArgs(workOrderId: orderId, taskId: taskId)),
      onOpenProposals: () => _pushAndRefresh(AppRoute.proposalsPanel, vm.workOrderId),
      onOpenGallery: () => _pushAndRefresh(AppRoute.intakeGallery, vm.workOrderId),
      onOpenAddTask: vm.onOpenAddTask,
      onDismissAddTask: vm.onDismissAddTask,
      onSelectTaskService: vm.onSelectTaskService,
      onAddTaskDescriptionChange: vm.onAddTaskDescriptionChange,
      onAddTaskPriceChange: vm.onAddTaskPriceChange,
      onSelectAddTaskMechanic: vm.onSelectAddTaskMechanic,
      onConfirmAddTask: vm.onConfirmAddTask,
      onOpenEditLabor: vm.onOpenEditLabor,
      onDismissEditLabor: vm.onDismissEditLabor,
      onEditLaborPriceChange: vm.onEditLaborPriceChange,
      onConfirmEditLabor: vm.onConfirmEditLabor,
      onOpenDeleteTask: vm.onOpenDeleteTask,
      onDismissDeleteTask: vm.onDismissDeleteTask,
      onConfirmDeleteTask: vm.onConfirmDeleteTask,
      onOpenChargePart: vm.onOpenChargePart,
      onDismissChargePart: vm.onDismissChargePart,
      onChargeQueryChange: vm.onChargeQueryChange,
      onSelectPart: vm.onSelectPart,
      onChargeQuantityChange: vm.onChargeQuantityChange,
      onConfirmChargePart: vm.onConfirmChargePart,
      onOpenEditPart: vm.onOpenEditPart,
      onOpenReturnPart: vm.onOpenReturnPart,
      onDismissPartEdit: vm.onDismissPartEdit,
      onPartEditQuantityChange: vm.onPartEditQuantityChange,
      onConfirmPartEdit: vm.onConfirmPartEdit,
      onGenerateQuotationPdf: vm.onGenerateQuotationPdf,
      onSharePdf: (file) async {
        final ok = await DocumentIntents.openPdf(file, strings.quotationShareChooser);
        if (!mounted) return;
        if (ok) {
          vm.onPdfHandled();
        } else {
          vm.onPdfOpenFailed();
        }
      },
      onDismissPdfPreview: vm.onPdfHandled,
      onSendQuotationEmail: vm.onSendQuotationEmail,
      onApproveQuotation: vm.onApproveQuotation,
      onOpenQuotationDecision: vm.onOpenQuotationDecision,
      onDismissQuotationDecision: vm.onDismissQuotationDecision,
      onOpenRejectQuotation: vm.onOpenRejectQuotation,
      onDismissRejectQuotation: vm.onDismissRejectQuotation,
      onRejectReasonChange: vm.onRejectReasonChange,
      onConfirmRejectQuotation: vm.onConfirmRejectQuotation,
      onOpenAssignMechanic: vm.onOpenAssignMechanic,
      onDismissAssignMechanic: vm.onDismissAssignMechanic,
      onConfirmAssignMechanic: vm.onConfirmAssignMechanic,
      onStartOrder: vm.onStartOrder,
      onCompleteWorkOrder: vm.onCompleteOrder,
      onOpenCancelOrder: vm.onOpenCancelOrder,
      onDismissCancelOrder: vm.onDismissCancelOrder,
      onCancelReasonChange: vm.onCancelReasonChange,
      onConfirmCancelOrder: vm.onConfirmCancelOrder,
      onOpenMovements: vm.onOpenMovements,
      onDismissMovements: vm.onDismissMovements,
    );

    return _OrderSheetHosts(
      viewModel: vm,
      actions: actions,
      child: ListenableBuilder(
        listenable: vm,
        builder: (context, _) => WorkOrderDetailContent(state: vm.state, actions: actions),
      ),
    );
  }
}

class _OrderSheetHosts extends StatelessWidget {
  final WorkOrderDetailViewModel viewModel;
  final WorkOrderDetailActions actions;
  final Widget child;

  const _OrderSheetHosts({required this.viewModel, required this.actions, required this.child});

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    return StateSheetHost<AddTaskForm>(
      listenable: vm,
      value: () => vm.state.addTaskForm,
      onDismiss: actions.onDismissAddTask,
      sheetBuilder: (context, _) => ListenableBuilder(
        listenable: vm,
        builder: (context, _) {
          final s = vm.state;
          final form = s.addTaskForm;
          if (form == null) return const SizedBox.shrink();
          return AddTaskSheet(
            form: form,
            services: s.services,
            mechanics: s.availableMechanics,
            isSaving: s.busyAction == WorkOrderDetailAction.addTask,
            invalidField: s.invalidField,
            error: s.error,
            onSelectService: actions.onSelectTaskService,
            onDescriptionChange: actions.onAddTaskDescriptionChange,
            onPriceChange: actions.onAddTaskPriceChange,
            onSelectMechanic: actions.onSelectAddTaskMechanic,
            onConfirm: actions.onConfirmAddTask,
          );
        },
      ),
      child: StateSheetHost<EditLaborForm>(
        listenable: vm,
        value: () => vm.state.editLaborForm,
        onDismiss: actions.onDismissEditLabor,
        sheetBuilder: (context, _) => ListenableBuilder(
          listenable: vm,
          builder: (context, _) {
            final s = vm.state;
            final form = s.editLaborForm;
            if (form == null) return const SizedBox.shrink();
            return EditLaborSheet(
              form: form,
              isSaving: s.busyAction == WorkOrderDetailAction.editLabor,
              invalidField: s.invalidField,
              error: s.error,
              onPriceChange: actions.onEditLaborPriceChange,
              onConfirm: actions.onConfirmEditLabor,
            );
          },
        ),
        child: StateSheetHost<TaskDetail>(
          listenable: vm,
          value: () => vm.state.deletingTask,
          onDismiss: actions.onDismissDeleteTask,
          sheetBuilder: (context, _) => ListenableBuilder(
            listenable: vm,
            builder: (context, _) {
              final s = vm.state;
              final task = s.deletingTask;
              if (task == null) return const SizedBox.shrink();
              return DeleteTaskSheet(
                taskTitle: s.taskTitle(task),
                hasProducts: task.products.isNotEmpty,
                isSaving: s.busyAction == WorkOrderDetailAction.deleteTask,
                error: s.error,
                onConfirm: actions.onConfirmDeleteTask,
                onDismiss: actions.onDismissDeleteTask,
              );
            },
          ),
          child: StateSheetHost<ChargeForm>(
            listenable: vm,
            value: () => vm.state.chargeForm,
            onDismiss: actions.onDismissChargePart,
            sheetBuilder: (context, _) => ListenableBuilder(
              listenable: vm,
              builder: (context, _) {
                final s = vm.state;
                final form = s.chargeForm;
                if (form == null) return const SizedBox.shrink();
                return OrderChargePartSheet(
                  form: form,
                  isSaving: s.busyAction == WorkOrderDetailAction.chargePart,
                  invalidField: s.invalidField,
                  error: s.error,
                  onQueryChange: actions.onChargeQueryChange,
                  onSelect: actions.onSelectPart,
                  onQuantityChange: actions.onChargeQuantityChange,
                  onConfirm: actions.onConfirmChargePart,
                  onDismiss: actions.onDismissChargePart,
                );
              },
            ),
            child: StateSheetHost<PartEditForm>(
              listenable: vm,
              value: () => vm.state.partEdit,
              onDismiss: actions.onDismissPartEdit,
              sheetBuilder: (context, _) => ListenableBuilder(
                listenable: vm,
                builder: (context, _) {
                  final s = vm.state;
                  final form = s.partEdit;
                  if (form == null) return const SizedBox.shrink();
                  return OrderPartEditSheet(
                    form: form,
                    isSaving:
                        s.busyAction == WorkOrderDetailAction.editPart ||
                        s.busyAction == WorkOrderDetailAction.removePart,
                    invalidField: s.invalidField,
                    error: s.error,
                    onQuantityChange: actions.onPartEditQuantityChange,
                    onConfirm: actions.onConfirmPartEdit,
                    onDismiss: actions.onDismissPartEdit,
                  );
                },
              ),
              child: StateSheetHost<bool>(
                listenable: vm,
                value: () => vm.state.showQuotationDecision ? true : null,
                onDismiss: actions.onDismissQuotationDecision,
                sheetBuilder: (context, _) => ListenableBuilder(
                  listenable: vm,
                  builder: (context, _) {
                    final s = vm.state;
                    return QuotationDecisionSheet(
                      isApproving: s.busyAction == WorkOrderDetailAction.approveQuotation,
                      isBusy: s.isBusy || !s.isOnline,
                      isOnline: s.isOnline,
                      error: s.error,
                      onApprove: actions.onApproveQuotation,
                      onReject: actions.onOpenRejectQuotation,
                    );
                  },
                ),
                child: StateSheetHost<RejectQuotationForm>(
                  listenable: vm,
                  value: () => vm.state.rejectForm,
                  onDismiss: actions.onDismissRejectQuotation,
                  sheetBuilder: (context, _) => ListenableBuilder(
                    listenable: vm,
                    builder: (context, _) {
                      final s = vm.state;
                      final form = s.rejectForm;
                      if (form == null) return const SizedBox.shrink();
                      return RejectQuotationSheet(
                        form: form,
                        isSaving: s.busyAction == WorkOrderDetailAction.rejectQuotation,
                        invalidField: s.invalidField,
                        error: s.error,
                        onReasonChange: actions.onRejectReasonChange,
                        onConfirm: actions.onConfirmRejectQuotation,
                        onDismiss: actions.onDismissRejectQuotation,
                      );
                    },
                  ),
                  child: StateSheetHost<CancelOrderForm>(
                    listenable: vm,
                    value: () => vm.state.cancelForm,
                    onDismiss: actions.onDismissCancelOrder,
                    sheetBuilder: (context, _) => ListenableBuilder(
                      listenable: vm,
                      builder: (context, _) {
                        final s = vm.state;
                        final form = s.cancelForm;
                        if (form == null) return const SizedBox.shrink();
                        return CancelOrderSheet(
                          form: form,
                          isSaving: s.busyAction == WorkOrderDetailAction.cancelOrder,
                          invalidField: s.invalidField,
                          error: s.error,
                          onReasonChange: actions.onCancelReasonChange,
                          onConfirm: actions.onConfirmCancelOrder,
                          onDismiss: actions.onDismissCancelOrder,
                        );
                      },
                    ),
                    child: StateSheetHost<File>(
                      listenable: vm,
                      value: () => vm.state.generatedPdf,
                      onDismiss: actions.onDismissPdfPreview,
                      sheetBuilder: (context, file) => PdfPreviewSheet(
                        pdfFile: file,
                        breakdown: vm.state.breakdown,
                        onShare: () => actions.onSharePdf(file),
                        onDismiss: actions.onDismissPdfPreview,
                      ),
                      child: StateSheetHost<TaskDetail>(
                        listenable: vm,
                        value: () => vm.state.assigningMechanicTask,
                        onDismiss: actions.onDismissAssignMechanic,
                        sheetBuilder: (context, _) => ListenableBuilder(
                          listenable: vm,
                          builder: (context, _) {
                            final s = vm.state;
                            final task = s.assigningMechanicTask;
                            if (task == null) return const SizedBox.shrink();
                            return AssignMechanicSheet(
                              taskTitle: s.taskTitle(task),
                              currentMechanicId: task.mechanicId,
                              mechanics: s.availableMechanics,
                              isSaving: s.busyAction == WorkOrderDetailAction.assignMechanic,
                              error: s.error,
                              onSelectMechanic: actions.onConfirmAssignMechanic,
                              onDismiss: actions.onDismissAssignMechanic,
                            );
                          },
                        ),
                        child: StateSheetHost<OnDemand<List<PartMovement>>>(
                          listenable: vm,
                          value: () => vm.state.movements,
                          onDismiss: actions.onDismissMovements,
                          sheetBuilder: (context, _) => ListenableBuilder(
                            listenable: vm,
                            builder: (context, _) {
                              final s = vm.state;
                              final data = s.movements;
                              if (data == null) return const SizedBox.shrink();
                              return PartMovementsSheet(
                                state: data,
                                partName: (id) => s.partNamesById[id],
                                onRetry: actions.onOpenMovements,
                                onDismiss: actions.onDismissMovements,
                              );
                            },
                          ),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WorkOrderDetailActions {
  final VoidCallback onBack;
  final Future<void> Function() onRetry;
  final void Function(String vehicleId, String customerId, String workOrderId) onCompleteIntake;
  final VoidCallback onOpenCheckout;
  final void Function(String vehicleId, String? plate) onOpenObd;
  final void Function(String workOrderId, String taskId) onOpenTask;
  final VoidCallback onOpenProposals;
  final VoidCallback onOpenGallery;
  final VoidCallback onOpenAddTask;
  final VoidCallback onDismissAddTask;
  final ValueChanged<ServiceOption> onSelectTaskService;
  final ValueChanged<String> onAddTaskDescriptionChange;
  final ValueChanged<String> onAddTaskPriceChange;
  final ValueChanged<String?> onSelectAddTaskMechanic;
  final VoidCallback onConfirmAddTask;
  final ValueChanged<TaskDetail> onOpenEditLabor;
  final VoidCallback onDismissEditLabor;
  final ValueChanged<String> onEditLaborPriceChange;
  final VoidCallback onConfirmEditLabor;
  final ValueChanged<TaskDetail> onOpenDeleteTask;
  final VoidCallback onDismissDeleteTask;
  final VoidCallback onConfirmDeleteTask;
  final ValueChanged<TaskId> onOpenChargePart;
  final VoidCallback onDismissChargePart;
  final ValueChanged<String> onChargeQueryChange;
  final ValueChanged<PartOption> onSelectPart;
  final ValueChanged<String> onChargeQuantityChange;
  final VoidCallback onConfirmChargePart;
  final void Function(TaskId taskId, TaskProduct product) onOpenEditPart;
  final void Function(TaskId taskId, TaskProduct product) onOpenReturnPart;
  final VoidCallback onDismissPartEdit;
  final ValueChanged<String> onPartEditQuantityChange;
  final VoidCallback onConfirmPartEdit;
  final VoidCallback onGenerateQuotationPdf;
  final ValueChanged<File> onSharePdf;
  final VoidCallback onDismissPdfPreview;
  final VoidCallback onSendQuotationEmail;
  final VoidCallback onApproveQuotation;
  final VoidCallback onOpenQuotationDecision;
  final VoidCallback onDismissQuotationDecision;
  final VoidCallback onOpenRejectQuotation;
  final VoidCallback onDismissRejectQuotation;
  final ValueChanged<String> onRejectReasonChange;
  final VoidCallback onConfirmRejectQuotation;
  final ValueChanged<TaskDetail> onOpenAssignMechanic;
  final VoidCallback onDismissAssignMechanic;
  final ValueChanged<MechanicOption> onConfirmAssignMechanic;
  final VoidCallback onStartOrder;
  final VoidCallback onCompleteWorkOrder;
  final VoidCallback onOpenCancelOrder;
  final VoidCallback onDismissCancelOrder;
  final ValueChanged<String> onCancelReasonChange;
  final VoidCallback onConfirmCancelOrder;
  final VoidCallback onOpenMovements;
  final VoidCallback onDismissMovements;

  static void _noop() {}
  static void _noop1(Object? _) {}
  static void _noop2(Object? a, Object? b) {}
  static void _noop3(Object? a, Object? b, Object? c) {}
  static Future<void> _noopRefresh() async {}

  const WorkOrderDetailActions({
    this.onBack = _noop,
    this.onRetry = _noopRefresh,
    this.onCompleteIntake = _noop3,
    this.onOpenCheckout = _noop,
    this.onOpenObd = _noop2,
    this.onOpenTask = _noop2,
    this.onOpenProposals = _noop,
    this.onOpenGallery = _noop,
    this.onOpenAddTask = _noop,
    this.onDismissAddTask = _noop,
    this.onSelectTaskService = _noop1,
    this.onAddTaskDescriptionChange = _noop1,
    this.onAddTaskPriceChange = _noop1,
    this.onSelectAddTaskMechanic = _noop1,
    this.onConfirmAddTask = _noop,
    this.onOpenEditLabor = _noop1,
    this.onDismissEditLabor = _noop,
    this.onEditLaborPriceChange = _noop1,
    this.onConfirmEditLabor = _noop,
    this.onOpenDeleteTask = _noop1,
    this.onDismissDeleteTask = _noop,
    this.onConfirmDeleteTask = _noop,
    this.onOpenChargePart = _noop1,
    this.onDismissChargePart = _noop,
    this.onChargeQueryChange = _noop1,
    this.onSelectPart = _noop1,
    this.onChargeQuantityChange = _noop1,
    this.onConfirmChargePart = _noop,
    this.onOpenEditPart = _noop2,
    this.onOpenReturnPart = _noop2,
    this.onDismissPartEdit = _noop,
    this.onPartEditQuantityChange = _noop1,
    this.onConfirmPartEdit = _noop,
    this.onGenerateQuotationPdf = _noop,
    this.onSharePdf = _noop1,
    this.onDismissPdfPreview = _noop,
    this.onSendQuotationEmail = _noop,
    this.onApproveQuotation = _noop,
    this.onOpenQuotationDecision = _noop,
    this.onDismissQuotationDecision = _noop,
    this.onOpenRejectQuotation = _noop,
    this.onDismissRejectQuotation = _noop,
    this.onRejectReasonChange = _noop1,
    this.onConfirmRejectQuotation = _noop,
    this.onOpenAssignMechanic = _noop1,
    this.onDismissAssignMechanic = _noop,
    this.onConfirmAssignMechanic = _noop1,
    this.onStartOrder = _noop,
    this.onCompleteWorkOrder = _noop,
    this.onOpenCancelOrder = _noop,
    this.onDismissCancelOrder = _noop,
    this.onCancelReasonChange = _noop1,
    this.onConfirmCancelOrder = _noop,
    this.onOpenMovements = _noop,
    this.onDismissMovements = _noop,
  });
}

class WorkOrderDetailContent extends StatelessWidget {
  final WorkOrderDetailUiState state;
  final WorkOrderDetailActions actions;

  const WorkOrderDetailContent({super.key, required this.state, required this.actions});

  @override
  Widget build(BuildContext context) {
    final detail = state.detail;
    final order = detail?.workOrder;
    final headerOrder = order ?? state.cachedOrder;
    final strings = AppLocalizations.of(context);
    return Scaffold(
      floatingActionButton: state.canCheckout
          ? AtelierButton(
              text: strings.ordersCheckout,
              icon: Icons.payments_outlined,
              onClick: actions.onOpenCheckout,
            )
          : null,
      body: DelayedLoading(
        loading: state.isLoading && detail == null,
        builder: (context, showSkeleton) => RefreshIndicator(
          onRefresh: actions.onRetry,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: 96 + FloatingBarInset.of(context)),
            children: [
              _OrderPanel(
                order: headerOrder,
                loading: showSkeleton && headerOrder == null,
                onBack: actions.onBack,
              ),
              AtelierRefreshBar(visible: state.isLoading && detail != null),
              if (detail == null || order == null)
                ..._emptyOrError(context, strings, showSkeleton)
              else
                ..._orderContent(context, strings, detail, order),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _emptyOrError(
    BuildContext context,
    AppLocalizations strings,
    bool showSkeleton,
  ) {
    final error = state.error;
    if (error != null) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: state.isOnline
              ? AtelierErrorState(message: error.asString(strings), onRetry: actions.onRetry)
              : AtelierOfflineState(onRetry: actions.onRetry),
        ),
      ];
    }
    if (showSkeleton) {
      return [
        for (var i = 0; i < 4; i++)
          const AtelierListRow(title: 'Tarea de la orden', subtitle: 'Mecánico', loading: true),
      ];
    }
    return const [];
  }

  List<Widget> _orderContent(
    BuildContext context,
    AppLocalizations strings,
    WorkOrderDetail detail,
    WorkOrder order,
  ) {
    final notice = state.notice;
    final error = state.error;
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            if (notice != null)
              AtelierBanner(
                message: notice.asString(strings),
                icon: Icons.check_circle_outline,
                kind: BannerKind.ok,
              ),
            if (!state.hasOpenSheet && error != null)
              AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
            if (state.isDraft && (order.mileageIn == null || order.mileageIn == 0)) ...[
              AtelierBanner(
                title: strings.orderIntakeIncompleteTitle,
                message: strings.orderIntakeIncompleteBody,
                icon: Icons.info_outline,
                kind: BannerKind.wait,
              ),
              AtelierButton(
                text: strings.orderCompleteIntakeBtn,
                onClick: () =>
                    actions.onCompleteIntake(order.vehicleId, order.customerId, order.id.value),
                style: AtelierButtonStyle.tonal,
              ),
            ],
          ],
        ),
      ),
      ..._decisions(strings, detail, order),
      ..._lifecycle(strings),
      if (state.canOpenObd)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: AtelierButton(
            text: strings.ordersObdDiagnosticBtn,
            onClick: () => actions.onOpenObd(order.vehicleId, order.plate),
            style: AtelierButtonStyle.outlined,
            icon: Icons.bluetooth_connected_outlined,
          ),
        ),
      ..._orderData(strings, order),
      ..._tasks(strings, detail, order),
      ..._proposals(strings, detail),
      ..._photos(context, strings, detail),
      ..._quotation(strings),
      ..._costs(context, strings),
    ];
  }

  /// "Esperan tu decisión": propuestas en revisión y proforma sin respuesta (sin suspensiones US29).
  List<Widget> _decisions(AppLocalizations strings, WorkOrderDetail detail, WorkOrder order) {
    final pendingProposals = state.canResolveProposals
        ? detail.proposals.where((p) => p.status == ProposalStatus.pendingReview).toList()
        : const <Proposal>[];
    final quotationPending = state.isDraft && state.canApproveQuotation;
    final count = pendingProposals.length + (quotationPending ? 1 : 0);
    if (count == 0) return const [];
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AtelierSectionHeader(title: strings.ordersSectionDecisions, count: count),
      ),
      for (final proposal in pendingProposals)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: AtelierDecisionRow(
            title: strings.ordersDecisionProposal(proposal.description),
            subtitle: proposal.severity?.label(strings),
            plate: order.plate,
            onClick: actions.onOpenProposals,
          ),
        ),
      if (quotationPending)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: AtelierDecisionRow(
            title: strings.ordersQuotationDecisionTitle,
            subtitle: strings.ordersQuotationDecisionRowHint,
            plate: order.plate,
            amount: state.breakdown?.totalAmount.format(),
            onClick: actions.onOpenQuotationDecision,
          ),
        ),
    ];
  }

  List<Widget> _lifecycle(AppLocalizations strings) {
    final showStart = state.canUpdateWorkOrder && state.isDraft;
    final showComplete = state.canUpdateWorkOrder && state.status == WorkOrderStatus.inProgress;
    final showCancel = state.canCancelWorkOrder && state.isEditableOrder;
    if (!showStart && !showComplete && !showCancel) return const [];
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            if (showStart)
              AtelierButton(
                text: strings.ordersActionStart,
                onClick: actions.onStartOrder,
                enabled: state.canStartOrder,
                loading: state.busyAction == WorkOrderDetailAction.startOrder,
              ),
            if (showComplete)
              AtelierButton(
                text: strings.ordersActionComplete,
                onClick: actions.onCompleteWorkOrder,
                enabled: state.canCompleteOrder,
                loading: state.busyAction == WorkOrderDetailAction.completeOrder,
              ),
            if (showCancel)
              AtelierButton(
                text: strings.ordersActionCancel,
                onClick: actions.onOpenCancelOrder,
                style: AtelierButtonStyle.destructive,
                enabled: state.canCancelOrder,
              ),
            if (!state.isOnline) const AtelierRequiresConnection(),
          ],
        ),
      ),
    ];
  }

  /// Bahía (solo lectura: US40 está fuera), kilometraje y diagnóstico de ingreso.
  List<Widget> _orderData(AppLocalizations strings, WorkOrder order) {
    final mileage = order.mileageIn != null && order.mileageIn! > 0 ? order.mileageIn : null;
    final rawDiag = order.diagnosticSummary;
    final diagnostic = rawDiag != null && rawDiag.trim().isNotEmpty ? rawDiag : null;
    final showBay = order.bayName != null;
    if (!showBay && mileage == null && diagnostic == null) return const [];
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AtelierSectionHeader(title: strings.ordersSectionData),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: AtelierSurface(
          tier: SurfaceTier.card,
          shape: cardLargeShape,
          child: Column(
            children: [
              if (showBay)
                AtelierListRow(
                  title: order.bayName!,
                  subtitle: strings.ordersBayLabel,
                  showDivider: mileage != null || diagnostic != null,
                ),
              if (mileage != null)
                AtelierListRow(
                  title: strings.receptionVehicleMileageKm(mileage),
                  subtitle: strings.ordersMileageLabel,
                  showDivider: diagnostic != null,
                ),
              if (diagnostic != null)
                AtelierListRow(
                  title: diagnostic,
                  subtitle: strings.ordersDiagnosticLabel,
                  showDivider: false,
                ),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _tasks(AppLocalizations strings, WorkOrderDetail detail, WorkOrder order) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AtelierSectionHeader(title: strings.orderTasksTitle, count: detail.tasks.length),
      ),
      if (detail.tasks.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AtelierEmptyState(text: strings.orderTasksEmpty),
        )
      else
        for (final task in detail.tasks)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: AtelierSurface(
              tier: SurfaceTier.card,
              shape: cardLargeShape,
              child: TaskBlock(
                task: task,
                state: state,
                onOpenTask: () => actions.onOpenTask(order.id.value, task.id.value),
                onEditLabor: () => actions.onOpenEditLabor(task),
                onAddPart: () => actions.onOpenChargePart(task.id),
                onEditPart: (product) => actions.onOpenEditPart(task.id, product),
                onReturnPart: (product) => actions.onOpenReturnPart(task.id, product),
                onAssignMechanic: () => actions.onOpenAssignMechanic(task),
                onDeleteTask: () => actions.onOpenDeleteTask(task),
                showOuterDivider: false,
              ),
            ),
          ),
      if (state.canModifyTasks && state.services.isNotEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: AtelierButton(
            text: strings.orderAddTask,
            onClick: actions.onOpenAddTask,
            style: AtelierButtonStyle.outlined,
            icon: Icons.add,
          ),
        ),
    ];
  }

  List<Widget> _proposals(AppLocalizations strings, WorkOrderDetail detail) {
    return [
      Padding(
        padding: const EdgeInsets.only(left: 16, right: 8),
        child: AtelierSectionHeader(
          title: strings.ordersSectionProposals,
          count: detail.proposals.length,
          action: AtelierButton(
            text: strings.ordersSeeAll,
            onClick: actions.onOpenProposals,
            style: AtelierButtonStyle.text,
          ),
        ),
      ),
      if (detail.proposals.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AtelierEmptyState(text: strings.proposalsEmpty),
        )
      else
        for (final proposal in detail.proposals)
          AtelierListRow(
            title: proposal.description,
            subtitle: proposal.severity?.label(strings),
            onClick: actions.onOpenProposals,
            trailing: proposal.status != null
                ? AtelierChip(
                    text: proposal.status!.label(strings),
                    kind: proposal.status!.chipKind,
                  )
                : null,
          ),
    ];
  }

  List<Widget> _photos(BuildContext context, AppLocalizations strings, WorkOrderDetail detail) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AtelierSectionHeader(title: strings.ordersSectionPhotos),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: AtelierSurface(
          tier: SurfaceTier.card,
          shape: cardLargeShape,
          child: AtelierListRow(
            title: strings.orderOpenGallery,
            subtitle: strings.ordersPhotosCount(detail.intakeImages.length),
            showDivider: false,
            onClick: actions.onOpenGallery,
            trailing: const _ChevronIcon(),
          ),
        ),
      ),
    ];
  }

  List<Widget> _quotation(AppLocalizations strings) {
    final breakdown = state.breakdown;
    if (breakdown == null) return const [];
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AtelierSectionHeader(title: strings.ordersSectionQuotation),
      ),
      Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QuotationSection(
            breakdown: breakdown,
            canGeneratePdf: state.canGeneratePdf,
            canEmailQuotation: state.canEmailQuotation,
            showPdfActions: state.canReadQuotation,
            showEmailAction: state.canSendQuotation,
            busyAction: state.busyAction,
            onGeneratePdf: actions.onGenerateQuotationPdf,
            onSendEmail: actions.onSendQuotationEmail,
          ),
          if (!state.isOnline && (state.canReadQuotation || state.canSendQuotation))
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: AtelierRequiresConnection(),
            ),
        ],
      ),
    ];
  }

  /// Solo movimientos de repuestos (US33 E2); rentabilidad (US35) queda fuera.
  List<Widget> _costs(BuildContext context, AppLocalizations strings) {
    if (!state.canReadPartMovements) return const [];
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AtelierSectionHeader(title: strings.ordersSectionCosts),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: AtelierSurface(
          tier: SurfaceTier.card,
          shape: cardLargeShape,
          child: AtelierListRow(
            title: strings.ordersMovementsTitle,
            subtitle: strings.ordersMovementsHint,
            showDivider: false,
            onClick: state.isOnline ? actions.onOpenMovements : null,
            trailing: const _ChevronIcon(),
          ),
        ),
      ),
      if (!state.isOnline)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: AtelierRequiresConnection(),
        ),
    ];
  }
}

class _OrderPanel extends StatelessWidget {
  final WorkOrder? order;
  final bool loading;
  final VoidCallback onBack;

  const _OrderPanel({required this.order, required this.loading, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final current = order;
    if (current == null) {
      return AtelierFichaPanel(
        onBack: onBack,
        title: strings.orderDetailTitle,
        subtitle: loading ? 'Cargando ficha…' : null,
        identity: loading
            ? const Bone(loading: true, child: AtelierPlate(plate: 'BKR418', size: PlateSize.l))
            : null,
      );
    }
    final numberLabel = current.internalNumber != null
        ? strings.ordersOrderNumber(current.internalNumber!)
        : strings.ordersNoNumber;
    final subtitleParts = [
      if (current.customerName != null) numberLabel,
      ?current.bayName,
      if (current.totalAmount != null) strings.ordersTotal(current.totalAmount!.format()),
    ];
    final plate = current.plate;
    return AtelierFichaPanel(
      onBack: onBack,
      title: current.customerName ?? numberLabel,
      subtitle: subtitleParts.isEmpty ? null : subtitleParts.join(' · '),
      identity: plate != null ? AtelierPlate(plate: plate, size: PlateSize.l) : null,
      status: AtelierChip(
        text: workOrderStatusLabel(strings, current.status),
        kind: workOrderStatusChipKind(current.status),
      ),
    );
  }
}

class _ChevronIcon extends StatelessWidget {
  const _ChevronIcon();

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.chevron_right_outlined, color: context.atelier.inkSecondary);
  }
}
