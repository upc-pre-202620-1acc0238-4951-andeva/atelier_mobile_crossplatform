import 'package:drift/drift.dart';

@DataClassName('PendingUploadEntity')
class PendingUploads extends Table {
  TextColumn get id => text()();
  TextColumn get localFilePath => text()();  // pending/{id}.jpg, relativa a la carpeta de soporte de la app
  TextColumn get storagePath => text()();  // {tenantId}/work-orders/{woId}/tasks/{taskId}/{id}.jpg
  TextColumn get target => text()();  // INTAKE | TASK_EVIDENCE | PROPOSAL
  TextColumn get publicUrl => text().nullable()();  // se llena al subir
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
