extension type const WorkOrderId(String value) {
  bool get isValid => value.trim().isNotEmpty;
}
