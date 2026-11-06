import 'dart:developer';

import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Abre los push (05 §5.5) sin un `BuildContext` a mano.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Login o app según la sesión. Relee solo cuando `SessionManager` avisa: un `Future` creado en
/// `build` volvería al spinner con cualquier reconstrucción. Si el worker borra la sesión, el
/// aviso de `LocalChangeNotifier` lo trae de vuelta al login.
class AppRoot extends StatefulWidget {
  final SessionManager session;

  const AppRoot({super.key, required this.session});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  Session? _current;
  bool _loaded = false;
  int _lastRead = 0;

  @override
  void initState() {
    super.initState();
    widget.session.addListener(_read);
    _read();
  }

  @override
  void dispose() {
    widget.session.removeListener(_read);
    super.dispose();
  }

  Future<void> _read() async {
    final read = ++_lastRead;
    Session? session;
    try {
      session = await widget.session.getSession();
    } on Exception catch (e) {
      // Almacenamiento seguro ilegible: mejor el login que un spinner para siempre.
      log('No se pudo leer la sesión: $e', name: 'AppRoot');
    }
    // Dos avisos seguidos: solo vale la lectura más reciente.
    if (!mounted || read != _lastRead) return;
    setState(() {
      _current = session;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final session = _current;
    // shortcut: marcadores sin estilo, hasta que se construya la capa de presentación (07, regla 7).
    return Scaffold(
      body: Center(
        child: !_loaded
            ? const CircularProgressIndicator()
            : Text(switch (session) {
                null => strings.placeholderSignedOut,
                Session(needsBranchChoice: true) =>
                  strings.placeholderBranchChoice,
                _ => strings.placeholderSignedIn,
              }),
      ),
    );
  }
}
