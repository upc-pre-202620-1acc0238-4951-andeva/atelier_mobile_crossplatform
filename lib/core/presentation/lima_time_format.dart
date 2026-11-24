import 'package:atelier_mobile_crossplatform/core/domain/business_time.dart';

// Abreviaturas de es-PE (los mismos `DateTimeFormatter` de Android). Sin `intl`: no exige inicializar
// los datos de localización y los formatos son fijos.
const _weekdays = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
const _months = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'set',
  'oct',
  'nov',
  'dic',
];

DateTime _lima(DateTime instant) => instant.toUtc().add(BusinessTime.limaOffset);

String _two(int value) => value.toString().padLeft(2, '0');

/// Hora de Lima `HH:mm`.
String formatLimaTime(DateTime instant) {
  final lima = _lima(instant);
  return '${_two(lima.hour)}:${_two(lima.minute)}';
}

/// `EEE d MMM` en es-PE: `lun 16 nov`.
String formatLimaDayShort(DateTime instant) => _dayShort(_lima(instant));

/// Día de Lima `yyyy-MM-dd` (el que da `BusinessTime.limaDate`) como `EEE d MMM`. Vacío si no se puede leer.
String formatLimaDayShortOfDate(String date) {
  final parsed = DateTime.tryParse('${date}T00:00:00Z');
  return parsed == null ? '' : _dayShort(parsed);
}

/// `EEE d MMM · HH:mm` en es-PE: `lun 16 nov · 08:04`.
String formatLimaDayTime(DateTime instant) {
  final lima = _lima(instant);
  return '${_dayShort(lima)} · ${_two(lima.hour)}:${_two(lima.minute)}';
}

/// `dd/MM HH:mm`: `16/11 08:02`.
String formatLimaStamp(DateTime instant) {
  final lima = _lima(instant);
  return '${_two(lima.day)}/${_two(lima.month)} ${_two(lima.hour)}:${_two(lima.minute)}';
}

/// `HH:mm:ss` o `HH:mm` del backend recortado a `HH:mm`.
String hourMinute(String time) => time.length >= 5 ? time.substring(0, 5) : time;

String _dayShort(DateTime lima) =>
    '${_weekdays[lima.weekday - 1]} ${lima.day} ${_months[lima.month - 1]}';
