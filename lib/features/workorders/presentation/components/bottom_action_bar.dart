import 'package:flutter/material.dart';

/// Barra de acciones al pie de un formulario (`bottomBar` del `Scaffold` de Android): fondo del lienzo y
/// márgenes 16 / 8 / 16 / 16. Va dentro del cuerpo para que suba con el teclado (`imePadding`).
class WorkOrderBottomBar extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const WorkOrderBottomBar({super.key, required this.children, this.spacing = 8});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: spacing,
            children: children,
          ),
        ),
      ),
    );
  }
}
