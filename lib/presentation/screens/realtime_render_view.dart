import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dream_engine_ai/core/state/engine_state.dart';
import 'package:dream_engine_ai/core/theme/cyber_theme.dart';
import 'package:dream_engine_ai/core/widgets/glass_container.dart';
import 'package:dream_engine_ai/core/widgets/neon_button.dart';

class _RealtimeRenderViewData {
  final String weatherSystem;
  final bool rayTracingEnabled;
  final double renderScale;
  final AppTheme currentTheme;
  final String gameTitle;
  final double proceduralSeed;
  final String activeGameType;

  _RealtimeRenderViewData({
    required this.weatherSystem,
    required this.rayTracingEnabled,
    required this.renderScale,
    required this.currentTheme,
    required this.gameTitle,
    required this.proceduralSeed,
    required this.activeGameType,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _RealtimeRenderViewData &&
          runtimeType == other.runtimeType &&
          weatherSystem == other.weatherSystem &&
          rayTracingEnabled == other.rayTracingEnabled &&
          renderScale == other.renderScale &&
          currentTheme == other.currentTheme &&
          gameTitle == other.gameTitle &&
          proceduralSeed == other.proceduralSeed &&
          activeGameType == other.activeGameType;

  @override
  int get hashCode => Object.hash(
        weatherSystem,
        rayTracingEnabled,
        renderScale,
        currentTheme,
        gameTitle,
        proceduralSeed,
        activeGameType,
      );
}

class RealtimeRenderView extends StatefulWidget {
  const RealtimeRenderView({super.key});

  @override
  State<RealtimeRenderView> createState() => _RealtimeRenderViewState();
}

class _RealtimeRenderViewState extends State<RealtimeRenderView>
    with SingleTickerProviderStateMixin {
  late AnimationController _ticker;
  double _yaw = 0.0;   // Left-right angle
  double _pitch = 0.0; // Up-down angle
  final List<RainParticle> _rain = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // Init rain particles
    for (int i = 0; i < 50; i++) {
      _rain.add(RainParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble() * 2 - 1, // Start above viewport
        speed: _random.nextDouble() * 0.03 + 0.015,
        length: _random.nextDouble() * 15 + 10,
      ));
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _yaw += details.delta.dx * 0.005;
      _pitch = (_pitch + details.delta.dy * 0.005).clamp(-0.4, 0.4);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<EngineState, _RealtimeRenderViewData>(
      selector: (context, state) => _RealtimeRenderViewData(
        weatherSystem: state.weatherSystem,
        rayTracingEnabled: state.rayTracingEnabled,
        renderScale: state.renderScale,
        currentTheme: state.currentTheme,
        gameTitle: state.gameTitle,
        proceduralSeed: state.proceduralSeed,
        activeGameType: state.activeGameType,
      ),
      builder: (context, data, _) {
        final state = Provider.of<EngineState>(context, listen: false);
        final themeColor = _getThemeColor(data.currentTheme);

        final double screenWidth = MediaQuery.of(context).size.width;
        final bool isMobile = screenWidth < 768;

        final Widget canvasWidget = Container(
          height: isMobile ? 300 : null,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: themeColor.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: GestureDetector(
              onPanUpdate: _onPanUpdate,
              child: Stack(
                children: [
                  // Canvas Drawing
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: _ticker,
                        builder: (context, _) {
                          // Update rain positions
                          for (var r in _rain) {
                            r.update(data.weatherSystem);
                          }
                          return CustomPaint(
                            painter: Viewport3DPainter(
                              yaw: _yaw,
                              pitch: _pitch,
                              rain: _rain,
                              weather: data.weatherSystem,
                              themeColor: themeColor,
                              rayTracing: data.rayTracingEnabled,
                              activeGameType: data.activeGameType,
                              vehicleSpeed: state.vehiclePhysics.speed,
                              vehicleTilt: state.vehiclePhysics.tilt,
                              vehicleDistance: state.vehiclePhysics.distance,
                              runnerLane: state.runnerLane,
                              runnerDistance: state.runnerDistance,
                              runnerHoverboard: state.runnerHoverboard,
                              runnerGameOver: state.runnerGameOver,
                              platformerDistance: state.platformerDistance,
                              platformerStealth: state.platformerStealth,
                              platformerGameOver: state.platformerGameOver,
                              platformerState: state.platformerState,
                              platformerLightIntensity: state.platformerLightIntensity,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Water reflections info HUD inside viewport
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      color: Colors.black.withOpacity(0.7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("CAMERA: FREE ORBIT", style: CyberTheme.monospaceStyle(fontSize: 9, color: themeColor)),
                          Text("DRAG MOUSE TO ROTATE CANVAS", style: CyberTheme.monospaceStyle(fontSize: 8, color: Colors.white60)),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Debug parameters inside viewport
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      color: Colors.black.withOpacity(0.7),
                      child: Text(
                        "YAW: ${_yaw.toStringAsFixed(2)} | PITCH: ${_pitch.toStringAsFixed(2)} | BUILD: ${data.gameTitle.toUpperCase()}",
                        style: CyberTheme.monospaceStyle(fontSize: 8, color: themeColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        final Widget controlsWidget = GlassContainer(
          borderColor: themeColor.withOpacity(0.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("RENDER ENGINE CONTROLS", style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white)),
              const SizedBox(height: 20),

              // Resolution slider
              Text(
                "RESOLUTION SCALE (${(data.renderScale * 100).toInt()}%)",
                style: CyberTheme.monospaceStyle(fontSize: 9, color: CyberTheme.textMuted),
              ),
              Slider(
                value: data.renderScale,
                onChanged: (val) => state.setRenderScale(val),
                min: 0.5,
                max: 2.0,
                activeColor: themeColor,
                inactiveColor: Colors.white10,
              ),
              const SizedBox(height: 16),

              if (!isMobile) const Spacer(),
              if (isMobile) const SizedBox(height: 24),

              // Compile triggers
              NeonButton(
                onPressed: () {
                  state.setScreenIndex(6); // Go to game preview
                },
                glowColor: themeColor,
                gradientColors: [themeColor, themeColor.withBlue(180).withRed(70)],
                child: Text("VIEW GAME DATA SPECS", style: CyberTheme.headingStyle(fontSize: 11, color: Colors.white)),
              ),
            ],
          ),
        );

        final Widget viewBody = isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  canvasWidget,
                  const SizedBox(height: 20),
                  controlsWidget,
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 7,
                    child: canvasWidget,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 3,
                    child: controlsWidget,
                  ),
                ],
              );

        return isMobile
            ? SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("REALTIME RENDER VIEWPORT", style: CyberTheme.titleStyle(fontSize: 18)),
                        const SizedBox(height: 4),
                        Text(
                          "COMPILE SEED: ${data.proceduralSeed.toInt()} // PIPELINE: IMPELLER HW-ACCEL",
                          style: CyberTheme.monospaceStyle(fontSize: 8, color: themeColor),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildToggleHeader("RAY-TRACING", data.rayTracingEnabled, themeColor),
                            const SizedBox(width: 8),
                            _buildToggleHeader("DYNAMIC WEATHER", true, themeColor),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    viewBody,
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "REALTIME RENDERING VIEWPORT",
                                style: CyberTheme.titleStyle(fontSize: 22),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "COMPILE SEED: ${data.proceduralSeed.toInt()} // PIPELINE: IMPELLER HW-ACCEL",
                                style: CyberTheme.monospaceStyle(fontSize: 10, color: themeColor),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            _buildToggleHeader("RAY-TRACING", data.rayTracingEnabled, themeColor),
                            const SizedBox(width: 8),
                            _buildToggleHeader("DYNAMIC WEATHER", true, themeColor),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(child: viewBody),
                  ],
                ),
              );
      },
    );
  }

  Widget _buildToggleHeader(String title, bool val, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: val ? color.withOpacity(0.12) : Colors.white.withOpacity(0.04),
        border: Border.all(color: val ? color : Colors.white10),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        "$title: ${val ? "ON" : "OFF"}",
        style: CyberTheme.monospaceStyle(fontSize: 9, color: val ? Colors.white : CyberTheme.textMuted),
      ),
    );
  }


  Color _getThemeColor(AppTheme theme) {
    if (theme == AppTheme.ironMan) return Colors.amber;
    if (theme == AppTheme.nvidiaGreen) return Colors.lightGreenAccent;
    if (theme == AppTheme.appleVision) return Colors.white;
    return CyberTheme.neonBlue;
  }
}

class RainParticle {
  double x; // normalized 0 to 1
  double y; // normalized -1 to 1
  double speed;
  double length;

  RainParticle({required this.x, required this.y, required this.speed, required this.length});

  void update(String weather) {
    double speedMult = 1.0;
    if (weather == "Solar Storm") speedMult = 1.8;
    if (weather == "Acid Fog") speedMult = 0.5;
    if (weather == "Clear Voxel") speedMult = 0.0;

    y += speed * speedMult;
    if (y > 1.0) {
      y = -1.0;
      x = Random().nextDouble();
    }
  }
}

class Viewport3DPainter extends CustomPainter {
  final double yaw;
  final double pitch;
  final List<RainParticle> rain;
  final String weather;
  final Color themeColor;
  final bool rayTracing;
  final String activeGameType;
  final double vehicleSpeed;
  final double vehicleTilt;
  final double vehicleDistance;
  final int runnerLane;
  final double runnerDistance;
  final bool runnerHoverboard;
  final bool runnerGameOver;
  final double platformerDistance;
  final double platformerStealth;
  final bool platformerGameOver;
  final String platformerState;
  final double platformerLightIntensity;

  // Cached Paint objects to avoid reallocation on every frame render tick
  final Paint _backgroundPaint = Paint()..color = const Color(0xFF030712);
  final Paint _gridPaint = Paint()..strokeWidth = 1.0..style = PaintingStyle.stroke;
  final Paint _buildingPaint = Paint()..strokeWidth = 1.0..style = PaintingStyle.stroke;
  final Paint _fillPaint = Paint()..style = PaintingStyle.fill;
  final Paint _windowPaint = Paint()..style = PaintingStyle.fill;
  final Paint _weatherPaint = Paint()..strokeWidth = 1.0;
  final Paint _fogPaint = Paint()..style = PaintingStyle.fill;

  Viewport3DPainter({
    required this.yaw,
    required this.pitch,
    required this.rain,
    required this.weather,
    required this.themeColor,
    required this.rayTracing,
    required this.activeGameType,
    required this.vehicleSpeed,
    required this.vehicleTilt,
    required this.vehicleDistance,
    required this.runnerLane,
    required this.runnerDistance,
    required this.runnerHoverboard,
    required this.runnerGameOver,
    required this.platformerDistance,
    required this.platformerStealth,
    required this.platformerGameOver,
    required this.platformerState,
    required this.platformerLightIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    if (activeGameType == "racing") {
      // --- RACING (HILL CLIMB) RENDERING MODE ---
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _backgroundPaint);

      // Apply pitch offsets to horizon
      final horizonY = center.dy + (pitch * size.height * 0.4);

      // Draw scrolling sky grid or stars
      final starPaint = Paint()..color = Colors.white24;
      for (int i = 0; i < 20; i++) {
        final double sx = (sin(i * 12.3) * 0.5 + 0.5) * size.width + (yaw * 40.0);
        final double sy = (cos(i * 7.9) * 0.3 + 0.3) * horizonY;
        canvas.drawCircle(Offset(sx % size.width, sy), 1.0, starPaint);
      }

      // Parallax mountains in background
      final mountPaint = Paint()
        ..color = themeColor.withOpacity(0.08)
        ..style = PaintingStyle.fill;
      final mountBorder = Paint()
        ..color = themeColor.withOpacity(0.2)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      final mountPath = Path()
        ..moveTo(0, horizonY)
        ..lineTo(size.width * 0.15 + yaw * 10, horizonY - 30)
        ..lineTo(size.width * 0.35 + yaw * 10, horizonY - 70)
        ..lineTo(size.width * 0.55 + yaw * 10, horizonY - 20)
        ..lineTo(size.width * 0.75 + yaw * 10, horizonY - 90)
        ..lineTo(size.width * 0.9 + yaw * 10, horizonY - 40)
        ..lineTo(size.width, horizonY)
        ..close();
      canvas.drawPath(mountPath, mountPaint);
      canvas.drawPath(mountPath, mountBorder);

      // Drawing active vehicle moving over 3D voxel hill climb profile
      final roadY = horizonY + 30;
      final path = Path();
      path.moveTo(0, roadY);
      for (double x = 0; x <= size.width; x += 10) {
        // Generate hill profile based on vehicleDistance
        final double terrainY = roadY + sin((x + vehicleDistance * 6) * 0.012) * 22 + cos((x + vehicleDistance * 3) * 0.005) * 12;
        if (x == 0) {
          path.moveTo(x, terrainY);
        } else {
          path.lineTo(x, terrainY);
        }
      }
      final roadPaint = Paint()
        ..color = themeColor
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke;
      canvas.drawPath(path, roadPaint);

      // Draw Buggy at center screen
      final double carX = size.width * 0.5;
      final double carY = roadY + sin((carX + vehicleDistance * 6) * 0.012) * 22 + cos((carX + vehicleDistance * 3) * 0.005) * 12 - 18;

      canvas.save();
      canvas.translate(carX, carY);
      canvas.rotate(vehicleTilt);

      // Voxel-style vehicle chassis
      final chassis = Paint()..color = themeColor..strokeWidth = 2.5..style = PaintingStyle.stroke;
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: 42, height: 12), chassis);
      canvas.drawRect(Rect.fromLTWH(-10, -14, 20, 8), Paint()..color = themeColor.withOpacity(0.25)..style = PaintingStyle.fill);
      canvas.drawRect(Rect.fromLTWH(-10, -14, 20, 8), Paint()..color = themeColor..strokeWidth = 1.5..style = PaintingStyle.stroke);

      // Draw wheels (spinning based on vehicleDistance)
      final wheelAngle = vehicleDistance * 0.6;
      final double wheelRad = 8.0;
      void drawWheel(double wx, double wy) {
        canvas.drawCircle(Offset(wx, wy), wheelRad, Paint()..color = Colors.black..style = PaintingStyle.fill);
        canvas.drawCircle(Offset(wx, wy), wheelRad, Paint()..color = themeColor..strokeWidth = 2.0..style = PaintingStyle.stroke);
        canvas.drawLine(
          Offset(wx, wy),
          Offset(wx + wheelRad * cos(wheelAngle), wy + wheelRad * sin(wheelAngle)),
          Paint()..color = themeColor..strokeWidth = 2.0,
        );
      }
      drawWheel(-14, 8);
      drawWheel(14, 8);

      canvas.restore();

      // Draw HUD stats text in top-right
      final hudPainter = TextPainter(
        text: TextSpan(
          text: "HUD: V-TELEMETRY COMPILER [C++]\n"
                "GRAVITY MULT: -9.81 m/s²\n"
                "TILT RATIO: ${(vehicleTilt * (180 / pi)).toStringAsFixed(1)}°\n"
                "DISPLACEMENT: ${vehicleDistance.toStringAsFixed(1)} M",
          style: TextStyle(color: themeColor.withOpacity(0.85), fontSize: 9, fontFamily: "monospace"),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      hudPainter.paint(canvas, Offset(size.width - hudPainter.width - 12, 12));

      // Draw weather overlay
      _drawWeather(canvas, size);

    } else if (activeGameType == "runner") {
      // --- ENDLESS RUNNER (SUBWAY SURFERS) RENDERING MODE ---
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _backgroundPaint);

      final horizonY = center.dy + (pitch * size.height * 0.4);
      final vp = Offset(center.dx + (yaw * size.width * 0.15), horizonY);

      // Draw 3D tunnel grids
      final tunnelPaint = Paint()
        ..color = themeColor.withOpacity(0.12)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      for (int i = 1; i <= 6; i++) {
        final double t = pow(i / 6, 2).toDouble();
        final double w = size.width * t;
        final double h = size.height * t;
        canvas.drawRect(
          Rect.fromCenter(center: Offset.lerp(center, vp, 1 - t)!, width: w, height: h * 0.8),
          tunnelPaint,
        );
      }

      // Draw rail lines
      final railPaint = Paint()
        ..color = themeColor.withOpacity(0.35)
        ..strokeWidth = 2.0;

      final bottomY = size.height * 0.95;
      final List<double> bottomXs = [
        size.width * 0.15,
        size.width * 0.38,
        size.width * 0.62,
        size.width * 0.85,
      ];

      for (var bx in bottomXs) {
        canvas.drawLine(vp, Offset(bx, bottomY), railPaint);
      }

      if (runnerGameOver) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: "CRITICAL FAILURE: INTRUSION INTERCEPTED\nREBOOT TERMINAL SIMULATION",
            style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: "monospace"),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, Offset(size.width / 2 - textPainter.width / 2, size.height / 2 - textPainter.height / 2));
      } else {
        // Draw player
        final double playerY = bottomY - 30;
        final double leftX = (bottomXs[0] + bottomXs[1]) / 2;
        final double centerX = (bottomXs[1] + bottomXs[2]) / 2;
        final double rightX = (bottomXs[2] + bottomXs[3]) / 2;

        double targetX = centerX;
        if (runnerLane == 0) targetX = leftX;
        if (runnerLane == 2) targetX = rightX;

        // Player hoverboard glow
        if (runnerHoverboard) {
          canvas.drawOval(
            Rect.fromCenter(center: Offset(targetX, playerY + 10), width: 22, height: 5),
            Paint()..color = Colors.cyanAccent.withOpacity(0.8)..style = PaintingStyle.fill,
          );
        }
        
        // Draw voxel character representation
        final charPaint = Paint()..color = runnerHoverboard ? Colors.cyanAccent : themeColor..style = PaintingStyle.fill;
        canvas.drawRect(Rect.fromCenter(center: Offset(targetX, playerY), width: 10, height: 16), charPaint);
        canvas.drawCircle(Offset(targetX, playerY - 12), 4, charPaint);

        // Draw active moving obstacles (trains / blockades)
        final double obsT = ((runnerDistance * 0.06) % 1.0);
        final double obsY = vp.dy + obsT * (bottomY - vp.dy);
        final int obsLane = (runnerDistance ~/ 16) % 3;

        double obsDestX = centerX;
        if (obsLane == 0) obsDestX = leftX;
        if (obsLane == 2) obsDestX = rightX;

        final double obsX = vp.dx + obsT * (obsDestX - vp.dx);
        final double obsW = 20 * obsT;
        final double obsH = 26 * obsT;

        if (obsT < 0.96) {
          final boxPaint = Paint()..color = Colors.redAccent.withOpacity(0.75)..style = PaintingStyle.fill;
          final borderPaint = Paint()..color = Colors.white..strokeWidth = 1.5..style = PaintingStyle.stroke;
          canvas.drawRect(Rect.fromCenter(center: Offset(obsX, obsY - obsH / 2), width: obsW, height: obsH), boxPaint);
          canvas.drawRect(Rect.fromCenter(center: Offset(obsX, obsY - obsH / 2), width: obsW, height: obsH), borderPaint);
        }
      }

      // Draw weather overlay
      _drawWeather(canvas, size);

    } else if (activeGameType == "platformer") {
      // --- ATMOSPHERIC 2.5D PLATFORMER (LITTLE NIGHTMARES) RENDERING MODE ---
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFF070B13));

      // Volumetric backlight glow
      final radialPaint = Paint()
        ..shader = RadialGradient(
          colors: [themeColor.withOpacity(0.16), Colors.transparent],
          radius: 0.9,
        ).createShader(Rect.fromCircle(center: Offset(size.width * 0.5, size.height * 0.4), radius: size.width * 0.4));
      canvas.drawPaint(radialPaint);

      // Background pipes & warehouse ruins (parallax silhouettes)
      final silPaint = Paint()
        ..color = Colors.black.withOpacity(0.6)
        ..style = PaintingStyle.fill;

      final facilityPath = Path()
        ..moveTo(0, size.height)
        ..lineTo(0, size.height - 80)
        ..lineTo(size.width * 0.25 + yaw * 20, size.height - 80)
        ..lineTo(size.width * 0.25 + yaw * 20, size.height - 180)
        ..lineTo(size.width * 0.45 + yaw * 20, size.height - 180)
        ..lineTo(size.width * 0.45 + yaw * 20, size.height - 110)
        ..lineTo(size.width * 0.75 + yaw * 20, size.height - 110)
        ..lineTo(size.width * 0.75 + yaw * 20, size.height - 220)
        ..lineTo(size.width * 0.9 + yaw * 20, size.height - 220)
        ..lineTo(size.width * 0.9 + yaw * 20, size.height - 90)
        ..lineTo(size.width, size.height - 90)
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(facilityPath, silPaint);

      // Add silhouetted steel beams
      final beamPaint = Paint()
        ..color = Colors.black.withOpacity(0.85)
        ..strokeWidth = 4.0;
      canvas.drawLine(Offset(0, size.height - 70), Offset(size.width, size.height - 70), beamPaint);
      
      // Oscillating Volumetric Searchlight (Sentinel Drone)
      final double timeSec = DateTime.now().millisecondsSinceEpoch / 1000.0;
      final double sweep = sin(timeSec * 2.0); // oscillating
      
      // Spotlight origin (top center surveillance tower)
      final towerX = size.width * 0.5 + (yaw * size.width * 0.05);
      final towerY = 30.0;
      
      // Spotlight target x
      final spotTargetX = towerX + sweep * (size.width * 0.45);
      final spotTargetY = size.height - 70;

      final lightPaint = Paint()
        ..shader = RadialGradient(
          colors: [Colors.amber.withOpacity(0.35), Colors.transparent],
          center: Alignment.topCenter,
          radius: 1.0,
        ).createShader(Rect.fromCircle(center: Offset(spotTargetX, spotTargetY), radius: 60));

      final lightBeamPath = Path()
        ..moveTo(towerX - 4, towerY)
        ..lineTo(towerX + 4, towerY)
        ..lineTo(spotTargetX + 60, spotTargetY)
        ..lineTo(spotTargetX - 60, spotTargetY)
        ..close();

      // Draw spotlight cone
      canvas.drawPath(lightBeamPath, Paint()..color = Colors.amber.withOpacity(0.08)..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(spotTargetX, spotTargetY), 45, lightPaint);

      // Draw surveillance tower eye
      canvas.drawCircle(Offset(towerX, towerY), 8, Paint()..color = Colors.black..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(towerX, towerY), 8, Paint()..color = Colors.white24..strokeWidth = 1.0..style = PaintingStyle.stroke);
      canvas.drawCircle(Offset(towerX, towerY), 3, Paint()..color = (sweep.abs() > 0.75) ? Colors.redAccent : Colors.greenAccent..style = PaintingStyle.fill);

      if (platformerGameOver) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: "DETECTED // SCAN LOCKED\nCOGNITIVE CAPTURE COMPLETE",
            style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: "monospace"),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, Offset(size.width / 2 - textPainter.width / 2, size.height / 2 - textPainter.height / 2));
      } else {
        // Draw tiny player avatar silhouette moving
        final double playerX = size.width * 0.2 + (platformerDistance * 12) % (size.width * 0.6);
        double playerY = size.height - 70;

        if (platformerState == "Climbing") {
          playerY -= 24.0; // jump offset
        } else if (platformerState == "Hiding") {
          playerY += 3.0; // crouch offset
        }

        // Player body
        final pPaint = Paint()
          ..color = (platformerState == "Spotted") ? Colors.redAccent : themeColor
          ..style = PaintingStyle.fill;
        
        // Silhouette height
        final double ph = (platformerState == "Hiding") ? 6 : 12;
        canvas.drawRect(Rect.fromCenter(center: Offset(playerX, playerY - ph / 2), width: 6, height: ph), pPaint);
        canvas.drawCircle(Offset(playerX, playerY - ph - 3), 3, pPaint);

        // If spotted, draw alert indicator
        if (platformerState == "Spotted") {
          final alertPainter = TextPainter(
            text: const TextSpan(
              text: "!",
              style: TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: "monospace"),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          alertPainter.paint(canvas, Offset(playerX - alertPainter.width / 2, playerY - ph - 22));
        }
      }

      // Draw HUD stats text in top-right
      final hudPainter = TextPainter(
        text: TextSpan(
          text: "HUD: CORE INTERACTION [C#]\n"
                "LIGHT THRESHOLD: ${platformerLightIntensity.toStringAsFixed(1)}%\n"
                "STEALTH METRIC: ${platformerStealth.toStringAsFixed(1)}%\n"
                "STATE LAYER: ${platformerState.toUpperCase()}",
          style: TextStyle(color: themeColor.withOpacity(0.85), fontSize: 9, fontFamily: "monospace"),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      hudPainter.paint(canvas, Offset(size.width - hudPainter.width - 12, 12));

      // Draw custom weather ash particles
      _drawWeather(canvas, size);

    } else {
      // --- CYBERPUNK DEFAULT CITY VIEWPORT RENDERING MODE ---
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _backgroundPaint);

      // Apply pitch offsets to horizon
      final horizonY = center.dy + (pitch * size.height * 0.4);
      final vanishingPoint = Offset(center.dx + (yaw * size.width * 0.15), horizonY);

      // Draw procedural grid lines projecting from vanishing point
      _gridPaint.color = themeColor.withOpacity(0.18);

      final int numGridLines = 16;
      for (int i = 0; i <= numGridLines; i++) {
        final double xOffset = (i / numGridLines) * size.width;
        canvas.drawLine(
          vanishingPoint,
          Offset(xOffset, size.height),
          _gridPaint,
        );
      }

      // Draw horizontal grid depth lines (exponential perspective spacing)
      for (int i = 1; i <= 10; i++) {
        final double t = pow(i / 10, 2).toDouble(); // exponential decay to vanishing point
        final double y = horizonY + t * (size.height - horizonY);
        final double widthOffset = size.width * t;
        _gridPaint.color = themeColor.withOpacity(0.18 * (1.0 - t));
        canvas.drawLine(
          Offset(center.dx - widthOffset, y),
          Offset(center.dx + widthOffset, y),
          _gridPaint,
        );
      }

      // Draw 3D Voxel Buildings (Skyscrapers in wireframe)
      _drawBuildings(canvas, size, vanishingPoint, horizonY);

      // Draw dynamic weather systems
      _drawWeather(canvas, size);
    }
  }

  void _drawBuildings(Canvas canvas, Size size, Offset vp, double horizonY) {
    final buildingColors = [
      themeColor,
      CyberTheme.cyberPink,
      CyberTheme.electricPurple,
    ];

    // Building coordinates (relative spacing)
    final List<Map<String, double>> buildingSpecs = [
      {"x": 0.25, "w": 0.1, "h": 0.35, "depth": 0.4},
      {"x": 0.4, "w": 0.08, "h": 0.5, "depth": 0.5},
      {"x": 0.75, "w": 0.12, "h": 0.42, "depth": 0.35},
      {"x": 0.62, "w": 0.09, "h": 0.28, "depth": 0.45},
    ];

    for (var b in buildingSpecs) {
      final double t = b["depth"]!;
      final double bx = size.width * b["x"]! + (yaw * size.width * 0.08);
      final double by = horizonY + t * (size.height - horizonY);
      final double bw = size.width * b["w"]! * t;
      final double bh = size.height * b["h"]! * t;

      final Color col = buildingColors[((b["x"]! * 10).toInt()) % buildingColors.length];
      _buildingPaint.color = col.withOpacity(0.3);
      _fillPaint.color = col.withOpacity(rayTracing ? 0.04 : 0.02);

      // Front Face
      final frontRect = Rect.fromLTWH(bx - bw / 2, by - bh, bw, bh);
      canvas.drawRect(frontRect, _fillPaint);
      canvas.drawRect(frontRect, _buildingPaint);

      // Back projection lines towards vanishing point
      final Offset frontTopLeft = Offset(bx - bw / 2, by - bh);
      final Offset frontTopRight = Offset(bx + bw / 2, by - bh);
      final Offset frontBottomLeft = Offset(bx - bw / 2, by);
      final Offset frontBottomRight = Offset(bx + bw / 2, by);

      // Back coordinates
      final double scaleBack = 0.85;
      final Offset backTopLeft = Offset.lerp(frontTopLeft, vp, 1 - scaleBack)!;
      final Offset backTopRight = Offset.lerp(frontTopRight, vp, 1 - scaleBack)!;
      final Offset backBottomLeft = Offset.lerp(frontBottomLeft, vp, 1 - scaleBack)!;
      final Offset backBottomRight = Offset.lerp(frontBottomRight, vp, 1 - scaleBack)!;

      // Draw lines projecting back
      canvas.drawLine(frontTopLeft, backTopLeft, _buildingPaint);
      canvas.drawLine(frontTopRight, backTopRight, _buildingPaint);
      canvas.drawLine(frontBottomLeft, backBottomLeft, _buildingPaint);
      canvas.drawLine(frontBottomRight, backBottomRight, _buildingPaint);

      // Draw back face
      canvas.drawLine(backTopLeft, backTopRight, _buildingPaint);
      canvas.drawLine(backBottomLeft, backBottomRight, _buildingPaint);
      canvas.drawLine(backTopLeft, backBottomLeft, _buildingPaint);
      canvas.drawLine(backTopRight, backBottomRight, _buildingPaint);

      // Draw neon signs/window matrix grid on the building front
      final int numWindowsX = 3;
      final int numWindowsY = 5;
      final double winSpacingX = bw / (numWindowsX + 1);
      final double winSpacingY = bh / (numWindowsY + 1);

      _windowPaint.color = col.withOpacity(0.4);

      for (int wx = 1; wx <= numWindowsX; wx++) {
        for (int wy = 1; wy <= numWindowsY; wy++) {
          final val = (wx * 17 + wy * 31) % 10;
          if (val > 3) {
            canvas.drawRect(
              Rect.fromCenter(
                center: Offset(frontTopLeft.dx + wx * winSpacingX, frontTopLeft.dy + wy * winSpacingY),
                width: bw * 0.08,
                height: bh * 0.04,
              ),
              _windowPaint,
            );
          }
        }
      }
    }
  }

  void _drawWeather(Canvas canvas, Size size) {
    if (weather == "Clear Voxel") return;

    if (weather == "Neon Rain") {
      _weatherPaint.color = CyberTheme.neonBlue.withOpacity(0.4);
      _weatherPaint.strokeWidth = 1.0;
      for (var r in rain) {
        final double rx = r.x * size.width;
        final double ry = r.y * size.height;
        canvas.drawLine(Offset(rx, ry), Offset(rx, ry + r.length), _weatherPaint);
      }
    } else if (weather == "Solar Storm") {
      // Draw meteor sparks/flares angled
      _weatherPaint.color = CyberTheme.cyberPink.withOpacity(0.5);
      _weatherPaint.strokeWidth = 1.5;
      for (var r in rain) {
        final double rx = r.x * size.width;
        final double ry = r.y * size.height;
        canvas.drawLine(Offset(rx, ry), Offset(rx + r.length, ry + r.length * 0.6), _weatherPaint);
      }
    } else if (weather == "Acid Fog") {
      _fogPaint.color = Colors.lightGreenAccent.withOpacity(0.06);
      canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.4), 100, _fogPaint);
      canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.3), 150, _fogPaint);
    }
  }

  @override
  bool shouldRepaint(covariant Viewport3DPainter oldDelegate) => true;
}
