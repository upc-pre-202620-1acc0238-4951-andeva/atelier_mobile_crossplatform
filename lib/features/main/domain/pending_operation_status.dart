/// Estado de una operación en cola (docs/06-offline-sync.md §3). Las exitosas se borran.
enum PendingOperationStatus {
  pending('PENDING'),
  syncing('SYNCING'),
  failed('FAILED');

  final String apiName;

  const PendingOperationStatus(this.apiName);

  static PendingOperationStatus fromApi(String value) {
    return values.firstWhere(
      (status) => status.apiName == value,
      orElse: () => pending,
    );
  }
}
