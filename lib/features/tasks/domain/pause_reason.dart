enum PauseReason {
  breakTime('BREAK'),
  endOfShift('END_OF_SHIFT');

  final String value;
  const PauseReason(this.value);
}
