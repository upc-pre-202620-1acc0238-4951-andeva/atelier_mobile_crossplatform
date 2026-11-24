import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/pending_work_order_capture.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/proposal.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/components/bottom_action_bar.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/components/choice_chip.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/components/photo_capture.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/components/pick_row.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/components/proposal_labels.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/finding/report_finding_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/finding/report_finding_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// US14: reporte técnico de un imprevisto encontrado en el foso o la bahía. Funciona sin red: el hallazgo se
/// encola y sale como "pendiente de sincronizar" hasta que el backend lo recibe.
class ReportFindingScreen extends StatefulWidget {
  final String workOrderId;
  final TakePhoto takePhoto;

  const ReportFindingScreen({
    super.key,
    required this.workOrderId,
    this.takePhoto = takeCameraPhoto,
  });

  @override
  State<ReportFindingScreen> createState() => _ReportFindingScreenState();
}

class _ReportFindingScreenState extends State<ReportFindingScreen> {
  late final ReportFindingViewModel viewModel = getIt<ReportFindingViewModel>(
    param1: widget.workOrderId,
  );

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) => ReportFindingContent(
        state: vm.state,
        onBack: () => Navigator.of(context).maybePop(),
        onDescriptionChange: vm.onDescriptionChange,
        onSeverityChange: vm.onSeverityChange,
        onServiceChange: vm.onServiceChange,
        onTakePhoto: () => widget.takePhoto(
          onCaptured: vm.onPhotoCaptured,
          onDenied: vm.onCameraDenied,
        ),
        onRetryServices: vm.loadServices,
        onSubmit: vm.onSubmit,
      ),
    );
  }
}

class ReportFindingContent extends StatelessWidget {
  final ReportFindingUiState state;
  final VoidCallback onBack;
  final ValueChanged<String> onDescriptionChange;
  final ValueChanged<ProposalSeverity> onSeverityChange;
  final ValueChanged<String?> onServiceChange;
  final VoidCallback onTakePhoto;
  final VoidCallback onRetryServices;
  final VoidCallback onSubmit;

  const ReportFindingContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onDescriptionChange,
    required this.onSeverityChange,
    required this.onServiceChange,
    required this.onTakePhoto,
    required this.onRetryServices,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final error = state.error;
    return Scaffold(
      body: Column(
        children: [
          AtelierTopBar(title: strings.findingTitle, onBack: onBack),
          Expanded(
            child: !state.canCreate
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: AtelierNoPermissionState(text: strings.receptionNoPermission),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 12,
                      children: [
                        Text(
                          strings.findingSubtitle,
                          style: context.text.bodyLarge?.copyWith(color: context.atelier.inkSecondary),
                        ),
                        if (state.saved)
                          AtelierBanner(
                            message: strings.findingSaved,
                            icon: Icons.check_circle_outline,
                            kind: BannerKind.ok,
                          ),
                        AtelierSectionHeader(title: strings.findingSeverity),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            for (final severity in submittableSeverities)
                              WorkOrderChoiceChip(
                                label: severity.label(strings),
                                selected: state.severity == severity,
                                enabled: !state.isSaving,
                                onClick: () => onSeverityChange(severity),
                              ),
                          ],
                        ),
                        AtelierTextField(
                          label: strings.findingDescription,
                          value: state.description,
                          onValueChange: onDescriptionChange,
                          enabled: !state.isSaving,
                          isError: state.invalidField == 'description',
                          errorText: state.invalidField == 'description'
                              ? strings.findingFieldDescription
                              : null,
                        ),
                        AtelierSectionHeader(title: strings.findingPhoto),
                        _PhotoArea(state: state, onTakePhoto: onTakePhoto),
                        _ServicesSection(
                          state: state,
                          onServiceChange: onServiceChange,
                          onRetry: onRetryServices,
                        ),
                        if (error != null)
                          AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
                        _PendingList(pending: state.pending),
                      ],
                    ),
                  ),
          ),
          if (state.canCreate)
            WorkOrderBottomBar(
              children: [
                AtelierButton(
                  text: strings.findingSubmit,
                  onClick: onSubmit,
                  enabled: state.canSubmit,
                  loading: state.isSaving,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PhotoArea extends StatelessWidget {
  final ReportFindingUiState state;
  final VoidCallback onTakePhoto;

  const _PhotoArea({required this.state, required this.onTakePhoto});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final photo = state.photo;
    if (photo == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          AtelierButton(
            text: strings.findingTakePhoto,
            onClick: onTakePhoto,
            style: AtelierButtonStyle.outlined,
            enabled: state.canCreate && !state.isSaving,
            icon: Icons.photo_camera_outlined,
          ),
          Text(
            strings.findingPhotoRequired,
            style: context.text.bodyMedium?.copyWith(
              color: state.invalidField == 'photo' ? context.atelier.bad : context.atelier.inkSecondary,
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        ClipRRect(
          borderRadius: chipRadius,
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.file(
              File(photo.path),
              fit: BoxFit.cover,
              semanticLabel: strings.findingPhoto,
            ),
          ),
        ),
        AtelierButton(
          text: strings.findingChangePhoto,
          onClick: onTakePhoto,
          style: AtelierButtonStyle.text,
          enabled: !state.isSaving,
        ),
      ],
    );
  }
}

class _ServicesSection extends StatelessWidget {
  final ReportFindingUiState state;
  final ValueChanged<String?> onServiceChange;
  final VoidCallback onRetry;

  const _ServicesSection({
    required this.state,
    required this.onServiceChange,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    if (state.isLoadingServices) return const SizedBox.shrink();
    if (state.services.isEmpty) {
      return AtelierButton(
        text: strings.commonRetry,
        onClick: onRetry,
        style: AtelierButtonStyle.text,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AtelierSectionHeader(title: strings.findingService),
        PickRow(
          title: strings.findingServiceNone,
          selected: state.suggestedServiceId == null,
          enabled: !state.isSaving,
          onClick: () => onServiceChange(null),
        ),
        for (final service in state.services)
          PickRow(
            title: service.name,
            selected: state.suggestedServiceId == service.id,
            enabled: !state.isSaving,
            onClick: () => onServiceChange(service.id),
          ),
      ],
    );
  }
}

class _PendingList extends StatelessWidget {
  final List<PendingProposal> pending;

  const _PendingList({required this.pending});

  @override
  Widget build(BuildContext context) {
    if (pending.isEmpty) return const SizedBox.shrink();
    final strings = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AtelierSectionHeader(title: strings.findingPendingTitle, count: pending.length),
        for (final proposal in pending)
          AtelierListRow(
            title: proposal.description,
            subtitle: proposal.severity?.label(strings),
            trailing: AtelierChip(
              text: proposal.status == 'FAILED'
                  ? strings.galleryStatusFailed
                  : strings.galleryStatusQueued,
              kind: proposal.status == 'FAILED' ? ChipKind.bad : ChipKind.wait,
            ),
          ),
      ],
    );
  }
}
