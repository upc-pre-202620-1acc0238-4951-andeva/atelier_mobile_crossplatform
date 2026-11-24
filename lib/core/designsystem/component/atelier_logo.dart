import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_colors.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_typography.dart';
import 'package:flutter/material.dart';

/// Imagotipo: isotipo en squircle azul + «Atelier / Workshop» en Albert Sans ExtraBold.
/// El isotipo se dibuja con [AtelierLogoMark], fiel al vector `ic_atelier_logo.xml` de Android.
class AtelierLogo extends StatelessWidget {
  final String name;

  const AtelierLogo({super.key, this.name = 'Atelier Workshop'});

  @override
  Widget build(BuildContext context) {
    final base = context.text.titleMedium!;
    final inkStyle = base.copyWith(
      fontFamily: albertSansFamily,
      fontWeight: FontWeight.w800,
      height: 1,
      color: context.scheme.onSurface,
    );
    return Semantics(
      label: name,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const AtelierLogoMark(size: 36),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Atelier', style: inkStyle),
              Text('Workshop', style: inkStyle),
            ],
          ),
        ],
      ),
    );
  }
}

/// Isotipo cuadrado (squircle azul con la silueta blanca), vector de 500 × 500.
class AtelierLogoMark extends StatelessWidget {
  final double size;

  const AtelierLogoMark({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const CustomPaint(painter: _LogoPainter()),
    );
  }
}

const _squircle = 'M0 110c0-60.75 49.25-110 110-110h280c60.75 0 110 49.25 110 110v280c0 60.75-49.25 110-110 110h-280c-60.75 0-110-49.25-110-110z';

const _hat =
    'M141.37 206.05C133.48 206.13 131.43 203.94 131.37 196.76V186.49C131.43 178.96 133.57 176.79 141.37 176.71H161.37V152.74C148.2 151.21 141.93 153.56 136.87 146.88 131.72 139.81 130.18 135.36 127.56 126.83 123.59 113.74 125.16 107.76 139.87 107.27 192.73 100.28 219.83 95.23 280.34 91.62 323.7 89.75 337.54 116.93 344.32 176.71H364.31C372.11 176.79 374.25 178.96 374.31 186.49V196.76C374.26 203.94 372.2 206.13 364.31 206.05H141.37Z';

const _hatInner =
    'M141.37 206.05C133.48 206.13 131.43 203.94 131.37 196.76V186.49C131.43 178.96 133.57 176.79 141.37 176.71H161.37V152.74C148.2 151.21 141.93 153.56 136.87 146.88 131.72 139.81 130.18 135.36 127.56 126.83 123.59 113.74 125.16 107.76 139.87 107.27 192.74 100.28 219.83 95.22 280.34 91.62 323.71 89.75 337.54 116.93 344.32 176.71H364.31C372.11 176.79 374.25 178.96 374.31 186.49V196.76C374.26 203.94 372.2 206.13 364.31 206.05H141.37Z';

const _body =
    'M168.51 343.13V265.33C148.66 265.29 141.53 261.95 141.59 245.27 141.49 229.83 148.12 226.32 168.51 226.67H326.59C340.4 226.44 344.3 230.44 344.21 245.27V300.06H352.15C357.08 300.09 358.48 302.73 358.4 312.79V378.86C358.45 388.42 356.66 390.68 351.06 390.6H236.54C228.94 390.93 226.77 387.76 226.75 375.92V361.24H182.22C171.34 361.19 168.15 357.48 168.51 343.13Z';

const _bodyInner =
    'M352.15 300.06H168.51V343.13C168.15 357.48 171.34 361.19 182.22 361.24H226.75V375.92C226.77 387.76 228.94 390.93 236.54 390.6H351.06C356.66 390.68 358.45 388.42 358.4 378.86V312.79C358.48 302.73 357.08 300.09 352.15 300.06Z';

const _bodyLines =
    'M168.51 300.06V265.33C148.66 265.29 141.53 261.95 141.59 245.27 141.49 229.83 148.12 226.32 168.51 226.67H326.6C340.4 226.44 344.3 230.44 344.21 245.27V300.06M168.51 300.06H344.21M168.51 300.06V343.13C168.15 357.48 171.34 361.19 182.22 361.24H226.75V375.92C226.77 387.76 228.94 390.93 236.54 390.6H351.06C356.66 390.68 358.45 388.42 358.4 378.86V312.79C358.48 302.73 357.08 300.09 352.15 300.06H344.21';

const _eyes = 'M265.91 251.12V275.1M303.1 251.12V275.1';

final _pathCache = <String, Path>{};

Path _path(String data) => _pathCache.putIfAbsent(data, () => _parseSvgPath(data));

/// Intérprete mínimo de `pathData` (M, L, H, V, C, Z en absoluto y relativo), suficiente para el isotipo.
Path _parseSvgPath(String data) {
  final path = Path();
  final tokens = RegExp(r'[MmLlHhVvCcZz]|-?(?:\d+\.?\d*|\.\d+)(?:[eE]-?\d+)?').allMatches(data).map((m) => m[0]!).toList();
  var i = 0;
  var x = 0.0, y = 0.0, startX = 0.0, startY = 0.0;
  String cmd = 'M';
  double num() => double.parse(tokens[i++]);
  while (i < tokens.length) {
    if (RegExp(r'[A-Za-z]').hasMatch(tokens[i])) cmd = tokens[i++];
    final rel = cmd == cmd.toLowerCase();
    switch (cmd.toUpperCase()) {
      case 'M':
        var nx = num(), ny = num();
        if (rel) {
          nx += x;
          ny += y;
        }
        path.moveTo(nx, ny);
        x = startX = nx;
        y = startY = ny;
        cmd = rel ? 'l' : 'L';
      case 'L':
        var nx = num(), ny = num();
        if (rel) {
          nx += x;
          ny += y;
        }
        path.lineTo(nx, ny);
        x = nx;
        y = ny;
      case 'H':
        final nx = rel ? x + num() : num();
        path.lineTo(nx, y);
        x = nx;
      case 'V':
        final ny = rel ? y + num() : num();
        path.lineTo(x, ny);
        y = ny;
      case 'C':
        final dx = rel ? x : 0.0, dy = rel ? y : 0.0;
        final x1 = num() + dx, y1 = num() + dy, x2 = num() + dx, y2 = num() + dy, ex = num() + dx, ey = num() + dy;
        path.cubicTo(x1, y1, x2, y2, ex, ey);
        x = ex;
        y = ey;
      case 'Z':
        path.close();
        x = startX;
        y = startY;
    }
  }
  return path;
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 500, size.height / 500);

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    Paint stroke(Color color, double width, {StrokeCap cap = StrokeCap.butt, StrokeJoin join = StrokeJoin.miter, double miter = 4}) =>
        Paint()
          ..style = PaintingStyle.stroke
          ..color = color
          ..strokeWidth = width
          ..strokeCap = cap
          ..strokeJoin = join
          ..strokeMiterLimit = miter
          ..isAntiAlias = true;

    canvas.drawPath(_path(_squircle), fill..color = atelierBlue);

    // Sombrero: relleno blanco con contorno redondeado (evenOdd) y encima la silueta azul.
    final hat = _path(_hat)..fillType = PathFillType.evenOdd;
    canvas.drawPath(hat, fill..color = Colors.white);
    canvas.drawPath(hat, stroke(Colors.white, 29.365, cap: StrokeCap.round, join: StrokeJoin.round, miter: 1.5));
    final hatInner = _path(_hatInner);
    canvas.drawPath(hatInner, fill..color = atelierBlue);
    canvas.drawPath(hatInner, stroke(atelierBlue, 0.978833));

    // Cuerpo.
    final body = _path(_body)..fillType = PathFillType.evenOdd;
    canvas.drawPath(body, fill..color = Colors.white);
    canvas.drawPath(body, stroke(Colors.white, 39.1533, cap: StrokeCap.round, join: StrokeJoin.round, miter: 1.5));
    final bodyInner = _path(_bodyInner);
    canvas.drawPath(bodyInner, fill..color = atelierBlue);
    canvas.drawPath(bodyInner, stroke(atelierBlue, 0.978833, join: StrokeJoin.round, miter: 10));
    canvas.drawPath(_path(_bodyLines), stroke(atelierBlue, 14.6825));
    canvas.drawPath(_path(_eyes), stroke(atelierBlue, 19.5767));

    canvas.restore();
  }

  @override
  bool shouldRepaint(_LogoPainter old) => false;
}
