import 'package:atelier_mobile_crossplatform/core/domain/notification_record.dart';
import 'package:atelier_mobile_crossplatform/core/domain/push_destination.dart';

/// Push tocado, pendiente de abrir (docs/04-mobile-integration.md §2), e historial en memoria de
/// los avisos recibidos en la sesión.
abstract class PushDestinationRepository {
  /// Repite el valor actual al suscribirse: el push pudo llegar antes de abrir la pantalla.
  Stream<PushDestination?> watchPending();

  /// Lo devuelve y lo borra, para navegar una sola vez.
  PushDestination? consume();

  /// Avisos recibidos, del más reciente al más antiguo. Repite el valor actual al suscribirse.
  Stream<List<NotificationRecord>> watchHistory();

  /// Marca como leído el aviso [id] y deja su destino pendiente de abrir (si lo tiene).
  void open(String id);

  void markAllRead();
}
