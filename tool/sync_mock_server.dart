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
      'operations:tasks:track_time',
      'operations:tasks:upload_photos',
      'operations:tasks:hold_request',
      'operations:tasks:hold_validate',
      'operations:tasks:complete',
      'operations:tasks:charge_parts',
      'operations:work_orders:update',
      'operations:bays:read',
      'crm:vehicles:read',
      'inventory:parts:read',
    ],
    'refreshToken': refresh,
    'membershipId': 'probe-membership',
    'activeTenant': {'id': 'probe-tenant', 'name': 'Taller', 'taxId': '1'},
    'plan': null,
  });

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  log('LISTENING $port');

  // En paralelo: los 401 de la UI deben llegar mientras otro motor está renovando.
  final tasks = _TasksBackend(log);

  server.listen((request) async {
    // En bytes: la subida a Supabase es un JPEG, no texto.
    final bytes = await request.fold(<int>[], (all, chunk) => all..addAll(chunk));
    final body = utf8.decode(bytes, allowMalformed: true);
    final path = request.uri.path;
    request.response.headers.contentType = ContentType.json;
    // Sin keep-alive: un socket abierto sobrevive a `adb reverse --remove` y el corte de red no sería real.
    request.response.persistentConnection = false;
    var status = 200;
    var answer = '{}';

    final handled = tasks.handle(request.method, path, body, bytes.length);
    if (handled != null) {
      request.response
        ..statusCode = handled.$1
        ..write(handled.$2);
      await request.response.close();
      return;
    }

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

/// Tareas, repuestos y Supabase del paso 5. Simula los huecos del backend tal como los documenta
/// docs/03-traceability.md (H9, H36–H39): no sirve para demostrar el contrato real.
class _TasksBackend {
  final void Function(String) log;
  final tasks = <String, Map<String, Object?>>{
    't1': _task('t1', 'wo1', 101, 'v1', 'ASSIGNED'),
    't2': _task('t2', 'wo2', 102, 'v1', 'IN_PROGRESS', startedAt: _nowUtc()),
    't3': _task('t3', 'wo3', 100, 'v2', 'ON_HOLD', holdReason: 'BREAK'),
  };
  final products = <String, List<Map<String, Object?>>>{};
  final evidence = <String, List<Map<String, Object?>>>{};
  var stock = 5.0;
  var ids = 0;

  _TasksBackend(this.log);

  static Map<String, Object?> _task(
    String id,
    String workOrderId,
    int number,
    String vehicleId,
    String status, {
    String? startedAt,
    String? holdReason,
  }) {
    return {
      'id': id,
      'workOrderId': workOrderId,
      'workOrderNumber': number,
      'workOrderStatus': 'IN_PROGRESS',
      'vehicleId': vehicleId,
      'branchId': 'probe-branch',
      'bayId': 'bay1',
      'status': status,
      'description': 'Tarea $id',
      'estimatedHours': 1.5,
      'startedAt': startedAt,
      'totalPausedSeconds': 0,
      'holdReason': holdReason,
      'missingItemDescription': null,
      'pendingSuspensionReason': null,
      'pendingSuspensionRequestedAt': null,
    };
  }

  String _detail(String id) {
    final task = tasks[id]!;
    return jsonEncode({
      ...task,
      'serviceId': 'srv1',
      'serviceName': 'Service', // H39
      'mechanicId': 'probe-membership',
      'mechanicName': 'Andrés Sonda',
      'price': 120.5,
      'currency': 'PEN',
      'completedAt': task['status'] == 'COMPLETED' ? _nowUtc() : null,
      'products': products[id] ?? [],
      'evidenceImages': evidence[id] ?? [],
    });
  }

  (int, String)? handle(String method, String path, String body, int size) {
    if (path.startsWith('/storage/v1/object/atelier/')) {
      log('UPLOAD ${path.split('/').last} bytes=$size');
      return (200, '{"Key":"ok"}');
    }
    if (path == '/api/v1/work-bays') {
      return (
        200,
        jsonEncode([
          {'id': 'bay1', 'branchId': 'probe-branch', 'name': 'Bahía 1', 'bayType': 'LIFT', 'status': 'OCCUPIED'},
        ]),
      );
    }
    if (path.startsWith('/api/v1/vehicles/')) {
      final id = path.split('/').last;
      return (
        200,
        jsonEncode({'id': id, 'plate': id == 'v1' ? 'ABC-123' : 'XYZ-789', 'brand': 'Toyota', 'model': 'Corolla'}),
      );
    }
    if (path == '/api/v1/inventory/items') {
      return (
        200,
        jsonEncode([
          {'id': 'p1', 'name': 'Filtro', 'sku': 'F1', 'basePrice': 25.5, 'totalStock': stock, 'unitOfMeasure': 'UNIT', 'status': 'ACTIVE'},
          {'id': 'p2', 'name': null, 'totalStock': 0},
        ]),
      );
    }
    if (path == '/api/v1/tasks/my') {
      log('TASKS_MY');
      final open = tasks.values.where(
        (t) => t['status'] != 'COMPLETED' && t['status'] != 'CANCELLED',
      );
      // Sin los campos de detalle, como `AssignedTaskResource`.
      return (
        200,
        jsonEncode([
          for (final t in open)
            {
              'taskId': t['id'],
              'workOrderId': t['workOrderId'],
              'workOrderNumber': t['workOrderNumber'],
              'workOrderStatus': t['workOrderStatus'],
              'vehicleId': t['vehicleId'],
              'branchId': t['branchId'],
              'bayId': t['bayId'],
              'status': t['status'],
              'description': t['description'],
              'estimatedHours': t['estimatedHours'],
              'startedAt': t['startedAt'],
              'totalPausedSeconds': t['totalPausedSeconds'],
            },
        ]),
      );
    }
    if (!path.startsWith('/api/v1/tasks/')) return null;

    final parts = path.substring('/api/v1/tasks/'.length).split('/');
    final id = parts.first;
    final task = tasks[id];
    if (task == null) return (404, '{"code":"NOT_FOUND","message":"Tarea no encontrada"}');
    final action = parts.skip(1).join('/');
    final sent = body.isEmpty ? const <String, dynamic>{} : jsonDecode(body) as Map<String, dynamic>;
    log('TASK $method $id/$action $body');

    switch (action) {
      case '':
        break;
      case 'start':
        if (task['holdReason'] == 'DEFECTIVE_PART') {
          return (422, '{"code":"SUSPENDED","message":"Solo un supervisor la levanta"}');
        }
        task['status'] = 'IN_PROGRESS';
        task['startedAt'] ??= _nowUtc();
        task['holdReason'] = null;
      case 'pause':
        if (sent['reason'] == 'END_OF_SHIFT') {
          return (422, '{"code":"SHIFT","message":"Tu turno termina a las 17:00; pausa por refrigerio"}');
        }
        task['status'] = 'ON_HOLD';
        task['holdReason'] = sent['reason'];
        task['totalPausedSeconds'] = (task['totalPausedSeconds'] as int) + 60;
      case 'hold':
        task['pendingSuspensionReason'] = sent['missingItemDescription'];
        task['pendingSuspensionRequestedAt'] = _nowUtc();
      case 'hold/approve':
        task['status'] = 'ON_HOLD';
        task['holdReason'] = 'DEFECTIVE_PART';
        task['missingItemDescription'] = task['pendingSuspensionReason'];
        task['pendingSuspensionReason'] = null;
        task['pendingSuspensionRequestedAt'] = null;
      case 'hold/reject':
        task['pendingSuspensionReason'] = null;
        task['pendingSuspensionRequestedAt'] = null;
      case 'resume':
        task['status'] = 'IN_PROGRESS';
        task['holdReason'] = null;
        task['missingItemDescription'] = null;
      case 'complete':
        task['status'] = 'COMPLETED';
      case 'evidence-images':
        final images = evidence.putIfAbsent(id, () => []);
        final url = sent['imageUrl'];
        final found = images.where((i) => i['imageUrl'] == url).firstOrNull; // R4
        log(found == null ? 'EVIDENCE nueva $url' : 'EVIDENCE repetida $url');
        final image = found ??
            {
              'id': 'img${++ids}',
              'taskId': id,
              'imageUrl': url,
              'description': sent['description'],
              'uploadedAt': _nowUtc(),
            };
        if (found == null) images.add(image);
        return (201, jsonEncode(image));
      case 'products':
        final quantity = (sent['quantity'] as num).toDouble();
        if (quantity > stock) {
          return (409, '{"code":"STOCK","message":"Stock insuficiente"}');
        }
        stock -= quantity;
        final line = {
          'id': 'line${++ids}',
          'taskId': id,
          'productId': sent['productId'],
          'productName': 'Product ${sent['productId']}', // H36
          'quantity': quantity,
          'unitPrice': 25.5,
          'totalAmount': 25.5 * quantity,
          'currency': 'PEN',
        };
        products.putIfAbsent(id, () => []).add(line);
        return (201, jsonEncode(line));
      default:
        if (parts.length == 3 && parts[1] == 'products') {
          if (method == 'DELETE') {
            // H37: devuelve el stock, pero la línea sigue en el detalle.
            final line = products[id]?.where((l) => l['productId'] == parts[2]).firstOrNull;
            if (line != null) stock += line['quantity'] as double;
            return (204, '');
          }
          // H9 y H38: responde una línea armada a mano y no cambia nada.
          return (200, jsonEncode({'id': 'aleatorio', 'name': 'Product ${parts[2]}', 'unitPrice': 0}));
        }
        return (404, '{"code":"NOT_FOUND","message":"Ruta no simulada"}');
    }
    return (200, _detail(id));
  }
}

String _nowUtc() => DateTime.now().toUtc().toIso8601String();

String _jwt(int generation) {
  final exp = DateTime.now().add(const Duration(hours: 24)).millisecondsSinceEpoch ~/ 1000;
  final payload = base64Url
      .encode(utf8.encode(jsonEncode({'exp': exp, 'gen': generation})))
      .replaceAll('=', '');
  return 'h.$payload.s';
}
