import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_live_beacon.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_main_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_navigation_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_colors.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/lima_time_format.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/money_format.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/cashier_formats.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/cashier_labels.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/dailycash/daily_cash_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/dailycash/daily_cash_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

const _placeholderTotal = 'S/ 0.00';

/// "Caja del día": cuánto se cobró en la sede un día y por qué medio de pago. Un solo reporte en línea; no hay
/// caché de este dato, así que sin red se dice y se reintenta.
///
/// Como raíz de la pestaña "Caja" lleva la cabecera de destinos principales; empujada desde otra pantalla,
/// la barra con Atrás. [showBack] fuerza una u otra; sin él se decide según haya o no a dónde volver.
/// Sin acceso a comprobantes (US37): la tarjeta "Comprobantes SUNAT" de Android no se construye.
class DailyCashScreen extends StatefulWidget {
  final bool? showBack;

  const DailyCashScreen({super.key, this.showBack});

  @override
  State<DailyCashScreen> createState() => _DailyCashScreenState();
}

class _DailyCashScreenState extends State<DailyCashScreen> {
  late final DailyCashViewModel viewModel = getIt<DailyCashViewModel>();

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showBack = widget.showBack ?? Navigator.of(context).canPop();
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => DailyCashContent(
        state: viewModel.state,
        showBack: showBack,
        onBack: () => Navigator.of(context).maybePop(),
        onRetry: viewModel.load,
        onPreviousDay: viewModel.onPreviousDay,
        onNextDay: viewModel.onNextDay,
        onToday: viewModel.onToday,
      ),
    );
  }
}

class DailyCashContent extends StatelessWidget {
  final DailyCashUiState state;
  final bool showBack;
  final VoidCallback onBack;
  final VoidCallback onRetry;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;
  final VoidCallback onToday;

  const DailyCashContent({
    super.key,
    required this.state,
    this.showBack = true,
    required this.onBack,
    required this.onRetry,
    required this.onPreviousDay,
    required this.onNextDay,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final rawSkeleton = state.isLoading && state.summary == null;
    return Scaffold(
      body: Column(
        children: [
          if (showBack)
            AtelierTopBar(title: strings.cashierDailyTitle, onBack: onBack)
          else
            AtelierMainTopBar(title: strings.cashierDailyTitle),
          Expanded(
            child: DelayedLoading(
              loading: rawSkeleton,
              builder: (context, showSkeleton) => ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  ..._items(context, strings, rawSkeleton, showSkeleton),
                  const SizedBox.shrink().floatingBarPadding(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _items(BuildContext context, AppLocalizations strings, bool rawSkeleton, bool showSkeleton) {
    final summary = state.summary;
    const side = EdgeInsets.symmetric(horizontal: 16);
    return [
      AtelierReportPanel(
        context: strings.cashierDailyContext(formatLimaDayShortOfDate(state.date)),
        legend: summary?.totalCollected.format() ?? _placeholderTotal,
        caption: strings.cashierDailyCaption,
        loading: showSkeleton,
        figures: summary == null
            ? const []
            : [
                PanelFigure(
                  value: summary.paymentCount.toString(),
                  label: strings.cashierDailyPayments(summary.paymentCount),
                ),
              ],
      ),
      if (!state.canRead)
        Padding(
          padding: side,
          child: AtelierNoPermissionState(text: strings.cashierDailyNoAccess),
        )
      else ...[
        _DateSwitcher(state: state, onPrevious: onPreviousDay, onNext: onNextDay, onToday: onToday),
        if (showSkeleton)
          for (var i = 0; i < 3; i++) const _SkeletonRow()
        else if (rawSkeleton)
          const SizedBox.shrink()
        else if (summary == null)
          Padding(
            padding: side,
            child: state.isOnline
                ? AtelierErrorState(message: state.error?.asString(strings) ?? '', onRetry: onRetry)
                : AtelierOfflineState(onRetry: onRetry),
          )
        else if (summary.paymentCount == 0 && summary.payments.isEmpty)
          Padding(
            padding: side,
            child: AtelierEmptyState(text: strings.cashierDailyEmpty),
          )
        else ...[
          Padding(
            padding: side,
            child: AtelierSectionHeader(title: strings.cashierDailyByMethod),
          ),
          _MethodsCard(summary: summary),
          Padding(
            padding: side,
            child: AtelierSectionHeader(
              title: strings.cashierDailyPaymentsHeader,
              count: summary.payments.length,
            ),
          ),
          for (final payment in summary.payments)
            AtelierListRow(
              key: ValueKey('payment-${payment.id}'),
              title: paymentMethodLabel(strings, payment.method),
              subtitle: _paymentSubtitle(payment),
              trailing: _AmountText(payment.amount.format()),
            ),
        ],
      ],
    ];
  }
}

/// `16/11 14:35 · POS-5521`; sin fecha ni referencia, sin segunda línea.
String? _paymentSubtitle(Payment payment) {
  final reference = payment.transactionReference;
  final parts = [
    ?(payment.paidAt == null ? null : formatLimaStamp(payment.paidAt!)),
    if (reference != null && reference.trim().isNotEmpty) reference,
  ];
  final text = parts.join(' · ');
  return text.trim().isEmpty ? null : text;
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Bone(
              loading: true,
              widthFraction: 0.55,
              child: Text('Efectivo', style: context.text.titleMedium),
            ),
          ),
          const _AmountText(_placeholderTotal, loading: true),
        ],
      ),
    );
  }
}

class _AmountText extends StatelessWidget {
  final String value;
  final bool loading;

  const _AmountText(this.value, {this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Bone(
      loading: loading,
      child: Text(value, style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface)),
    );
  }
}

/// Lo cobrado por medio de pago, del mayor al menor, con su porción del total en una barra.
class _MethodsCard extends StatelessWidget {
  final DailyCashSummary summary;

  const _MethodsCard({required this.summary});

  Color _color(BuildContext context, PaymentMethod method) {
    final colors = context.atelier;
    return switch (method) {
      PaymentMethod.cash => colors.okMark,
      PaymentMethod.yape || PaymentMethod.plin => atelierBlue,
      PaymentMethod.creditCard || PaymentMethod.debitCard => atelierBlueSoft,
      PaymentMethod.bankTransfer => colors.info,
    };
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final entries = summary.byMethod.entries.toList()
      ..sort((a, b) => b.value.amount.compareTo(a.value.amount));
    final total = summary.totalCollected.amount.toDouble();
    final totalCollected = total < 0 ? 0.0 : total;
    double ratioOf(double value) => totalCollected > 0 ? (value / totalCollected).clamp(0.0, 1.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
      child: AtelierSurface(
        tier: SurfaceTier.card,
        shape: cardLargeShape,
        contentPadding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.sm,
          children: [
            for (var index = 0; index < entries.length; index++) ...[
              _MethodRow(
                label: paymentMethodLabel(strings, entries[index].key),
                amount: entries[index].value.format(),
                ratio: ratioOf(entries[index].value.amount.toDouble()),
                color: _color(context, entries[index].key),
                shareLabel: strings.premiumDailyMethodShare(
                  (ratioOf(entries[index].value.amount.toDouble()) * 100).round(),
                ),
              ),
              if (index < entries.length - 1)
                Divider(height: 1, thickness: 1, color: context.scheme.outlineVariant),
            ],
          ],
        ),
      ),
    );
  }
}

class _MethodRow extends StatelessWidget {
  final String label;
  final String amount;
  final double ratio;
  final Color color;
  final String shareLabel;

  const _MethodRow({
    required this.label,
    required this.amount,
    required this.ratio,
    required this.color,
    required this.shareLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.xs,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: context.text.titleSmall?.copyWith(color: context.scheme.onSurface),
              ),
            ),
            Row(
              spacing: Spacing.sm,
              children: [
                Text(
                  shareLabel,
                  style: context.text.labelMedium?.copyWith(color: context.atelier.inkSecondary),
                ),
                _AmountText(amount),
              ],
            ),
          ],
        ),
        AtelierMetricBar(progress: ratio, color: color, height: 6),
      ],
    );
  }
}

class _DateSwitcher extends StatelessWidget {
  final DailyCashUiState state;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  const _DateSwitcher({
    required this.state,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 12, top: 8),
      child: Row(
        spacing: 4,
        children: [
          IconButton(
            onPressed: onPrevious,
            tooltip: strings.cashierDailyPrevious,
            icon: const Icon(Icons.keyboard_arrow_left_outlined),
          ),
          Expanded(
            child: Text(
              formatLimaDayFull(state.date),
              style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
            ),
          ),
          IconButton(
            onPressed: state.canGoNext ? onNext : null,
            tooltip: strings.cashierDailyNext,
            icon: const Icon(Icons.keyboard_arrow_right_outlined),
          ),
          if (!state.isToday)
            AtelierButton(text: strings.cashierDailyToday, onClick: onToday, style: AtelierButtonStyle.text),
        ],
      ),
    );
  }
}
