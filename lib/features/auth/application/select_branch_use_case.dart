import 'package:atelier_mobile_crossplatform/features/auth/domain/branch_choice_repository.dart';

class SelectBranchUseCase {
  final BranchChoiceRepository repository;

  const SelectBranchUseCase({required this.repository});

  Future<void> execute(String branchId) => repository.selectBranch(branchId);
}
