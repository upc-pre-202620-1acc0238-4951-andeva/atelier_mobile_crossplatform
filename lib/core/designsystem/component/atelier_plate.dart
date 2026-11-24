import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_colors.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// [l] en fichas y paneles de decisión; [m] en listas densas.
enum PlateSize { m, l }

bool _isLetterOrDigit(String c) => RegExp(r'^[\p{L}\p{N}]$', unicode: true).hasMatch(c);

/// `BKL482` → `BKL-482`. Solo el formato de auto (3 + 3, empieza en letra); el resto se muestra tal cual.
String formatPlate(String raw) {
  final plate = raw.trim().toUpperCase();
  final chars = plate.split('');
  if (plate.length == 6 && chars.every(_isLetterOrDigit) && RegExp(r'^\p{L}', unicode: true).hasMatch(plate)) {
    return '${plate.substring(0, 3)}-${plate.substring(3)}';
  }
  return plate;
}

/// Insignia automotriz mecanizada: blanca metálica con franja superior peruana `#031A6B`, bisel sutil
/// y texto Satoshi Black `tnum` en `#262626` en ambos temas.
/// El lector de pantalla la deletrea ("placa B K L 4 8 2") en vez de leerla como palabra.
class AtelierPlate extends StatelessWidget {
  final String plate;
  final PlateSize size;

  const AtelierPlate({super.key, required this.plate, this.size = PlateSize.m});

  @override
  Widget build(BuildContext context) {
    final colors = context.atelier;
    final text = formatPlate(plate);
    final spoken = AppLocalizations.of(context).plateA11y(text.split('').where(_isLetterOrDigit).join(' '));
    final style = size == PlateSize.l
        ? context.text.titleLarge!
        : context.text.titleMedium!.copyWith(fontWeight: FontWeight.w900);

    return Semantics(
      label: spoken,
      excludeSemantics: true,
      child: ClipPath(
        clipper: const ShapeBorderClipper(shape: plateShape),
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: plateRadius,
              side: BorderSide(color: atelierInk.withValues(alpha: 0.22)),
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [colors.plate, colors.plateBase],
              ),
            ),
            child: CustomPaint(
              foregroundPainter: const _PlateStripePainter(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 2),
                child: Text(text, style: style.copyWith(color: atelierInk), maxLines: 1, softWrap: false),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlateStripePainter extends CustomPainter {
  const _PlateStripePainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 2.5), Paint()..color = atelierBlueDark);
  }

  @override
  bool shouldRepaint(_PlateStripePainter old) => false;
}
