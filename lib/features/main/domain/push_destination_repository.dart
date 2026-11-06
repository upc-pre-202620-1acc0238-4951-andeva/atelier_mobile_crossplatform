import 'package:atelier_mobile_crossplatform/core/domain/push_destination.dart';

/// Push tocado, pendiente de abrir (docs/04-mobile-integration.md §2).
abstract class PushDestinationRepository {
  /// Repite el valor actual al suscribirse: el push pudo llegar antes de abrir la pantalla.
  Stream<PushDestination?> watchPending();

  /// Lo devuelve y lo borra, para navegar una sola vez.
  PushDestination? consume();
}
