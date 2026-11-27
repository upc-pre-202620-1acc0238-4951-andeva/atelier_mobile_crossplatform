import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_photo_grid.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_segmented_control.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/lima_time_format.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/evidence_kind.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/pending_evidence.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/detail/task_detail_ui_state.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// US28: evidencias de desmontaje y montaje. Junta las confirmadas por el servidor con las que siguen en cola.
/// Elegir el tipo, escribir la nota (con su contador) y tomar la foto funciona sin red.
class TaskEvidenceSection extends StatelessWidget {
  final TaskDetailUiState state;
  final ValueChanged<EvidenceKind> onKindChange;
  final ValueChanged<String> onNoteChange;
  final VoidCallback onTakePhoto;
  final ValueChanged<PendingEvidence> onSelectFailedEvidence;

  const TaskEvidenceSection({
    super.key,
    required this.state,
    required this.onKindChange,
    required this.onNoteChange,
    required this.onTakePhoto,
    required this.onSelectFailedEvidence,
  });

  List<AtelierPhotoItem> _items() {
    final confirmed = {for (final image in state.evidenceImages) image.imageUrl};
    return [
      for (final image in state.evidenceImages)
        AtelierPhotoItem(
          id: 'synced-${image.id}',
          model: image.imageUrl,
          caption: image.description,
          capturedAtLabel: image.uploadedAt == null ? null : formatLimaStamp(image.uploadedAt!),
        ),
      for (final item in state.pendingEvidence)
        // Una foto ya confirmada puede seguir un instante en la cola: no se muestra dos veces.
        if (!confirmed.contains(item.imageUrl))
          AtelierPhotoItem(
            id: 'pending-${item.operationId}',
            model: item.localFilePath ?? item.imageUrl,
            caption: item.description,
            capturedAtLabel: formatLimaStamp(item.capturedAt),
            syncState: item.status == 'FAILED' ? PhotoSyncState.failed : PhotoSyncState.pending,
          ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final items = _items();
    final pendingById = {for (final item in state.pendingEvidence) 'pending-${item.operationId}': item};
    final maxLength = state.maxEvidenceNoteLength;
    final overLimit = state.evidenceNote.length > maxLength;
    final invalid = state.invalidField == 'description' || overLimit;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        AtelierSectionHeader(title: strings.tasksSeg2EvidenceSection, count: items.length),
        if (state.canUploadPhotos) ...[
          Text(
            strings.tasksSeg2EvidenceKindLabel,
            style: context.text.labelLarge?.copyWith(color: context.atelier.inkSecondary),
          ),
          AtelierSegmentedControl<EvidenceKind>(
            options: EvidenceKind.values,
            selected: state.evidenceKind,
            onSelect: onKindChange,
            label: (kind) => switch (kind) {
              EvidenceKind.disassembly => strings.tasksSeg2EvidenceDisassembly,
              EvidenceKind.assembly => strings.tasksSeg2EvidenceAssembly,
            },
          ),
          AtelierTextField(
            label: strings.tasksSeg2EvidenceNoteLabel,
            value: state.evidenceNote,
            onValueChange: onNoteChange,
            placeholder: strings.tasksSeg2EvidenceNoteHint,
            enabled: state.busyAction != TaskAction.attachEvidence,
            isError: invalid,
            errorText: invalid ? strings.tasksSeg2EvidenceFieldError : null,
            textInputAction: TextInputAction.done,
          ),
          Text(
            strings.tasksSeg2EvidenceNoteCounter(state.evidenceNote.length, maxLength),
            style: context.text.labelSmall?.copyWith(color: context.atelier.inkSecondary),
          ),
        ],
        if (items.isEmpty && !state.canUploadPhotos)
          AtelierEmptyState(text: strings.tasksSeg2EvidenceEmpty)
        else
          AtelierPhotoGrid(
            items: items,
            addLabel: state.canUploadPhotos ? strings.tasksSeg2EvidenceTakePhoto : null,
            onAddPhoto: state.canAddEvidence && !overLimit && !state.isBusy ? onTakePhoto : null,
            onPhotoClick: (item) {
              if (item.syncState == PhotoSyncState.failed) {
                final pending = pendingById[item.id];
                if (pending != null) onSelectFailedEvidence(pending);
              } else {
                _openPhoto(context, item);
              }
            },
          ),
      ],
    );
  }

  /// Foto a pantalla completa con su descripción y marca de tiempo.
  void _openPhoto(BuildContext context, AtelierPhotoItem item) {
    final caption = [?item.caption, ?item.capturedAtLabel].join(' · ');
    final model = item.model.toString();
    showDialog<void>(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: CloseButton(color: Colors.white, onPressed: () => Navigator.of(context).pop()),
              ),
              Expanded(
                child: InteractiveViewer(
                  child: model.toLowerCase().startsWith('http')
                      ? CachedNetworkImage(imageUrl: model, fit: BoxFit.contain)
                      : Image.file(File(model), fit: BoxFit.contain),
                ),
              ),
              if (caption.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(caption, style: context.text.bodyLarge?.copyWith(color: Colors.white)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
