import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/cancel_appointment_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/confirm_appointment_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/create_appointment_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/find_vehicle_by_plate_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/get_customer_vehicles_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/mark_appointment_arrived_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/observe_appointments_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/observe_customers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/observe_workshop_vehicles_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/refresh_appointments_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/refresh_customers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/reschedule_appointment_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/search_customers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/update_customer_contact_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/appointment.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/customer.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/vehicle.dart';
import 'package:atelier_mobile_crossplatform/features/reception/presentation/search/vehicle_search_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/reception/presentation/search/vehicle_search_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'reception_presentation_support.dart';

class _ObserveSession extends Mock implements ObserveSessionUseCase {}

class _Find extends Mock implements FindVehicleByPlateUseCase {}

class _Search extends Mock implements SearchCustomersUseCase {}

class _CustomerVehicles extends Mock implements GetCustomerVehiclesUseCase {}

class _RefreshAppointments extends Mock implements RefreshAppointmentsUseCase {}

class _ObserveAppointments extends Mock implements ObserveAppointmentsUseCase {}

class _Arrived extends Mock implements MarkAppointmentArrivedUseCase {}

class _RefreshCustomers extends Mock implements RefreshCustomersUseCase {}

class _ObserveCustomers extends Mock implements ObserveCustomersUseCase {}

class _ObserveVehicles extends Mock implements ObserveWorkshopVehiclesUseCase {}

class _Create extends Mock implements CreateAppointmentUseCase {}

class _Confirm extends Mock implements ConfirmAppointmentUseCase {}

class _Reschedule extends Mock implements RescheduleAppointmentUseCase {}

class _Cancel extends Mock implements CancelAppointmentUseCase {}

class _UpdateContact extends Mock implements UpdateCustomerContactUseCase {}

void main() {
  final strings = lookupAppLocalizations(const Locale('es'));

  late _ObserveSession observeSession;
  late _Find find;
  late _Search search;
  late _CustomerVehicles customerVehicles;
  late _RefreshAppointments refreshAppointments;
  late _ObserveAppointments observeAppointments;
  late _Arrived arrived;
  late _RefreshCustomers refreshCustomers;
  late _ObserveCustomers observeCustomers;
  late _ObserveVehicles observeVehicles;
  late _Create create;
  late _Confirm confirm;
  late _Reschedule reschedule;
  late _Cancel cancel;
  late _UpdateContact updateContact;
  late StreamController<List<Appointment>> appointments;

  VehicleSearchViewModel build({Session? session, ConnectivityObserver? connectivity}) {
    when(() => observeSession.execute()).thenAnswer(
      (_) => Stream.value(session ?? receptionSession(receptionAllPermissions)),
    );
    final vm = VehicleSearchViewModel(
      observeSession: observeSession,
      findVehicleByPlate: find,
      searchCustomers: search,
      getCustomerVehicles: customerVehicles,
      refreshAppointments: refreshAppointments,
      observeAppointments: observeAppointments,
      markArrived: arrived,
      refreshCustomers: refreshCustomers,
      observeCustomers: observeCustomers,
      observeWorkshopVehicles: observeVehicles,
      connectivity: connectivity,
      createAppointment: create,
      confirmAppointment: confirm,
      rescheduleAppointment: reschedule,
      cancelAppointment: cancel,
      updateCustomerContact: updateContact,
    );
    addTearDown(vm.dispose);
    return vm;
  }

  Future<Appointment> stubCreate() => create.execute(
    customerId: any(named: 'customerId'),
    vehicleId: any(named: 'vehicleId'),
    scheduledAt: any(named: 'scheduledAt'),
    estimatedDurationMinutes: any(named: 'estimatedDurationMinutes'),
    reason: any(named: 'reason'),
  );

  setUpAll(() {
    registerFallbackValue(DateTime.utc(2026));
  });

  setUp(() {
    observeSession = _ObserveSession();
    find = _Find();
    search = _Search();
    customerVehicles = _CustomerVehicles();
    refreshAppointments = _RefreshAppointments();
    observeAppointments = _ObserveAppointments();
    arrived = _Arrived();
    refreshCustomers = _RefreshCustomers();
    observeCustomers = _ObserveCustomers();
    observeVehicles = _ObserveVehicles();
    create = _Create();
    confirm = _Confirm();
    reschedule = _Reschedule();
    cancel = _Cancel();
    updateContact = _UpdateContact();
    appointments = StreamController<List<Appointment>>.broadcast();
    addTearDown(appointments.close);
    when(() => observeAppointments.execute(any(), to: any(named: 'to'))).thenAnswer((_) => appointments.stream);
    when(() => refreshAppointments.execute(any(), to: any(named: 'to'))).thenAnswer((_) async {});
    when(() => refreshCustomers.execute(force: any(named: 'force'))).thenAnswer((_) async {});
    when(() => observeCustomers.execute()).thenAnswer((_) => Stream.value(const [testOwner]));
    when(() => observeVehicles.execute()).thenAnswer((_) => Stream.value(const <VehicleWithOwner>[]));
  });

  group('permisos', () {
    test('sin permisos no se puede buscar ni ver citas, y no se llama al backend', () async {
      final vm = build(session: receptionSession({}));
      await pumpEventQueue();

      expect(vm.state.canSearch, isFalse);
      expect(vm.state.canViewAppointments, isFalse);
      verifyNever(() => refreshAppointments.execute(any(), to: any(named: 'to')));
    });

    test('con permisos habilita búsqueda, citas, alta y orden', () async {
      final vm = build();
      await pumpEventQueue();

      expect(vm.state.canSearch, isTrue);
      expect(vm.state.canViewAppointments, isTrue);
      expect(vm.state.canRegister, isTrue);
      expect(vm.state.canOpenWorkOrder, isTrue);
      verify(() => refreshAppointments.execute(any(), to: any(named: 'to'))).called(1);
    });
  });

  group('búsqueda', () {
    test('por placa encontrada deja la ficha con su titular', () async {
      when(() => find.execute('BKR-418')).thenAnswer(
        (_) async => const VehicleWithOwner(vehicle: testVehicle, owner: testOwner),
      );
      final vm = build();
      await pumpEventQueue();

      vm.onQueryChange('BKR-418');
      await vm.onSearch();

      expect(vm.state.searched, isTrue);
      expect(vm.state.vehicleResult?.vehicle.plate, 'BKR418');
      expect(vm.state.vehicleNotFound, isFalse);
    });

    test('por placa sin resultado marca "no encontrado" y ofrece la placa para registrar', () async {
      when(() => find.execute('XYZ-999')).thenAnswer((_) async => null);
      final vm = build();
      await pumpEventQueue();

      vm.onQueryChange('XYZ-999');
      await vm.onSearch();

      expect(vm.state.vehicleNotFound, isTrue);
      expect(vm.state.initialPlateCandidate, 'XYZ-999');
    });

    test('un error del backend muestra su mensaje', () async {
      when(() => find.execute(any())).thenThrow(const ApiException(httpStatus: 500, code: 'X', message: 'Servicio caído'));
      final vm = build();
      await pumpEventQueue();

      vm.onQueryChange('BKR418');
      await vm.onSearch();

      expect(vm.state.isSearching, isFalse);
      expect(vm.state.error?.asString(strings), 'Servicio caído');
    });

    test('por documento con un solo cliente lo elige y carga sus vehículos', () async {
      when(() => search.execute('45678912')).thenAnswer((_) async => const [testOwner]);
      when(() => customerVehicles.execute('c1')).thenAnswer((_) async => const [testVehicle]);
      final vm = build();
      await pumpEventQueue();

      vm.onModeChange(SearchMode.document);
      vm.onQueryChange('45678912');
      await vm.onSearch();
      await pumpEventQueue();

      expect(vm.state.selectedCustomer?.id, 'c1');
      expect(vm.state.customerVehicles.single.plate, 'BKR418');
      expect(vm.state.isLoadingVehicles, isFalse);
    });

    test('cambiar de modo limpia el texto y el resultado', () async {
      final vm = build();
      await pumpEventQueue();

      vm.onQueryChange('BKR418');
      vm.onModeChange(SearchMode.document);

      expect(vm.state.query, isEmpty);
      expect(vm.state.mode, SearchMode.document);
    });
  });

  group('agenda de citas', () {
    test('al cambiar de rango recarga con el último día del rango', () async {
      final vm = build();
      await pumpEventQueue();

      await vm.onAppointmentRangeChange(AppointmentRange.week);

      verify(() => refreshAppointments.execute(any(), to: any(named: 'to', that: isNotNull))).called(1);
      expect(vm.state.appointmentRange, AppointmentRange.week);
    });

    test('muestra las citas observadas', () async {
      final vm = build();
      await pumpEventQueue();

      appointments.add([testAppointment('a1', AppointmentStatus.pending)]);
      await pumpEventQueue();

      expect(vm.state.appointments.single.id, 'a1');
    });

    test('confirmar deja el aviso y cierra la hoja', () async {
      when(() => confirm.execute('a1')).thenAnswer((_) async => testAppointment('a1', AppointmentStatus.confirmed));
      final vm = build();
      await pumpEventQueue();

      vm.onOpenAppointmentActions('a1');
      await vm.onConfirmAppointment('a1');

      expect(vm.state.actionAppointmentId, isNull);
      expect(vm.state.notice?.asString(strings), strings.receptionAppointmentConfirmedNotice);
    });

    test('registrar llegada guarda el resultado y cierra la hoja', () async {
      final appointment = testAppointment('a1', AppointmentStatus.confirmed);
      when(() => arrived.execute('a1')).thenAnswer((_) async => WorkOrderReady(appointment, const WorkOrderId('w1')));
      final vm = build();
      await pumpEventQueue();

      vm.onOpenAppointmentActions('a1');
      await vm.onMarkArrived('a1');

      expect(vm.state.arrival, isA<WorkOrderReady>());
      expect(vm.state.actionAppointmentId, isNull);
      expect(vm.state.arrivingId, isNull);
    });

    test('reprogramar con fecha inválida no llama al backend y avisa', () async {
      final vm = build();
      await pumpEventQueue();

      await vm.onRescheduleAppointment('a1', '2026-13-40', '25:99');

      expect(vm.state.error?.asString(strings), strings.receptionAppointmentInvalidDatetime);
      verifyNever(() => reschedule.execute(any(), any()));
    });

    test('reprogramar convierte la hora de Lima a UTC', () async {
      when(() => reschedule.execute(any(), any())).thenAnswer(
        (_) async => testAppointment('a1', AppointmentStatus.confirmed),
      );
      final vm = build();
      await pumpEventQueue();

      await vm.onRescheduleAppointment('a1', '2026-11-23', '10:00');

      verify(() => reschedule.execute('a1', DateTime.utc(2026, 11, 23, 15))).called(1);
      expect(vm.state.notice?.asString(strings), strings.receptionAppointmentRescheduledNotice);
    });

    test('cancelar sin red no llama al backend', () async {
      final vm = build(connectivity: OfflineConnectivity());
      await pumpEventQueue();

      await vm.onCancelAppointment('a1', 'No vino');

      verifyNever(() => cancel.execute(any(), any()));
      expect(vm.state.isOnline, isFalse);
    });

    test('cancelar con motivo deja el aviso', () async {
      when(() => cancel.execute('a1', 'No vino')).thenAnswer(
        (_) async => testAppointment('a1', AppointmentStatus.canceled),
      );
      final vm = build();
      await pumpEventQueue();

      await vm.onCancelAppointment('a1', 'No vino');

      expect(vm.state.notice?.asString(strings), strings.receptionAppointmentCanceledNotice);
    });
  });

  group('nueva cita', () {
    test('abre el formulario con el cliente y el vehículo del resultado y la fecha de hoy', () async {
      when(() => find.execute(any())).thenAnswer(
        (_) async => const VehicleWithOwner(vehicle: testVehicle, owner: testOwner),
      );
      final vm = build();
      await pumpEventQueue();
      vm.onQueryChange('BKR418');
      await vm.onSearch();

      vm.onOpenCreateAppointment();

      final form = vm.state.createAppointmentForm!;
      expect(form.selectedCustomer?.id, 'c1');
      expect(form.selectedVehicleId, 'v1');
      expect(form.dateText, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
      expect(form.timeText, '10:00');
      expect(form.durationText, '60');
    });

    test('sin cliente marca el campo y no llama al backend', () async {
      final vm = build();
      await pumpEventQueue();
      vm.onOpenCreateAppointment();

      await vm.onConfirmCreateAppointment();

      expect(vm.state.createAppointmentForm?.invalidField, 'customerId');
      verifyNever(stubCreate);
    });

    test('agenda la cita, cierra la hoja y avisa', () async {
      when(stubCreate).thenAnswer((_) async => testAppointment('a9', AppointmentStatus.pending));
      when(() => customerVehicles.execute('c1')).thenAnswer((_) async => const [testVehicle]);
      final vm = build();
      await pumpEventQueue();

      vm.onOpenCreateAppointment();
      vm.onSelectAppointmentCustomer(testOwner);
      await pumpEventQueue();
      vm.onAppointmentDateChange('2026-11-23');
      vm.onAppointmentDurationChange('45 min');
      vm.onAppointmentReasonChange('  Frenos  ');
      expect(vm.state.createAppointmentForm?.durationText, '45');
      await vm.onConfirmCreateAppointment();

      verify(
        () => create.execute(
          customerId: 'c1',
          vehicleId: 'v1',
          scheduledAt: DateTime.utc(2026, 11, 23, 15),
          estimatedDurationMinutes: 45,
          reason: 'Frenos',
        ),
      ).called(1);
      expect(vm.state.createAppointmentForm, isNull);
      expect(vm.state.notice?.asString(strings), strings.receptionAppointmentScheduledNotice);
    });
  });

  group('editar contacto', () {
    test('guarda y actualiza al cliente en el resultado', () async {
      const updated = Customer(
        id: 'c1',
        type: CustomerType.individual,
        displayName: 'Ana Torres Quispe',
        taxId: '45678912',
        email: 'nuevo@correo.pe',
        phone: '999888777',
      );
      when(() => find.execute(any())).thenAnswer(
        (_) async => const VehicleWithOwner(vehicle: testVehicle, owner: testOwner),
      );
      when(
        () => updateContact.execute('c1', email: 'nuevo@correo.pe', phone: '999888777'),
      ).thenAnswer((_) async => updated);
      final vm = build();
      await pumpEventQueue();
      vm.onQueryChange('BKR418');
      await vm.onSearch();

      vm.onOpenEditContact(testOwner);
      vm.onEditContactEmailChange('nuevo@correo.pe');
      vm.onEditContactPhoneChange('999888777');
      await vm.onConfirmEditContact();

      expect(vm.state.editContactForm, isNull);
      expect(vm.state.vehicleResult?.owner?.email, 'nuevo@correo.pe');
      expect(vm.state.notice?.asString(strings), strings.receptionEditContactNotice);
    });
  });

  group('parseLimaDateTime', () {
    test('acepta fecha y hora válidas y rechaza fechas imposibles', () {
      expect(VehicleSearchViewModel.parseLimaDateTime('2026-11-23', '10:00'), DateTime.utc(2026, 11, 23, 15));
      expect(VehicleSearchViewModel.parseLimaDateTime('2026-02-30', '10:00'), isNull);
      expect(VehicleSearchViewModel.parseLimaDateTime('23/11/2026', '10:00'), isNull);
      expect(VehicleSearchViewModel.parseLimaDateTime('2026-11-23', '24:00'), isNull);
    });
  });
}
