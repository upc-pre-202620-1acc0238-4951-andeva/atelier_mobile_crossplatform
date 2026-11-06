import 'package:decimal/decimal.dart';

class LaborTime {
  static const secondsPerHour = 3600;

  static int effectiveSeconds(
    DateTime startedAt,
    int totalPausedSeconds,
    DateTime now,
  ) {
    final diff = now.difference(startedAt).inSeconds;
    final worked = diff - totalPausedSeconds;
    return worked < 0 ? 0 : worked;
  }

  /// Dos decimales con HALF_UP, en enteros: con `double`, 3618 s daría 1.00 en vez de 1.01.
  static Decimal suggestedHours(
    DateTime startedAt,
    int totalPausedSeconds,
    DateTime now,
  ) {
    final worked = effectiveSeconds(startedAt, totalPausedSeconds, now);
    final hundredths = (worked * 100 + secondsPerHour ~/ 2) ~/ secondsPerHour;
    return Decimal.fromInt(hundredths).shift(-2);
  }
}
