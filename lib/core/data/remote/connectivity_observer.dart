import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Estado de red para deshabilitar las acciones "en línea" (docs/06-offline-sync.md §2). Solo UI.
class ConnectivityObserver extends ChangeNotifier {
  final Stream<List<ConnectivityResult>> changes;
  final Future<List<ConnectivityResult>> Function() current;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  // Optimista hasta la primera lectura: si no hay red, la acción falla y lo dice el error.
  bool _isOnline = true;

  ConnectivityObserver({required this.changes, required this.current});

  bool get isOnline => _isOnline;

  Future<void> start() async {
    _subscription = changes.listen(_update);
    _update(await current());
  }

  void _update(List<ConnectivityResult> results) {
    final online = results.any((r) => r != ConnectivityResult.none);
    if (online == _isOnline) return;
    _isOnline = online;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
