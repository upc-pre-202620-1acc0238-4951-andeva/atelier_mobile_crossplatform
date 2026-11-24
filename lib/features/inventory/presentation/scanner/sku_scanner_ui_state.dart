import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';

class SkuScannerUiState {
  final String manualSku;
  final String? lastScannedSku;
  final bool isSearching;
  final String? notFoundSku;
  final String? invalidSku;
  final UiText? error;
  final String? foundPartId;
  final bool canRead;

  const SkuScannerUiState({
    this.manualSku = '',
    this.lastScannedSku,
    this.isSearching = false,
    this.notFoundSku,
    this.invalidSku,
    this.error,
    this.foundPartId,
    this.canRead = true,
  });

  bool get hasFailure => notFoundSku != null || invalidSku != null || error != null;

  SkuScannerUiState copyWith({
    String? manualSku,
    String? lastScannedSku,
    bool clearLastScanned = false,
    bool? isSearching,
    String? notFoundSku,
    bool clearNotFound = false,
    String? invalidSku,
    bool clearInvalid = false,
    UiText? error,
    bool clearError = false,
    String? foundPartId,
    bool clearFoundPart = false,
    bool? canRead,
  }) {
    return SkuScannerUiState(
      manualSku: manualSku ?? this.manualSku,
      lastScannedSku: clearLastScanned ? null : lastScannedSku ?? this.lastScannedSku,
      isSearching: isSearching ?? this.isSearching,
      notFoundSku: clearNotFound ? null : notFoundSku ?? this.notFoundSku,
      invalidSku: clearInvalid ? null : invalidSku ?? this.invalidSku,
      error: clearError ? null : error ?? this.error,
      foundPartId: clearFoundPart ? null : foundPartId ?? this.foundPartId,
      canRead: canRead ?? this.canRead,
    );
  }
}
