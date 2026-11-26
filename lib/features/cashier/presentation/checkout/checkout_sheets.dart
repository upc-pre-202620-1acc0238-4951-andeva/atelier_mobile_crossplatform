import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_plate.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/cashier_components.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/cashier_labels.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/checkout/work_order_checkout_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/checkout/work_order_checkout_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

/// Hojas de confirmación de "Cobrar y entregar": Emitir, Anular y Nota de Crédito (US37) y Registrar cobro
/// (US38). Emitir y cobrar son irreversibles: llevan la placa a la vista.
class CheckoutSheetBody extends StatelessWidget {
  final WorkOrderCheckoutUiState state;
  final WorkOrderCheckoutViewModel vm;

  const CheckoutSheetBody({super.key, required this.state, required this.vm});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final sheet = state.sheet;
    if (sheet == null) return const SizedBox.shrink();

    return switch (sheet) {
      IssueCheckoutSheet(:final form) => AtelierBottomSheet(
        title: strings.cashierIssueTitle,
        actions: _sheetActions(
          strings: strings,
          confirm: strings.cashierIssueConfirm(
            voucherTypeLabel(strings, form.type),
            formatCashierAmount(form.total, form.base.currency),
          ),
          enabled: form.canSubmit && state.isOnline,
          loading: state.busy == CheckoutAction.issuing,
          online: state.isOnline,
          onConfirm: vm.onConfirmIssue,
          onCancel: vm.onDismissSheet,
        ),
        content: [
          IssueSheetContent(
            order: state.order,
            form: form,
            error: state.sheetError?.asString(strings),
            onIssueType: vm.onIssueType,
            onIssueDocumentType: vm.onIssueDocumentType,
            onIssueTaxId: vm.onIssueTaxId,
            onIssueName: vm.onIssueName,
            onIssueAddress: vm.onIssueAddress,
            onIssueLineName: vm.onIssueLineName,
          ),
        ],
      ),
      PaymentCheckoutSheet(:final form) => AtelierBottomSheet(
        title: strings.cashierPaymentTitle,
        actions: _sheetActions(
          strings: strings,
          confirm: strings.cashierPaymentConfirm(
            formatCashierAmount(form.parsedAmount ?? Decimal.zero, form.voucher.currency),
          ),
          enabled: form.canSubmit && state.isOnline,
          loading: state.busy == CheckoutAction.paying,
          online: state.isOnline,
          onConfirm: vm.onConfirmPayment,
          onCancel: vm.onDismissSheet,
        ),
        content: [
          PaymentSheetContent(
            order: state.order,
            form: form,
            error: state.sheetError?.asString(strings),
            onPaymentAmount: vm.onPaymentAmount,
            onPaymentMethod: vm.onPaymentMethod,
            onPaymentReference: vm.onPaymentReference,
          ),
        ],
      ),
      VoidCheckoutSheet(:final voucher, :final form) => AtelierBottomSheet(
        title: strings.cashierVoidTitle(
          strings.cashierVoucherName(voucherTypeLabel(strings, voucher.type), form.voucherLabel),
        ),
        actions: [
          AtelierButton(
            text: strings.cashierVoidConfirm,
            onClick: vm.onConfirmVoid,
            style: AtelierButtonStyle.destructiveFilled,
            enabled: form.canSubmit && state.isOnline,
            loading: state.busy == CheckoutAction.voiding,
          ),
          if (!state.isOnline) const AtelierRequiresConnection(),
          AtelierButton(
            text: strings.commonCancel,
            onClick: vm.onDismissSheet,
            style: AtelierButtonStyle.text,
            enabled: state.busy == null,
          ),
        ],
        content: [
          _OrderIdentity(order: state.order),
          VoidSheetContent(
            form: form,
            onReasonChange: vm.onVoidReason,
            error: state.sheetError?.asString(strings),
          ),
        ],
      ),
      CreditNoteCheckoutSheet(:final form) => AtelierBottomSheet(
        title: strings.cashierNcTitle,
        actions: _sheetActions(
          strings: strings,
          confirm: strings.cashierNcConfirm(
            formatCashierAmount(form.parsedAmount ?? Decimal.zero, form.currency),
          ),
          enabled: form.canSubmit && state.isOnline,
          loading: state.busy == CheckoutAction.issuingCreditNote,
          online: state.isOnline,
          onConfirm: vm.onConfirmCreditNote,
          onCancel: vm.onDismissSheet,
        ),
        content: [
          _OrderIdentity(order: state.order),
          CreditNoteSheetContent(
            form: form,
            onReasonChange: vm.onCreditNoteReason,
            onAmountChange: vm.onCreditNoteAmount,
            error: state.sheetError?.asString(strings),
          ),
        ],
      ),
    };
  }

  List<Widget> _sheetActions({
    required AppLocalizations strings,
    required String confirm,
    required bool enabled,
    required bool loading,
    required bool online,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
  }) => [
    AtelierButton(text: confirm, onClick: onConfirm, enabled: enabled, loading: loading),
    if (!online) const AtelierRequiresConnection(),
    AtelierButton(
      text: strings.commonCancel,
      onClick: onCancel,
      style: AtelierButtonStyle.text,
      enabled: !loading,
    ),
  ];
}

class _OrderIdentity extends StatelessWidget {
  final WorkOrder? order;

  const _OrderIdentity({required this.order});

  @override
  Widget build(BuildContext context) {
    final current = order;
    if (current == null) return const SizedBox.shrink();
    return Row(
      spacing: 12,
      children: [
        if (current.plate != null) AtelierPlate(plate: current.plate!, size: PlateSize.l),
        if (current.customerName != null)
          Expanded(
            child: Text(
              current.customerName!,
              style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
            ),
          ),
      ],
    );
  }
}

class IssueSheetContent extends StatelessWidget {
  final WorkOrder? order;
  final IssueForm form;
  final String? error;
  final ValueChanged<VoucherType> onIssueType;
  final ValueChanged<FiscalDocumentType> onIssueDocumentType;
  final ValueChanged<String> onIssueTaxId;
  final ValueChanged<String> onIssueName;
  final ValueChanged<String> onIssueAddress;
  final void Function(int index, String value) onIssueLineName;

  const IssueSheetContent({
    super.key,
    required this.order,
    required this.form,
    this.error,
    required this.onIssueType,
    required this.onIssueDocumentType,
    required this.onIssueTaxId,
    required this.onIssueName,
    required this.onIssueAddress,
    required this.onIssueLineName,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final taxError = form.taxId.isNotEmpty && !form.taxIdValid;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        _OrderIdentity(order: order),
        Text(
          strings.cashierIssueType,
          style: context.text.titleSmall?.copyWith(color: colors.inkSecondary),
        ),
        ChoiceGrid<VoucherType>(
          options: const [VoucherType.boleta, VoucherType.factura],
          selected: form.type,
          label: (t) => voucherTypeLabel(strings, t),
          onSelect: onIssueType,
          columns: 2,
        ),
        if (!form.isCompany) ...[
          Text(
            strings.cashierIssueDocument,
            style: context.text.titleSmall?.copyWith(color: colors.inkSecondary),
          ),
          ChoiceGrid<FiscalDocumentType>(
            options: const [
              FiscalDocumentType.dni,
              FiscalDocumentType.ce,
              FiscalDocumentType.pasaporte,
            ],
            selected: form.documentType,
            label: (d) => fiscalDocumentTypeLabel(strings, d),
            onSelect: onIssueDocumentType,
          ),
        ],
        AtelierTextField(
          label: strings.cashierIssueDocumentNumber,
          value: form.taxId,
          onValueChange: onIssueTaxId,
          isError: taxError,
          errorText: taxError ? strings.cashierIssueDocumentError : null,
          keyboardType:
              form.documentType == FiscalDocumentType.pasaporte ||
                  form.documentType == FiscalDocumentType.ce
              ? TextInputType.text
              : TextInputType.number,
        ),
        AtelierTextField(
          label: form.isCompany ? strings.cashierIssueNameCompany : strings.cashierIssueNamePerson,
          value: form.legalName,
          onValueChange: onIssueName,
          isError: !form.nameValid,
          errorText: !form.nameValid ? strings.cashierIssueNameError : null,
        ),
        if (form.isCompany)
          AtelierTextField(
            label: strings.cashierIssueAddress,
            value: form.address,
            onValueChange: onIssueAddress,
          ),
        Text(
          strings.cashierIssueLines,
          style: context.text.titleSmall?.copyWith(color: colors.inkSecondary),
        ),
        for (var i = 0; i < form.lines.length; i++) ...[
          if (form.lines[i].needsDescription)
            AtelierTextField(
              label: strings.cashierIssueLineName,
              value: form.lines[i].description,
              onValueChange: (val) => onIssueLineName(i, val),
              placeholder: strings.cashierIssueLineNeedsName,
            ),
          AmountRow(
            label: form.lines[i].needsDescription
                ? strings.cashierIssueLineDetail(form.lines[i].quantity.toString(), '').trim()
                : strings.cashierIssueLineDetail(
                    form.lines[i].description,
                    form.lines[i].quantity.toString(),
                  ),
            value: formatCashierAmount(
              form.lines[i].quantity * form.lines[i].unitPriceWithIgv,
              form.base.currency,
            ),
          ),
        ],
        AmountRow(
          label: strings.cashierSubtotal,
          value: formatCashierAmount(form.subtotal, form.base.currency),
        ),
        AmountRow(
          label: strings.cashierIgv(18),
          value: formatCashierAmount(form.igv, form.base.currency),
        ),
        AmountRow(
          label: strings.cashierTotal,
          value: formatCashierAmount(form.total, form.base.currency),
          emphasized: true,
        ),
        Text(
          strings.cashierIssueIrreversible,
          style: context.text.bodyMedium?.copyWith(color: colors.inkSecondary),
        ),
        if (error != null) AtelierBanner(message: error!, icon: Icons.error_outline),
      ],
    );
  }
}

/// Registrar un cobro total o parcial (US38): resumen del comprobante, monto (sugerido el saldo), medio de pago y
/// código de operación cuando no es efectivo.
class PaymentSheetContent extends StatelessWidget {
  final WorkOrder? order;
  final PaymentForm form;
  final String? error;
  final ValueChanged<String> onPaymentAmount;
  final ValueChanged<PaymentMethod> onPaymentMethod;
  final ValueChanged<String> onPaymentReference;

  const PaymentSheetContent({
    super.key,
    required this.order,
    required this.form,
    this.error,
    required this.onPaymentAmount,
    required this.onPaymentMethod,
    required this.onPaymentReference,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final voucher = form.voucher;
    final amountInvalid = form.amount.trim().isNotEmpty && form.parsedAmount == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        _OrderIdentity(order: order),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (voucher.subtotal != null && voucher.igv != null) ...[
              AmountRow(
                label: strings.cashierSubtotal,
                value: formatCashierAmount(voucher.subtotal!, voucher.currency),
              ),
              AmountRow(
                label: strings.cashierIgv(18),
                value: formatCashierAmount(voucher.igv!, voucher.currency),
              ),
            ],
            AmountRow(
              label: strings.cashierTotal,
              value: formatCashierAmount(voucher.total, voucher.currency),
              emphasized: true,
            ),
            AmountRow(
              label: strings.cashierCollected,
              value: formatCashierAmount(voucher.paid, voucher.currency),
            ),
            AmountRow(
              label: strings.cashierBalance,
              value: formatCashierAmount(voucher.pending, voucher.currency),
              emphasized: true,
            ),
          ],
        ),
        AtelierTextField(
          label: strings.cashierPaymentAmount,
          value: form.amount,
          onValueChange: onPaymentAmount,
          isError: amountInvalid,
          errorText: amountInvalid ? strings.cashierPaymentAmountError : null,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        Text(
          strings.cashierPaymentMethod,
          style: context.text.titleSmall?.copyWith(color: colors.inkSecondary),
        ),
        ChoiceGrid<PaymentMethod>(
          options: PaymentMethod.values,
          selected: form.method,
          label: (m) => paymentMethodLabel(strings, m),
          onSelect: onPaymentMethod,
          columns: 2,
        ),
        if (form.requiresReference) ...[
          AtelierTextField(
            label: strings.cashierPaymentReference,
            value: form.reference,
            onValueChange: onPaymentReference,
            placeholder: strings.cashierPaymentReferenceHint,
          ),
          if (form.reference.trim().isEmpty)
            Text(
              strings.cashierPaymentReferenceRequired,
              style: context.text.labelSmall?.copyWith(color: colors.inkSecondary),
            ),
        ],
        Text(
          strings.cashierPaymentIrreversible,
          style: context.text.bodyMedium?.copyWith(color: colors.inkSecondary),
        ),
        if (error != null) AtelierBanner(message: error!, icon: Icons.error_outline),
      ],
    );
  }
}
