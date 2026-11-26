import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/plan.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/request_notification_permission_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/freeze_telemetry_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/get_latest_telemetry_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/get_vehicle_telemetry_history_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/observe_diagnostics_sync_state_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/observe_live_telemetry_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/reconnect_obd_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/start_live_telemetry_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/stop_live_telemetry_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_errors.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/live/live_telemetry_screen.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/live/live_telemetry_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/live/live_telemetry_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/observe_vehicle_use_case.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _ObserveSession extends Mock implements ObserveSessionUseCase {}

class _ObserveVehicle extends Mock implements ObserveVehicleUseCase {}

class _ObserveLive extends Mock implements ObserveLiveTelemetryUseCase {}

class _ObserveSync extends Mock implements ObserveDiagnosticsSyncStateUseCase {}

class _Start extends Mock implements StartLiveTelemetryUseCase {}

class _Stop extends Mock implements StopLiveTelemetryUseCase {}

class _Freeze extends Mock implements FreezeTelemetryUseCase {}

class _Latest extends Mock implements GetLatestTelemetryUseCase {}

class _History extends Mock implements GetVehicleTelemetryHistoryUseCase {}

class _Reconnect extends Mock implements ReconnectObdUseCase {}

class _Notifications extends Mock implements RequestNotificationPermissionUseCase {}

final _sample = TelemetrySample(
  timestamp: DateTime.utc(2026, 11, 25, 15),
  engineTempCelsius: 110,
  engineRpm: 2500,
  batteryVoltage: 13.8,
  intakePressureKpa: 35,
  engineLoadPercentage: 42,
  throttlePositionPercentage: 18,
);

void main() {
  final strings = lookupAppLocalizations(const Locale('es'));
  late _Start start;
  late _Stop stop;
  late _Freeze freeze;
  late _Latest latest;
  late _History history;
  late _Reconnect reconnect;
  late StreamController<LiveTelemetry> live;
  final fixedNow = DateTime.utc(2026, 11, 26, 12);

  setUp(() {
    start = _Start();
    stop = _Stop();
    freeze = _Freeze();
    latest = _Latest();
    history = _History();
    reconnect = _Reconnect();
    live = StreamController<LiveTelemetry>.broadcast();
    when(() => latest.execute(any())).thenAnswer((_) async => null);
    when(
      () => history.execute(any(), from: any(named: 'from'), to: any(named: 'to'), bucket: any(named: 'bucket')),
    ).thenAnswer((_) async => const []);
  });

  tearDown(() => live.close());

  LiveTelemetryViewModel build(Set<String> permissions, {bool telemetryInPlan = true}) {
    final session = _ObserveSession();
    when(() => session.execute()).thenAnswer(
      (_) => Stream.value(
        Session(
          userId: 'u1',
          email: 'a@b.pe',
          fullName: 'Ana',
          tenantId: 't1',
          tenantName: 'Taller',
          membershipId: 'm1',
          permissions: permissions,
          plan: telemetryInPlan
              ? null
              : const Plan(
                  tier: 'BASIC',
                  status: 'ACTIVE',
                  accessGranted: true,
                  iotTelemetryEnabled: false,
                  aiDiagnosticsEnabled: false,
                ),
        ),
      ),
    );
    final vehicle = _ObserveVehicle();
    when(() => vehicle.execute(any())).thenAnswer((_) => const Stream.empty());
    final observeLive = _ObserveLive();
    when(() => observeLive.execute()).thenAnswer((_) => live.stream);
    final sync = _ObserveSync();
    when(() => sync.execute(any())).thenAnswer((_) => const Stream.empty());
    final notifications = _Notifications();
    when(() => notifications.execute()).thenAnswer((_) async => false);
    return LiveTelemetryViewModel(
      vehicleId: 'v1',
      observeSession: session,
      observeVehicle: vehicle,
      observeLiveTelemetry: observeLive,
      observeSyncState: sync,
      startTelemetry: start,
      stopTelemetry: stop,
      reconnectObd: reconnect,
      freezeTelemetry: freeze,
      getLatestTelemetry: latest,
      getTelemetryHistory: history,
      requestNotificationPermission: notifications,
      connectivity: ConnectivityObserver(
        changes: const Stream.empty(),
        current: () async => [ConnectivityResult.wifi],
      ),
      now: () => fixedNow,
    );
  }

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('LiveTelemetryViewModel', () {
    test('inicia con el adaptador conectado y detiene el muestreo', () async {
      when(() => start.execute(any())).thenAnswer((_) async {});
      when(() => stop.execute()).thenAnswer((_) async {});
      final vm = build({'iot:telemetry:ingest'});
      await settle();

      live.add(const LiveTelemetry(state: ObdLinkState.connected));
      await settle();
      // Conectado desde cero: el muestreo arranca solo, como en Android.
      verify(() => start.execute('v1')).called(1);

      live.add(LiveTelemetry(state: ObdLinkState.streaming, vehicleId: 'v1', sample: _sample));
      await settle();
      expect(vm.state.isStreaming, isTrue);
      await vm.stopStreaming();
      verify(() => stop.execute()).called(1);
      vm.dispose();
    });

    test('con el muestreo activo no vuelve a iniciar', () async {
      when(() => start.execute(any())).thenAnswer((_) async {});
      final vm = build({'iot:telemetry:ingest'});
      await settle();
      live.add(LiveTelemetry(state: ObdLinkState.streaming, vehicleId: 'v1', sample: _sample));
      await settle();
      await vm.startStreamingIfEligible();
      verifyNever(() => start.execute(any()));
      vm.dispose();
    });

    test('congela la muestra en vivo (US18 E2)', () async {
      when(
        () => freeze.execute(),
      ).thenReturn(TelemetrySnapshot(vehicleId: 'v1', sample: _sample, warnings: const {}));
      final vm = build({'iot:telemetry:ingest'});
      live.add(LiveTelemetry(state: ObdLinkState.streaming, vehicleId: 'v1', sample: _sample));
      await settle();

      vm.freezeSample();
      expect(vm.state.frozenSnapshot?.sample, same(_sample));
      vm.dismissFrozenSnapshot();
      expect(vm.state.frozenSnapshot, isNull);
      vm.dispose();
    });

    test('no muestra las cifras de otro vehículo y lo avisa', () async {
      final vm = build({'iot:telemetry:ingest'});
      await settle();
      live.add(LiveTelemetry(state: ObdLinkState.streaming, vehicleId: 'v2', sample: _sample));
      await settle();

      expect(vm.state.connectedToOtherVehicle, isTrue);
      expect(vm.state.liveSample, isNull);
      expect(vm.state.linkState, ObdLinkState.disconnected);
      vm.dispose();
    });

    test('con solo lectura trae la última del servidor y el historial de 24 h por hora', () async {
      when(() => latest.execute(any())).thenAnswer((_) async => _sample);
      final bucket = TelemetryHistoryBucket(
        bucketTime: DateTime.utc(2026, 11, 26, 11),
        vehicleId: 'v1',
        sampleCount: 30,
      );
      when(
        () => history.execute(any(), from: any(named: 'from'), to: any(named: 'to'), bucket: any(named: 'bucket')),
      ).thenAnswer((_) async => [bucket]);
      final vm = build({'iot:telemetry:read'});
      await settle();
      await settle();

      expect(vm.state.isRemoteMode, isTrue);
      expect(vm.state.remoteTelemetry, same(_sample));
      expect(vm.state.telemetryHistory.single.sampleCount, 30);
      verify(
        () => history.execute('v1', from: fixedNow.subtract(const Duration(hours: 24)), to: fixedNow, bucket: '1 hour'),
      ).called(1);
      vm.dispose();
    });

    test('un historial que falla no tumba la lectura remota', () async {
      when(() => latest.execute(any())).thenAnswer((_) async => _sample);
      when(
        () => history.execute(any(), from: any(named: 'from'), to: any(named: 'to'), bucket: any(named: 'bucket')),
      ).thenThrow(const ApiException(httpStatus: 500, code: 'E', message: 'Falló'));
      final vm = build({'iot:telemetry:read'});
      await settle();
      await settle();

      expect(vm.state.remoteTelemetry, same(_sample));
      expect(vm.state.telemetryHistory, isEmpty);
      expect(vm.state.error, isNull);
      vm.dispose();
    });

    test('leer fallas no basta para la lectura remota', () async {
      final vm = build({'iot:faults:read'});
      await settle();
      expect(vm.state.canReadTelemetry, isFalse);
      expect(vm.state.canReadFaults, isTrue);
      verifyNever(() => latest.execute(any()));
      vm.dispose();
    });

    test('el plan sin telemetría lo marca y los errores de la sesión y del backend se muestran', () async {
      final locked = build({'iot:telemetry:ingest'}, telemetryInPlan: false);
      await settle();
      expect(locked.state.planIncludesTelemetry, isFalse);
      locked.dispose();

      when(() => start.execute(any())).thenThrow(const ObdNotConnectedException());
      final vm = build({'iot:telemetry:ingest'});
      live.add(const LiveTelemetry(state: ObdLinkState.connected));
      await settle();
      await settle();
      expect(vm.state.error?.asString(strings), strings.diagErrNotConnected);
      vm.dispose();

      when(
        () => latest.execute(any()),
      ).thenThrow(const ApiException(httpStatus: 403, code: 'F', message: 'Sin acceso'));
      final reader = build({'iot:telemetry:read'});
      await settle();
      await settle();
      expect(reader.state.error?.asString(strings), 'Sin acceso');
      reader.dispose();
    });

    test('reconectar reabre el escáner y retoma el muestreo', () async {
      when(() => reconnect.execute()).thenAnswer((_) async => const ObdConnectionInfo(protocol: 'CAN'));
      when(() => start.execute(any())).thenAnswer((_) async {});
      final vm = build({'iot:telemetry:ingest'});
      await settle();
      live.add(const LiveTelemetry(state: ObdLinkState.lost, vehicleId: 'v1'));
      await settle();

      await vm.reconnect();

      verify(() => reconnect.execute()).called(1);
      verify(() => start.execute('v1')).called(1);
      expect(vm.state.isReconnecting, isFalse);
      vm.dispose();
    });

    test('si reconectar falla muestra el error y no muestrea', () async {
      when(() => reconnect.execute()).thenThrow(const ObdAdapterUnreachableException());
      final vm = build({'iot:telemetry:ingest'});
      await settle();

      await vm.reconnect();

      expect(vm.state.error?.asString(strings), strings.diagErrAdapterUnreachable);
      expect(vm.state.isReconnecting, isFalse);
      verifyNever(() => start.execute(any()));
      vm.dispose();
    });

    test('sin permiso de ingesta no reconecta', () async {
      final vm = build({'iot:telemetry:read'});
      await settle();
      await vm.reconnect();
      verifyNever(() => reconnect.execute());
      vm.dispose();
    });
  });

  group('LiveTelemetryContent', () {
    Future<void> pump(WidgetTester tester, LiveTelemetryUiState state, {VoidCallback? onReconnect}) async {
      tester.view.physicalSize = const Size(390 * 3, 2400 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: AtelierTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
          home: LiveTelemetryContent(
            state: state,
            onBack: () {},
            onStartStreaming: () {},
            onStopStreaming: () {},
            onFreezeSample: () {},
            onRefreshRemote: () async {},
            onOpenFaults: () {},
            onReconnect: onReconnect ?? () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
    }

    testWidgets('en vivo: las ocho fichas calibradas, estado por PID y acciones', (tester) async {
      await pump(
        tester,
        LiveTelemetryUiState(
          vehicleId: 'v1',
          canUseTelemetry: true,
          canReadFaults: true,
          linkState: ObdLinkState.streaming,
          liveSample: _sample,
        ),
      );
      for (final label in [
        strings.diagPidRpm,
        strings.diagPidCoolant,
        strings.diagPidVoltage,
        strings.diagPidLoad,
        strings.diagPidSpeed,
        strings.diagPidThrottle,
        strings.diagPidFuel,
        strings.diagPidIntakePressure,
      ]) {
        expect(find.textContaining(label, findRichText: true), findsWidgets, reason: label);
      }
      expect(find.text(strings.diagPidStatusOverheat), findsOneWidget);
      expect(find.text(strings.diagLiveStop), findsOneWidget);
      expect(find.text(strings.diagLiveFreeze), findsOneWidget);
      expect(find.text(strings.diagLiveFaults), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('sin PID 0105 avisa y sin permiso solo el aviso', (tester) async {
      await pump(
        tester,
        LiveTelemetryUiState(
          vehicleId: 'v1',
          canUseTelemetry: true,
          linkState: ObdLinkState.streaming,
          liveSample: TelemetrySample(timestamp: DateTime.utc(2026, 11, 25), engineRpm: 800),
        ),
      );
      expect(find.textContaining(strings.diagLiveMissingPid0105, findRichText: true), findsOneWidget);
      await tester.pumpWidget(const SizedBox());

      await pump(tester, const LiveTelemetryUiState(vehicleId: 'v1'));
      expect(find.text(strings.diagLiveNoPermission), findsOneWidget);
      expect(find.text(strings.diagLiveStart), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('plan sin telemetría: solo el estado de plan y sin barra inferior', (tester) async {
      await pump(
        tester,
        const LiveTelemetryUiState(vehicleId: 'v1', canUseTelemetry: true, planIncludesTelemetry: false),
      );
      expect(find.text(strings.diagHubPlanLocked), findsOneWidget);
      expect(find.text(strings.diagLiveStart), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('señal perdida: Reconectar en la barra y banner', (tester) async {
      var reconnected = 0;
      await pump(
        tester,
        const LiveTelemetryUiState(vehicleId: 'v1', canUseTelemetry: true, linkState: ObdLinkState.lost),
        onReconnect: () => reconnected++,
      );
      expect(find.text(strings.diagErrConnectionLost), findsWidgets);
      await tester.tap(find.text(strings.diagLiveReconnect));
      expect(reconnected, 1);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('remoto: banner, fichas, historial por cubos y Actualizar', (tester) async {
      await pump(
        tester,
        LiveTelemetryUiState(
          vehicleId: 'v1',
          canReadTelemetry: true,
          remoteTelemetry: _sample,
          telemetryHistory: [
            TelemetryHistoryBucket(
              bucketTime: DateTime.utc(2026, 11, 26, 11),
              vehicleId: 'v1',
              avgEngineRpm: 2100,
              avgEngineTempCelsius: 91.4,
              avgBatteryVoltage: 13.76,
              avgSpeedKmh: 40,
              sampleCount: 30,
            ),
          ],
        ),
      );
      expect(find.text(strings.diagLiveRemoteBanner), findsOneWidget);
      expect(find.textContaining(strings.diagLiveHistoryHeader), findsOneWidget);
      expect(find.text('2100 rpm · 91 °C · 13.8 V · 40 km/h'), findsOneWidget);
      expect(find.text(strings.diagLiveHistorySamples(30)), findsOneWidget);
      expect(find.text(strings.diagLiveRefresh), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('remoto sin lecturas: estado vacío con Actualizar', (tester) async {
      await pump(tester, const LiveTelemetryUiState(vehicleId: 'v1', canReadTelemetry: true));
      expect(find.text(strings.diagLiveRemoteEmpty), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('la hoja de muestra congelada muestra las fichas de ese instante', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 2400 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: AtelierTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
          home: Scaffold(
            body: SingleChildScrollView(
              child: FrozenSampleSheet(
                snapshot: TelemetrySnapshot(vehicleId: 'v1', sample: _sample, warnings: const {}),
                onDismiss: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text(strings.diagLiveFrozenTitle), findsOneWidget);
      expect(find.text(strings.diagLiveFrozenSaved), findsOneWidget);
      expect(find.text(strings.diagPidLoad), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  });
}
