import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/supplier.dart';

class SuppliersUiState {
  final String query;
  final List<Supplier> suppliers;
  final bool isLoading;
  final bool isOnline;
  final UiText? error;
  final bool canManage;
  final UiText? bannerMessage;
  final bool sheetOpen;
  final Supplier? editingSupplier;
  final String businessName;
  final String taxId;
  final String contactName;
  final String phone;
  final String email;
  final String address;
  final bool active;
  final UiText? nameError;
  final UiText? taxIdError;
  final UiText? emailError;
  final UiText? submitError;
  final bool isSaving;
  final int hapticEvent;
  final bool hapticIsError;

  const SuppliersUiState({
    this.query = '',
    this.suppliers = const [],
    this.isLoading = true,
    this.isOnline = true,
    this.error,
    this.canManage = true,
    this.bannerMessage,
    this.sheetOpen = false,
    this.editingSupplier,
    this.businessName = '',
    this.taxId = '',
    this.contactName = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.active = true,
    this.nameError,
    this.taxIdError,
    this.emailError,
    this.submitError,
    this.isSaving = false,
    this.hapticEvent = 0,
    this.hapticIsError = false,
  });

  bool get isEditing => editingSupplier != null;

  SuppliersUiState copyWith({
    String? query,
    List<Supplier>? suppliers,
    bool? isLoading,
    bool? isOnline,
    UiText? error,
    bool clearError = false,
    bool? canManage,
    UiText? bannerMessage,
    bool? sheetOpen,
    Supplier? editingSupplier,
    bool clearEditing = false,
    String? businessName,
    String? taxId,
    String? contactName,
    String? phone,
    String? email,
    String? address,
    bool? active,
    UiText? nameError,
    UiText? taxIdError,
    UiText? emailError,
    bool clearFieldErrors = false,
    UiText? submitError,
    bool clearSubmitError = false,
    bool? isSaving,
    int? hapticEvent,
    bool? hapticIsError,
  }) {
    return SuppliersUiState(
      query: query ?? this.query,
      suppliers: suppliers ?? this.suppliers,
      isLoading: isLoading ?? this.isLoading,
      isOnline: isOnline ?? this.isOnline,
      error: clearError ? null : error ?? this.error,
      canManage: canManage ?? this.canManage,
      bannerMessage: bannerMessage ?? this.bannerMessage,
      sheetOpen: sheetOpen ?? this.sheetOpen,
      editingSupplier: clearEditing ? null : editingSupplier ?? this.editingSupplier,
      businessName: businessName ?? this.businessName,
      taxId: taxId ?? this.taxId,
      contactName: contactName ?? this.contactName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      active: active ?? this.active,
      nameError: clearFieldErrors ? null : nameError ?? this.nameError,
      taxIdError: clearFieldErrors ? null : taxIdError ?? this.taxIdError,
      emailError: clearFieldErrors ? null : emailError ?? this.emailError,
      submitError: clearSubmitError ? null : submitError ?? this.submitError,
      isSaving: isSaving ?? this.isSaving,
      hapticEvent: hapticEvent ?? this.hapticEvent,
      hapticIsError: hapticIsError ?? this.hapticIsError,
    );
  }
}
