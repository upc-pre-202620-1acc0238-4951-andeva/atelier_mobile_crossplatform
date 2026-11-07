import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/affiliate_customer_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/find_vehicle_by_plate_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/lookup_affiliation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/mark_appointment_arrived_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/register_company_customer_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/register_individual_customer_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/register_vehicle_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/appointment.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/customer.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/invalid_reception_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_repository.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_validation.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/vehicle.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockReception extends Mock implements ReceptionRepository {}

class _MockWorkOrders extends Mock implements WorkOrderRepository {}

Matcher _invalid(String field) => throwsA(
  isA<InvalidReceptionInputException>().having((e) => e.field, 'field', field),
);

void main() {
  late _MockReception reception;

  setUpAll(() {
    registerFallbackValue(
      const NewIndividualCustomer(firstName: '', lastName: '', taxId: ''),
    );
    registerFallbackValue(const NewCompanyCustomer(companyName: '', taxId: ''));
    registerFallbackValue(
      const NewVehicle(
        plate: '',
        brand: '',
        model: '',
        engineType: EngineType.diesel,
      ),
    );
  });

  setUp(() => reception = _MockReception());

  test('normalizePlate quita espacios y pasa a mayúsculas', () {
    expect(ReceptionValidation.normalizePlate(' abc 1\t23 '), 'ABC123');
  });

  test(
    'FindVehicleByPlate rechaza una placa vacía o larga sin llamar',
    () async {
      final useCase = FindVehicleByPlateUseCase(repository: reception);

      await expectLater(useCase.execute('  '), _invalid('plate'));
      await expectLater(useCase.execute('A' * 16), _invalid('plate'));
      verifyZeroInteractions(reception);
    },
  );

  group('RegisterIndividualCustomer', () {
    NewIndividualCustomer valid({
      String firstName = 'Ana',
      String lastName = 'Pérez',
      String taxId = '12345678',
      String? email,
      String? phone,
    }) {
      return NewIndividualCustomer(
        firstName: firstName,
        lastName: lastName,
        taxId: taxId,
        email: email,
        phone: phone,
      );
    }

    test('rechaza cada campo sin llamar al repositorio', () async {
      final useCase = RegisterIndividualCustomerUseCase(repository: reception);

      await expectLater(
        useCase.execute(valid(firstName: ' ')),
        _invalid('firstName'),
      );
      await expectLater(
        useCase.execute(valid(lastName: 'x' * 101)),
        _invalid('lastName'),
      );
      await expectLater(
        useCase.execute(valid(taxId: '1234567')),
        _invalid('taxId'),
      );
      await expectLater(
        useCase.execute(valid(email: 'sin-arroba')),
        _invalid('email'),
      );
      await expectLater(
        useCase.execute(valid(phone: '1' * 21)),
        _invalid('phone'),
      );
      verifyZeroInteractions(reception);
    });

    test('el correo vacío es válido', () async {
      when(
        () => reception.registerIndividual(any()),
      ).thenAnswer((_) async => const Customer(id: 'c1', displayName: 'Ana'));

      await RegisterIndividualCustomerUseCase(repository: reception)
          .execute(valid(email: ' '));

      verify(() => reception.registerIndividual(any())).called(1);
    });
  });

  test('RegisterCompanyCustomer exige RUC de 11 o más', () async {
    final useCase = RegisterCompanyCustomerUseCase(repository: reception);

    await expectLater(
      useCase.execute(
        const NewCompanyCustomer(companyName: ' ', taxId: '20123456789'),
      ),
      _invalid('companyName'),
    );
    await expectLater(
      useCase.execute(
        const NewCompanyCustomer(companyName: 'SAC', taxId: '2012345678'),
      ),
      _invalid('taxId'),
    );
  });

  test('RegisterVehicle valida placa, marca, modelo, VIN y año', () async {
    final useCase = RegisterVehicleUseCase(repository: reception);
    NewVehicle vehicle({
      String plate = 'ABC123',
      String brand = 'Toyota',
      String model = 'Corolla',
      String? vin,
      int? year,
    }) {
      return NewVehicle(
        plate: plate,
        brand: brand,
        model: model,
        engineType: EngineType.gasoline,
        vin: vin,
        year: year,
      );
    }

    await expectLater(useCase.execute(vehicle(plate: '  ')), _invalid('plate'));
    await expectLater(
      useCase.execute(vehicle(plate: 'A' * 16)),
      _invalid('plate'),
    );
    await expectLater(useCase.execute(vehicle(brand: '')), _invalid('brand'));
    await expectLater(useCase.execute(vehicle(model: '')), _invalid('model'));
    await expectLater(useCase.execute(vehicle(vin: 'V' * 18)), _invalid('vin'));
    await expectLater(useCase.execute(vehicle(year: 1949)), _invalid('year'));
  });

  test('afiliar y buscar validan correo y documento', () async {
    await expectLater(
      LookupAffiliationUseCase(repository: reception).execute('x'),
      _invalid('email'),
    );
    final affiliate = AffiliateCustomerUseCase(repository: reception);
    await expectLater(affiliate.execute('x', '12345678'), _invalid('email'));
    await expectLater(affiliate.execute('a@b.pe', ''), _invalid('taxId'));
    await expectLater(
      affiliate.execute('a@b.pe', '12345678', phone: '1' * 21),
      _invalid('phone'),
    );
  });

  group('MarkAppointmentArrived', () {
    late _MockWorkOrders workOrders;
    late List<Duration> delays;
    late MarkAppointmentArrivedUseCase useCase;

    final appointment = Appointment(
      id: 'a1',
      branchId: 'b1',
      customerId: 'c1',
      vehicleId: 'v1',
      scheduledAt: DateTime.utc(2026, 11, 6, 15),
    );
    const draft = WorkOrder(
      id: WorkOrderId('wo1'),
      branchId: 'b1',
      vehicleId: 'v1',
      customerId: 'c1',
    );

    setUp(() {
      workOrders = _MockWorkOrders();
      delays = [];
      useCase = MarkAppointmentArrivedUseCase(
        receptionRepository: reception,
        workOrderRepository: workOrders,
        delay: (duration) async => delays.add(duration),
      );
      when(() => reception.markArrived('a1'))
          .thenAnswer((_) async => appointment);
    });

    void answers(List<Object?> results) {
      var call = 0;
      when(() => workOrders.findDraftForVehicle('b1', 'v1'))
          .thenAnswer((_) async {
            final result = results[call++];
            if (result is Exception) throw result;
            return result as WorkOrder?;
          });
    }

    test('orden lista al primer intento, sin esperar', () async {
      answers([draft]);

      final result = await useCase.execute('a1');

      expect(result, isA<WorkOrderReady>());
      expect((result as WorkOrderReady).workOrderId, const WorkOrderId('wo1'));
      expect(delays, isEmpty);
    });

    test('orden lista al tercer intento, con 1 s entre intentos', () async {
      answers([null, null, draft]);

      expect(await useCase.execute('a1'), isA<WorkOrderReady>());
      expect(delays, [const Duration(seconds: 1), const Duration(seconds: 1)]);
    });

    test('tras 3 intentos sin orden queda pendiente', () async {
      answers([null, null, null]);

      expect(await useCase.execute('a1'), isA<WorkOrderPending>());
      verify(() => workOrders.findDraftForVehicle('b1', 'v1')).called(3);
    });

    test('un fallo de búsqueda no hace fallar la llegada', () async {
      answers([
        const NetworkException('Sin red'),
        const ApiException(httpStatus: 500, code: 'E', message: 'Error'),
        draft,
      ]);
      expect(await useCase.execute('a1'), isA<WorkOrderReady>());

      answers([
        const NetworkException('Sin red'),
        const NetworkException('Sin red'),
        const NetworkException('Sin red'),
      ]);
      expect(await useCase.execute('a1'), isA<WorkOrderPending>());
    });

    test('si falla la llegada no se busca la orden', () async {
      when(() => reception.markArrived('a1')).thenThrow(
        const ApiException(httpStatus: 409, code: 'E', message: 'Ya llegó'),
      );

      await expectLater(useCase.execute('a1'), throwsA(isA<ApiException>()));
      verifyZeroInteractions(workOrders);
    });
  });
}
