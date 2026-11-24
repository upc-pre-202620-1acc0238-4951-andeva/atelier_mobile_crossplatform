import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/cancel_appointment_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/create_appointment_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/update_customer_contact_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/customer.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/invalid_reception_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/vehicle.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/reception_test_env.dart';

void main() {
  late ReceptionTestEnv env;

  setUp(() async {
    env = await ReceptionTestEnv.create();
    await env.signIn();
  });

  tearDown(() => env.close());

  group('citas', () {
    test('agendar envía UTC y sede de la sesión y guarda la cita', () async {
      env.responses['POST /api/v1/appointments'] = (_) =>
          jsonResponse(appointmentJson(id: 'a9', status: 'PENDING'), 201);

      final appointment = await CreateAppointmentUseCase(
        repository: env.reception,
      ).execute(
        customerId: 'c1',
        vehicleId: 'v1',
        scheduledAt: DateTime.utc(2026, 11, 7, 15),
        estimatedDurationMinutes: 60,
        reason: ' Frenos ',
      );

      expect(appointment.id, 'a9');
      final body = env.requested('POST', '/api/v1/appointments').single.body;
      expect(body, contains('"branchId":"b1"'));
      expect(body, contains('"scheduledAt":"2026-11-07T15:00:00.000Z"'));
      expect(body, contains('"reason":"Frenos"'));
      final saved = await env.db.select(env.db.appointments).get();
      expect(saved.map((a) => a.id), ['a9']);
    });

    test('validaciones de agendar y cancelar', () {
      final create = CreateAppointmentUseCase(repository: env.reception);
      expect(
        () => create.execute(
          customerId: 'c1',
          vehicleId: 'v1',
          scheduledAt: DateTime.utc(2026),
          estimatedDurationMinutes: 10,
        ),
        throwsA(
          isA<InvalidReceptionInputException>().having(
            (e) => e.field,
            'field',
            'estimatedDurationMinutes',
          ),
        ),
      );
      expect(
        () => CancelAppointmentUseCase(repository: env.reception).execute('a1', '  '),
        throwsA(isA<InvalidReceptionInputException>()),
      );
    });

    test('confirmar, reprogramar y cancelar usan su endpoint', () async {
      env.responses['POST /api/v1/appointments/a1/confirm'] = (_) =>
          jsonResponse(appointmentJson(status: 'CONFIRMED'));
      env.responses['POST /api/v1/appointments/a1/reschedule'] = (_) =>
          jsonResponse(appointmentJson(scheduledAt: '2026-11-08T16:00:00Z'));
      env.responses['POST /api/v1/appointments/a1/cancel'] = (_) =>
          jsonResponse(appointmentJson(status: 'CANCELED'));

      await env.reception.confirmAppointment('a1');
      final moved = await env.reception.rescheduleAppointment(
        'a1',
        DateTime.utc(2026, 11, 8, 16),
      );
      await CancelAppointmentUseCase(repository: env.reception).execute('a1', ' Cliente no puede ');

      expect(moved.scheduledAt, DateTime.utc(2026, 11, 8, 16));
      expect(
        env.requested('POST', '/api/v1/appointments/a1/reschedule').single.body,
        contains('"newScheduledAt":"2026-11-08T16:00:00.000Z"'),
      );
      expect(
        env.requested('POST', '/api/v1/appointments/a1/cancel').single.body,
        contains('"cancellationReason":"Cliente no puede"'),
      );
    });

    test('un rango de agenda pide día por día y rechaza más de 31 días', () async {
      env.responses['GET /api/v1/appointments'] = (request) {
        final day = request.url.queryParameters['date'];
        return jsonResponse([
          appointmentJson(
            id: 'a-$day',
            scheduledAt: '${day}T15:00:00Z',
          ),
        ]);
      };

      await env.reception.refreshAppointmentsRange('2026-11-06', '2026-11-08');

      expect(env.requested('GET', '/api/v1/appointments'), hasLength(3));
      final list = await env.reception
          .observeAppointmentsRange('2026-11-06', '2026-11-08')
          .first;
      expect(list, hasLength(3));
      await expectLater(
        env.reception.refreshAppointmentsRange('2026-11-01', '2026-12-31'),
        throwsA(isA<InvalidReceptionInputException>()),
      );
    });
  });

  group('clientes', () {
    test('refreshCustomers pagina, guarda la cartera y respeta los 15 min', () async {
      env.responses['GET /api/v1/customers'] = (request) {
        final page = int.parse(request.url.queryParameters['page']!);
        return jsonResponse([
          for (var i = 0; i < (page == 0 ? 50 : 3); i++)
            customerJson(id: 'c$page-$i', displayName: 'Cliente $page-$i'),
        ]);
      };

      await env.reception.refreshCustomers();
      expect(env.requested('GET', '/api/v1/customers'), hasLength(2));
      expect(await env.reception.observeCustomers().first, hasLength(53));

      await env.reception.refreshCustomers();
      expect(env.requested('GET', '/api/v1/customers'), hasLength(2));
      await env.reception.refreshCustomers(force: true);
      expect(env.requested('GET', '/api/v1/customers'), hasLength(4));
    });

    test('observeWorkshopVehicles une el titular si está en caché', () async {
      env.responses['GET /api/v1/customers/c1'] = (_) => jsonResponse(customerJson());
      await env.reception.getCustomer('c1');
      env.responses['GET /api/v1/customers/c1/vehicles'] = (_) =>
          jsonResponse([ownedVehicleJson(), ownedVehicleJson(id: 'v2', plate: 'XYZ999', ownerId: 'zz')]);
      await env.reception.getCustomerVehicles('c1');

      final vehicles = await env.reception.observeWorkshopVehicles().first;

      expect(vehicles, hasLength(2));
      final byPlate = {for (final v in vehicles) v.vehicle.plate: v};
      expect(byPlate['ABC123']!.owner?.displayName, 'Ana Pérez');
      expect(byPlate['XYZ999']!.owner, isNull);
    });

    test('actualizar contacto valida y guarda el cliente', () async {
      env.responses['PUT /api/v1/customers/c1/contact'] = (_) =>
          jsonResponse(customerJson(phone: '987654321'));

      final customer = await UpdateCustomerContactUseCase(
        repository: env.reception,
      ).execute('c1', phone: ' 987654321 ');

      expect(customer.phone, '987654321');
      expect(
        env.requested('PUT', '/api/v1/customers/c1/contact').single.body,
        '{"phone":"987654321"}',
      );
      expect(
        () => UpdateCustomerContactUseCase(repository: env.reception)
            .execute('c1', email: 'no-es-correo'),
        throwsA(isA<InvalidReceptionInputException>()),
      );
    });

    test('alta sin correo ni teléfono manda el teléfono de relleno', () async {
      env.responses['POST /api/v1/customers/individuals'] = (_) =>
          jsonResponse(customerJson(), 201);

      await env.reception.registerIndividual(
        const NewIndividualCustomer(
          firstName: 'Ana',
          lastName: 'Pérez',
          taxId: '12345678',
        ),
      );

      expect(
        env.requested('POST', '/api/v1/customers/individuals').single.body,
        contains('"phone":"900000000"'),
      );
    });

    test('alta de vehículo sin año usa el año de Lima', () async {
      env.responses['POST /api/v1/vehicles'] = (_) =>
          jsonResponse(ownedVehicleJson(), 201);

      await env.reception.registerVehicle(
        const NewVehicle(
          plate: 'abc 123',
          brand: 'Toyota',
          model: 'Corolla',
          engineType: EngineType.gasoline,
        ),
      );

      expect(
        env.requested('POST', '/api/v1/vehicles').single.body,
        contains('"year":2026'),
      );
    });

    test('enrichReferences trae solo lo que falta y sin permiso no hace nada', () async {
      env.responses['GET /api/v1/vehicles/v1'] = (_) => jsonResponse(ownedVehicleJson());
      env.responses['GET /api/v1/customers/c1'] = (_) => jsonResponse(customerJson());

      await env.reception.enrichReferences(['v1', 'v1'], ['c1']);
      await env.reception.enrichReferences(['v1'], ['c1']);
      expect(env.requested('GET', '/api/v1/vehicles/v1'), hasLength(1));
      expect(env.requested('GET', '/api/v1/customers/c1'), hasLength(1));

      await env.signIn(permissions: [Permission.appointmentsRead]);
      await env.reception.enrichReferences(['v2'], ['c2']);
      expect(env.requested('GET', '/api/v1/vehicles/v2'), isEmpty);
    });
  });
}
