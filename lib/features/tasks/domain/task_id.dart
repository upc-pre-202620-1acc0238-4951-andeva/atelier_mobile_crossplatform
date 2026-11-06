extension type const TaskId(String value) {
  bool get isValid => value.trim().isNotEmpty;
}
