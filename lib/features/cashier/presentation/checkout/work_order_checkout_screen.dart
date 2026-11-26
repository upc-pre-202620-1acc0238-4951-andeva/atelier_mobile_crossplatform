import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_adaptive_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_plate.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/document_intents.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/lima_time_format.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/money_format.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/state_sheet_host.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/cashier_components.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/cashier_labels.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/checkout/checkout_sheets.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/checkout/work_order_checkout_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/checkout/work_order_checkout_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/work_order_labels.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

/// "Cobrar y entregar": comprobante (US37) y cobros (US38) de una orden, con los pasos a la vista. Emitir y
/// cobrar son irreversibles: se confirman en una hoja inferior con la placa y el monto. Todo es en línea; sin red
/// las acciones se deshabilitan. Sin pase de salida ni entrega (US39).
class WorkOrderCheckoutScreen extends StatefulWidget {
  final String workOrderId;

  const WorkOrderCheckoutScreen({super.key, required this.workOrderId});

  @override
  State<WorkOrderCheckoutScreen> createState() => _WorkOrderCheckoutScreenState();
}

class _WorkOrderCheckoutScreenState extends State<WorkOrderCheckoutScreen> {
  late final WorkOrderCheckoutViewModel viewModel = getIt<WorkOrderCheckoutViewModel>(
    param1: widget.workOrderId,
  );
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
    final err = state.actionError ?? state.sheetError;
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
    final title = AppLocalizations.of(context).cashierExitPassChooser;
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
    return StateSheetHost<CheckoutSheet>(
      listenable: vm,
      value: () => vm.state.sheet,
      onDismiss: vm.onDismissSheet,
      sheetBuilder: (context, _) => ListenableBuilder(
        listenable: vm,
        builder: (context, _) => CheckoutSheetBody(state: vm.state, vm: vm),
      ),
      child: ListenableBuilder(
        listenable: vm,
        builder: (context, _) => WorkOrderCheckoutContent(
          state: vm.state,
          onBack: () => Navigator.of(context).maybePop(),
          onRefresh: vm.refresh,
          onPrepareVoucher: vm.onPrepareVoucher,
          onOpenVoid: vm.onOpenVoid,
          onOpenCreditNote: vm.onOpenCreditNote,
          onOpenVoucherPdf: vm.onOpenVoucherPdf,
          onShareVoucherPdf: vm.onShareVoucherPdf,
          onShareVoucherXml: vm.onShareVoucherXml,
          onShareVoucherCdr: vm.onShareVoucherCdr,
          onRefreshVoucherSunat: vm.onRefreshVoucherSunat,
          onOpenPayment: vm.onOpenPayment,
        ),
      ),
    );
  }
}

void _noop() {}

class WorkOrderCheckoutContent extends StatelessWidget {
  final WorkOrderCheckoutUiState state;
  final VoidCallback onBack;
  final Future<void> Function() onRefresh;
  final VoidCallback onPrepareVoucher;
  final ValueChanged<VoucherView> onOpenVoid;
  final ValueChanged<VoucherView> onOpenCreditNote;
  final ValueChanged<VoucherView> onOpenVoucherPdf;
  final ValueChanged<VoucherView> onShareVoucherPdf;
  final ValueChanged<VoucherView> onShareVoucherXml;
  final ValueChanged<VoucherView> onShareVoucherCdr;
  final ValueChanged<VoucherView> onRefreshVoucherSunat;
  final VoidCallback onOpenPayment;

  const WorkOrderCheckoutContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onRefresh,
    required this.onPrepareVoucher,
    required this.onOpenVoid,
    required this.onOpenCreditNote,
    required this.onOpenVoucherPdf,
    required this.onShareVoucherPdf,
    required this.onShareVoucherXml,
    required this.onShareVoucherCdr,
    required this.onRefreshVoucherSunat,
    this.onOpenPayment = _noop,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      body: DelayedLoading(
        loading: state.showSkeleton,
        builder: (context, showSkeleton) => RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              _CheckoutHeader(state: state, onBack: onBack),
              AtelierRefreshBar(visible: state.isRefreshing && state.hasLoaded),
              if (!state.hasAnyAccess)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AtelierNoPermissionState(text: strings.cashierCheckoutNoAccess),
                )
              else ...[
                ..._messages(strings),
                if (state.canReadInvoices || state.canIssueVoucher) _voucherStep(context, strings, showSkeleton),
                if (state.canReadInvoices || state.canRegisterPayment)
                  _paymentsStep(context, strings, showSkeleton),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _messages(AppLocalizations strings) {
    final failure =
        state.actionError ??
        (state.order != null || state.vouchers.isNotEmpty ? state.error : null);
    return [
      if (!state.isOnline)
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          child: AtelierBanner(
            message: strings.todayOfflineCache,
            icon: Icons.info_outline,
            kind: BannerKind.info,
          ),
        ),
      if (state.notice != null)
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          child: AtelierBanner(
            message: state.notice!.asString(strings),
            icon: Icons.check_circle_outline,
            kind: BannerKind.ok,
          ),
        ),
      if (failure != null)
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          child: AtelierBanner(
            message: failure.asString(strings),
            icon: Icons.error_outline,
          ),
        ),
      if (state.error != null &&
          state.order == null &&
          state.vouchers.isEmpty &&
          state.actionError == null)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: state.isOnline
              ? AtelierErrorState(
                  message: state.error!.asString(strings),
                  onRetry: onRefresh,
                )
              : AtelierOfflineState(onRetry: onRefresh),
        ),
    ];
  }

  Widget _voucherStep(BuildContext context, AppLocalizations strings, bool showSkeleton) {
    final isActive = state.activeVoucher == null;
    final activeVoucher = state.activeVoucher;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
      child: AtelierSurface(
        tier: isActive ? SurfaceTier.elevated : SurfaceTier.card,
        shape: cardLargeShape,
        contentPadding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.sm,
          children: [
            AtelierSectionHeader(
              title: strings.cashierStepTitle(1, strings.cashierStepVoucher),
              action: activeVoucher != null
                  ? () {
                      final (label, kind) = voucherStatusChip(strings, activeVoucher.status);
                      return AtelierChip(text: label, kind: kind);
                    }()
                  : null,
            ),
            if (showSkeleton) ...[
              const _VoucherSkeletonRow(),
              const _VoucherSkeletonRow(),
            ] else if (!state.showSkeleton) ...[
              if (state.hasDifferentialCascadeNote)
                AtelierBanner(
                  message: strings.cashierCheckoutH26Note,
                  icon: Icons.info_outline,
                  kind: BannerKind.info,
                ),
              if (state.hasRejectedVoucherWithoutActive)
                AtelierBanner(
                  message: strings.cashierSunatRejectedReissueHint,
                  icon: Icons.error_outline,
                  kind: BannerKind.bad,
                ),
              for (var i = 0; i < state.vouchers.length; i++) ...[
                if (i > 0) Divider(height: 1, thickness: 1, color: context.scheme.outlineVariant),
                _VoucherBlock(
                  voucher: state.vouchers[i],
                  showStatusChip:
                      state.vouchers.length > 1 || state.vouchers[i].id != activeVoucher?.id,
                  canManageVoucher: state.canIssueVoucher,
                  isOnline: state.isOnline,
                  busy: state.busy,
                  onCreditNote: () => onOpenCreditNote(state.vouchers[i]),
                  onVoid: () => onOpenVoid(state.vouchers[i]),
                  onOpenPdf: () => onOpenVoucherPdf(state.vouchers[i]),
                  onSharePdf: () => onShareVoucherPdf(state.vouchers[i]),
                  onShareXml: () => onShareVoucherXml(state.vouchers[i]),
                  onShareCdr: () => onShareVoucherCdr(state.vouchers[i]),
                  onRefreshSunat: () => onRefreshVoucherSunat(state.vouchers[i]),
                ),
              ],
              if (activeVoucher == null)
                if (state.canIssueVoucher && state.isCompleted)
                  AtelierButton(
                    text: strings.cashierVoucherPrepare,
                    onClick: onPrepareVoucher,
                    enabled:
                        state.isOnline &&
                        (state.busy == null || state.busy == CheckoutAction.preparing),
                    loading: state.busy == CheckoutAction.preparing,
                  )
                else if (state.canIssueVoucher && state.order != null)
                  Text(
                    strings.cashierVoucherNeedsCompleted,
                    style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary),
                  )
                else if (state.vouchers.isEmpty)
                  AtelierEmptyState(text: strings.cashierVoucherEmpty),
            ],
          ],
        ),
      ),
    );
  }

  /// Tarjeta de un paso: elevada si es el paso en curso.
  Widget _stepCard({required bool isActive, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
      child: AtelierSurface(
        tier: isActive ? SurfaceTier.elevated : SurfaceTier.card,
        shape: cardLargeShape,
        contentPadding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.sm,
          children: children,
        ),
      ),
    );
  }

  Widget _stepHint(BuildContext context, String text) => Text(
    text,
    style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary),
  );

  /// Botón de un paso: en línea y sin otra acción en vuelo; en carga si es la suya.
  Widget _stepAction({
    required String text,
    required VoidCallback onClick,
    required CheckoutAction action,
    AtelierButtonStyle style = AtelierButtonStyle.filled,
    bool enabled = true,
  }) {
    return AtelierButton(
      text: text,
      onClick: onClick,
      style: style,
      enabled: enabled && state.isOnline && (state.busy == null || state.busy == action),
      loading: state.busy == action,
    );
  }

  /// Paso 2 (US38): cobrado, saldo, historial de abonos y "Registrar cobro" hasta saldar el comprobante.
  Widget _paymentsStep(BuildContext context, AppLocalizations strings, bool showSkeleton) {
    final voucher = state.activeVoucher;
    final isActive = voucher != null && !state.isOrderPaid;
    return _stepCard(
      isActive: isActive,
      children: [
        AtelierSectionHeader(
          title: strings.cashierStepTitle(2, strings.cashierStepPayments),
          action: voucher != null
              ? () {
                  final (label, kind) = voucherPaymentStatusChip(strings, voucher.paymentStatus);
                  return AtelierChip(text: label, kind: kind);
                }()
              : null,
        ),
        if (voucher == null) ...[
          if (!showSkeleton && !state.showSkeleton) _stepHint(context, strings.cashierPaymentsNeedsVoucher),
        ] else ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
          if (state.payments.isEmpty)
            _stepHint(context, strings.cashierPaymentsEmpty)
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < state.payments.length; i++)
                  _PaymentRow(
                    payment: state.payments[i],
                    currency: voucher.currency,
                    showDivider: i < state.payments.length - 1,
                  ),
              ],
            ),
          if (state.canRegisterPayment && voucher.pending > Decimal.zero)
            _stepAction(
              text: strings.cashierPaymentRegister,
              onClick: onOpenPayment,
              action: CheckoutAction.paying,
            ),
        ],
      ],
    );
  }
}

/// Un abono del historial: medio, hora de Lima y referencia; monto a la derecha.
class _PaymentRow extends StatelessWidget {
  final Payment payment;
  final String? currency;
  final bool showDivider;

  const _PaymentRow({required this.payment, required this.currency, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final paidAt = payment.paidAt;
    final reference = payment.transactionReference?.trim();
    final subtitle = [
      if (paidAt != null) formatLimaStamp(paidAt),
      if (reference != null && reference.isNotEmpty) reference,
    ].join(' · ');
    final amountCurrency = payment.amount.currency.trim().isEmpty ? currency : payment.amount.currency;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
          child: Row(
            spacing: 12,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      paymentMethodLabel(strings, payment.method),
                      style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary),
                      ),
                  ],
                ),
              ),
              Text(
                formatCashierAmount(payment.amount.amount, amountCurrency),
                style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
              ),
            ],
          ),
        ),
        if (showDivider) Divider(height: 1, thickness: 1, color: context.scheme.outlineVariant),
      ],
    );
  }
}

class _CheckoutHeader extends StatelessWidget {
  final WorkOrderCheckoutUiState state;
  final VoidCallback onBack;

  const _CheckoutHeader({required this.state, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final order = state.order;
    final titleContext = strings.cashierCheckoutTitle;
    final detailParts = [
      if (order?.internalNumber != null) strings.cashierOrderNumber(order!.internalNumber!),
      if (order?.customerName != null) order!.customerName!,
    ];
    final detail = detailParts.join(' · ');
    final subtitleParts = [
      if (order?.totalAmount != null) titleContext,
      if (detail.isNotEmpty) detail,
    ];
    return AtelierFichaPanel(
      onBack: onBack,
      title: order?.totalAmount?.format() ?? titleContext,
      subtitle: subtitleParts.isEmpty ? null : subtitleParts.join(' · '),
      identity: order?.plate != null ? AtelierPlate(plate: order!.plate!, size: PlateSize.l) : null,
      status: order != null
          ? AtelierChip(
              text: workOrderStatusLabel(strings, order.status),
              kind: workOrderStatusChipKind(order.status),
            )
          : null,
    );
  }
}

class _VoucherSkeletonRow extends StatelessWidget {
  const _VoucherSkeletonRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Bone(
            loading: true,
            widthFraction: 0.65,
            child: Text('Boleta B001-00000001', style: context.text.titleMedium),
          ),
          Bone(
            loading: true,
            widthFraction: 0.4,
            child: Text('Total S/ 0.00', style: context.text.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _VoucherBlock extends StatelessWidget {
  final VoucherView voucher;
  final bool showStatusChip;
  final bool canManageVoucher;
  final bool isOnline;
  final CheckoutAction? busy;
  final VoidCallback onCreditNote;
  final VoidCallback onVoid;
  final VoidCallback onOpenPdf;
  final VoidCallback onSharePdf;
  final VoidCallback onShareXml;
  final VoidCallback onShareCdr;
  final VoidCallback onRefreshSunat;

  const _VoucherBlock({
    required this.voucher,
    required this.showStatusChip,
    required this.canManageVoucher,
    required this.isOnline,
    required this.busy,
    required this.onCreditNote,
    required this.onVoid,
    required this.onOpenPdf,
    required this.onSharePdf,
    required this.onShareXml,
    required this.onShareCdr,
    required this.onRefreshSunat,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final name = strings.cashierVoucherName(
      voucherTypeLabel(strings, voucher.type),
      formatVoucherCode(voucher.serie, voucher.number),
    );
    final (statusLabel, statusKind) = voucherStatusChip(strings, voucher.status);
    final hasSunatInfo =
        (voucher.sunatResponseCode?.trim().isNotEmpty ?? false) ||
        (voucher.sunatDescription?.trim().isNotEmpty ?? false);
    final hasPdf = voucher.pdfUrl != null && voucher.pdfUrl!.trim().isNotEmpty;
    final hasXml = voucher.xmlUrl != null && voucher.xmlUrl!.trim().isNotEmpty;
    final hasCdr = voucher.cdrUrl != null && voucher.cdrUrl!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.xs,
      children: [
        Row(
          spacing: Spacing.sm,
          children: [
            Expanded(
              child: Text(
                name,
                style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
              ),
            ),
            if (showStatusChip) AtelierChip(text: statusLabel, kind: statusKind),
          ],
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
            style: context.text.bodySmall?.copyWith(color: context.atelier.inkSecondary),
          ),
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
        if (hasPdf)
          Padding(
            padding: const EdgeInsets.only(top: Spacing.xs),
            child: AtelierAdaptiveRow(
              equalWidthInRow: true,
              children: [
                AtelierButton(
                  text: strings.cashierDocOpenPdf,
                  onClick: onOpenPdf,
                  style: AtelierButtonStyle.tonal,
                  enabled: isOnline && busy == null,
                  loading: busy == CheckoutAction.downloadingDocument,
                ),
                AtelierButton(
                  text: strings.cashierDocSharePdf,
                  onClick: onSharePdf,
                  style: AtelierButtonStyle.outlined,
                  enabled: isOnline && busy == null,
                ),
              ],
            ),
          ),
        if (hasXml || hasCdr)
          Padding(
            padding: const EdgeInsets.only(top: Spacing.xs),
            child: AtelierAdaptiveRow(
              equalWidthInRow: true,
              children: [
                if (hasXml)
                  AtelierButton(
                    text: strings.cashierDocShareXml,
                    onClick: onShareXml,
                    style: AtelierButtonStyle.outlined,
                    enabled: isOnline && busy == null,
                  ),
                if (hasCdr)
                  AtelierButton(
                    text: strings.cashierDocShareCdr,
                    onClick: onShareCdr,
                    style: AtelierButtonStyle.outlined,
                    enabled: isOnline && busy == null,
                  ),
              ],
            ),
          ),
        if (voucher.status == VoucherStatus.issued)
          Padding(
            padding: const EdgeInsets.only(top: Spacing.xs),
            child: AtelierButton(
              text: strings.cashierSunatRefreshStatus,
              onClick: onRefreshSunat,
              style: AtelierButtonStyle.tonal,
              enabled: isOnline && busy == null,
              loading: busy == CheckoutAction.refreshingSunat,
            ),
          ),
        if (canManageVoucher && voucher.canVoidOrCreditNote)
          Padding(
            padding: const EdgeInsets.only(top: Spacing.xs),
            child: AtelierAdaptiveRow(
              equalWidthInRow: true,
              children: [
                AtelierButton(
                  text: strings.cashierNcShort,
                  onClick: onCreditNote,
                  style: AtelierButtonStyle.outlined,
                  enabled: isOnline && busy == null,
                  loading: busy == CheckoutAction.issuingCreditNote,
                ),
                AtelierButton(
                  text: strings.cashierVoidShort,
                  onClick: onVoid,
                  style: AtelierButtonStyle.destructive,
                  enabled: isOnline && busy == null,
                  loading: busy == CheckoutAction.voiding,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
