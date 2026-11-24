import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

/// Apertura y envío unificado de documentos descargados (directorio de caché `pdfs`): PDFs de proforma,
/// informe IA, flota, flujo de caja, pase de salida y comprobantes SUNAT (PDF, XML, CDR ZIP).
///
/// Android usa `FileProvider` por detrás de `open_filex` y `share_plus`; en iOS abre el visor de
/// documentos y la hoja de compartir del sistema (sin comprobar en una Mac). Devuelve `false` si no se
/// pudo abrir ni compartir.
abstract final class DocumentIntents {
  static const mimePdf = 'application/pdf';
  static const mimeXml = 'application/xml';
  static const mimeZip = 'application/zip';

  /// Abre el archivo con una app del sistema; si no hay ninguna que lo abra, abre la hoja de compartir.
  static Future<bool> openDocument(
    File file,
    String mimeType,
    String chooserTitle,
  ) async {
    try {
      final result = await OpenFilex.open(file.path, type: mimeType);
      switch (result.type) {
        case ResultType.done:
          return true;
        case ResultType.noAppToOpen:
          return await shareDocument(file, mimeType, chooserTitle);
        case ResultType.fileNotFound:
        case ResultType.permissionDenied:
        case ResultType.error:
          return false;
      }
    } on Exception {
      return false;
    }
  }

  /// Hoja de compartir del sistema con el archivo adjunto.
  static Future<bool> shareDocument(
    File file,
    String mimeType,
    String chooserTitle,
  ) async {
    try {
      if (!await file.exists()) return false;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: mimeType)],
          title: chooserTitle,
        ),
      );
      return true;
    } on Exception {
      return false;
    }
  }

  static Future<bool> openPdf(File file, String chooserTitle) =>
      openDocument(file, mimePdf, chooserTitle);

  static Future<bool> sharePdf(File file, String chooserTitle) =>
      shareDocument(file, mimePdf, chooserTitle);

  static Future<bool> openFile(
    File file,
    String mimeType,
    String chooserTitle,
  ) => openDocument(file, mimeType, chooserTitle);

  static Future<bool> shareFile(
    File file,
    String mimeType,
    String chooserTitle,
  ) => shareDocument(file, mimeType, chooserTitle);
}
