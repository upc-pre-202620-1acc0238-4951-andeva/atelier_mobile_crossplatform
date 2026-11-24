import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_navigation_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_plate.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_segmented_control.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/predictive_alert.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/diagnostics_ui_formatters.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/hub/diagnostics_hub_ui_state.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Pestaña "Alertas": alertas predictivas del taller o del vehículo en revisión.
class AlertsTabContent extends StatelessWidget {
  final DiagnosticsHubUiState state;
  final ValueChanged<AlertsScope> onSetAlertsScope;
  final Future<void> Function() onRefreshAlerts;
  final ValueChanged<String> onAcknowledgeAlert;
  final ValueChanged<PredictiveAlert> onOpenConvertAlert;

  const AlertsTabContent({
    super.key,
    required this.state,
    required this.onSetAlertsScope,
    required this.onRefreshAlerts,
    required this.onAcknowledgeAlert,
    required this.onOpenConvertAlert,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final alerts = state.visibleAlerts;
    final plateByVehicle = {for (final item in state.workshopVehicles) item.vehicle.id: item.vehicle.plate};
    return DelayedLoading(
      loading: state.isLoadingAlerts && alerts.isEmpty,
      builder: (context, showSkeleton) {
        final children = <Widget>[
          if (showSkeleton)
            for (var i = 0; i < 3; i++)
              const AtelierListRow(
                title: 'Riesgo de sobrecalentamiento',
                subtitle: 'Confianza: 88% · 24/10/2026',
                plate: 'BKL482',
                loading: true,
              )
          else if (alerts.isEmpty && state.error != null && !state.isOnline)
            AtelierOfflineState(onRetry: onRefreshAlerts)
          else if (alerts.isEmpty && state.error != null)
            AtelierErrorState(message: state.error!.asString(strings), onRetry: onRefreshAlerts)
          else if (alerts.isEmpty)
            AtelierEmptyState(text: strings.diagAlertsEmpty)
          else
            for (final alert in alerts)
              _AlertCard(
                alert: alert,
                plate: plateByVehicle[alert.vehicleId],
                canAcknowledge: state.canAcknowledgeAlerts && state.isOnline,
                canConvert: state.canCreateAppointment && state.isOnline,
                isBusy: state.isActingOnAlert,
                onAcknowledge: () => onAcknowledgeAlert(alert.id),
                onConvert: () => onOpenConvertAlert(alert),
              ),
        ];
        return Column(
          children: [
            if (state.selectedVehicleId != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: AtelierSegmentedControl<AlertsScope>(
                  options: const [AlertsScope.tenant, AlertsScope.vehicle],
                  selected: state.alertsScope,
                  onSelect: onSetAlertsScope,
                  label: (scope) => switch (scope) {
                    AlertsScope.tenant => strings.diagAlertsScopeTenant,
                    AlertsScope.vehicle => strings.diagAlertsScopeVehicle,
                  },
                ),
              ),
            AtelierRefreshBar(visible: state.isLoadingAlerts && alerts.isNotEmpty),
            Expanded(
              child: RefreshIndicator(
                onRefresh: onRefreshAlerts,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 24 + FloatingBarInset.of(context)),
                  itemCount: children.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, index) => children[index],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AlertCard extends StatelessWidget {
  final PredictiveAlert alert;
  final String? plate;
  final bool canAcknowledge;
  final bool canConvert;
  final bool isBusy;
  final VoidCallback onAcknowledge;
  final VoidCallback onConvert;

  const _AlertCard({
    required this.alert,
    required this.plate,
    required this.canAcknowledge,
    required this.canConvert,
    required this.isBusy,
    required this.onAcknowledge,
    required this.onConvert,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final confidencePct = (alert.confidenceScore * 100).round().clamp(0, 100);
    final createdAt = alert.createdAt;
    final meta = [
      strings.diagAlertsConfidence(confidencePct),
      if (createdAt != null) formatLimaDateTime(createdAt),
    ].join(' · ');
    final status = alert.status;
    final plate = this.plate;
    final showAck = canAcknowledge && status == PredictiveAlertStatus.dispatched;
    return AtelierSurface(
      shape: cardLargeShape,
      contentPadding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Row(
            spacing: 8,
            children: [
              if (plate != null && plate.trim().isNotEmpty) AtelierPlate(plate: plate),
              Expanded(
                child: Text(
                  predictiveAlertTypeLabel(strings, alert.alertType),
                  style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
                ),
              ),
              if (status != null)
                AtelierChip(
                  text: predictiveAlertStatusLabel(strings, status),
                  kind: predictiveAlertStatusChipKind(status),
                ),
            ],
          ),
          Text(alert.message, style: context.text.bodyMedium?.copyWith(color: context.scheme.onSurface)),
          Text(meta, style: context.text.bodySmall?.copyWith(color: context.atelier.inkSecondary)),
          if (showAck || canConvert)
            Row(
              spacing: 8,
              children: [
                if (showAck)
                  Expanded(
                    child: AtelierButton(
                      text: strings.diagAlertsAck,
                      onClick: onAcknowledge,
                      style: AtelierButtonStyle.outlined,
                      enabled: !isBusy,
                    ),
                  ),
                if (canConvert)
                  Expanded(
                    child: AtelierButton(
                      text: strings.diagAlertsConvert,
                      onClick: onConvert,
                      enabled: !isBusy,
                      icon: Icons.event_available_outlined,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
