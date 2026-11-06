import 'package:atelier_mobile_crossplatform/core/notifications/push_router.dart';
import 'package:flutter/foundation.dart';

/// Push tocado, pendiente de abrir. La navegación de cada feature lo consume. El push es solo un
/// aviso: la pantalla recarga desde la API.
class PushInbox extends ChangeNotifier {
  PushDestination? _pending;

  PushDestination? get pending => _pending;

  void post(PushDestination destination) {
    _pending = destination;
    notifyListeners();
  }

  PushDestination? consume() {
    final destination = _pending;
    _pending = null;
    return destination;
  }
}
