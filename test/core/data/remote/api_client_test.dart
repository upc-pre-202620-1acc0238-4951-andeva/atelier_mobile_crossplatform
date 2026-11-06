import 'dart:convert';
import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

ApiClient _client(MockClientHandler handler) {
  return ApiClient(client: MockClient(handler), baseUrl: 'https://api.test');
}

http.Response _bytes(String body, int status, {Map<String, String>? headers}) {
  return http.Response.bytes(utf8.encode(body), status, headers: headers ?? {});
}

void main() {
  test('decodifica UTF-8 aunque el servidor no declare charset', () async {
    final client = _client((_) async => _bytes('{"name":"Vílchez"}', 200));
    final json = await client.get('/x');
    expect(json['name'], 'Vílchez');
  });

  test('204 devuelve null', () async {
    final client = _client((_) async => http.Response('', 204));
    expect(await client.put('/x', body: {'fcmToken': null}), null);
  });

  test('un cuerpo con null lo envía tal cual', () async {
    late String sent;
    final client = _client((request) async {
      sent = request.body;
      return http.Response('', 204);
    });
    await client.put('/x', body: {'fcmToken': null});
    expect(sent, '{"fcmToken":null}');
  });

  test('error del backend queda como ApiException con su message', () async {
    final client = _client(
      (_) async => _bytes(
        '{"code":"CONFLICT","message":"Stock insuficiente","details":["a: b"]}',
        409,
      ),
    );
    await expectLater(
      client.post('/x', body: {}),
      throwsA(
        isA<ApiException>()
            .having((e) => e.httpStatus, 'httpStatus', 409)
            .having((e) => e.code, 'code', 'CONFLICT')
            .having((e) => e.toString(), 'message', 'Stock insuficiente')
            .having((e) => e.details, 'details', ['a: b']),
      ),
    );
  });

  test('un error que no es JSON ni objeto no revienta', () async {
    for (final body in ['<html>Bad gateway</html>', '["x"]', '{"code":1}']) {
      final client = _client((_) async => _bytes(body, 502));
      await expectLater(
        client.get('/x'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.httpStatus, 'httpStatus', 502)
              .having((e) => e.code, 'code', 'UNKNOWN')
              .having((e) => e.message, 'message', 'Error del servidor'),
        ),
      );
    }
  });

  test('sin red, TLS o cliente caído son NetworkException', () async {
    final errors = <Exception>[
      const SocketException('sin red'),
      const TlsException('tls'),
      http.ClientException('cerrado'),
    ];
    for (final error in errors) {
      final client = _client((_) async => throw error);
      await expectLater(client.get('/x'), throwsA(isA<NetworkException>()));
    }
  });

  test('getBytes entrega el archivo y Content-Disposition', () async {
    final client = _client(
      (_) async => _bytes(
        '%PDF',
        200,
        headers: {'content-disposition': 'attachment; filename="a.pdf"'},
      ),
    );
    final file = await client.getBytes('/pdf');
    expect(utf8.decode(file.bytes), '%PDF');
    expect(file.contentDisposition, 'attachment; filename="a.pdf"');
  });
}
