import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/create_supplier_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/get_suppliers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/update_supplier_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_validation.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/supplier.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/suppliers/suppliers_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:flutter/foundation.dart';

/// Catálogo y alta/edición de proveedores homologados (`inventory:suppliers:manage`).
class SuppliersViewModel extends ChangeNotifier {
  static const searchDebounce = Duration(milliseconds: 250);

  final ObserveSessionUseCase observeSession;
  final GetSuppliersUseCase getSuppliers;
  final CreateSupplierUseCase createSupplier;
  final UpdateSupplierUseCase updateSupplier;
  final ConnectivityObserver connectivity;

  SuppliersViewModel({
    required this.observeSession,
    required this.getSuppliers,
    required this.createSupplier,
    required this.updateSupplier,
    required this.connectivity,
  }) {
    _subscription = observeSession.execute().listen(
      (session) => _update(_state.copyWith(canManage: session?.has(Permission.suppliersManage) ?? false)),
    );
    _state = _state.copyWith(isOnline: connectivity.isOnline);
    connectivity.addListener(_onConnectivity);
    _load('');
  }

  SuppliersUiState _state = const SuppliersUiState();
  SuppliersUiState get state => _state;

  StreamSubscription<Object?>? _subscription;
  Timer? _debounce;
  int _loadToken = 0;
  bool _disposed = false;

  void _onConnectivity() {
    final online = connectivity.isOnline;
    final retry = online && !_state.isOnline && _state.error != null;
    _update(_state.copyWith(isOnline: online));
    if (retry) refresh();
  }

  void onQueryChange(String value) {
    _update(_state.copyWith(query: value));
    _debounce?.cancel();
    _debounce = Timer(searchDebounce, () => _load(_state.query));
  }

  Future<void> refresh() => _load(_state.query);

  Future<void> _load(String query) async {
    final token = ++_loadToken;
    _update(_state.copyWith(isLoading: true, clearError: true));
    final trimmed = query.trim();
    try {
      final list = await getSuppliers.execute(search: trimmed.isEmpty ? null : trimmed);
      if (token != _loadToken) return;
      _update(_state.copyWith(suppliers: list, isLoading: false));
    } on Object catch (e) {
      if (token != _loadToken) return;
      _update(_state.copyWith(isLoading: false, error: toUiText(e)));
    }
  }

  void onOpenCreate() {
    _update(
      _state.copyWith(
        sheetOpen: true,
        clearEditing: true,
        businessName: '',
        taxId: '',
        contactName: '',
        phone: '',
        email: '',
        address: '',
        active: true,
        clearFieldErrors: true,
        clearSubmitError: true,
      ),
    );
  }

  void onOpenEdit(Supplier supplier) {
    _update(
      _state.copyWith(
        sheetOpen: true,
        editingSupplier: supplier,
        businessName: supplier.businessName,
        taxId: supplier.taxId,
        contactName: supplier.contactName ?? '',
        phone: supplier.phone ?? '',
        email: supplier.email ?? '',
        address: supplier.address ?? '',
        active: supplier.active,
        clearFieldErrors: true,
        clearSubmitError: true,
      ),
    );
  }

  void onDismissSheet() {
    if (!_state.sheetOpen || _state.isSaving) return;
    _update(_state.copyWith(sheetOpen: false, clearSubmitError: true));
  }

  void onBusinessNameChange(String v) =>
      _update(_state.copyWith(businessName: v, clearFieldErrors: true, clearSubmitError: true));
  void onTaxIdChange(String v) =>
      _update(_state.copyWith(taxId: v, clearFieldErrors: true, clearSubmitError: true));
  void onContactNameChange(String v) => _update(_state.copyWith(contactName: v, clearSubmitError: true));
  void onPhoneChange(String v) => _update(_state.copyWith(phone: v, clearSubmitError: true));
  void onEmailChange(String v) =>
      _update(_state.copyWith(email: v, clearFieldErrors: true, clearSubmitError: true));
  void onAddressChange(String v) => _update(_state.copyWith(address: v, clearSubmitError: true));
  void onActiveChange(bool v) => _update(_state.copyWith(active: v, clearSubmitError: true));

  Future<void> onSave() async {
    final state = _state;
    if (state.isSaving || !state.isOnline) return;
    final nameErr = !InventoryValidation.isNonEmptyText(state.businessName)
        ? UiText.resource((s) => s.invSeg2SupplierErrName)
        : null;
    final taxErr = !state.isEditing && !InventoryValidation.isTaxId(state.taxId)
        ? UiText.resource((s) => s.invSeg2SupplierErrTaxId)
        : null;
    final emailErr = !InventoryValidation.isOptionalEmail(state.email)
        ? UiText.resource((s) => s.invSeg2SupplierErrEmail)
        : null;
    if (nameErr != null || taxErr != null || emailErr != null) {
      _update(
        _state.copyWith(
          clearFieldErrors: true,
          nameError: nameErr,
          taxIdError: taxErr,
          emailError: emailErr,
          hapticEvent: _state.hapticEvent + 1,
          hapticIsError: true,
        ),
      );
      return;
    }
    _update(_state.copyWith(isSaving: true, clearSubmitError: true));
    try {
      final editing = state.editingSupplier;
      if (editing == null) {
        await createSupplier.execute(
          businessName: state.businessName,
          taxId: state.taxId,
          contactName: state.contactName,
          phone: state.phone,
          email: state.email,
          address: state.address,
        );
      } else {
        await updateSupplier.execute(
          editing.id,
          businessName: state.businessName,
          contactName: state.contactName,
          phone: state.phone,
          email: state.email,
          address: state.address,
          active: state.active,
        );
      }
      _update(
        _state.copyWith(
          isSaving: false,
          sheetOpen: false,
          bannerMessage: UiText.resource((s) => s.invSeg2SupplierSaved),
          hapticEvent: _state.hapticEvent + 1,
          hapticIsError: false,
        ),
      );
      refresh();
    } on Object catch (e) {
      _update(
        _state.copyWith(
          isSaving: false,
          submitError: toUiText(e),
          hapticEvent: _state.hapticEvent + 1,
          hapticIsError: true,
        ),
      );
    }
  }

  void _update(SuppliersUiState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    connectivity.removeListener(_onConnectivity);
    _subscription?.cancel();
    super.dispose();
  }
}
