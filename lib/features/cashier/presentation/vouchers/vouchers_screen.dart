import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_adaptive_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_navigation_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_segmented_control.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/document_intents.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/lima_time_format.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/money_format.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/state_sheet_host.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/cashier_components.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/cashier_labels.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/checkout/work_order_checkout_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/vouchers/vouchers_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/vouchers/vouchers_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

/// Comprobantes SUNAT emitidos en la sede: boletas, facturas y notas de crédito (US37).
class VouchersScreen extends StatefulWidget {
  const VouchersScreen({super.key});

  @override
  State<VouchersScreen> createState() => _VouchersScreenState();
}

class _VouchersScreenState extends State<VouchersScreen> {
  late final VouchersViewModel viewModel = getIt<VouchersViewModel>();
  final AtelierHaptics _haptics = rememberAtelierHaptics();
  Object? _lastNotice;
  Object? _lastError;
  PendingDocumentFile? _handlingDoc;

  @override
  void initState() {
    super.initState();
    viewModel.addListener(_onChange);
  }

  @override
  void dispose() {
    viewModel.removeListener(_onChange);
    viewModel.dispose();
    super.dispose();
  }

  void _onChange() {
    final state = viewModel.state;
    if (state.notice != null && !identical(state.notice, _lastNotice)) _haptics.confirm();
    final err = state.sheetError ?? state.error;
    if (err != null && !identical(err, _lastError)) _haptics.reject();
    _lastNotice = state.notice;
    _lastError = err;

    final doc = state.pendingDocument;
    if (doc != null && !identical(doc, _handlingDoc)) {
      _handlingDoc = doc;
      WidgetsBinding.instance.addPostFrameCallback((_) => _openDocument(doc));
    }
  }

  Future<void> _openDocument(PendingDocumentFile doc) async {
    if (!mounted) return;
    final title = AppLocalizations.of(context).cashierVouchersTitle;
    final opened = switch (doc.mode) {
      CheckoutDocumentActionMode.open => await DocumentIntents.openFile(doc.file, doc.mimeType, title),
      CheckoutDocumentActionMode.share => await DocumentIntents.shareFile(doc.file, doc.mimeType, title),
    };
    _handlingDoc = null;
    if (!mounted) return;
    if (opened) {
      viewModel.onDocumentHandled();
    } else {
      viewModel.onDocumentOpenFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    return StateSheetHost<VoucherSheet>(
      listenable: vm,
      value: () => vm.state.sheet,
      onDismiss: vm.onDismissSheet,
      sheetBuilder: (context, _) => ListenableBuilder(
        listenable: vm,
        builder: (context, _) => _VouchersSheetBody(state: vm.state, vm: vm),
      ),
      child: ListenableBuilder(
        listenable: vm,
        builder: (context, _) => VouchersContent(
          state: vm.state,
          onBack: () => Navigator.of(context).maybePop(),
          onRefresh: vm.refresh,
          onFilterChange: vm.onFilterChange,
          onOpenVoucher: vm.onOpenVoucher,
        ),
      ),
    );
  }
}

class VouchersContent extends StatelessWidget {
  final VouchersUiState state;
  final VoidCallback onBack;
  final Future<void> Function() onRefresh;
  final ValueChanged<VoucherFilter> onFilterChange;
  final ValueChanged<Voucher> onOpenVoucher;

  const VouchersContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onRefresh,
    required this.onFilterChange,
    required this.onOpenVoucher,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final visible = state.filteredVouchers;
    return Scaffold(
      body: Column(
        children: [
          AtelierTopBar(title: strings.cashierVouchersTitle, onBack: onBack),
          Expanded(
            child: DelayedLoading(
              loading: state.showSkeleton && state.canRead,
              builder: (context, showSkeleton) => RefreshIndicator(
                onRefresh: onRefresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 16 + FloatingBarInset.of(context)),
                  children: [
                    AtelierRefreshBar(visible: state.isRefreshing && state.hasLoaded),
                    if (!state.canRead)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AtelierNoPermissionState(text: strings.cashierVouchersNoAccess),
                      )
                    else ...[
                      if (!state.isOnline)
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                          child: AtelierBanner(
                            message: strings.errorRequiresConnection,
                            icon: Icons.info_outline,
                            kind: BannerKind.info,
                          ),
                        ),
                      if (state.notice != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                          child: AtelierBanner(
                            message: state.notice!.asString(strings),
                            icon: Icons.check_circle_outline,
                            kind: BannerKind.ok,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
                        child: AtelierSegmentedControl<VoucherFilter>(
                          options: VoucherFilter.values,
                          selected: state.filter,
                          onSelect: onFilterChange,
                          label: (filter) => _filterLabel(strings, filter),
                        ),
                      ),
                      if (showSkeleton)
                        for (var i = 0; i < 5; i++)
                          _VoucherRow(voucher: _placeholderVoucher, loading: true, onClick: () {})
                      else if (state.showSkeleton)
                        const SizedBox.shrink()
                      else if (state.error != null && state.vouchers.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: state.isOnline
                              ? AtelierErrorState(
                                  message: state.error!.asString(strings),
                                  onRetry: onRefresh,
                                )
                              : AtelierOfflineState(onRetry: onRefresh),
                        )
                      else if (state.vouchers.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: AtelierEmptyState(text: strings.cashierVouchersEmpty),
                        )
                      else if (visible.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: AtelierEmptyState(text: strings.cashierVouchersEmptyFiltered),
                        )
                      else
                        for (final voucher in visible)
                          _VoucherRow(
                            key: ValueKey(voucher.id),
                            voucher: voucher,
                            loading: false,
                            onClick: () => onOpenVoucher(voucher),
                          ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VoucherRow extends StatelessWidget {
  final Voucher voucher;
  final bool loading;
  final VoidCallback onClick;

  const _VoucherRow({
    super.key,
    required this.voucher,
    required this.loading,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final scheme = context.scheme;
    final colors = context.atelier;
    final stacked = MediaQuery.textScalerOf(context).scale(1) >= 1.15;
    final title = strings.cashierVoucherName(
      voucherTypeLabel(strings, voucher.type),
      formatVoucherCode(voucher.serie, voucher.number),
    );
    final balanceLabel = voucher.activeSale && voucher.pendingBalance.amount > Decimal.zero
        ? strings.cashierVouchersBalanceShort(voucher.pendingBalance.format())
        : null;
    final legalName = voucher.customerInfo?.legalName.trim();
    final parts = [
      if (legalName != null && legalName.isNotEmpty) legalName,
      if (voucher.issuedAt != null) formatLimaStamp(voucher.issuedAt!),
      ?balanceLabel,
    ];
    final subtitle = parts.isEmpty ? null : parts.join(' · ');
    final (statusLabel, statusKind) = voucherStatusChip(strings, voucher.status);
    final amountText = formatCashierAmount(
      voucher.totalAmount.amount,
      voucher.totalAmount.currency,
    );

    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 72),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          spacing: 12,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 2,
                children: [
                  Bone(
                    loading: loading,
                    widthFraction: 0.7,
                    child: Text(
                      title,
                      style: context.text.titleMedium?.copyWith(color: scheme.onSurface),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (subtitle != null || loading)
                    Bone(
                      loading: loading,
                      widthFraction: 0.55,
                      child: Text(
                        subtitle ?? 'Cliente · 24/10 09:30',
                        style: context.text.bodyMedium?.copyWith(color: colors.inkSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (stacked)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: _VoucherTrailing(
                        amountText: amountText,
                        statusText: statusLabel,
                        statusKind: statusKind,
                        loading: loading,
                        alignment: CrossAxisAlignment.start,
                      ),
                    ),
                ],
              ),
            ),
            if (!stacked)
              _VoucherTrailing(
                amountText: amountText,
                statusText: statusLabel,
                statusKind: statusKind,
                loading: loading,
                alignment: CrossAxisAlignment.end,
              ),
          ],
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        loading ? row : InkWell(onTap: onClick, child: row),
        Divider(height: 1, thickness: 1, color: scheme.outlineVariant),
      ],
    );
  }
}

class _VoucherTrailing extends StatelessWidget {
  final String amountText;
  final String statusText;
  final ChipKind statusKind;
  final bool loading;
  final CrossAxisAlignment alignment;

  const _VoucherTrailing({
    required this.amountText,
    required this.statusText,
    required this.statusKind,
    required this.loading,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      spacing: 4,
      children: [
        Bone(
          loading: loading,
          child: Text(
            amountText,
            style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
            maxLines: 1,
          ),
        ),
        if (loading)
          Bone(
            loading: true,
            child: Text('Aceptado', style: context.text.labelLarge),
          )
        else
          AtelierChip(text: statusText, kind: statusKind),
      ],
    );
  }
}

class _VouchersSheetBody extends StatelessWidget {
  final VouchersUiState state;
  final VouchersViewModel vm;

  const _VouchersSheetBody({required this.state, required this.vm});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final sheet = state.sheet;
    if (sheet == null) return const SizedBox.shrink();
    return switch (sheet) {
      VoucherDetailSheet(:final voucher) => _buildDetailSheet(context, strings, voucher),
      VoucherVoidSheet(:final voucher, :final form) => AtelierBottomSheet(
        title: strings.cashierVoidTitle(
          strings.cashierVoucherName(voucherTypeLabel(strings, voucher.type), form.voucherLabel),
        ),
        actions: [
          AtelierButton(
            text: strings.cashierVoidConfirm,
            onClick: vm.onConfirmVoid,
            style: AtelierButtonStyle.destructiveFilled,
            enabled: form.canSubmit && state.isOnline,
            loading: state.isSubmitting,
          ),
          if (!state.isOnline) const AtelierRequiresConnection(),
          AtelierButton(
            text: strings.commonCancel,
            onClick: vm.onBackToDetail,
            style: AtelierButtonStyle.text,
            enabled: !state.isSubmitting,
          ),
        ],
        content: [
          VoidSheetContent(
            form: form,
            onReasonChange: vm.onVoidReason,
            error: state.sheetError?.asString(strings),
          ),
        ],
      ),
      VoucherCreditNoteSheet(:final form) => AtelierBottomSheet(
        title: strings.cashierNcTitle,
        actions: [
          AtelierButton(
            text: strings.cashierNcConfirm(
              formatCashierAmount(form.parsedAmount ?? Decimal.zero, form.currency),
            ),
            onClick: vm.onConfirmCreditNote,
            enabled: form.canSubmit && state.isOnline,
            loading: state.isSubmitting,
          ),
          if (!state.isOnline) const AtelierRequiresConnection(),
          AtelierButton(
            text: strings.commonCancel,
            onClick: vm.onBackToDetail,
            style: AtelierButtonStyle.text,
            enabled: !state.isSubmitting,
          ),
        ],
        content: [
          CreditNoteSheetContent(
            form: form,
            onReasonChange: vm.onCreditNoteReason,
            onAmountChange: vm.onCreditNoteAmount,
            onSerieChange: vm.onCreditNoteSerie,
            error: state.sheetError?.asString(strings),
          ),
        ],
      ),
    };
  }

  Widget _buildDetailSheet(BuildContext context, AppLocalizations strings, Voucher voucher) {
    final code = formatVoucherCode(voucher.serie, voucher.number);
    final title = strings.cashierVoucherName(voucherTypeLabel(strings, voucher.type), code);
    final hasPdf = voucher.pdfUrl != null && voucher.pdfUrl!.trim().isNotEmpty;
    final hasXml = voucher.xmlUrl != null && voucher.xmlUrl!.trim().isNotEmpty;
    final hasCdr = voucher.cdrUrl != null && voucher.cdrUrl!.trim().isNotEmpty;

    return AtelierBottomSheet(
      title: title,
      actions: [
        if (hasPdf)
          AtelierAdaptiveRow(
            equalWidthInRow: true,
            children: [
              AtelierButton(
                text: strings.cashierDocOpenPdf,
                onClick: vm.onOpenPdf,
                style: AtelierButtonStyle.tonal,
                enabled: state.isOnline && !state.isDownloadingDocument,
                loading: state.isDownloadingDocument,
              ),
              AtelierButton(
                text: strings.cashierDocSharePdf,
                onClick: vm.onSharePdf,
                style: AtelierButtonStyle.outlined,
                enabled: state.isOnline && !state.isDownloadingDocument,
              ),
            ],
          ),
        if (hasXml || hasCdr)
          AtelierAdaptiveRow(
            equalWidthInRow: true,
            children: [
              if (hasXml)
                AtelierButton(
                  text: strings.cashierDocShareXml,
                  onClick: vm.onShareXml,
                  style: AtelierButtonStyle.outlined,
                  enabled: state.isOnline && !state.isDownloadingDocument,
                ),
              if (hasCdr)
                AtelierButton(
                  text: strings.cashierDocShareCdr,
                  onClick: vm.onShareCdr,
                  style: AtelierButtonStyle.outlined,
                  enabled: state.isOnline && !state.isDownloadingDocument,
                ),
            ],
          ),
        if (voucher.status == VoucherStatus.issued)
          AtelierButton(
            text: strings.cashierSunatRefreshStatus,
            onClick: vm.onRefreshSunat,
            style: AtelierButtonStyle.tonal,
            enabled: state.isOnline && !state.isRefreshingSunat,
            loading: state.isRefreshingSunat,
          ),
        if (state.canIssueSunat && voucher.canIssueActions) ...[
          AtelierButton(
            text: strings.cashierNcAction,
            onClick: vm.onStartCreditNote,
            style: AtelierButtonStyle.tonal,
            enabled: state.isOnline,
          ),
          AtelierButton(
            text: strings.cashierVoidAction,
            onClick: vm.onStartVoid,
            style: AtelierButtonStyle.destructive,
            enabled: state.isOnline,
          ),
        ],
        if (!state.isOnline) const AtelierRequiresConnection(),
        AtelierButton(
          text: strings.cashierVouchersClose,
          onClick: vm.onDismissSheet,
          style: AtelierButtonStyle.text,
        ),
      ],
      content: [
        VoucherDetailSheetContent(
          voucher: voucher,
          canIssueSunat: state.canIssueSunat,
          error: state.sheetError?.asString(strings),
        ),
      ],
    );
  }
}

class VoucherDetailSheetContent extends StatelessWidget {
  final Voucher voucher;
  final bool canIssueSunat;
  final String? error;

  const VoucherDetailSheetContent({
    super.key,
    required this.voucher,
    required this.canIssueSunat,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final (statusLabel, statusKind) = voucherStatusChip(strings, voucher.status);
    final (paymentLabel, paymentKind) = voucherPaymentStatusChip(strings, voucher.paymentStatus);
    final currency = voucher.totalAmount.currency;
    final hasSunatInfo =
        (voucher.sunatResponseCode?.trim().isNotEmpty ?? false) ||
        (voucher.sunatDescription?.trim().isNotEmpty ?? false);
    final customer = voucher.customerInfo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            AtelierChip(text: statusLabel, kind: statusKind),
            if (voucher.activeSale) AtelierChip(text: paymentLabel, kind: paymentKind),
          ],
        ),
        if (voucher.issuedAt != null)
          Text(
            strings.cashierVouchersIssuedAt(formatLimaStamp(voucher.issuedAt!)),
            style: context.text.bodyMedium?.copyWith(color: colors.inkSecondary),
          ),
        if (hasSunatInfo)
          Text(
            strings.cashierVouchersCdrCode(
              (voucher.sunatResponseCode?.trim().isNotEmpty ?? false)
                  ? voucher.sunatResponseCode!
                  : '—',
              (voucher.sunatDescription?.trim().isNotEmpty ?? false)
                  ? voucher.sunatDescription!
                  : statusLabel,
            ),
            style: context.text.bodyMedium?.copyWith(color: colors.inkSecondary),
          ),
        if (customer != null) ...[
          Text(
            strings.cashierVouchersCustomerLabel,
            style: context.text.titleSmall?.copyWith(color: colors.inkSecondary),
          ),
          Text(
            customer.legalName.trim().isEmpty ? '—' : customer.legalName,
            style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
          ),
          if (customer.taxId.trim().isNotEmpty)
            Text(
              [
                if (customer.documentType != null)
                  fiscalDocumentTypeLabel(strings, customer.documentType),
                customer.taxId,
              ].join(' '),
              style: context.text.bodyMedium?.copyWith(color: colors.inkSecondary),
            ),
          if (customer.fiscalAddress != null && customer.fiscalAddress!.trim().isNotEmpty)
            Text(
              customer.fiscalAddress!,
              style: context.text.bodyMedium?.copyWith(color: colors.inkSecondary),
            ),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AmountRow(
              label: strings.cashierSubtotal,
              value: formatCashierAmount(voucher.subtotal.amount, currency),
            ),
            AmountRow(
              label: strings.cashierIgv(18),
              value: formatCashierAmount(voucher.igvAmount.amount, currency),
            ),
            AmountRow(
              label: strings.cashierTotal,
              value: formatCashierAmount(voucher.totalAmount.amount, currency),
              emphasized: true,
            ),
            if (voucher.activeSale) ...[
              AmountRow(
                label: strings.cashierCollected,
                value: formatCashierAmount(voucher.paidAmount.amount, currency),
              ),
              AmountRow(
                label: strings.cashierBalance,
                value: formatCashierAmount(voucher.pendingBalance.amount, currency),
                emphasized: true,
              ),
            ],
          ],
        ),
        if (voucher.lines.isNotEmpty) ...[
          Text(
            strings.cashierVouchersLinesLabel,
            style: context.text.titleSmall?.copyWith(color: colors.inkSecondary),
          ),
          for (final line in voucher.lines)
            AmountRow(
              label: strings.cashierIssueLineDetail(
                line.description,
                line.quantity.toString(),
              ),
              value: formatCashierAmount(
                line.totalLine ?? line.unitPrice ?? Decimal.zero,
                currency,
              ),
            ),
        ],
        if (canIssueSunat && !voucher.canIssueActions)
          Text(
            strings.cashierVouchersNoActions,
            style: context.text.bodyMedium?.copyWith(color: colors.inkSecondary),
          ),
        if (error != null)
          AtelierBanner(message: error!, icon: Icons.info_outline, kind: BannerKind.bad),
      ],
    );
  }
}

String _filterLabel(AppLocalizations strings, VoucherFilter filter) => switch (filter) {
  VoucherFilter.all => strings.cashierVouchersFilterAll,
  VoucherFilter.accepted => strings.cashierVouchersFilterAccepted,
  VoucherFilter.withBalance => strings.cashierVouchersFilterBalance,
  VoucherFilter.voided => strings.cashierVouchersFilterVoided,
  VoucherFilter.creditNotes => strings.cashierVouchersFilterCreditNotes,
};

final _placeholderVoucher = Voucher(
  id: 'placeholder',
  type: VoucherType.factura,
  serie: 'F001',
  number: 1,
  subtotal: Money(amount: Decimal.zero, currency: Money.pen),
  igvAmount: Money(amount: Decimal.zero, currency: Money.pen),
  totalAmount: Money(amount: Decimal.zero, currency: Money.pen),
  paidAmount: Money(amount: Decimal.zero, currency: Money.pen),
  pendingBalance: Money(amount: Decimal.zero, currency: Money.pen),
  status: VoucherStatus.acceptedSunat,
);
