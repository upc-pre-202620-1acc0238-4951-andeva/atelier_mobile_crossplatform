import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_queue.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_upload_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/upload_file_handler.dart';
import 'package:atelier_mobile_crossplatform/core/media/storage_paths.dart';
import 'package:atelier_mobile_crossplatform/core/media/supabase_uploader.dart';

/// Fotos sin señal (docs/06-offline-sync.md §6): comprimir → soporte/pending → `pending_uploads` →
/// `UPLOAD_FILE` + la `ATTACH_*` de la feature. Va siempre por la cola, con o sin red. Se guarda la
/// copia: el sistema puede borrar la ruta temporal de `image_picker`.
class PhotoCapture {
  final SupabaseUploader uploader;
  final PendingUploadDao uploadDao;
  final PendingOperationQueue queue;
  final SessionManager session;
  final Future<Directory> Function() supportDirectory;
  final DateTime Function() now;

  PhotoCapture({
    required this.uploader,
    required this.uploadDao,
    required this.queue,
    required this.session,
    required this.supportDirectory,
    this.now = DateTime.now,
  });

  static String uploadDedupeKey(String photoId) => 'UPLOAD_FILE:$photoId';

  /// Devuelve el id de la foto: con él la feature reconoce sus fotos en cola (06 §7).
  Future<String> capture({
    required String photoPath,
    required String target,
    required String Function(String tenantId, String photoId) storagePath,
    required String attachType,
    required String Function(String photoId) attachDedupeKey,
    required Object Function(String imageUrl) attachPayload,
  }) async {
    final current = await session.getSession();
    if (current == null) throw StateError('No se puede capturar sin sesión');

    final photoId = StoragePaths.newId();
    final relativePath = 'pending/$photoId.jpg';
    final directory = await supportDirectory();
    await uploader.compress(
      photoPath,
      File('${directory.path}/$relativePath'),
    );
    final path = storagePath(current.tenantId, photoId);
    await uploadDao.insert(
      PendingUploadsCompanion.insert(
        id: photoId,
        localFilePath: relativePath,
        storagePath: path,
        target: target,
        createdAt: now().millisecondsSinceEpoch,
      ),
    );

    // Sin disparar hasta encolar las dos: si la subida fallara antes de existir la `ATTACH_*`, la
    // cascada no la vería y quedaría esperando para siempre a un padre en FAILED.
    // shortcut: no es una transacción; si matan la app justo entre ambas, la foto sube sin
    // adjuntarse (igual en Android). Unir las inserciones si aparece en producción.
    final uploadId = await queue.enqueue(
      type: UploadFileHandler.type,
      payload: {'uploadId': photoId},
      dedupeKey: uploadDedupeKey(photoId),
      dispatch: false,
    );
    await queue.enqueue(
      type: attachType,
      payload: attachPayload(uploader.publicUrlFor(path)),
      dedupeKey: attachDedupeKey(photoId),
      dependsOn: uploadId,
    );
    return photoId;
  }
}
