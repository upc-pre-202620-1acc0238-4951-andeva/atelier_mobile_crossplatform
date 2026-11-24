import 'dart:math' as math;

import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_density.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_live_beacon.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_plate.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/money_format.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/state_sheet_host.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/health_report.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/diagnostics_ui_formatters.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/report/ai_health_report_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/report/ai_health_report_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

const _analysisDayOptions = [7, 15, 30, 60, 90];

/// Informe de salud vehicular con IA (US21). La descarga y el envío del PDF (US43) no se portan.
class AiHealthReportScreen extends StatefulWidget {
  final VehicleArgs args;

  const AiHealthReportScreen({super.key, required this.args});

  @override
  State<AiHealthReportScreen> createState() => _AiHealthReportScreenState();
}

class _AiHealthReportScreenState extends State<AiHealthReportScreen> {
  late final AiHealthReportViewModel viewModel = getIt<AiHealthReportViewModel>(param1: widget.args);
  final AtelierHaptics _haptics = rememberAtelierHaptics();

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StateSheetHost<bool>(
      listenable: viewModel,
      value: () => viewModel.state.generateSheetOpen ? true : null,
      onDismiss: viewModel.dismissGenerateSheet,
      sheetBuilder: (context, _) => GenerateReportSheet(
        state: viewModel.state,
        onSelectDays: viewModel.selectDays,
        onToggleResolvedDtc: viewModel.toggleIncludeResolvedDtcHistory,
        onConfirm: () {
          _haptics.confirm();
          viewModel.confirmGenerate();
        },
        onCancel: viewModel.dismissGenerateSheet,
      ),
      child: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => AiHealthReportContent(
          state: viewModel.state,
          onBack: () => Navigator.of(context).maybePop(),
          onRefresh: viewModel.loadLatest,
          onOpenGenerate: viewModel.openGenerateSheet,
        ),
      ),
    );
  }
}

class AiHealthReportContent extends StatelessWidget {
  final AiHealthReportUiState state;
  final VoidCallback onBack;
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenGenerate;

  const AiHealthReportContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onRefresh,
    required this.onOpenGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final subtitle = _subtitleFor(strings);
    final vehicle = state.vehicle;
    final vehicleTitle = vehicle == null ? '' : '${vehicle.brand} ${vehicle.model}'.trim();
    final condition = state.detail?.diagnosis?.overallCondition;
    final showBottomBar = state.planIncludesAi && state.canGenerate;
    return AtelierMinTouchTarget(
      value: AtelierMinTouchTarget.floor,
      child: Scaffold(
        bottomNavigationBar: showBottomBar ? _BottomBar(state: state, onOpenGenerate: onOpenGenerate) : null,
        body: Column(
          children: [
            AtelierFichaPanel(
              onBack: onBack,
              title: vehicleTitle.isEmpty ? strings.diagReportTitle : vehicleTitle,
              subtitle: subtitle,
              identity: state.displayPlate.trim().isNotEmpty
                  ? AtelierPlate(plate: state.displayPlate, size: PlateSize.l)
                  : null,
              status: condition == null ? null : AtelierChip(text: condition, kind: conditionChipKind(condition)),
            ),
            Expanded(child: _body(context, strings)),
          ],
        ),
      ),
    );
  }

  String? _subtitleFor(AppLocalizations strings) {
    final detail = state.detail;
    if (detail != null) {
      final generated = detail.generatedAt;
      final date = generated == null ? '' : formatLimaDateTime(generated);
      final days = detail.daysAnalyzed;
      final text = days != null ? strings.diagReportDaysAnalyzed(days, date) : (date.trim().isEmpty ? null : date);
      if (text != null) return text;
    }
    final generated = state.latestSummary?.generatedAt;
    return generated == null ? null : formatLimaDateTime(generated);
  }

  Widget _body(BuildContext context, AppLocalizations strings) {
    if (!state.planIncludesAi) {
      return _padded(AtelierPlanLockedState(text: strings.diagReportPlanLocked));
    }
    if (!state.canRead && !state.canGenerate) {
      return _padded(AtelierNoPermissionState(text: strings.diagReportNoPermission));
    }
    final hasReport = state.hasReport;
    final error = state.error;
    final diagnosis = state.detail?.diagnosis;
    return DelayedLoading(
      loading: state.isLoading && state.latestSummary == null,
      builder: (context, showSkeleton) {
        final items = <Widget>[
          if (error != null && hasReport) AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
          if (showSkeleton)
            const _ScoreCard(score: 84, summary: 'Motor operando en rango normal.', loading: true)
          else if (!hasReport && error != null && !state.isOnline)
            AtelierOfflineState(onRetry: onRefresh)
          else if (!hasReport && error != null)
            AtelierErrorState(message: error.asString(strings), onRetry: onRefresh)
          else if (!hasReport)
            AtelierEmptyState(
              text: strings.diagReportEmpty,
              actionLabel: state.canGenerate && state.isOnline ? strings.diagReportGenerate : null,
              onAction: state.canGenerate && state.isOnline ? onOpenGenerate : null,
            )
          else ...[
            _ScoreCard(score: state.effectiveScore, summary: state.effectiveSummary, loading: false),
            if (diagnosis != null) ...[
              if (diagnosis.subsystemEvaluations.isNotEmpty) ...[
                AtelierSectionHeader(
                  title: strings.diagReportSubsystemsSection,
                  count: diagnosis.subsystemEvaluations.length,
                ),
                for (final sub in diagnosis.subsystemEvaluations) _SubsystemCard(sub: sub),
              ],
              if (diagnosis.predictiveRisks.isNotEmpty) ...[
                AtelierSectionHeader(
                  title: strings.diagReportRisksSection,
                  count: diagnosis.predictiveRisks.length,
                ),
                for (final risk in diagnosis.predictiveRisks) _RiskCard(risk: risk),
              ],
              if (diagnosis.recommendedActions.isNotEmpty) ...[
                AtelierSectionHeader(
                  title: strings.diagReportActionsSection,
                  count: diagnosis.recommendedActions.length,
                ),
                for (final action in diagnosis.recommendedActions) _RecommendedActionCard(action: action),
              ],
              if (diagnosis.dtcCorrelations.isNotEmpty) ...[
                AtelierSectionHeader(
                  title: strings.diagReportCorrelationsSection,
                  count: diagnosis.dtcCorrelations.length,
                ),
                for (final correlation in diagnosis.dtcCorrelations) _CorrelationCard(correlation: correlation),
              ],
            ],
          ],
        ];
        return Column(
          children: [
            AtelierRefreshBar(visible: state.isLoading && hasReport),
            Expanded(
              child: RefreshIndicator(
                onRefresh: onRefresh,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (_, index) => items[index],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _padded(Widget child) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: child);
}

class _BottomBar extends StatelessWidget {
  final AiHealthReportUiState state;
  final VoidCallback onOpenGenerate;

  const _BottomBar({required this.state, required this.onOpenGenerate});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Material(
      color: context.scheme.surface,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Divider(color: context.scheme.outlineVariant, height: 1),
            if (!state.isOnline)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: AtelierRequiresConnection(),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: AtelierButton(
                text: strings.diagReportGenerate,
                onClick: onOpenGenerate,
                enabled: state.isOnline && !state.isGenerating,
                loading: state.isGenerating,
                icon: Icons.auto_awesome_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hoja para elegir la ventana de análisis y generar el informe.
class GenerateReportSheet extends StatelessWidget {
  final AiHealthReportUiState state;
  final ValueChanged<int> onSelectDays;
  final VoidCallback onToggleResolvedDtc;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const GenerateReportSheet({
    super.key,
    required this.state,
    required this.onSelectDays,
    required this.onToggleResolvedDtc,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final error = state.error;
    return AtelierBottomSheet(
      title: strings.diagReportGenerateSheetTitle,
      actions: [
        if (!state.isOnline) const AtelierRequiresConnection(),
        AtelierButton(
          text: state.isGenerating ? strings.diagReportGenerating : strings.diagReportGenerate,
          onClick: onConfirm,
          enabled: state.isOnline && !state.isGenerating,
          loading: state.isGenerating,
          icon: Icons.auto_awesome_outlined,
        ),
        AtelierButton(
          text: strings.commonCancel,
          onClick: onCancel,
          style: AtelierButtonStyle.text,
          enabled: !state.isGenerating,
        ),
      ],
      content: [
        Text(
          strings.diagReportDaysLabel,
          style: context.text.titleSmall?.copyWith(color: context.atelier.inkSecondary),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final days in _analysisDayOptions)
              FilterChip(
                selected: state.daysToAnalyze == days,
                onSelected: state.isGenerating ? null : (_) => onSelectDays(days),
                shape: const RoundedRectangleBorder(borderRadius: chipRadius),
                label: Text(strings.diagReportDaysOption(days)),
                showCheckmark: true,
              ),
          ],
        ),
        Row(
          spacing: 8,
          children: [
            Checkbox(
              value: state.includeResolvedDtcHistory,
              onChanged: state.isGenerating ? null : (_) => onToggleResolvedDtc(),
            ),
            Expanded(
              child: Text(
                strings.diagReportIncludeResolved,
                style: context.text.bodyLarge?.copyWith(color: context.scheme.onSurface),
              ),
            ),
          ],
        ),
        if (error != null) AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final int? score;
  final String? summary;
  final bool loading;

  const _ScoreCard({required this.score, required this.summary, required this.loading});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final summary = this.summary;
    return AtelierSurface(
      tier: SurfaceTier.elevated,
      shape: heroShape,
      contentPadding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Text(strings.diagReportScoreLabel, style: context.text.labelLarge?.copyWith(color: colors.inkSecondary)),
          Center(child: HealthScoreArc(score: score, loading: loading)),
          if (summary != null && summary.trim().isNotEmpty) ...[
            Divider(color: context.scheme.outlineVariant, height: 1),
            Text(
              strings.diagReportSummarySection,
              style: context.text.titleSmall?.copyWith(color: colors.inkSecondary),
            ),
            Bone(
              loading: loading,
              widthFraction: 0.9,
              child: Text(summary, style: context.text.bodyLarge?.copyWith(color: context.scheme.onSurface)),
            ),
          ],
        ],
      ),
    );
  }
}

/// Arco radial del puntaje de salud (sin neón): trazo redondeado, marcas calibradas en el perímetro, color
/// semántico por umbral (verde ≥ 80, ámbar ≥ 55, rojo) y cifra grande al centro.
class HealthScoreArc extends StatefulWidget {
  final int? score;
  final bool loading;

  const HealthScoreArc({super.key, required this.score, required this.loading});

  @override
  State<HealthScoreArc> createState() => _HealthScoreArcState();
}

class _HealthScoreArcState extends State<HealthScoreArc> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController.unbounded(vsync: this, value: _target);

  double get _target => widget.loading ? 0 : (widget.score?.clamp(0, 100) ?? 0) / 100;

  @override
  void didUpdateWidget(HealthScoreArc oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = _target;
    if (target == _controller.value) return;
    if (rememberReducedMotion(context)) {
      _controller.value = target;
    } else {
      _controller.animateWith(
        SpringSimulation(AtelierSprings.criticallyDamped(), _controller.value, target, _controller.velocity),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final clamped = widget.score?.clamp(0, 100);
    final arcColor = clamped == null
        ? colors.inkSecondary
        : clamped >= 80
        ? colors.okMark
        : clamped >= 55
        ? colors.warnMark
        : colors.badMark;
    final textColor = clamped == null
        ? context.scheme.onSurface
        : clamped >= 80
        ? colors.ok
        : clamped >= 55
        ? colors.warn
        : colors.bad;
    final description = clamped == null ? strings.diagReportScoreLabel : strings.pitReportScoreCd(clamped);
    return Semantics(
      container: true,
      label: description,
      excludeSemantics: true,
      child: SizedBox(
        width: 168,
        height: 168,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  painter: _ScoreArcPainter(
                    fraction: _controller.value.clamp(0.0, 1.0),
                    arcColor: arcColor,
                    trackColor: colors.surfaceRecessed,
                    tickColor: colors.inkSecondary.withValues(alpha: 0.30),
                  ),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 2,
              children: [
                Bone(
                  loading: widget.loading,
                  widthFraction: 0.4,
                  child: Text(
                    clamped?.toString() ?? '—',
                    style: context.text.displaySmall?.copyWith(color: textColor),
                  ),
                ),
                if (!widget.loading)
                  Text(
                    strings.pitReportScoreMax,
                    style: context.text.labelLarge?.copyWith(color: colors.inkSecondary),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreArcPainter extends CustomPainter {
  final double fraction;
  final Color arcColor;
  final Color trackColor;
  final Color tickColor;

  const _ScoreArcPainter({
    required this.fraction,
    required this.arcColor,
    required this.trackColor,
    required this.tickColor,
  });

  static const _startDegrees = 150.0;
  static const _sweepDegrees = 240.0;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 12.0;
    const inset = stroke / 2 + 10;
    final diameter = math.max(math.min(size.width, size.height) - inset * 2, 1.0);
    final rect = Rect.fromLTWH((size.width - diameter) / 2, (size.height - diameter) / 2, diameter, diameter);
    final startRad = _startDegrees * math.pi / 180;
    final sweepRad = _sweepDegrees * math.pi / 180;

    // Marcas de calibración discretas en el perímetro exterior (0, 25, 50, 75, 100 %).
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = math.min(size.width, size.height) / 2 - 2;
    final innerR = outerR - 4;
    final tickPaint = Paint()
      ..color = tickColor
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (var step = 0; step <= 4; step++) {
      final angle = startRad + (sweepRad / 4) * step;
      final dx = math.cos(angle);
      final dy = math.sin(angle);
      canvas.drawLine(
        Offset(center.dx + innerR * dx, center.dy + innerR * dy),
        Offset(center.dx + outerR * dx, center.dy + outerR * dy),
        tickPaint,
      );
    }

    Paint arcPaint(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startRad, sweepRad, false, arcPaint(trackColor));
    if (fraction > 0) {
      canvas.drawArc(rect, startRad, sweepRad * fraction, false, arcPaint(arcColor));
    }
  }

  @override
  bool shouldRepaint(_ScoreArcPainter old) =>
      old.fraction != fraction ||
      old.arcColor != arcColor ||
      old.trackColor != trackColor ||
      old.tickColor != tickColor;
}

class _SubsystemCard extends StatelessWidget {
  final SubsystemEvaluation sub;

  const _SubsystemCard({required this.sub});

  @override
  Widget build(BuildContext context) {
    final colors = context.atelier;
    final score = sub.score;
    final status = sub.status;
    final findings = sub.findings;
    return AtelierSurface(
      shape: cardLargeShape,
      contentPadding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
        children: [
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: Text(
                  sub.subsystemName ?? '',
                  style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
                ),
              ),
              if (score != null)
                Text('$score/100', style: context.text.titleMedium?.copyWith(color: colors.primaryText)),
              if (status != null) AtelierChip(text: status, kind: conditionChipKind(status)),
            ],
          ),
          if (score != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: AtelierMetricBar(
                progress: (score / 100).clamp(0.0, 1.0),
                color: score >= 80
                    ? colors.okMark
                    : score >= 55
                    ? colors.warnMark
                    : colors.badMark,
              ),
            ),
          if (findings != null && findings.trim().isNotEmpty)
            Text(findings, style: context.text.bodyMedium?.copyWith(color: colors.inkSecondary)),
        ],
      ),
    );
  }
}

class _RiskCard extends StatelessWidget {
  final PredictiveRisk risk;

  const _RiskCard({required this.risk});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final probability = risk.probability;
    final probabilityPct = probability == null ? null : (probability * 100).round().clamp(0, 100);
    final horizon = risk.timeHorizonDays;
    final consequences = risk.consequences;
    return AtelierSurface(
      shape: cardLargeShape,
      contentPadding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
        children: [
          Text(
            risk.category ?? '',
            style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
          ),
          if (probabilityPct != null && horizon != null)
            Text(
              strings.diagReportRiskDetail(probabilityPct, horizon),
              style: context.text.labelLarge?.copyWith(color: context.atelier.warn),
            ),
          if (consequences != null && consequences.trim().isNotEmpty)
            Text(consequences, style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary)),
        ],
      ),
    );
  }
}

class _RecommendedActionCard extends StatelessWidget {
  final RecommendedServiceAction action;

  const _RecommendedActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    final urgency = action.urgency;
    final cost = action.estimatedCost;
    final rationale = action.rationale;
    return AtelierSurface(
      shape: cardLargeShape,
      contentPadding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
        children: [
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: Text(
                  action.serviceName ?? action.serviceCode ?? '',
                  style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
                ),
              ),
              if (urgency != null) AtelierChip(text: urgency, kind: conditionChipKind(urgency)),
            ],
          ),
          if (cost != null)
            Text(
              Money(amount: cost < Decimal.zero ? Decimal.zero : cost, currency: Money.pen).format(),
              style: context.text.labelLarge?.copyWith(color: context.atelier.primaryText),
            ),
          if (rationale != null && rationale.trim().isNotEmpty)
            Text(rationale, style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary)),
        ],
      ),
    );
  }
}

class _CorrelationCard extends StatelessWidget {
  final DtcCorrelation correlation;

  const _CorrelationCard({required this.correlation});

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      ?correlation.correlatedSensorReading,
      ?correlation.anomalyExplanation,
    ].where((part) => part.trim().isNotEmpty).join(' · ');
    return AtelierListRow(title: correlation.dtcCode ?? '', subtitle: subtitle);
  }
}

/// El estado del informe, la urgencia o la condición general en un color de chip.
ChipKind conditionChipKind(String raw) {
  final upper = raw.toUpperCase();
  bool any(List<String> words) => words.any(upper.contains);
  if (any(['CRITICAL', 'HIGH', 'BAD', 'POOR', 'CRITIC'])) return ChipKind.bad;
  if (any(['MODERATE', 'WARN', 'MEDIUM', 'FAIR'])) return ChipKind.warn;
  if (any(['LOW', 'GOOD', 'OPTIMAL', 'HEALTHY', 'NORMAL'])) return ChipKind.ok;
  return ChipKind.info;
}
