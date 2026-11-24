import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_colors.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:flutter/material.dart';

/// Hoja inferior para decidir sin salir de la lista (aprobar una propuesta, revisar un descargo, elegir sede).
/// Es la de Material con [sheetTopShape] (24 dp), plano `surfaceElevated` y manija estilizada: sigue al dedo
/// y se cierra por velocidad. El contenido va arriba y las acciones en [actions], al pie y al alcance del
/// pulgar; el cuerpo hace scroll si no cabe y la hoja sube con el teclado.
///
/// Se muestra con [showAtelierSheet] o [showAtelierSheetBuilder]. El widget solo dibuja el contenido de la
/// hoja (título, cuerpo y acciones); el contenedor modal lo pone la función.
class AtelierBottomSheet extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final List<Widget> content;

  const AtelierBottomSheet({
    super.key,
    required this.title,
    this.actions = const [],
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.atelier;
    return Padding(
      // La hoja sube con el teclado.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: ShapeDecoration(
                    shape: floatingBarShape,
                    color: colors.inkSecondary.withValues(alpha: 0.28),
                  ),
                ),
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(title, style: context.text.titleLarge!.copyWith(color: context.scheme.onSurface)),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          spacing: 12,
                          children: content,
                        ),
                      ),
                    ),
                    if (actions.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8,
                        children: actions,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Muestra una [AtelierBottomSheet] fija. [onDismiss] se invoca al cerrarse la hoja (gesto, scrim o
/// `Navigator.pop`), no solo al descartarla: debe ser idempotente.
Future<T?> showAtelierSheet<T>({
  required BuildContext context,
  required String title,
  required List<Widget> content,
  List<Widget> actions = const [],
  VoidCallback? onDismiss,
}) {
  return showAtelierSheetBuilder<T>(
    context: context,
    onDismiss: onDismiss,
    builder: (context) => AtelierBottomSheet(title: title, actions: actions, content: content),
  );
}

/// Variante con constructor, para hojas cuyo contenido reacciona a un ViewModel (`ListenableBuilder`).
Future<T?> showAtelierSheetBuilder<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  VoidCallback? onDismiss,
}) {
  final colors = context.atelier;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: false,
    backgroundColor: colors.surfaceElevated,
    shape: sheetTopShape,
    clipBehavior: Clip.antiAlias,
    builder: builder,
  ).whenComplete(() => onDismiss?.call());
}

/// FAB extendido esculpido, uno por pantalla, con verbo y objeto ("Recibir vehículo"): degradado
/// `#031A6B → #0071EB`, borde especular `#69B1FF @ 35%`, sombra azul real y respuesta de resorte al tocar.
class AtelierFab extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onClick;

  const AtelierFab({super.key, required this.text, required this.icon, required this.onClick});

  @override
  Widget build(BuildContext context) {
    final colors = context.atelier;
    return AtelierSurface(
      tier: SurfaceTier.floating,
      shape: panelShape,
      onClick: onClick,
      child: Ink(
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.heroStart, colors.heroEnd],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: panelRadius,
            side: BorderSide(color: atelierBlueSoft.withValues(alpha: 0.35)),
          ),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Align(
            widthFactor: 1,
            heightFactor: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white),
                  Text(text, style: context.text.labelLarge!.copyWith(color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
