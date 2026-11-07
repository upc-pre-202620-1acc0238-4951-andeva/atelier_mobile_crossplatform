/// `dedupe_key` de la cola de diagnóstico (06 §3 y §6).
abstract final class DiagnosticsDedupeKeys {
  static const resolveFaultPrefix = 'RESOLVE_FAULT:';

  /// Un mismo código no se encola dos veces por sesión de diagnóstico.
  static String registerFault(
    String vehicleId,
    String dtcCode,
    String sessionId,
  ) {
    return 'FAULT:$vehicleId:$dtcCode:$sessionId';
  }

  static String resolveFault(String faultId) => '$resolveFaultPrefix$faultId';

  /// El mismo tramo de lecturas no forma dos lotes.
  static String telemetryBatch(String vehicleId, int first, int last) {
    return 'TELEMETRY:$vehicleId:$first:$last';
  }
}
