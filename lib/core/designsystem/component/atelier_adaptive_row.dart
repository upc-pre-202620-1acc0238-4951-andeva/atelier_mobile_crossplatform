import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Contenedor adaptable por medición intrínseca de ancho: coloca los hijos en fila horizontal con
/// [horizontalSpacing] cuando sus anchos máximos intrínsecos caben dentro del ancho disponible; cuando
/// exceden (pantallas compactas de 320–360 dp, textos largos en español o escala de fuente 1.3) los apila
/// verticalmente con [verticalSpacing] a ancho completo, sin recortar ni depender de umbrales mágicos.
///
/// Los hijos deben soportar medición intrínseca (evitar `LayoutBuilder`).
class AtelierAdaptiveRow extends MultiChildRenderObjectWidget {
  final double horizontalSpacing;
  final double verticalSpacing;
  final bool equalWidthInRow;

  const AtelierAdaptiveRow({
    super.key,
    this.horizontalSpacing = 8,
    this.verticalSpacing = 8,
    this.equalWidthInRow = false,
    super.children,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => RenderAtelierAdaptiveRow(horizontalSpacing, verticalSpacing, equalWidthInRow);

  @override
  void updateRenderObject(BuildContext context, RenderAtelierAdaptiveRow renderObject) {
    renderObject
      ..horizontalSpacing = horizontalSpacing
      ..verticalSpacing = verticalSpacing
      ..equalWidthInRow = equalWidthInRow;
  }
}

class AtelierAdaptiveRowParentData extends ContainerBoxParentData<RenderBox> {}

class RenderAtelierAdaptiveRow extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, AtelierAdaptiveRowParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, AtelierAdaptiveRowParentData> {
  RenderAtelierAdaptiveRow(this._horizontalSpacing, this._verticalSpacing, this._equalWidthInRow);

  double _horizontalSpacing;
  double _verticalSpacing;
  bool _equalWidthInRow;

  set horizontalSpacing(double v) {
    if (v == _horizontalSpacing) return;
    _horizontalSpacing = v;
    markNeedsLayout();
  }

  set verticalSpacing(double v) {
    if (v == _verticalSpacing) return;
    _verticalSpacing = v;
    markNeedsLayout();
  }

  set equalWidthInRow(bool v) {
    if (v == _equalWidthInRow) return;
    _equalWidthInRow = v;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! AtelierAdaptiveRowParentData) child.parentData = AtelierAdaptiveRowParentData();
  }

  List<RenderBox> get _children {
    final list = <RenderBox>[];
    var child = firstChild;
    while (child != null) {
      list.add(child);
      child = childAfter(child);
    }
    return list;
  }

  /// Misma lógica para el layout real y el seco: [measure] mide cada hijo con las restricciones dadas.
  (Size, List<Offset>) _plan(BoxConstraints constraints, Size Function(RenderBox child, BoxConstraints c) measure) {
    final children = _children;
    if (children.isEmpty) {
      return (constraints.constrain(Size(constraints.minWidth, constraints.minHeight)), const []);
    }
    final hGap = _horizontalSpacing;
    final vGap = _verticalSpacing;
    final maxWidth = constraints.maxWidth;
    final totalIntrinsic = children.fold<double>(0, (s, c) => s + c.getMaxIntrinsicWidth(constraints.maxHeight)) +
        hGap * (children.length - 1);
    final fits = maxWidth.isFinite && totalIntrinsic <= maxWidth;

    if (fits) {
      final BoxConstraints itemConstraints;
      if (_equalWidthInRow) {
        final cell = math.max(0.0, (maxWidth - hGap * (children.length - 1)) / children.length);
        itemConstraints = BoxConstraints(
          minWidth: cell,
          maxWidth: cell,
          maxHeight: constraints.maxHeight,
        );
      } else {
        itemConstraints = BoxConstraints(maxWidth: constraints.maxWidth, maxHeight: constraints.maxHeight);
      }
      final sizes = [for (final c in children) measure(c, itemConstraints)];
      final height = constraints.constrainHeight(sizes.fold<double>(0, (m, s) => math.max(m, s.height)));
      final width = _equalWidthInRow
          ? maxWidth
          : constraints.constrainWidth(sizes.fold<double>(0, (s, e) => s + e.width) + hGap * (sizes.length - 1));
      var x = 0.0;
      final offsets = <Offset>[];
      for (final s in sizes) {
        offsets.add(Offset(x, (height - s.height) / 2));
        x += s.width + hGap;
      }
      return (Size(width, height), offsets);
    }

    final childConstraints = BoxConstraints(
      minWidth: maxWidth.isFinite ? maxWidth : constraints.minWidth,
      maxWidth: maxWidth,
      maxHeight: constraints.maxHeight,
    );
    final sizes = [for (final c in children) measure(c, childConstraints)];
    final height = constraints.constrainHeight(sizes.fold<double>(0, (s, e) => s + e.height) + vGap * (sizes.length - 1));
    final width = constraints.constrainWidth(sizes.fold<double>(0, (m, s) => math.max(m, s.width)));
    var y = 0.0;
    final offsets = <Offset>[];
    for (final s in sizes) {
      offsets.add(Offset(0, y));
      y += s.height + vGap;
    }
    return (Size(width, height), offsets);
  }

  @override
  void performLayout() {
    final (size, offsets) = _plan(constraints, (child, c) {
      child.layout(c, parentUsesSize: true);
      return child.size;
    });
    this.size = size;
    final children = _children;
    for (var i = 0; i < children.length; i++) {
      (children[i].parentData! as AtelierAdaptiveRowParentData).offset = offsets[i];
    }
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => _plan(constraints, (c, k) => c.getDryLayout(k)).$1;

  @override
  double computeMinIntrinsicWidth(double height) =>
      _children.fold<double>(0, (m, c) => math.max(m, c.getMinIntrinsicWidth(height)));

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _children.fold<double>(0, (s, c) => s + c.getMaxIntrinsicWidth(height)) +
      _horizontalSpacing * math.max(0, childCount - 1);

  @override
  double computeMinIntrinsicHeight(double width) => getDryLayout(BoxConstraints(maxWidth: width)).height;

  @override
  double computeMaxIntrinsicHeight(double width) => getDryLayout(BoxConstraints(maxWidth: width)).height;

  @override
  void paint(PaintingContext context, Offset offset) => defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
