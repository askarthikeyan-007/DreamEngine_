import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dream_engine_ai/core/theme/cyber_theme.dart';

class ParticleBackground extends StatefulWidget {
  final Widget? child;
  const ParticleBackground({super.key, this.child});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final List<CodeDrop> _codeDrops = [];
  final Random _random = Random();
  final Map<String, TextPainter> _textPainterCache = {};

  Offset _mousePosition = Offset.zero;
  bool _hasMouse = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Initialize particles
    for (int i = 0; i < 20; i++) {
      _particles.add(Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        vx: (_random.nextDouble() - 0.5) * 0.0016,
        vy: (_random.nextDouble() - 0.5) * 0.0016,
        radius: _random.nextDouble() * 2.2 + 1.2,
        color: _random.nextBool() ? CyberTheme.neonBlue : CyberTheme.electricPurple,
      ));
    }

    // Initialize code rain drops
    final String chars = "0123456789ABCDEF<>/\\@#*%&";
    for (int i = 0; i < 12; i++) {
      _codeDrops.add(CodeDrop(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: 0.002 + _random.nextDouble() * 0.004,
        opacity: 0.04 + _random.nextDouble() * 0.12,
        characters: List.generate(
          4 + _random.nextInt(4),
          (_) => chars[_random.nextInt(chars.length)],
        ),
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return MouseRegion(
          onHover: (event) {
            setState(() {
              _mousePosition = event.localPosition;
              _hasMouse = true;
            });
          },
          onExit: (_) {
            setState(() {
              _hasMouse = false;
            });
          },
          child: Stack(
            children: [
              // Deep background color
              Container(color: CyberTheme.darkMetallic),

              // Custom Painter for grid, rain, particles
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  // Update code rain and particles
                  for (var drop in _codeDrops) {
                    drop.update();
                  }
                  for (var p in _particles) {
                    p.update(
                      mousePos: _hasMouse ? _mousePosition : null,
                      size: size,
                    );
                  }

                  return RepaintBoundary(
                    child: CustomPaint(
                      painter: SciFiBackgroundPainter(
                        particles: _particles,
                        codeDrops: _codeDrops,
                        mousePosition: _mousePosition,
                        hasMouse: _hasMouse,
                        animationValue: _controller.value,
                        textPainterCache: _textPainterCache,
                      ),
                      child: Container(),
                    ),
                  );
                },
              ),

              // Scanner lines overlay
              const Positioned.fill(child: ScannerLinesWidget()),

              if (widget.child != null) widget.child!,
            ],
          ),
        );
      },
    );
  }
}

class Particle {
  double x; // normalized 0.0 to 1.0
  double y; // normalized 0.0 to 1.0
  double vx;
  double vy;
  double radius;
  Color color;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.color,
  });

  void update({Offset? mousePos, Size? size}) {
    x += vx;
    y += vy;

    // Bounce off edges
    if (x < 0 || x > 1) vx = -vx;
    if (y < 0 || y > 1) vy = -vy;

    // Gentle attraction to the cursor if hovering
    if (mousePos != null && size != null) {
      final px = x * size.width;
      final py = y * size.height;
      final dx = mousePos.dx - px;
      final dy = mousePos.dy - py;
      final dist = sqrt(dx * dx + dy * dy);

      if (dist < 200) {
        final double pullForce = (200 - dist) / 200 * 0.00015;
        vx += (dx / dist) * pullForce;
        vy += (dy / dist) * pullForce;

        // Friction / drag cap
        final double speed = sqrt(vx * vx + vy * vy);
        const double maxSpeed = 0.0025;
        if (speed > maxSpeed) {
          vx = (vx / speed) * maxSpeed;
          vy = (vy / speed) * maxSpeed;
        }
      }
    }

    x = x.clamp(0.0, 1.0);
    y = y.clamp(0.0, 1.0);
  }
}

class CodeDrop {
  double x; // normalized 0.0 to 1.0
  double y; // normalized 0.0 to 1.0
  double speed;
  double opacity;
  List<String> characters;

  CodeDrop({
    required this.x,
    required this.y,
    required this.speed,
    required this.opacity,
    required this.characters,
  });

  void update() {
    y += speed;
    if (y > 1.0) {
      y = -0.15;
      final Random r = Random();
      speed = 0.002 + r.nextDouble() * 0.005;
      opacity = 0.04 + r.nextDouble() * 0.12;
    }

    // Occasional character mutation
    final Random r = Random();
    if (r.nextDouble() < 0.1) {
      final idx = r.nextInt(characters.length);
      const chars = "0123456789ABCDEF<>/\\@#*%&";
      characters[idx] = chars[r.nextInt(chars.length)];
    }
  }
}

class SciFiBackgroundPainter extends CustomPainter {
  final List<Particle> particles;
  final List<CodeDrop> codeDrops;
  final Offset mousePosition;
  final bool hasMouse;
  final double animationValue;
  final Map<String, TextPainter> textPainterCache;

  SciFiBackgroundPainter({
    required this.particles,
    required this.codeDrops,
    required this.mousePosition,
    required this.hasMouse,
    required this.animationValue,
    required this.textPainterCache,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw 3D perspective grid warp
    _draw3DGrid(canvas, size);

    // 2. Draw Falling code rain columns
    _drawCodeRain(canvas, size);

    // 3. Draw cursor halo
    if (hasMouse) {
      final auraPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          colors: [
            CyberTheme.neonBlue.withOpacity(0.12),
            CyberTheme.neonBlue.withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(center: mousePosition, radius: 150));
      canvas.drawCircle(mousePosition, 150, auraPaint);
    }

    // 4. Draw interactive particles & lines
    _drawParticlesAndLines(canvas, size);
  }

  void _draw3DGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = CyberTheme.neonBlue.withOpacity(0.04)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final horizonY = size.height * 0.22;
    final vanishingPoint = Offset(
      size.width / 2 + (hasMouse ? (mousePosition.dx - size.width / 2) * 0.05 : 0),
      horizonY
    );

    // Draw vertical/perspective lines
    const int numPerspectiveLines = 14;
    for (int i = 0; i <= numPerspectiveLines; i++) {
      final double progress = i / numPerspectiveLines;
      final double targetX = progress * size.width;
      final double startX = vanishingPoint.dx + (progress - 0.5) * 80;

      canvas.drawLine(
        Offset(startX, horizonY),
        Offset(targetX, size.height),
        gridPaint,
      );
    }

    // Draw exponential horizontal lines
    const int numHorizontalLines = 8;
    final double gridPhase = animationValue % 1.0;

    for (int i = 0; i < numHorizontalLines; i++) {
      final double ratio = (i + gridPhase) / numHorizontalLines;
      final double lineY = horizonY + pow(ratio, 2.3) * (size.height - horizonY);

      if (lineY > horizonY) {
        final double opacity = (0.01 + 0.06 * ratio).clamp(0.0, 0.07);
        final linePaint = Paint()
          ..color = CyberTheme.neonBlue.withOpacity(opacity)
          ..strokeWidth = 0.5 + 1.2 * ratio
          ..style = PaintingStyle.stroke;

        canvas.drawLine(
          Offset(0, lineY),
          Offset(size.width, lineY),
          linePaint,
        );
      }
    }

    // Horizon line
    final horizonPaint = Paint()
      ..color = CyberTheme.neonBlue.withOpacity(0.18)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, horizonY), Offset(size.width, horizonY), horizonPaint);
  }

  void _drawCodeRain(Canvas canvas, Size size) {
    final textStyle = GoogleFonts.shareTechMono(
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );

    for (var drop in codeDrops) {
      final double dx = drop.x * size.width;
      final double dy = drop.y * size.height;

      for (int i = 0; i < drop.characters.length; i++) {
        final charY = dy - (i * 12);
        if (charY < 0 || charY > size.height) continue;

        // Gradient opacity fading down the stream
        final double factor = (1.0 - (i / drop.characters.length)).clamp(0.0, 1.0);
        final double currentOpacity = factor * drop.opacity;

        // Quantize opacity to 10 discrete steps (0.0 to 1.0) to achieve 100% text painter cache hits
        final double roundedOpacity = (currentOpacity * 10).roundToDouble() / 10.0;
        if (roundedOpacity <= 0.0) continue;

        final Color color = i == 0
            ? Colors.white.withOpacity((roundedOpacity * 2.2).clamp(0.0, 1.0))
            : CyberTheme.cyanGlow.withOpacity(roundedOpacity);

        final String char = drop.characters[i];
        final String cacheKey = '${char}_${color.value}';

        final textPainter = textPainterCache.putIfAbsent(cacheKey, () {
          final tp = TextPainter(
            text: TextSpan(
              text: char,
              style: textStyle.copyWith(color: color),
            ),
            textDirection: TextDirection.ltr,
          );
          tp.layout();
          return tp;
        });

        textPainter.paint(canvas, Offset(dx - textPainter.width / 2, charY));
      }
    }
  }

  void _drawParticlesAndLines(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final linePaint = Paint()..style = PaintingStyle.stroke;

    final double maxConnectionDist = size.width * 0.12;
    final double maxConnectionDistSq = maxConnectionDist * maxConnectionDist;

    // Draw neural connections
    for (int i = 0; i < particles.length; i++) {
      final p1 = particles[i];
      final dx1 = p1.x * size.width;
      final dy1 = p1.y * size.height;

      for (int j = i + 1; j < particles.length; j++) {
        final p2 = particles[j];
        final dx2 = p2.x * size.width;
        final dy2 = p2.y * size.height;

        final double dx = dx1 - dx2;
        final double dy = dy1 - dy2;
        final double distSq = dx * dx + dy * dy;

        // Check squared distance first to bypass expensive sqrt calls for 90%+ of particle pairs
        if (distSq < maxConnectionDistSq) {
          final dist = sqrt(distSq);
          final opacity = (1.0 - (dist / maxConnectionDist)).clamp(0.0, 0.15);
          final double roundedOpacity = (opacity * 20).roundToDouble() / 20.0;
          
          if (roundedOpacity > 0.0) {
            linePaint.color = p1.color.withOpacity(roundedOpacity);
            linePaint.strokeWidth = 0.5;
            canvas.drawLine(Offset(dx1, dy1), Offset(dx2, dy2), linePaint);
          }
        }
      }
    }

    // Draw particles
    for (var p in particles) {
      final dx = p.x * size.width;
      final dy = p.y * size.height;

      paint.color = p.color.withOpacity(0.45);
      canvas.drawCircle(Offset(dx, dy), p.radius, paint);

      // Inner glow ring
      paint.color = p.color.withOpacity(0.12);
      canvas.drawCircle(Offset(dx, dy), p.radius * 2.8, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SciFiBackgroundPainter oldDelegate) => true;
}

class ScannerLinesWidget extends StatefulWidget {
  const ScannerLinesWidget({super.key});

  @override
  State<ScannerLinesWidget> createState() => _ScannerLinesWidgetState();
}

class _ScannerLinesWidgetState extends State<ScannerLinesWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scannerController,
      builder: (context, _) {
        return CustomPaint(
          painter: ScannerPainter(progress: _scannerController.value),
        );
      },
    );
  }
}

class ScannerPainter extends CustomPainter {
  final double progress;

  ScannerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double y = progress * size.height;
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          CyberTheme.neonBlue.withOpacity(0.0),
          CyberTheme.neonBlue.withOpacity(0.1),
          CyberTheme.neonBlue.withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, y - 25, size.width, 50));

    canvas.drawRect(Rect.fromLTWH(0, y - 25, size.width, 50), paint);

    final linePaint = Paint()
      ..color = CyberTheme.neonBlue.withOpacity(0.25)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
  }

  @override
  bool shouldRepaint(covariant ScannerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
