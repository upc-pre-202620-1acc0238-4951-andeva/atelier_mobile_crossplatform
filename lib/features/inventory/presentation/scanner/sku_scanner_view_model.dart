import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/find_part_by_sku_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_errors.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_validation.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/scanner/sku_scanner_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:flutter/foundation.dart';

/// Lector de códigos de barras/QR por SKU (US31 E1) con entrada manual siempre accesible.
class SkuScannerViewModel extends ChangeNotifier {
  final ObserveSessionUseCase observeSession;
  final FindPartBySkuUseCase findPartBySku;

  SkuScannerViewModel({required this.observeSession, required this.findPartBySku}) {
    _subscription = observeSession.execute().listen(
      (session) => _update(_state.copyWith(canRead: session?.has(Permission.partsRead) ?? false)),
    );
  }

  SkuScannerUiState _state = const SkuScannerUiState();
  SkuScannerUiState get state => _state;

  StreamSubscription<Object?>? _subscription;
  bool _disposed = false;

  void onBarcodeDetected(String rawValue) {
    final normalized = InventoryValidation.normalizeSku(rawValue);
    final current = _state;
    if (!current.canRead || current.isSearching || current.foundPartId != null) return;
    if (normalized.isEmpty || normalized == current.lastScannedSku) return;
    _update(_state.copyWith(lastScannedSku: normalized, manualSku: normalized));
    _lookupSku(rawValue);
  }

  void onManualSkuChange(String value) {
    _update(
      _state.copyWith(manualSku: value, clearNotFound: true, clearInvalid: true, clearError: true),
    );
  }

  void onSubmitManualSku() {
    final current = _state;
    if (!current.canRead || current.isSearching) return;
    final normalized = InventoryValidation.normalizeSku(current.manualSku);
    _update(_state.copyWith(lastScannedSku: normalized));
    _lookupSku(current.manualSku);
  }

  void onResetScan() {
    _update(
      _state.copyWith(
        clearLastScanned: true,
        clearNotFound: true,
        clearInvalid: true,
        clearError: true,
      ),
    );
  }

  void onPartNavigated() {
    _update(_state.copyWith(clearFoundPart: true, clearLastScanned: true));
  }

  Future<void> _lookupSku(String rawSku) async {
    _update(
      _state.copyWith(isSearching: true, clearNotFound: true, clearInvalid: true, clearError: true),
    );
    try {
      final part = await findPartBySku.execute(rawSku);
      if (part != null) {
        _update(_state.copyWith(isSearching: false, foundPartId: part.id));
      } else {
        _update(
          _state.copyWith(
            isSearching: false,
            notFoundSku: InventoryValidation.normalizeSku(rawSku),
          ),
        );
      }
    } on InvalidInventoryInputException catch (e) {
      if (e.field == 'sku') {
        final trimmed = rawSku.trim();
        _update(_state.copyWith(isSearching: false, invalidSku: trimmed.isEmpty ? rawSku : trimmed));
      } else {
        _update(_state.copyWith(isSearching: false, error: toUiText(e)));
      }
    } on Object catch (e) {
      _update(_state.copyWith(isSearching: false, error: toUiText(e)));
    }
  }

  void _update(SkuScannerUiState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
