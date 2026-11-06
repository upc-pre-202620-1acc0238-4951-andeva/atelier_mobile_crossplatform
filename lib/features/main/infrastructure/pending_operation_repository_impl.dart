import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_upload_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/upload_file_handler.dart';
import 'package:atelier_mobile_crossplatform/features/main/domain/pending_operation.dart';
import 'package:atelier_mobile_crossplatform/features/main/domain/pending_operation_repository.dart';
import 'package:atelier_mobile_crossplatform/features/main/domain/pending_operation_status.dart';

/// Invariante: `SyncProcessor` toma "padre ausente" como "padre aplicado", así que nunca se deja en
/// la cola un hijo cuyo padre se descartó.
class PendingOperationRepositoryImpl implements PendingOperationRepository {
  final PendingOperationDao dao;
  final PendingUploadDao uploadDao;
  final SessionManager session;
  final Future<Directory> Function() supportDirectory;
  final Future<void> Function() requestSync;
  final DateTime Function() now;

  const PendingOperationRepositoryImpl({
    required this.dao,
    required this.uploadDao,
    required this.session,
    required this.supportDirectory,
    required this.requestSync,
    this.now = DateTime.now,
  });

  @override
  Stream<List<PendingOperation>> watchAll() {
    return _forCurrentUser(
      const [],
      (userId) =>
          dao.watchForUser(userId).map((rows) => rows.map(_toDomain).toList()),
    );
  }

  @override
  Stream<int> watchCount() => _forCurrentUser(0, dao.watchPendingCount);

  @override
  Future<bool> retry(String id) async {
    final operation = await _ownOperation(id);
    if (operation == null || operation.status != 'FAILED') return false;

    // Hacia arriba: un padre FAILED (la subida de la foto) tiene que salir primero. Hacia abajo: los
    // que fallaron en cascada por esta.
    final ids = <String>{id, ...await _descendantsOf(id)};
    var parentId = operation.dependsOn;
    while (parentId != null && ids.add(parentId)) {
      parentId = (await dao.findById(parentId))?.dependsOn;
    }

    await dao.resetFailed(ids.toList(), now().millisecondsSinceEpoch);
    await requestSync();
    return true;
  }

  @override
  Future<bool> discard(String id) async {
    final operation = await _ownOperation(id);
    if (operation == null) return false;

    // Hacia arriba solo con fotos: una subida sin su ATTACH_* dejaría un archivo huérfano en Supabase.
    // Un CLOCK_IN no se descarta con su CLOCK_OUT: son hechos distintos.
    var root = operation;
    final visited = {id};
    while (true) {
      final parentId = root.dependsOn;
      if (parentId == null || !visited.add(parentId)) break;
      final parent = await dao.findById(parentId);
      if (parent == null || parent.type != UploadFileHandler.type) break;
      final children = await dao.allDependentIds(parent.id);
      if (children.any((child) => child != root.id)) break;
      root = parent;
    }

    final ids = [root.id, ...await _descendantsOf(root.id)];
    final uploads = await _uploadsOf(ids);

    // Primero la cola: es lo que decide si algo se está enviando. Después las filas y al final los
    // archivos, como `UploadFileHandler`.
    if (!await dao.discardUnlessSyncing(ids)) return false;
    for (final upload in uploads) {
      await uploadDao.deleteById(upload.id);
    }
    await _deleteFiles(uploads);
    return true;
  }

  /// Cambia sola al cambiar de usuario: nunca se ve la cola de otro (06 §3, "Cambio de usuario").
  Stream<T> _forCurrentUser<T>(T empty, Stream<T> Function(String) query) {
    return session.switchOn<String?, T>(
      (current) => current?.userId,
      (userId) => userId == null ? Stream.value(empty) : query(userId),
    );
  }

  Future<PendingOperationEntity?> _ownOperation(String id) async {
    final userId = (await session.getSession())?.userId;
    if (userId == null) return null;
    final operation = await dao.findById(id);
    return operation?.userId == userId ? operation : null;
  }

  Future<List<String>> _descendantsOf(String id) async {
    final result = <String>{};
    final pending = await dao.allDependentIds(id);
    while (pending.isNotEmpty) {
      final child = pending.removeLast();
      if (child != id && result.add(child)) {
        pending.addAll(await dao.allDependentIds(child));
      }
    }
    return result.toList();
  }

  Future<List<PendingUploadEntity>> _uploadsOf(List<String> ids) async {
    final uploads = <PendingUploadEntity>[];
    for (final id in ids) {
      final operation = await dao.findById(id);
      if (operation == null || operation.type != UploadFileHandler.type) {
        continue;
      }
      final uploadId = _uploadIdOf(operation.payload);
      final upload = uploadId == null
          ? null
          : await uploadDao.findById(uploadId);
      if (upload != null) uploads.add(upload);
    }
    return uploads;
  }

  /// Un payload dañado no debe impedir descartarla: solo queda el archivo huérfano.
  String? _uploadIdOf(String payload) {
    try {
      final json = jsonDecode(payload);
      final uploadId = json is Map ? json['uploadId'] : null;
      return uploadId is String ? uploadId : null;
    } on FormatException {
      return null;
    }
  }

  /// La cola ya quedó limpia: un archivo que no se pueda borrar solo ocupa espacio.
  Future<void> _deleteFiles(List<PendingUploadEntity> uploads) async {
    if (uploads.isEmpty) return;
    try {
      // Relativa: en iOS la carpeta de la app cambia al actualizarla.
      final directory = await supportDirectory();
      for (final upload in uploads) {
        final file = File('${directory.path}/${upload.localFilePath}');
        if (await file.exists()) await file.delete();
      }
    } on Exception catch (e) {
      log('No se pudo borrar una foto: $e', name: 'PendingOperationRepository');
    }
  }

  PendingOperation _toDomain(PendingOperationEntity entity) {
    return PendingOperation(
      id: entity.id,
      type: entity.type,
      status: PendingOperationStatus.fromApi(entity.status),
      attempts: entity.attempts,
      lastErrorMessage: entity.lastErrorMessage,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        entity.createdAt,
        isUtc: true,
      ),
      dependsOn: entity.dependsOn,
    );
  }
}
