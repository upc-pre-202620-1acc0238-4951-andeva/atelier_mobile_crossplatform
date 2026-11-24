import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/invalid_task_input_exception.dart';

/// Campo que `TaskValidation` rechazó antes de llamar al backend, para marcarlo en el formulario.
String? invalidTaskField(Object error) => error is InvalidTaskInputException ? error.field : null;

/// Dato inválido: aviso genérico (el campo se marca aparte); el resto muestra el `message` del backend.
UiText toTaskUiText(Object error) {
  if (error is InvalidTaskInputException) {
    return UiText.resource((s) => s.taskInvalidInput);
  }
  return toUiText(error);
}
