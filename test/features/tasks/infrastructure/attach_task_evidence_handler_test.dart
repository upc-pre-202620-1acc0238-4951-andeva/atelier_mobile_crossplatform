import 'dart:convert';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/operation_handler.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/attach_task_evidence_payload.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/sync/attach_task_evidence_handler.dart';
import 'package:flutter_test/flutter_test.dart' hide Retry;

import '../support/tasks_test_env.dart';

PendingOperationEntity _operation({
  required String taskId,
  required String imageUrl,
  required String description,
}) {
  final payload = AttachTaskEvidencePayload(
    taskId: taskId,
    imageUrl: imageUrl,
    description: description,
  ).toJson();

  return PendingOperationEntity(
    id: 'op_evidence_1',
    type: AttachTaskEvidenceHandler.type,
    payload: jsonEncode(payload),
    dedupeKey: 'TASK_EVIDENCE:$taskId:photo1',
    userId: 'u1',
    tenantId: 't1',
    status: 'SYNCING',
    attempts: 0,
    nextAttemptAt: 0,
    createdAt: 0,
  );
}

void main() {
  late TasksTestEnv env;
  late AttachTaskEvidenceHandler handler;

  setUp(() async {
    env = await TasksTestEnv.create();
    await env.signIn();
    handler = AttachTaskEvidenceHandler(api: env.taskApi);
  });

  tearDown(() => env.close());

  test('tiene el tipo ATTACH_TASK_EVIDENCE', () {
    expect(AttachTaskEvidenceHandler.type, 'ATTACH_TASK_EVIDENCE');
  });

  test('201/200 devuelve Applied y manda payload correcto a la API', () async {
    env.responses['POST /api/v1/tasks/t1/evidence-images'] = (_) => jsonResponse({
      'id': 'img1',
      'imageUrl': 'https://storage/img1.jpg',
      'description': 'Foto de prueba',
      'uploadedAt': '2026-11-06T12:00:00Z',
    }, 201);

    final op = _operation(
      taskId: 't1',
      imageUrl: 'https://storage/img1.jpg',
      description: 'Foto de prueba',
    );

    final result = await handler.send(op);

    expect(result, isA<Applied>());
    final calls = env.requested('POST', '/api/v1/tasks/t1/evidence-images');
    expect(calls.length, 1);
    final body = jsonDecode(calls.single.body) as Map<String, dynamic>;
    expect(body['imageUrl'], 'https://storage/img1.jpg');
    expect(body['description'], 'Foto de prueba');
  });

  test('error 401 devuelve Unauthorized', () async {
    env.responses['POST /api/v1/tasks/t1/evidence-images'] = (_) => apiError(401, 'No autorizado');

    final op = _operation(
      taskId: 't1',
      imageUrl: 'https://storage/img1.jpg',
      description: 'Foto',
    );

    final result = await handler.send(op);
    expect(result, isA<Unauthorized>());
  });

  test('error 500 devuelve Retry', () async {
    env.responses['POST /api/v1/tasks/t1/evidence-images'] = (_) => apiError(500, 'Error interno');

    final op = _operation(
      taskId: 't1',
      imageUrl: 'https://storage/img1.jpg',
      description: 'Foto',
    );

    final result = await handler.send(op);
    expect(result, isA<Retry>());
    expect((result as Retry).httpStatus, 500);
  });

  test('sin conexión devuelve Retry', () async {
    env.responses['POST /api/v1/tasks/t1/evidence-images'] = offline;

    final op = _operation(
      taskId: 't1',
      imageUrl: 'https://storage/img1.jpg',
      description: 'Foto',
    );

    final result = await handler.send(op);
    expect(result, isA<Retry>());
  });

  test('error 422 de negocio devuelve Failed con mensaje', () async {
    env.responses['POST /api/v1/tasks/t1/evidence-images'] = (_) => apiError(422, 'La tarea ya está completada');

    final op = _operation(
      taskId: 't1',
      imageUrl: 'https://storage/img1.jpg',
      description: 'Foto',
    );

    final result = await handler.send(op);
    expect(result, isA<Failed>());
    expect((result as Failed).message, 'La tarea ya está completada');
  });
}
