import 'dart:async';
import 'dart:io';
import 'dart:math' show max;
import 'dart:ui' as ui;

import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;

/// `flutter_image_compress` escala por `max(1, min(ancho / minWidth, alto / minHeight))`: esos
/// valores fijan el lado **menor**. Dar el mismo en ambos deja el lado mayor en [maxSide] y no
/// depende de si el plugin mide la foto antes o después de aplicar la rotación EXIF.
int compressionMinSide(int width, int height, {int maxSide = 1600}) {
  final long = max(width, height);
  final short = width + height - long;
  if (long <= maxSide) return short;
  return max(1, (short * maxSide / long).round());
}

/// Subida directa a Supabase Storage (docs/04-mobile-integration.md §3). El backend no recibe
/// archivos, solo la URL. [client] no es el autenticado: a Supabase no se le envía el JWT.
class SupabaseUploader {
  static const _quality = 80;
  static const _timeout = Duration(seconds: 60);

  final http.Client client;
  final String baseUrl;
  final String anonKey;
  final String bucket;
  final String notConfiguredMessage;
  final String uploadFailedMessage;

  SupabaseUploader({
    required this.client,
    required String baseUrl,
    required this.anonKey,
    required this.bucket,
    required this.notConfiguredMessage,
    required this.uploadFailedMessage,
  }) : baseUrl = baseUrl.endsWith('/')
           ? baseUrl.substring(0, baseUrl.length - 1)
           : baseUrl;

  /// Determinista: el payload de `ATTACH_*` se arma antes de subir la foto.
  String publicUrlFor(String storagePath) {
    return '$baseUrl/storage/v1/object/public/$bucket/$storagePath';
  }

  /// Con `x-upsert`: reintentar la misma ruta reemplaza el mismo objeto.
  Future<void> upload(File file, String storagePath) async {
    if (baseUrl.isEmpty || anonKey.isEmpty) {
      throw ApiException(
        httpStatus: 0,
        code: 'SUPABASE_NOT_CONFIGURED',
        message: notConfiguredMessage,
      );
    }
    final bytes = await file.readAsBytes();

    final http.Response response;
    try {
      response = await client
          .post(
            Uri.parse('$baseUrl/storage/v1/object/$bucket/$storagePath'),
            headers: {
              'Authorization': 'Bearer $anonKey',
              'apikey': anonKey,
              'x-upsert': 'true',
              'Content-Type': 'image/jpeg',
            },
            body: bytes,
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw const NetworkException();
    } on IOException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        httpStatus: response.statusCode,
        code: 'HTTP_${response.statusCode}',
        message: uploadFailedMessage,
      );
    }
  }

  /// JPEG con el lado mayor en 1600 px y calidad 80. Sin red ni sesión: corre al capturar.
  Future<File> compress(String sourcePath, File target) async {
    final buffer = await ui.ImmutableBuffer.fromFilePath(sourcePath);
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    final minSide = compressionMinSide(descriptor.width, descriptor.height);
    descriptor.dispose();
    buffer.dispose();

    await target.parent.create(recursive: true);
    final result = await FlutterImageCompress.compressAndGetFile(
      sourcePath,
      target.path,
      minWidth: minSide,
      minHeight: minSide,
      quality: _quality,
    );
    if (result == null) throw FileSystemException('No se comprimió', sourcePath);
    return target;
  }
}
