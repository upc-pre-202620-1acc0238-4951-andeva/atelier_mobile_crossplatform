import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher_draft.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/infrastructure/remote/cashier_dtos.dart';
import 'package:decimal/decimal.dart';

extension ElectronicVoucherDtoMapper on ElectronicVoucherDto {
  bool get isActiveSaleDto => isActiveSale(
    VoucherType.fromApi(voucherType),
    VoucherStatus.fromString(status),
  );

  /// `null` si falta un monto: nunca se guarda un 0 inventado.
  VoucherEntity? toEntity(String fallbackWorkOrderId, int syncedAt) {
    final total = totalAmount;
    final paid = paidAmount;
    final pending = pendingBalance;
    if (total == null || paid == null || pending == null) return null;
    return VoucherEntity(
      id: id,
      workOrderId: workOrderId ?? fallbackWorkOrderId,
      voucherType: voucherType ?? '',
      serie: serie ?? '',
      number: number ?? 0,
      totalAmount: total.toString(),
      paidAmount: paid.toString(),
      pendingBalance: pending.toString(),
      paymentStatus: paymentStatus ?? '',
      status: status ?? '',
      pdfUrl: pdfUrl,
      syncedAt: syncedAt,
    );
  }

  /// Lanza si falta un monto o una cantidad, o si un monto es negativo: mejor fallar que mostrar
  /// dinero inventado. Una moneda desconocida se muestra como PEN, pero [Voucher.currency] la guarda.
  Voucher toDomain() {
    final moneyCurrency = currency == Money.usd ? Money.usd : Money.pen;
    Money money(Decimal? amount) {
      if (amount == null) throw FormatException('Falta un monto en $id');
      return Money(amount: amount, currency: moneyCurrency);
    }

    final info = customerInfo;
    return Voucher(
      id: id,
      branchId: branchId,
      customerId: customerId,
      workOrderId: workOrderId,
      type: VoucherType.fromApi(voucherType),
      serie: serie ?? '',
      number: number ?? 0,
      currency: currency,
      subtotal: money(subtotal),
      igvAmount: money(igvAmount),
      totalAmount: money(totalAmount),
      paidAmount: money(paidAmount),
      pendingBalance: money(pendingBalance),
      paymentStatus: VoucherPaymentStatus.fromString(paymentStatus),
      status: VoucherStatus.fromString(status),
      customerInfo: info == null
          ? null
          : CustomerFiscalInfo(
              documentType: FiscalDocumentType.fromString(info.documentType),
              taxId: info.taxId ?? '',
              legalName: info.legalName ?? '',
              fiscalAddress: info.fiscalAddress,
            ),
      pdfUrl: pdfUrl,
      xmlUrl: xmlUrl,
      cdrUrl: cdrUrl,
      sunatResponseCode: sunatResponseCode,
      sunatDescription: sunatDescription,
      lines: [
        for (final line in lines)
          VoucherLine(
            id: line.id,
            itemId: line.itemId,
            itemType: VoucherItemType.fromString(line.itemType),
            description: line.description ?? '',
            quantity:
                line.quantity ??
                (throw FormatException('Falta la cantidad en $id')),
            unitValue: line.unitValue,
            unitPrice: line.unitPrice,
            igvAmount: line.igvAmount,
            totalLine: line.totalLine,
          ),
      ],
      payments: [
        for (final payment in payments) payment.toDomain(moneyCurrency),
      ],
      issuedAt: issuedAt == null ? null : DateTime.tryParse(issuedAt!),
    );
  }
}

extension VoucherPaymentDtoMapper on VoucherPaymentDto {
  Payment toDomain(String fallbackCurrency) {
    final value = amount;
    if (value == null) throw FormatException('Falta el monto del cobro $id');
    return Payment(
      id: id,
      voucherId: voucherId,
      amount: Money(
        amount: value,
        currency: currency == Money.usd || currency == Money.pen
            ? currency!
            : fallbackCurrency,
      ),
      method: PaymentMethod.fromString(paymentMethod),
      transactionReference: transactionReference,
      status: status,
      paidAt: paidAt == null ? null : DateTime.tryParse(paidAt!),
    );
  }
}

extension VoucherEntityMapper on VoucherEntity {
  /// `null` si un monto guardado no se puede leer.
  VoucherSummary? toSummary() {
    final total = Decimal.tryParse(totalAmount);
    final paid = Decimal.tryParse(paidAmount);
    final pending = Decimal.tryParse(pendingBalance);
    if (total == null || paid == null || pending == null) return null;
    return VoucherSummary(
      id: id,
      workOrderId: workOrderId,
      type: VoucherType.fromApi(voucherType),
      serie: serie,
      number: number,
      totalAmount: total,
      paidAmount: paid,
      pendingBalance: pending,
      paymentStatus: VoucherPaymentStatus.fromString(paymentStatus),
      status: VoucherStatus.fromString(status),
      pdfUrl: pdfUrl,
    );
  }
}

extension SeriesConfigurationDtoMapper on SeriesConfigurationDto {
  FiscalSeries toDomain() {
    return FiscalSeries(
      id: id,
      branchId: branchId,
      type: VoucherType.fromApi(voucherType),
      serie: serie ?? '',
      currentCorrelative: currentCorrelative ?? 0,
      active: active ?? false,
    );
  }
}

extension DailyReconciliationDtoMapper on DailyReconciliationDto {
  DailyCashSummary toDomain(String requestedDate) {
    final moneyCurrency = currency == Money.usd ? Money.usd : Money.pen;
    final total = totalCollected;
    if (total == null) throw const FormatException('Falta el total de caja');
    final domainPayments = [
      for (final payment in payments) payment.toDomain(moneyCurrency),
    ];
    return DailyCashSummary(
      date: date ?? requestedDate,
      totalCollected: Money(amount: total, currency: moneyCurrency),
      paymentCount: paymentCount ?? domainPayments.length,
      byMethod: {
        for (final entry in breakdownByMethod.entries)
          if (PaymentMethod.fromString(entry.key) case final method?)
            if (entry.value case final amount?)
              method: Money(amount: amount, currency: moneyCurrency),
      },
      payments: domainPayments,
    );
  }
}

extension VoucherDraftMapper on VoucherDraft {
  IssueVoucherRequestDto toRequest(String branchId, String serie) {
    return IssueVoucherRequestDto(
      branchId: branchId,
      currency: currency,
      customerId: customerId,
      customerInfo: CustomerFiscalInfoDto(
        documentType: customerInfo.documentType?.value,
        taxId: customerInfo.taxId.trim(),
        legalName: customerInfo.legalName.trim(),
        fiscalAddress: customerInfo.fiscalAddress?.trim(),
      ),
      lines: [
        for (final line in lines)
          VoucherLineRequestDto(
            description: line.description.trim(),
            itemType: line.itemType.value,
            quantity: line.quantity,
            unitPriceWithIgv: line.unitPriceWithIgv,
            itemId: line.itemId,
          ),
      ],
      serie: serie,
      voucherType: type.code,
      workOrderId: workOrderId,
    );
  }
}
