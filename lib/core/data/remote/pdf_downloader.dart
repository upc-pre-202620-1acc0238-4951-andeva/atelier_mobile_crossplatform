import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';

/// PDFs del backend (docs/04-mobile-integration.md §8). Abrirlo o compartirlo es de la UI.
class PdfDownloader {
  static const _directory = 'pdfs';

  final Future<Directory> Function() cacheDirectory;

  const PdfDownloader({required this.cacheDirectory});

  /// Lanza lo mismo que [call]: `ApiException` con el `message` del backend (p. ej. 422 del pase de
  /// salida de una orden sin pagar) o `NetworkException`.
  Future<File> download(
    String fallbackName,
    Future<ApiFile> Function() call,
  ) async {
    final response = await call();
    final directory = await cacheDirectory();
    final target = File(
      '${directory.path}/$_directory/'
      '${fileName(response.contentDisposition, fallbackName)}',
    );
    await target.parent.create(recursive: true);
    return target.writeAsBytes(response.bytes);
  }

  /// `filename*=UTF-8''…` gana a `filename="…"`; el resultado es seguro y termina en `.pdf`.
  static String fileName(String? contentDisposition, String fallbackName) {
    final parts = (contentDisposition ?? '').split(';').map((e) => e.trim());
    String? valueOf(String prefix) {
      for (final part in parts) {
        if (part.toLowerCase().startsWith(prefix)) {
          return part.substring(prefix.length);
        }
      }
      return null;
    }

    final raw = _decodeExtended(valueOf('filename*=')) ??
        valueOf('filename=')?.replaceAll('"', '');
    final name = raw?.split(RegExp(r'[/\\]')).last ?? '';
    final safe = (name.isEmpty ? fallbackName : name).replaceAll(
      RegExp(r'[^A-Za-z0-9._-]'),
      '_',
    );
    return safe.toLowerCase().endsWith('.pdf') ? safe : '$safe.pdf';
  }

  static String? _decodeExtended(String? value) {
    if (value == null) return null;
    final start = value.indexOf("''");
    try {
      return Uri.decodeComponent(start < 0 ? value : value.substring(start + 2));
    } on ArgumentError {
      return null; // Mal codificado: sirve el `filename=` o el nombre por defecto.
    } on FormatException {
      return null; // Bytes que no son UTF-8: lo mismo.
    }
  }
}
