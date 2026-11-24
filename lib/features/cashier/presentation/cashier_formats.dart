// Fechas de Lima en es-PE para "Caja del día" (los mismos `DateTimeFormatter` de Android). Sin `intl`.
const _weekdaysFull = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
const _monthsFull = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'setiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

/// Día de Lima `yyyy-MM-dd` como `EEEE d 'de' MMMM`: `lunes 16 de noviembre`. Vacío si no se puede leer.
String formatLimaDayFull(String date) {
  final parsed = DateTime.tryParse('${date}T00:00:00Z');
  if (parsed == null) return '';
  return '${_weekdaysFull[parsed.weekday - 1]} ${parsed.day} de ${_monthsFull[parsed.month - 1]}';
}
