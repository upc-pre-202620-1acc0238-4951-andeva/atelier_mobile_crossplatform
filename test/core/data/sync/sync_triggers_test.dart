import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/sync_triggers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StreamController<List<ConnectivityResult>> changes;
  late ConnectivityObserver observer;
  late SyncTriggers triggers;
  var syncs = 0;
  var refreshes = 0;

  Future<void> emit(ConnectivityResult result) async {
    changes.add([result]);
    await pumpEventQueue();
  }

  Future<void> start(ConnectivityResult initial) async {
    syncs = 0;
    refreshes = 0;
    changes = StreamController();
    observer = ConnectivityObserver(
      changes: changes.stream,
      current: () async => [initial],
    );
    triggers = SyncTriggers(
      connectivity: observer,
      sync: () => syncs++,
      refreshExternalChanges: () => refreshes++,
    );
    await triggers.start();
  }

  tearDown(() async {
    triggers.dispose();
    observer.dispose();
    await changes.close();
  });

  test('intenta enviar al abrir, aun si arranca sin red', () async {
    await start(ConnectivityResult.none);

    expect(syncs, 1);
    expect(observer.isOnline, isFalse);
  });

  test('solo dispara al pasar de sin red a con red', () async {
    await start(ConnectivityResult.none);
    syncs = 0;

    await emit(ConnectivityResult.wifi);
    expect(syncs, 1);
    expect(observer.isOnline, isTrue);

    await emit(ConnectivityResult.mobile); // Cambió de red, pero nunca estuvo sin ella.
    expect(syncs, 1);

    await emit(ConnectivityResult.none);
    expect(syncs, 1);
    expect(observer.isOnline, isFalse);

    await emit(ConnectivityResult.mobile);
    expect(syncs, 2);
  });

  test('al volver a primer plano relee lo externo y envía', () async {
    await start(ConnectivityResult.wifi);
    syncs = 0;

    final binding = WidgetsBinding.instance;
    binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    expect(syncs, 0);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

    expect(refreshes, 1);
    expect(syncs, 1);
  });

  test('avisa a los oyentes solo si cambia el estado', () async {
    await start(ConnectivityResult.wifi);
    var notified = 0;
    observer.addListener(() => notified++);

    await emit(ConnectivityResult.mobile);
    expect(notified, 0);

    await emit(ConnectivityResult.none);
    expect(notified, 1);
  });
}
