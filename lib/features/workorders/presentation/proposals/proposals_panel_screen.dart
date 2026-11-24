import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/money_format.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/state_sheet_host.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/proposal.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_references.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/components/pick_row.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/components/proposal_labels.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/proposals/proposals_panel_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/proposals/proposals_panel_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final _decimalFormatters = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))];

/// US15: panel de propuestas por hallazgo. Las que esperan una decisión (`proposals:resolve`) salen en
/// ámbar y se deciden en una hoja inferior: notificar al cliente, registrar su aprobación o su rechazo.
/// Todo en línea.
class ProposalsPanelScreen extends StatefulWidget {
  final String workOrderId;

  const ProposalsPanelScreen({super.key, required this.workOrderId});

  @override
  State<ProposalsPanelScreen> createState() => _ProposalsPanelScreenState();
}

class _ProposalsPanelScreenState extends State<ProposalsPanelScreen> {
  late final ProposalsPanelViewModel viewModel = getIt<ProposalsPanelViewModel>(
    param1: widget.workOrderId,
  );
  final ValueNotifier<String?> _selectedId = ValueNotifier(null);
  late final Listenable _combined = Listenable.merge([viewModel, _selectedId]);

  @override
  void initState() {
    super.initState();
    viewModel.addListener(_clearClosedSelection);
  }

  void _clearClosedSelection() {
    final id = _selectedId.value;
    if (id == null) return;
    final stillPending = viewModel.state.proposals.any(
      (p) => p.id == id && p.status == ProposalStatus.pendingReview,
    );
    if (!stillPending) _selectedId.value = null;
  }

  @override
  void dispose() {
    viewModel.removeListener(_clearClosedSelection);
    _selectedId.dispose();
    viewModel.dispose();
    super.dispose();
  }

  Proposal? _selectedProposal() {
    final id = _selectedId.value;
    if (id == null) return null;
    for (final p in viewModel.state.proposals) {
      if (p.id == id && p.status == ProposalStatus.pendingReview) return p;
    }
    return null;
  }

  Future<void> _openReportFinding() async {
    await AppNavigator.push(context, AppRoute.reportFinding, widget.workOrderId);
    if (mounted) viewModel.load();
  }

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    final actions = ProposalsPanelActions(
      onBack: () => Navigator.of(context).maybePop(),
      onReportFinding: _openReportFinding,
      onRetry: vm.load,
      onNotify: vm.onNotify,
      onOpenForm: vm.onOpenForm,
      onCloseForm: vm.onCloseForm,
      onServiceChange: vm.onServiceChange,
      onFinalPriceChange: vm.onFinalPriceChange,
      onLaborHoursChange: vm.onLaborHoursChange,
      onMechanicChange: vm.onMechanicChange,
      onNotesChange: vm.onNotesChange,
      onConfirm: vm.onConfirm,
    );

    return StateSheetHost<Proposal>(
      listenable: _combined,
      value: _selectedProposal,
      onDismiss: () {
        vm.onCloseForm();
        _selectedId.value = null;
      },
      sheetBuilder: (context, proposal) => ListenableBuilder(
        listenable: _combined,
        builder: (context, _) {
          final current = _selectedProposal() ?? proposal;
          return _ProposalSheet(
            proposal: current,
            state: vm.state,
            actions: actions,
            onDismiss: () {
              vm.onCloseForm();
              _selectedId.value = null;
            },
          );
        },
      ),
      child: ListenableBuilder(
        listenable: _combined,
        builder: (context, _) => ProposalsPanelContent(
          state: vm.state,
          actions: actions,
          onSelectProposal: (id) => _selectedId.value = id,
        ),
      ),
    );
  }
}

class ProposalsPanelActions {
  final VoidCallback onBack;
  final VoidCallback onReportFinding;
  final Future<void> Function() onRetry;
  final ValueChanged<String> onNotify;
  final void Function(String proposalId, ProposalAction action) onOpenForm;
  final VoidCallback onCloseForm;
  final ValueChanged<String> onServiceChange;
  final ValueChanged<String> onFinalPriceChange;
  final ValueChanged<String> onLaborHoursChange;
  final ValueChanged<String?> onMechanicChange;
  final ValueChanged<String> onNotesChange;
  final VoidCallback onConfirm;

  static void _noop() {}
  static void _noop1(Object? _) {}
  static void _noop2(Object? a, Object? b) {}
  static Future<void> _noopRefresh() async {}

  const ProposalsPanelActions({
    this.onBack = _noop,
    this.onReportFinding = _noop,
    this.onRetry = _noopRefresh,
    this.onNotify = _noop1,
    this.onOpenForm = _noop2,
    this.onCloseForm = _noop,
    this.onServiceChange = _noop1,
    this.onFinalPriceChange = _noop1,
    this.onLaborHoursChange = _noop1,
    this.onMechanicChange = _noop1,
    this.onNotesChange = _noop1,
    this.onConfirm = _noop,
  });
}

class ProposalsPanelContent extends StatelessWidget {
  final ProposalsPanelUiState state;
  final ProposalsPanelActions actions;
  final ValueChanged<String> onSelectProposal;

  const ProposalsPanelContent({
    super.key,
    required this.state,
    required this.actions,
    required this.onSelectProposal,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final canDecideAnything = state.canNotify || state.canResolve;
    final pending = state.proposals.where((p) => p.status == ProposalStatus.pendingReview).toList();
    final pendingIds = pending.map((p) => p.id).toSet();
    final resolved = state.proposals.where((p) => !pendingIds.contains(p.id)).toList();
    final notice = state.notice;
    final error = state.error;

    return Scaffold(
      floatingActionButton: state.canReport
          ? AtelierFab(
              text: strings.proposalsReport,
              icon: Icons.report_outlined,
              onClick: actions.onReportFinding,
            )
          : null,
      body: Column(
        children: [
          AtelierTopBar(title: strings.proposalsTitle, onBack: actions.onBack),
          AtelierRefreshBar(visible: state.isLoading && state.proposals.isNotEmpty),
          Expanded(
            child: DelayedLoading(
              loading: state.isLoading && state.proposals.isEmpty,
              builder: (context, showSkeleton) => RefreshIndicator(
                onRefresh: actions.onRetry,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 96),
                  children: [
                    if (notice != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: AtelierBanner(
                          message: notice.asString(strings),
                          icon: Icons.check_circle_outline,
                          kind: BannerKind.ok,
                        ),
                      ),
                    if (showSkeleton)
                      for (var i = 0; i < 3; i++)
                        const AtelierListRow(
                          title: 'Hallazgo en el foso',
                          subtitle: 'Severidad',
                          loading: true,
                        )
                    else if (state.isLoading && state.proposals.isEmpty)
                      const SizedBox.shrink()
                    else if (state.proposals.isEmpty && error != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AtelierErrorState(
                          message: error.asString(strings),
                          onRetry: actions.onRetry,
                        ),
                      )
                    else if (state.proposals.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AtelierEmptyState(text: strings.proposalsEmpty),
                      )
                    else ...[
                      if (pending.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: AtelierSectionHeader(
                            title: strings.ordersSectionDecisions,
                            count: pending.length,
                          ),
                        ),
                        for (final proposal in pending)
                          if (state.canResolve)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: AtelierDecisionRow(
                                title: proposal.description,
                                subtitle: proposal.severity?.label(strings),
                                onClick: () => onSelectProposal(proposal.id),
                              ),
                            )
                          else
                            AtelierListRow(
                              title: proposal.description,
                              subtitle: proposal.severity?.label(strings),
                              onClick: canDecideAnything ? () => onSelectProposal(proposal.id) : null,
                              trailing: AtelierChip(
                                text: ProposalStatus.pendingReview.label(strings),
                                kind: ProposalStatus.pendingReview.chipKind,
                              ),
                            ),
                      ],
                      if (resolved.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: AtelierSectionHeader(
                            title: strings.ordersProposalsResolved,
                            count: resolved.length,
                          ),
                        ),
                        for (final proposal in resolved)
                          AtelierListRow(
                            title: proposal.description,
                            subtitle: _resolvedSubtitle(strings, proposal),
                            trailing: proposal.status != null
                                ? AtelierChip(
                                    text: proposal.status!.label(strings),
                                    kind: proposal.status!.chipKind,
                                  )
                                : null,
                          ),
                      ],
                      if (error != null && state.form == null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: AtelierBanner(
                            message: error.asString(strings),
                            icon: Icons.error_outline,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _resolvedSubtitle(AppLocalizations strings, Proposal proposal) {
    final notes = proposal.customerNotes;
    final parts = [
      if (proposal.severity != null) proposal.severity!.label(strings),
      if (notes != null && notes.trim().isNotEmpty) strings.proposalsCustomerNotes(notes),
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }
}

class _ProposalSheet extends StatelessWidget {
  final Proposal proposal;
  final ProposalsPanelUiState state;
  final ProposalsPanelActions actions;
  final VoidCallback onDismiss;

  const _ProposalSheet({
    required this.proposal,
    required this.state,
    required this.actions,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final currentForm = state.form;
    final form = currentForm != null && currentForm.proposalId == proposal.id ? currentForm : null;
    final busy = state.busyProposalId == proposal.id;
    final canAct = state.isOnline && !state.isBusy;
    final ServiceOption? recommendedService = proposal.serviceId == null
        ? null
        : state.services.where((s) => s.id == proposal.serviceId).firstOrNull;
    final severity = proposal.severity;
    final imageUrl = proposal.imageUrl;
    final notice = state.notice;
    final error = state.error;

    return AtelierBottomSheet(
      title: strings.ordersProposalSheetTitle,
      actions: [
        if (!state.isOnline) const AtelierRequiresConnection(),
        if (form != null) ...[
          AtelierButton(
            text: strings.proposalsConfirm,
            onClick: actions.onConfirm,
            enabled: state.canConfirm,
            loading: busy,
          ),
          AtelierButton(
            text: strings.proposalsCancel,
            onClick: actions.onCloseForm,
            style: AtelierButtonStyle.text,
            enabled: !state.isBusy,
          ),
        ] else ...[
          if (state.canNotify)
            AtelierButton(
              text: strings.proposalsNotify,
              onClick: () => actions.onNotify(proposal.id),
              style: AtelierButtonStyle.tonal,
              enabled: canAct,
              loading: busy,
            ),
          if (state.canResolve) ...[
            AtelierButton(
              text: strings.proposalsApprove,
              onClick: () => actions.onOpenForm(proposal.id, ProposalAction.approve),
              enabled: canAct,
            ),
            AtelierButton(
              text: strings.proposalsReject,
              onClick: () => actions.onOpenForm(proposal.id, ProposalAction.reject),
              style: AtelierButtonStyle.destructive,
              enabled: canAct,
            ),
          ],
        ],
      ],
      content: [
        if (severity != null)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AtelierChip(text: severity.label(strings), kind: severity.chipKind),
          ),
        Text(
          proposal.description,
          style: context.text.bodyLarge?.copyWith(color: context.scheme.onSurface),
        ),
        if (recommendedService != null)
          Text(
            strings.proposalsRecommendedService(
              [
                recommendedService.name,
                if (recommendedService.basePrice != null) recommendedService.basePrice!.format(),
                if ((recommendedService.estimatedMinutes ?? 0) > 0)
                  '${recommendedService.estimatedMinutes} min',
              ].join(' · '),
            ),
            style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary),
          ),
        if (imageUrl != null && imageUrl.isNotEmpty)
          ClipRRect(
            borderRadius: chipRadius,
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                semanticLabel: strings.findingPhoto,
                errorBuilder: (_, _, _) => const Center(child: Icon(Icons.broken_image_outlined)),
              ),
            ),
          ),
        if (notice != null)
          AtelierBanner(
            message: notice.asString(strings),
            icon: Icons.check_circle_outline,
            kind: BannerKind.ok,
          ),
        if (form != null)
          _ProposalFormFields(form: form, state: state, actions: actions)
        else if (error != null)
          AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
      ],
    );
  }
}

class _ProposalFormFields extends StatelessWidget {
  final ProposalForm form;
  final ProposalsPanelUiState state;
  final ProposalsPanelActions actions;

  const _ProposalFormFields({required this.form, required this.state, required this.actions});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final approve = form.action == ProposalAction.approve;
    final saving = state.isBusy;
    final priceLocked = state.isPriceLockedByCatalog;
    final error = state.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        if (approve) ...[
          Text(
            strings.proposalsService,
            style: context.text.labelLarge?.copyWith(color: colors.inkSecondary),
          ),
          Column(
            children: [
              for (final service in state.services)
                PickRow(
                  title: service.name,
                  subtitle: _serviceSubtitle(service),
                  selected: form.serviceId == service.id,
                  enabled: !saving,
                  onClick: () => actions.onServiceChange(service.id),
                ),
            ],
          ),
          if (state.invalidField == 'serviceId')
            Text(
              strings.proposalsFieldService,
              style: context.text.bodyMedium?.copyWith(color: colors.bad),
            ),
          AtelierTextField(
            label: strings.proposalsFinalPrice,
            value: form.finalPrice,
            onValueChange: actions.onFinalPriceChange,
            enabled: !saving && !priceLocked,
            isError: state.invalidField == 'finalPrice',
            errorText: state.invalidField == 'finalPrice' ? strings.proposalsFieldAmount : null,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: _decimalFormatters,
            textInputAction: TextInputAction.next,
          ),
          if (priceLocked)
            Text(
              strings.proposalsPriceFromCatalog,
              style: context.text.labelSmall?.copyWith(color: colors.inkSecondary),
            ),
          AtelierTextField(
            label: strings.proposalsLaborHours,
            value: form.laborHours,
            onValueChange: actions.onLaborHoursChange,
            enabled: !saving,
            isError: state.invalidField == 'laborHours',
            errorText: state.invalidField == 'laborHours' ? strings.proposalsFieldAmount : null,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: _decimalFormatters,
            textInputAction: TextInputAction.next,
          ),
          if (state.availableMechanics.isNotEmpty) ...[
            Text(
              strings.proposalsMechanic,
              style: context.text.labelLarge?.copyWith(color: colors.inkSecondary),
            ),
            Column(
              children: [
                PickRow(
                  title: strings.proposalsMechanicUnassigned,
                  selected: form.mechanicId == null,
                  enabled: !saving,
                  onClick: () => actions.onMechanicChange(null),
                ),
                for (final mechanic in state.availableMechanics)
                  PickRow(
                    title: mechanic.displayName,
                    selected: form.mechanicId == mechanic.membershipId,
                    enabled: !saving,
                    onClick: () => actions.onMechanicChange(mechanic.membershipId),
                  ),
              ],
            ),
          ],
        ],
        AtelierTextField(
          label: approve ? strings.proposalsNotesOptional : strings.proposalsCustomerNotesLabel,
          value: form.notes,
          onValueChange: actions.onNotesChange,
          enabled: !saving,
          isError: state.invalidField == 'notes' || state.invalidField == 'customerNotes',
          errorText: state.invalidField == 'notes' || state.invalidField == 'customerNotes'
              ? strings.proposalsFieldNotes
              : null,
        ),
        if (error != null)
          AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
      ],
    );
  }

  String? _serviceSubtitle(ServiceOption service) {
    final parts = [
      if (service.basePrice != null) service.basePrice!.format(),
      if ((service.estimatedMinutes ?? 0) > 0) '${service.estimatedMinutes} min',
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }
}
