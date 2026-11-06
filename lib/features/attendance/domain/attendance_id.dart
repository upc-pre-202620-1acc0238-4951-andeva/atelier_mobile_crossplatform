extension type AttendanceId._(String value) {
  factory AttendanceId(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError('AttendanceId must not be blank');
    }
    return AttendanceId._(value);
  }
}
