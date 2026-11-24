import 'dart:async';
import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/attach_intake_photo_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_work_order_detail_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/observe_pending_intake_photos_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/intake/intake_gallery_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/work_order_labels.dart';
import 'package:flutter/foundation.dart';

/// US13: galería pericial de recepción. Las fotos van siempre por la cola (con o sin red) y aparecen como
/// "en cola" hasta que el backend las registra; las ya registradas salen del detalle de la orden (E2).
class IntakeGalleryViewModel extends ChangeNotifier {
  final String workOrderId;
  final ObserveSessionUseCase observeSession;
  final AttachIntakePhotoUseCase attachPhoto;
  final ObservePendingIntakePhotosUseCase observePending;
  final GetWorkOrderDetailUseCase getDetail;

  IntakeGalleryViewModel({
    required this.workOrderId,
    required this.observeSession,
    required this.attachPhoto,
    required this.observePending,
    required this.getDetail,
  }) {
    _subscriptions.add(
      observeSession.execute().listen((session) {
        final canRead = session?.has(Permission.workOrdersRead) == true;
        _update(
          _state.copyWith(
            canRead: canRead,
            canUpload: session?.has(Permission.inspectionsUploadPhotos) == true,
          ),
        );
        if (!_detailRequested) {
          _detailRequested = true;
          if (canRead) {
            refresh();
          } else {
            _update(_state.copyWith(isLoading: false));
          }
        }
      }),
    );
    var previous = 0;
    _subscriptions.add(
      observePending.execute(WorkOrderId(workOrderId)).listen((pending) {
        _update(_state.copyWith(pending: pending));
        // Una foto salió de la cola: ya está registrada y hay que traerla del detalle.
        if (pending.length < previous && _state.canRead) refresh();
        previous = pending.length;
      }),
    );
  }

  IntakeGalleryUiState _state = const IntakeGalleryUiState();
  IntakeGalleryUiState get state => _state;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  bool _detailRequested = false;
  bool _disposed = false;

  /// `GET /work-orders/{id}`: fotos ya registradas. Sin red se sigue con lo que hay y las fotos en cola.
  Future<void> refresh() async {
    try {
      final detail = await getDetail.execute(WorkOrderId(workOrderId));
      _update(_state.copyWith(isLoading: false, uploaded: detail.intakeImages, error: null));
    } on Object catch (error) {
      _update(_state.copyWith(isLoading: false, error: toWorkOrderUiText(error)));
    }
  }

  void onNoteChange(String value) => _update(_state.copyWith(note: value, error: null));

  /// La foto ya fue tomada: se comprime, se guarda y se encola. Funciona sin red.
  Future<void> onPhotoCaptured(InspectionAngle angle, File photo) async {
    final state = _state;
    if (!state.canUpload || state.isSaving) return;
    _update(state.copyWith(isSaving: true, error: null));
    try {
      await attachPhoto.execute(
        WorkOrderId(workOrderId),
        photo,
        description: InspectionAngle.describe(angle, state.note),
      );
      _update(_state.copyWith(isSaving: false, note: ''));
    } on Object catch (error) {
      _update(_state.copyWith(isSaving: false, error: toWorkOrderUiText(error)));
    } finally {
      if (photo.existsSync()) photo.deleteSync();
    }
  }

  void onCameraDenied() =>
      _update(_state.copyWith(error: UiText.resource((s) => s.galleryCameraDenied)));

  void _update(IntakeGalleryUiState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}
