import 'dart:convert';

import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/missing_branch_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/affiliation_lookup.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/customer.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/vehicle.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/reception_test_env.dart';

void main() {
  late ReceptionTestEnv env;

  const byPlate = 'GET /api/v1/vehicles/by-plate/ABC123';
  const owner = 'GET /api/v1/customers/c1';
  const agenda = 'GET /api/v1/appointments';

  setUp(() async {
    env = await ReceptionTestEnv.create();
    await env.signIn();
  });

  tearDown(() => env.close());

  group('findVehicleByPlate', () {
    test('normaliza la placa y devuelve vehículo con titular', () async {
      env.responses[byPlate] = (_) => jsonResponse(ownedVehicleJson());
      env.responses[owner] = (_) => jsonResponse(customerJson());

      final found = await env.reception.findVehicleByPlate(' abc 123 ');

      expect(found!.vehicle.plate, 'ABC123');
      expect(found.vehicle.engineType, EngineType.gasoline);
      expect(found.owner!.displayName, 'Ana Pérez');
      expect(await env.db.vehicleDao.findByPlate('ABC123'), isNotNull);
    });

    test('404 es primer ingreso', () async {
      env.responses[byPlate] = (_) => apiError(404);

      expect(await env.reception.findVehicleByPlate('ABC123'), isNull);
    });

    test('otro error del backend sube', () async {
      env.responses[byPlate] = (_) => apiError(500);

      await expectLater(
        env.reception.findVehicleByPlate('ABC123'),
        throwsA(isA<ApiException>()),
      );
    });

    test('sin red y sin caché relanza', () async {
      env.responses[byPlate] = offline;

      await expectLater(
        env.reception.findVehicleByPlate('ABC123'),
        throwsA(isA<NetworkException>()),
      );
    });

    test('sin red responde con la caché, titular incluido', () async {
      env.responses[byPlate] = (_) => jsonResponse(ownedVehicleJson());
      env.responses[owner] = (_) => jsonResponse(customerJson());
      await env.reception.findVehicleByPlate('ABC123');

      env.responses[byPlate] = offline;
      final found = await env.reception.findVehicleByPlate('ABC123');

      expect(found!.vehicle.id, 'v1');
      expect(found.owner!.id, 'c1');
    });

    test('si falla el titular se usa el de la caché o null', () async {
      env.responses[byPlate] = (_) => jsonResponse(ownedVehicleJson());
      env.responses[owner] = (_) => apiError(403);

      final sinCache = await env.reception.findVehicleByPlate('ABC123');
      expect(sinCache!.owner, isNull);

      env.responses[owner] = (_) => jsonResponse(customerJson());
      await env.reception.findVehicleByPlate('ABC123');
      env.responses[owner] = (_) => apiError(403);

      final conCache = await env.reception.findVehicleByPlate('ABC123');
      expect(conCache!.owner!.displayName, 'Ana Pérez');
    });
  });

  group('searchCustomers', () {
    const search = 'GET /api/v1/customers';

    test('sin texto no manda search; con texto sí, y guarda', () async {
      env.responses[search] = (_) => jsonResponse([customerJson()]);

      await env.reception.searchCustomers('  ');
      expect(env.requests.last.url.queryParameters, isEmpty);

      await env.reception.searchCustomers(' Ana ');
      expect(env.requests.last.url.queryParameters['search'], 'Ana');
      expect(await env.db.customerDao.findById('c1'), isNotNull);
    });

    test('sin red y con texto busca en caché por documento o nombre', () async {
      env.responses[search] = (_) => jsonResponse([customerJson()]);
      await env.reception.searchCustomers('Ana');
      env.responses[search] = offline;

      expect(await env.reception.searchCustomers('1234'), hasLength(1));
      expect(await env.reception.searchCustomers('Pérez'), hasLength(1));
      expect(await env.reception.searchCustomers('5678'), isEmpty);
    });

    test('sin red y sin texto relanza', () async {
      env.responses[search] = offline;

      await expectLater(
        env.reception.searchCustomers(''),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('altas', () {
    test('registerVehicle normaliza la placa y omite nulos', () async {
      env.responses['POST /api/v1/vehicles'] = (_) =>
          jsonResponse(ownedVehicleJson(), 201);

      final vehicle = await env.reception.registerVehicle(
        const NewVehicle(
          plate: 'abc 123',
          brand: ' Toyota ',
          model: 'Corolla',
          engineType: EngineType.hybrid,
          customerId: 'c1',
          vin: '  ',
        ),
      );

      expect(vehicle.id, 'v1');
      expect(jsonDecode(env.requests.last.body), {
        'plate': 'ABC123',
        'brand': 'Toyota',
        'model': 'Corolla',
        'engineType': 'HYBRID',
        'customerId': 'c1',
      });
    });

    test('registerIndividual convierte correo vacío en ausente', () async {
      env.responses['POST /api/v1/customers/individuals'] = (_) =>
          jsonResponse(customerJson(), 201);

      await env.reception.registerIndividual(
        const NewIndividualCustomer(
          firstName: 'Ana',
          lastName: 'Pérez',
          taxId: '12345678',
          email: ' ',
        ),
      );

      expect(jsonDecode(env.requests.last.body), {
        'firstName': 'Ana',
        'lastName': 'Pérez',
        'taxId': '12345678',
      });
      expect(await env.db.customerDao.findById('c1'), isNotNull);
    });

    test('un cliente sin displayName usa su razón social', () async {
      env.responses['POST /api/v1/customers/companies'] = (_) {
        return jsonResponse({
          'id': 'c2',
          'type': 'COMPANY',
          'companyName': 'Transportes SAC',
          'taxId': '20123456789',
        }, 201);
      };

      final customer = await env.reception.registerCompany(
        const NewCompanyCustomer(
          companyName: 'Transportes SAC',
          taxId: '20123456789',
        ),
      );

      expect(customer.displayName, 'Transportes SAC');
      expect(customer.type, CustomerType.company);
    });
  });

  group('afiliación', () {
    test('lookup traduce el siguiente paso; desconocido da null', () async {
      const lookup = 'GET /api/v1/customers/affiliation-lookup';
      env.responses[lookup] = (_) => jsonResponse({
        'workshopCustomer': null,
        'platformAccount': {'userId': 'u9', 'email': 'a@b.pe'},
        'vehicles': [ownedVehicleJson(ownerId: null)],
        'nextStep': 'AFFILIATE',
      });

      final result = await env.reception.lookupAffiliation(' a@b.pe ');

      expect(result.nextStep, AffiliationStep.affiliate);
      expect(result.platformAccount!.userId, 'u9');
      expect(result.vehicles.single.plate, 'ABC123');
      expect(env.requests.last.url.queryParameters['email'], 'a@b.pe');

      env.responses[lookup] = (_) => jsonResponse({'nextStep': 'NUEVO'});
      expect(
        (await env.reception.lookupAffiliation('a@b.pe')).nextStep,
        isNull,
      );
    });

    test('tras afiliar guarda los vehículos', () async {
      env.responses['POST /api/v1/customers/affiliations'] = (_) =>
          jsonResponse(customerJson(), 201);
      env.responses['GET /api/v1/customers/c1/vehicles'] = (_) =>
          jsonResponse([ownedVehicleJson()]);

      await env.reception.affiliate('a@b.pe', '12345678');

      expect(await env.db.vehicleDao.findById('v1'), isNotNull);
    });

    test('si fallan los vehículos, la afiliación sigue siendo éxito', () async {
      env.responses['POST /api/v1/customers/affiliations'] = (_) =>
          jsonResponse(customerJson(), 201);
      env.responses['GET /api/v1/customers/c1/vehicles'] = offline;

      final customer = await env.reception.affiliate('a@b.pe', '12345678');

      expect(customer.id, 'c1');
    });
  });

  group('agenda', () {
    const date = '2026-11-06';

    test('sin sesión o sin sede lanza; sin permiso no llama', () async {
      await env.session.clear();
      await expectLater(
        env.reception.refreshAppointments(date),
        throwsStateError,
      );
      expect(env.requests, isEmpty);

      await env.signIn(branchId: null);
      await expectLater(
        env.reception.refreshAppointments(date),
        throwsA(isA<MissingBranchException>()),
      );

      await env.signIn(permissions: [Permission.vehiclesRead]);
      await env.reception.refreshAppointments(date);
      expect(env.requests, isEmpty);
    });

    test('recarga el día de Lima sin tocar otros días ni sedes', () async {
      env.responses[agenda] = (request) {
        final day = request.url.queryParameters['date'];
        return jsonResponse([
          appointmentJson(
            id: 'a-$day',
            // 04:59Z del 7 sigue siendo 6 en Lima.
            scheduledAt: day == date
                ? '2026-11-07T04:59:00Z'
                : '2026-11-07T05:00:00Z',
          ),
        ]);
      };
      await env.reception.refreshAppointments(date);
      await env.reception.refreshAppointments('2026-11-07');

      env.responses[agenda] = (_) => jsonResponse([]);
      await env.reception.refreshAppointments(date);

      expect(await env.reception.observeAppointments(date).first, isEmpty);
      final tomorrow = await env.reception
          .observeAppointments('2026-11-07')
          .first;
      expect(tomorrow.single.id, 'a-2026-11-07');
    });

    test('trae placa y cliente que faltan y luego respeta el TTL', () async {
      env.responses[agenda] = (_) => jsonResponse([appointmentJson()]);
      env.responses['GET /api/v1/vehicles/v1'] = (_) =>
          jsonResponse(ownedVehicleJson());
      env.responses[owner] = (_) => jsonResponse(customerJson());

      await env.reception.refreshAppointments(date);
      final rows = await env.reception.observeAppointments(date).first;
      expect(rows.single.plate, 'ABC123');
      expect(rows.single.customerName, 'Ana Pérez');

      env.requests.clear();
      await env.reception.refreshAppointments(date);
      expect(env.requested('GET', '/api/v1/vehicles/v1'), isEmpty);

      env.clock = env.clock.add(const Duration(days: 8));
      await env.reception.refreshAppointments(date);
      expect(env.requested('GET', '/api/v1/vehicles/v1'), hasLength(1));
    });

    test('sin permiso no enriquece y un fallo no tumba la recarga', () async {
      env.responses[agenda] = (_) => jsonResponse([appointmentJson()]);
      env.responses['GET /api/v1/vehicles/v1'] = (_) => apiError(500);
      env.responses[owner] = offline;

      await env.reception.refreshAppointments(date);
      expect(await env.reception.observeAppointments(date).first, hasLength(1));

      env.requests.clear();
      await env.signIn(permissions: [Permission.appointmentsRead]);
      await env.reception.refreshAppointments(date);
      expect(env.requested('GET', '/api/v1/vehicles/v1'), isEmpty);
      expect(env.requested('GET', '/api/v1/customers/c1'), isEmpty);
    });

    test('sin red sube el error y la caché sigue visible', () async {
      env.responses[agenda] = (_) => jsonResponse([appointmentJson()]);
      await env.reception.refreshAppointments(date);

      env.responses[agenda] = offline;
      await expectLater(
        env.reception.refreshAppointments(date),
        throwsA(isA<NetworkException>()),
      );
      expect(await env.reception.observeAppointments(date).first, hasLength(1));
    });

    test('markArrived actualiza la cita en caché', () async {
      env.responses[agenda] = (_) => jsonResponse([appointmentJson()]);
      await env.reception.refreshAppointments(date);
      env.responses['POST /api/v1/appointments/a1/arrive'] = (_) =>
          jsonResponse(appointmentJson(status: 'ARRIVED'));

      final arrived = await env.reception.markArrived('a1');

      expect(arrived.status?.value, 'ARRIVED');
      final rows = await env.reception.observeAppointments(date).first;
      expect(rows.single.status?.value, 'ARRIVED');
    });
  });
}
