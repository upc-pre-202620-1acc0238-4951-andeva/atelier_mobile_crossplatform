import 'package:atelier_mobile_crossplatform/features/bays/domain/bay_board.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/bay_repository.dart';

class ObserveBayBoardUseCase {
  final BayRepository repository;

  const ObserveBayBoardUseCase({required this.repository});

  Stream<List<BayBoardItem>> execute() => repository.observeBoard();
}
