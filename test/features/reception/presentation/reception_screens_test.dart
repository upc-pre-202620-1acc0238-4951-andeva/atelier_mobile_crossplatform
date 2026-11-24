import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/affiliation_lookup.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/appointment.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/customer.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/vehicle.dart';
import 'package:atelier_mobile_crossplatform/features/reception/presentation/affiliation/affiliation_screen.dart';
import 'package:atelier_mobile_crossplatform/features/reception/presentation/affiliation/affiliation_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/reception/presentation/register/register_customer_screen.dart';
import 'package:atelier_mobile_crossplatform/features/reception/presentation/register/register_customer_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/reception/presentation/search/vehicle_search_screen.dart';
import 'package:atelier_mobile_crossplatform/features/reception/presentation/search/vehicle_search_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/reception/presentation/search/vehicle_search_sheets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'reception_presentation_support.dart';

const _allowed = VehicleSearchUiState(
  canSearch: true,
  canReadCustomers: true,
  canUpdateCustomer: true,
  canViewAppointments: true,
  canCreateAppointments: true,
  canMarkArrival: true,
  canRegister: true,
  canOpenWorkOrder: true,
);

void main() {
  setUpAll(loadSatoshi);

  group('VehicleSearchContent', () {
    testWidgets('cargado: ficha del vehículo y citas del día', (tester) async {
      await pumpReception(
        tester,
        VehicleSearchContent(
          state: _allowed.copyWith(
            query: 'BKR-418',
            searched: true,
            vehicleResult: const VehicleWithOwner(vehicle: testVehicle, owner: testOwner),
            appointments: [
              testAppointment('a1', AppointmentStatus.confirmed),
              testAppointment('a2', AppointmentStatus.pending, plate: 'F4T119', name: 'Transportes Andes SAC'),
            ],
          ),
          actions: const VehicleSearchActions(),
        ),
      );

      expect(find.text('Recibir vehículo'), findsOneWidget);
      expect(find.text('Toyota Yaris 2019'), findsOneWidget);
      expect(find.text('Abrir orden'), findsOneWidget);
      expect(find.text('Editar contacto'), findsOneWidget);
      expect(find.text('Agenda de citas · 2'), findsOneWidget);
      expect(find.text('Transportes Andes SAC'), findsOneWidget);
      expect(find.text('Confirmada'), findsOneWidget);
      expect(find.text('Pendiente'), findsOneWidget);
      expect(find.text('Nueva cita'), findsOneWidget);
      await teardownReception(tester);
    });

    testWidgets('vacío: sin resultado ofrece registrar o afiliar; sin citas lo dice', (tester) async {
      await pumpReception(
        tester,
        VehicleSearchContent(
          state: _allowed.copyWith(query: 'XYZ-999', searched: true),
          actions: const VehicleSearchActions(),
        ),
      );

      expect(find.text('No hay un vehículo con la placa XYZ-999.'), findsOneWidget);
      expect(find.text('Registrar cliente y vehículo'), findsOneWidget);
      expect(find.text('Afiliar por correo'), findsOneWidget);
      expect(find.text('No hay citas para hoy.'), findsOneWidget);
      await teardownReception(tester);
    });

    testWidgets('error: muestra el mensaje con reintentar', (tester) async {
      await pumpReception(
        tester,
        VehicleSearchContent(
          state: _allowed.copyWith(
            query: 'BKR-418',
            error: const UiText.dynamic('No se pudo consultar el vehículo. Inténtalo de nuevo.'),
          ),
          actions: const VehicleSearchActions(),
        ),
      );

      expect(find.text('No se pudo consultar el vehículo. Inténtalo de nuevo.'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
      await teardownReception(tester);
    });

    testWidgets('sin red: avisa que se busca en el teléfono y deshabilita el alta', (tester) async {
      await pumpReception(
        tester,
        VehicleSearchContent(
          state: _allowed.copyWith(query: 'XYZ-999', searched: true, isOnline: false),
          actions: const VehicleSearchActions(),
        ),
      );

      expect(find.text('Sin conexión. Buscas entre los datos guardados en este teléfono.'), findsOneWidget);
      expect(find.text('Nueva cita'), findsNothing);
      await teardownReception(tester);
    });

    testWidgets('sin permiso: solo el aviso de acceso', (tester) async {
      await pumpReception(
        tester,
        const VehicleSearchContent(state: VehicleSearchUiState(), actions: VehicleSearchActions()),
      );

      expect(find.text('Tu perfil no tiene acceso a Recepción.'), findsOneWidget);
      expect(find.text('Buscar'), findsNothing);
      await teardownReception(tester);
    });

    testWidgets('tocar una cita pendiente abre sus acciones', (tester) async {
      String? opened;
      await pumpReception(
        tester,
        VehicleSearchContent(
          state: _allowed.copyWith(appointments: [testAppointment('a1', AppointmentStatus.pending)]),
          actions: VehicleSearchActions(onOpenAppointmentActions: (id) => opened = id),
        ),
      );

      await tester.tap(find.text('Ana Torres Quispe'));
      expect(opened, 'a1');
      await teardownReception(tester);
    });
  });

  group('AppointmentActionsSheet', () {
    testWidgets('pendiente: confirmar, llegada, reprogramar y cancelar; cancelar pide motivo', (tester) async {
      String? cancelled;
      await pumpReception(
        tester,
        Scaffold(
          body: AppointmentActionsSheet(
            appointment: testAppointment('a1', AppointmentStatus.pending),
            state: _allowed,
            onConfirmAppointment: () {},
            onMarkArrived: () {},
            onReschedule: (_, _) {},
            onCancelAppointment: (reason) => cancelled = reason,
            onDismiss: () {},
          ),
        ),
      );

      expect(find.text('Gestionar cita'), findsOneWidget);
      expect(find.text('Confirmar cita'), findsOneWidget);
      expect(find.text('Registrar llegada'), findsOneWidget);

      await tester.tap(find.text('Cancelar cita'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Sí, cancelar cita'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'No vino');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Sí, cancelar cita'));
      expect(cancelled, 'No vino');
      await teardownReception(tester);
    });
  });

  group('AffiliationContent', () {
    AffiliationContent content(AffiliationUiState state) => AffiliationContent(
      state: state,
      onBack: () {},
      onEmailChange: (_) {},
      onTaxIdChange: (_) {},
      onPhoneChange: (_) {},
      onSearch: () {},
      onAffiliate: () {},
      onRegisterWalkIn: () {},
    );

    testWidgets('cuenta encontrada: lista los vehículos y pide el documento', (tester) async {
      await pumpReception(
        tester,
        content(
          const AffiliationUiState(
            email: 'ana@correo.pe',
            canLookup: true,
            canAffiliate: true,
            taxId: '45678912',
            lookup: AffiliationLookup(
              platformAccount: PlatformAccount(userId: 'u1', email: 'ana@correo.pe', fullName: 'Ana Torres'),
              vehicles: [testVehicle],
              nextStep: AffiliationStep.affiliate,
            ),
          ),
        ),
      );

      expect(find.textContaining('Cuenta de Atelier encontrada.'), findsOneWidget);
      expect(find.text('Vehículos que se vincularán · 1'), findsOneWidget);
      expect(find.text('Afiliar al taller'), findsOneWidget);
      await teardownReception(tester);
    });

    testWidgets('vacío: sin cuenta propone registrar presencial', (tester) async {
      await pumpReception(
        tester,
        content(
          const AffiliationUiState(
            email: 'luis@correo.pe',
            canLookup: true,
            canAffiliate: true,
            lookup: AffiliationLookup(nextStep: AffiliationStep.registerWalkIn),
          ),
        ),
      );

      expect(find.textContaining('Sin cuenta en Atelier.'), findsOneWidget);
      expect(find.text('Registrar cliente presencial'), findsOneWidget);
      await teardownReception(tester);
    });

    testWidgets('error y sin red', (tester) async {
      await pumpReception(
        tester,
        content(
          const AffiliationUiState(
            email: 'ana@',
            canLookup: true,
            invalidField: 'email',
            isOnline: false,
            error: UiText.dynamic('Revisa los datos marcados.'),
          ),
        ),
      );

      expect(find.text('Revisa los datos marcados.'), findsOneWidget);
      expect(find.text('Ingresa un correo válido.'), findsOneWidget);
      await teardownReception(tester);
    });

    testWidgets('sin permiso', (tester) async {
      await pumpReception(tester, content(const AffiliationUiState()));

      expect(find.text('Tu perfil no tiene permiso para esta acción.'), findsOneWidget);
      await teardownReception(tester);
    });
  });

  group('RegisterCustomerContent', () {
    RegisterCustomerContent content(RegisterCustomerUiState state) =>
        RegisterCustomerContent(state: state, onBack: () {}, actions: const RegisterCustomerActions());

    testWidgets('persona: secciones cliente y vehículo', (tester) async {
      await pumpReception(
        tester,
        content(
          const RegisterCustomerUiState(
            firstName: 'Ana',
            lastName: 'Torres',
            taxId: '45678912',
            plate: 'BKR418',
            brand: 'Toyota',
            model: 'Yaris',
            canRegister: true,
          ),
        ),
      );

      expect(find.text('Registrar cliente'), findsOneWidget);
      expect(find.text('Nombres'), findsOneWidget);
      expect(find.text('Gasolina'), findsOneWidget);
      expect(find.text('Registrar cliente y vehículo'), findsOneWidget);
      await teardownReception(tester);
    });

    testWidgets('empresa con error de RUC', (tester) async {
      await pumpReception(
        tester,
        content(
          const RegisterCustomerUiState(
            kind: CustomerType.company,
            companyName: 'Transportes Andes SAC',
            taxId: '2012345',
            canRegister: true,
            invalidField: 'taxId',
            error: UiText.dynamic('Revisa los datos marcados.'),
          ),
        ),
      );

      expect(find.text('Razón social'), findsOneWidget);
      expect(find.text('El RUC debe tener entre 11 y 20 caracteres.'), findsOneWidget);
      await teardownReception(tester);
    });

    testWidgets('vehículo de un cliente existente oculta la sección de cliente', (tester) async {
      await pumpReception(
        tester,
        content(
          const RegisterCustomerUiState(
            registeredCustomerId: 'c1',
            presetCustomerName: 'Ana Torres Quispe',
            canRegister: true,
          ),
        ),
      );

      expect(find.text('Agregar vehículo'), findsOneWidget);
      expect(find.text('Propietario seleccionado: Ana Torres Quispe'), findsOneWidget);
      expect(find.text('Nombres'), findsNothing);
      expect(find.text('Registrar vehículo'), findsOneWidget);
      await teardownReception(tester);
    });

    testWidgets('sin permiso y sin red', (tester) async {
      await pumpReception(tester, content(const RegisterCustomerUiState(isOnline: false)));

      expect(find.text('Tu perfil no tiene permiso para esta acción.'), findsOneWidget);
      await teardownReception(tester);
    });
  });
}
