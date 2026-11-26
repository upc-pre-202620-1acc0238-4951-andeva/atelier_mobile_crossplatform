import 'dart:io';

/// Purga archivos temporales sensibles al cerrar sesión (US04): los PDF y documentos fiscales descargados
/// (`<temp>/pdfs`) y las capturas de cámara que quedaron en caché (`<temp>/capture`). Las fotos que esperan
/// subir están en el soporte de la app (`pending/`), no aquí, y se conservan con su cola.
class TempCacheCleaner {
  static const sensitiveDirectories = ['pdfs', 'capture'];

  final Future<Directory> Function() temporaryDirectory;

  const TempCacheCleaner({required this.temporaryDirectory});

  /// Nunca lanza: un archivo que no se pudo borrar no debe impedir cerrar sesión.
  Future<void> clearSensitiveTempFiles() async {
    try {
      final root = await temporaryDirectory();
      for (final name in sensitiveDirectories) {
        try {
          final directory = Directory('${root.path}/$name');
          if (await directory.exists()) await directory.delete(recursive: true);
        } on FileSystemException {
          // Se reintenta en el próximo cierre.
        }
      }
    } on Object {
      // Sin directorio temporal (p. ej. en pruebas) no hay nada que purgar.
    }
  }
}
