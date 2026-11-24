import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';

/// Texto que el ViewModel decide pero no puede resolver (no tiene `BuildContext`): el `message` del
/// backend ([UiText.dynamic]) o un texto de `app_es.arb` ([UiText.resource]).
sealed class UiText {
  const UiText();

  /// Texto ya resuelto (p. ej. el `message` del backend).
  const factory UiText.dynamic(String value) = DynamicUiText;

  /// Texto del ARB: `UiText.resource((s) => s.errorGeneric)`.
  const factory UiText.resource(String Function(AppLocalizations strings) resolve) = ResourceUiText;

  String asString(AppLocalizations strings);
}

class DynamicUiText extends UiText {
  final String value;

  const DynamicUiText(this.value);

  @override
  String asString(AppLocalizations strings) => value;

  @override
  bool operator ==(Object other) => other is DynamicUiText && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

class ResourceUiText extends UiText {
  final String Function(AppLocalizations strings) resolve;

  const ResourceUiText(this.resolve);

  @override
  String asString(AppLocalizations strings) => resolve(strings);
}

/// Mensaje del backend si lo hay (AGENTS.md); si no, el error genérico o el de "sin conexión".
UiText toUiText(Object error) {
  if (error is ApiException && error.message.trim().isNotEmpty) {
    return UiText.dynamic(error.message);
  }
  if (error is NetworkException) {
    return UiText.resource((s) => s.errorRequiresConnection);
  }
  return UiText.resource((s) => s.errorGeneric);
}
