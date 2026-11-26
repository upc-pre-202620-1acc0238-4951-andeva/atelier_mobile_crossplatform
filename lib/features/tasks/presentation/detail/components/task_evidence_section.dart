import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_photo_grid.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/lima_time_format.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/pending_evidence.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_evidence.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// US28: evidencias de desmontaje y montaje. Junta las confirmadas por el servidor con las que siguen en cola.
/// Añadir funciona sin red.
class TaskEvidenceSection extends StatelessWidget {
  final List<TaskEvidence> images;
  final List<PendingEvidence> pending;
  final VoidCallback? onAdd;

  const TaskEvidenceSection({super.key, required this.images, required this.pending, this.onAdd});

  List<AtelierPhotoItem> _items() {
    final confirmed = {for (final image in images) image.imageUrl};
    return [
      for (final image in images)
        AtelierPhotoItem(
          id: image.id,
          model: image.imageUrl,
          caption: image.description,
          capturedAtLabel: image.uploadedAt == null ? null : formatLimaStamp(image.uploadedAt!),
        ),
      for (final item in pending)
        // Una foto ya confirmada puede seguir un instante en la cola: no se muestra dos veces.
        if (!confirmed.contains(item.imageUrl))
          AtelierPhotoItem(
            id: item.operationId,
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
    final failures = [
      for (final item in pending)
        if (item.status == 'FAILED' && item.lastErrorMessage != null) item.lastErrorMessage!,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        AtelierSectionHeader(title: strings.tasksSeg2EvidenceSection),
        if (items.isEmpty)
          Text(
            strings.tasksSeg2EvidenceEmpty,
            style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary),
          ),
        for (final message in failures)
          Text(message, style: context.text.bodySmall?.copyWith(color: context.atelier.bad)),
        if (items.isNotEmpty || onAdd != null)
          AtelierPhotoGrid(
            items: items,
            addLabel: strings.tasksSeg2EvidenceTakePhoto,
            onAddPhoto: onAdd,
            onPhotoClick: (item) => _openPhoto(context, item),
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
