import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/invalid_reception_input_exception.dart';

/// Campo que `ReceptionValidation` rechazó antes de llamar al backend, para marcarlo en el formulario.
String? invalidReceptionField(Object error) => error is InvalidReceptionInputException ? error.field : null;

/// Dato inválido: aviso genérico (el campo se marca aparte); el resto muestra el `message` del backend.
UiText toReceptionUiText(Object error) {
  if (error is InvalidReceptionInputException) {
    return UiText.resource((s) => s.receptionInvalidInput);
  }
  return toUiText(error);
}
