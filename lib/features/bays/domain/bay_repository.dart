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

  /// Con `operations:bays:read`: sin él, el tablero no se sondea.
  Future<bool> canReadBoard();

  /// [mechanicId] es el membershipId (H11).
  Future<void> reassignMechanic(String taskId, String mechanicId);
}
