import 'dart:async';

import 'package:atelier_mobile_crossplatform/features/bays/domain/bay_repository.dart';

/// US40 E3: refresca ya y cada 30 s mientras se escuche; escuchar solo con el tablero visible (H24).
/// Cada fallo llega como evento de error y el ciclo sigue. Sin `operations:bays:read` se cierra sin
/// emitir ni llamar.
class PollBayBoardUseCase {
  static const interval = Duration(seconds: 30);

  final BayRepository repository;

  const PollBayBoardUseCase({required this.repository});

  Stream<void> execute() {
    late final StreamController<void> controller;
    Timer? timer;
    var active = true;

    Future<void> tick() async {
      try {
        await repository.refreshBranchBays();
        if (active) controller.add(null);
      } catch (error, stackTrace) {
        if (active) controller.addError(error, stackTrace);
      }
      if (active) timer = Timer(interval, tick);
    }

    controller = StreamController<void>(
      onListen: () async {
        if (!await repository.canReadBoard()) {
          active = false;
          await controller.close();
          return;
        }
        if (active) unawaited(tick());
      },
      onCancel: () {
        active = false;
        timer?.cancel();
      },
    );
    return controller.stream;
  }
}
