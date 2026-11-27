import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/domain/plan.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/navigation/main_tab.dart';
import 'package:flutter_test/flutter_test.dart';

Session _session(Iterable<Permission> permissions, {Plan? plan}) => Session(
  userId: 'u1',
  email: 'm@taller.pe',
  fullName: 'Andrés',
  tenantId: 't1',
  tenantName: 'Taller',
  membershipId: 'm1',
  permissions: {for (final p in permissions) p.value},
  plan: plan,
);

void main() {
  group('tabsFor', () {
    test('administrador: Hoy · Órdenes · Equipo, con Hoy primero', () {
      final tabs = MainTab.tabsFor(
        _session([
          Permission.attendanceAuditAll,
          Permission.workOrdersRead,
          Permission.workOrdersCreate,
          Permission.appointmentsRead,
        ]),
      );
      expect(tabs, [MainTab.today, MainTab.orders, MainTab.team]);
    });

    test('asesor de servicio (sin auditoría): Hoy · Recepción · Órdenes', () {
      final tabs = MainTab.tabsFor(
        _session([Permission.workOrdersCreate, Permission.customersRead, Permission.workOrdersRead]),
      );
      expect(tabs, [MainTab.today, MainTab.reception, MainTab.orders]);
    });

    test('mecánico: Turno · Tareas · Órdenes (sin telemetría)', () {
      final tabs = MainTab.tabsFor(
        _session([Permission.tasksRead, Permission.tasksTrackTime, Permission.workOrdersRead]),
      );
      expect(tabs, [MainTab.shift, MainTab.tasks, MainTab.orders]);
    });

    test('mecánico con telemetría: Turno · Tareas · OBD-II', () {
      final tabs = MainTab.tabsFor(
        _session([
          Permission.tasksRead,
          Permission.tasksTrackTime,
          Permission.telemetryIngest,
          Permission.workOrdersRead,
        ]),
      );
      expect(tabs, [MainTab.shift, MainTab.tasks, MainTab.obd]);
    });

    test('sin telemetría en el plan no hay OBD-II', () {
      final tabs = MainTab.tabsFor(
        _session(
          [Permission.tasksRead, Permission.tasksTrackTime, Permission.telemetryIngest],
          plan: const Plan(
            tier: 'BASIC',
            status: 'ACTIVE',
            accessGranted: true,
            iotTelemetryEnabled: false,
            aiDiagnosticsEnabled: true,
          ),
        ),
      );
      expect(tabs, [MainTab.shift, MainTab.tasks]);
    });

    test('recepcionista: Turno · Recepción · Órdenes', () {
      final tabs = MainTab.tabsFor(
        _session([Permission.appointmentsRead, Permission.customersCreate, Permission.workOrdersRead]),
      );
      expect(tabs, [MainTab.shift, MainTab.reception, MainTab.orders]);
    });

    test('encargado de inventario: Turno · Stock · Compras', () {
      final tabs = MainTab.tabsFor(
        _session([
          Permission.partsManage,
          Permission.partsRead,
          Permission.purchaseOrdersRead,
        ]),
      );
      expect(tabs, [MainTab.shift, MainTab.inventory, MainTab.purchases]);
    });

    test('cajero: Turno · Órdenes · Caja', () {
      final tabs = MainTab.tabsFor(
        _session([
          Permission.invoicesIssueSunat,
          Permission.invoicesRead,
          Permission.workOrdersRead,
        ]),
      );
      expect(tabs, [MainTab.shift, MainTab.orders, MainTab.cash]);
    });

    test('nunca pasa de tres pestañas ni repite', () {
      final tabs = MainTab.tabsFor(
        _session([
          Permission.tasksRead,
          Permission.tasksTrackTime,
          Permission.workOrdersRead,
          Permission.partsRead,
          Permission.partsManage,
          Permission.purchaseOrdersRead,
          Permission.appointmentsRead,
          Permission.invoicesRead,
          Permission.paymentsCreate,
          Permission.telemetryIngest,
        ]),
      );
      expect(tabs.length, lessThanOrEqualTo(3));
      expect(tabs.toSet().length, tabs.length);
    });

    test('Bahías: el permiso de lectura rellena la barra de piso', () {
      final tabs = MainTab.tabsFor(_session([Permission.baysRead]));
      expect(tabs, [MainTab.shift, MainTab.bays]);
    });

    test('técnico sin telemetría: Bahías va antes que Órdenes', () {
      final tabs = MainTab.tabsFor(
        _session([Permission.tasksRead, Permission.tasksTrackTime, Permission.baysRead, Permission.workOrdersRead]),
      );
      expect(tabs, [MainTab.shift, MainTab.tasks, MainTab.bays]);
    });

    test('supervisión parcial: Bahías rellena tras Hoy', () {
      final tabs = MainTab.tabsFor(_session([Permission.baysAssign, Permission.baysRead]));
      expect(tabs, [MainTab.today, MainTab.bays]);
    });

    test('sin permisos queda solo Turno', () {
      expect(MainTab.tabsFor(_session(const [])), [MainTab.shift]);
    });
  });

  group('prefersOperationalDashboard', () {
    test('cualquiera de los permisos de supervisión lo activa', () {
      for (final permission in [
        Permission.workOrdersCreate,
        Permission.quotationsApprove,
        Permission.attendanceAuditAll,
        Permission.baysAssign,
        Permission.obdDevicesRegister,
        Permission.cashflowExportPdf,
        Permission.fiscalConfigManage,
      ]) {
        expect(_session([permission]).prefersOperationalDashboard(), isTrue, reason: permission.value);
      }
    });

    test('piso y mostrador no lo activan', () {
      expect(
        _session([Permission.tasksRead, Permission.appointmentsRead]).prefersOperationalDashboard(),
        isFalse,
      );
    });
  });

  group('BarPrimaryAction', () {
    test('se decide por permiso, en este orden', () {
      expect(BarPrimaryAction.forSession(_session([Permission.workOrdersCreate])), BarPrimaryAction.receiveVehicle);
      expect(BarPrimaryAction.forSession(_session([Permission.appointmentsCreate])), BarPrimaryAction.newAppointment);
      expect(BarPrimaryAction.forSession(_session([Permission.paymentsCreate])), BarPrimaryAction.collectPayment);
      expect(BarPrimaryAction.forSession(_session([Permission.partsManage])), BarPrimaryAction.scanSku);
      expect(BarPrimaryAction.forSession(_session(const [])), BarPrimaryAction.none);
    });

    test('Mis tareas solo si Tareas no es ya una pestaña', () {
      final onlyTasks = _session([Permission.tasksTrackTime, Permission.tasksRead]);
      // Con Tareas en la barra no hace falta el botón.
      expect(MainTab.tabsFor(onlyTasks), contains(MainTab.tasks));
      expect(BarPrimaryAction.forSession(onlyTasks), BarPrimaryAction.none);
    });
  });
}
