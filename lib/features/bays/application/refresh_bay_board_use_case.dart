import 'package:atelier_mobile_crossplatform/features/bays/domain/bay_repository.dart';

class RefreshBayBoardUseCase {
  final BayRepository repository;

  const RefreshBayBoardUseCase({required this.repository});

  Future<void> execute() => repository.refreshBranchBays();
}
