import 'dart:convert';
import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/session/authenticated_user_dto.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_upload_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/upload_file_handler.dart';
import 'package:atelier_mobile_crossplatform/features/main/domain/pending_operation_status.dart';
import 'package:atelier_mobile_crossplatform/features/main/infrastructure/pending_operation_repository_impl.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../../core/support/fake_session_store.dart';

AuthenticatedUserDto _user(String id) {
  return AuthenticatedUserDto.fromJson(
    jsonDecode(sessionJson().replaceAll('"u1"', '"$id"')),
  );
}

Future<void> _eventually(bool Function() condition) async {
  for (var i = 0; i < 200 && !condition(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  expect(condition(), isTrue);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late PendingOperationDao dao;
  late PendingUploadDao uploadDao;
  late SessionManager session;
  late Directory directory;
  late PendingOperationRepositoryImpl repository;
  late int syncRequests;
  final clock = DateTime.utc(2026, 11, 6);

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    FlutterSecureStorage.setMockInitialValues({});
    database = AppDatabase(NativeDatabase.memory());
    dao = database.pendingOperationDao;
    uploadDao = database.pendingUploadDao;
    session = SessionManager();
    await session.save(_user('u1'));
    directory = await Directory.systemTemp.createTemp('pending_ops');
    syncRequests = 0;
    repository = PendingOperationRepositoryImpl(
      dao: dao,
      uploadDao: uploadDao,
      session: session,
      supportDirectory: () async => directory,
      requestSync: () async => syncRequests++,
      now: () => clock,
    );
  });
  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  Future<void> enqueue(
    String id, {
    String type = 'PROBE',
    String payload = '{}',
    String? dependsOn,
    String userId = 'u1',
  }) async {
    await dao.enqueue(
      PendingOperationsCompanion.insert(
        id: id,
        type: type,
        payload: payload,
        dedupeKey: id,
        userId: userId,
        tenantId: 't1',
        nextAttemptAt: 0,
        createdAt: 0,
        dependsOn: Value(dependsOn),
      ),
    );
  }

  /// `UPLOAD_FILE` [upload] con su fila y su archivo en disco.
  Future<File> enqueueUpload(String upload) async {
    final file = File('${directory.path}/$upload.jpg');
    await file.writeAsString('foto');
    await uploadDao.insert(
      PendingUploadsCompanion.insert(
        id: upload,
        localFilePath: '$upload.jpg',
        storagePath: 'tenant/$upload.jpg',
        target: 'TASK_EVIDENCE',
        createdAt: 0,
      ),
    );
    await enqueue(
      upload,
      type: UploadFileHandler.type,
      payload: jsonEncode({'uploadId': upload}),
    );
    return file;
  }

  Future<String> statusOf(String id) async => (await dao.findById(id))!.status;

  group('retry', () {
    test('reactiva toda la cadena y pide sincronizar', () async {
      await enqueueUpload('upload');
      await enqueue('attach', dependsOn: 'upload');
      await enqueue('next', dependsOn: 'attach');
      for (final id in ['upload', 'attach', 'next']) {
        await dao.markFailed(id, attempts: 8, message: 'Falló');
      }

      expect(await repository.retry('attach'), isTrue);

      for (final id in ['upload', 'attach', 'next']) {
        final row = (await dao.findById(id))!;
        expect(row.status, 'PENDING');
        expect(row.attempts, 0);
        expect(row.nextAttemptAt, clock.millisecondsSinceEpoch);
        expect(row.lastErrorMessage, isNull);
      }
      expect(syncRequests, 1);
    });

    test('no toca lo que se está enviando en la cadena', () async {
      await enqueue('parent');
      await enqueue('child', dependsOn: 'parent');
      await dao.markSyncing('parent');
      await dao.markFailed('child', attempts: 1);

      expect(await repository.retry('child'), isTrue);

      expect(await statusOf('parent'), 'SYNCING');
      expect(await statusOf('child'), 'PENDING');
    });

    test('solo aplica a FAILED propias', () async {
      await enqueue('pending');
      await enqueue('other', userId: 'u2');
      await dao.markFailed('other', attempts: 1);

      expect(await repository.retry('pending'), isFalse);
      expect(await repository.retry('other'), isFalse);
      expect(await repository.retry('missing'), isFalse);
      expect(await statusOf('other'), 'FAILED');
      expect(syncRequests, 0);
    });

    test('sin sesión no hace nada', () async {
      await enqueue('a');
      await dao.markFailed('a', attempts: 1);
      await session.clear();

      expect(await repository.retry('a'), isFalse);
      expect(await statusOf('a'), 'FAILED');
    });
  });

  group('discard', () {
    test('un ATTACH se lleva su subida, la fila y el archivo', () async {
      final file = await enqueueUpload('upload');
      await enqueue('attach', dependsOn: 'upload');

      expect(await repository.discard('attach'), isTrue);

      expect(await dao.findById('upload'), isNull);
      expect(await dao.findById('attach'), isNull);
      expect(await uploadDao.findById('upload'), isNull);
      expect(await file.exists(), isFalse);
    });

    test('descartar la subida se lleva a sus dependientes', () async {
      final file = await enqueueUpload('upload');
      await enqueue('attach', dependsOn: 'upload');

      expect(await repository.discard('upload'), isTrue);

      expect(await dao.findById('attach'), isNull);
      expect(await file.exists(), isFalse);
    });

    test('la subida con otro hijo se conserva', () async {
      final file = await enqueueUpload('upload');
      await enqueue('attach1', dependsOn: 'upload');
      await enqueue('attach2', dependsOn: 'upload');

      expect(await repository.discard('attach1'), isTrue);

      expect(await dao.findById('attach1'), isNull);
      expect(await dao.findById('attach2'), isNotNull);
      expect(await dao.findById('upload'), isNotNull);
      expect(await uploadDao.findById('upload'), isNotNull);
      expect(await file.exists(), isTrue);
    });

    test('CLOCK_IN no se descarta con su CLOCK_OUT', () async {
      await enqueue('in', type: 'CLOCK_IN');
      await enqueue('out', type: 'CLOCK_OUT', dependsOn: 'in');

      expect(await repository.discard('out'), isTrue);

      expect(await dao.findById('out'), isNull);
      expect(await dao.findById('in'), isNotNull);
    });

    test('CLOCK_OUT se va con el CLOCK_IN del que depende', () async {
      await enqueue('in', type: 'CLOCK_IN');
      await enqueue('out', type: 'CLOCK_OUT', dependsOn: 'in');

      expect(await repository.discard('in'), isTrue);

      expect(await dao.findById('out'), isNull);
    });

    test('no borra nada si algo de la cadena se está enviando', () async {
      final file = await enqueueUpload('upload');
      await enqueue('attach', dependsOn: 'upload');
      await dao.markSyncing('upload');

      expect(await repository.discard('attach'), isFalse);

      expect(await dao.findById('attach'), isNotNull);
      expect(await uploadDao.findById('upload'), isNotNull);
      expect(await file.exists(), isTrue);
    });

    test('un SYNCING escrito por otra conexión también lo impide', () async {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      final file = File('${directory.path}/queue.sqlite');
      final ui = AppDatabase(NativeDatabase(file));
      final worker = AppDatabase(NativeDatabase(file));
      addTearDown(() async {
        await ui.close();
        await worker.close();
      });
      final uiRepository = PendingOperationRepositoryImpl(
        dao: ui.pendingOperationDao,
        uploadDao: ui.pendingUploadDao,
        session: session,
        supportDirectory: () async => directory,
        requestSync: () async {},
      );
      await ui.pendingOperationDao.enqueue(
        PendingOperationsCompanion.insert(
          id: 'a',
          type: 'PROBE',
          payload: '{}',
          dedupeKey: 'a',
          userId: 'u1',
          tenantId: 't1',
          nextAttemptAt: 0,
          createdAt: 0,
        ),
      );

      expect(await worker.pendingOperationDao.markSyncing('a'), isTrue);

      expect(await uiRepository.discard('a'), isFalse);
      expect(await ui.pendingOperationDao.findById('a'), isNotNull);
    });

    test('no toca operaciones de otro usuario', () async {
      await enqueue('other', userId: 'u2');

      expect(await repository.discard('other'), isFalse);
      expect(await dao.findById('other'), isNotNull);
    });

    test('un payload dañado o un archivo ausente no lo impiden', () async {
      await enqueue(
        'broken',
        type: UploadFileHandler.type,
        payload: 'no es json',
      );
      final file = await enqueueUpload('gone');
      await file.delete();

      expect(await repository.discard('broken'), isTrue);
      expect(await repository.discard('gone'), isTrue);
      expect(await dao.findById('broken'), isNull);
      expect(await uploadDao.findById('gone'), isNull);
    });

    test('si no se puede leer la carpeta, igual queda descartada', () async {
      await enqueueUpload('upload');
      final failing = PendingOperationRepositoryImpl(
        dao: dao,
        uploadDao: uploadDao,
        session: session,
        supportDirectory: () async => throw const FileSystemException('x'),
        requestSync: () async {},
      );

      expect(await failing.discard('upload'), isTrue);
      expect(await dao.findById('upload'), isNull);
    });
  });

  group('watch', () {
    test('lista y contador siguen al usuario de la sesión', () async {
      await enqueue('mine');
      await enqueue('other', userId: 'u2');
      await enqueue('other2', userId: 'u2');

      final lists = <List<String>>[];
      final counts = <int>[];
      final listSub = repository.watchAll().listen(
        (rows) => lists.add(rows.map((row) => row.id).toList()),
      );
      final countSub = repository.watchCount().listen(counts.add);
      addTearDown(listSub.cancel);
      addTearDown(countSub.cancel);

      await _eventually(() => lists.isNotEmpty && counts.isNotEmpty);
      expect(lists.last, ['mine']);
      expect(counts.last, 1);

      await session.save(_user('u2'));
      await _eventually(() => counts.last == 2);
      await _eventually(() => lists.last.length == 2);
      expect(lists.last, containsAll(['other', 'other2']));

      await session.clear();
      await _eventually(() => counts.last == 0 && lists.last.isEmpty);
    });

    test('tras cambiar de usuario no llegan filas del anterior', () async {
      await enqueue('mine');
      final lists = <List<String>>[];
      final sub = repository.watchAll().listen(
        (rows) => lists.add(rows.map((row) => row.id).toList()),
      );
      addTearDown(sub.cancel);
      await _eventually(() => lists.isNotEmpty);

      await session.save(_user('u2'));
      await _eventually(() => lists.last.isEmpty);
      lists.clear();
      await enqueue('late');

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(lists, everyElement(isEmpty));
    });

    test('un refresh del mismo usuario no reinicia la consulta', () async {
      await enqueue('mine');
      final counts = <int>[];
      final sub = repository.watchCount().listen(counts.add);
      addTearDown(sub.cancel);
      await _eventually(() => counts.isNotEmpty);

      await session.save(_user('u1'));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(counts, [1]);
    });

    test(
      'convierte la fila al dominio, incluido un estado desconocido',
      () async {
        await enqueue('a');
        await enqueue('b');
        await dao.markFailed('a', attempts: 2, message: 'Fuera de geocerca');
        await database.customStatement(
          "UPDATE pending_operations SET status = 'NUEVO' WHERE id = 'b'",
        );

        final rows = await repository.watchAll().first;

        final failed = rows.firstWhere((row) => row.id == 'a');
        expect(failed.status, PendingOperationStatus.failed);
        expect(failed.attempts, 2);
        expect(failed.lastErrorMessage, 'Fuera de geocerca');
        expect(failed.createdAt.isUtc, isTrue);
        expect(
          rows.firstWhere((row) => row.id == 'b').status,
          PendingOperationStatus.pending,
        );
      },
    );
  });
}
