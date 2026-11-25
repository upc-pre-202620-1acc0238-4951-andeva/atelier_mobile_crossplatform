import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/request_notification_permission_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/freeze_telemetry_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/get_latest_telemetry_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/observe_diagnostics_sync_state_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/observe_live_telemetry_use_case.dart';
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

class _Notifications extends Mock implements RequestNotificationPermissionUseCase {}

final _sample = TelemetrySample(
  timestamp: DateTime.utc(2026, 11, 25, 15),
  engineTempCelsius: 110,
  engineRpm: 2500,
  batteryVoltage: 13.8,
  intakePressureKpa: 35,
);

void main() {
  final strings = lookupAppLocalizations(const Locale('es'));
  late _Start start;
  late _Stop stop;
  late _Freeze freeze;
  late _Latest latest;
  late StreamController<LiveTelemetry> live;

  setUp(() {
    start = _Start();
    stop = _Stop();
    freeze = _Freeze();
    latest = _Latest();
    live = StreamController<LiveTelemetry>.broadcast();
    when(() => latest.execute(any())).thenAnswer((_) async => null);
  });

  tearDown(() => live.close());

  LiveTelemetryViewModel build(Set<String> permissions) {
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
          plan: null,
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
      freezeTelemetry: freeze,
      getLatestTelemetry: latest,
      requestNotificationPermission: notifications,
      connectivity: ConnectivityObserver(
        changes: const Stream.empty(),
        current: () async => [ConnectivityResult.wifi],
      ),
    );
  }

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('LiveTelemetryViewModel', () {
    test('inicia con el adaptador conectado y detiene el muestreo', () async {
      when(() => start.execute(any())).thenAnswer((_) async {});
      when(() => stop.execute()).thenAnswer((_) async {});
      final vm = build({'iot:telemetry:ingest'});
      await settle();

      await vm.startStreaming();
      verifyNever(() => start.execute(any()));

      live.add(const LiveTelemetry(state: ObdLinkState.connected));
      await settle();
      await vm.startStreaming();
      verify(() => start.execute('v1')).called(1);

      live.add(LiveTelemetry(state: ObdLinkState.streaming, vehicleId: 'v1', sample: _sample));
      await settle();
      expect(vm.state.isStreamingHere, isTrue);
      await vm.stopStreaming();
      verify(() => stop.execute()).called(1);
      vm.dispose();
    });

    test('congela la muestra en vivo (US18 E2)', () async {
      when(() => freeze.execute())
          .thenReturn(TelemetrySnapshot(vehicleId: 'v1', sample: _sample, warnings: const {}));
      final vm = build({'iot:telemetry:ingest'});
      live.add(LiveTelemetry(state: ObdLinkState.streaming, vehicleId: 'v1', sample: _sample));
      await settle();
      live.add(LiveTelemetry(state: ObdLinkState.streaming, vehicleId: 'v1', sample: _sample));
      await settle();

      vm.freezeSample();
      expect(vm.state.frozen?.sample, same(_sample));
      vm.clearFrozenSnapshot();
      expect(vm.state.frozen, isNull);
      vm.dispose();
    });

    test('no muestra ni congela las cifras de otro vehículo', () async {
      final vm = build({'iot:telemetry:ingest'});
      await settle();
      live.add(LiveTelemetry(state: ObdLinkState.streaming, vehicleId: 'v2', sample: _sample));
      await settle();

      expect(vm.state.isOtherVehicle, isTrue);
      expect(vm.state.displayedSample, isNull);
      vm.freezeSample();
      verifyNever(() => freeze.execute());
      vm.dispose();
    });

    test('con solo lectura trae la última del servidor y calcula sus avisos', () async {
      when(() => latest.execute(any())).thenAnswer((_) async => _sample);
      final vm = build({'iot:telemetry:read'});
      await settle();
      await settle();

      expect(vm.state.showRemote, isTrue);
      expect(vm.state.displayedSample, same(_sample));
      expect(vm.state.displayedWarnings, {TelemetryWarning.coolantOverheat});
      vm.dispose();
    });

    test('leer fallas no basta para la lectura remota', () async {
      final vm = build({'iot:faults:read'});
      await settle();
      expect(vm.state.hasAnyPermission, isFalse);
      verifyNever(() => latest.execute(any()));
      vm.dispose();
    });

    test('los errores de la sesión y del backend se muestran', () async {
      when(() => start.execute(any())).thenThrow(const ObdNotConnectedException());
      final vm = build({'iot:telemetry:ingest'});
      live.add(const LiveTelemetry(state: ObdLinkState.connected));
      await settle();
      live.add(const LiveTelemetry(state: ObdLinkState.connected));
      await settle();
      await vm.startStreaming();
      expect(vm.state.error?.asString(strings), strings.diagErrNotConnected);
      vm.dispose();

      when(() => latest.execute(any()))
          .thenThrow(const ApiException(httpStatus: 403, code: 'F', message: 'Sin acceso'));
      final reader = build({'iot:telemetry:read'});
      await settle();
      await settle();
      expect(reader.state.error?.asString(strings), 'Sin acceso');
      reader.dispose();
    });
  });

  group('LiveTelemetryContent', () {
    Future<void> pump(WidgetTester tester, LiveTelemetryUiState state) async {
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
            onStart: () {},
            onStop: () {},
            onFreeze: () {},
            onClearFrozen: () {},
            onRefreshRemote: () {},
            onReconnect: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
    }

    testWidgets('en vivo: parámetros, aviso de umbral y acciones', (tester) async {
      await pump(
        tester,
        LiveTelemetryUiState(
          vehicleId: 'v1',
          canIngest: true,
          live: LiveTelemetry(
            state: ObdLinkState.streaming,
            vehicleId: 'v1',
            sample: _sample,
            warnings: const {TelemetryWarning.coolantOverheat},
          ),
        ),
      );
      for (final label in ['RPM', 'Refrigerante', 'Presión de admisión', 'Voltaje', 'Fuera de rango']) {
        expect(find.textContaining(label, findRichText: true), findsWidgets, reason: label);
      }
      expect(find.text(strings.diagLiveStop), findsOneWidget);
      expect(find.text(strings.diagLiveFreeze), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('sin PID 0105 avisa y sin permiso solo el aviso', (tester) async {
      await pump(
        tester,
        LiveTelemetryUiState(
          vehicleId: 'v1',
          canIngest: true,
          live: LiveTelemetry(
            state: ObdLinkState.streaming,
            vehicleId: 'v1',
            sample: TelemetrySample(timestamp: DateTime.utc(2026, 11, 25), engineRpm: 800),
          ),
        ),
      );
      expect(find.textContaining(strings.diagLiveMissingPid0105, findRichText: true), findsOneWidget);
      await tester.pumpWidget(const SizedBox());

      await pump(tester, const LiveTelemetryUiState(vehicleId: 'v1'));
      expect(find.text(strings.diagLiveNoPermission), findsOneWidget);
      expect(find.text(strings.diagLiveStart), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });
  });
}
