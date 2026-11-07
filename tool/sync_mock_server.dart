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
      'crm:customers:read',
      'crm:appointments:read',
      'operations:work_orders:read',
      'operations:services:read',
      'iam:members:read',
      'inventory:batches:read',
      'inventory:batches:receive',
      'inventory:purchase_orders:read',
      'inventory:alerts:read',
      'iot:devices:read',
      'iot:installations:manage',
      'iot:telemetry:ingest',
      'iot:faults:read',
      'iot:faults:resolve',
      'iot:health_reports:generate',
      'iot:health_reports:read',
      'iot:alerts:read',
      'iot:alerts:acknowledge',
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
  final reception = _ReceptionBackend(log);
  final inventory = _InventoryBackend(log);
  final iot = _IotBackend(log);

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

    // Primero recepción: `by-plate` y `POST /vehicles` también empiezan por `/api/v1/vehicles`.
    final handled =
        iot.handle(request.method, request.uri, body) ??
        inventory.handle(request.method, request.uri, body) ??
        reception.handle(request.method, request.uri, body) ??
        tasks.handle(request.method, path, body, bytes.length);
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

/// Recepción y órdenes del paso 6. Simula H10 (la orden llega después de `/arrive`, con kilometraje
/// 0) y R4 (idempotencia por `imageUrl`): no sirve para demostrar el contrato real.
class _ReceptionBackend {
  static const _branch = 'probe-branch';

  final void Function(String) log;
  final vehicles = <String, Map<String, Object?>>{
    'rv1': {'id': 'rv1', 'plate': 'RCP123', 'brand': 'Kia', 'model': 'Rio', 'engineType': 'GASOLINE', 'currentOwnerId': 'rc1', 'currentMileage': 1000},
    'rv2': {'id': 'rv2', 'plate': 'CIT456', 'brand': 'Nissan', 'model': 'Versa', 'engineType': 'GASOLINE', 'currentOwnerId': 'rc1'},
  };
  final customers = <String, Map<String, Object?>>{
    'rc1': {'id': 'rc1', 'type': 'INDIVIDUAL', 'displayName': 'Ana Pérez', 'taxId': '12345678', 'email': 'ana@correo.pe', 'status': 'ACTIVE'},
  };
  final appointments = <String, Map<String, Object?>>{};
  final orders = <String, Map<String, Object?>>{};
  final proposals = <String, Map<String, Object?>>{};
  var ids = 0;

  _ReceptionBackend(this.log) {
    appointments['ra1'] = {
      'id': 'ra1',
      'branchId': _branch,
      'customerId': 'rc1',
      'vehicleId': 'rv2',
      'scheduledAt': _nowUtc(),
      'estimatedDurationMinutes': 60,
      'reason': 'Mantenimiento',
      'status': 'CONFIRMED',
    };
    _newOrder('rv1', 'rc1', 45000, 'Combustible: 3/4. Ruido al frenar', id: 'rw1');
    _newOrder('rv1', 'rc1', 0, null, id: 'rw-pagada', status: 'PAID');
  }

  Map<String, Object?> _newOrder(
    String vehicleId,
    String customerId,
    int mileage,
    String? diagnostic, {
    String? id,
    String status = 'DRAFT',
  }) {
    final order = <String, Object?>{
      'id': id ?? 'rw${++ids + 1}',
      'internalNumber': 200 + orders.length,
      'vehicleId': vehicleId,
      'customerId': customerId,
      'branchId': _branch,
      'currentBayId': null,
      'mileageIn': mileage,
      'diagnosticSummary': diagnostic,
      'status': status,
      'subtotal': 0,
      'taxAmount': 0,
      'totalAmount': 0,
      'currency': 'PEN',
      'tasks': <Map<String, Object?>>[],
      'proposals': <Map<String, Object?>>[],
      'intakeImages': <Map<String, Object?>>[],
      'createdAt': _nowUtc(),
      'updatedAt': _nowUtc(),
    };
    orders[order['id'] as String] = order;
    return order;
  }

  /// La lista no trae subtotal, IGV, kilometraje, diagnóstico ni detalle.
  Map<String, Object?> _summary(Map<String, Object?> order) {
    return {
      for (final key in ['id', 'internalNumber', 'vehicleId', 'customerId', 'branchId', 'currentBayId', 'status', 'totalAmount', 'currency'])
        key: order[key],
    };
  }

  /// Las acciones devuelven la cabecera, sin tareas, propuestas ni fotos.
  Map<String, Object?> _resource(Map<String, Object?> order) {
    return {...order}
      ..remove('tasks')
      ..remove('proposals')
      ..remove('intakeImages');
  }

  void _recalculate(Map<String, Object?> order) {
    final tasks = order['tasks'] as List;
    final subtotal = tasks.fold<num>(0, (sum, t) => sum + ((t as Map)['price'] as num? ?? 0));
    order['subtotal'] = subtotal;
    order['taxAmount'] = subtotal * 0.18;
    order['totalAmount'] = subtotal * 1.18;
  }

  Map<String, Object?> _task(String orderId, Map<String, dynamic> sent) {
    return {
      'id': 'rt${++ids}',
      'workOrderId': orderId,
      'serviceId': sent['serviceId'],
      'serviceName': 'Service', // H11
      'mechanicId': sent['mechanicId'],
      'mechanicName': null,
      'status': 'ASSIGNED',
      'description': sent['description'],
      'price': sent['price'] ?? sent['finalPrice'],
      'currency': 'PEN',
      'totalPausedSeconds': 0,
      'products': <Object?>[],
      'evidenceImages': <Object?>[],
    };
  }

  (int, String) _ok(Object? value, [int status = 200]) => (status, jsonEncode(value));

  (int, String) _error(int status, String message) {
    return (status, jsonEncode({'code': 'PROBE', 'message': message}));
  }

  (int, String)? handle(String method, Uri uri, String body) {
    final path = uri.path;
    final isMine =
        path.startsWith('/api/v1/customers') ||
        path.startsWith('/api/v1/appointments') ||
        path.startsWith('/api/v1/work-orders') ||
        path.startsWith('/api/v1/vehicles/by-plate/') ||
        path.startsWith('/api/v1/vehicles/rv') ||
        path == '/api/v1/vehicles' ||
        path == '/api/v1/services' ||
        path == '/api/v1/hr/employees/branch/$_branch' ||
        (method == 'PUT' && path.startsWith('/api/v1/tasks/rt'));
    if (!isMine) return null;
    final sent = body.isEmpty ? const <String, dynamic>{} : jsonDecode(body) as Map<String, dynamic>;
    log('RECEPTION $method ${uri.toString()} $body');

    if (path.startsWith('/api/v1/vehicles/by-plate/')) {
      final plate = Uri.decodeComponent(path.split('/').last);
      final found = vehicles.values.where((v) => v['plate'] == plate).firstOrNull;
      return found == null ? _error(404, 'Vehículo no encontrado') : _ok(found);
    }
    if (path == '/api/v1/vehicles') {
      if (vehicles.values.any((v) => v['plate'] == sent['plate'])) {
        return _error(409, 'La placa ya existe');
      }
      final id = 'rv${++ids + 10}';
      return _ok(vehicles[id] = {'id': id, ...sent, 'currentOwnerId': sent['customerId']}, 201);
    }
    if (path.startsWith('/api/v1/vehicles/rv')) {
      final found = vehicles[path.split('/').last];
      return found == null ? _error(404, 'Vehículo no encontrado') : _ok(found);
    }
    if (path == '/api/v1/services') {
      return _ok([
        {'id': 'srv1', 'name': 'Cambio de aceite', 'basePrice': 80.5, 'currency': 'PEN', 'estimatedMinutes': 30},
      ]);
    }
    if (path.startsWith('/api/v1/hr/employees/branch/')) {
      return _ok([
        {'id': 'e1', 'membershipId': 'probe-membership', 'jobTitle': 'Mecánico', 'employmentStatus': 'ACTIVE'},
        {'id': 'e2', 'membershipId': 'baja', 'jobTitle': 'Mecánico', 'employmentStatus': 'TERMINATED'},
      ]);
    }
    if (path.startsWith('/api/v1/customers')) return _customers(method, path, uri, sent);
    if (path.startsWith('/api/v1/appointments')) return _appointments(method, path);
    if (path.startsWith('/api/v1/tasks/')) return _updateTask(path, sent);
    return _workOrders(method, path, sent);
  }

  (int, String) _customers(String method, String path, Uri uri, Map<String, dynamic> sent) {
    final rest = path.substring('/api/v1/customers'.length);
    switch ('$method $rest') {
      case 'GET ':
        final query = (uri.queryParameters['search'] ?? '').toLowerCase();
        return _ok(customers.values.where((c) {
          return '${c['displayName']} ${c['taxId']}'.toLowerCase().contains(query);
        }).toList());
      case 'POST /individuals':
      case 'POST /companies':
        if (customers.values.any((c) => c['taxId'] == sent['taxId'])) {
          return _error(409, 'El documento ya existe');
        }
        final id = 'rc${++ids + 10}';
        return _ok(customers[id] = {
          'id': id,
          ...sent,
          'type': rest == '/companies' ? 'COMPANY' : 'INDIVIDUAL',
          'displayName': sent['companyName'] ?? '${sent['firstName']} ${sent['lastName']}',
          'status': 'ACTIVE',
        }, 201);
      case 'GET /affiliation-lookup':
        final email = uri.queryParameters['email'];
        final known = customers.values.where((c) => c['email'] == email).firstOrNull;
        if (known != null) return _ok({'workshopCustomer': known, 'nextStep': 'ALREADY_CUSTOMER'});
        if (email == 'app@correo.pe') {
          return _ok({
            'platformAccount': {'userId': 'pu1', 'email': email, 'fullName': 'Luz App'},
            'vehicles': [
              {'id': 'rv3', 'plate': 'APP789', 'brand': 'Mazda', 'model': '3'},
            ],
            'nextStep': 'AFFILIATE',
          });
        }
        return _ok({'nextStep': 'REGISTER_WALK_IN'});
      case 'POST /affiliations':
        final id = 'rc${++ids + 10}';
        vehicles['rv3'] = {'id': 'rv3', 'plate': 'APP789', 'brand': 'Mazda', 'model': '3', 'currentOwnerId': id};
        return _ok(customers[id] = {
          'id': id,
          'type': 'INDIVIDUAL',
          'displayName': 'Luz App',
          'email': sent['email'],
          'taxId': sent['taxId'],
          'status': 'ACTIVE',
        }, 201);
    }
    final parts = rest.substring(1).split('/');
    if (!customers.containsKey(parts.first)) return _error(404, 'Cliente no encontrado');
    if (parts.length == 2 && parts[1] == 'vehicles') {
      return _ok(vehicles.values.where((v) => v['currentOwnerId'] == parts.first).toList());
    }
    return _ok(customers[parts.first]);
  }

  (int, String) _appointments(String method, String path) {
    if (method == 'GET') return _ok(appointments.values.toList());
    final appointment = appointments[path.split('/')[4]];
    if (appointment == null) return _error(404, 'Cita no encontrada');
    if (appointment['status'] == 'ARRIVED') return _error(409, 'La cita ya llegó');
    appointment['status'] = 'ARRIVED';
    // H10: la respuesta no trae la orden; aparece después, en borrador y con kilometraje 0.
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      final order = _newOrder(appointment['vehicleId'] as String, appointment['customerId'] as String, 0, null);
      log('ORDEN asíncrona ${order['id']} de ${appointment['id']}');
    });
    return _ok(appointment);
  }

  (int, String) _updateTask(String path, Map<String, dynamic> sent) {
    final id = path.split('/').last;
    for (final order in orders.values) {
      for (final task in (order['tasks'] as List).cast<Map<String, Object?>>()) {
        if (task['id'] != id) continue;
        task.addAll(sent);
        _recalculate(order);
        return _ok(task);
      }
    }
    return _error(404, 'Tarea no encontrada');
  }

  (int, String) _workOrders(String method, String path, Map<String, dynamic> sent) {
    if (path == '/api/v1/work-orders') {
      if (method == 'GET') return _ok(orders.values.map(_summary).toList());
      if (sent.containsKey('appointmentId')) return _error(409, 'H10: no se manda appointmentId');
      final vehicleId = sent['vehicleId'] as String;
      final open = orders.values.any((o) {
        return o['vehicleId'] == vehicleId && o['status'] != 'PAID' && o['status'] != 'CANCELED';
      });
      if (open) return _error(409, 'El vehículo ya tiene una orden abierta');
      return _ok(
        _resource(_newOrder(vehicleId, sent['customerId'] as String, sent['mileageIn'] as int, sent['diagnosticSummary'] as String?)),
        201,
      );
    }
    final parts = path.substring('/api/v1/work-orders/'.length).split('/');
    final order = orders[parts.first];
    if (order == null) return _error(404, 'Orden no encontrada');
    final action = parts.skip(1).join('/');
    final images = (order['intakeImages'] as List).cast<Map<String, Object?>>();
    final found = (order['proposals'] as List).cast<Map<String, Object?>>();

    switch ('$method $action') {
      case 'GET ':
        return _ok(order);
      case 'PUT ':
        order.addAll(sent);
        return _ok(_resource(order));
      case 'POST tasks':
        final task = _task(parts.first, sent);
        (order['tasks'] as List).add(task);
        _recalculate(order);
        return _ok(task, 201);
      case 'POST intake-images':
        final url = sent['imageUrl'];
        final repeated = images.where((i) => i['imageUrl'] == url).firstOrNull; // R4
        log(repeated == null ? 'INTAKE nueva $url' : 'INTAKE repetida $url');
        if (repeated != null) return _ok(repeated, 201);
        final image = {'id': 'ri${++ids}', 'imageUrl': url, 'description': sent['description'], 'uploadedAt': _nowUtc()};
        images.add(image);
        return _ok(image, 201);
      case 'POST proposals':
        if (sent['severity'] == 'HIGH') return _error(400, 'Severidad no admitida');
        final url = sent['imageUrl'];
        final repeated = found.where((p) => p['imageUrl'] == url).firstOrNull; // R4
        log(repeated == null ? 'PROPUESTA nueva $url' : 'PROPUESTA repetida $url');
        if (repeated != null) return _ok(repeated, 201);
        final proposal = <String, Object?>{
          'id': 'rp${++ids}',
          'workOrderId': parts.first,
          'mechanicId': sent['mechanicId'],
          'serviceId': sent['suggestedServiceId'],
          'description': sent['description'],
          'severity': sent['severity'],
          'imageUrl': url,
          'status': 'PENDING_REVIEW',
          'createdAt': _nowUtc(),
        };
        found.add(proposal);
        return _ok(proposal, 201);
      case 'GET quotation/pdf':
        return (200, '%PDF-1.4 proforma de la sonda');
      case 'POST quotation/send':
        return _ok({'message': 'Enviada', 'recipient': 'ana@correo.pe'});
      case 'POST quotation/approve':
        return _ok(_resource(order));
      case 'POST quotation/reject':
      case 'POST cancel':
        order['status'] = 'CANCELED';
        return _ok(_resource(order));
      case 'POST start':
        if (order['status'] != 'DRAFT') return _error(422, 'Solo se inicia una orden en borrador');
        order['status'] = 'IN_PROGRESS';
        return _ok(_resource(order));
      case 'POST complete':
        order['status'] = 'COMPLETED';
        return _ok(_resource(order));
      case 'GET part-movements':
        return _ok([
          {'allocationId': 'al1', 'productId': 'p1', 'chargedQuantity': 2, 'returnedQuantity': 1, 'unitCost': 10.5, 'currency': 'PEN'},
        ]);
      case 'GET profitability':
        return _ok({
          'workOrderId': parts.first,
          'laborRevenue': 100,
          'partsRevenue': 10,
          'partsCostOfSales': 22.5,
          'partsGrossProfit': -12.5,
          'subtotal': 110,
          'currency': 'PEN',
          'lines': [
            {'productId': 'p1', 'quantity': 1, 'revenue': 10, 'costOfSales': 22.5, 'grossProfit': -12.5},
          ],
        });
    }
    if (parts.length == 4 && parts[1] == 'proposals') {
      final proposal = found.where((p) => p['id'] == parts[2]).firstOrNull;
      if (proposal == null) return _error(404, 'Propuesta no encontrada');
      switch (parts[3]) {
        case 'notify':
          return _ok({'message': 'Enviada', 'recipient': 'ana@correo.pe'});
        case 'approve':
          proposal['status'] = 'APPROVED';
          final task = _task(parts.first, {...sent, 'description': proposal['description']});
          (order['tasks'] as List).add(task);
          _recalculate(order);
          return _ok(task, 201);
        case 'reject':
          proposal['status'] = 'REJECTED';
          proposal['customerNotes'] = sent['customerNotes'];
          return _ok(proposal);
      }
    }
    return _error(404, 'Ruta no simulada: $method $action');
  }
}

/// IoT del paso 8. Simula R3 (`POST /faults` devuelve el DTC ya activo), resolver dos veces con 200, H16 (lote
/// sin instalación activa: 404) y la deduplicación de lecturas por vehículo + `timestamp`, tal como los
/// documenta docs/api/iot.md. `v-sin-escaner` no tiene instalación; `v-corto` da 422 y `v-sin-cuota` 403.
class _IotBackend {
  static const _base = '/api/v1/iot';

  final void Function(String) log;
  final Map<String, Map<String, Object?>> faults = {};
  final Map<String, Set<String>> readings = {};
  final Map<String, Object?> installations = {};
  var faultSeq = 0;
  var batches = 0;
  var duplicates = 0;
  var faultPosts = 0;
  var resolves = 0;
  var generated = 0;

  _IotBackend(this.log);

  (int, String) _error(int status, String code, String message) {
    return (status, jsonEncode({'code': code, 'message': message, 'details': []}));
  }

  Map<String, Object?> _installation(String vehicleId, Map sent) {
    return {
      'id': 'inst-$vehicleId',
      'deviceId': sent['deviceId'],
      'vehicleId': vehicleId,
      'installedAt': _nowUtc(),
      'initialOdometerKm': sent['currentOdometerKm'],
      'isActive': true,
    };
  }

  (int, String)? handle(String method, Uri uri, String body) {
    final path = uri.path;
    if (path == '/control/iot') {
      return (
        200,
        jsonEncode({
          'batches': batches,
          'readings': {
            for (final entry in readings.entries) entry.key: entry.value.length,
          },
          'duplicates': duplicates,
          'faultPosts': faultPosts,
          'resolves': resolves,
          'generated': generated,
          'activeFaults': [
            for (final fault in faults.values)
              if (fault['isResolved'] != true) fault['dtcCode'],
          ],
          'resolvedFaults': [
            for (final fault in faults.values)
              if (fault['isResolved'] == true) fault['dtcCode'],
          ],
        }),
      );
    }
    if (!path.startsWith(_base)) return null;
    final route = path.substring(_base.length);
    log('IOT $method $route ${uri.query}');

    if (route == '/devices' && method == 'GET') {
      return (
        200,
        jsonEncode([
          {
            'id': 'd1',
            'deviceIdentifier': 'SIM:OB:D2:00:00:01',
            'connectionType': 'BLUETOOTH_CLASSIC',
            'status': uri.queryParameters['status'] ?? 'ACTIVE',
          },
        ]),
      );
    }
    if (route == '/installations/install' && method == 'POST') {
      final sent = jsonDecode(body) as Map;
      final vehicleId = sent['vehicleId'] as String;
      if (installations.containsKey(vehicleId)) {
        return _error(409, 'ERR_ACTIVE_INSTALLATION_CONFLICT', 'El vehículo ya tiene un escáner');
      }
      final installation = _installation(vehicleId, sent);
      installations[vehicleId] = installation;
      return (201, jsonEncode(installation));
    }
    final active = RegExp(r'^/installations/vehicle/([^/]+)/active$').firstMatch(route);
    if (active != null) {
      final installation = installations[active[1]];
      return installation == null
          ? _error(404, 'NOT_FOUND', 'Sin instalación activa')
          : (200, jsonEncode(installation));
    }
    if (route == '/telemetry/batch' && method == 'POST') {
      final sent = jsonDecode(body) as Map;
      final vehicleId = sent['vehicleId'] as String;
      batches++;
      if (!installations.containsKey(vehicleId)) {
        return _error(404, 'NOT_FOUND', 'El vehículo no tiene un escáner instalado');
      }
      final seen = readings.putIfAbsent(vehicleId, () => {});
      final items = sent['readings'] as List;
      for (final item in items) {
        if (!seen.add((item as Map)['timestamp'] as String)) duplicates++;
      }
      log('BATCH $vehicleId lecturas=${items.length} total=${seen.length}');
      return (202, jsonEncode({'vehicleId': vehicleId, 'ingestedCount': items.length}));
    }
    if (route == '/faults' && method == 'POST') {
      final sent = jsonDecode(body) as Map;
      faultPosts++;
      for (final fault in faults.values) {
        if (fault['vehicleId'] == sent['vehicleId'] &&
            fault['dtcCode'] == sent['dtcCode'] &&
            fault['isResolved'] != true) {
          return (200, jsonEncode(fault));
        }
      }
      final id = 'f${++faultSeq}';
      final fault = <String, Object?>{
        'id': id,
        'vehicleId': sent['vehicleId'],
        'dtcCode': sent['dtcCode'],
        'severity': sent['severity'],
        'description': sent['description'],
        'detectedAt': _nowUtc(),
        'isResolved': false,
      };
      faults[id] = fault;
      return (201, jsonEncode(fault));
    }
    final activeFaults = RegExp(r'^/faults/vehicle/([^/]+)/active$').firstMatch(route);
    if (activeFaults != null) {
      return (
        200,
        jsonEncode([
          for (final fault in faults.values)
            if (fault['vehicleId'] == activeFaults[1] && fault['isResolved'] != true) fault,
        ]),
      );
    }
    final resolve = RegExp(r'^/faults/([^/]+)/resolve$').firstMatch(route);
    if (resolve != null && method == 'POST') {
      final fault = faults[resolve[1]];
      if (fault == null) return _error(404, 'NOT_FOUND', 'Falla no encontrada');
      resolves++;
      fault['isResolved'] = true;
      fault['resolvedAt'] ??= _nowUtc();
      return (200, jsonEncode(fault));
    }
    if (route == '/health-reports/generate' && method == 'POST') {
      final vehicleId = uri.queryParameters['vehicleId'];
      if (vehicleId == 'v-corto') {
        return _error(422, 'ERR_INSUFFICIENT_TELEMETRY', 'Telemetría insuficiente en el período');
      }
      if (vehicleId == 'v-sin-cuota') {
        return _error(403, 'QUOTA_EXCEEDED', 'Cuota de IA agotada');
      }
      generated++;
      return (
        201,
        jsonEncode({
          'reportId': 'r$generated',
          'vehicleId': vehicleId,
          'overallHealthScore': 78,
          'executiveSummary': 'Motor estable',
          'totalRisksDetected': 1,
          'generatedAt': _nowUtc(),
        }),
      );
    }
    if (route == '/health-reports/latest') {
      return generated == 0
          ? _error(404, 'NOT_FOUND', 'Sin informes')
          : (
              200,
              jsonEncode({
                'reportId': 'r$generated',
                'vehicleId': uri.queryParameters['vehicleId'],
                'overallHealthScore': 78,
                'generatedAt': _nowUtc(),
              }),
            );
    }
    return _error(404, 'NOT_FOUND', 'Ruta IoT sin simular: $method $route');
  }
}

/// Inventario del paso 7. Simula H13 (alertas calculadas al consultar), H15 (`receive` responde 400 a
/// todo y no es idempotente) y lotes del más nuevo al más viejo, tal como los documenta
/// docs/api/inventory.md. `GET /items` sin `size` lo sigue atendiendo `_TasksBackend`.
class _InventoryBackend {
  final void Function(String) log;

  /// Pagina en memoria, como el backend. `ip1` queda bajo el mínimo: `"9"` frente a `"10"`.
  final List<Map<String, Object?>> parts = [
    for (var i = 0; i < 130; i++)
      {
        'id': 'ip$i',
        'tenantId': 'probe-tenant',
        'name': 'Repuesto ${i.toString().padLeft(3, '0')}',
        'sku': 'INV-${i.toString().padLeft(3, '0')}',
        'category': i.isEven ? 'BRAKES' : 'FILTERS',
        'basePrice': 25.5,
        'totalStock': i == 1 ? 9 : 10,
        'minimumStock': i == 1 ? 10 : 9,
        'unitOfMeasure': 'UNIT',
        'status': 'ACTIVE',
      },
  ];

  final List<Map<String, Object?>> batches = [
    _batch('b-nuevo', 'ip1', 'L-3', 9, '2026-10-01T10:00:00Z'),
    _batch('b-agotado', 'ip1', 'L-2', 0, '2026-05-01T10:00:00Z'),
    _batch('b-viejo', 'ip1', 'L-1', 0, '2026-01-01T10:00:00Z'),
  ];

  final Map<String, String> orders = {
    'po1': 'ISSUED',
    'po2': 'ISSUED',
    'po3': 'DRAFT',
    'po4': 'ISSUED',
  };

  var catalogRequests = 0;
  var uploads = 0;

  _InventoryBackend(this.log);

  static Map<String, Object?> _batch(
    String id,
    String itemId,
    String number,
    num remaining,
    String arrival,
  ) {
    return {
      'id': id,
      'itemId': itemId,
      'batchNumber': number,
      'initialQty': 10,
      'remainingQty': remaining,
      'unitCost': 12.5,
      'arrivalDate': arrival,
    };
  }

  Map<String, Object?> _order(String id) {
    return {
      'id': id,
      'tenantId': 'probe-tenant',
      'supplierId': 's1',
      'branchId': 'probe-branch',
      'orderNumber': 'OC-$id',
      'status': orders[id],
      'totalCost': 500,
      'items': [
        {'id': 'line-$id', 'itemId': 'ip1', 'quantity': 20, 'unitCost': 25, 'totalCost': 500},
      ],
    };
  }

  void _receive(String id, Map<String, Object?> body) {
    orders[id] = 'RECEIVED';
    final part = parts.firstWhere((p) => p['id'] == 'ip1');
    part['totalStock'] = (part['totalStock']! as num) + 20;
    batches.insert(0, _batch('b-$id', 'ip1', 'L-$id', 20, '2026-11-07T10:00:00Z'));
    log('RECEIVE $id numero=${body['receiptNumber']} url=${body['receiptImageUrl']}');
  }

  (int, String)? handle(String method, Uri uri, String body) {
    final path = uri.path;
    if (path.startsWith('/storage/v1/object/atelier/') && path.contains('/purchase-orders/')) {
      uploads++;
      return null; // Lo registra `_TasksBackend`.
    }
    if (path == '/control/inventory') {
      return (200, jsonEncode({'catalogRequests': catalogRequests, 'uploads': uploads}));
    }
    const base = '/api/v1/inventory';
    if (path == '$base/items') {
      final query = uri.queryParameters;
      if (!query.containsKey('size')) return null;
      final size = int.parse(query['size']!);
      final page = int.tryParse(query['page'] ?? '') ?? 0;
      if (query.containsKey('page')) catalogRequests++;
      final text = query['search']?.toLowerCase();
      final found = parts.where((p) {
        if (query['category'] != null && p['category'] != query['category']) return false;
        return text == null ||
            '${p['name']}'.toLowerCase().contains(text) ||
            '${p['sku']}'.toLowerCase().contains(text);
      }).toList();
      return (200, jsonEncode(found.skip(page * size).take(size).toList()));
    }
    if (path.startsWith('$base/items/by-sku/')) {
      final sku = path.split('/').last.toUpperCase();
      final found = parts.where((p) => p['sku'] == sku);
      return found.isEmpty ? (404, '') : (200, jsonEncode(found.first));
    }
    if (path == '$base/items/valuation') return (200, '{"valuation":12345.67}');
    if (path.startsWith('$base/items/')) {
      final segments = path.split('/');
      final id = segments[5];
      final mine = batches.where((b) => b['itemId'] == id).toList();
      if (segments.length == 7) return (200, jsonEncode(mine));
      final part = parts.where((p) => p['id'] == id);
      if (part.isEmpty) return (404, '{"code":"NOT_FOUND","message":"No existe"}');
      return (200, jsonEncode({...part.first, 'batches': mine}));
    }
    if (path == '$base/alerts') {
      final low = parts.where((p) => (p['totalStock']! as num) <= (p['minimumStock']! as num));
      return (
        200,
        jsonEncode([
          for (final p in low)
            {
              'itemId': p['id'],
              'name': p['name'],
              'sku': p['sku'],
              'category': p['category'],
              'currentStock': p['totalStock'],
              'minimumStock': p['minimumStock'],
              'deficit': (p['minimumStock']! as num) - (p['totalStock']! as num),
              'evaluatedAt': DateTime.now().toUtc().toIso8601String(),
            },
        ]),
      );
    }
    if (path == '$base/purchase-orders') {
      final status = uri.queryParameters['status'];
      return (
        200,
        jsonEncode([
          for (final id in orders.keys)
            if (status == null || orders[id] == status) _order(id),
        ]),
      );
    }
    if (path.startsWith('$base/purchase-orders/')) {
      final segments = path.split('/');
      final id = segments[5];
      if (!orders.containsKey(id)) return (404, '{"code":"NOT_FOUND","message":"No existe"}');
      if (segments.length == 6) return (200, jsonEncode(_order(id)));
      final request = jsonDecode(body) as Map<String, Object?>;
      const invalid = '{"code":"BAD_REQUEST","message":"La orden no se puede recibir"}';
      if (orders[id] != 'ISSUED') return (400, invalid);
      // po2: el backend la aplicó pero la app recibe 400. po4: 400 de verdad, no se aplica.
      if (id == 'po4') return (400, invalid);
      _receive(id, request);
      return id == 'po2' ? (400, invalid) : (200, jsonEncode(_order(id)));
    }
    return null;
  }
}
