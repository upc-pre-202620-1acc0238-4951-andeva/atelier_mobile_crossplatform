import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/create_service_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/delete_service_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/refresh_service_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/update_service_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/invalid_work_order_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_references.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/services/services_catalog_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/work_order_labels.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

/// Gestión del catálogo de servicios estándar del taller (`GET/POST/PUT/DELETE /api/v1/services`).
class ServicesCatalogViewModel extends ChangeNotifier {
  final ObserveSessionUseCase observeSession;
  final RefreshServiceCatalogUseCase refreshServices;
  final CreateServiceUseCase createService;
  final UpdateServiceUseCase updateService;
  final DeleteServiceUseCase deleteService;
  final ConnectivityObserver connectivity;

  ServicesCatalogViewModel({
    required this.observeSession,
    required this.refreshServices,
    required this.createService,
    required this.updateService,
    required this.deleteService,
    required this.connectivity,
  }) {
    _state = ServicesCatalogUiState(isOnline: connectivity.isOnline);
    _subscription = observeSession.execute().listen((session) {
      final canManage = session?.has(Permission.servicesManage) == true;
      final canRead = session?.has(Permission.servicesRead) == true || canManage;
      _update(_state.copyWith(canRead: canRead, canManage: canManage));
    });
    connectivity.addListener(_onConnectivity);
    load();
  }

  late ServicesCatalogUiState _state;
  ServicesCatalogUiState get state => _state;

  StreamSubscription<Object?>? _subscription;
  bool _disposed = false;

  void _onConnectivity() {
    _update(_state.copyWith(isOnline: connectivity.isOnline));
  }

  Future<void> load() async {
    _update(_state.copyWith(isLoading: true, error: null));
    try {
      final list = await refreshServices.execute();
      _update(_state.copyWith(services: list, isLoading: false, error: null));
    } on Object catch (error) {
      _update(_state.copyWith(isLoading: false, error: toWorkOrderUiText(error)));
    }
  }

  void onSearchQueryChange(String value) => _update(_state.copyWith(searchQuery: value));

  void onOpenCreate() {
    final state = _state;
    if (!state.canCreate) return;
    _update(
      state.copyWith(
        form: const ServiceEditorForm(),
        notice: null,
        error: null,
        invalidField: null,
      ),
    );
  }

  void onOpenEdit(ServiceOption service) {
    final state = _state;
    if (!state.canManage || state.isSaving) return;
    _update(
      state.copyWith(
        form: ServiceEditorForm(
          serviceId: service.id,
          name: service.name,
          basePrice: service.basePrice?.amount.toString() ?? '',
          estimatedMinutes: service.estimatedMinutes?.toString() ?? '',
        ),
        notice: null,
        error: null,
        invalidField: null,
      ),
    );
  }

  void onDismissForm() {
    if (_state.isSaving) return;
    _update(_state.copyWith(form: null, error: null, invalidField: null));
  }

  void onNameChange(String value) => _editForm((f) => f.copyWith(name: value));

  void onBasePriceChange(String value) => _editForm((f) => f.copyWith(basePrice: value));

  void onEstimatedMinutesChange(String value) =>
      _editForm((f) => f.copyWith(estimatedMinutes: value.replaceAll(RegExp(r'[^0-9]'), '')));

  void _editForm(ServiceEditorForm Function(ServiceEditorForm) change) {
    final current = _state.form;
    if (current == null || _state.isSaving) return;
    _update(_state.copyWith(form: change(current), error: null, invalidField: null));
  }

  Future<void> onConfirmForm() async {
    final state = _state;
    final form = state.form;
    if (form == null || !state.canManage || state.isSaving || !state.isOnline) return;

    final trimmedName = form.name.trim();
    if (trimmedName.isEmpty || trimmedName.length > 150) {
      _fail(const InvalidWorkOrderInputException('name'));
      return;
    }
    final parsedPrice = Decimal.tryParse(form.basePrice.trim().replaceAll(',', '.'));
    if (parsedPrice == null || parsedPrice <= Decimal.zero) {
      _fail(const InvalidWorkOrderInputException('basePrice'));
      return;
    }
    final parsedMinutes = int.tryParse(form.estimatedMinutes.trim());
    if (parsedMinutes == null || parsedMinutes <= 0) {
      _fail(const InvalidWorkOrderInputException('estimatedMinutes'));
      return;
    }

    _update(state.copyWith(isSaving: true, error: null, invalidField: null));
    try {
      final serviceId = form.serviceId;
      final saved = serviceId == null
          ? await createService.execute(
              name: trimmedName,
              basePrice: parsedPrice,
              estimatedMinutes: parsedMinutes,
            )
          : await updateService.execute(
              serviceId,
              name: trimmedName,
              basePrice: parsedPrice,
              estimatedMinutes: parsedMinutes,
            );
      final updatedList = [
        for (final s in _state.services)
          if (s.id != saved.id) s,
        saved,
      ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      _update(
        _state.copyWith(
          services: updatedList,
          isSaving: false,
          form: null,
          notice: UiText.resource(
            (s) => serviceId == null ? s.servicesCreatedNotice : s.servicesUpdatedNotice,
          ),
          error: null,
          invalidField: null,
        ),
      );
    } on Object catch (error) {
      _fail(error);
    }
  }

  void onOpenDelete(ServiceOption service) {
    final state = _state;
    if (!state.canManage || state.isSaving) return;
    _update(state.copyWith(deletingService: service, form: null, error: null, notice: null));
  }

  void onDismissDelete() {
    if (_state.isSaving) return;
    _update(_state.copyWith(deletingService: null, error: null));
  }

  Future<void> onConfirmDelete() async {
    final state = _state;
    final target = state.deletingService;
    if (target == null || !state.canManage || state.isSaving || !state.isOnline) return;
    _update(state.copyWith(isSaving: true, error: null));
    try {
      await deleteService.execute(target.id);
      _update(
        _state.copyWith(
          services: _state.services.where((s) => s.id != target.id).toList(),
          isSaving: false,
          deletingService: null,
          notice: UiText.resource((s) => s.servicesDeletedNotice),
          error: null,
        ),
      );
    } on Object catch (error) {
      _fail(error);
    }
  }

  void _fail(Object error) {
    _update(
      _state.copyWith(
        isSaving: false,
        error: toWorkOrderUiText(error),
        invalidField: invalidWorkOrderField(error),
      ),
    );
  }

  void _update(ServicesCatalogUiState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    connectivity.removeListener(_onConnectivity);
    _subscription?.cancel();
    super.dispose();
  }
}
