import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/generate_health_report_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/get_health_report_detail_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/get_latest_health_report_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/health_report.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/diagnostics_ui_formatters.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/report/ai_health_report_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/observe_vehicle_use_case.dart';
import 'package:flutter/foundation.dart';

class AiHealthReportViewModel extends ChangeNotifier {
  final ObserveSessionUseCase observeSession;
  final ObserveVehicleUseCase observeVehicle;
  final ConnectivityObserver connectivity;
  final GetLatestHealthReportUseCase getLatestHealthReport;
  final GetHealthReportDetailUseCase getHealthReportDetail;
  final GenerateHealthReportUseCase generateHealthReport;
  final String vehicleId;

  AiHealthReportViewModel({
    required this.observeSession,
    required this.observeVehicle,
    required this.connectivity,
    required this.getLatestHealthReport,
    required this.getHealthReportDetail,
    required this.generateHealthReport,
    required this.vehicleId,
    String? plate,
  }) : _state = AiHealthReportUiState(vehicleId: vehicleId, plate: plate, isOnline: connectivity.isOnline) {
    _subscriptions.add(
      observeSession.execute().listen((session) {
        final planAi = session?.plan?.aiDiagnosticsEnabled ?? true;
        final canGen = session?.canUseAiDiagnostics() ?? false;
        final canRd =
            (session?.canReadAiReports() ?? false) ||
            ((session?.has(Permission.healthReportsRead) ?? false) && planAi);
        _update(_state.copyWith(planIncludesAi: planAi, canGenerate: canGen, canRead: canRd));
        if (planAi && canRd && _state.latestSummary == null && !_state.isLoading) {
          loadLatest();
        }
      }),
    );
    if (vehicleId.trim().isNotEmpty) {
      _subscriptions.add(
        observeVehicle.execute(vehicleId).listen((vehicle) {
          if (vehicle != null) _update(_state.copyWith(vehicle: vehicle));
        }),
      );
    }
    connectivity.addListener(_onConnectivity);
  }

  AiHealthReportUiState _state;
  AiHealthReportUiState get state => _state;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  bool _disposed = false;

  void _onConnectivity() => _update(_state.copyWith(isOnline: connectivity.isOnline));

  void _update(AiHealthReportUiState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  Future<void> loadLatest() async {
    final state = _state;
    if (!state.planIncludesAi || !state.canRead || vehicleId.trim().isEmpty || state.isLoading) return;
    _update(_state.copyWith(isLoading: true, clearError: true));
    try {
      final latest = await getLatestHealthReport.execute(vehicleId);
      if (latest == null) {
        _update(_state.copyWith(isLoading: false, clearLatestSummary: true, clearDetail: true));
      } else {
        final detail = await _detailOrNull(latest.reportId);
        _update(
          _state.copyWith(
            isLoading: false,
            latestSummary: latest,
            detail: detail,
            clearDetail: detail == null,
          ),
        );
      }
    } on Object catch (e) {
      _update(_state.copyWith(isLoading: false, error: toDiagnosticsUiText(e)));
    }
  }

  Future<HealthReportDetail?> _detailOrNull(String reportId) async {
    try {
      return await getHealthReportDetail.execute(reportId);
    } on Object {
      return null;
    }
  }

  void openGenerateSheet() {
    final state = _state;
    if (!state.planIncludesAi || !state.canGenerate || state.isGenerating) return;
    _update(_state.copyWith(generateSheetOpen: true, clearError: true));
  }

  void dismissGenerateSheet() {
    if (_state.isGenerating) return;
    _update(_state.copyWith(generateSheetOpen: false));
  }

  void selectDays(int days) => _update(_state.copyWith(daysToAnalyze: days));

  void toggleIncludeResolvedDtcHistory() {
    _update(_state.copyWith(includeResolvedDtcHistory: !_state.includeResolvedDtcHistory));
  }

  Future<void> confirmGenerate() async {
    final state = _state;
    if (!state.planIncludesAi ||
        !state.canGenerate ||
        !state.isOnline ||
        state.isGenerating ||
        vehicleId.trim().isEmpty) {
      return;
    }
    _update(_state.copyWith(isGenerating: true, clearError: true));
    try {
      final report = await generateHealthReport.execute(
        vehicleId,
        daysToAnalyze: state.daysToAnalyze,
        includeResolvedDtcHistory: state.includeResolvedDtcHistory,
      );
      final detail = await _detailOrNull(report.reportId);
      _update(
        _state.copyWith(
          isGenerating: false,
          generateSheetOpen: false,
          latestSummary: report,
          detail: detail,
          clearDetail: detail == null,
        ),
      );
    } on Object catch (e) {
      _update(_state.copyWith(isGenerating: false, error: toDiagnosticsUiText(e)));
    }
  }

  @override
  void dispose() {
    _disposed = true;
    connectivity.removeListener(_onConnectivity);
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}
