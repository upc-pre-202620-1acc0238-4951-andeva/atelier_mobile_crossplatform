enum TaskStatus {
  pending('PENDING'),
  assigned('ASSIGNED'),
  inProgress('IN_PROGRESS'),
  onHold('ON_HOLD'),
  completed('COMPLETED'),
  cancelled('CANCELLED');

  final String value;
  const TaskStatus(this.value);

  static TaskStatus? fromString(String? raw) {
    if (raw == null) return null;
    for (final s in values) {
      if (s.value == raw) return s;
    }
    return null;
  }
}
