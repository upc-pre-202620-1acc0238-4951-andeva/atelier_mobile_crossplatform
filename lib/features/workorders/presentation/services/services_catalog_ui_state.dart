import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_references.dart';

const _keep = Object();

/// Formulario de alta o edición de un servicio estándar del catálogo del taller.
class ServiceEditorForm {
  final String? serviceId;
  final String name;
  final String basePrice;
  final String estimatedMinutes;

  const ServiceEditorForm({
    this.serviceId,
    this.name = '',
    this.basePrice = '',
    this.estimatedMinutes = '',
  });

  bool get isEditing => serviceId != null;

  ServiceEditorForm copyWith({
    String? name,
    String? basePrice,
    String? estimatedMinutes,
  }) {
    return ServiceEditorForm(
      serviceId: serviceId,
      name: name ?? this.name,
      basePrice: basePrice ?? this.basePrice,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
    );
  }
}

class ServicesCatalogUiState {
  final List<ServiceOption> services;
  final String searchQuery;
  final bool isLoading;
  final bool isOnline;
  final bool canRead;
  final bool canManage;
  final bool isSaving;
  final ServiceEditorForm? form;
  final ServiceOption? deletingService;
  final String? invalidField;
  final UiText? notice;
  final UiText? error;

  const ServicesCatalogUiState({
    this.services = const [],
    this.searchQuery = '',
    this.isLoading = true,
    this.isOnline = true,
    this.canRead = false,
    this.canManage = false,
    this.isSaving = false,
    this.form,
    this.deletingService,
    this.invalidField,
    this.notice,
    this.error,
  });

  List<ServiceOption> get filteredServices {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return services;
    return services.where((s) => s.name.toLowerCase().contains(q)).toList();
  }

  bool get canCreate => canManage && isOnline && !isSaving;

  bool get canConfirmForm {
    final current = form;
    if (current == null) return false;
    return current.name.trim().isNotEmpty &&
        current.basePrice.trim().isNotEmpty &&
        current.estimatedMinutes.trim().isNotEmpty &&
        isOnline &&
        !isSaving;
  }

  ServicesCatalogUiState copyWith({
    List<ServiceOption>? services,
    String? searchQuery,
    bool? isLoading,
    bool? isOnline,
    bool? canRead,
    bool? canManage,
    bool? isSaving,
    Object? form = _keep,
    Object? deletingService = _keep,
    Object? invalidField = _keep,
    Object? notice = _keep,
    Object? error = _keep,
  }) {
    return ServicesCatalogUiState(
      services: services ?? this.services,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      isOnline: isOnline ?? this.isOnline,
      canRead: canRead ?? this.canRead,
      canManage: canManage ?? this.canManage,
      isSaving: isSaving ?? this.isSaving,
      form: identical(form, _keep) ? this.form : form as ServiceEditorForm?,
      deletingService: identical(deletingService, _keep)
          ? this.deletingService
          : deletingService as ServiceOption?,
      invalidField: identical(invalidField, _keep) ? this.invalidField : invalidField as String?,
      notice: identical(notice, _keep) ? this.notice : notice as UiText?,
      error: identical(error, _keep) ? this.error : error as UiText?,
    );
  }
}
