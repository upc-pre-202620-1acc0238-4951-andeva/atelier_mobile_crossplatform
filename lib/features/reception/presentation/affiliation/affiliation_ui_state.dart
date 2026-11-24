import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/affiliation_lookup.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/customer.dart';

class AffiliationUiState {
  final String email;
  final String taxId;
  final String phone;
  final bool isSearching;
  final bool isAffiliating;
  final AffiliationLookup? lookup;

  /// Cliente ya afiliado en esta pantalla (US44 E1).
  final Customer? affiliated;
  final UiText? error;

  /// Campo que no pasó la validación local (`email`, `taxId`, `phone`).
  final String? invalidField;
  final bool canLookup;
  final bool canAffiliate;
  final bool isOnline;

  const AffiliationUiState({
    this.email = '',
    this.taxId = '',
    this.phone = '',
    this.isSearching = false,
    this.isAffiliating = false,
    this.lookup,
    this.affiliated,
    this.error,
    this.invalidField,
    this.canLookup = false,
    this.canAffiliate = false,
    this.isOnline = true,
  });

  bool get isBusy => isSearching || isAffiliating;
  AffiliationStep? get step => lookup?.nextStep;
  bool get canSearch => isOnline && canLookup && email.trim().isNotEmpty && !isBusy;
  bool get canSubmitAffiliation =>
      isOnline &&
      canAffiliate &&
      step == AffiliationStep.affiliate &&
      affiliated == null &&
      taxId.trim().isNotEmpty &&
      !isBusy;

  AffiliationUiState copyWith({
    String? email,
    String? taxId,
    String? phone,
    bool? isSearching,
    bool? isAffiliating,
    AffiliationLookup? lookup,
    bool clearLookup = false,
    Customer? affiliated,
    bool clearAffiliated = false,
    UiText? error,
    bool clearError = false,
    String? invalidField,
    bool clearInvalidField = false,
    bool? canLookup,
    bool? canAffiliate,
    bool? isOnline,
  }) {
    return AffiliationUiState(
      email: email ?? this.email,
      taxId: taxId ?? this.taxId,
      phone: phone ?? this.phone,
      isSearching: isSearching ?? this.isSearching,
      isAffiliating: isAffiliating ?? this.isAffiliating,
      lookup: clearLookup ? null : lookup ?? this.lookup,
      affiliated: clearAffiliated ? null : affiliated ?? this.affiliated,
      error: clearError ? null : error ?? this.error,
      invalidField: clearInvalidField ? null : invalidField ?? this.invalidField,
      canLookup: canLookup ?? this.canLookup,
      canAffiliate: canAffiliate ?? this.canAffiliate,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
