import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:flutter/widgets.dart';

/// Disparadores de la cola en la UI (docs/06-offline-sync.md §3): al abrir, al recuperar red y al
/// volver a primer plano. iOS no garantiza el segundo plano (H42), así que estos son los que
/// cuentan allí. Al volver también se relee lo que otro motor pudo cambiar.
class SyncTriggers {
  final ConnectivityObserver connectivity;
  final VoidCallback sync;
  final VoidCallback refreshExternalChanges;

  AppLifecycleListener? _lifecycle;
  bool _wasOnline = true;

  SyncTriggers({
    required this.connectivity,
    required this.sync,
    required this.refreshExternalChanges,
  });

  Future<void> start() async {
    await connectivity.start();
    _wasOnline = connectivity.isOnline;
    connectivity.addListener(_onConnectivity);
    _lifecycle = AppLifecycleListener(onResume: _onResume);
    sync();
  }

  void _onConnectivity() {
    final online = connectivity.isOnline;
    if (online && !_wasOnline) sync();
    _wasOnline = online;
  }

  void _onResume() {
    refreshExternalChanges();
    sync();
  }

  void dispose() {
    connectivity.removeListener(_onConnectivity);
    _lifecycle?.dispose();
  }
}
