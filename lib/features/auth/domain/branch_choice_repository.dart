import 'package:atelier_mobile_crossplatform/features/auth/domain/branch_option.dart';

/// Elegir sede (A5b, H33). Solo para cuentas que entraron sin perfil laboral.
abstract class BranchChoiceRepository {
  /// `GET /branches`: sedes activas del taller. En línea.
  Future<List<BranchOption>> availableBranches();

  /// Deja la sede en la sesión. No llama al backend: el perfil laboral sigue sin sede.
  Future<void> selectBranch(String branchId);

  /// "Elegir después": se entra sin sede y no se vuelve a ofrecer.
  Future<void> skipBranchChoice();
}
