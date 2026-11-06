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

  static double suggestedHours(
    DateTime startedAt,
    int totalPausedSeconds,
    DateTime now,
  ) {
    final worked = effectiveSeconds(startedAt, totalPausedSeconds, now);
    final hours = worked / secondsPerHour;
    return (hours * 100).roundToDouble() / 100;
  }
}
