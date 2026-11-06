class Plan {
  final String tier;
  final String status;
  final bool accessGranted;
  final bool iotTelemetryEnabled;
  final bool aiDiagnosticsEnabled;

  const Plan({
    required this.tier,
    required this.status,
    required this.accessGranted,
    required this.iotTelemetryEnabled,
    required this.aiDiagnosticsEnabled,
  });
}
