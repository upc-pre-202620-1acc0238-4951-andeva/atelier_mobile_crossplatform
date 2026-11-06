/// Zona del negocio (docs/api/README.md §6): los cortes de "hoy" se calculan en Lima
/// (UTC−5, sin horario de verano), no en la zona del teléfono.
class BusinessTime {
  static const limaOffset = Duration(hours: -5);

  final DateTime Function() now;

  const BusinessTime({this.now = DateTime.now});

  /// Fecha de Lima `yyyy-MM-dd` de un instante.
  static String limaDate(DateTime instant) {
    return instant.toUtc().add(limaOffset).toIso8601String().substring(0, 10);
  }

  /// Inicio del día de Lima (`yyyy-MM-dd`) como instante UTC.
  static DateTime startOfDay(String date) {
    return DateTime.parse('${date}T00:00:00Z').subtract(limaOffset);
  }

  String today() => limaDate(now());
}
