import 'package:atelier_mobile_crossplatform/features/bays/domain/work_bay.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/bay_board.dart';

/// Tablero de bahías (US40). Se lee de la caché `bays:{branchId}`, compartida con `tasks`; reasignar
/// es en línea (06 §2).
abstract class BayRepository {
  /// Sin sesión lanza `StateError`; sin sede, `MissingBranchException`.
  Future<void> refreshBranchBays();

  /// Emite enseguida desde la caché y completa mecánicos y tiempo cuando llega el detalle de cada
  /// orden. Sin sede emite una lista vacía.
  Stream<List<BayBoardItem>> observeBoard();

  /// 409 con el `message` si otra orden la ocupó antes (US40 E2).
  Future<void> reassignBay(String workOrderId, String bayId);

  /// `operations:bays:manage`. La bahía se crea en la sede de la sesión. En línea.
  Future<void> createBay(String name, BayType type);

  /// `operations:bays:manage`. En línea.
  Future<void> setMaintenance(String bayId, String reason);

  /// `operations:bays:manage`: devuelve la bahía a `AVAILABLE`. En línea.
  Future<void> restoreBay(String bayId);

  /// `operations:bays:reassign`: la orden se queda sin bahía. En línea.
  Future<void> releaseBay(String workOrderId);

  /// Con `operations:bays:read`: sin él, el tablero no se sondea.
  Future<bool> canReadBoard();

  /// [mechanicId] es el membershipId (H11).
  Future<void> reassignMechanic(String taskId, String mechanicId);
}
