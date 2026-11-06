import 'package:atelier_mobile_crossplatform/features/auth/domain/branch_choice_repository.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/branch_option.dart';

class GetSelectableBranchesUseCase {
  final BranchChoiceRepository repository;

  const GetSelectableBranchesUseCase({required this.repository});

  Future<List<BranchOption>> execute() => repository.availableBranches();
}
