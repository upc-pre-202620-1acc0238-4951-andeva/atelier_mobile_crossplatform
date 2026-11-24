import 'package:atelier_mobile_crossplatform/features/tasks/domain/part_option.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/pause_reason.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_product.dart';
import 'package:flutter/foundation.dart';

/// Acciones de la pantalla de detalle de tarea. Sin las de evidencia (US28), suspensión (US29) ni cierre (US30).
class TaskDetailActions {
  final VoidCallback onBack;
  final Future<void> Function() onRetry;
  final VoidCallback onStart;
  final VoidCallback onPauseClick;
  final VoidCallback onPauseDismiss;
  final ValueChanged<PauseReason> onPause;
  final VoidCallback onReopenClick;
  final VoidCallback onReopenDismiss;
  final ValueChanged<String> onReopenReasonChange;
  final VoidCallback onReopenConfirm;
  final VoidCallback onChargeClick;
  final VoidCallback onChargeDismiss;
  final ValueChanged<String> onChargeQueryChange;
  final ValueChanged<PartOption> onPartSelect;
  final ValueChanged<String> onChargeQuantityChange;
  final VoidCallback onChargeConfirm;
  final ValueChanged<TaskProduct> onEditPartClick;
  final ValueChanged<TaskProduct> onReturnPartClick;
  final VoidCallback onPartEditDismiss;
  final ValueChanged<String> onPartQuantityChange;
  final VoidCallback onPartEditConfirm;
  final ValueChanged<String>? onReportFinding;
  final void Function(String vehicleId, String? plate) onOpenObd;

  static void _noop() {}
  static Future<void> _noopAsync() async {}
  static void _noop1(Object? _) {}

  const TaskDetailActions({
    this.onBack = _noop,
    this.onRetry = _noopAsync,
    this.onStart = _noop,
    this.onPauseClick = _noop,
    this.onPauseDismiss = _noop,
    this.onPause = _noop1,
    this.onReopenClick = _noop,
    this.onReopenDismiss = _noop,
    this.onReopenReasonChange = _noop1,
    this.onReopenConfirm = _noop,
    this.onChargeClick = _noop,
    this.onChargeDismiss = _noop,
    this.onChargeQueryChange = _noop1,
    this.onPartSelect = _noop1,
    this.onChargeQuantityChange = _noop1,
    this.onChargeConfirm = _noop,
    this.onEditPartClick = _noop1,
    this.onReturnPartClick = _noop1,
    this.onPartEditDismiss = _noop,
    this.onPartQuantityChange = _noop1,
    this.onPartEditConfirm = _noop,
    this.onReportFinding,
    this.onOpenObd = _noopObd,
  });

  static void _noopObd(String vehicleId, String? plate) {}
}
