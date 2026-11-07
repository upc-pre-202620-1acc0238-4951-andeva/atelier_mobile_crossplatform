/// Alcances de `cache_metadata` y vigencias de 06 §4 para las cachés de recepción.
class ReceptionCachePolicy {
  static const vehiclesTtlMillis = 7 * 24 * 60 * 60 * 1000;
  static const customersTtlMillis = 7 * 24 * 60 * 60 * 1000;

  static String vehicleScope(String vehicleId) => 'vehicles:$vehicleId';

  static String customerScope(String customerId) => 'customers:$customerId';

  static String appointmentsScope(String branchId, String date) {
    return 'appointments:$branchId:$date';
  }
}
