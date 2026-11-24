import 'package:flutter/widgets.dart';

/// Ícono vectorial propio (viewport 24 x 24), portado de `Icons.kt` de Android: Material Symbols
/// (contorno) que `material-icons-outlined` no trae. Se dibuja con [AtelierIcon].
@immutable
class AtelierVectorIcon {
  final String name;
  final Path Function() _build;

  const AtelierVectorIcon._(this.name, this._build);

  /// Trazado en el viewport de 24 x 24, relleno `nonZero`.
  Path buildPath() => _build();
}

/// Los cuatro íconos propios de Android. El resto del set son `Icons.xxx_outlined` de Flutter.
abstract final class AtelierIcons {
  static const person = AtelierVectorIcon._('person', _person);
  static const assignment = AtelierVectorIcon._('assignment', _assignment);
  static const bluetoothSearching = AtelierVectorIcon._(
    'bluetooth_searching',
    _bluetoothSearching,
  );
  static const home = AtelierVectorIcon._('home', _home);
}

/// Dibuja un [AtelierVectorIcon] del tamaño y color pedidos (24 y el color de texto por defecto, como `Icon`).
class AtelierIcon extends StatelessWidget {
  final AtelierVectorIcon icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  const AtelierIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final side = size ?? iconTheme.size ?? 24;
    final tint = (color ?? iconTheme.color ?? const Color(0xFF000000))
        .withValues(alpha: iconTheme.opacity);
    return Semantics(
      label: semanticLabel,
      image: true,
      excludeSemantics: semanticLabel == null,
      child: SizedBox.square(
        dimension: side,
        child: CustomPaint(painter: _VectorIconPainter(icon, tint)),
      ),
    );
  }
}

class _VectorIconPainter extends CustomPainter {
  final AtelierVectorIcon icon;
  final Color color;

  _VectorIconPainter(this.icon, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    canvas.drawPath(
      icon.buildPath(),
      Paint()
        ..color = color
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(_VectorIconPainter old) =>
      old.icon != icon || old.color != color;
}

Path _person() => Path()
  ..moveTo(9.18, 10.83)
  ..quadraticBezierTo(8.0, 9.65, 8.0, 8.0)
  ..quadraticBezierTo(8.0, 6.35, 9.18, 5.18)
  ..quadraticBezierTo(10.36, 4.01, 12.0, 4.0)
  ..quadraticBezierTo(13.64, 3.99, 14.83, 5.18)
  ..quadraticBezierTo(16.02, 6.37, 16.0, 8.0)
  ..quadraticBezierTo(15.98, 9.63, 14.83, 10.82)
  ..quadraticBezierTo(13.68, 12.01, 12.0, 12.0)
  ..quadraticBezierTo(10.32, 11.99, 9.18, 10.83)
  ..close()
  ..moveTo(4.0, 20.0)
  ..lineTo(4.0, 17.2)
  ..quadraticBezierTo(4.0, 16.35, 4.44, 15.64)
  ..quadraticBezierTo(4.88, 14.93, 5.6, 14.55)
  ..quadraticBezierTo(7.15, 13.77, 8.75, 13.39)
  ..quadraticBezierTo(10.35, 13.01, 12.0, 13.0)
  ..quadraticBezierTo(13.65, 12.99, 15.25, 13.39)
  ..quadraticBezierTo(16.85, 13.79, 18.4, 14.55)
  ..quadraticBezierTo(19.12, 14.93, 19.56, 15.64)
  ..quadraticBezierTo(20.0, 16.35, 20.0, 17.2)
  ..lineTo(20.0, 20.0)
  ..lineTo(4.0, 20.0)
  ..close()
  ..moveTo(6.0, 18.0)
  ..lineTo(18.0, 18.0)
  ..lineTo(18.0, 17.2)
  ..quadraticBezierTo(18.0, 16.93, 17.86, 16.7)
  ..quadraticBezierTo(17.73, 16.48, 17.5, 16.35)
  ..quadraticBezierTo(16.15, 15.68, 14.78, 15.34)
  ..quadraticBezierTo(13.41, 15.0, 12.0, 15.0)
  ..quadraticBezierTo(10.59, 15.0, 9.23, 15.34)
  ..quadraticBezierTo(7.87, 15.68, 6.5, 16.35)
  ..quadraticBezierTo(6.28, 16.48, 6.14, 16.7)
  ..quadraticBezierTo(6.0, 16.93, 6.0, 17.2)
  ..lineTo(6.0, 18.0)
  ..close()
  ..moveTo(13.41, 9.41)
  ..quadraticBezierTo(14.0, 8.82, 14.0, 8.0)
  ..quadraticBezierTo(14.0, 7.18, 13.41, 6.59)
  ..quadraticBezierTo(12.82, 6.0, 12.0, 6.0)
  ..quadraticBezierTo(11.18, 6.0, 10.59, 6.59)
  ..quadraticBezierTo(10.0, 7.18, 10.0, 8.0)
  ..quadraticBezierTo(10.0, 8.82, 10.59, 9.41)
  ..quadraticBezierTo(11.18, 10.0, 12.0, 10.0)
  ..quadraticBezierTo(12.82, 10.0, 13.41, 9.41)
  ..close()
  ..moveTo(12.0, 8.0)
  ..close()
  ..moveTo(12.0, 18.0)
  ..close();

Path _assignment() => Path()
  ..moveTo(5.0, 21.0)
  ..quadraticBezierTo(4.18, 21.0, 3.59, 20.41)
  ..quadraticBezierTo(3.0, 19.82, 3.0, 19.0)
  ..lineTo(3.0, 5.0)
  ..quadraticBezierTo(3.0, 4.17, 3.59, 3.59)
  ..quadraticBezierTo(4.18, 3.01, 5.0, 3.0)
  ..lineTo(9.2, 3.0)
  ..quadraticBezierTo(9.53, 2.1, 10.29, 1.55)
  ..quadraticBezierTo(11.05, 1.0, 12.0, 1.0)
  ..quadraticBezierTo(12.95, 1.0, 13.71, 1.55)
  ..quadraticBezierTo(14.47, 2.1, 14.8, 3.0)
  ..lineTo(19.0, 3.0)
  ..quadraticBezierTo(19.83, 3.0, 20.41, 3.59)
  ..quadraticBezierTo(20.99, 4.18, 21.0, 5.0)
  ..lineTo(21.0, 19.0)
  ..quadraticBezierTo(21.0, 19.82, 20.41, 20.41)
  ..quadraticBezierTo(19.82, 21.0, 19.0, 21.0)
  ..lineTo(5.0, 21.0)
  ..close()
  ..moveTo(5.0, 19.0)
  ..lineTo(19.0, 19.0)
  ..lineTo(19.0, 5.0)
  ..lineTo(5.0, 5.0)
  ..lineTo(5.0, 19.0)
  ..close()
  ..moveTo(7.0, 17.0)
  ..lineTo(14.0, 17.0)
  ..lineTo(14.0, 15.0)
  ..lineTo(7.0, 15.0)
  ..lineTo(7.0, 17.0)
  ..close()
  ..moveTo(7.0, 13.0)
  ..lineTo(17.0, 13.0)
  ..lineTo(17.0, 11.0)
  ..lineTo(7.0, 11.0)
  ..lineTo(7.0, 13.0)
  ..close()
  ..moveTo(7.0, 9.0)
  ..lineTo(17.0, 9.0)
  ..lineTo(17.0, 7.0)
  ..lineTo(7.0, 7.0)
  ..lineTo(7.0, 9.0)
  ..close()
  ..moveTo(12.54, 4.04)
  ..quadraticBezierTo(12.75, 3.82, 12.75, 3.5)
  ..quadraticBezierTo(12.75, 3.17, 12.54, 2.96)
  ..quadraticBezierTo(12.33, 2.75, 12.0, 2.75)
  ..quadraticBezierTo(11.67, 2.75, 11.46, 2.96)
  ..quadraticBezierTo(11.25, 3.17, 11.25, 3.5)
  ..quadraticBezierTo(11.25, 3.82, 11.46, 4.04)
  ..quadraticBezierTo(11.67, 4.26, 12.0, 4.25)
  ..quadraticBezierTo(12.33, 4.24, 12.54, 4.04)
  ..close()
  ..moveTo(5.0, 19.0)
  ..lineTo(5.0, 5.0)
  ..lineTo(5.0, 19.0)
  ..close();

Path _bluetoothSearching() => Path()
  ..moveTo(9.0, 22.0)
  ..lineTo(9.0, 14.4)
  ..lineTo(4.4, 19.0)
  ..lineTo(3.0, 17.6)
  ..lineTo(8.6, 12.0)
  ..lineTo(3.0, 6.4)
  ..lineTo(4.4, 5.0)
  ..lineTo(9.0, 9.6)
  ..lineTo(9.0, 2.0)
  ..lineTo(10.0, 2.0)
  ..lineTo(15.7, 7.7)
  ..lineTo(11.4, 12.0)
  ..lineTo(15.7, 16.3)
  ..lineTo(10.0, 22.0)
  ..lineTo(9.0, 22.0)
  ..close()
  ..moveTo(11.0, 9.6)
  ..lineTo(12.9, 7.7)
  ..lineTo(11.0, 5.85)
  ..lineTo(11.0, 9.6)
  ..close()
  ..moveTo(11.0, 18.15)
  ..lineTo(12.9, 16.3)
  ..lineTo(11.0, 14.4)
  ..lineTo(11.0, 18.15)
  ..close()
  ..moveTo(16.55, 14.35)
  ..lineTo(14.25, 12.0)
  ..lineTo(16.55, 9.7)
  ..quadraticBezierTo(16.78, 10.25, 16.91, 10.83)
  ..quadraticBezierTo(17.04, 11.41, 17.05, 12.0)
  ..quadraticBezierTo(17.06, 12.59, 16.91, 13.19)
  ..quadraticBezierTo(16.77, 13.78, 16.55, 14.35)
  ..close()
  ..moveTo(19.5, 17.2)
  ..lineTo(18.25, 16.0)
  ..quadraticBezierTo(18.75, 15.07, 19.03, 14.06)
  ..quadraticBezierTo(19.31, 13.05, 19.3, 12.0)
  ..quadraticBezierTo(19.29, 10.95, 19.03, 9.94)
  ..quadraticBezierTo(18.75, 8.92, 18.25, 8.0)
  ..lineTo(19.5, 6.75)
  ..quadraticBezierTo(20.23, 7.95, 20.61, 9.27)
  ..quadraticBezierTo(20.99, 10.59, 21.0, 12.0)
  ..quadraticBezierTo(21.01, 13.41, 20.61, 14.71)
  ..quadraticBezierTo(20.23, 16.02, 19.5, 17.2)
  ..close();

Path _home() => Path()
  ..moveTo(6.0, 19.0)
  ..lineTo(9.0, 19.0)
  ..lineTo(9.0, 13.0)
  ..lineTo(15.0, 13.0)
  ..lineTo(15.0, 19.0)
  ..lineTo(18.0, 19.0)
  ..lineTo(18.0, 10.0)
  ..lineTo(12.0, 5.5)
  ..lineTo(6.0, 10.0)
  ..lineTo(6.0, 19.0)
  ..close()
  ..moveTo(4.0, 21.0)
  ..lineTo(4.0, 9.0)
  ..lineTo(12.0, 3.0)
  ..lineTo(20.0, 9.0)
  ..lineTo(20.0, 21.0)
  ..lineTo(13.0, 21.0)
  ..lineTo(13.0, 15.0)
  ..lineTo(11.0, 15.0)
  ..lineTo(11.0, 21.0)
  ..lineTo(4.0, 21.0)
  ..close()
  ..moveTo(12.0, 12.25)
  ..close();
