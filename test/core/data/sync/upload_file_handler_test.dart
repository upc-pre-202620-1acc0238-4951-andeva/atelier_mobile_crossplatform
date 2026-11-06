import 'dart:convert';
import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/operation_handler.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/upload_file_handler.dart';
import 'package:atelier_mobile_crossplatform/core/media/supabase_uploader.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart' hide Retry;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late AppDatabase database;
  late Directory directory;
  late File photo;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    directory = await Directory.systemTemp.createTemp('handler_test');
    photo = File('${directory.path}/pending/p1.jpg')
      ..createSync(recursive: true)
      ..writeAsBytesSync([1, 2, 3]);
    await database.pendingUploadDao.insert(
      PendingUploadsCompanion.insert(
        id: 'p1',
        localFilePath: 'pending/p1.jpg',
        storagePath: 't/p1.jpg',
        target: 'INTAKE',
        createdAt: 0,
      ),
    );
  });
  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  UploadFileHandler handlerWith(int status) {
    return UploadFileHandler(
      dao: database.pendingUploadDao,
      uploader: SupabaseUploader(
        client: MockClient((_) async => http.Response('{}', status)),
        baseUrl: 'https://p.supabase.co',
        anonKey: 'anon',
        bucket: 'atelier',
        notConfiguredMessage: 'sin configurar',
        uploadFailedMessage: 'no subió',
      ),
      supportDirectory: () async => directory,
      missingPhotoMessage: 'foto perdida',
      uploadFailedMessage: 'no subió',
    );
  }

  PendingOperationEntity operation({String uploadId = 'p1'}) {
    return PendingOperationEntity(
      id: 'op1',
      type: UploadFileHandler.type,
      payload: jsonEncode({'uploadId': uploadId}),
      dedupeKey: 'UPLOAD_FILE:$uploadId',
      userId: 'u1',
      tenantId: 't1',
      status: 'PENDING',
      attempts: 0,
      nextAttemptAt: 0,
      createdAt: 0,
    );
  }

  test('al subir libera el archivo y la fila', () async {
    final result = await handlerWith(200).send(operation());

    expect(result, isA<Applied>());
    expect(photo.existsSync(), isFalse);
    expect(await database.pendingUploadDao.findById('p1'), isNull);
  });

  test('si la fila ya no está, cuenta como subida', () async {
    final result = await handlerWith(500).send(operation(uploadId: 'otra'));

    expect(result, isA<Applied>());
  });

  test('si falta el archivo falla con el mensaje para el usuario', () async {
    photo.deleteSync();

    final result = await handlerWith(200).send(operation());

    expect(
      result,
      isA<Failed>()
          .having((f) => f.code, 'code', 'FILE_NOT_FOUND')
          .having((f) => f.message, 'message', 'foto perdida'),
    );
  });

  test('un 5xx reintenta y conserva la foto', () async {
    final result = await handlerWith(503).send(operation());

    expect(result, isA<Retry>());
    expect(photo.existsSync(), isTrue);
    expect(await database.pendingUploadDao.findById('p1'), isNotNull);
  });

  test('un 401 de Supabase falla sin detener la cola por sesión', () async {
    final result = await handlerWith(401).send(operation());

    expect(result, isA<Failed>());
    expect(photo.existsSync(), isTrue);
  });
}
