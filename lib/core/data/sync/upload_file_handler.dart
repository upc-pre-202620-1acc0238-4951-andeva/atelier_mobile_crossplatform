import 'dart:convert';
import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/operation_handler.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_upload_dao.dart';
import 'package:atelier_mobile_crossplatform/core/media/supabase_uploader.dart';

/// Sube la foto guardada en soporte/pending. La `ATTACH_*` que depende de esta ya lleva la URL
/// pública en su payload (es determinista), así que solo espera a que esta termine.
class UploadFileHandler implements OperationHandler {
  static const type = 'UPLOAD_FILE';

  final PendingUploadDao dao;
  final SupabaseUploader uploader;
  final Future<Directory> Function() supportDirectory;
  final String missingPhotoMessage;
  final String uploadFailedMessage;

  const UploadFileHandler({
    required this.dao,
    required this.uploader,
    required this.supportDirectory,
    required this.missingPhotoMessage,
    required this.uploadFailedMessage,
  });

  @override
  Future<OperationResult> send(PendingOperationEntity operation) async {
    final uploadId = (jsonDecode(operation.payload) as Map)['uploadId'] as String;
    final upload = await dao.findById(uploadId);
    if (upload == null) return const Applied(); // Ya se subió antes.

    // Relativa: en iOS la carpeta de la app cambia al actualizarla.
    final directory = await supportDirectory();
    final file = File('${directory.path}/${upload.localFilePath}');
    if (!await file.exists()) {
      return Failed(code: 'FILE_NOT_FOUND', message: missingPhotoMessage);
    }

    final result = await OperationResult.from(
      () => uploader.upload(file, upload.storagePath),
    );
    if (result is Applied) {
      // Primero la fila: un corte entre ambos deja un archivo huérfano, no una foto "perdida".
      await dao.deleteById(upload.id);
      await file.delete();
    }
    // Este 401 es de la anon key, no de la sesión: no debe detener el resto de la cola.
    if (result is Unauthorized) {
      return Failed(
        httpStatus: 401,
        code: 'HTTP_401',
        message: uploadFailedMessage,
      );
    }
    return result;
  }
}
