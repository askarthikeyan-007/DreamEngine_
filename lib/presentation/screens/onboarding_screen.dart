import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dream_engine_ai/core/state/engine_state.dart';
import 'package:dream_engine_ai/core/theme/cyber_theme.dart';
import 'package:dream_engine_ai/core/widgets/neon_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentSlide = 0;
  final PageController _pageController = PageController();

  final List<OnboardingSlideData> _slides = [
    OnboardingSlideData(
      title: "PROCEDURAL WORLD SYNTHESIS",
      subtitle: "Convert text prompts into full 3D environments, voxel maps, and shader layouts in real-time.",
      accentColor: CyberTheme.neonBlue,
      drawType: GraphicDrawType.worldNode,
    ),
    OnboardingSlideData(
      title: "SYNTHETIC NPC BEHAVIOR",
      subtitle: "Inject deep-learning dialogue systems, neural memory models, and tactical combat AI into characters.",
      accentColor: CyberTheme.cyberPink,
      drawType: GraphicDrawType.npcBrain,
    ),
    OnboardingSlideData(
      title: "ONE-CLICK MULTIPLAYER DEPLOY",
      subtitle: "Distribute your generated games instantly on dedicated servers with live analytics and active anti-cheat.",
      accentColor: CyberTheme.electricPurple,
      drawType: GraphicDrawType.cloudServer,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentSlide < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      // Go to Login Screen
      Provider.of<EngineState>(context, listen: false).setScreenIndex(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              // Top Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("DREAMENGINE AI", style: CyberTheme.headingStyle(fontSize: isMobile ? 14 : 16)),
                  TextButton(
                    onPressed: () {
                      Provider.of<EngineState>(context, listen: false).setScreenIndex(2);
                    },
                    child: Text(
                      "SKIP BOOTSTRAP",
                      style: CyberTheme.monospaceStyle(fontSize: isMobile ? 10 : 12, color: CyberTheme.textMuted),
                    ),
                  ),
                ],
              ),
              if (isMobile) const SizedBox(height: 16) else const Spacer(),

              // Slides Content
              Expanded(
                flex: 8,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (val) {
                    setState(() {
                      _currentSlide = val;
                    });
                  },
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: slide.accentColor.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(4),
                                color: slide.accentColor.withOpacity(0.08),
                              ),
                              child: Text(
                                "MODULE 0${index + 1}",
                                style: CyberTheme.monospaceStyle(
                                  fontSize: 11,
                                  color: slide.accentColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              slide.title,
                              style: CyberTheme.titleStyle(fontSize: isMobile ? 20 : 26, color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              slide.subtitle,
                              style: CyberTheme.bodyStyle(
                                fontSize: isMobile ? 14 : 15,
                                color: CyberTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              if (isMobile) const SizedBox(height: 16) else const Spacer(),
              // Footer Navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators
                  Row(
                    children: List.generate(_slides.length, (index) {
                      final isActive = index == _currentSlide;
                      final accent = _slides[_currentSlide].accentColor;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8.0),
                        height: 5,
                        width: isActive ? 30 : 10,
                        decoration: BoxDecoration(
                          color: isActive ? accent : CyberTheme.textMuted.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: isActive ? CyberTheme.neonGlow(color: accent) : null,
                        ),
                      );
                    }),
                  ),

                  // Next Action
                  NeonButton(
                    onPressed: _nextPage,
                    glowColor: _slides[_currentSlide].accentColor,
                    gradientColors: [
                      _slides[_currentSlide].accentColor,
                      _slides[_currentSlide].accentColor.withBlue(220).withRed(100),
                    ],
                    width: isMobile ? 150 : 180,
                    child: Text(
                      _currentSlide == _slides.length - 1 ? "ENTER INTERFACE" : "NEXT INSTRUCTION",
                      style: CyberTheme.headingStyle(fontSize: isMobile ? 10 : 12, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum GraphicDrawType { worldNode, npcBrain, cloudServer }

class OnboardingSlideData {
  final String title;
  final String subtitle;
  final Color accentColor;
  final GraphicDrawType drawType;

  OnboardingSlideData({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.drawType,
  });
}

class OnboardingGraphicPainter extends CustomPainter {
  final GraphicDrawType drawType;
  final Color accentColor;

  OnboardingGraphicPainter({required this.drawType, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = accentColor.withOpacity(0.35);

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = accentColor.withOpacity(0.08);

    // Common outer holographic UI borders
    canvas.drawRect(
      Rect.fromCenter(center: center, width: size.width * 0.9, height: size.height * 0.9),
      paint,
    );
    canvas.drawCircle(center, size.width * 0.42, paint..strokeWidth = 0.5);

    if (drawType == GraphicDrawType.worldNode) {
      // Draw 3D-like wireframe grid box
      paint.strokeWidth = 1.0;
      final double width = size.width * 0.35;
      final double offset = 20;

      // Back box
      final rBack = Rect.fromCenter(
          center: center - Offset(offset, offset), width: width, height: width);
      canvas.drawRect(rBack, paint);

      // Front box
      final rFront = Rect.fromCenter(
          center: center + Offset(offset, offset), width: width, height: width);
      canvas.drawRect(rFront, paint);

      // Connecting corners
      canvas.drawLine(rBack.topLeft, rFront.topLeft, paint);
      canvas.drawLine(rBack.topRight, rFront.topRight, paint);
      canvas.drawLine(rBack.bottomLeft, rFront.bottomLeft, paint);
      canvas.drawLine(rBack.bottomRight, rFront.bottomRight, paint);

      // Nodes on corners
      final nodePaint = Paint()
        ..color = accentColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(rFront.topLeft, 4, nodePaint);
      canvas.drawCircle(rFront.bottomRight, 4, nodePaint);
      canvas.drawCircle(rBack.topRight, 4, nodePaint);
    } else if (drawType == GraphicDrawType.npcBrain) {
      // Draw concentric neural nodes and connections
      paint.strokeWidth = 0.8;
      final int numNodes = 7;
      final double radius = size.width * 0.28;

      canvas.drawCircle(center, radius, paint);
      canvas.drawCircle(center, radius * 0.5, paint);

      List<Offset> nodePositions = [];
      nodePositions.add(center);

      for (int i = 0; i < numNodes; i++) {
        final angle = (i * 2 * pi) / numNodes;
        final x = center.dx + radius * cos(angle);
        final y = center.dy + radius * sin(angle);
        nodePositions.add(Offset(x, y));
      }

      // Draw connection wires
      for (int i = 0; i < nodePositions.length; i++) {
        for (int j = i + 1; j < nodePositions.length; j++) {
          canvas.drawLine(nodePositions[i], nodePositions[j], paint..color = accentColor.withOpacity(0.12));
        }
      }

      // Draw neural dots
      final nodePaint = Paint()
        ..color = accentColor
        ..style = PaintingStyle.fill;

      for (var pos in nodePositions) {
        canvas.drawCircle(pos, 5, nodePaint);
        canvas.drawCircle(pos, 8, paint..color = accentColor.withOpacity(0.3)..style = PaintingStyle.stroke);
      }
    } else if (drawType == GraphicDrawType.cloudServer) {
      // Draw grid database blocks
      paint.strokeWidth = 1.0;
      final double rectW = size.width * 0.45;
      final double rectH = 30.0;

      // Draw 3 layers of server blades
      for (int i = 0; i < 3; i++) {
        final double y = center.dy - 50 + (i * 45);
        final rect = Rect.fromCenter(center: Offset(center.dx, y), width: rectW, height: rectH);
        canvas.drawRect(rect, paint);
        canvas.drawRect(rect, fillPaint);

        // Server lights
        canvas.drawCircle(Offset(rect.left + 15, y), 3, Paint()..color = Colors.greenAccent..style = PaintingStyle.fill);
        canvas.drawCircle(Offset(rect.left + 30, y), 3, Paint()..color = accentColor..style = PaintingStyle.fill);

        // Blade vents lines
        canvas.drawLine(Offset(rect.left + 50, y - 5), Offset(rect.right - 15, y - 5), paint..strokeWidth = 0.5);
        canvas.drawLine(Offset(rect.left + 50, y + 5), Offset(rect.right - 15, y + 5), paint..strokeWidth = 0.5);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
