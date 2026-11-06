class TaskValidation {
  static const notesMax = 1000;
  static const missingItemMax = 500;
  static const evidenceDescriptionMax = 500;

  static bool isLaborHours(double value) => value >= 0;

  static bool isNotes(String? value) =>
      value == null || value.trim().length <= notesMax;

  static bool isMissingItem(String value) =>
      value.trim().isNotEmpty && value.trim().length <= missingItemMax;

  static bool isEvidenceDescription(String value) =>
      value.length <= evidenceDescriptionMax;

  static bool isQuantity(double value) => value > 0;
}
