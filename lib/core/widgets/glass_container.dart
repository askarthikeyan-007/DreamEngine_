import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dream_engine_ai/core/theme/cyber_theme.dart';

class GlassContainer extends StatefulWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color borderColor;
  final Color? cornerColor;
  final bool hasGlow;
  final bool showCorners;
  final bool showScanLine;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 6.0,
    this.opacity = 0.08,
    this.borderRadius = 16.0,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderColor = Colors.white24,
    this.cornerColor,
    this.hasGlow = false,
    this.showCorners = true,
    this.showScanLine = true, // Enabled by default to show off wow factor
  });

  @override
  State<GlassContainer> createState() => _GlassContainerState();
}

class _GlassContainerState extends State<GlassContainer> with SingleTickerProviderStateMixin {
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    if (widget.showScanLine) {
      _scanController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant GlassContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showScanLine && !_scanController.isAnimating) {
      _scanController.repeat();
    } else if (!widget.showScanLine && _scanController.isAnimating) {
      _scanController.stop();
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cColor = widget.cornerColor ?? widget.borderColor.withOpacity(0.7);
    final glowColor = widget.cornerColor ?? CyberTheme.neonBlue;

    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: widget.hasGlow
            ? [
                BoxShadow(
                  color: glowColor.withOpacity(0.18),
                  blurRadius: 24,
                  spreadRadius: -4,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Stack(
          children: [
            // Background blur + glass panel (isolated in RepaintBoundary to cache blurred texture)
            Positioned.fill(
              child: RepaintBoundary(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(widget.opacity),
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      border: Border.all(
                        color: widget.borderColor,
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Animated scanning gradient sweep
            if (widget.showScanLine)
              Positioned.fill(
                child: IgnorePointer(
                  child: RepaintBoundary(
                    child: AnimatedBuilder(
                      animation: _scanController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _ScanLinePainter(
                            progress: _scanController.value,
                            color: glowColor.withOpacity(0.2),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

            // Corner brackets overlay
            if (widget.showCorners)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: SciFiCornerPainter(
                      color: cColor,
                      borderRadius: widget.borderRadius,
                    ),
                  ),
                ),
              ),

            // Child Content
            Padding(
              padding: widget.padding ?? const EdgeInsets.all(16.0),
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanLinePainter extends CustomPainter {
  final double progress;
  final Color color;

  _ScanLinePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Top-to-bottom sweeping line position
    final double y = size.height * progress;
    final paint = Paint()
      ..shader = LinearGradient(
        colors: const [Colors.transparent, Colors.white10, Colors.transparent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTRB(0, y - 8, size.width, y + 8));

    // Sweeping laser lines
    canvas.drawRect(Rect.fromLTRB(0, y - 4, size.width, y + 4), paint);
    
    // Thin neon center line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
  }

  @override
  bool shouldRepaint(covariant _ScanLinePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class SciFiCornerPainter extends CustomPainter {
  final Color color;
  final double borderRadius;
  final double bracketLength;

  SciFiCornerPainter({
    required this.color,
    required this.borderRadius,
    this.bracketLength = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final double r = borderRadius;
    final double l = bracketLength;

    // Top-Left corner bracket
    final pathTL = Path()
      ..moveTo(0, r + l)
      ..lineTo(0, r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..lineTo(r + l, 0);
    canvas.drawPath(pathTL, paint);

    // Top-Right corner bracket
    final pathTR = Path()
      ..moveTo(size.width - r - l, 0)
      ..lineTo(size.width - r, 0)
      ..quadraticBezierTo(size.width, 0, size.width, r)
      ..lineTo(size.width, r + l);
    canvas.drawPath(pathTR, paint);

    // Bottom-Left corner bracket
    final pathBL = Path()
      ..moveTo(0, size.height - r - l)
      ..lineTo(0, size.height - r)
      ..quadraticBezierTo(0, size.height, r, size.height)
      ..lineTo(r + l, size.height);
    canvas.drawPath(pathBL, paint);

    // Bottom-Right corner bracket
    final pathBR = Path()
      ..moveTo(size.width - r - l, size.height)
      ..lineTo(size.width - r, size.height)
      ..quadraticBezierTo(size.width, size.height, size.width, size.height - r)
      ..lineTo(size.width, size.height - r - l);
    canvas.drawPath(pathBR, paint);
  }

  @override
  bool shouldRepaint(covariant SciFiCornerPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.bracketLength != bracketLength;
  }
}
