import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_density.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_grouped_card.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_plate.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/icon/atelier_icons.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/state_sheet_host.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/detail/components/chronometer_timer.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/detail/components/part_sheets.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/detail/components/task_evidence_section.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/detail/components/task_photo_capture.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/detail/components/task_parts_section.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/detail/components/task_pit_action_dock.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/detail/components/task_sheets.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/detail/task_detail_actions.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/detail/task_detail_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/detail/task_detail_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/task_labels.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';

/// US27, US23, US33: detalle de tarea con panel Ficha, cronómetro tabular, controles grandes de fosa, reapertura
/// e imputación FIFO de repuestos. Incluye evidencia fotográfica (US28), suspensión (US29) y cierre (US30).
class TaskDetailScreen extends StatefulWidget {
  final TaskDetailArgs args;

  const TaskDetailScreen({super.key, required this.args});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late final TaskDetailViewModel viewModel = getIt<TaskDetailViewModel>(param1: widget.args);
  Object? _lastNotice;
  Object? _lastError;

  @override
  void initState() {
    super.initState();
    viewModel.addListener(_haptics);
  }

  void _haptics() {
    final state = viewModel.state;
    if (state.notice != null && !identical(state.notice, _lastNotice)) {
      rememberAtelierHaptics().confirm();
    }
    if (state.error != null && !identical(state.error, _lastError)) {
      rememberAtelierHaptics().reject();
    }
    _lastNotice = state.notice;
    _lastError = state.error;
  }

  @override
  void dispose() {
    viewModel.removeListener(_haptics);
    viewModel.dispose();
    super.dispose();
  }

  /// Hoja dirigida por el estado; en piso y fosa los objetivos táctiles son de 56 dp también dentro de ella.
  Widget _sheet<T extends Object>({
    required T? Function() value,
    required VoidCallback onDismiss,
    required Widget Function(BuildContext context, T value) builder,
    required Widget child,
  }) {
    return StateSheetHost<T>(
      listenable: viewModel,
      value: value,
      onDismiss: onDismiss,
      sheetBuilder: (context, value) =>
          AtelierMinTouchTarget(value: AtelierMinTouchTarget.floor, child: builder(context, value)),
      child: child,
    );
  }

  /// Hojas de cierre (US30), suspensión (US29) y evidencia (US28) alrededor de la pantalla.
  Widget _storySheets({required Widget child}) {
    final vm = viewModel;
    return _sheet<CompleteTaskForm>(
      value: () => vm.state.completeForm,
      onDismiss: vm.onCompleteDismiss,
      builder: (context, form) => CompleteTaskSheet(
        form: form,
        isOnline: vm.state.isOnline,
        isSaving: vm.state.busyAction == TaskAction.complete,
        invalidField: vm.state.invalidField,
        error: vm.state.error,
        onHoursChange: vm.onCompleteHoursChange,
        onNotesChange: vm.onCompleteNotesChange,
        onConfirm: vm.onCompleteConfirm,
        onDismiss: vm.onCompleteDismiss,
      ),
      child: _sheet<RequestSuspensionForm>(
        value: () => vm.state.suspensionForm,
        onDismiss: vm.onRequestSuspensionDismiss,
        builder: (context, form) => RequestSuspensionSheet(
          form: form,
          isOnline: vm.state.isOnline,
          isSaving: vm.state.busyAction == TaskAction.requestSuspension,
          invalidField: vm.state.invalidField,
          error: vm.state.error,
          onDescriptionChange: vm.onSuspensionDescriptionChange,
          onPartQueryChange: vm.onSuspensionPartQueryChange,
          onPartSelect: vm.onSuspensionPartSelect,
          onPartClear: vm.onSuspensionPartClear,
          onConfirm: vm.onRequestSuspensionConfirm,
          onDismiss: vm.onRequestSuspensionDismiss,
        ),
        child: _sheet<ReviewSuspensionForm>(
          value: () => vm.state.reviewForm,
          onDismiss: vm.onReviewSuspensionDismiss,
          builder: (context, _) => ReviewSuspensionSheet(
            reason: vm.state.pendingSuspensionReason,
            requestedAt: vm.state.pendingSuspensionRequestedAt,
            isOnline: vm.state.isOnline,
            busyAction: vm.state.busyAction,
            error: vm.state.error,
            onApprove: vm.onApproveSuspension,
            onReject: vm.onRejectSuspension,
            onDismiss: vm.onReviewSuspensionDismiss,
          ),
          child: _sheet<ResumeSuspensionForm>(
            value: () => vm.state.resumeForm,
            onDismiss: vm.onResumeSuspendedDismiss,
            builder: (context, _) => ResumeSuspensionSheet(
              isOnline: vm.state.isOnline,
              isSaving: vm.state.busyAction == TaskAction.resumeSuspended,
              error: vm.state.error,
              onConfirm: vm.onResumeSuspendedConfirm,
              onDismiss: vm.onResumeSuspendedDismiss,
            ),
            child: _sheet<EvidenceCaptureForm>(
              value: () => vm.state.evidenceForm,
              onDismiss: vm.onEvidenceDismiss,
              builder: (context, form) => EvidenceCaptureSheet(
                form: form,
                isSaving: vm.state.busyAction == TaskAction.attachEvidence,
                invalidField: vm.state.invalidField,
                error: vm.state.error,
                onKindChange: vm.onEvidenceKindChange,
                onNoteChange: vm.onEvidenceNoteChange,
                onCaptured: vm.onEvidenceCaptured,
                onDenied: vm.onCameraDenied,
                onDismiss: vm.onEvidenceDismiss,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _storySheets(child: _baseSheets(context));

  Widget _baseSheets(BuildContext context) {
    final vm = viewModel;
    return _sheet<PauseForm>(
      value: () => vm.state.pauseForm,
      onDismiss: vm.onPauseDismiss,
      builder: (context, _) => PauseReasonSheet(
        isOnline: vm.state.isOnline,
        isSaving: vm.state.busyAction == TaskAction.pause,
        onSelect: vm.onPause,
        onDismiss: vm.onPauseDismiss,
      ),
      child: _sheet<ChargeForm>(
        value: () => vm.state.chargeForm,
        onDismiss: vm.onChargeDismiss,
        builder: (context, form) => ChargePartSheet(
          form: form,
          isSaving: vm.state.busyAction == TaskAction.charge,
          invalidField: vm.state.invalidField,
          error: vm.state.error,
          onQueryChange: vm.onChargeQueryChange,
          onSelect: vm.onPartSelect,
          onQuantityChange: vm.onChargeQuantityChange,
          onConfirm: vm.onChargeConfirm,
          onDismiss: vm.onChargeDismiss,
        ),
        child: _sheet<PartEditForm>(
          value: () => vm.state.partEdit,
          onDismiss: vm.onPartEditDismiss,
          builder: (context, form) => PartEditSheet(
            form: form,
            isSaving:
                vm.state.busyAction == TaskAction.editPart || vm.state.busyAction == TaskAction.removePart,
            invalidField: vm.state.invalidField,
            error: vm.state.error,
            onQuantityChange: vm.onPartQuantityChange,
            onConfirm: vm.onPartEditConfirm,
            onDismiss: vm.onPartEditDismiss,
          ),
          child: _sheet<ReopenTaskForm>(
            value: () => vm.state.reopenForm,
            onDismiss: vm.onReopenDismiss,
            builder: (context, form) => ReopenTaskSheet(
              form: form,
              isOnline: vm.state.isOnline,
              isSaving: vm.state.busyAction == TaskAction.reopen,
              error: vm.state.error,
              onReasonChange: vm.onReopenReasonChange,
              onConfirm: vm.onReopenConfirm,
              onDismiss: vm.onReopenDismiss,
            ),
            child: ListenableBuilder(
              listenable: vm,
              builder: (context, _) => TaskDetailContent(
                state: vm.state,
                actions: TaskDetailActions(
                  onCompleteClick: vm.onCompleteClick,
                  onRequestSuspensionClick: vm.onRequestSuspensionClick,
                  onReviewSuspensionClick: vm.onReviewSuspensionClick,
                  onResumeSuspendedClick: vm.onResumeSuspendedClick,
                  onAddEvidenceClick: vm.onAddEvidenceClick,
                  onBack: () => Navigator.of(context).maybePop(),
                  onRetry: vm.load,
                  onStart: vm.onStart,
                  onPauseClick: vm.onPauseClick,
                  onPauseDismiss: vm.onPauseDismiss,
                  onPause: vm.onPause,
                  onReopenClick: vm.onReopenClick,
                  onReopenDismiss: vm.onReopenDismiss,
                  onReopenReasonChange: vm.onReopenReasonChange,
                  onReopenConfirm: vm.onReopenConfirm,
                  onChargeClick: vm.onChargeClick,
                  onChargeDismiss: vm.onChargeDismiss,
                  onChargeQueryChange: vm.onChargeQueryChange,
                  onPartSelect: vm.onPartSelect,
                  onChargeQuantityChange: vm.onChargeQuantityChange,
                  onChargeConfirm: vm.onChargeConfirm,
                  onEditPartClick: vm.onEditPartClick,
                  onReturnPartClick: vm.onReturnPartClick,
                  onPartEditDismiss: vm.onPartEditDismiss,
                  onPartQuantityChange: vm.onPartQuantityChange,
                  onPartEditConfirm: vm.onPartEditConfirm,
                  onReportFinding: (workOrderId) =>
                      AppNavigator.push(context, AppRoute.reportFinding, workOrderId),
                  onOpenObd: (vehicleId, plate) => AppNavigator.push(
                    context,
                    AppRoute.diagnosticsHub,
                    DiagnosticsHubArgs(initialVehicleId: vehicleId),
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

class TaskDetailContent extends StatelessWidget {
  final TaskDetailUiState state;
  final TaskDetailActions actions;

  const TaskDetailContent({super.key, required this.state, required this.actions});

  @override
  Widget build(BuildContext context) {
    final hasData = state.task != null || state.detail != null;
    // Piso y fosa: objetivos táctiles de 56 dp para manos con grasa o guantes.
    return AtelierMinTouchTarget(
      value: AtelierMinTouchTarget.floor,
      child: Scaffold(
        bottomNavigationBar: TaskPitActionDock(state: state, actions: actions),
        body: RefreshIndicator(
          onRefresh: actions.onRetry,
          child: DelayedLoading(
            loading: state.isLoading && !hasData,
            builder: (context, showSkeleton) {
              final items = _items(context, hasData, showSkeleton);
              return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (_, index) => items[index],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _padded(Widget child) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: child);

  List<Widget> _items(BuildContext context, bool hasData, bool showSkeleton) {
    final strings = AppLocalizations.of(context);
    final header = [
      _FichaHeader(state: state, loading: showSkeleton, onBack: actions.onBack),
      AtelierRefreshBar(visible: state.isLoading && hasData),
    ];
    final error = state.error;
    if (!hasData && !showSkeleton && !state.isLoading && error != null) {
      return [
        ...header,
        _padded(
          state.isOnline
              ? AtelierErrorState(message: error.asString(strings), onRetry: actions.onRetry)
              : AtelierOfflineState(onRetry: actions.onRetry),
        ),
      ];
    }

    final showObd = state.canOpenObd && state.vehicleId != null;
    final onReportFinding = actions.onReportFinding;
    final showFinding = state.canReportFinding && onReportFinding != null && state.resolvedWorkOrderId.trim().isNotEmpty;
    final banners = _banners(strings);
    final showControls =
        (state.canReopenTask && state.status == TaskStatus.completed) ||
        state.showRequestSuspension ||
        state.showReviewSuspension ||
        state.showResumeSuspended;
    final showEvidence = state.detail != null || state.pendingEvidence.isNotEmpty || state.canAddEvidence;
    return [
      ...header,
      if (banners.isNotEmpty)
        _padded(
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 8, children: banners),
        ),
      if (state.description.trim().isNotEmpty || showSkeleton)
        _padded(_DescriptionCard(description: state.description, loading: showSkeleton)),
      _padded(
        ChronometerTimer(
          startedAt: state.startedAt,
          totalPausedSeconds: state.totalPausedSeconds,
          running: state.status == TaskStatus.inProgress,
          paused: state.status == TaskStatus.onHold,
          pausedElapsedSeconds: state.pausedElapsedSeconds,
          status: state.status,
          holdReason: state.holdReason,
          suspended: state.isSuspended,
          estimatedHours: state.task?.estimatedHours,
          loading: state.isLoading && !hasData,
        ),
      ),
      if (showControls) _padded(_PitControls(state: state, actions: actions)),
      if (showObd || showFinding)
        _padded(
          _QuickActions(
            state: state,
            showObd: showObd,
            showFinding: showFinding,
            onOpenObd: actions.onOpenObd,
            onReportFinding: onReportFinding,
          ),
        ),
      if (showEvidence)
        _padded(
          TaskEvidenceSection(
            images: state.evidenceImages,
            pending: state.pendingEvidence,
            onAdd: state.canAddEvidence && !state.isBusy ? actions.onAddEvidenceClick : null,
          ),
        ),
      if (state.detail != null || state.canChargeParts)
        _padded(
          TaskPartsSection(
            products: state.products,
            available: state.partsAvailable,
            canCharge: state.canOpenCharge,
            canEdit: state.canEditParts,
            isOnline: state.isOnline,
            isBusy: state.isBusy,
            onCharge: actions.onChargeClick,
            onEdit: actions.onEditPartClick,
            onReturn: actions.onReturnPartClick,
          ),
        ),
      if (!state.partsAvailable && !state.isLoading)
        _padded(
          AtelierButton(
            text: strings.branchRetry,
            onClick: () => actions.onRetry(),
            style: AtelierButtonStyle.text,
          ),
        ),
    ];
  }

  List<Widget> _banners(AppLocalizations strings) {
    final notice = state.notice;
    final error = state.error;
    final pendingReason = state.pendingSuspensionReason;
    return [
      if (notice != null)
        AtelierBanner(
          message: notice.asString(strings),
          icon: Icons.check_circle_outline,
          kind: BannerKind.ok,
        ),
      if (!state.hasOpenSheet && error != null)
        AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
      // US29: aviso de solicitud en espera; quien valida la revisa desde "Control de labor".
      if (state.hasPendingSuspension)
        AtelierBanner(
          title: strings.tasksSeg2SuspensionPendingTitle,
          message: pendingReason != null && pendingReason.trim().isNotEmpty
              ? pendingReason
              : strings.tasksSeg2SuspensionPendingBody,
          icon: Icons.hourglass_empty_outlined,
          kind: BannerKind.wait,
        ),
      if (state.isSuspended && !state.canValidateSuspension)
        AtelierBanner(
          message: strings.taskSuspendedNotice,
          icon: Icons.info_outline,
          kind: BannerKind.wait,
        ),
      if (!state.hasAnyActionPermission)
        AtelierBanner(
          message: strings.receptionNoPermission,
          icon: Icons.info_outline,
          kind: BannerKind.wait,
        ),
    ];
  }
}

class _FichaHeader extends StatelessWidget {
  final TaskDetailUiState state;
  final bool loading;
  final VoidCallback onBack;

  const _FichaHeader({required this.state, required this.loading, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final task = state.task;
    final detail = state.detail;
    final serviceName = detail?.serviceName;
    final title = loading
        ? 'Cambio de pastillas'
        : serviceName != null && serviceName.trim().isNotEmpty
        ? serviceName
        : state.description.trim().isNotEmpty
        ? state.description
        : strings.taskDetailTitle;
    final bay = task?.bayName;
    final number = task?.workOrderNumber;
    final mechanic = detail?.mechanicName;
    final subtitle = [
      if (bay != null) strings.taskCardBay(bay),
      if (number != null) strings.taskCardWorkOrder(number),
      if (mechanic != null && mechanic.trim().isNotEmpty) strings.orderTaskMechanic(mechanic),
    ].join(' · ');
    final plate = state.plate;
    final status = state.status;
    return AtelierFichaPanel(
      onBack: onBack,
      title: title,
      subtitle: subtitle.isEmpty ? null : subtitle,
      identity: plate == null ? null : AtelierPlate(plate: plate, size: PlateSize.l),
      status: status == null
          ? null
          : AtelierChip(
              text: taskStatusLabel(strings, status, state.holdReason),
              kind: taskStatusChipKind(status, state.holdReason),
            ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  final String description;
  final bool loading;

  const _DescriptionCard({required this.description, required this.loading});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AtelierGroupedCard(
      title: strings.tasksSeg2DescriptionSection,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: Bone(
              loading: loading,
              widthFraction: 0.85,
              child: Text(
                description.trim().isEmpty ? 'Descripción de la tarea técnica' : description,
                style: context.text.bodyLarge?.copyWith(color: context.scheme.onSurface),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Control de labor: suspensión por pieza (US29) y reapertura de una tarea cerrada.
class _PitControls extends StatelessWidget {
  final TaskDetailUiState state;
  final TaskDetailActions actions;

  const _PitControls({required this.state, required this.actions});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final haptics = rememberAtelierHaptics();
    final hasDockAbove =
        state.showComplete ||
        (state.canTrackTime &&
            (state.status == TaskStatus.assigned ||
                state.isPausedByMechanic ||
                state.status == TaskStatus.inProgress));
    final enabled = !state.isBusy && state.isOnline;
    Widget button(String text, IconData icon, VoidCallback onClick) => AtelierButton(
      text: text,
      onClick: () {
        haptics.toggle();
        onClick();
      },
      style: AtelierButtonStyle.outlined,
      minHeight: 56,
      enabled: enabled,
      icon: icon,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        AtelierSectionHeader(title: strings.tasksSeg2ControlsSection),
        if (state.showRequestSuspension)
          button(
            strings.tasksSeg2SuspensionRequestBtn,
            Icons.report_problem_outlined,
            actions.onRequestSuspensionClick,
          ),
        if (state.showReviewSuspension)
          button(strings.ordersSuspensionTitle, Icons.fact_check_outlined, actions.onReviewSuspensionClick),
        if (state.showResumeSuspended)
          button(strings.ordersResumeTask, Icons.play_arrow_outlined, actions.onResumeSuspendedClick),
        if (state.canReopenTask && state.status == TaskStatus.completed)
          AtelierButton(
            text: strings.tasksSeg2ReopenBtn,
            onClick: () {
              haptics.toggle();
              actions.onReopenClick();
            },
            style: AtelierButtonStyle.outlined,
            minHeight: 56,
            enabled: state.canReopen && state.isOnline,
            loading: state.busyAction == TaskAction.reopen,
            icon: Icons.restart_alt_outlined,
          ),
        if (!state.isOnline && !hasDockAbove) const AtelierRequiresConnection(),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  final TaskDetailUiState state;
  final bool showObd;
  final bool showFinding;
  final void Function(String vehicleId, String? plate) onOpenObd;
  final ValueChanged<String>? onReportFinding;

  const _QuickActions({
    required this.state,
    required this.showObd,
    required this.showFinding,
    required this.onOpenObd,
    required this.onReportFinding,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final vehicleId = state.vehicleId;
    final report = onReportFinding;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        AtelierSectionHeader(title: strings.tasksSeg2QuickActions),
        Row(
          spacing: 8,
          children: [
            if (showObd && vehicleId != null)
              Expanded(
                child: AtelierButton(
                  text: strings.tasksSeg2ActionObd,
                  onClick: () => onOpenObd(vehicleId, state.plate),
                  style: AtelierButtonStyle.tonal,
                  minHeight: 56,
                  vectorIcon: AtelierIcons.bluetoothSearching,
                ),
              ),
            if (showFinding && report != null)
              Expanded(
                child: AtelierButton(
                  text: strings.tasksSeg2ActionFinding,
                  onClick: () => report(state.resolvedWorkOrderId),
                  style: AtelierButtonStyle.outlined,
                  minHeight: 56,
                  icon: Icons.camera_alt_outlined,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
