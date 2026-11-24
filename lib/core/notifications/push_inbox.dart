import 'package:atelier_mobile_crossplatform/core/domain/notification_record.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/push_router.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

/// Push tocado, pendiente de abrir, e historial en memoria de los avisos recibidos en la sesión.
/// La navegación de cada feature consume el pendiente. El push es solo un aviso: la pantalla
/// recarga desde la API.
class PushInbox extends ChangeNotifier {
  static const maxHistory = 50;

  final DateTime Function() now;

  PushInbox({this.now = DateTime.now});

  PushDestination? _pending;
  List<NotificationRecord> _history = const [];

  PushDestination? get pending => _pending;

  /// Del más reciente al más antiguo, hasta [maxHistory].
  List<NotificationRecord> get history => _history;

  void post(PushDestination destination) {
    _pending = destination;
    notifyListeners();
  }

  /// Guarda un aviso recibido. Sin título o cuerpo en el push, quedan `null` y vacío.
  void record(String? title, String? body, PushDestination destination) {
    final record = NotificationRecord(
      id: const Uuid().v4(),
      title: title != null && title.trim().isNotEmpty ? title : null,
      body: body != null && body.trim().isNotEmpty ? body : '',
      destination: destination,
      channel: PushRouter.channelFor(destination),
      receivedAt: now(),
    );
    _history = [record, ..._history.take(maxHistory - 1)];
    notifyListeners();
  }

  void markRead(String id) {
    _history = [
      for (final item in _history) item.id == id ? item.copyWith(read: true) : item,
    ];
    notifyListeners();
  }

  void markAllRead() {
    _history = [for (final item in _history) item.copyWith(read: true)];
    notifyListeners();
  }

  PushDestination? consume() {
    final destination = _pending;
    _pending = null;
    if (destination != null) notifyListeners();
    return destination;
  }

  /// Limpia historial y destino pendiente al cerrar sesión.
  void clear() {
    _history = const [];
    _pending = null;
    notifyListeners();
  }
}
