enum AttendanceStatus {
  onTime('ON_TIME'),
  late('LATE'),
  excused('EXCUSED'),
  absent('ABSENT');

  final String apiName;

  const AttendanceStatus(this.apiName);

  /// `null` si el backend envía un estado nuevo.
  static AttendanceStatus? fromApi(String? value) {
    for (final status in values) {
      if (status.apiName == value) return status;
    }
    return null;
  }
}
