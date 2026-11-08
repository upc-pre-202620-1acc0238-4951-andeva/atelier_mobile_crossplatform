import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:decimal/decimal.dart';

/// Reglas de caja. Los montos de la orden van sin IGV y las líneas del comprobante con IGV
/// (docs/api/README.md); el IGV se aplica por unidad y por línea (H26).
abstract final class CashierValidation {
  static final igvFactor = Decimal.parse('1.18');
  static final minAmount = Decimal.parse('0.01');
  static const maxReferenceLength = 100;

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
}
