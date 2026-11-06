enum EvidenceKind {
  disassembly('Desmontaje'),
  assembly('Montaje');

  final String label;
  const EvidenceKind(this.label);

  String describe(String? note) {
    final trimmed = note?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return '$label: $trimmed';
    }
    return label;
  }
}
