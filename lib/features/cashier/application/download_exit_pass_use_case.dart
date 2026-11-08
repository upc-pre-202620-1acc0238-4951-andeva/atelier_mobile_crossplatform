import 'dart:io';

import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';

/// US39 E2/E3 (`invoicing:exit_passes:issue`). Abrir y compartir el PDF es de la UI.
class DownloadExitPassUseCase {
  final WorkOrderRepository repository;

  const DownloadExitPassUseCase({required this.repository});

  Future<File> execute(WorkOrderId id) => repository.downloadExitPass(id);
}
