import 'package:atelier_mobile_crossplatform/features/main/domain/push_destination_repository.dart';

/// Marca el aviso como leído y reabre su destino por la misma vía que un push tocado.
class OpenPushNotificationUseCase {
  final PushDestinationRepository repository;

  const OpenPushNotificationUseCase({required this.repository});

  void execute(String id) => repository.open(id);
}
