import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/appointment.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/customer.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/vehicle.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const receptionAllPermissions = {
  'crm:customers:read',
  'crm:customers:create',
  'crm:customers:update',
  'crm:vehicles:read',
  'crm:vehicles:create',
  'crm:appointments:read',
  'crm:appointments:create',
  'crm:appointments:update',
  'operations:work_orders:create',
};

Session receptionSession(Set<String> permissions) {
  return Session(
    userId: 'u1',
    email: 'a@b.pe',
    fullName: 'Andrés',
    tenantId: 't1',
    tenantName: 'Taller',
    membershipId: 'm1',
    permissions: permissions,
    plan: null,
    branchId: 'b1',
    shiftId: 's1',
  );
}

const testVehicle = Vehicle(
  id: 'v1',
  plate: 'BKR418',
  brand: 'Toyota',
  model: 'Yaris',
  year: 2019,
  engineType: EngineType.gasoline,
  currentOwnerId: 'c1',
);

const testOwner = Customer(
  id: 'c1',
  type: CustomerType.individual,
  displayName: 'Ana Torres Quispe',
  taxId: '45678912',
  email: 'ana@correo.pe',
  phone: '987654321',
  status: 'ACTIVE',
);

Appointment testAppointment(String id, AppointmentStatus status, {String? plate, String? name}) {
  return Appointment(
    id: id,
    branchId: 'b1',
    customerId: 'c1',
    vehicleId: 'v1',
    scheduledAt: DateTime.utc(2026, 10, 27, 15),
    estimatedDurationMinutes: 60,
    reason: 'Cambio de aceite',
    status: status,
    plate: plate ?? 'BKR418',
    customerName: name ?? 'Ana Torres Quispe',
  );
}

/// Conectividad sin red para las pruebas de ViewModel.
class OfflineConnectivity extends ConnectivityObserver {
  OfflineConnectivity() : super(changes: const Stream.empty(), current: () async => []);

  @override
  bool get isOnline => false;
}

Future<void> loadSatoshi() async {
  final loader = FontLoader('Satoshi');
  for (final file in ['regular', 'medium', 'bold', 'black']) {
    loader.addFont(rootBundle.load('assets/fonts/satoshi_$file.otf'));
  }
  await loader.load();
}

Future<void> pumpReception(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(390 * 3, 3000 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AtelierTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: child,
    ),
  );
  await tester.pump(const Duration(milliseconds: 400));
}

/// Quita del árbol las animaciones infinitas (balizas, huesos) antes de cerrar la prueba.
Future<void> teardownReception(WidgetTester tester) => tester.pumpWidget(const SizedBox());
