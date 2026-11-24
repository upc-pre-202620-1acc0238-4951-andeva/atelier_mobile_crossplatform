import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/pending_work_order_capture.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';

const _keep = Object();

/// Paneles de la inspección de recepción (US13). [storedLabel] abre la descripción de la foto en el backend,
/// que no tiene un campo de posición (docs/api/operations.md): así se reconoce a qué panel pertenece cada foto.
enum InspectionAngle {
  front('Frente'),
  rear('Trasera'),
  left('Lateral izquierdo'),
  right('Lateral derecho'),
  roof('Techo'),
  dashboard('Tablero'),
  other('Otra foto');

  final String storedLabel;

  const InspectionAngle(this.storedLabel);

  /// Descripción que se guarda: el panel y, si hay, la nota del daño.
  static String describe(InspectionAngle angle, String note) {
    final trimmed = note.trim();
    return trimmed.isEmpty ? angle.storedLabel : '${angle.storedLabel}: $trimmed';
  }

  String label(AppLocalizations strings) => switch (this) {
    InspectionAngle.front => strings.galleryAngleFront,
    InspectionAngle.rear => strings.galleryAngleRear,
    InspectionAngle.left => strings.galleryAngleLeft,
    InspectionAngle.right => strings.galleryAngleRight,
    InspectionAngle.roof => strings.galleryAngleRoof,
    InspectionAngle.dashboard => strings.galleryAngleDashboard,
    InspectionAngle.other => strings.galleryAngleOther,
  };
}

enum PhotoStatus { uploaded, queued, failed }

/// Foto de la galería: la que ya está en el backend o la que espera señal ([localPath] o [remoteUrl]).
class GalleryPhoto {
  final String key;
  final String? localPath;
  final String? remoteUrl;
  final String? description;
  final PhotoStatus status;

  const GalleryPhoto({
    required this.key,
    this.localPath,
    this.remoteUrl,
    this.description,
    required this.status,
  });

  bool _matches(InspectionAngle angle) => description?.startsWith(angle.storedLabel) ?? false;
}

class IntakeGalleryUiState {
  static const _failed = 'FAILED';

  final String note;
  final List<IntakeImage> uploaded;
  final List<PendingIntakePhoto> pending;
  final bool isLoading;
  final bool isSaving;
  final UiText? error;
  final bool canUpload;
  final bool canRead;

  const IntakeGalleryUiState({
    this.note = '',
    this.uploaded = const [],
    this.pending = const [],
    this.isLoading = true,
    this.isSaving = false,
    this.error,
    this.canUpload = false,
    this.canRead = false,
  });

  /// En cola primero (lo último que tomó el usuario) y luego las ya registradas.
  List<GalleryPhoto> get photos => [
    for (final photo in pending)
      GalleryPhoto(
        key: photo.operationId,
        localPath: photo.localFilePath,
        remoteUrl: photo.imageUrl,
        description: photo.description,
        status: photo.status == _failed ? PhotoStatus.failed : PhotoStatus.queued,
      ),
    for (final image in uploaded)
      GalleryPhoto(
        key: image.id,
        remoteUrl: image.imageUrl,
        description: image.description,
        status: PhotoStatus.uploaded,
      ),
  ];

  List<GalleryPhoto> photosFor(InspectionAngle angle) {
    final all = photos;
    if (angle == InspectionAngle.other) {
      return all
          .where(
            (photo) =>
                InspectionAngle.values.every((a) => a == InspectionAngle.other || !photo._matches(a)),
          )
          .toList();
    }
    return all.where((photo) => photo._matches(angle)).toList();
  }

  IntakeGalleryUiState copyWith({
    String? note,
    List<IntakeImage>? uploaded,
    List<PendingIntakePhoto>? pending,
    bool? isLoading,
    bool? isSaving,
    Object? error = _keep,
    bool? canUpload,
    bool? canRead,
  }) {
    return IntakeGalleryUiState(
      note: note ?? this.note,
      uploaded: uploaded ?? this.uploaded,
      pending: pending ?? this.pending,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: identical(error, _keep) ? this.error : error as UiText?,
      canUpload: canUpload ?? this.canUpload,
      canRead: canRead ?? this.canRead,
    );
  }
}
