import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_colors.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/inventory_navigation.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/scanner/sku_scanner_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/scanner/sku_scanner_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

/// Escáner real de SKU con la cámara (`mobile_scanner`: CameraX + ML Kit en Android, AVFoundation en iOS) y
/// entrada manual siempre disponible. En iOS está sin comprobar: no se ejecutó en una Mac.
class SkuScannerScreen extends StatefulWidget {
  const SkuScannerScreen({super.key});

  @override
  State<SkuScannerScreen> createState() => _SkuScannerScreenState();
}

class _SkuScannerScreenState extends State<SkuScannerScreen> {
  late final SkuScannerViewModel viewModel = getIt<SkuScannerViewModel>();
  bool _hasCameraPermission = false;
  bool _navigating = false;
  bool _lastFailure = false;

  @override
  void initState() {
    super.initState();
    viewModel.addListener(_onState);
    _checkCamera();
  }

  Future<void> _checkCamera() async {
    var status = await ph.Permission.camera.status;
    if (!status.isGranted && viewModel.state.canRead) {
      status = await ph.Permission.camera.request();
    }
    if (mounted) setState(() => _hasCameraPermission = status.isGranted);
  }

  Future<void> _requestCamera() async {
    final status = await ph.Permission.camera.request();
    if (mounted) setState(() => _hasCameraPermission = status.isGranted);
  }

  void _onState() {
    final state = viewModel.state;
    final haptics = rememberAtelierHaptics();
    final partId = state.foundPartId;
    if (partId != null && !_navigating) {
      _navigating = true;
      haptics.confirm();
      viewModel.onPartNavigated();
      // `popUpTo<SkuScannerRoute> { inclusive = true }`: el detalle reemplaza al escáner.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) AppNavigator.pushReplacement(context, AppRoute.partDetail, partId);
      });
    }
    if (state.hasFailure && !_lastFailure) haptics.reject();
    _lastFailure = state.hasFailure;
  }

  @override
  void dispose() {
    viewModel.removeListener(_onState);
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => SkuScannerContent(
        state: viewModel.state,
        hasCameraPermission: _hasCameraPermission,
        onBack: inventoryBack(context),
        onRequestPermission: _requestCamera,
        onBarcodeDetected: viewModel.onBarcodeDetected,
        onManualSkuChange: viewModel.onManualSkuChange,
        onSubmitManualSku: viewModel.onSubmitManualSku,
        onResetScan: viewModel.onResetScan,
      ),
    );
  }
}

class SkuScannerContent extends StatelessWidget {
  final SkuScannerUiState state;
  final bool hasCameraPermission;
  final VoidCallback onBack;
  final VoidCallback onRequestPermission;
  final ValueChanged<String> onBarcodeDetected;
  final ValueChanged<String> onManualSkuChange;
  final VoidCallback onSubmitManualSku;
  final VoidCallback onResetScan;

  /// Solo pruebas: sustituye a la cámara real.
  final Widget Function(ValueChanged<String> onDetect)? cameraBuilder;

  const SkuScannerContent({
    super.key,
    required this.state,
    required this.hasCameraPermission,
    required this.onBack,
    required this.onRequestPermission,
    required this.onBarcodeDetected,
    required this.onManualSkuChange,
    required this.onSubmitManualSku,
    required this.onResetScan,
    this.cameraBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    return Scaffold(
      backgroundColor: context.scheme.surface,
      body: Column(
        children: [
          AtelierTopBar(title: strings.invSeg2ScannerTitle, onBack: onBack),
          if (!state.canRead)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AtelierNoPermissionState(text: strings.invSeg2ScannerNoPermission),
            )
          else ...[
            AtelierRefreshBar(visible: state.isSearching),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Spacing.md,
                  children: [
                    if (hasCameraPermission) ...[
                      SizedBox(
                        height: 300,
                        child: _BarcodeCameraViewport(
                          onBarcodeDetected: onBarcodeDetected,
                          cameraBuilder: cameraBuilder,
                        ),
                      ),
                      Text(
                        strings.invSeg2ScannerHint,
                        style: context.text.bodyMedium?.copyWith(color: colors.inkSecondary),
                      ),
                    ] else
                      _CameraPermissionCard(onRequestPermission: onRequestPermission),
                    if (state.notFoundSku case final sku?)
                      AtelierBanner(
                        message: strings.invSeg2ScannerNotFound(sku),
                        icon: Icons.error_outline,
                        kind: BannerKind.wait,
                      ),
                    if (state.invalidSku case final sku?)
                      AtelierBanner(
                        message: strings.invSeg2ScannerInvalidSku(sku),
                        icon: Icons.error_outline,
                        kind: BannerKind.bad,
                      ),
                    if (state.error case final error?)
                      AtelierBanner(
                        message: error.asString(strings),
                        icon: Icons.error_outline,
                        kind: BannerKind.bad,
                      ),
                    if (state.hasFailure)
                      AtelierButton(
                        text: strings.invSeg2ScannerRetry,
                        onClick: onResetScan,
                        style: AtelierButtonStyle.outlined,
                        icon: Icons.qr_code_scanner,
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                Spacing.md,
                Spacing.sm,
                Spacing.md,
                Spacing.sm + MediaQuery.viewPaddingOf(context).bottom,
              ),
              child: AtelierSurface(
                tier: SurfaceTier.floating,
                shape: heroShape,
                contentPadding: const EdgeInsets.all(Spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Spacing.sm,
                  children: [
                    AtelierTextField(
                      label: strings.invSeg2ScannerManualLabel,
                      value: state.manualSku,
                      onValueChange: onManualSkuChange,
                      leadingIcon: Icons.search,
                      placeholder: strings.invSeg2ScannerManualHint,
                      enabled: !state.isSearching,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.search,
                      onSubmitted: onSubmitManualSku,
                    ),
                    AtelierButton(
                      text: strings.invSeg2ScannerSearchBtn,
                      onClick: onSubmitManualSku,
                      enabled: state.manualSku.trim().isNotEmpty,
                      loading: state.isSearching,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CameraPermissionCard extends StatelessWidget {
  final VoidCallback onRequestPermission;

  const _CameraPermissionCard({required this.onRequestPermission});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AtelierSurface(
      tier: SurfaceTier.card,
      shape: cardLargeShape,
      contentPadding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Icon(Icons.camera_alt_outlined, size: 32, color: context.atelier.primaryText),
          Text(
            strings.invSeg2ScannerPermissionTitle,
            style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
          ),
          Text(
            strings.invSeg2ScannerPermissionBody,
            style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary),
          ),
          AtelierButton(
            text: strings.invSeg2ScannerPermissionGrant,
            onClick: onRequestPermission,
            style: AtelierButtonStyle.tonal,
          ),
        ],
      ),
    );
  }
}

class _BarcodeCameraViewport extends StatefulWidget {
  final ValueChanged<String> onBarcodeDetected;
  final Widget Function(ValueChanged<String> onDetect)? cameraBuilder;

  const _BarcodeCameraViewport({required this.onBarcodeDetected, this.cameraBuilder});

  @override
  State<_BarcodeCameraViewport> createState() => _BarcodeCameraViewportState();
}

class _BarcodeCameraViewportState extends State<_BarcodeCameraViewport> {
  MobileScannerController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.cameraBuilder == null) _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue?.trim();
      if (raw != null && raw.isNotEmpty) {
        widget.onBarcodeDetected(raw);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final builder = widget.cameraBuilder;
    return ClipRRect(
      borderRadius: panelRadius,
      child: ColoredBox(
        color: context.scheme.surfaceContainerHighest,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (builder != null)
              builder(widget.onBarcodeDetected)
            else
              MobileScanner(
                controller: _controller,
                onDetect: _onDetect,
                errorBuilder: (context, error) => const SizedBox.shrink(),
              ),
            const PrecisionReticleOverlay(),
          ],
        ),
      ),
    );
  }
}

/// Retícula de precisión para lectura de códigos de barras/QR: velo oscuro fuera de la zona de lectura,
/// esquinas redondeadas en `#69B1FF`/`#FFFFFF` y haz de escaneo animado (quieto si el sistema quita animaciones).
class PrecisionReticleOverlay extends StatefulWidget {
  const PrecisionReticleOverlay({super.key});

  @override
  State<PrecisionReticleOverlay> createState() => _PrecisionReticleOverlayState();
}

class _PrecisionReticleOverlayState extends State<PrecisionReticleOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  late final Animation<double> _progress = CurvedAnimation(parent: _controller, curve: easeOutQuint);
  bool _reduced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = rememberReducedMotion(context);
    if (reduced == _reduced && _controller.isAnimating) return;
    _reduced = reduced;
    if (reduced) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _progress,
        builder: (context, _) => CustomPaint(
          painter: _ReticlePainter(scanProgress: _reduced ? 0.5 : _progress.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _ReticlePainter extends CustomPainter {
  final double scanProgress;

  const _ReticlePainter({required this.scanProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final reticleW = size.width * 0.78;
    final reticleH = (size.height * 0.52).clamp(0.0, 136.0);
    final left = (size.width - reticleW) / 2;
    final top = (size.height - reticleH) / 2;
    final right = left + reticleW;
    final bottom = top + reticleH;
    const cornerRadius = 14.0;
    const bracketArm = 22.0;
    final rect = Rect.fromLTRB(left, top, right, bottom);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(cornerRadius));

    // Velo oscuro sutil fuera del área de lectura.
    final veil = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(veil, Paint()..color = const Color(0x85000000));

    // Borde guía sutil dentro del visor.
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0x38FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Esquinas redondeadas de precisión en #69B1FF + acento blanco.
    final corners = Path()
      ..moveTo(left, top + bracketArm)
      ..lineTo(left, top + cornerRadius)
      ..quadraticBezierTo(left, top, left + cornerRadius, top)
      ..lineTo(left + bracketArm, top)
      ..moveTo(right - bracketArm, top)
      ..lineTo(right - cornerRadius, top)
      ..quadraticBezierTo(right, top, right, top + cornerRadius)
      ..lineTo(right, top + bracketArm)
      ..moveTo(right, bottom - bracketArm)
      ..lineTo(right, bottom - cornerRadius)
      ..quadraticBezierTo(right, bottom, right - cornerRadius, bottom)
      ..lineTo(right - bracketArm, bottom)
      ..moveTo(left + bracketArm, bottom)
      ..lineTo(left + cornerRadius, bottom)
      ..quadraticBezierTo(left, bottom, left, bottom - cornerRadius)
      ..lineTo(left, bottom - bracketArm);
    canvas.drawPath(
      corners,
      Paint()
        ..color = atelierBlueSoft
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      corners,
      Paint()
        ..color = const Color(0xA6FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.25
        ..strokeCap = StrokeCap.round,
    );

    // Línea de escaneo suave animada.
    const lineInset = 10.0;
    const glowHalfHeight = 10.0;
    final scanY = (top + lineInset) + (reticleH - lineInset * 2) * scanProgress;
    final glowRect = Rect.fromLTWH(
      left + lineInset,
      scanY - glowHalfHeight,
      reticleW - lineInset * 2,
      glowHalfHeight * 2,
    );
    canvas.drawRect(
      glowRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0x00000000),
            atelierBlueSoft.withValues(alpha: 0.24),
            const Color(0x00000000),
          ],
        ).createShader(glowRect),
    );
    final lineStart = Offset(left + lineInset, scanY);
    final lineEnd = Offset(right - lineInset, scanY);
    canvas.drawLine(
      lineStart,
      lineEnd,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0x00000000), atelierBlueSoft, Color(0xFFFFFFFF), atelierBlueSoft, Color(0x00000000)],
        ).createShader(Rect.fromPoints(lineStart, lineEnd + const Offset(0, 1)))
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ReticlePainter oldDelegate) => oldDelegate.scanProgress != scanProgress;
}
