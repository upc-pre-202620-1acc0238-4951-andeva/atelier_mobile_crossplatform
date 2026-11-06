enum HoldReason {
  breakTime('BREAK'),
  endOfShift('END_OF_SHIFT'),
  defectivePart('DEFECTIVE_PART'),
  waitingParts('WAITING_PARTS'),
  waitingForParts('WAITING_FOR_PARTS');

  final String value;
  const HoldReason(this.value);

  bool get isMechanicPause =>
      this == HoldReason.breakTime || this == HoldReason.endOfShift;

  static HoldReason? fromString(String? raw) {
    if (raw == null) return null;
    for (final r in values) {
      if (r.value == raw) return r;
    }
    return null;
  }
}
