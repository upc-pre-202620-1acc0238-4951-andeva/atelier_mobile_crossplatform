import 'package:atelier_mobile_crossplatform/features/auth/domain/auth_repository.dart';

class GetPendingOperationCountUseCase {
  final AuthRepository repository;

  const GetPendingOperationCountUseCase({required this.repository});

  Future<int> execute() => repository.pendingOperationCount();
}
