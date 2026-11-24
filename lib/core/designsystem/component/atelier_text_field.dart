import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campo de Atelier: etiqueta arriba, caja de 56 dp en pozo hundido ([AtelierColors.surfaceRecessed]) que
/// sube a [AtelierColors.card] al enfocar con borde azul de 2 dp.
///
/// El texto es controlado: [value] es la fuente de verdad y [onValueChange] avisa de cada cambio.
/// Equivalencias con Compose: `keyboardOptions` → [keyboardType], [textInputAction], [textCapitalization],
/// [autocorrect], [inputFormatters]; `keyboardActions` → [onSubmitted]; `visualTransformation` → [obscureText];
/// `autofill` → [autofillHints].
class AtelierTextField extends StatefulWidget {
  final String label;
  final String value;
  final ValueChanged<String> onValueChange;
  final IconData? leadingIcon;
  final Widget? trailing;
  final String? placeholder;
  final bool isError;
  final String? errorText;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final VoidCallback? onSubmitted;
  final FocusNode? focusNode;

  const AtelierTextField({
    super.key,
    required this.label,
    required this.value,
    required this.onValueChange,
    this.leadingIcon,
    this.trailing,
    this.placeholder,
    this.isError = false,
    this.errorText,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.inputFormatters,
    this.obscureText = false,
    this.autofillHints,
    this.onSubmitted,
    this.focusNode,
  });

  @override
  State<AtelierTextField> createState() => _AtelierTextFieldState();
}

class _AtelierTextFieldState extends State<AtelierTextField> {
  late final TextEditingController _controller;
  FocusNode? _ownFocusNode;
  bool _focused = false;

  FocusNode get _focusNode => widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(AtelierTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownFocusNode)?.removeListener(_onFocusChange);
      _focusNode.addListener(_onFocusChange);
    }
    if (_controller.text != widget.value) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus != _focused) setState(() => _focused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _ownFocusNode?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final atelier = context.atelier;
    final focused = _focused;
    final isError = widget.isError;

    final containerColor = focused ? atelier.card : atelier.surfaceRecessed;
    final borderColor = isError
        ? atelier.bad
        : focused
            ? scheme.primary
            : atelier.outlineSoft;
    final iconColor = isError
        ? atelier.bad
        : focused
            ? scheme.primary
            : atelier.muted;
    final bodyLarge = context.text.bodyLarge!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Text(widget.label, style: context.text.titleSmall!.copyWith(color: atelier.inkSecondary)),
        AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          constraints: const BoxConstraints(minHeight: 56),
          padding: EdgeInsets.only(left: 16, right: widget.trailing != null ? 4 : 16),
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            color: containerColor,
            shape: RoundedRectangleBorder(
              borderRadius: fieldRadius,
              side: BorderSide(color: borderColor, width: (focused || isError) ? 2 : 1),
            ),
          ),
          child: Row(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.leadingIcon != null) Icon(widget.leadingIcon, color: iconColor),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  style: bodyLarge.copyWith(color: scheme.onSurface),
                  cursorColor: scheme.primary,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  textCapitalization: widget.textCapitalization,
                  autocorrect: widget.autocorrect,
                  enableSuggestions: widget.autocorrect,
                  inputFormatters: widget.inputFormatters,
                  obscureText: widget.obscureText,
                  autofillHints: widget.autofillHints,
                  maxLines: 1,
                  onChanged: widget.onValueChange,
                  onSubmitted: (_) => widget.onSubmitted?.call(),
                  decoration: InputDecoration.collapsed(
                    hintText: widget.placeholder,
                    hintStyle: bodyLarge.copyWith(color: atelier.muted),
                  ),
                ),
              ),
              if (widget.trailing != null) widget.trailing!,
            ],
          ),
        ),
        if (isError && widget.errorText != null)
          Semantics(
            liveRegion: true,
            child: Row(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 16, color: atelier.bad),
                Flexible(
                  child: Text(widget.errorText!, style: context.text.bodySmall!.copyWith(color: atelier.bad)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Campo de contraseña con el botón de ojo (48 dp). El estado `visible` vive en el UiState.
class AtelierPasswordField extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onValueChange;
  final bool visible;
  final ValueChanged<bool> onVisibleChange;
  final bool isError;
  final String? errorText;
  final bool enabled;
  final TextInputAction imeAction;
  final VoidCallback onImeAction;
  final Iterable<String>? autofill;

  const AtelierPasswordField({
    super.key,
    required this.label,
    required this.value,
    required this.onValueChange,
    required this.visible,
    required this.onVisibleChange,
    this.isError = false,
    this.errorText,
    this.enabled = true,
    this.imeAction = TextInputAction.done,
    this.onImeAction = _noop,
    this.autofill = const [AutofillHints.password],
  });

  static void _noop() {}

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AtelierTextField(
      label: label,
      value: value,
      onValueChange: onValueChange,
      leadingIcon: Icons.lock_outline,
      trailing: IconButton(
        onPressed: () => onVisibleChange(!visible),
        tooltip: visible ? strings.authHidePassword : strings.authShowPassword,
        icon: Icon(visible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
      ),
      isError: isError,
      errorText: errorText,
      enabled: enabled,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: imeAction,
      onSubmitted: onImeAction,
      obscureText: !visible,
      autofillHints: autofill,
    );
  }
}
