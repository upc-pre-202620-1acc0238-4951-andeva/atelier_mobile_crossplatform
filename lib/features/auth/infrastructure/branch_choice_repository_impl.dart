import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/branch/branch_api.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/branch_choice_repository.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/branch_option.dart';

class BranchChoiceRepositoryImpl implements BranchChoiceRepository {
  final BranchApi api;
  final SessionManager session;

  const BranchChoiceRepositoryImpl({required this.api, required this.session});

  @override
  Future<List<BranchOption>> availableBranches() async {
    final branches = await api.getAll();
    final options = [
      for (final branch in branches)
        if (branch.isActive != false && (branch.name?.trim() ?? '').isNotEmpty)
          BranchOption(
            id: branch.id,
            name: branch.name!.trim(),
            geofenceRadiusMeters: branch.geofenceRadiusMeters,
          ),
    ];
    options.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return options;
  }

  @override
  Future<void> selectBranch(String branchId) => session.selectBranch(branchId);

  @override
  Future<void> skipBranchChoice() => session.dismissBranchChoice();
}
