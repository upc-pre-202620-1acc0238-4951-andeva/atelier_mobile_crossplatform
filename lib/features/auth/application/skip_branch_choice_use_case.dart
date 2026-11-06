import 'package:atelier_mobile_crossplatform/features/auth/domain/branch_choice_repository.dart';

class SkipBranchChoiceUseCase {
  final BranchChoiceRepository repository;

  const SkipBranchChoiceUseCase({required this.repository});

  Future<void> execute() => repository.skipBranchChoice();
}
