/// `dedupe_key` de docs/06-offline-sync.md §3 y §6: un mismo hecho no se encola dos veces. La fecha
/// es de Lima.
class AttendanceDedupeKeys {
  static String clockIn(String membershipId, String date) {
    return 'CLOCK_IN:$membershipId:$date';
  }

  static String clockOut(String membershipId, String date) {
    return 'CLOCK_OUT:$membershipId:$date';
  }

  static String justification(String attendanceId) {
    return 'JUSTIFICATION:$attendanceId';
  }
}
