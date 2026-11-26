import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/get_stock_alerts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/observe_stock_alerts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/alerts/stock_alerts_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGet extends Mock implements GetStockAlertsUseCase {}

class _MockObserveAlerts extends Mock implements ObserveStockAlertsUseCase {}

class _MockObserveSession extends Mock implements ObserveSessionUseCase {}

Session _session(Set<String> permissions) => Session(
  userId: 'u1',
  email: 'a@b.pe',
  fullName: 'Andrés',
  tenantId: 't1',
  tenantName: 'Taller',
  membershipId: 'm1',
  permissions: permissions,
  plan: null,
  branchId: 'b1',
);

StockAlert _alert(String id, String name, int stock, int min) => StockAlert(
  itemId: id,
  name: name,
  sku: 'SKU-$id',
  currentStock: Decimal.fromInt(stock),
  minimumStock: Decimal.fromInt(min),
  deficit: Decimal.fromInt(min - stock > 0 ? min - stock : 0),
);

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late _MockGet get;
  late _MockObserveAlerts observe;
  late _MockObserveSession observeSession;
  late StreamController<List<StockAlert>> alerts;
  late StreamController<Session?> sessions;
  late StreamController<List<ConnectivityResult>> network;
  late ConnectivityObserver connectivity;
  late StockAlertsViewModel viewModel;

  setUp(() async {
    get = _MockGet();
    observe = _MockObserveAlerts();
    observeSession = _MockObserveSession();
    alerts = StreamController<List<StockAlert>>();
    sessions = StreamController<Session?>();
    network = StreamController<List<ConnectivityResult>>.broadcast();
    connectivity = ConnectivityObserver(
      changes: network.stream,
      current: () async => [ConnectivityResult.wifi],
    );
    await connectivity.start();
    when(() => observeSession.execute()).thenAnswer((_) => sessions.stream);
    when(() => observe.execute()).thenAnswer((_) => alerts.stream);
    when(() => get.execute())
        .thenAnswer((_) async => [_alert('1', 'Bujía', 2, 5)]);
    viewModel = StockAlertsViewModel(
      observeSession: observeSession,
      getAlerts: get,
      observeAlerts: observe,
      connectivity: connectivity,
    );
  });

  tearDown(() async {
    viewModel.dispose();
    connectivity.dispose();
    await alerts.close();
    await sessions.close();
    await network.close();
  });

  test(
    'E1: carga las alertas de los repuestos en el mínimo o por debajo',
    () async {
      await _settle();

      expect(viewModel.state.alerts.single.name, 'Bujía');
      expect(viewModel.state.isLoading, isFalse);
    },
  );

  test('las alertas con mayor faltante van primero', () async {
    alerts.add([_alert('1', 'Bujía', 4, 5), _alert('2', 'Filtro', 0, 6)]);
    await _settle();

    expect(viewModel.state.alerts.map((a) => a.name), ['Filtro', 'Bujía']);
  });

  test('E2: al recibir la compra el stock sube y la alerta desaparece sin recargar', () async {
    alerts.add([_alert('1', 'Bujía', 2, 5)]);
    await _settle();
    expect(viewModel.state.alerts, hasLength(1));

    alerts.add(
      const [],
    ); // la caché observada ya no tiene el repuesto bajo el mínimo
    await _settle();

    expect(viewModel.state.alerts, isEmpty);
  });

  test('el permiso inventory:alerts:read habilita la bandeja', () async {
    sessions.add(_session({}));
    await _settle();
    expect(viewModel.state.canRead, isFalse);

    sessions.add(_session({'inventory:alerts:read'}));
    await _settle();
    expect(viewModel.state.canRead, isTrue);
  });
}
