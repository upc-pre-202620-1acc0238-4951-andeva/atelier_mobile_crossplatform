import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:flutter/material.dart';

/// El esqueleto espera 150 ms antes de aparecer: si los datos llegan antes, no se muestra (DESIGN.md → Carga).
/// Úsalo con `isLoading && noHayCaché`; con caché se pinta Drift y basta `AtelierRefreshBar`.
///
/// Equivalente a `rememberDelayedLoading(loading)`: entrega `show` al [builder].
class DelayedLoading extends StatefulWidget {
  final bool loading;
  final Widget Function(BuildContext context, bool show) builder;

  const DelayedLoading({super.key, required this.loading, required this.builder});

  @override
  State<DelayedLoading> createState() => _DelayedLoadingState();
}

class _DelayedLoadingState extends State<DelayedLoading> {
  bool _show = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(DelayedLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.loading != widget.loading) _sync();
  }

  void _sync() {
    _timer?.cancel();
    if (widget.loading) {
      _timer = Timer(const Duration(milliseconds: 150), () {
        if (mounted) setState(() => _show = true);
      });
    } else {
      _show = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _show && widget.loading);
}

/// Pinta este dato como un hueso mientras [loading]: mismo tamaño y márgenes que el contenido real, así al
/// llegar los datos nada se mueve. Se aplica a cada hoja de datos (texto, cifra, placa, foto) de un layout
/// renderizado con un `UiState` de muestra; lo fijo (títulos, barras, FAB) se deja sin hueso.
///
/// [widthFraction] entre 0.4 y 0.8 del ancho de la línea. Late en opacidad (1 → 0.55, 1.2 s), sin barrido;
/// con "quitar animaciones" queda fijo. Los huesos no existen para el lector de pantalla: el contenedor
/// anuncia la carga.
class Bone extends StatelessWidget {
  final bool loading;
  final bool onPanel;
  final double widthFraction;
  final Widget child;

  const Bone({
    super.key,
    required this.loading,
    this.onPanel = false,
    this.widthFraction = 1,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!loading) return child;
    return _BoneLoading(onPanel: onPanel, widthFraction: widthFraction, child: child);
  }
}

class _BoneLoading extends StatefulWidget {
  final bool onPanel;
  final double widthFraction;
  final Widget child;

  const _BoneLoading({required this.onPanel, required this.widthFraction, required this.child});

  @override
  State<_BoneLoading> createState() => _BoneLoadingState();
}

class _BoneLoadingState extends State<_BoneLoading> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;
  bool _reduced = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _pulse = Tween<double>(begin: 1, end: 0.55).animate(CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = rememberReducedMotion(context);
    if (reduced != _reduced || !_controller.isAnimating) {
      _reduced = reduced;
      if (reduced) {
        _controller.stop();
        _controller.value = 0;
      } else {
        _controller.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.atelier;
    final color = widget.onPanel ? colors.boneOnPanel : colors.bone;
    return ExcludeSemantics(
      child: CustomPaint(
        foregroundPainter: _BonePainter(
          color: color,
          widthFraction: widget.widthFraction,
          pulse: _pulse,
        ),
        // El contenido se mide pero no se pinta (drawWithContent sin drawContent en Compose).
        child: Opacity(opacity: 0, child: widget.child),
      ),
    );
  }
}

class _BonePainter extends CustomPainter {
  final Color color;
  final double widthFraction;
  final Animation<double> pulse;

  _BonePainter({required this.color, required this.widthFraction, required this.pulse}) : super(repaint: pulse);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: color.a * pulse.value);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width * widthFraction, size.height), const Radius.circular(6)),
      paint,
    );
  }

  @override
  bool shouldRepaint(_BonePainter old) => old.color != color || old.widthFraction != widthFraction;
}
