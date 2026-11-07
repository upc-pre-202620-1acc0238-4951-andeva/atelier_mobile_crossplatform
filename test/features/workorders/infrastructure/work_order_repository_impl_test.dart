import 'dart:convert';

import 'package:atelier_mobile_crossplatform/core/domain/missing_branch_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/proposal.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_references.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/sync/attach_intake_image_handler.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/sync/submit_proposal_handler.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import '../../reception/support/reception_test_env.dart';

void main() {
  late ReceptionTestEnv env;

  const id = WorkOrderId('wo1');
  const list = 'GET /api/v1/work-orders';
  const one = 'GET /api/v1/work-orders/wo1';

  setUp(() async {
    env = await ReceptionTestEnv.create();
    await env.signIn();
  });

  tearDown(() => env.close());

  group('refreshBranchWorkOrders', () {
    test('sin sesión o sin sede lanza; sin permiso no llama', () async {
      await env.session.clear();
      await expectLater(
        env.workOrders.refreshBranchWorkOrders(),
        throwsStateError,
      );
      expect(env.requests, isEmpty);

      await env.signIn(branchId: null);
      await expectLater(
        env.workOrders.refreshBranchWorkOrders(),
        throwsA(isA<MissingBranchException>()),
      );

      await env.signIn(permissions: [Permission.vehiclesRead]);
      await env.workOrders.refreshBranchWorkOrders();
      expect(env.requests, isEmpty);
    });

    test('deja fuera PAID y CANCELED y ordena por número', () async {
      env.responses[list] = (_) => jsonResponse([
        workOrderJson(id: 'a', internalNumber: 1),
        workOrderJson(id: 'b', internalNumber: 3, status: 'COMPLETED'),
        workOrderJson(id: 'c', internalNumber: 4, status: 'PAID'),
        workOrderJson(id: 'd', internalNumber: 5, status: 'CANCELED'),
      ]);

      await env.workOrders.refreshBranchWorkOrders();

      final rows = await env.workOrders.observeBranchWorkOrders().first;
      expect(rows.map((e) => e.id.value), ['b', 'a']);
      expect(env.requests.first.url.queryParameters['branchId'], 'b1');
    });

    test(
      'no trae placa ni cliente: los muestra si ya están en caché',
      () async {
        env.responses[list] = (_) => jsonResponse([workOrderJson()]);

        await env.workOrders.refreshBranchWorkOrders();

        expect(env.requests, hasLength(1));
        var row = (await env.workOrders.observeBranchWorkOrders().first).single;
        expect(row.plate, isNull);
        expect(row.customerName, isNull);

        env.responses['GET /api/v1/customers/c1/vehicles'] = (_) =>
            jsonResponse([ownedVehicleJson()]);
        await env.reception.getCustomerVehicles('c1');

        row = (await env.workOrders.observeBranchWorkOrders().first).single;
        expect(row.plate, 'ABC123');
      },
    );

    test('sin red sube el error y la caché sigue visible', () async {
      env.responses[list] = (_) => jsonResponse([workOrderJson()]);
      await env.workOrders.refreshBranchWorkOrders();

      env.responses[list] = offline;
      await expectLater(
        env.workOrders.refreshBranchWorkOrders(),
        throwsA(isA<NetworkException>()),
      );
      expect(
        await env.workOrders.observeBranchWorkOrders().first,
        hasLength(1),
      );
    });

    test('conserva lo que la lista no trae', () async {
      env.responses[one] = (_) => jsonResponse(
        workOrderJson(
          currentBayId: 'bay1',
          bayName: 'Bahía 1',
          mileageIn: 45000,
          diagnosticSummary: 'Combustible: 1/2. Ruido',
          subtotal: 100,
          taxAmount: 18,
        ),
      );
      await env.workOrders.getDetail(id);

      env.responses[list] = (_) =>
          jsonResponse([workOrderJson(currentBayId: 'bay1')]);
      await env.workOrders.refreshBranchWorkOrders();

      final row = await env.workOrders.observeWorkOrder(id).first;
      expect(row!.mileageIn, 45000);
      expect(row.diagnosticSummary, 'Combustible: 1/2. Ruido');
      expect(row.bayName, 'Bahía 1');
      expect(row.subtotal!.amount, Decimal.parse('100'));
    });

    test('con otro total o bahía no resucita los datos viejos', () async {
      env.responses[one] = (_) => jsonResponse(
        workOrderJson(
          currentBayId: 'bay1',
          bayName: 'Bahía 1',
          subtotal: 100,
          taxAmount: 18,
        ),
      );
      await env.workOrders.getDetail(id);

      env.responses[list] = (_) =>
          jsonResponse([workOrderJson(currentBayId: 'bay2', totalAmount: 236)]);
      await env.workOrders.refreshBranchWorkOrders();

      final row = await env.workOrders.observeWorkOrder(id).first;
      expect(row!.totalAmount!.amount, Decimal.parse('236'));
      expect(row.subtotal, isNull);
      expect(row.taxAmount, isNull);
      expect(row.bayName, isNull);
    });
  });

  group('findDraftForVehicle', () {
    test('filtra por vehículo y DRAFT', () async {
      env.responses[list] = (_) => jsonResponse([
        workOrderJson(id: 'otro', vehicleId: 'v2'),
        workOrderJson(id: 'curso', status: 'IN_PROGRESS'),
        workOrderJson(id: 'borrador'),
      ]);

      final draft = await env.workOrders.findDraftForVehicle('b1', 'v1');

      expect(draft!.id, const WorkOrderId('borrador'));
      expect(env.requests, hasLength(1));
    });

    test('sin coincidencia da null', () async {
      env.responses[list] = (_) =>
          jsonResponse([workOrderJson(status: 'IN_PROGRESS')]);

      expect(await env.workOrders.findDraftForVehicle('b1', 'v1'), isNull);
    });
  });

  group('cabecera', () {
    test('open usa la sede de la sesión y omite lo vacío', () async {
      env.responses['POST /api/v1/work-orders'] = (_) =>
          jsonResponse(workOrderJson(mileageIn: 1000), 201);

      final order = await env.workOrders.open(
        const NewWorkOrder(
          vehicleId: 'v1',
          customerId: 'c1',
          mileageIn: 1000,
          diagnosticSummary: '  ',
        ),
      );

      expect(jsonDecode(env.requests.last.body), {
        'vehicleId': 'v1',
        'customerId': 'c1',
        'branchId': 'b1',
        'mileageIn': 1000,
      });
      expect(order.mileageIn, 1000);
      expect(await env.db.workOrderDao.findById('wo1'), isNotNull);
    });

    test('open manda appointmentId si se da', () async {
      env.responses['POST /api/v1/work-orders'] = (_) =>
          jsonResponse(workOrderJson(), 201);

      await env.workOrders.open(
        const NewWorkOrder(
          vehicleId: 'v1',
          customerId: 'c1',
          mileageIn: 1,
          appointmentId: 'a1',
        ),
      );

      expect(
        (jsonDecode(env.requests.last.body) as Map)['appointmentId'],
        'a1',
      );
    });

    test('open sin sede lanza y no llama', () async {
      await env.session.clear();
      await env.signIn(branchId: null);

      await expectLater(
        env.workOrders.open(
          const NewWorkOrder(vehicleId: 'v1', customerId: 'c1', mileageIn: 0),
        ),
        throwsA(isA<MissingBranchException>()),
      );
      expect(env.requests, isEmpty);
    });

    test('update omite lo que no cambia', () async {
      env.responses['PUT /api/v1/work-orders/wo1'] = (_) =>
          jsonResponse(workOrderJson(mileageIn: 5));

      await env.workOrders.update(id, mileageIn: 5, diagnosticSummary: ' ');

      expect(jsonDecode(env.requests.last.body), {'mileageIn': 5});
    });

    test('cerrar la saca de la caché, pero devuelve la orden', () async {
      env.responses[one] = (_) => jsonResponse(workOrderJson());
      await env.workOrders.getDetail(id);
      env.responses['POST /api/v1/work-orders/wo1/cancel'] = (_) =>
          jsonResponse(workOrderJson(status: 'CANCELED'));

      final order = await env.workOrders.cancel(id, ' Cliente desiste ');

      expect(order.status, WorkOrderStatus.canceled);
      expect(jsonDecode(env.requests.last.body), {'reason': 'Cliente desiste'});
      expect(await env.db.workOrderDao.findById('wo1'), isNull);
    });

    test('la cabecera devuelta no trae placa; la observada sí', () async {
      env.responses['GET /api/v1/customers/c1/vehicles'] = (_) =>
          jsonResponse([ownedVehicleJson()]);
      await env.reception.getCustomerVehicles('c1');
      env.responses['POST /api/v1/work-orders/wo1/start'] = (_) =>
          jsonResponse(workOrderJson(status: 'IN_PROGRESS'));

      final order = await env.workOrders.start(id);

      expect(order.status, WorkOrderStatus.inProgress);
      expect(order.plate, isNull);
      final observed = await env.workOrders.observeWorkOrder(id).first;
      expect(observed!.plate, 'ABC123');
    });

    test('estado desconocido da null y no rompe', () async {
      env.responses[one] = (_) => jsonResponse(workOrderJson(status: 'NUEVO'));

      final detail = await env.workOrders.getDetail(id);

      expect(detail.workOrder.status, isNull);
    });
  });

  group('detalle', () {
    test('mapea tareas, propuestas y fotos (H5)', () async {
      env.responses[one] = (_) => jsonResponse(
        workOrderJson(
          tasks: [
            detailJson(id: 't1'),
            detailJson(
              id: 't2',
              pendingSuspensionReason: 'Falta repuesto',
              pendingSuspensionRequestedAt: '2026-11-06T12:00:00Z',
            ),
          ],
          proposals: [
            {
              'id': 'p1',
              'workOrderId': 'wo1',
              'description': 'Pastillas',
              'severity': 'HIGH',
              'status': 'PENDING_REVIEW',
              'createdAt': '2026-11-06T12:00:00Z',
            },
          ],
          intakeImages: [
            {'id': 'i1', 'imageUrl': 'https://x/i1.jpg'},
          ],
        ),
      );

      final detail = await env.workOrders.getDetail(id);

      expect(detail.tasks, hasLength(2));
      expect(detail.tasksAwaitingSuspensionReview.single.id.value, 't2');
      expect(detail.proposals.single.severity, ProposalSeverity.high);
      expect(detail.proposals.single.status, ProposalStatus.pendingReview);
      expect(detail.intakeImages.single.imageUrl, 'https://x/i1.jpg');
    });

    test('addTask y updateTask recargan el detalle', () async {
      env.responses['POST /api/v1/work-orders/wo1/tasks'] = (_) =>
          jsonResponse(detailJson(), 201);
      env.responses['PUT /api/v1/tasks/t1'] = (_) => jsonResponse(detailJson());
      env.responses[one] = (_) => jsonResponse(workOrderJson(totalAmount: 500));

      final added = await env.workOrders.addTask(
        id,
        NewWorkOrderTask(
          serviceId: 'srv1',
          description: ' Cambio ',
          price: Decimal.parse('100.5'),
        ),
      );
      expect(jsonDecode(env.requests[env.requests.length - 2].body), {
        'serviceId': 'srv1',
        'description': 'Cambio',
        'price': 100.5,
      });
      expect(added.workOrder.totalAmount!.amount, Decimal.parse('500'));

      await env.workOrders.updateTask(
        id,
        const TaskId('t1'),
        const WorkOrderTaskChanges(description: ' ', mechanicId: 'm2'),
      );
      expect(jsonDecode(env.requests[env.requests.length - 2].body), {
        'mechanicId': 'm2',
      });
      expect(env.requests.last.url.path, '/api/v1/work-orders/wo1');
    });
  });

  group('referencias', () {
    test('catálogo: una lectura por taller; sin permiso, vacío', () async {
      env.responses['GET /api/v1/services'] = (_) => jsonResponse([
        {
          'id': 'srv1',
          'name': 'Aceite',
          'basePrice': 80,
          'currency': 'PEN',
          'estimatedMinutes': 30,
        },
      ]);

      final services = await env.workOrders.getServiceCatalog();
      expect(services.single.basePrice!.amount, Decimal.parse('80'));
      await env.workOrders.getServiceCatalog();
      expect(env.requested('GET', '/api/v1/services'), hasLength(1));

      await env.signIn(tenantId: 't2');
      await env.workOrders.getServiceCatalog();
      expect(env.requested('GET', '/api/v1/services'), hasLength(2));

      await env.signIn(permissions: [Permission.workOrdersRead]);
      expect(await env.workOrders.getServiceCatalog(), isEmpty);

      await env.session.clear();
      await expectLater(env.workOrders.getServiceCatalog(), throwsStateError);
      await expectLater(env.workOrders.getBranchMechanics(), throwsStateError);
    });

    test('mecánicos: activos con membresía; sin permiso, vacío', () async {
      env.responses['GET /api/v1/hr/employees/branch/b1'] = (_) => jsonResponse(
        [
          {
            'id': 'e1',
            'membershipId': 'm1',
            'jobTitle': 'Mecánico',
            'employmentStatus': 'ACTIVE',
          },
          {'id': 'e2', 'membershipId': 'm2'},
          {'id': 'e3', 'membershipId': 'm3', 'employmentStatus': 'TERMINATED'},
          {'id': 'e4', 'employmentStatus': 'ACTIVE'},
        ],
      );

      final mechanics = await env.workOrders.getBranchMechanics();
      expect(mechanics.map((e) => e.membershipId), ['m1', 'm2']);

      env.requests.clear();
      await env.signIn(permissions: [Permission.workOrdersRead]);
      expect(await env.workOrders.getBranchMechanics(), isEmpty);
      expect(env.requests, isEmpty);
    });
  });

  group('cola', () {
    test('foto de recepción: UPLOAD_FILE + hijo con depends_on', () async {
      final photo = await env.photo();

      await env.workOrders.attachIntakePhoto(id, photo, description: ' Golpe ');

      final operations = await env.db.pendingOperationDao
          .watchByTypeAndDedupePrefix(
            AttachIntakeImageHandler.type,
            'INTAKE_IMAGE:wo1:',
          )
          .first;
      final attach = operations.single;
      final payload = jsonDecode(attach.payload) as Map<String, dynamic>;
      expect(payload['workOrderId'], 'wo1');
      expect(payload['description'], 'Golpe');
      expect(payload['imageUrl'], contains('/wo1/'));
      expect(attach.dependsOn, isNotNull);
      expect(env.requests, isEmpty);

      final uploads = await env.db.pendingUploadDao
          .watchByTarget('INTAKE')
          .first;
      expect(uploads, hasLength(1));
    });

    test('pendientes con ruta absoluta y estado', () async {
      await env.workOrders.attachIntakePhoto(id, await env.photo());

      final pending = await env.workOrders.observePendingIntakePhotos(id).first;

      expect(pending.single.localFilePath, startsWith(env.tempDir.path));
      expect(pending.single.capturedAt, env.clock);
      expect(
        await env.workOrders
            .observePendingIntakePhotos(const WorkOrderId('otra'))
            .first,
        isEmpty,
      );
    });

    test('propuesta: mecánico de la sesión y payload exacto', () async {
      await env.workOrders.submitProposal(
        id,
        description: ' Pastillas ',
        severity: ProposalSeverity.critical,
        photo: await env.photo(),
        suggestedServiceId: 'srv1',
      );

      final operation =
          (await env.db.pendingOperationDao
                  .watchByTypeAndDedupePrefix(
                    SubmitProposalHandler.type,
                    'PROPOSAL:wo1:',
                  )
                  .first)
              .single;
      final payload = jsonDecode(operation.payload) as Map<String, dynamic>;
      expect(payload..remove('imageUrl'), {
        'workOrderId': 'wo1',
        'mechanicId': 'm1',
        'description': 'Pastillas',
        'severity': 'CRITICAL',
        'suggestedServiceId': 'srv1',
      });
      expect(operation.dependsOn, isNotNull);

      final pending = await env.workOrders.observePendingProposals(id).first;
      expect(pending.single.severity, ProposalSeverity.critical);
      expect(pending.single.localFilePath, startsWith(env.tempDir.path));
    });
  });

  group('propuesta y proforma en línea', () {
    test('notify y send devuelven el correo o vacío', () async {
      env.responses['POST /api/v1/work-orders/wo1/proposals/p1/notify'] = (_) =>
          jsonResponse({'message': 'ok', 'recipient': 'a@b.pe'});
      env.responses['POST /api/v1/work-orders/wo1/quotation/send'] = (_) =>
          jsonResponse({'message': 'ok'});

      expect(await env.workOrders.notifyProposal(id, 'p1'), 'a@b.pe');
      expect(await env.workOrders.sendQuotation(id), '');
    });

    test('aprobar recarga el detalle; rechazar manda las notas', () async {
      env.responses['POST /api/v1/work-orders/wo1/proposals/p1/approve'] = (
        _,
      ) => jsonResponse(detailJson(), 201);
      env.responses[one] = (_) => jsonResponse(workOrderJson());
      env.responses['POST /api/v1/work-orders/wo1/proposals/p1/reject'] = (_) =>
          jsonResponse({
            'id': 'p1',
            'workOrderId': 'wo1',
            'status': 'REJECTED',
            'customerNotes': 'No',
          });

      await env.workOrders.approveProposal(
        id,
        'p1',
        ProposalApproval(
          serviceId: 'srv1',
          finalPrice: Decimal.parse('50'),
          laborHours: Decimal.parse('1.5'),
          notes: ' ',
        ),
      );
      expect(jsonDecode(env.requests[env.requests.length - 2].body), {
        'serviceId': 'srv1',
        'finalPrice': 50.0,
        'laborHours': 1.5,
      });
      expect(env.requests.last.url.path, '/api/v1/work-orders/wo1');

      final rejected = await env.workOrders.rejectProposal(id, 'p1', ' No ');
      expect(rejected.status, ProposalStatus.rejected);
      expect(jsonDecode(env.requests.last.body), {'customerNotes': 'No'});
    });

    test('el PDF queda en disco', () async {
      env.responses['GET /api/v1/work-orders/wo1/quotation/pdf'] = (_) =>
          http.Response.bytes([37, 80, 68, 70], 200);

      final file = await env.workOrders.downloadQuotationPdf(id);

      expect(file.path, endsWith('proforma-wo1.pdf'));
      expect(await file.readAsBytes(), [37, 80, 68, 70]);
    });
  });

  group('auditoría', () {
    test('movimientos con ceros por defecto', () async {
      env.responses['GET /api/v1/work-orders/wo1/part-movements'] = (_) =>
          jsonResponse([
            {
              'allocationId': 'al1',
              'productId': 'p1',
              'unitCost': 10,
              'currency': 'PEN',
            },
          ]);

      final movement = (await env.workOrders.getPartMovements(id)).single;

      expect(movement.chargedQuantity, Decimal.zero);
      expect(movement.unitCost!.amount, Decimal.parse('10'));
    });

    test('la rentabilidad admite ganancia negativa', () async {
      env.responses['GET /api/v1/work-orders/wo1/profitability'] = (_) =>
          jsonResponse({
            'workOrderId': 'wo1',
            'partsGrossProfit': -12.5,
            'currency': 'PEN',
            'lines': [
              {'productId': 'p1', 'grossProfit': -12.5},
            ],
          });

      final profit = await env.workOrders.getProfitability(id);

      expect(profit.partsGrossProfit, Decimal.parse('-12.5'));
      expect(profit.lines.single.quantity, Decimal.zero);
    });
  });
}
