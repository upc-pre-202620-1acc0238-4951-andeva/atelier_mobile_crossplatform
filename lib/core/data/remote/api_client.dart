import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:http/http.dart' as http;

/// Archivo descargado con `getBytes`.
class ApiFile {
  final Uint8List bytes;
  final String? contentDisposition;

  const ApiFile({required this.bytes, required this.contentDisposition});
}

/// Convierte cualquier error en una excepción de dominio. El timeout vive en AuthenticatedClient.
class ApiClient {
  final http.Client client;
  final String baseUrl;

  const ApiClient({required this.client, required this.baseUrl});

  Future<dynamic> get(
    String path, {
    Map<String, String>? query,
    Map<String, String>? headers,
  }) async {
    return _decode(
      await _send(() => client.get(_uri(path, query), headers: headers)),
    );
  }

  Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    return _decode(
      await _send(
        () => client.post(
          _uri(path, null),
          headers: _withJson(headers),
          body: body == null ? null : jsonEncode(body),
        ),
      ),
    );
  }

  Future<dynamic> put(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    return _decode(
      await _send(
        () => client.put(
          _uri(path, null),
          headers: _withJson(headers),
          body: body == null ? null : jsonEncode(body),
        ),
      ),
    );
  }

  Future<dynamic> patch(String path, {Object? body}) async {
    return _decode(
      await _send(
        () => client.patch(
          _uri(path, null),
          headers: _withJson(null),
          body: body == null ? null : jsonEncode(body),
        ),
      ),
    );
  }

  Future<dynamic> delete(String path, {Map<String, String>? headers}) async {
    return _decode(
      await _send(() => client.delete(_uri(path, null), headers: headers)),
    );
  }

  /// PDFs del backend (04 §8).
  Future<ApiFile> getBytes(String path, {Map<String, String>? query}) async {
    final response = await _send(() => client.get(_uri(path, query)));
    return ApiFile(
      bytes: response.bodyBytes,
      contentDisposition: response.headers['content-disposition'],
    );
  }

  Uri _uri(String path, Map<String, String>? query) {
    return Uri.parse('$baseUrl$path').replace(queryParameters: query);
  }

  Map<String, String> _withJson(Map<String, String>? headers) {
    return {'Content-Type': 'application/json', ...?headers};
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    final http.Response response;
    try {
      response = await call();
    } on TimeoutException {
      throw const NetworkException('El servidor no respondió');
    } on IOException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }
    throw _toApiException(response);
  }

  /// Siempre UTF-8: `response.body` dañaría las tildes si el servidor no declara el `charset`.
  dynamic _decode(http.Response response) {
    final text = utf8.decode(response.bodyBytes);
    return text.isEmpty ? null : jsonDecode(text); // 204 → null
  }

  ApiException _toApiException(http.Response response) {
    Object? json;
    try {
      json = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      json = null; // Render o un proxy pueden responder HTML.
    }
    final map = json is Map ? json : const {};
    final code = map['code'];
    final message = map['message'];
    final details = map['details'];
    return ApiException(
      httpStatus: response.statusCode,
      code: code is String ? code : 'UNKNOWN',
      message: message is String ? message : 'Error del servidor',
      details: details is List ? details.whereType<String>().toList() : const [],
    );
  }
}
