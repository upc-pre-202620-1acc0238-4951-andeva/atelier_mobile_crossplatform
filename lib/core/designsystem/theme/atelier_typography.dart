import 'package:flutter/material.dart';

/// Toda la interfaz. Satoshi trae 400, 500, 700 y 900: no hay 600 ni 800 (DESIGN.md → Typography).
const satoshiFamily = 'Satoshi';

/// Solo para el texto del imagotipo.
const albertSansFamily = 'AlbertSans';

// Cifras tabulares en todo: placas, montos y cronómetros se alinean sin fuente mono.
TextStyle _satoshi(FontWeight weight, double size, double line, [double tracking = 0]) {
  return TextStyle(
    fontFamily: satoshiFamily,
    fontWeight: weight,
    fontSize: size,
    height: line / size,
    letterSpacing: tracking * size,
    fontFeatures: const [FontFeature.tabularFigures()],
    leadingDistribution: TextLeadingDistribution.even,
  );
}

/// Escala de DESIGN.md sobre los roles de Material 3. Nada baja de 12.
final atelierTextTheme = TextTheme(
  displayLarge: _satoshi(FontWeight.w900, 48, 48, -0.02),
  displayMedium: _satoshi(FontWeight.w900, 48, 48, -0.02),
  displaySmall: _satoshi(FontWeight.w900, 48, 48, -0.02),
  headlineLarge: _satoshi(FontWeight.w900, 32, 40, -0.01),
  headlineMedium: _satoshi(FontWeight.w900, 28, 32, -0.01),
  headlineSmall: _satoshi(FontWeight.w900, 24, 32, -0.01),
  titleLarge: _satoshi(FontWeight.w900, 22, 28),
  titleMedium: _satoshi(FontWeight.w700, 16, 24),
  titleSmall: _satoshi(FontWeight.w700, 14, 20),
  bodyLarge: _satoshi(FontWeight.w400, 16, 24),
  bodyMedium: _satoshi(FontWeight.w400, 14, 20),
  bodySmall: _satoshi(FontWeight.w400, 12, 16),
  labelLarge: _satoshi(FontWeight.w700, 14, 20),
  labelMedium: _satoshi(FontWeight.w500, 12, 16, 0.01),
  labelSmall: _satoshi(FontWeight.w500, 12, 16, 0.01),
);
