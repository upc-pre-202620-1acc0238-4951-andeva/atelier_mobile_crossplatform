import 'dart:convert';
import 'dart:io';

/// Backend mínimo para la prueba de dos motores (`integration_probe/`). Rota el refresh como
/// el real: reusar uno ya rotado responde 401. Uso: `dart run tool/sync_mock_server.dart [puerto]` y
/// `adb reverse tcp:8099 tcp:<puerto>`.
void main(List<String> args) async {
  final port = args.isEmpty ? 8099 : int.parse(args.first);
  var generation = 0;
  var access = _jwt(generation);
  var refresh = 'refresh-$generation';
  var refreshDelay = Duration.zero;
  var rotations = 0;

  void log(String line) {
    stdout.writeln('${DateTime.now().toIso8601String()} $line');
  }

  String session() => jsonEncode({
    'userId': 'probe-user',
    'email': 'probe@taller.pe',
    'fullName': 'Andrés Sonda',
    'token': access,
    'tokenType': 'Bearer',
    'permissions': ['operations:tasks:read'],
    'refreshToken': refresh,
    'membershipId': 'probe-membership',
    'activeTenant': {'id': 'probe-tenant', 'name': 'Taller', 'taxId': '1'},
    'plan': null,
  });

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  log('LISTENING $port');

  // En paralelo: los 401 de la UI deben llegar mientras otro motor está renovando.
  server.listen((request) async {
    final body = await utf8.decoder.bind(request).join();
    final path = request.uri.path;
    request.response.headers.contentType = ContentType.json;
    var status = 200;
    var answer = '{}';

    switch (path) {
      case '/control/session':
        answer = session();
      case '/control/expire':
        // Invalida el token de acceso sin rotar el refresh: el cliente recibirá 401.
        access = _jwt(++generation);
        refreshDelay = Duration(
          milliseconds:
              int.tryParse(request.uri.queryParameters['refreshDelayMs'] ?? '') ?? 0,
        );
        log('EXPIRE access; refreshDelay=${refreshDelay.inMilliseconds}ms');
      case '/api/v1/auth/refresh':
        final sent = (jsonDecode(body) as Map)['refreshToken'];
        log('REFRESH start sent=$sent valid=$refresh');
        await Future<void>.delayed(refreshDelay);
        if (sent == refresh) {
          rotations++;
          refresh = 'refresh-${++generation}';
          access = _jwt(generation);
          answer = session();
          log('REFRESH ok rotation#$rotations new=$refresh');
        } else {
          status = 401;
          answer = '{"code":"UNAUTHORIZED","message":"Refresh ya rotado"}';
          log('REFRESH REUSED -> 401 (cerraría la sesión)');
        }
      case '/api/v1/probe':
        final authorized = request.headers.value('authorization') == 'Bearer $access';
        log('PROBE $body authorized=$authorized');
        if (!authorized) {
          status = 401;
          answer = '{"code":"UNAUTHORIZED","message":"Token vencido"}';
        }
      default:
        status = 404;
    }

    request.response
      ..statusCode = status
      ..write(answer);
    await request.response.close();
  });
}

String _jwt(int generation) {
  final exp = DateTime.now().add(const Duration(hours: 24)).millisecondsSinceEpoch ~/ 1000;
  final payload = base64Url
      .encode(utf8.encode(jsonEncode({'exp': exp, 'gen': generation})))
      .replaceAll('=', '');
  return 'h.$payload.s';
}
