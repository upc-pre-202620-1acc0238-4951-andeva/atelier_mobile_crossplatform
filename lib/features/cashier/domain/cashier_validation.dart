import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:decimal/decimal.dart';

/// Reglas de caja. Los montos de la orden van sin IGV y las líneas del comprobante con IGV
/// (docs/api/README.md); el IGV se aplica por unidad y por línea (H26).
abstract final class CashierValidation {
  static final igvRate = Decimal.parse('0.18');
  static final igvFactor = Decimal.parse('1.18');
  static final minAmount = Decimal.parse('0.01');
  static const maxReferenceLength = 100;
  static const maxReasonLength = 250;
  static const maxLineDescriptionLength = 250;

  static final _placeholderProduct = RegExp(
    r'^Product [0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );
  static final _digits = RegExp(r'^[0-9]+$');
  static final _seriesSuffix = RegExp(r'^[0-9A-Za-z]{3}$');

  /// Precio con IGV redondeado a 2 decimales, mitad hacia arriba (los montos nunca son negativos).
  static Decimal withIgv(Decimal net) => (net * igvFactor).round(scale: 2);

  static bool isRuc(String taxId) =>
      taxId.length == 11 && _digits.hasMatch(taxId);

  static bool isDni(String taxId) =>
      taxId.length == 8 && _digits.hasMatch(taxId);

  /// `F` + 3 alfanuméricos para factura, `B` para boleta. Las notas de crédito no se configuran aquí.
  static bool isSeriesFor(VoucherType type, String serie) {
    final prefix = switch (type) {
      VoucherType.factura => 'F',
      VoucherType.boleta => 'B',
      VoucherType.notaCredito => null,
    };
    return prefix != null &&
        serie.length == 4 &&
        serie.startsWith(prefix) &&
        _seriesSuffix.hasMatch(serie.substring(1));
  }

  /// Nombre que el backend inventa (H11, H26): vacío, "Standard Service" o "Product {uuid}".
  static bool isPlaceholderDescription(String description) {
    final text = description.trim();
    return text.isEmpty ||
        text == 'Standard Service' ||
        _placeholderProduct.hasMatch(text);
  }

  /// Regla de la app, no de la API: al menos 0,01 y como mucho 2 decimales.
  static bool isPaymentAmount(Decimal amount) {
    return amount >= minAmount && amount == amount.round(scale: 2);
  }

  static bool isValidMoneyAmount(Decimal amount, {Decimal? max}) {
    return isPaymentAmount(amount) && (max == null || amount <= max);
  }

  static bool isValidReason(String reason) {
    final trimmed = reason.trim();
    return trimmed.isNotEmpty && trimmed.length <= maxReasonLength;
  }

  /// Serie de nota de crédito (4 caracteres): `F...` para factura, `B...` para boleta.
  static bool isCreditNoteSeries(String serie, [VoucherType? referenceType]) {
    final normalized = serie.trim().toUpperCase();
    if (normalized.length != 4 || !_seriesSuffix.hasMatch(normalized.substring(1))) {
      return false;
    }
    return switch (referenceType) {
      VoucherType.factura => normalized.startsWith('F'),
      VoucherType.boleta => normalized.startsWith('B'),
      _ => normalized.startsWith('F') || normalized.startsWith('B'),
    };
  }
}
