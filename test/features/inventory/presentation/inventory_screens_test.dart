import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/purchase_order.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/supplier.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/catalog/parts_catalog_screen.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/catalog/parts_catalog_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/detail/part_detail_screen.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/detail/part_detail_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/orders/purchase_order_detail_screen.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/orders/purchase_order_detail_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/orders/purchase_orders_screen.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/orders/purchase_orders_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/scanner/sku_scanner_screen.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/scanner/sku_scanner_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/suppliers/suppliers_screen.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/suppliers/suppliers_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/valuation/inventory_valuation_screen.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/valuation/inventory_valuation_ui_state.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _loadSatoshi() async {
  final loader = FontLoader('Satoshi');
  for (final file in ['regular', 'medium', 'bold', 'black']) {
    loader.addFont(rootBundle.load('assets/fonts/satoshi_$file.otf'));
  }
  await loader.load();
}

Future<void> _pump(WidgetTester tester, Widget child) async {
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

Future<void> _teardown(WidgetTester tester) => tester.pumpWidget(const SizedBox());

final _part = Part(
  id: 'p1',
  name: 'Filtro de aceite Bosch',
  sku: 'BOS-101',
  category: ItemCategory.filters,
  basePrice: Money.of('45.00', Money.pen),
  totalStock: Decimal.fromInt(8),
  minimumStock: Decimal.fromInt(4),
);

final _po = PurchaseOrder(
  id: 'po1',
  orderNumber: 'OC-0042',
  supplierId: 'sup1',
  branchId: 'b1',
  status: PurchaseOrderStatus.issued,
  totalCost: Money.of('450.00', Money.pen),
  lines: [
    PurchaseOrderLine(
      id: 'l1',
      itemId: 'p1',
      quantity: Decimal.fromInt(10),
      unitCost: Money.of('45.00', Money.pen),
      totalCost: Money.of('450.00', Money.pen),
    ),
  ],
);

void main() {
  setUpAll(_loadSatoshi);

  group('PartsCatalogContent & PartDetailContent', () {
    testWidgets('catálogo cargado, vacío y error', (tester) async {
      await _pump(
        tester,
        PartsCatalogContent(
          state: PartsCatalogUiState(isLoaded: true, parts: [_part]),
          onBack: () {},
          onQueryChange: (_) {},
          onCategoryClick: (_) {},
          onClearFilters: () {},
          onRefresh: () async {},
          onOpenPart: (_) {},
          onOpenScanner: () {},
          onOpenCreateSheet: () {},
        ),
      );
      expect(find.text('Filtro de aceite Bosch'), findsOneWidget);

      await _pump(
        tester,
        PartsCatalogContent(
          state: const PartsCatalogUiState(isLoaded: true),
          onBack: () {},
          onQueryChange: (_) {},
          onCategoryClick: (_) {},
          onClearFilters: () {},
          onRefresh: () async {},
          onOpenPart: (_) {},
          onOpenScanner: () {},
          onOpenCreateSheet: () {},
        ),
      );
      expect(find.text('Todavía no hay repuestos en el catálogo.'), findsOneWidget);

      await _pump(
        tester,
        PartsCatalogContent(
          state: const PartsCatalogUiState(isLoaded: true, error: UiText.dynamic('Error catálogo')),
          onBack: () {},
          onQueryChange: (_) {},
          onCategoryClick: (_) {},
          onClearFilters: () {},
          onRefresh: () async {},
          onOpenPart: (_) {},
          onOpenScanner: () {},
          onOpenCreateSheet: () {},
        ),
      );
      expect(find.text('Error catálogo'), findsOneWidget);
      await _teardown(tester);
    });

    testWidgets('detalle de repuesto cargado', (tester) async {
      await _pump(
        tester,
        PartDetailContent(
          state: PartDetailUiState(part: _part, isLoading: false, canReadBatches: true),
          onBack: () {},
          onRefresh: () async {},
          onOpenEditPart: () {},
          onOpenReceiveBatch: () {},
          onOpenDispatchFifo: () {},
          onOpenRestoreBatch: () {},
        ),
      );
      expect(find.text('Filtro de aceite Bosch'), findsOneWidget);
      await _teardown(tester);
    });
  });

  group('PurchaseOrdersContent & PurchaseOrderDetailContent', () {
    testWidgets('lista y detalle de orden sin recepción US34', (tester) async {
      await _pump(
        tester,
        PurchaseOrdersContent(
          state: PurchaseOrdersUiState(isLoading: false, orders: [_po]),
          onBack: () {},
          onStatusClick: (_) {},
          onRefresh: () async {},
          onOpenOrder: (_) {},
          onOpenCreateSheet: () {},
        ),
      );
      expect(find.text('Orden OC-0042'), findsOneWidget);

      await _pump(
        tester,
        PurchaseOrderDetailContent(
          state: PurchaseOrderDetailUiState(
            isLoading: false,
            order: _po,
            partNames: const {'p1': 'Filtro de aceite Bosch'},
            canRead: true,
            canCreate: true,
          ),
          onBack: () {},
          onRefresh: () async {},
          onOpenAddLine: () {},
          onIssueOrder: () {},
          onOpenCancel: () {},
        ),
      );
      expect(find.text('Orden OC-0042'), findsOneWidget);
      expect(find.text('Filtro de aceite Bosch'), findsOneWidget);
      // US34 recepción de orden excluida
      expect(find.text('Recibir orden'), findsNothing);
      await _teardown(tester);
    });
  });

  group('Suppliers / Valuation / SkuScanner', () {
    testWidgets('proveedores, valorización y escáner cargados', (tester) async {
      await _pump(
        tester,
        SuppliersContent(
          state: const SuppliersUiState(
            isLoading: false,
            suppliers: [
              Supplier(id: 'sup1', businessName: 'Repuestos Lima SAC', taxId: '20123456789', active: true),
            ],
          ),
          onBack: () {},
          onQueryChange: (_) {},
          onRefresh: () async {},
          onOpenCreate: () {},
          onOpenEdit: (_) {},
        ),
      );
      expect(find.text('Repuestos Lima SAC'), findsOneWidget);

      await _pump(
        tester,
        InventoryValuationContent(
          state: InventoryValuationUiState(
            isLoading: false,
            valuation: Money.of('5000.00', Money.pen),
            parts: [_part],
          ),
          onBack: () {},
          onRefresh: () async {},
        ),
      );
      expect(find.text('S/ 5,000.00'), findsOneWidget);

      await _pump(
        tester,
        SkuScannerContent(
          state: const SkuScannerUiState(),
          hasCameraPermission: false,
          onBack: () {},
          onRequestPermission: () {},
          onBarcodeDetected: (_) {},
          onManualSkuChange: (_) {},
          onSubmitManualSku: () {},
          onResetScan: () {},
        ),
      );
      expect(find.text('Escanear SKU'), findsOneWidget);
      await _teardown(tester);
    });
  });
}
