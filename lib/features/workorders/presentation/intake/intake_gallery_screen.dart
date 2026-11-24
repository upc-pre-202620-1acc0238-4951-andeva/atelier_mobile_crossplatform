import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/components/bottom_action_bar.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/components/photo_capture.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/intake/intake_gallery_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/intake/intake_gallery_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';

/// US13: galería pericial de la recepción. Las fotos se encolan con o sin red: las que esperan señal llevan
/// su marca "pendiente de sincronizar". [onDone] cierra la galería cuando el asesor terminó de fotografiar.
class IntakeGalleryScreen extends StatefulWidget {
  final String workOrderId;
  final TakePhoto takePhoto;

  const IntakeGalleryScreen({
    super.key,
    required this.workOrderId,
    this.takePhoto = takeCameraPhoto,
  });

  @override
  State<IntakeGalleryScreen> createState() => _IntakeGalleryScreenState();
}

class _IntakeGalleryScreenState extends State<IntakeGalleryScreen> {
  late final IntakeGalleryViewModel viewModel = getIt<IntakeGalleryViewModel>(
    param1: widget.workOrderId,
  );

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  void _onDone() {
    var foundDetail = false;
    Navigator.of(context).popUntil((route) {
      if (route.settings.name == AppRoute.workOrderDetail.name &&
          route.settings.arguments == widget.workOrderId) {
        foundDetail = true;
        return true;
      }
      return route.isFirst;
    });
    if (!foundDetail && mounted) {
      AppNavigator.pushReplacement<void, void>(
        context,
        AppRoute.workOrderDetail,
        widget.workOrderId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) => IntakeGalleryContent(
        state: vm.state,
        onBack: () => Navigator.of(context).maybePop(),
        onDone: _onDone,
        onOpenProposals: () => AppNavigator.push(context, AppRoute.proposalsPanel, vm.workOrderId),
        onNoteChange: vm.onNoteChange,
        onCapture: (angle) => widget.takePhoto(
          onCaptured: (file) => vm.onPhotoCaptured(angle, file),
          onDenied: vm.onCameraDenied,
        ),
      ),
    );
  }
}

class IntakeGalleryContent extends StatelessWidget {
  final IntakeGalleryUiState state;
  final VoidCallback onBack;
  final VoidCallback onDone;
  final VoidCallback onOpenProposals;
  final ValueChanged<String> onNoteChange;
  final ValueChanged<InspectionAngle> onCapture;

  const IntakeGalleryContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onDone,
    required this.onOpenProposals,
    required this.onNoteChange,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final panels = InspectionAngle.values.where((a) => a != InspectionAngle.other).toList();
    final noAccess = !state.canUpload && !state.canRead && !state.isLoading;
    final error = state.error;

    return Scaffold(
      body: Column(
        children: [
          AtelierTopBar(title: strings.galleryTitle, onBack: onBack),
          Expanded(
            child: noAccess
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: AtelierNoPermissionState(text: strings.receptionNoPermission),
                  )
                : DelayedLoading(
                    loading: state.isLoading && state.photos.isEmpty && state.canRead,
                    builder: (context, loading) {
                      final others = state.photosFor(InspectionAngle.other);
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: 12,
                          children: [
                            Text(
                              strings.gallerySubtitle,
                              style: context.text.bodyLarge?.copyWith(
                                color: context.atelier.inkSecondary,
                              ),
                            ),
                            if (!state.canUpload)
                              AtelierNoPermissionState(text: strings.receptionNoPermission),
                            AtelierTextField(
                              label: strings.galleryNote,
                              value: state.note,
                              onValueChange: onNoteChange,
                              enabled: !state.isSaving && state.canUpload,
                            ),
                            if (error != null)
                              AtelierBanner(
                                message: error.asString(strings),
                                icon: Icons.error_outline,
                              ),
                            for (var i = 0; i < panels.length; i += 2)
                              Row(
                                spacing: 12,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final angle in panels.skip(i).take(2))
                                    Expanded(
                                      child: _PhotoSlot(
                                        label: angle.label(strings),
                                        photo: state.photosFor(angle).firstOrNull,
                                        enabled: state.canUpload && !state.isSaving,
                                        loading: loading,
                                        onClick: () => onCapture(angle),
                                      ),
                                    ),
                                ],
                              ),
                            AtelierSectionHeader(
                              title: strings.galleryOther,
                              count: others.isEmpty ? null : others.length,
                            ),
                            for (var i = 0; i < others.length; i += 2)
                              Row(
                                spacing: 12,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final photo in others.skip(i).take(2))
                                    Expanded(
                                      child: _PhotoSlot(
                                        label: photo.description ?? strings.galleryAngleOther,
                                        photo: photo,
                                        enabled: false,
                                        loading: false,
                                        onClick: () {},
                                      ),
                                    ),
                                  if (others.skip(i).take(2).length == 1) const Expanded(child: SizedBox()),
                                ],
                              ),
                            AtelierButton(
                              text: strings.galleryAddOther,
                              onClick: () => onCapture(InspectionAngle.other),
                              style: AtelierButtonStyle.outlined,
                              enabled: state.canUpload && !state.isSaving,
                              loading: state.isSaving,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          if (!noAccess)
            WorkOrderBottomBar(
              spacing: 4,
              children: [
                AtelierButton(text: strings.galleryDone, onClick: onDone),
                AtelierButton(
                  text: strings.galleryProposals,
                  onClick: onOpenProposals,
                  style: AtelierButtonStyle.text,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  final String label;
  final GalleryPhoto? photo;
  final bool enabled;
  final bool loading;
  final VoidCallback onClick;

  const _PhotoSlot({
    required this.label,
    required this.photo,
    required this.enabled,
    required this.loading,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final current = photo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        Bone(
          loading: loading,
          child: AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: chipRadius,
              child: Material(
                color: colors.card,
                child: InkWell(
                  onTap: enabled && !loading ? onClick : null,
                  child: loading
                      ? const SizedBox.expand()
                      : current == null
                      ? Center(
                          child: Icon(
                            Icons.photo_camera_outlined,
                            semanticLabel: strings.galleryTakePhoto(label),
                            color: enabled ? context.scheme.primary : colors.muted,
                          ),
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            _PhotoImage(photo: current, label: label),
                            Positioned(
                              left: 8,
                              bottom: 8,
                              child: AtelierChip(
                                text: _statusLabel(strings, current.status),
                                kind: _statusKind(current.status),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
        Text(
          label,
          style: context.text.bodyMedium?.copyWith(color: context.scheme.onSurface),
        ),
      ],
    );
  }

  String _statusLabel(AppLocalizations strings, PhotoStatus status) => switch (status) {
    PhotoStatus.uploaded => strings.galleryStatusUploaded,
    PhotoStatus.queued => strings.galleryStatusQueued,
    PhotoStatus.failed => strings.galleryStatusFailed,
  };

  ChipKind _statusKind(PhotoStatus status) => switch (status) {
    PhotoStatus.uploaded => ChipKind.ok,
    PhotoStatus.queued => ChipKind.wait,
    PhotoStatus.failed => ChipKind.bad,
  };
}

class _PhotoImage extends StatelessWidget {
  final GalleryPhoto photo;
  final String label;

  const _PhotoImage({required this.photo, required this.label});

  @override
  Widget build(BuildContext context) {
    final local = photo.localPath;
    if (local != null) {
      return Image.file(
        File(local),
        fit: BoxFit.cover,
        semanticLabel: label,
        errorBuilder: (_, _, _) => const Center(child: Icon(Icons.broken_image_outlined)),
      );
    }
    final remote = photo.remoteUrl;
    if (remote != null && remote.isNotEmpty) {
      return Image.network(
        remote,
        fit: BoxFit.cover,
        semanticLabel: label,
        errorBuilder: (_, _, _) => const Center(child: Icon(Icons.broken_image_outlined)),
      );
    }
    return const Center(child: Icon(Icons.broken_image_outlined));
  }
}
