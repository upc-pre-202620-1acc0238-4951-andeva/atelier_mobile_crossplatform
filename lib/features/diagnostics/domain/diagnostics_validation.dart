/// Restricciones de docs/api/iot.md. Solo evitan una llamada inútil; el backend vuelve a validar.
abstract final class DiagnosticsValidation {
  static const minDaysToAnalyze = 7;
  static const maxDaysToAnalyze = 90;

  /// `GenerateHealthReportRequest.daysToAnalyze`: 7–90.
  static bool isDaysToAnalyze(int days) {
    return days >= minDaysToAnalyze && days <= maxDaysToAnalyze;
  }

  /// `currentOdometerKm` / `finalOdometerKm`: ≥ 0 o sin enviar.
  static bool isOdometer(int? km) => km == null || km >= 0;
}
