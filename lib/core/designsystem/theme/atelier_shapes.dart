import 'package:flutter/material.dart';

/// Familia de formas de esquina redondeada (DESIGN.md → Shapes).
const plateRadius = BorderRadius.all(Radius.circular(6));
const controlRadius = BorderRadius.all(Radius.circular(12));
const panelRadius = BorderRadius.all(Radius.circular(16));
const cardLargeRadius = BorderRadius.all(Radius.circular(18));
const heroRadius = BorderRadius.all(Radius.circular(20));
const sheetTopRadius = BorderRadius.vertical(top: Radius.circular(24));

/// Única excepción a "sin píldoras": la barra inferior flotante y su botón de acción.
const floatingBarRadius = BorderRadius.all(Radius.circular(999));

const cardRadius = controlRadius;
const fieldRadius = controlRadius;

/// Marca de estado: a 28 de alto, 12 de radio se leería como píldora.
const chipRadius = plateRadius;

const plateShape = RoundedRectangleBorder(borderRadius: plateRadius);
const controlShape = RoundedRectangleBorder(borderRadius: controlRadius);
const panelShape = RoundedRectangleBorder(borderRadius: panelRadius);
const cardLargeShape = RoundedRectangleBorder(borderRadius: cardLargeRadius);
const heroShape = RoundedRectangleBorder(borderRadius: heroRadius);
const sheetTopShape = RoundedRectangleBorder(borderRadius: sheetTopRadius);
const floatingBarShape = StadiumBorder();

/// Módulo de 8; 4 solo dentro de un componente.
abstract final class Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}
