import 'package:flutter/material.dart';

/// Marca (docs/branding/pallette.txt). Cada color dice una sola cosa: DESIGN.md → La Regla del Código Vial.
const atelierBlue = Color(0xFF0071EB);
const atelierBlueDark = Color(0xFF031A6B);
const atelierBlueSoft = Color(0xFF69B1FF);
const atelierAccent = Color(0xFFF68B01);
const atelierAmberDark = Color(0xFFD87900);
const atelierAmberSoft = Color(0xFFFFCD69);
const atelierSuccess = Color(0xFF3AC530);
const atelierError = Color(0xFFFB2C36);
const atelierWarning = Color(0xFFF0B100);
const atelierInk = Color(0xFF262626);

/// Neutros de marca.
const atelierSurfaceLight = Color(0xFFF8F8FA);
const atelierSurfaceDark = Color(0xFF262626);
const atelierCardLight = Color(0xFFFFFFFF);
const atelierCardDark = Color(0xFF272727);
const atelierBorderLight = Color(0xFFC6C6C6);
const atelierBorderDark = Color(0xFFEBEBEB);

/// Roles que Material 3 no tiene (`AtelierColors` de Android). Acceso: `context.atelier.ok`.
@immutable
class AtelierColors extends ThemeExtension<AtelierColors> {
  final Color card;
  final Color cardHigh;
  final Color outlineSoft;
  final Color inkSecondary;
  final Color muted;
  final Color primaryText;
  final Color ok;
  final Color okContainer;
  final Color wait;
  final Color waitContainer;
  final Color bad;
  final Color badContainer;
  final Color info;
  final Color infoContainer;
  final Color idle;
  final Color idleContainer;
  final Color warn;
  final Color warnContainer;
  final Color fab;
  final Color onFab;
  final Color bone;
  final Color panel;
  final Color onPanel;
  final Color boneOnPanel;
  final Color decision;
  final Color decisionPressed;
  final Color decisionSoft;
  final Color onDecision;
  final Color plate;
  final Color onPlate;
  final Color okMark;
  final Color badMark;
  final Color warnMark;
  final bool isDark;
  final Color surfaceRecessed;
  final Color surfaceElevated;
  final Color surfaceFloating;
  final Color specularTop;
  final Color specularBottom;
  final Color shadowAmbient;
  final Color shadowSpot;
  final Color heroStart;
  final Color heroMid;
  final Color heroEnd;
  final Color heroSpecular;
  final Color buttonTop;
  final Color buttonBottom;
  final Color destructiveTop;
  final Color destructiveBottom;
  final Color plateBase;
  final Color decisionSurface;
  final Color decisionWash;
  final Color decisionBorder;
  final Color decisionAccent;
  final Color primaryGlow;

  const AtelierColors({
    required this.card,
    required this.cardHigh,
    required this.outlineSoft,
    required this.inkSecondary,
    required this.muted,
    required this.primaryText,
    required this.ok,
    required this.okContainer,
    required this.wait,
    required this.waitContainer,
    required this.bad,
    required this.badContainer,
    required this.info,
    required this.infoContainer,
    required this.idle,
    required this.idleContainer,
    required this.warn,
    required this.warnContainer,
    required this.fab,
    required this.onFab,
    required this.bone,
    this.panel = atelierBlue,
    this.onPanel = Colors.white,
    this.boneOnPanel = const Color(0x3DFFFFFF),
    this.decision = atelierAccent,
    this.decisionPressed = atelierAmberDark,
    this.decisionSoft = atelierAmberSoft,
    this.onDecision = atelierInk,
    this.plate = Colors.white,
    this.onPlate = atelierInk,
    this.okMark = atelierSuccess,
    this.badMark = atelierError,
    this.warnMark = atelierWarning,
    this.isDark = false,
    this.surfaceRecessed = const Color(0xFFECEFF4),
    this.surfaceElevated = Colors.white,
    this.surfaceFloating = Colors.white,
    required this.specularTop,
    required this.specularBottom,
    required this.shadowAmbient,
    required this.shadowSpot,
    this.heroStart = atelierBlueDark,
    this.heroMid = const Color(0xFF08349C),
    this.heroEnd = atelierBlue,
    this.heroSpecular = const Color(0x4D69B1FF),
    this.buttonTop = const Color(0xFF0E7FF5),
    this.buttonBottom = const Color(0xFF0062D1),
    this.destructiveTop = const Color(0xFFFF3B45),
    this.destructiveBottom = const Color(0xFFD91E29),
    this.plateBase = const Color(0xFFF1F3F7),
    this.decisionSurface = const Color(0xFFFFFBF4),
    required this.decisionWash,
    required this.decisionBorder,
    required this.decisionAccent,
    this.primaryGlow = const Color(0x3D0071EB),
  });

  @override
  AtelierColors copyWith() => this;

  /// Los dos esquemas son fijos: al animar el cambio de tema se cambia de uno a otro.
  @override
  AtelierColors lerp(ThemeExtension<AtelierColors>? other, double t) {
    if (other is! AtelierColors) return this;
    return t < 0.5 ? this : other;
  }
}

// Color.withValues(alpha:) no es const: los valores con alfa se precalculan.
final darkAtelierColors = AtelierColors(
  card: atelierCardDark,
  cardHigh: const Color(0xFF333333),
  outlineSoft: atelierBorderDark.withValues(alpha: 0.12),
  inkSecondary: atelierBorderLight,
  muted: const Color(0xFFA3A3A3),
  primaryText: atelierBlueSoft,
  ok: atelierSuccess,
  okContainer: const Color(0x293AC530),
  wait: atelierAmberSoft,
  waitContainer: const Color(0x33F68B01),
  bad: const Color(0xFFFF6B76),
  badContainer: const Color(0x38FB2C36),
  info: atelierBlueSoft,
  infoContainer: const Color(0x3D0071EB),
  idle: atelierBorderLight,
  idleContainer: const Color(0x14FFFFFF),
  warn: atelierWarning,
  warnContainer: const Color(0x29F0B100),
  fab: atelierBlueSoft,
  onFab: atelierBlueDark,
  bone: const Color(0x1FFFFFFF),
  isDark: true,
  surfaceRecessed: const Color(0xFF1C1D20),
  surfaceElevated: const Color(0xFF2F3136),
  surfaceFloating: const Color(0xFF33363C),
  specularTop: atelierBorderDark.withValues(alpha: 0.18),
  specularBottom: atelierBorderDark.withValues(alpha: 0.05),
  shadowAmbient: Colors.black.withValues(alpha: 0.55),
  shadowSpot: Colors.black.withValues(alpha: 0.70),
  decisionSurface: const Color(0xFF2D2924),
  decisionWash: atelierAccent.withValues(alpha: 0.14),
  decisionBorder: atelierAmberSoft.withValues(alpha: 0.32),
  decisionAccent: atelierAmberSoft,
);

final lightAtelierColors = AtelierColors(
  card: atelierCardLight,
  cardHigh: const Color(0xFFEEF0F4),
  outlineSoft: const Color(0xFFE5E8EE),
  inkSecondary: const Color(0xFF454B55),
  muted: const Color(0xFF5B6676),
  primaryText: const Color(0xFF005DC2),
  ok: const Color(0xFF00702B),
  okContainer: const Color(0xFFD9F7E4),
  wait: const Color(0xFF9A5300),
  waitContainer: const Color(0xFFFFF0D9),
  bad: const Color(0xFFB3101D),
  badContainer: const Color(0xFFFDE3E5),
  info: const Color(0xFF005DC2),
  infoContainer: const Color(0xFFDCEBFF),
  idle: const Color(0xFF4B5361),
  idleContainer: const Color(0xFFECEEF2),
  warn: const Color(0xFF9A5300),
  warnContainer: const Color(0xFFFFF4CC),
  fab: atelierBlueDark,
  onFab: Colors.white,
  bone: const Color(0x14262626),
  isDark: false,
  specularTop: Colors.white.withValues(alpha: 0.90),
  specularBottom: atelierBorderLight.withValues(alpha: 0.38),
  shadowAmbient: atelierBlueDark.withValues(alpha: 0.14),
  shadowSpot: atelierBlueDark.withValues(alpha: 0.20),
  decisionWash: atelierAccent.withValues(alpha: 0.08),
  decisionBorder: atelierAccent.withValues(alpha: 0.38),
  decisionAccent: atelierAmberDark,
);
