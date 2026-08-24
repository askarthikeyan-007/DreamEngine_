import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:dream_engine_ai/core/state/engine_state.dart';
import 'package:dream_engine_ai/core/theme/cyber_theme.dart';
import 'package:dream_engine_ai/core/widgets/glass_container.dart';
import 'package:dream_engine_ai/core/widgets/neon_button.dart';
import 'package:dream_engine_ai/core/services/download_helper.dart' as dl;

class _GamePreviewScreenData {
  final String gameTitle;
  final String gameGenre;
  final double proceduralSeed;
  final String storyOutline;
  final List<GeneratedNPC> npcs;
  final AppTheme currentTheme;

  _GamePreviewScreenData({
    required this.gameTitle,
    required this.gameGenre,
    required this.proceduralSeed,
    required this.storyOutline,
    required this.npcs,
    required this.currentTheme,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _GamePreviewScreenData &&
          runtimeType == other.runtimeType &&
          gameTitle == other.gameTitle &&
          gameGenre == other.gameGenre &&
          proceduralSeed == other.proceduralSeed &&
          storyOutline == other.storyOutline &&
          npcs.length == other.npcs.length &&
          currentTheme == other.currentTheme;

  @override
  int get hashCode => Object.hash(
        gameTitle,
        gameGenre,
        proceduralSeed,
        storyOutline,
        npcs,
        currentTheme,
      );
}

class _APKDeployerData {
  final bool isCompilingAPK;
  final double apkProgress;
  final String apkStatus;
  final bool apkReady;
  final String gameTitle;
  final bool isInstallingGame;
  final double installProgress;
  final bool gameInstalled;
  final AppTheme currentTheme;

  _APKDeployerData({
    required this.isCompilingAPK,
    required this.apkProgress,
    required this.apkStatus,
    required this.apkReady,
    required this.gameTitle,
    required this.isInstallingGame,
    required this.installProgress,
    required this.gameInstalled,
    required this.currentTheme,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _APKDeployerData &&
          runtimeType == other.runtimeType &&
          isCompilingAPK == other.isCompilingAPK &&
          apkProgress == other.apkProgress &&
          apkStatus == other.apkStatus &&
          apkReady == other.apkReady &&
          gameTitle == other.gameTitle &&
          isInstallingGame == other.isInstallingGame &&
          installProgress == other.installProgress &&
          gameInstalled == other.gameInstalled &&
          currentTheme == other.currentTheme;

  @override
  int get hashCode => Object.hash(
        isCompilingAPK,
        apkProgress,
        apkStatus,
        apkReady,
        gameTitle,
        isInstallingGame,
        installProgress,
        gameInstalled,
        currentTheme,
      );
}

class _SoundtrackData {
  final bool isPlayingSoundtrack;
  final int currentTrackIndex;
  final List<String> playlist;
  final double trackProgress;
  final bool isGeneratingSound;
  final String soundStatus;
  final double soundProgress;
  final AppTheme currentTheme;

  _SoundtrackData({
    required this.isPlayingSoundtrack,
    required this.currentTrackIndex,
    required this.playlist,
    required this.trackProgress,
    required this.isGeneratingSound,
    required this.soundStatus,
    required this.soundProgress,
    required this.currentTheme,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _SoundtrackData &&
          runtimeType == other.runtimeType &&
          isPlayingSoundtrack == other.isPlayingSoundtrack &&
          currentTrackIndex == other.currentTrackIndex &&
          playlist == other.playlist &&
          trackProgress == other.trackProgress &&
          isGeneratingSound == other.isGeneratingSound &&
          soundStatus == other.soundStatus &&
          soundProgress == other.soundProgress &&
          currentTheme == other.currentTheme;

  @override
  int get hashCode => Object.hash(
        isPlayingSoundtrack,
        currentTrackIndex,
        playlist,
        trackProgress,
        isGeneratingSound,
        soundStatus,
        soundProgress,
        currentTheme,
      );
}

class _SimulatorSectionData {
  final String activeGameType;
  final double speed;
  final double rpm;
  final double tilt;
  final double distance;
  final int runnerLane;
  final double runnerDistance;
  final bool runnerHoverboard;
  final bool runnerGameOver;
  final int runnerScore;
  final int runnerCoins;
  final double platformerDistance;
  final double platformerStealth;
  final bool platformerGameOver;
  final int platformerScore;
  final String platformerState;
  final double platformerLightIntensity;
  final double platformerSensitivity;
  final double platformerJumpHeight;
  final double platformerSearchlightSpeed;
  final AppTheme currentTheme;

  _SimulatorSectionData({
    required this.activeGameType,
    required this.speed,
    required this.rpm,
    required this.tilt,
    required this.distance,
    required this.runnerLane,
    required this.runnerDistance,
    required this.runnerHoverboard,
    required this.runnerGameOver,
    required this.runnerScore,
    required this.runnerCoins,
    required this.platformerDistance,
    required this.platformerStealth,
    required this.platformerGameOver,
    required this.platformerScore,
    required this.platformerState,
    required this.platformerLightIntensity,
    required this.platformerSensitivity,
    required this.platformerJumpHeight,
    required this.platformerSearchlightSpeed,
    required this.currentTheme,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _SimulatorSectionData &&
          runtimeType == other.runtimeType &&
          activeGameType == other.activeGameType &&
          speed == other.speed &&
          rpm == other.rpm &&
          tilt == other.tilt &&
          distance == other.distance &&
          runnerLane == other.runnerLane &&
          runnerDistance == other.runnerDistance &&
          runnerHoverboard == other.runnerHoverboard &&
          runnerGameOver == other.runnerGameOver &&
          runnerScore == other.runnerScore &&
          runnerCoins == other.runnerCoins &&
          platformerDistance == other.platformerDistance &&
          platformerStealth == other.platformerStealth &&
          platformerGameOver == other.platformerGameOver &&
          platformerScore == other.platformerScore &&
          platformerState == other.platformerState &&
          platformerLightIntensity == other.platformerLightIntensity &&
          platformerSensitivity == other.platformerSensitivity &&
          platformerJumpHeight == other.platformerJumpHeight &&
          platformerSearchlightSpeed == other.platformerSearchlightSpeed &&
          currentTheme == other.currentTheme;

  @override
  int get hashCode => Object.hashAll([
        activeGameType,
        speed,
        rpm,
        tilt,
        distance,
        runnerLane,
        runnerDistance,
        runnerHoverboard,
        runnerGameOver,
        runnerScore,
        runnerCoins,
        platformerDistance,
        platformerStealth,
        platformerGameOver,
        platformerScore,
        platformerState,
        platformerLightIntensity,
        platformerSensitivity,
        platformerJumpHeight,
        platformerSearchlightSpeed,
        currentTheme,
      ]);
}

class GamePreviewScreen extends StatefulWidget {
  const GamePreviewScreen({super.key});

  @override
  State<GamePreviewScreen> createState() => _GamePreviewScreenState();
}

class _GamePreviewScreenState extends State<GamePreviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EngineState>(context, listen: false).startSimulationLoop();
    });
  }

  @override
  void dispose() {
    try {
      Provider.of<EngineState>(context, listen: false).stopSimulationLoop();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<EngineState, _GamePreviewScreenData>(
      selector: (context, state) => _GamePreviewScreenData(
        gameTitle: state.gameTitle,
        gameGenre: state.gameGenre,
        proceduralSeed: state.proceduralSeed,
        storyOutline: state.storyOutline,
        npcs: state.npcs,
        currentTheme: state.currentTheme,
      ),
      builder: (context, data, _) {
        final state = Provider.of<EngineState>(context, listen: false);
        final themeColor = _getThemeColor(data.currentTheme);

        final double screenWidth = MediaQuery.of(context).size.width;
        final bool isMobile = screenWidth < 768;

        final Widget leftColumnContent = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Core Specs Glass Container
            GlassContainer(
              borderColor: themeColor.withOpacity(0.2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionTitle("SYSTEM LOGS"),
                  const SizedBox(height: 12),
                  _buildMetadataRow("GAME PROJECT", data.gameTitle.toUpperCase()),
                  _buildMetadataRow("GENRE LAYER", data.gameGenre.toUpperCase()),
                  _buildMetadataRow("COMPILING STATE", "READY"),
                  _buildMetadataRow("SEED VALUE", data.proceduralSeed.toInt().toString()),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 12),
                  _buildSectionTitle("NARRATIVE FRAMEWORK"),
                  const SizedBox(height: 8),
                  Text(
                    data.storyOutline,
                    style: CyberTheme.bodyStyle(fontSize: 13, color: CyberTheme.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Mobile Pipeline & Installation Container
            const _APKDeployerSection(),
            const SizedBox(height: 20),

            // NPC list
            Text(
              "Synthesized Characters (NPC)",
              style: CyberTheme.headingStyle(fontSize: 14, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Column(
              children: data.npcs.map((npc) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: GlassContainer(
                    borderColor: themeColor.withOpacity(0.15),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              npc.name.toUpperCase(),
                              style: CyberTheme.headingStyle(fontSize: 13, color: themeColor),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: themeColor.withOpacity(0.08),
                                border: Border.all(color: themeColor.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "${npc.role.toUpperCase()} // ${npc.emotion.toUpperCase()}",
                                style: CyberTheme.monospaceStyle(fontSize: 8, color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "\"${npc.dialogue}\"",
                          style: CyberTheme.monospaceStyle(fontSize: 11, color: CyberTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );

        final Widget rightColumnContent = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SimulatorSection(),
            const SizedBox(height: 20),
            const _SoundtrackSection(),
            const SizedBox(height: 20),
            const _CodeInspectorSection(),
          ],
        );

        final Widget layoutBody = isMobile
            ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    leftColumnContent,
                    const SizedBox(height: 20),
                    rightColumnContent,
                  ],
                ),
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 6,
                    child: SingleChildScrollView(
                      child: leftColumnContent,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 4,
                    child: SingleChildScrollView(
                      child: rightColumnContent,
                    ),
                  ),
                ],
              );

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("GENERATED GAME BLUEPRINT", style: CyberTheme.titleStyle(fontSize: 22)),
                      Text(
                        "ACTIVE COMPILE SUMMARY // ENCRYPTED IN CORE MODULES",
                        style: CyberTheme.monospaceStyle(fontSize: 10, color: themeColor),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => state.setScreenIndex(5), // Go back to rendering
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(child: layoutBody),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.white54),
    );
  }

  Widget _buildMetadataRow(String key, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: CyberTheme.monospaceStyle(fontSize: 11, color: CyberTheme.textMuted)),
          Text(val, style: CyberTheme.headingStyle(fontSize: 11, color: Colors.white)),
        ],
      ),
    );
  }
}

class RadialVisualizerPainter extends CustomPainter {
  final bool isPlaying;
  final Color color;
  final Random _random = Random();

  RadialVisualizerPainter({required this.isPlaying, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final double baseRadius = 70.0;
    final int barCount = 45;

    for (int i = 0; i < barCount; i++) {
      final double angle = (i * 2 * pi) / barCount;
      double factor = 1.0;
      if (isPlaying) {
        // Bouncing heights based on pseudorandom frequencies
        factor = 1.0 + (_random.nextDouble() * 0.28);
      }

      final double startRadius = baseRadius;
      final double endRadius = baseRadius * factor;

      final Offset start = Offset(
        center.dx + startRadius * cos(angle),
        center.dy + startRadius * sin(angle),
      );
      final Offset end = Offset(
        center.dx + endRadius * cos(angle),
        center.dy + endRadius * sin(angle),
      );

      canvas.drawLine(start, end, paint..color = color.withOpacity(isPlaying ? 0.6 : 0.25));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SciFiQRCodePainter extends CustomPainter {
  final Color color;
  SciFiQRCodePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw the 3 corners squares of a QR Code
    final double sqSize = size.width * 0.25;
    
    // Top-Left corner
    canvas.drawRect(Rect.fromLTWH(0, 0, sqSize, sqSize), paint);
    canvas.drawRect(Rect.fromLTWH(2, 2, sqSize - 4, sqSize - 4), Paint()..color = Colors.black);
    canvas.drawRect(Rect.fromLTWH(4, 4, sqSize - 8, sqSize - 8), paint);

    // Top-Right corner
    canvas.drawRect(Rect.fromLTWH(size.width - sqSize, 0, sqSize, sqSize), paint);
    canvas.drawRect(Rect.fromLTWH(size.width - sqSize + 2, 2, sqSize - 4, sqSize - 4), Paint()..color = Colors.black);
    canvas.drawRect(Rect.fromLTWH(size.width - sqSize + 4, 4, sqSize - 8, sqSize - 8), paint);

    // Bottom-Left corner
    canvas.drawRect(Rect.fromLTWH(0, size.height - sqSize, sqSize, sqSize), paint);
    canvas.drawRect(Rect.fromLTWH(2, size.height - sqSize + 2, sqSize - 4, sqSize - 4), Paint()..color = Colors.black);
    canvas.drawRect(Rect.fromLTWH(4, size.height - sqSize + 4, sqSize - 8, sqSize - 8), paint);

    // Draw random block matrices
    final random = Random(42);
    final double blockW = size.width / 10;
    for (int r = 0; r < 10; r++) {
      for (int c = 0; c < 10; c++) {
        // Skip corner areas
        if (r < 3 && c < 3) continue;
        if (r < 3 && c > 6) continue;
        if (r > 6 && c < 3) continue;

        if (random.nextBool()) {
          canvas.drawRect(
            Rect.fromLTWH(c * blockW, r * blockW, blockW - 1, blockW - 1),
            paint..color = color.withOpacity(0.8),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HillClimbVisualizerPainter extends CustomPainter {
  final double speed;
  final double rpm;
  final double tilt;
  final double distance;
  final Color themeColor;

  HillClimbVisualizerPainter({
    required this.speed,
    required this.rpm,
    required this.tilt,
    required this.distance,
    required this.themeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = themeColor.withOpacity(0.3)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Draw terrain curve (sine wave based on distance)
    final path = Path();
    final double midY = size.height * 0.75;
    path.moveTo(0, midY);

    for (double x = 0; x <= size.width; x += 5) {
      final double terrainY = midY + sin((x + distance * 10) * 0.02) * 15;
      if (x == 0) {
        path.moveTo(x, terrainY);
      } else {
        path.lineTo(x, terrainY);
      }
    }
    canvas.drawPath(path, paint);

    // Car chassis center (on the terrain at the middle of the screen)
    final double carX = size.width * 0.5;
    final double carY = midY + sin((carX + distance * 10) * 0.02) * 15 - 12;

    // Save canvas to apply rotation (tilt)
    canvas.save();
    canvas.translate(carX, carY);
    canvas.rotate(tilt);

    // Draw car body (simple futuristic neon box/line chassis)
    final chassisPaint = Paint()
      ..color = themeColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: 34, height: 10), chassisPaint);
    
    // Glowing cabin
    final cabinPaint = Paint()
      ..color = themeColor.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(-8, -12, 16, 7), cabinPaint);
    canvas.drawRect(Rect.fromLTWH(-8, -12, 16, 7), Paint()..color = themeColor..style = PaintingStyle.stroke..strokeWidth = 1.5);

    // Draw wheels (rotating based on distance)
    final wheelAngle = distance * 0.5;
    final double wheelRadius = 6.0;

    void drawWheel(double wx, double wy) {
      canvas.drawCircle(Offset(wx, wy), wheelRadius, Paint()..color = Colors.black..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(wx, wy), wheelRadius, Paint()..color = themeColor..style = PaintingStyle.stroke..strokeWidth = 1.5);
      
      // Draw spoke to show rotation
      canvas.drawLine(
        Offset(wx, wy),
        Offset(wx + wheelRadius * cos(wheelAngle), wy + wheelRadius * sin(wheelAngle)),
        Paint()..color = themeColor..strokeWidth = 1.5,
      );
    }

    drawWheel(-12, 6);
    drawWheel(12, 6);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class RunnerVisualizerPainter extends CustomPainter {
  final int lane; // 0, 1, 2
  final double distance;
  final bool hoverboard;
  final bool gameOver;
  final Color themeColor;

  RunnerVisualizerPainter({
    required this.lane,
    required this.distance,
    required this.hoverboard,
    required this.gameOver,
    required this.themeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFF030712));

    // Draw 3 lanes perspective lines going to a vanishing point
    final Offset vp = Offset(size.width / 2, size.height * 0.2);
    final paint = Paint()
      ..color = themeColor.withOpacity(0.25)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final double bottomY = size.height * 0.95;
    final List<double> bottomXs = [
      size.width * 0.1,
      size.width * 0.36,
      size.width * 0.64,
      size.width * 0.9,
    ];

    for (var bx in bottomXs) {
      canvas.drawLine(vp, Offset(bx, bottomY), paint);
    }

    // Horizontal track markings (sliding down)
    final linePaint = Paint()
      ..color = themeColor.withOpacity(0.12)
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 8; i++) {
      final double t = pow(i / 8, 2).toDouble();
      final double y = vp.dy + t * (bottomY - vp.dy);
      final double width = size.width * 0.8 * t;
      canvas.drawLine(
        Offset((size.width / 2) - width / 2, y),
        Offset((size.width / 2) + width / 2, y),
        linePaint..color = themeColor.withOpacity(0.25 * (1.0 - t)),
      );
    }

    if (gameOver) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: "COLLISION DETECTED\nNODE CRASHED // REBOOT",
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: "monospace",
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(size.width / 2 - textPainter.width / 2, size.height / 2 - textPainter.height / 2));
      return;
    }

    // Draw the runner avatar (placed at bottomY - 30)
    final double playerY = bottomY - 25;
    final double leftX = (bottomXs[0] + bottomXs[1]) / 2;
    final double centerX = (bottomXs[1] + bottomXs[2]) / 2;
    final double rightX = (bottomXs[2] + bottomXs[3]) / 2;

    double targetX = centerX;
    if (lane == 0) targetX = leftX;
    if (lane == 2) targetX = rightX;

    final double playerX = targetX;

    // Draw glowing hoverboard
    if (hoverboard) {
      final boardPaint = Paint()
        ..color = Colors.cyanAccent.withOpacity(0.8)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(playerX, playerY + 8), width: 18, height: 4),
        boardPaint,
      );
      canvas.drawCircle(Offset(playerX, playerY + 8), 10, Paint()..color = Colors.cyanAccent.withOpacity(0.2)..style = PaintingStyle.stroke);
    }

    // Draw player body
    final playerPaint = Paint()
      ..color = hoverboard ? Colors.cyanAccent : themeColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(playerX, playerY - 6), 4, playerPaint);
    final bodyPath = Path()
      ..moveTo(playerX - 6, playerY)
      ..lineTo(playerX + 6, playerY)
      ..lineTo(playerX + 3, playerY - 10)
      ..lineTo(playerX - 3, playerY - 10)
      ..close();
    canvas.drawPath(bodyPath, playerPaint);

    // Draw upcoming obstacle (sliding down the lane)
    final double obstacleT = ((distance * 0.08) % 1.0);
    final double obstacleY = vp.dy + obstacleT * (bottomY - vp.dy);
    
    final int obstacleLane = (distance ~/ 12) % 3;
    double obsX = centerX;
    if (obstacleLane == 0) obsX = leftX;
    if (obstacleLane == 2) obsX = rightX;

    final double obstacleX = vp.dx + obstacleT * (obsX - vp.dx);
    final double obstacleWidth = 12 * obstacleT;
    final double obstacleHeight = 14 * obstacleT;

    if (obstacleT < 0.95) {
      final obsPaint = Paint()
        ..color = Colors.redAccent.withOpacity(0.8)
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(obstacleX, obstacleY - obstacleHeight / 2),
          width: obstacleWidth,
          height: obstacleHeight,
        ),
        obsPaint,
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(obstacleX, obstacleY - obstacleHeight / 2),
          width: obstacleWidth,
          height: obstacleHeight,
        ),
        Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.0,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PlatformerVisualizerPainter extends CustomPainter {
  final double distance;
  final double stealth;
  final bool gameOver;
  final String playerState;
  final double lightIntensity;
  final Color themeColor;

  PlatformerVisualizerPainter({
    required this.distance,
    required this.stealth,
    required this.gameOver,
    required this.playerState,
    required this.lightIntensity,
    required this.themeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFF030712));

    final floorY = size.height * 0.8;
    canvas.drawLine(
      Offset(0, floorY),
      Offset(size.width, floorY),
      Paint()..color = themeColor.withOpacity(0.35)..strokeWidth = 2.0,
    );

    if (gameOver) {
      final textPainter = TextPainter(
        text: const TextSpan(
          text: "DETECTED // SIMULATION HALTED\nREBOOT TO RESET CORE",
          style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: "monospace"),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(size.width / 2 - textPainter.width / 2, size.height / 2 - textPainter.height / 2));
      return;
    }

    // Draw background grid lines/details
    final detailPaint = Paint()..color = Colors.white10..strokeWidth = 1.0;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, floorY), detailPaint);
    }

    // Draw searchlight tower (top right)
    final towerX = size.width * 0.75;
    final towerY = size.height * 0.15;
    canvas.drawRect(Rect.fromLTWH(towerX - 4, towerY, 8, floorY - towerY), Paint()..color = Colors.white12);

    final double timeSec = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final double sweep = sin(timeSec * 2.0);
    final spotX = towerX + sweep * (size.width * 0.45);

    // Searchlight beam
    final lightPath = Path()
      ..moveTo(towerX, towerY)
      ..lineTo(spotX - 35, floorY)
      ..lineTo(spotX + 35, floorY)
      ..close();
    canvas.drawPath(lightPath, Paint()..color = Colors.amber.withOpacity(0.08)..style = PaintingStyle.fill);

    // Voxel Player
    final playerX = size.width * 0.25;
    double playerY = floorY - 14;
    if (playerState == "Climbing") {
      playerY -= 20; // Jump offset
    } else if (playerState == "Hiding") {
      playerY += 3; // Crouch/Hide offset
    }

    // Draw character box
    final charH = (playerState == "Hiding") ? 6.0 : 12.0;
    final pColor = (playerState == "Spotted") ? Colors.redAccent : themeColor;
    canvas.drawRect(Rect.fromLTWH(playerX - 4, playerY + 14 - charH, 8, charH), Paint()..color = pColor);
    canvas.drawCircle(Offset(playerX, playerY + 14 - charH - 2.5), 2.5, Paint()..color = pColor);

    if (playerState == "Spotted") {
      final alertPainter = TextPainter(
        text: const TextSpan(text: "!", style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: "monospace")),
        textDirection: TextDirection.ltr,
      )..layout();
      alertPainter.paint(canvas, Offset(playerX - alertPainter.width / 2, playerY - 18));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _CodeInspectorSection extends StatefulWidget {
  const _CodeInspectorSection();

  @override
  State<_CodeInspectorSection> createState() => _CodeInspectorSectionState();
}

class _CodeInspectorSectionState extends State<_CodeInspectorSection> {
  int _selectedLanguage = 0; // 0 = C++ Engine, 1 = C# Logic

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<EngineState>(context);
    final themeColor = _getThemeColor(state.currentTheme);
    final activeGame = state.activeGameType;

    // Retrieve active physics/alarm parameters
    final double gScale = state.vehiclePhysics.gravityScale;
    final double torque = state.vehiclePhysics.torque;
    final double susp = state.vehiclePhysics.suspensionStiffness;
    
    final int runnerCoins = state.runnerCoins;
    final int runnerScore = state.runnerScore;
    final double runnerSpeedMult = state.runnerSpeedMult;

    final double platformerSens = state.platformerSensitivity;
    final double platformerJump = state.platformerJumpHeight;
    final double platformerLightSpeed = state.platformerSearchlightSpeed;

    // Generate C++ Code
    String cppCode = "";
    if (activeGame == "racing") {
      cppCode = """#include <iostream>
#include <cmath>
#include "PhysicsEngine.h"

// Dynamically calibrated via HUD tuning sliders
const float GRAVITY = -9.81f * ${gScale.toStringAsFixed(2)}f;
const float TORQUE = ${torque.toStringAsFixed(1)}f;
const float SUSPENSION = ${susp.toStringAsFixed(1)}f;

class WheelPhysics {
public:
    float CalculateTireFriction(float slip) {
        // Stark-HUD tire slip calculation
        return std::atan(slip) * SUSPENSION * 0.02f;
    }

    void ApplyTorque(float throttle) {
        float angularAccel = (throttle * TORQUE) / (12.0f * std::abs(GRAVITY));
        std::cout << "[Physics C++] Applied Torque force: " << angularAccel << " N-m" << std::endl;
    }
};""";
    } else if (activeGame == "runner") {
      cppCode = """#include <iostream>
#include <algorithm>
#include "ArcadeEngine.h"

class GridRunnerCore {
private:
    int totalLanes = 3;
    float currentLaneWidth = 3.5f;

public:
    bool CheckBarrierCollision(float playerX, float obstacleX, float distance) {
        // High-performance AABB calculation
        float deltaX = std::abs(playerX - obstacleX);
        if (deltaX < 0.6f && distance < 0.3f) {
            std::cout << "[Runner C++] COLLISION DETECTED AT GRID NODE!" << std::endl;
            return true;
        }
        return false;
    }
};""";
    } else if (activeGame == "platformer") {
      cppCode = """#include <iostream>
#include <cmath>
#include "AtmosphereRenderer.h"

// Searchlight sweeping speed
const float SWEEP_FREQ = ${platformerLightSpeed.toStringAsFixed(2)}f;
const float VOLUMETRIC_INTENSITY = 0.85f;

class VolumetricShadowMap {
public:
    float GetLightIntensityAtNode(float playerX, float lightX, float yaw) {
        float distance = std::abs(playerX - lightX);
        float baseBeam = std::exp(-distance * 0.05f) * VOLUMETRIC_INTENSITY;
        return baseBeam * std::cos(yaw * SWEEP_FREQ) * 100.0f;
    }
};""";
    } else {
      cppCode = """#include <iostream>
#include <vector>
#include "DreamEngine.h"

class CyberCore {
private:
    float voxelPackingRatio = 12.8f;
    int maxThreads = 4096;
    bool rayTracing = true;

public:
    void CompileVoxelGrid() {
        std::cout << "[DreamEngine C++] Packing Voxel Grid..." << std::endl;
        std::cout << "[DreamEngine C++] Ray Tracing active at 16 bounces." << std::endl;
    }
};""";
    }

    // Generate C# Code
    String csCode = "";
    if (activeGame == "racing") {
      csCode = """using System;
using DreamEngine.Physics;

public class TelemetryHUD : IHUDModule {
    private float currentTorque = ${torque.toStringAsFixed(1)}f;
    private float gravityFactor = ${gScale.toStringAsFixed(2)}f;

    public void UpdateTelemetry(float currentSpeed, float engineRPM) {
        // Live feedback from DreamEngine core
        Console.WriteLine(\$"[C# Telemetry] SPEED: {currentSpeed:F1} KM/H | RPM: {engineRPM:F0}");
        if (engineRPM > 4000f) {
            Console.WriteLine(\$"[C# Telemetry] WARNING: Over-torque warning under gravity scale {gravityFactor}!");
        }
    }
}""";
    } else if (activeGame == "runner") {
      csCode = """using System;
using DreamEngine.Arcade;

public class ScoreController : IGameLogic {
    private int coinsCollected = $runnerCoins;
    private double currentScore = $runnerScore;

    public void OnCoinCollected() {
        coinsCollected++;
        currentScore += 100 * ${runnerSpeedMult.toStringAsFixed(2)};
        Console.WriteLine(\$"[C#] Coin collected! Total score: {currentScore}");
    }
}""";
    } else if (activeGame == "platformer") {
      csCode = """using System;
using DreamEngine.Stealth;

public class SecuritySensor : IStealthModule {
    private float sensitivity = ${platformerSens.toStringAsFixed(2)}f;
    private float jumpMultiplier = ${platformerJump.toStringAsFixed(2)}f;

    public void CheckStealthAlert(float currentStealth, float lightIntensity, string state) {
        if (lightIntensity > 75.0f && state != "Hiding") {
            float alertFactor = lightIntensity * sensitivity;
            Console.WriteLine(\$"[C# Alert] SPOTTED! Guard drone tracking player. Alert Level: {alertFactor:F1}%");
        } else if (state == "Climbing") {
            Console.WriteLine(\$"[C# Physics] Character climbing ledge with leap height {jumpMultiplier}m");
        }
    }
}""";
    } else {
      csCode = """using UnityEngine;
using DreamEngine.AI;

public class VesperNetrunner : MonoBehaviour {
    public string npcRole = "Rogue Netrunner";
    public string activeStatus = "ONLINE";

    void Start() {
        Debug.Log("Vesper netrunner interface linked to node 0x4B291A.");
    }
}""";
    }

    final String activeCodeText = (_selectedLanguage == 0) ? cppCode : csCode;
    final String activeFileName = (_selectedLanguage == 0) ? "EngineCore.cpp" : "GameLogic.cs";

    return GlassContainer(
      borderColor: themeColor.withOpacity(0.2),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "DYNAMIC ENGINE SOURCE INSPECTOR",
                style: CyberTheme.headingStyle(fontSize: 11, color: Colors.white),
              ),
              const Icon(Icons.code_rounded, color: Colors.white30, size: 16),
            ],
          ),
          const SizedBox(height: 12),

          // Glass tab bar
          Row(
            children: [
              _buildLanguageTab("C++ CORE ENGINE", 0, themeColor),
              const SizedBox(width: 8),
              _buildLanguageTab("C# GAME LOGIC", 1, themeColor),
            ],
          ),
          const SizedBox(height: 12),

          // Code Container Viewport
          Container(
            height: 200,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: themeColor.withOpacity(0.2)),
            ),
            child: SingleChildScrollView(
              child: SelectableText.rich(
                _highlightCode(activeCodeText, themeColor),
                style: CyberTheme.monospaceStyle(fontSize: 10).copyWith(height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Copy / Download Buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 34,
                  child: OutlinedButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: activeCodeText)).then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: themeColor.withOpacity(0.25),
                            duration: const Duration(seconds: 1),
                            content: Text(
                              "COPIED $activeFileName TO PIPELINE CLIPBOARD",
                              style: CyberTheme.monospaceStyle(fontSize: 9, color: Colors.white),
                            ),
                          ),
                        );
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: themeColor.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.copy_rounded, color: Colors.white70, size: 12),
                        const SizedBox(width: 6),
                        Text(
                          "COPY CODE",
                          style: CyberTheme.monospaceStyle(fontSize: 9, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 34,
                  child: OutlinedButton(
                    onPressed: () {
                      final bytes = Uint8List.fromList(utf8.encode(activeCodeText));
                      dl.downloadBytes(fileName: activeFileName.toLowerCase(), bytes: bytes);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: themeColor.withOpacity(0.25),
                          content: Text(
                            "DOWNLOAD INITIALIZED: ${activeFileName.toLowerCase()}",
                            style: CyberTheme.monospaceStyle(fontSize: 9, color: Colors.white),
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: themeColor.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.download_rounded, color: Colors.white70, size: 12),
                        const SizedBox(width: 6),
                        Text(
                          "DOWNLOAD FILE",
                          style: CyberTheme.monospaceStyle(fontSize: 9, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTab(String title, int idx, Color themeColor) {
    final isSelected = _selectedLanguage == idx;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedLanguage = idx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? themeColor.withOpacity(0.12) : Colors.white.withOpacity(0.02),
            border: Border.all(
              color: isSelected ? themeColor : Colors.white10,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            title,
            style: CyberTheme.monospaceStyle(
              fontSize: 9,
              color: isSelected ? Colors.white : CyberTheme.textMuted,
            ).copyWith(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          ),
        ),
      ),
    );
  }

  TextSpan _highlightCode(String code, Color themeColor) {
    final List<TextSpan> spans = [];
    final keywords = {
      'class', 'public', 'private', 'void', 'float', 'int', 'string', 'bool',
      'const', 'if', 'else', 'return', 'using', 'include', 'namespace',
      'std', 'cout', 'endl', 'Debug', 'Log', 'Console', 'WriteLine', 'MonoBehaviour'
    };

    final pattern = RegExp(r'(\w+|[^\w\s]|\s+)');
    final matches = pattern.allMatches(code);

    for (final match in matches) {
      final token = match.group(0)!;
      if (keywords.contains(token.trim())) {
        spans.add(TextSpan(
          text: token,
          style: TextStyle(
            color: token.trim().startsWith(RegExp(r'^[A-Z]')) ? Colors.cyanAccent : Colors.pinkAccent,
            fontWeight: FontWeight.bold,
          ),
        ));
      } else if (token.startsWith('"') || token.endsWith('"') || token.contains('//') || token.startsWith(r'$"')) {
        spans.add(TextSpan(
          text: token,
          style: const TextStyle(color: Colors.greenAccent),
        ));
      } else if (double.tryParse(token.trim()) != null || token.trim().endsWith('f')) {
        spans.add(TextSpan(
          text: token,
          style: const TextStyle(color: Colors.amberAccent),
        ));
      } else {
        spans.add(TextSpan(
          text: token,
          style: const TextStyle(color: Colors.white70),
        ));
      }
    }
    return TextSpan(children: spans);
  }
}

Color _getThemeColor(AppTheme theme) {
  if (theme == AppTheme.ironMan) return Colors.amber;
  if (theme == AppTheme.nvidiaGreen) return Colors.lightGreenAccent;
  if (theme == AppTheme.appleVision) return Colors.white;
  return CyberTheme.neonBlue;
}

class _APKDeployerSection extends StatelessWidget {
  const _APKDeployerSection();

  @override
  Widget build(BuildContext context) {
    return Selector<EngineState, _APKDeployerData>(
      selector: (context, state) => _APKDeployerData(
        isCompilingAPK: state.isCompilingAPK,
        apkProgress: state.apkProgress,
        apkStatus: state.apkStatus,
        apkReady: state.apkReady,
        gameTitle: state.gameTitle,
        isInstallingGame: state.isInstallingGame,
        installProgress: state.installProgress,
        gameInstalled: state.gameInstalled,
        currentTheme: state.currentTheme,
      ),
      builder: (context, data, _) {
        final state = Provider.of<EngineState>(context, listen: false);
        final themeColor = _getThemeColor(data.currentTheme);
        return GlassContainer(
          borderColor: themeColor.withOpacity(0.2),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "MOBILE PIPELINE GATEWAY (APK DEPLOYER)",
                style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                "COMPILE AND INSTALL RUNTIME PACKAGES DIRECT FROM HUD",
                style: CyberTheme.monospaceStyle(fontSize: 9, color: themeColor),
              ),
              const SizedBox(height: 16),
              
              if (data.isCompilingAPK) ...[
                LinearProgressIndicator(
                  value: data.apkProgress,
                  backgroundColor: Colors.white10,
                  color: themeColor,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        data.apkStatus,
                        style: CyberTheme.monospaceStyle(fontSize: 9, color: CyberTheme.textMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "${(data.apkProgress * 100).toInt()}%",
                      style: CyberTheme.monospaceStyle(fontSize: 9, color: themeColor),
                    ),
                  ],
                ),
              ] else if (data.apkReady) ...[
                Row(
                  children: [
                    // Custom Painter QR Code
                    Container(
                      width: 80,
                      height: 80,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        border: Border.all(color: themeColor.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: CustomPaint(
                        painter: SciFiQRCodePainter(color: themeColor),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Actions
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "BUILD COMPLETED: ${data.gameTitle.toUpperCase()}_RELEASE.APK",
                            style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.greenAccent),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "SCAN QR CODE OR CLICK BUTTON TO DEPLOY DIRECTLY TO YOUR MOBILE HOST",
                            style: CyberTheme.bodyStyle(fontSize: 10, color: CyberTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: NeonButton(
                        onPressed: () {
                          final mockContent = "DreamEngine AI Compiled Game Package\n"
                              "======================================\n"
                              "Title: ${data.gameTitle}\n"
                              "Seed: ${state.proceduralSeed}\n"
                              "Genre: ${state.gameGenre}\n"
                              "Difficulty: ${state.gameDifficulty}\n"
                              "Weather System: ${state.weatherSystem}\n"
                              "Active Game Type: ${state.activeGameType}\n"
                              "Narrative Framework: ${state.storyOutline}\n"
                              "NPCs:\n"
                              "${state.npcs.map((n) => ' - Name: ${n.name}, Role: ${n.role}, Emotion: ${n.emotion}').join('\n')}\n"
                              "Missions:\n"
                              "${state.missions.map((m) => ' - Title: ${m.title}, Rewards: ${m.rewards}').join('\n')}\n"
                              "Compiled timestamp: ${DateTime.now().toUtc().toIso8601String()}\n";
                          final bytes = Uint8List.fromList(utf8.encode(mockContent));
                          final fileName = "${data.gameTitle.replaceAll(' ', '_').toLowerCase()}_release.apk";
                          
                          dl.downloadBytes(fileName: fileName, bytes: bytes);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: themeColor.withOpacity(0.2),
                              content: Text(
                                "APK DOWNLOAD INITIALIZED: $fileName",
                                style: CyberTheme.monospaceStyle(fontSize: 11, color: Colors.white),
                              ),
                            ),
                          );
                        },
                        glowColor: themeColor,
                        gradientColors: [themeColor, themeColor.withBlue(210).withRed(40)],
                        child: Text(
                          "DOWNLOAD APK",
                          style: CyberTheme.headingStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: data.isInstallingGame
                          ? Column(
                              children: [
                                LinearProgressIndicator(
                                  value: data.installProgress,
                                  color: Colors.greenAccent,
                                  backgroundColor: Colors.white10,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "INSTALLING TO CORE...",
                                  style: CyberTheme.monospaceStyle(fontSize: 8, color: Colors.greenAccent),
                                ),
                              ],
                            )
                          : SizedBox(
                              height: 38,
                              child: OutlinedButton(
                                onPressed: () => state.installGameFromApp(),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: data.gameInstalled ? Colors.greenAccent : themeColor.withOpacity(0.5),
                                  ),
                                  backgroundColor: data.gameInstalled
                                      ? Colors.greenAccent.withOpacity(0.12)
                                      : Colors.transparent,
                                ),
                                child: Text(
                                  data.gameInstalled ? "RUN GAME" : "INSTALL IN LAUNCHER",
                                  style: CyberTheme.monospaceStyle(
                                    fontSize: 9,
                                    color: data.gameInstalled ? Colors.greenAccent : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ] else ...[
                Text(
                  "NO COMPILED PACKAGE FOUND FOR CURRENT PROCEDURAL SEED.",
                  style: CyberTheme.monospaceStyle(fontSize: 10, color: CyberTheme.textMuted),
                ),
                const SizedBox(height: 12),
                NeonButton(
                  onPressed: () => state.compileAndroidAPK(),
                  glowColor: themeColor,
                  gradientColors: [themeColor, themeColor.withBlue(210).withRed(40)],
                  child: Text(
                    "COMPILE DYNAMIC APK",
                    style: CyberTheme.headingStyle(fontSize: 11, color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SoundtrackSection extends StatefulWidget {
  const _SoundtrackSection();

  @override
  State<_SoundtrackSection> createState() => _SoundtrackSectionState();
}

class _SoundtrackSectionState extends State<_SoundtrackSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _visualizerController;
  final _soundPromptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _visualizerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _visualizerController.dispose();
    _soundPromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<EngineState, _SoundtrackData>(
      selector: (context, state) => _SoundtrackData(
        isPlayingSoundtrack: state.isPlayingSoundtrack,
        currentTrackIndex: state.currentTrackIndex,
        playlist: state.playlist,
        trackProgress: state.trackProgress,
        isGeneratingSound: state.isGeneratingSound,
        soundStatus: state.soundStatus,
        soundProgress: state.soundProgress,
        currentTheme: state.currentTheme,
      ),
      builder: (context, data, _) {
        final state = Provider.of<EngineState>(context, listen: false);
        final themeColor = _getThemeColor(data.currentTheme);

        // Run visualizer only when playing soundtrack
        if (data.isPlayingSoundtrack) {
          if (!_visualizerController.isAnimating) {
            _visualizerController.repeat();
          }
        } else {
          if (_visualizerController.isAnimating) {
            _visualizerController.stop();
          }
        }

        return GlassContainer(
          borderColor: themeColor.withOpacity(0.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("SYNTH SOUNDTRACK ENGINE", style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white)),
              const SizedBox(height: 12),

              // Compact visualizer block (Holographic disc rotating)
              SizedBox(
                height: 120,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: themeColor.withOpacity(0.05),
                          border: Border.all(color: themeColor.withOpacity(0.2)),
                        ),
                      ),
                      Positioned.fill(
                        child: RepaintBoundary(
                          child: AnimatedBuilder(
                            animation: _visualizerController,
                            builder: (context, _) {
                              return CustomPaint(
                                painter: RadialVisualizerPainter(
                                  isPlaying: data.isPlayingSoundtrack,
                                  color: themeColor,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Icon(Icons.music_note_rounded, color: themeColor, size: 24),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Track Info
              Text(
                data.playlist[data.currentTrackIndex].toUpperCase(),
                style: CyberTheme.headingStyle(fontSize: 10, color: Colors.white),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                data.isPlayingSoundtrack ? "SYNTHESIZER DEPLOYED // RUNNING" : "SYNTHESIZER IDLE",
                style: CyberTheme.monospaceStyle(fontSize: 8, color: themeColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Player buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.skip_previous_rounded, color: Colors.white70, size: 20),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => state.toggleSoundtrack(),
                    child: Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: themeColor.withOpacity(0.5)),
                        color: themeColor.withOpacity(0.12),
                      ),
                      child: Icon(
                        data.isPlayingSoundtrack ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => state.nextTrack(),
                    icon: const Icon(Icons.skip_next_rounded, color: Colors.white70, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Linear slider track
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
                ),
                child: Slider(
                  value: data.trackProgress,
                  onChanged: (val) {},
                  activeColor: themeColor,
                  inactiveColor: Colors.white10,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(color: Colors.white10),
              const SizedBox(height: 4),
              Text(
                "SOUND AI SOUNDTRACK GENERATOR",
                style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (data.isGeneratingSound) ...[
                Text(
                  data.soundStatus.toUpperCase(),
                  style: CyberTheme.monospaceStyle(fontSize: 8, color: themeColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: data.soundProgress,
                  backgroundColor: Colors.white12,
                  color: themeColor,
                  minHeight: 2,
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _soundPromptController,
                        style: CyberTheme.bodyStyle(fontSize: 10, color: Colors.white),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.2),
                          hintText: "epic arcade synthwave beat...",
                          hintStyle: CyberTheme.bodyStyle(fontSize: 9, color: Colors.white30),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: themeColor.withOpacity(0.2)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: themeColor),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      height: 28,
                      child: ElevatedButton(
                        onPressed: () {
                          final text = _soundPromptController.text.trim();
                          if (text.isNotEmpty) {
                            state.generateSoundWithAI(text);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor.withOpacity(0.12),
                          side: BorderSide(color: themeColor),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SimulatorSection extends StatelessWidget {
  const _SimulatorSection();

  @override
  Widget build(BuildContext context) {
    return Selector<EngineState, _SimulatorSectionData>(
      selector: (context, state) => _SimulatorSectionData(
        activeGameType: state.activeGameType,
        speed: state.vehiclePhysics.speed,
        rpm: state.vehiclePhysics.rpm,
        tilt: state.vehiclePhysics.tilt,
        distance: state.vehiclePhysics.distance,
        runnerLane: state.runnerLane,
        runnerDistance: state.runnerDistance,
        runnerHoverboard: state.runnerHoverboard,
        runnerGameOver: state.runnerGameOver,
        runnerScore: state.runnerScore,
        runnerCoins: state.runnerCoins,
        platformerDistance: state.platformerDistance,
        platformerStealth: state.platformerStealth,
        platformerGameOver: state.platformerGameOver,
        platformerScore: state.platformerScore,
        platformerState: state.platformerState,
        platformerLightIntensity: state.platformerLightIntensity,
        platformerSensitivity: state.platformerSensitivity,
        platformerJumpHeight: state.platformerJumpHeight,
        platformerSearchlightSpeed: state.platformerSearchlightSpeed,
        currentTheme: state.currentTheme,
      ),
      builder: (context, data, _) {
        final state = Provider.of<EngineState>(context, listen: false);
        final themeColor = _getThemeColor(data.currentTheme);

        if (data.activeGameType == "racing") {
          return _buildRacingSimulator(context, state, data, themeColor);
        } else if (data.activeGameType == "runner") {
          return _buildRunnerSimulator(context, state, data, themeColor);
        } else if (data.activeGameType == "platformer") {
          return _buildPlatformerSimulator(context, state, data, themeColor);
        } else {
          return _buildAdvancedSoftwareDiagnostics(context, state, data, themeColor);
        }
      },
    );
  }

  Widget _buildRacingSimulator(BuildContext context, EngineState state, _SimulatorSectionData data, Color themeColor) {
    final physics = state.vehiclePhysics;
    return GlassContainer(
      borderColor: themeColor.withOpacity(0.2),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("PHYSICS SIMULATION: VEHICLE", style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "TICKING // 30 FPS",
                  style: CyberTheme.monospaceStyle(fontSize: 8, color: Colors.redAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Canvas Terrain Visualizer
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              border: Border.all(color: themeColor.withOpacity(0.25)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: HillClimbVisualizerPainter(
                    speed: data.speed,
                    rpm: data.rpm,
                    tilt: data.tilt,
                    distance: data.distance,
                    themeColor: themeColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Telemetry readout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTelemetryIndicator("SPEED", "${data.speed.toStringAsFixed(1)} KM/H"),
              _buildTelemetryIndicator("ENGINE RPM", "${data.rpm.toInt()} RPM"),
              _buildTelemetryIndicator("DISTANCE", "${data.distance.toStringAsFixed(1)} M"),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),

          // Tuner Sliders
          Text("CALIBRATE PHYSICS MATRIX", style: CyberTheme.monospaceStyle(fontSize: 9, color: Colors.white70)),
          const SizedBox(height: 8),
          _buildTunerSlider("TORQUE MULTIPLIER", physics.torque, 50.0, 300.0, (val) {
            state.updatePhysicsParameters(torque: val);
          }),
          _buildTunerSlider("SUSPENSION COILS", physics.suspensionStiffness, 20.0, 150.0, (val) {
            state.updatePhysicsParameters(suspension: val);
          }),
          _buildTunerSlider("GRAVITY MULTIPLIER", physics.gravityScale, 0.5, 3.0, (val) {
            state.updatePhysicsParameters(gravity: val);
          }),

          const SizedBox(height: 12),

          // Interactive Pedals
          Row(
            children: [
              Expanded(
                child: Listener(
                  onPointerDown: (_) => state.setVehicleBraking(true),
                  onPointerUp: (_) => state.setVehicleBraking(false),
                  onPointerCancel: (_) => state.setVehicleBraking(false),
                  child: NeonButton(
                    onPressed: () {},
                    glowColor: Colors.redAccent,
                    gradientColors: const [Color(0xFF3A0007), Color(0xFF6B000F)],
                    child: Text("BRAKE", style: CyberTheme.headingStyle(fontSize: 10, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Listener(
                  onPointerDown: (_) => state.setVehicleAccelerating(true),
                  onPointerUp: (_) => state.setVehicleAccelerating(false),
                  onPointerCancel: (_) => state.setVehicleAccelerating(false),
                  child: NeonButton(
                    onPressed: () {},
                    glowColor: themeColor,
                    gradientColors: [themeColor, themeColor.withRed(150)],
                    child: Text("GAS (THRUST)", style: CyberTheme.headingStyle(fontSize: 10, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              "HOLD PEDALS TO INTERACT WITH VEHICLE RUNTIME",
              style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRunnerSimulator(BuildContext context, EngineState state, _SimulatorSectionData data, Color themeColor) {
    return GlassContainer(
      borderColor: themeColor.withOpacity(0.2),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("RUNNER ARCADE CORE", style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white)),
              Text(
                data.runnerGameOver ? "COLLIDED // HALTED" : "RUNNING // MULT: ${state.runnerSpeedMult.toStringAsFixed(2)}x",
                style: CyberTheme.monospaceStyle(
                  fontSize: 8,
                  color: data.runnerGameOver ? Colors.redAccent : Colors.greenAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Canvas Runner Viewport
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: themeColor.withOpacity(0.25)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: RunnerVisualizerPainter(
                    lane: data.runnerLane,
                    distance: data.runnerDistance,
                    hoverboard: data.runnerHoverboard,
                    gameOver: data.runnerGameOver,
                    themeColor: themeColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Telemetry readout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTelemetryIndicator("SCORE", "${data.runnerScore}"),
              _buildTelemetryIndicator("BATTERIES", "${data.runnerCoins}"),
              _buildTelemetryIndicator("DISTANCE", "${data.runnerDistance.toStringAsFixed(1)} M"),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),

          // Interactive controls
          if (data.runnerGameOver) ...[
            NeonButton(
              onPressed: () => state.resetSimulationState(),
              glowColor: Colors.greenAccent,
              gradientColors: const [Colors.green, Colors.teal],
              child: Text("REBOOT RUNNER NODE", style: CyberTheme.headingStyle(fontSize: 11, color: Colors.white)),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: NeonButton(
                    onPressed: () => state.moveRunnerLane(-1),
                    glowColor: themeColor,
                    gradientColors: [themeColor.withOpacity(0.3), themeColor],
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 16),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: NeonButton(
                    onPressed: () => state.toggleRunnerHoverboard(),
                    glowColor: Colors.cyanAccent,
                    gradientColors: [Colors.cyan.shade900, Colors.cyan],
                    child: Text(
                      data.runnerHoverboard ? "BOARD ON" : "DEPLOY BOARD",
                      style: CyberTheme.headingStyle(fontSize: 9, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: NeonButton(
                    onPressed: () => state.moveRunnerLane(1),
                    glowColor: themeColor,
                    gradientColors: [themeColor.withOpacity(0.3), themeColor],
                    child: const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                "DODGE INCOMING RED INSPECTOR DROIDS OR USE SHIELD",
                style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlatformerSimulator(BuildContext context, EngineState state, _SimulatorSectionData data, Color themeColor) {
    return GlassContainer(
      borderColor: themeColor.withOpacity(0.2),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("PHYSICS & LIGHT SIMULATION: ATMOSPHERIC", style: CyberTheme.headingStyle(fontSize: 11, color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: data.platformerState == "Spotted" ? Colors.redAccent.withOpacity(0.1) : Colors.greenAccent.withOpacity(0.1),
                  border: Border.all(color: data.platformerState == "Spotted" ? Colors.redAccent.withOpacity(0.3) : Colors.greenAccent.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  data.platformerState.toUpperCase(),
                  style: CyberTheme.monospaceStyle(
                    fontSize: 8,
                    color: data.platformerState == "Spotted" ? Colors.redAccent : Colors.greenAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Custom Platformer minigame canvas
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              border: Border.all(color: themeColor.withOpacity(0.25)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: PlatformerVisualizerPainter(
                    distance: data.platformerDistance,
                    stealth: data.platformerStealth,
                    gameOver: data.platformerGameOver,
                    playerState: data.platformerState,
                    lightIntensity: data.platformerLightIntensity,
                    themeColor: themeColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Telemetry readout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTelemetryIndicator("STEALTH", "${data.platformerStealth.toStringAsFixed(1)}%"),
              _buildTelemetryIndicator("LIGHT LEVEL", "${data.platformerLightIntensity.toStringAsFixed(1)}%"),
              _buildTelemetryIndicator("SCORE", "${data.platformerScore}"),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),

          // Platformer Parameter Tuning Sliders
          Text("CALIBRATE ALARM & PHYSICS MATRIX", style: CyberTheme.monospaceStyle(fontSize: 9, color: Colors.white70)),
          const SizedBox(height: 8),
          _buildTunerSlider("LIGHT SENSITIVITY", data.platformerSensitivity, 0.2, 3.0, (val) {
            state.updatePlatformerParameters(sensitivity: val);
          }),
          _buildTunerSlider("JUMP FORCE FACTOR", data.platformerJumpHeight, 0.5, 3.0, (val) {
            state.updatePlatformerParameters(jumpHeight: val);
          }),
          _buildTunerSlider("SEARCHLIGHT ROTATION", data.platformerSearchlightSpeed, 0.5, 5.0, (val) {
            state.updatePlatformerParameters(searchlightSpeed: val);
          }),
          const SizedBox(height: 12),

          // Interactive game buttons
          if (data.platformerGameOver) ...[
            NeonButton(
              onPressed: () => state.resetSimulationState(),
              glowColor: Colors.greenAccent,
              gradientColors: const [Colors.green, Colors.teal],
              child: Text("REBOOT PLATFORMER SIMULATOR", style: CyberTheme.headingStyle(fontSize: 10, color: Colors.white)),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: NeonButton(
                    onPressed: () => state.jumpPlatformer(),
                    glowColor: themeColor,
                    gradientColors: [themeColor.withOpacity(0.3), themeColor],
                    child: Text("LEAP / CLIMB", style: CyberTheme.headingStyle(fontSize: 10, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => state.toggleHidePlatformer(data.platformerState != "Hiding"),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: data.platformerState == "Hiding" ? Colors.greenAccent : themeColor.withOpacity(0.5),
                      ),
                      backgroundColor: data.platformerState == "Hiding" ? Colors.greenAccent.withOpacity(0.12) : Colors.transparent,
                      fixedSize: const Size.fromHeight(40),
                    ),
                    child: Text(
                      data.platformerState == "Hiding" ? "HIDING IN SHADOW" : "CROUCH / HIDE",
                      style: CyberTheme.monospaceStyle(
                        fontSize: 9,
                        color: data.platformerState == "Hiding" ? Colors.greenAccent : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                "HIDE IN SHADOWS TO AVOID SEARCHLIGHT SWEEPS AND CONSERVE STEALTH",
                style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdvancedSoftwareDiagnostics(BuildContext context, EngineState state, _SimulatorSectionData data, Color themeColor) {
    return GlassContainer(
      borderColor: themeColor.withOpacity(0.2),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("COMPILER HARDWARE DIAGNOSTICS", style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white)),
              Icon(Icons.query_stats_rounded, color: themeColor, size: 16),
            ],
          ),
          const SizedBox(height: 12),

          // Diagnostic statistics
          _buildHardwareLog("RENDER QUEUE CAPACITY", "65,536 POLY/SEC", "OPTIMIZED"),
          _buildHardwareLog("RAY TRACING BUFFERS", state.rayTracingEnabled ? "ENABLED (16 BOUNCES)" : "DISABLED (FALLBACK)", state.rayTracingEnabled ? "MAX-AESTHETIC" : "SPEED-MODE"),
          _buildHardwareLog("VOXEL PACKING RATIO", "12.8x ENCODED", "STABLE"),
          _buildHardwareLog("COMPUTE SHADER THREADS", "4,096 ASYNC BUFFERS", "ACTIVE"),
          _buildHardwareLog("DRAWCALL OVERHEAD", "124 CALLS/FRAME", "EFFICIENT"),
          
          const SizedBox(height: 12),
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),

          Text("CALIBRATION ENGINE OPTIMIZATION", style: CyberTheme.monospaceStyle(fontSize: 9, color: Colors.white70)),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => state.toggleRayTracing(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: state.rayTracingEnabled ? themeColor : Colors.white10),
                    backgroundColor: state.rayTracingEnabled ? themeColor.withOpacity(0.08) : Colors.transparent,
                  ),
                  child: Text(
                    "RAY-TRACING",
                    style: CyberTheme.monospaceStyle(
                      fontSize: 9,
                      color: state.rayTracingEnabled ? Colors.white : CyberTheme.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: themeColor.withOpacity(0.2),
                        content: Text(
                          "COMPUTE PIPELINE SET TO EXTREME PERFORMANCE MODE",
                          style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white10),
                  ),
                  child: Text(
                    "PERF PROFILE",
                    style: CyberTheme.monospaceStyle(fontSize: 9, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryIndicator(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted)),
        const SizedBox(height: 4),
        Text(value, style: CyberTheme.headingStyle(fontSize: 11, color: Colors.white)),
      ],
    );
  }

  Widget _buildTunerSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
            ),
          ),
          Expanded(
            flex: 5,
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                onChanged: onChanged,
                activeColor: Colors.redAccent,
                inactiveColor: Colors.white10,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            child: Text(
              value.toStringAsFixed(1),
              style: CyberTheme.monospaceStyle(fontSize: 9, color: Colors.white),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHardwareLog(String label, String val, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: CyberTheme.monospaceStyle(fontSize: 9, color: CyberTheme.textMuted),
            ),
          ),
          Text(
            val,
            style: CyberTheme.monospaceStyle(fontSize: 9, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: CyberTheme.monospaceStyle(
              fontSize: 8,
              color: status == "OPTIMIZED" || status == "STABLE" || status == "EFFICIENT" ? Colors.greenAccent : Colors.amberAccent,
            ),
          ),
        ],
      ),
    );
  }
}
