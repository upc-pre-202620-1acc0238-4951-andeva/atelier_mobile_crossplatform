import 'package:atelier_mobile_crossplatform/features/workorders/domain/pending_work_order_capture.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';

class ObservePendingIntakePhotosUseCase {
  final WorkOrderRepository repository;

  const ObservePendingIntakePhotosUseCase({required this.repository});

  Stream<List<PendingIntakePhoto>> execute(WorkOrderId id) {
    return repository.observePendingIntakePhotos(id);
  }
}
