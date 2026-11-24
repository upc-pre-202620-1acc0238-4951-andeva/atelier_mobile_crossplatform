import 'package:atelier_mobile_crossplatform/core/data/remote/employee/employee_api.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/pdf_downloader.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/create_service_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/update_service_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/invalid_work_order_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/local/work_order_mappers.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/remote/membership_api.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/remote/service_catalog_api.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/work_order_repository_impl.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../reception/support/reception_test_env.dart';

void main() {
  late ReceptionTestEnv env;
  late WorkOrderRepositoryImpl repository;

  setUp(() async {
    env = await ReceptionTestEnv.create();
    await env.signIn(
      permissions: [
        ...receptionPermissions,
        Permission.servicesManage,
        Permission.workOrdersUpdate,
      ],
    );
    repository = WorkOrderRepositoryImpl(
      workOrderApi: env.workOrderApi,
      serviceCatalogApi: ServiceCatalogApi(client: env.client),
      employeeApi: EmployeeApi(client: env.client),
      workOrderDao: env.db.workOrderDao,
      cacheMetadataDao: env.db.cacheMetadataDao,
      pendingOperationDao: env.db.pendingOperationDao,
      pendingUploadDao: env.db.pendingUploadDao,
      photoCapture: env.photoCapture,
      pdfDownloader: PdfDownloader(cacheDirectory: () async => env.tempDir),
      session: env.session,
      supportDirectory: () async => env.tempDir,
      now: () => env.clock,
      membershipApi: MembershipApi(client: env.client),
    );
  });

  tearDown(() => env.close());

  Map<String, Object?> serviceJson(String id, String name) => {
    'id': id,
    'name': name,
    'basePrice': 80,
    'currency': 'PEN',
    'estimatedMinutes': 30,
  };

  test('refreshServiceCatalog ordena por nombre y renueva la copia', () async {
    env.responses['GET /api/v1/services'] = (_) => jsonResponse([
      serviceJson('s2', 'frenos'),
      serviceJson('s1', 'Alineación'),
    ]);

    final services = await repository.refreshServiceCatalog();
    expect(services.map((s) => s.id), ['s1', 's2']);
    await repository.getServiceCatalog();
    expect(env.requested('GET', '/api/v1/services'), hasLength(1));
    await repository.refreshServiceCatalog();
    expect(env.requested('GET', '/api/v1/services'), hasLength(2));
  });

  test('createService y updateService envían el cuerpo e invalidan la copia', () async {
    env.responses['GET /api/v1/services'] = (_) =>
        jsonResponse([serviceJson('s1', 'Alineación')]);
    env.responses['POST /api/v1/services'] = (_) =>
        jsonResponse(serviceJson('s3', 'Balanceo'), 201);
    env.responses['PUT /api/v1/services/s3'] = (_) =>
        jsonResponse(serviceJson('s3', 'Balanceo 4x4'));
    await repository.getServiceCatalog();

    final created = await CreateServiceUseCase(repository: repository).execute(
      name: '  Balanceo ',
      basePrice: Decimal.parse('80'),
      estimatedMinutes: 30,
    );
    expect(created.id, 's3');
    final body = env.requested('POST', '/api/v1/services').single.body;
    expect(body, contains('"name":"Balanceo"'));
    expect(body, contains('"currency":"PEN"'));

    final updated = await UpdateServiceUseCase(repository: repository).execute(
      's3',
      name: 'Balanceo 4x4',
      basePrice: Decimal.parse('90'),
      estimatedMinutes: 45,
    );
    expect(updated.name, 'Balanceo 4x4');

    await repository.getServiceCatalog();
    expect(env.requested('GET', '/api/v1/services'), hasLength(2));
  });

  test('los casos de uso de servicio validan nombre, precio y minutos', () {
    final create = CreateServiceUseCase(repository: repository);
    expect(
      () => create.execute(name: ' ', basePrice: Decimal.one, estimatedMinutes: 5),
      throwsA(isA<InvalidWorkOrderInputException>()),
    );
    expect(
      () => create.execute(name: 'x', basePrice: Decimal.zero, estimatedMinutes: 5),
      throwsA(
        isA<InvalidWorkOrderInputException>().having((e) => e.field, 'field', 'basePrice'),
      ),
    );
    expect(
      () => UpdateServiceUseCase(repository: repository).execute(
        's1',
        name: 'x',
        basePrice: Decimal.one,
        estimatedMinutes: 0,
      ),
      throwsA(
        isA<InvalidWorkOrderInputException>().having(
          (e) => e.field,
          'field',
          'estimatedMinutes',
        ),
      ),
    );
  });

  test('getBranchMechanics pone nombre desde las membresías y la sesión', () async {
    env.responses['GET /api/v1/hr/employees/branch/b1'] = (_) => jsonResponse([
      {'id': 'e1', 'membershipId': 'm1', 'jobTitle': 'Asesor', 'employmentStatus': 'ACTIVE'},
      {'id': 'e2', 'membershipId': 'm2', 'jobTitle': 'Mecánico', 'employmentStatus': 'ACTIVE'},
      {'id': 'e3', 'membershipId': 'm3', 'jobTitle': 'Mecánico', 'employmentStatus': 'ACTIVE'},
    ]);
    env.responses['GET /api/v1/memberships'] = (_) => jsonResponse([
      {'id': 'm2', 'employeeName': 'Luis Ríos'},
    ]);

    final mechanics = await repository.getBranchMechanics();

    expect(mechanics.map((m) => m.displayName), ['Asesor', 'Luis Ríos', 'Mecánico']);
    expect(mechanics.first.name, 'Asesor'); // fullName de la sesión
  });

  test('getBranchMechanics sigue por cargo si las membresías fallan', () async {
    env.responses['GET /api/v1/hr/employees/branch/b1'] = (_) => jsonResponse([
      {'id': 'e9', 'membershipId': 'm9', 'jobTitle': null, 'employmentStatus': 'ACTIVE'},
    ]);
    env.responses['GET /api/v1/memberships'] = (_) => apiError(403);

    final mechanics = await repository.getBranchMechanics();

    expect(mechanics.single.displayName, 'Colaborador m9');
  });

  test('cleanDiagnosticSummary quita el uuid técnico de la cita', () {
    expect(
      cleanDiagnosticSummary(
        'Ingreso por cita programada: 123e4567-e89b-12d3-a456-426614174000',
      ),
      'Ingreso por cita programada',
    );
    expect(cleanDiagnosticSummary('  '), isNull);
  });

  test('el diagnóstico de relleno de la cita no pisa el real ni el km 0 al real', () async {
    env.responses['GET /api/v1/work-orders/wo1'] = (_) => jsonResponse(
      workOrderJson(
        mileageIn: 52000,
        diagnosticSummary: 'Ruido en frenos',
        status: 'IN_PROGRESS',
      ),
    );
    await repository.getDetail(const WorkOrderId('wo1'));
    env.responses['GET /api/v1/work-orders/wo1'] = (_) => jsonResponse(
      workOrderJson(
        mileageIn: 0,
        diagnosticSummary:
            'Ingreso por cita programada: 123e4567-e89b-12d3-a456-426614174000',
        status: 'IN_PROGRESS',
      ),
    );

    await repository.getDetail(const WorkOrderId('wo1'));

    final row = await env.db.workOrderDao.findById('wo1');
    expect(row!.mileageIn, 52000);
    expect(row.diagnosticSummary, 'Ruido en frenos');
  });

  test('update prioriza lo enviado sobre una respuesta sin esos campos', () async {
    env.responses['PUT /api/v1/work-orders/wo1'] = (_) => jsonResponse(
      workOrderJson(mileageIn: null, diagnosticSummary: null),
    );

    final order = await repository.update(
      const WorkOrderId('wo1'),
      mileageIn: 61000,
      diagnosticSummary: ' Revisión ',
    );

    expect(order.mileageIn, 61000);
    expect(order.diagnosticSummary, 'Revisión');
  });
}
