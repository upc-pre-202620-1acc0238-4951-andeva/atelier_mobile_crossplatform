import 'package:flutter/widgets.dart';

/// Densidad táctil ambiental (DESIGN.md y segment-2-floor-counter):
/// - Estándar (mostrador, administración): 48 dp.
/// - Piso y fosa (`FloorHub`, `TaskDetail`, `DiagnosticsHub`, `LiveTelemetry`, `VehicleFaults`): 56 dp
///   provisto en la raíz de pantalla para manos con grasa o guantes.
///
/// Equivalente a `LocalAtelierMinTouchTarget`: `AtelierMinTouchTarget.of(context)`.
class AtelierMinTouchTarget extends InheritedWidget {
  final double value;

  const AtelierMinTouchTarget({super.key, this.value = standard, required super.child});

  static const double standard = 48;
  static const double floor = 56;

  static double of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AtelierMinTouchTarget>()?.value ?? standard;

  @override
  bool updateShouldNotify(AtelierMinTouchTarget oldWidget) => value != oldWidget.value;
}
