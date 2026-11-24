import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_colors.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Estado de sincronización de una evidencia fotográfica.
enum PhotoSyncState { synced, pending, failed }

/// Elemento de [AtelierPhotoGrid]: soporta URL remota o archivo local en cola offline.
@immutable
class AtelierPhotoItem {
  final String id;

  /// URL (`http…`), ruta de archivo local (`String`) o un [File]. Vacío deja el fondo sin imagen.
  final Object model;
  final String? caption;
  final PhotoSyncState syncState;
  final String? capturedAtLabel;

  const AtelierPhotoItem({
    required this.id,
    required this.model,
    this.caption,
    this.syncState = PhotoSyncState.synced,
    this.capturedAtLabel,
  });
}

/// Grilla de evidencias fotográficas (recepción o desmontaje/montaje de tarea).
/// Muestra el estado de sincronización con ícono + texto y reserva el último espacio para capturar foto.
class AtelierPhotoGrid extends StatelessWidget {
  final List<AtelierPhotoItem> items;
  final int columns;
  final String? addLabel;
  final VoidCallback? onAddPhoto;
  final void Function(AtelierPhotoItem item)? onPhotoClick;

  const AtelierPhotoGrid({
    super.key,
    required this.items,
    this.columns = 2,
    this.addLabel,
    this.onAddPhoto,
    this.onPhotoClick,
  });

  @override
  Widget build(BuildContext context) {
    final perRow = columns < 1 ? 1 : columns;
    final label = addLabel;
    final hasAddTile = onAddPhoto != null && label != null;
    final cells = <AtelierPhotoItem?>[...items, if (hasAddTile) null];
    final rows = <List<AtelierPhotoItem?>>[
      for (var i = 0; i < cells.length; i += perRow)
        cells.sublist(i, i + perRow > cells.length ? cells.length : i + perRow),
    ];
    final onPhotoClick = this.onPhotoClick;

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          for (final row in rows)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                for (final item in row)
                  Expanded(
                    child: item == null
                        ? _AddPhotoTile(
                            label: label ?? '',
                            onClick: () => onAddPhoto?.call(),
                          )
                        : _PhotoTile(
                            item: item,
                            onClick: onPhotoClick == null
                                ? null
                                : () => onPhotoClick(item),
                          ),
                  ),
                for (var i = row.length; i < perRow; i++) const Spacer(),
              ],
            ),
        ],
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final AtelierPhotoItem item;
  final VoidCallback? onClick;

  const _PhotoTile({required this.item, required this.onClick});

  @override
  Widget build(BuildContext context) {
    final colors = context.atelier;
    final strings = AppLocalizations.of(context);
    final caption = item.caption;
    final captured = item.capturedAtLabel;
    final hasCaption = caption != null && caption.trim().isNotEmpty;
    final hasCaptured = captured != null && captured.trim().isNotEmpty;
    final (badgeKind, badgeIcon, badgeText) = switch (item.syncState) {
      PhotoSyncState.synced => (
        ChipKind.ok,
        Icons.cloud_done_outlined,
        strings.atelierPhotoSynced,
      ),
      PhotoSyncState.pending => (
        ChipKind.idle,
        Icons.sync_outlined,
        strings.atelierPhotoPending,
      ),
      PhotoSyncState.failed => (
        ChipKind.bad,
        Icons.error_outline,
        strings.atelierPhotoFailed,
      ),
    };

    return AtelierSurface(
      tier: SurfaceTier.card,
      shape: controlShape,
      onClick: onClick,
      child: ClipRRect(
        borderRadius: controlRadius,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: ColoredBox(
                color: colors.surfaceRecessed,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _PhotoImage(model: item.model, semanticLabel: caption),
                    if (item.syncState != PhotoSyncState.synced)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: AtelierChip(
                          text: badgeText,
                          kind: badgeKind,
                          icon: badgeIcon,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (hasCaption || hasCaptured)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    if (hasCaption)
                      Text(
                        caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall?.copyWith(
                          color: context.scheme.onSurface,
                        ),
                      ),
                    if (hasCaptured)
                      Text(
                        captured,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.labelSmall?.copyWith(
                          color: colors.inkSecondary,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Imagen remota (`http…`) o archivo local; recorta al cubrir el recuadro.
class _PhotoImage extends StatelessWidget {
  final Object model;
  final String? semanticLabel;

  const _PhotoImage({required this.model, required this.semanticLabel});

  @override
  Widget build(BuildContext context) {
    final raw = model;
    if (raw is String && raw.isEmpty) return const SizedBox.shrink();
    if (raw is String && raw.toLowerCase().startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: raw,
        fit: BoxFit.cover,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        errorWidget: (context, url, error) => const SizedBox.shrink(),
      );
    }
    final file = raw is File ? raw : File(raw.toString());
    return Image.file(
      file,
      fit: BoxFit.cover,
      semanticLabel: semanticLabel,
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
    );
  }
}

class _AddPhotoTile extends StatefulWidget {
  final String label;
  final VoidCallback onClick;

  const _AddPhotoTile({required this.label, required this.onClick});

  @override
  State<_AddPhotoTile> createState() => _AddPhotoTileState();
}

class _AddPhotoTileState extends State<_AddPhotoTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.atelier;
    final scheme = context.scheme;
    final tileGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        scheme.primaryContainer,
        scheme.primaryContainer.withValues(alpha: 0.72),
      ],
    );
    final borderGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        atelierBlueSoft.withValues(alpha: 0.65),
        scheme.primary.withValues(alpha: 0.45),
      ],
    );

    return SpringPressScale(
      isPressed: _pressed,
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Semantics(
          button: true,
          label: widget.label,
          excludeSemantics: true,
          onTap: widget.onClick,
          child: CustomPaint(
            foregroundPainter: AtelierBorderPainter(
              shape: controlShape,
              spec: AtelierBorderSpec(gradient: borderGradient),
            ),
            child: ClipRRect(
              borderRadius: controlRadius,
              child: Material(
                color: colors.card,
                child: Ink(
                  decoration: BoxDecoration(gradient: tileGradient),
                  child: InkWell(
                    onTap: widget.onClick,
                    onHighlightChanged: (value) =>
                        setState(() => _pressed = value),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 8,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 28,
                            color: scheme.onPrimaryContainer,
                          ),
                          Text(
                            widget.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: context.text.labelLarge?.copyWith(
                              color: scheme.onPrimaryContainer,
                            ),
                          ),
                        ],
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
