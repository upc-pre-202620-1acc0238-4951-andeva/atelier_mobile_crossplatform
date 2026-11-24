import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/affiliate_customer_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/lookup_affiliation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/presentation/affiliation/affiliation_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/reception/presentation/reception_errors.dart';
import 'package:flutter/foundation.dart';

class AffiliationViewModel extends ChangeNotifier {
  final ObserveSessionUseCase observeSession;
  final LookupAffiliationUseCase lookupAffiliation;
  final AffiliateCustomerUseCase affiliateCustomer;
  final ConnectivityObserver? connectivity;

  AffiliationViewModel({
    required this.observeSession,
    required this.lookupAffiliation,
    required this.affiliateCustomer,
    this.connectivity,
  }) {
    final online = connectivity;
    if (online != null) {
      _state = _state.copyWith(isOnline: online.isOnline);
      online.addListener(_onConnectivity);
    }
    _subscription = observeSession.execute().listen((session) {
      _update(
        _state.copyWith(
          canLookup: session?.has(Permission.customersRead) == true,
          canAffiliate: session?.has(Permission.customersCreate) == true,
        ),
      );
    });
  }

  AffiliationUiState _state = const AffiliationUiState();
  AffiliationUiState get state => _state;

  StreamSubscription<Object?>? _subscription;
  bool _disposed = false;

  void _onConnectivity() => _update(_state.copyWith(isOnline: connectivity?.isOnline ?? true));

  /// Cambiar el correo descarta el resultado anterior: el siguiente paso depende de ese correo.
  void onEmailChange(String value) {
    if (_state.isBusy) return;
    _update(
      _state.copyWith(
        email: value,
        clearLookup: true,
        clearAffiliated: true,
        clearError: true,
        clearInvalidField: true,
      ),
    );
  }

  void onTaxIdChange(String value) {
    if (_state.isBusy) return;
    _update(_state.copyWith(taxId: value, clearError: true, clearInvalidField: true));
  }

  void onPhoneChange(String value) {
    if (_state.isBusy) return;
    _update(_state.copyWith(phone: value, clearError: true, clearInvalidField: true));
  }

  /// `GET /customers/affiliation-lookup` (US44): `nextStep` decide qué se muestra. En línea.
  Future<void> onSearch() async {
    final state = _state;
    if (!state.canSearch) return;
    _update(
      _state.copyWith(
        isSearching: true,
        clearLookup: true,
        clearAffiliated: true,
        clearError: true,
        clearInvalidField: true,
      ),
    );
    try {
      final lookup = await lookupAffiliation.execute(state.email.trim());
      _update(_state.copyWith(isSearching: false, lookup: lookup));
    } on Object catch (e) {
      _fail(e, searching: true);
    }
  }

  /// `POST /customers/affiliations` (US44 E1): `taxId` obligatorio. En línea, no se encola.
  Future<void> onAffiliate() async {
    final state = _state;
    if (!state.canSubmitAffiliation) return;
    _update(_state.copyWith(isAffiliating: true, clearError: true, clearInvalidField: true));
    try {
      final phone = state.phone.trim();
      final customer = await affiliateCustomer.execute(
        state.email.trim(),
        state.taxId.trim(),
        phone: phone.isEmpty ? null : phone,
      );
      _update(_state.copyWith(isAffiliating: false, affiliated: customer));
    } on Object catch (e) {
      _fail(e, searching: false);
    }
  }

  void _fail(Object error, {required bool searching}) {
    final field = invalidReceptionField(error);
    _update(
      _state.copyWith(
        isSearching: searching ? false : null,
        isAffiliating: searching ? null : false,
        error: toReceptionUiText(error),
        invalidField: field,
        clearInvalidField: field == null,
      ),
    );
  }

  void _update(AffiliationUiState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    connectivity?.removeListener(_onConnectivity);
    _subscription?.cancel();
    super.dispose();
  }
}
