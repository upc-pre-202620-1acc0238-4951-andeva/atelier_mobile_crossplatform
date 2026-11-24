import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campo dedicado a placas vehiculares (DESIGN.md → Inputs / Fields): teclado en mayúsculas y formato
/// automático `ABC-123` mientras el usuario teclea.
class AtelierPlateField extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onValueChange;
  final String placeholder;
  final bool isError;
  final String? errorText;
  final bool enabled;
  final TextInputAction imeAction;
  final VoidCallback onImeAction;
  final Widget? trailing;

  const AtelierPlateField({
    super.key,
    required this.label,
    required this.value,
    required this.onValueChange,
    this.placeholder = 'BKL-482',
    this.isError = false,
    this.errorText,
    this.enabled = true,
    this.imeAction = TextInputAction.search,
    this.onImeAction = _noop,
    this.trailing,
  });

  static void _noop() {}

  @override
  Widget build(BuildContext context) {
    return AtelierTextField(
      label: label,
      value: value,
      onValueChange: (raw) => onValueChange(formatPlateInput(raw)),
      leadingIcon: Icons.directions_car_outlined,
      trailing: trailing,
      placeholder: placeholder,
      isError: isError,
      errorText: errorText,
      enabled: enabled,
      textCapitalization: TextCapitalization.characters,
      autocorrect: false,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: imeAction,
      onSubmitted: onImeAction,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-]'))],
    );
  }
}

bool _isLetterOrDigit(String c) => RegExp(r'^[\p{L}\p{N}]$', unicode: true).hasMatch(c);

String formatPlateInput(String raw) {
  final letters = raw.toUpperCase().split('').where(_isLetterOrDigit).take(7).join();
  return letters.length > 3 ? '${letters.substring(0, 3)}-${letters.substring(3)}' : letters;
}
