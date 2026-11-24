import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:flutter/material.dart';

/// Hoja inferior dirigida por el estado del ViewModel: se abre sola mientras [value] no sea `null` y se
/// cierra cuando vuelve a serlo. Es el equivalente de `state.reviewing?.let { AtelierBottomSheet(...) }` de
/// Compose. [onDismiss] se invoca al cerrarse la hoja por cualquier vía (gesto, scrim o desde el estado) y debe
/// ser idempotente: el ViewModel limpia el valor.
class StateSheetHost<T extends Object> extends StatefulWidget {
  final Listenable listenable;
  final T? Function() value;
  final VoidCallback onDismiss;
  final Widget Function(BuildContext context, T value) sheetBuilder;
  final Widget child;

  const StateSheetHost({
    super.key,
    required this.listenable,
    required this.value,
    required this.onDismiss,
    required this.sheetBuilder,
    required this.child,
  });

  @override
  State<StateSheetHost<T>> createState() => _StateSheetHostState<T>();
}

class _StateSheetHostState<T extends Object> extends State<StateSheetHost<T>> {
  bool _open = false;

  @override
  void initState() {
    super.initState();
    widget.listenable.addListener(_sync);
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void didUpdateWidget(StateSheetHost<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listenable != widget.listenable) {
      oldWidget.listenable.removeListener(_sync);
      widget.listenable.addListener(_sync);
    }
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_sync);
    super.dispose();
  }

  void _sync() {
    if (!mounted) return;
    final current = widget.value();
    if (current != null && !_open) {
      _open = true;
      showAtelierSheetBuilder<void>(
        context: context,
        onDismiss: () {
          _open = false;
          widget.onDismiss();
        },
        builder: (sheetContext) => ListenableBuilder(
          listenable: widget.listenable,
          builder: (context, _) {
            final value = widget.value();
            return value == null ? const SizedBox.shrink() : widget.sheetBuilder(context, value);
          },
        ),
      );
    } else if (current == null && _open) {
      // Se marca cerrada ya: si el estado vuelve a notificar antes de que termine la animación de cierre, un
      // segundo `maybePop` sacaría la pantalla de debajo.
      _open = false;
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
