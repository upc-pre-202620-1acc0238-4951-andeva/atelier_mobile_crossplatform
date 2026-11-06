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
  Map<String, Object?>? attendance;
  var attendances = 0;

  void log(String line) {
    stdout.writeln('${DateTime.now().toIso8601String()} $line');
  }

  String session() => jsonEncode({
    'userId': 'probe-user',
    'email': 'probe@taller.pe',
    'fullName': 'Andrés Sonda',
    'token': access,
    'tokenType': 'Bearer',
    'permissions': [
      'operations:tasks:read',
      'iam:branches:read',
      'hr:attendance:clock_in',
      'hr:attendance:clock_out',
      'hr:attendance:read_own',
      'hr:shifts:read',
      'hr:justifications:create',
    ],
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
    // Sin keep-alive: un socket abierto sobrevive a `adb reverse --remove` y el corte de red no sería real.
    request.response.persistentConnection = false;
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
      case '/api/v1/hr/employees/membership/probe-membership':
        answer = jsonEncode({
          'id': 'probe-profile',
          'branchId': 'probe-branch',
          'assignedShiftId': 'probe-shift',
        });
      case '/api/v1/branches':
        answer = jsonEncode([
          {
            'id': 'probe-branch',
            'name': 'Sede Lima',
            'latitude': -12.0464,
            'longitude': -77.0428,
            'geofenceRadiusMeters': 100,
            'isActive': true,
          },
        ]);
      case '/api/v1/hr/work-shifts/probe-shift':
        answer = jsonEncode({
          'id': 'probe-shift',
          'name': 'Mañana',
          'startTime': '08:00:00',
          'endTime': '17:00:00',
          'gracePeriodMinutes': 15,
          'isActive': true,
          'restDays': ['SUNDAY'],
        });
      case '/api/v1/hr/attendances/clock-in':
        final sent = jsonDecode(body) as Map;
        log('CLOCK_IN $body');
        attendance = {
          'id': 'probe-attendance-${++attendances}',
          'branchId': sent['branchId'],
          'membershipId': 'probe-membership',
          'shiftId': sent['shiftId'],
          'clockIn': sent['clockInTime'] ?? _nowUtc(),
          'status': 'ON_TIME',
          'latitude': sent['latitude'],
          'longitude': sent['longitude'],
          'distanceToBranchMeters': 5.0,
        };
        status = 201;
        answer = jsonEncode(attendance);
      case '/api/v1/hr/attendances/clock-out':
        final sent = jsonDecode(body) as Map;
        log('CLOCK_OUT $body abierta=${attendance?['id']}');
        final open = attendance;
        if (open == null || open['clockOut'] != null) {
          status = 404;
          answer = '{"code":"NOT_FOUND","message":"Sin jornada abierta"}';
        } else {
          open['clockOut'] = sent['clockOutTime'] ?? _nowUtc();
          open['workedMinutes'] = 480;
          answer = jsonEncode(open);
        }
      case '/api/v1/hr/attendances/employee/probe-membership/status-today':
        log('STATUS_TODAY');
        final open = attendance;
        if (open == null || open['clockOut'] != null) {
          status = 404;
          answer = '{"code":"NOT_FOUND","message":"Sin jornada"}';
        } else {
          answer = jsonEncode(open);
        }
      case '/api/v1/hr/attendances/employee/probe-membership/history':
        log('HISTORY ${request.uri.query}');
        answer = jsonEncode([?attendance]);
      default:
        status = 404;
    }

    request.response
      ..statusCode = status
      ..write(answer);
    await request.response.close();
  });
}

String _nowUtc() => DateTime.now().toUtc().toIso8601String();

String _jwt(int generation) {
  final exp = DateTime.now().add(const Duration(hours: 24)).millisecondsSinceEpoch ~/ 1000;
  final payload = base64Url
      .encode(utf8.encode(jsonEncode({'exp': exp, 'gen': generation})))
      .replaceAll('=', '');
  return 'h.$payload.s';
}
