import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chronometer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_live_beacon.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_photo_grid.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_pid_tile.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/icon/atelier_icons.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {bool dark = false}) => MaterialApp(
  theme: dark ? AtelierTheme.dark : AtelierTheme.light,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('es'),
  home: Scaffold(
    body: SingleChildScrollView(
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  ),
);

void main() {
  testWidgets('AtelierChronometer muestra estado y cifra, en claro y oscuro', (
    tester,
  ) async {
    for (final dark in [false, true]) {
      await tester.pumpWidget(
        _host(
          const AtelierChronometer(
            elapsedText: '01:24:18',
            statusLabel: 'En curso',
            visualState: ChronometerVisualState.running,
            caption: 'Est. 2.0 h',
          ),
          dark: dark,
        ),
      );
      expect(find.text('01:24:18'), findsOneWidget);
      expect(find.text('En curso'), findsOneWidget);
      expect(find.text('Est. 2.0 h'), findsOneWidget);
    }
    // Detiene las animaciones infinitas antes de terminar la prueba.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('AtelierPidTile muestra valor, unidad y estado fuera de rango', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const AtelierPidTile(
          label: 'Temp. motor',
          value: '108',
          unit: '°C',
          severity: PidSeverity.critical,
          statusText: 'Sobrecalentamiento',
          level: 0.92,
        ),
      ),
    );
    expect(find.text('Temp. motor'), findsOneWidget);
    expect(find.text('108'), findsOneWidget);
    expect(find.text('°C'), findsOneWidget);
    expect(find.text('Sobrecalentamiento'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('AtelierPidTile cargando oculta unidad, estado y barra', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const AtelierPidTile(
          label: 'RPM',
          value: '—',
          unit: 'rpm',
          statusText: 'Estable',
          level: 0.2,
          loading: true,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('rpm'), findsNothing);
    expect(find.text('Estable'), findsNothing);
    expect(find.byType(AtelierMetricBar), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('AtelierLiveBeacon y AtelierMetricBar se dibujan', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const Column(
          children: [
            AtelierLiveBeacon(color: Colors.green),
            AtelierLiveBeacon(color: Colors.red, pulsing: false),
            AtelierMetricBar(
              progress: 0.72,
              color: Colors.blue,
              markerAt: 0.85,
            ),
          ],
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(AtelierLiveBeacon), findsNWidgets(2));
    expect(find.byType(AtelierMetricBar), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'AtelierPhotoGrid reparte celdas, marca estados y reserva "agregar"',
    (tester) async {
      var added = 0;
      AtelierPhotoItem? tapped;
      await tester.pumpWidget(
        _host(
          AtelierPhotoGrid(
            items: const [
              AtelierPhotoItem(
                id: '1',
                model: '',
                caption: 'Desmontaje: pastillas',
              ),
              AtelierPhotoItem(
                id: '2',
                model: '',
                caption: 'Montaje: discos',
                syncState: PhotoSyncState.pending,
              ),
              AtelierPhotoItem(
                id: '3',
                model: '',
                syncState: PhotoSyncState.failed,
              ),
            ],
            addLabel: 'Tomar foto',
            onAddPhoto: () => added++,
            onPhotoClick: (item) => tapped = item,
          ),
        ),
      );
      expect(find.text('Pendiente'), findsOneWidget);
      expect(find.text('Falló'), findsOneWidget);
      expect(find.text('Guardada'), findsNothing);
      expect(find.text('Tomar foto'), findsOneWidget);

      await tester.tap(find.text('Tomar foto'));
      expect(added, 1);
      await tester.tap(find.text('Desmontaje: pastillas'));
      expect(tapped?.id, '1');
    },
  );

  testWidgets(
    'AtelierPhotoGrid sin onAddPhoto no muestra la celda de captura',
    (tester) async {
      await tester.pumpWidget(
        _host(
          const AtelierPhotoGrid(
            items: [AtelierPhotoItem(id: '1', model: '')],
            addLabel: 'Tomar foto',
          ),
        ),
      );
      expect(find.text('Tomar foto'), findsNothing);
    },
  );

  testWidgets('AtelierIcon dibuja los cuatro íconos propios', (tester) async {
    await tester.pumpWidget(
      _host(
        const Row(
          children: [
            AtelierIcon(AtelierIcons.person),
            AtelierIcon(AtelierIcons.assignment, size: 32, color: Colors.red),
            AtelierIcon(AtelierIcons.bluetoothSearching),
            AtelierIcon(AtelierIcons.home, semanticLabel: 'Inicio'),
          ],
        ),
      ),
    );
    expect(find.byType(AtelierIcon), findsNWidgets(4));
    expect(tester.getSize(find.byType(AtelierIcon).at(1)), const Size(32, 32));
    final bounds = AtelierIcons.home.buildPath().getBounds();
    expect(bounds.left, 4);
    expect(bounds.right, 20);
  });
}
