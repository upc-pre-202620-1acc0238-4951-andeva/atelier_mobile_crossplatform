enum JustificationStatus {
  pending('PENDING'),
  approved('APPROVED'),
  rejected('REJECTED');

  final String apiName;

  const JustificationStatus(this.apiName);

  /// `null` sin descargo o si el backend envía un estado nuevo.
  static JustificationStatus? fromApi(String? value) {
    for (final status in values) {
      if (status.apiName == value) return status;
    }
    return null;
  }
}
