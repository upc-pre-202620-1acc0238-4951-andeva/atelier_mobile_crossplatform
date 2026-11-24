import 'package:atelier_mobile_crossplatform/core/domain/push_destination.dart';

/// Aviso push recibido en la sesión (historial en memoria de la pantalla de notificaciones).
class NotificationRecord {
  final String id;

  /// `null` si el push no trajo título: la pantalla pone uno según [destination].
  final String? title;
  final String body;
  final PushDestination? destination;
  final PushChannel channel;
  final DateTime receivedAt;
  final bool read;

  const NotificationRecord({
    required this.id,
    required this.title,
    required this.body,
    required this.destination,
    required this.channel,
    required this.receivedAt,
    this.read = false,
  });

  NotificationRecord copyWith({bool? read}) {
    return NotificationRecord(
      id: id,
      title: title,
      body: body,
      destination: destination,
      channel: channel,
      receivedAt: receivedAt,
      read: read ?? this.read,
    );
  }
}
