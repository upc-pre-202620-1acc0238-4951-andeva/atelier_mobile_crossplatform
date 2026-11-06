import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/main/domain/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  final SessionManager session;

  const SessionRepositoryImpl({required this.session});

  @override
  Stream<Session?> watchSession() => session.watchSession();
}
