import 'dart:isolate';
import 'dart:ui';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';

/// El worker avisa a la UI que escribió. `IsolateNameServer` es de todo el proceso y sí cruza
/// motores; si la app está cerrada no hay nadie escuchando, y no pasa nada.
class LocalChangeNotifier {
  static const _portName = 'atelier_ui_port';

  /// Se llama en `main()`, en el motor de la UI. [sync] corre al terminar el worker: lo reintentado
  /// o encolado mientras él enviaba no estaba en su lote y `requestSync` lo ignoró por `keep`.
  static void listenInUi(
    AppDatabase database,
    SessionManager session, {
    required void Function() sync,
  }) {
    final port = ReceivePort();
    IsolateNameServer.removePortNameMapping(_portName);
    IsolateNameServer.registerPortWithName(port.sendPort, _portName);
    port.listen((_) {
      refresh(database, session);
      sync();
    });
  }

  /// Lo que otro motor pudo cambiar: filas y sesión. También se llama al volver a primer plano.
  static void refresh(AppDatabase database, SessionManager session) {
    database.notifyExternalChanges();
    session.reload();
  }

  /// Se llama en el worker al terminar.
  static void notifyUi() {
    IsolateNameServer.lookupPortByName(_portName)?.send(null);
  }
}
