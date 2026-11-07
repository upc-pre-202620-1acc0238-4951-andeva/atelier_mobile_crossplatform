import 'dart:convert';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/operation_handler.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/remote/work_order_payloads.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/sync/attach_intake_image_handler.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/sync/submit_proposal_handler.dart';
import 'package:flutter_test/flutter_test.dart' hide Retry;

import '../../reception/support/reception_test_env.dart';

PendingOperationEntity _operation(String type, Object payload) {
  return PendingOperationEntity(
    id: 'op1',
    type: type,
    payload: jsonEncode(payload),
    dedupeKey: 'KEY:wo1:photo1',
    userId: 'u1',
    tenantId: 't1',
    status: 'SYNCING',
    attempts: 0,
    nextAttemptAt: 0,
    createdAt: 0,
  );
}

void main() {
  late ReceptionTestEnv env;

  setUp(() async {
    env = await ReceptionTestEnv.create();
    await env.signIn();
  });

  tearDown(() => env.close());

  group('AttachIntakeImageHandler', () {
    const route = 'POST /api/v1/work-orders/wo1/intake-images';
    late PendingOperationEntity operation;
    late AttachIntakeImageHandler handler;

    setUp(() {
      handler = AttachIntakeImageHandler(api: env.workOrderApi);
      operation = _operation(
        AttachIntakeImageHandler.type,
        const AttachIntakeImagePayload(
          workOrderId: 'wo1',
          imageUrl: 'https://x/a.jpg',
          description: 'Golpe',
        ),
      );
    });

    test('2xx aplica y manda el cuerpo sin el id', () async {
      env.responses[route] = (_) =>
          jsonResponse({'id': 'i1', 'imageUrl': 'https://x/a.jpg'}, 201);

      expect(await handler.send(operation), isA<Applied>());
      expect(jsonDecode(env.requests.single.body), {
        'imageUrl': 'https://x/a.jpg',
        'description': 'Golpe',
      });
    });

    test('4xx falla con el mensaje; 5xx y sin red reintentan', () async {
      env.responses[route] = (_) => apiError(422, 'Orden cerrada');
      final failed = await handler.send(operation);
      expect((failed as Failed).message, 'Orden cerrada');

      env.responses[route] = (_) => apiError(500);
      expect(await handler.send(operation), isA<Retry>());

      env.responses[route] = offline;
      expect(await handler.send(operation), isA<Retry>());
    });
  });

  group('SubmitProposalHandler', () {
    const route = 'POST /api/v1/work-orders/wo1/proposals';
    late PendingOperationEntity operation;
    late SubmitProposalHandler handler;

    setUp(() {
      handler = SubmitProposalHandler(api: env.workOrderApi);
      operation = _operation(
        SubmitProposalHandler.type,
        const SubmitProposalPayload(
          workOrderId: 'wo1',
          mechanicId: 'm1',
          description: 'Pastillas',
          severity: 'LOW',
          imageUrl: 'https://x/p.jpg',
        ),
      );
    });

    test('2xx aplica con el cuerpo exacto', () async {
      env.responses[route] = (_) =>
          jsonResponse({'id': 'p1', 'workOrderId': 'wo1'}, 201);

      expect(await handler.send(operation), isA<Applied>());
      expect(jsonDecode(env.requests.single.body), {
        'mechanicId': 'm1',
        'description': 'Pastillas',
        'severity': 'LOW',
        'imageUrl': 'https://x/p.jpg',
      });
    });

    test('4xx falla; 5xx reintenta', () async {
      env.responses[route] = (_) => apiError(400, 'Severidad inválida');
      expect(await handler.send(operation), isA<Failed>());

      env.responses[route] = (_) => apiError(503);
      expect(await handler.send(operation), isA<Retry>());
    });
  });
}
