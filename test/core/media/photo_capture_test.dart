import 'dart:convert';
import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_queue.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/sync_processor.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/sync_scheduler.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/core/media/photo_capture.dart';
import 'package:atelier_mobile_crossplatform/core/media/storage_paths.dart';
import 'package:atelier_mobile_crossplatform/core/media/supabase_uploader.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

class _MockSession extends Mock implements SessionManager {}

class _MockProcessor extends Mock implements SyncProcessor {}

class _MockScheduler extends Mock implements SyncScheduler {}

class _FakeUploader extends SupabaseUploader {
  _FakeUploader()
    : super(
        client: MockClient((_) async => fail('no debe subir al capturar')),
        baseUrl: 'https://p.supabase.co',
        anonKey: 'anon',
        bucket: 'atelier',
        notConfiguredMessage: '',
        uploadFailedMessage: '',
      );

  @override
  Future<File> compress(String sourcePath, File target) async {
    await target.parent.create(recursive: true);
    return File(sourcePath).copy(target.path);
  }
}

void main() {
  late AppDatabase database;
  late Directory directory;
  late File original;
  late _MockSession session;
  late _MockProcessor processor;
  late PhotoCapture capture;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    directory = await Directory.systemTemp.createTemp('capture_test');
    original = File('${directory.path}/picker.jpg')..writeAsBytesSync([1]);
    session = _MockSession();
    processor = _MockProcessor();
    final scheduler = _MockScheduler();
    when(() => scheduler.requestSync()).thenAnswer((_) async {});
    when(() => session.getSession()).thenAnswer(
      (_) async => const Session(
        userId: 'u1',
        email: 'm@taller.pe',
        fullName: 'Andrés',
        tenantId: 't1',
        tenantName: 'Taller',
        membershipId: 'm1',
        permissions: {},
        plan: null,
      ),
    );
    final uploader = _FakeUploader();
    capture = PhotoCapture(
      uploader: uploader,
      uploadDao: database.pendingUploadDao,
      queue: PendingOperationQueue(
        dao: database.pendingOperationDao,
        session: session,
        processor: processor,
        scheduler: scheduler,
      ),
      session: session,
      supportDirectory: () async => directory,
    );
  });
  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  Future<String> take() {
    return capture.capture(
      photoPath: original.path,
      target: 'INTAKE',
      storagePath: (tenant, photo) => StoragePaths.intake(tenant, 'wo1', photo),
      attachType: 'ATTACH_INTAKE',
      attachDedupeKey: (photo) => 'ATTACH:$photo',
      attachPayload: (url) => {'imageUrl': url},
    );
  }

  test('guarda la copia con ruta relativa y encadena las dos operaciones', () async {
    final photoId = await take();

    final upload = await database.pendingUploadDao.findById(photoId);
    expect(upload!.localFilePath, 'pending/$photoId.jpg');
    expect(File('${directory.path}/pending/$photoId.jpg').existsSync(), isTrue);

    final operations = await database.pendingOperationDao.nextBatch('u1', 1 << 62);
    final uploadOp = operations.singleWhere((o) => o.type == 'UPLOAD_FILE');
    final attachOp = operations.singleWhere((o) => o.type == 'ATTACH_INTAKE');
    expect(jsonDecode(uploadOp.payload), {'uploadId': photoId});
    expect(uploadOp.dedupeKey, 'UPLOAD_FILE:$photoId');
    expect(attachOp.dependsOn, uploadOp.id);
    expect(jsonDecode(attachOp.payload), {
      'imageUrl':
          'https://p.supabase.co/storage/v1/object/public/atelier/'
          't1/work-orders/wo1/intake/$photoId.jpg',
    });
  });

  test('el sync se dispara una vez y con las dos ya en cola', () async {
    var queuedAtDispatch = -1;
    when(() => processor.runDetached()).thenAnswer((_) {
      // La consulta termina después, pero ya no puede insertarse nada más.
      database.pendingOperationDao
          .nextBatch('u1', 1 << 62)
          .then((batch) => queuedAtDispatch = batch.length);
    });

    await take();
    await pumpEventQueue();

    verify(() => processor.runDetached()).called(1);
    expect(queuedAtDispatch, 2);
  });

  test('sin sesión no guarda nada', () async {
    when(() => session.getSession()).thenAnswer((_) async => null);

    await expectLater(take(), throwsStateError);
    expect(Directory('${directory.path}/pending').existsSync(), isFalse);
  });
}
