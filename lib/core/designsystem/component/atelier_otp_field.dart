import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Código de [length] dígitos. Es un solo campo de texto (acepta pegar y el código del SMS/correo)
/// dibujado como casillas de 64 dp; la casilla activa lleva el borde azul.
class AtelierOtpField extends StatefulWidget {
  final String value;
  final ValueChanged<String> onValueChange;
  final String contentDescription;
  final int length;
  final bool isError;
  final bool enabled;
  final bool autoFocus;
  final VoidCallback onDone;

  const AtelierOtpField({
    super.key,
    required this.value,
    required this.onValueChange,
    required this.contentDescription,
    this.length = 6,
    this.isError = false,
    this.enabled = true,
    this.autoFocus = true,
    this.onDone = _noop,
  });

  static void _noop() {}

  @override
  State<AtelierOtpField> createState() => _AtelierOtpFieldState();
}

class _AtelierOtpFieldState extends State<AtelierOtpField> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode.addListener(() {
      if (_focusNode.hasFocus != _focused) setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void didUpdateWidget(AtelierOtpField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.value) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final atelier = context.atelier;
    final strings = AppLocalizations.of(context);
    final value = widget.value;
    final length = widget.length;
    final progress = strings.authOtpProgress(value.length, length);
    final activeIndex = value.length < length - 1 ? value.length : length - 1;
    final digitStyle = context.text.headlineMedium!.copyWith(fontWeight: FontWeight.w700, color: scheme.onSurface);

    final boxes = Row(
      spacing: 8,
      children: [
        for (var index = 0; index < length; index++)
          Expanded(
            child: Builder(builder: (context) {
              final active = _focused && index == activeIndex;
              final border = widget.isError
                  ? atelier.bad
                  : active
                      ? scheme.primary
                      : scheme.outline;
              return Container(
                height: 64,
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: scheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: fieldRadius,
                    side: BorderSide(color: border, width: (active || widget.isError) ? 2 : 1),
                  ),
                ),
                child: Text(index < value.length ? value[index] : '', style: digitStyle),
              );
            }),
          ),
      ],
    );

    return Semantics(
      textField: true,
      label: widget.contentDescription,
      value: progress,
      excludeSemantics: true,
      onTap: () => _focusNode.requestFocus(),
      child: Stack(
        children: [
          boxes,
          // Campo real, invisible, encima de las casillas: recibe el toque, el pegado y el código del SMS.
          Positioned.fill(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.autoFocus && widget.enabled,
              enabled: widget.enabled,
              showCursor: false,
              enableInteractiveSelection: false,
              cursorColor: Colors.transparent,
              style: const TextStyle(color: Colors.transparent),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.oneTimeCode],
              maxLines: 1,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(length),
              ],
              onChanged: (raw) => widget.onValueChange(raw.replaceAll(RegExp(r'\D'), '').characters.take(length).string),
              onSubmitted: (_) => widget.onDone(),
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                counterText: '',
                filled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
