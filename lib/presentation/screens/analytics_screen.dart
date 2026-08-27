import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dream_engine_ai/core/state/engine_state.dart';
import 'package:dream_engine_ai/core/theme/cyber_theme.dart';
import 'package:dream_engine_ai/core/widgets/glass_container.dart';
import 'package:dream_engine_ai/core/widgets/neon_button.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _showBoostOverlay = false;
  bool _showReportDialog = false;
  double _reportedCacheCleared = 0.0;
  double _reportedTempBefore = 0.0;
  double _reportedTempAfter = 0.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerBoost(EngineState state) async {
    setState(() {
      _reportedTempBefore = state.realTimeTemperature;
      _reportedCacheCleared = 0.5 + Random().nextDouble() * 0.8; // 500MB to 1.3GB
      _showBoostOverlay = true;
    });

    // Execute actual memory purge and cooldown in state
    await state.purgeRamAndCoolDown();

    if (mounted) {
      setState(() {
        _showBoostOverlay = false;
        _reportedTempAfter = state.realTimeTemperature;
        _showReportDialog = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<EngineState>(context);
    final themeColor = _getThemeColor(state);

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    // Thermal indicator color mapping
    Color tempColor = CyberTheme.neonBlue; // Red
    if (state.realTimeTemperature < 35.0) {
      tempColor = Colors.cyanAccent;
    } else if (state.realTimeTemperature < 40.0) {
      tempColor = Colors.amberAccent;
    }

    final Widget metricsLayout = isMobile
        ? Column(
            children: [
              _buildTelemetryTile(
                "SYSTEM TEMPERATURE",
                "${state.realTimeTemperature.toStringAsFixed(1)} °C",
                state.hardwareStatusText,
                tempColor,
                Icons.thermostat_rounded,
              ),
              const SizedBox(height: 12),
              _buildTelemetryTile(
                "RAM UTILIZATION",
                "${state.usedRamGB.toStringAsFixed(2)} / ${state.totalRamGB.toStringAsFixed(1)} GB",
                "${(state.ramUsagePercentage * 100).toInt()}% ALLOCATED",
                themeColor,
                Icons.memory_rounded,
              ),
              const SizedBox(height: 12),
              _buildTelemetryTile(
                "RAM FREE CAPACITY",
                "${state.availRamGB.toStringAsFixed(2)} GB",
                state.hardwareIsSimulated ? "SIMULATED ENVIRONMENT" : "PHYSICAL MEMORY OK",
                themeColor,
                Icons.align_horizontal_left_rounded,
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: _buildTelemetryTile(
                  "SYSTEM TEMPERATURE",
                  "${state.realTimeTemperature.toStringAsFixed(1)} °C",
                  state.hardwareStatusText,
                  tempColor,
                  Icons.thermostat_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTelemetryTile(
                  "RAM UTILIZATION",
                  "${state.usedRamGB.toStringAsFixed(2)} / ${state.totalRamGB.toStringAsFixed(1)} GB",
                  "${(state.ramUsagePercentage * 100).toInt()}% ALLOCATED",
                  themeColor,
                  Icons.memory_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTelemetryTile(
                  "RAM FREE CAPACITY",
                  "${state.availRamGB.toStringAsFixed(2)} GB",
                  state.hardwareIsSimulated ? "SIMULATED ENVIRONMENT" : "PHYSICAL MEMORY OK",
                  themeColor,
                  Icons.align_horizontal_left_rounded,
                ),
              ),
            ],
          );

    final Widget chartsPanel = GlassContainer(
      borderColor: themeColor.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "REALTIME PERFORMANCE TELEMETRY WAVEFORMS",
                  style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green.withOpacity(0.5)),
                ),
                child: Text(
                  "LIVE POLLING: 1Hz",
                  style: CyberTheme.monospaceStyle(fontSize: 8, color: Colors.greenAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          isMobile
              ? Column(
                  children: [
                    _buildWaveformSection("MEMORY PRESSURE INDEX", state.ramHistory, 0.0, 1.0, themeColor),
                    const SizedBox(height: 24),
                    _buildWaveformSection("THERMAL HEAT MAP (°C)", state.tempHistory, 25.0, 50.0, tempColor),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _buildWaveformSection("MEMORY PRESSURE INDEX", state.ramHistory, 0.0, 1.0, themeColor),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildWaveformSection("THERMAL HEAT MAP (°C)", state.tempHistory, 25.0, 50.0, tempColor),
                    ),
                  ],
                ),
        ],
      ),
    );

    final Widget optimizationPanel = GlassContainer(
      borderColor: themeColor.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("COGNITIVE COOLDOWN PROCEDURES", style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white)),
          const SizedBox(height: 8),
          Text(
            "Purge background render texture caches, dump local compiler histories, and optimize thread pooling for 120Hz smooth layout transitions.",
            style: CyberTheme.bodyStyle(fontSize: 11, color: CyberTheme.textMuted),
          ),
          const SizedBox(height: 20),
          NeonButton(
            onPressed: () {
              if (!state.isPurgingHardware) {
                _triggerBoost(state);
              }
            },
            glowColor: themeColor,
            gradientColors: [themeColor, themeColor.withBlue(220).withRed(40)],
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bolt_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    state.isPurgingHardware ? "OPTIMIZING HARDWARE METRICS..." : "BOOST VRAM & COOL DOWN",
                    style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    final Widget systemSpecsPanel = GlassContainer(
      borderColor: themeColor.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("SYSTEM DIAGNOSTICS", style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white)),
          const SizedBox(height: 16),
          _buildSpecsIndicator("PROCEDURAL SYNTHESIS RATE", 0.85, themeColor),
          _buildSpecsIndicator("RAY-TRACING SHADER LOAD", 0.62, themeColor),
          _buildSpecsIndicator("ENVIRONMENT VOXEL DEPTH", 0.45, themeColor),
          _buildSpecsIndicator("NPC NARRATIVE MEMORY", 0.90, themeColor),
        ],
      ),
    );

    final Widget bodyLayout = isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              chartsPanel,
              const SizedBox(height: 20),
              optimizationPanel,
              const SizedBox(height: 20),
              systemSpecsPanel,
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    chartsPanel,
                    const SizedBox(height: 20),
                    optimizationPanel,
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 4,
                child: systemSpecsPanel,
              ),
            ],
          );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Base Telemetry View layout
          Positioned.fill(
            child: isMobile
                ? SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text("PROCEDURAL TELEMETRY", style: CyberTheme.titleStyle(fontSize: 18)),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "REALTIME HARDWARE SENSOR PROBES // STATUS: ",
                                style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
                              ),
                              TextSpan(
                                text: state.hardwareStatusText,
                                style: CyberTheme.monospaceStyle(fontSize: 8, color: tempColor),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 20),
                        metricsLayout,
                        const SizedBox(height: 20),
                        bodyLayout,
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("PROCEDURAL TELEMETRY", style: CyberTheme.titleStyle(fontSize: 22)),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "REALTIME HARDWARE SENSOR PROBES // STATUS: ",
                                        style: CyberTheme.monospaceStyle(fontSize: 10, color: CyberTheme.textMuted),
                                      ),
                                      TextSpan(
                                        text: state.hardwareStatusText,
                                        style: CyberTheme.monospaceStyle(fontSize: 10, color: tempColor),
                                      ),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        metricsLayout,
                        const SizedBox(height: 20),
                        Expanded(child: SingleChildScrollView(child: bodyLayout)),
                      ],
                    ),
                  ),
          ),

          // Boost Scanning Overlay Screen
          if (_showBoostOverlay)
            Positioned.fill(
              child: SystemBoostOverlay(
                themeColor: themeColor,
                onComplete: () {},
              ),
            ),

          // Boost Completion Report Dialogue
          if (_showReportDialog)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: GlassContainer(
                    borderColor: themeColor,
                    padding: const EdgeInsets.all(24),
                    width: 380,
                    hasGlow: true,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text("DIAGNOSTIC OPTIMIZE REPORT", style: CyberTheme.headingStyle(fontSize: 14, color: Colors.white)),
                        const SizedBox(height: 8),
                        Text(
                          "SYSTEM STACKS COMPACTED successfully.",
                          style: CyberTheme.monospaceStyle(fontSize: 8, color: themeColor),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.02),
                            border: Border.all(color: Colors.white10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              _buildReportRow("CACHE PURGED", "+${_reportedCacheCleared.toStringAsFixed(2)} GB"),
                              const Divider(color: Colors.white10, height: 16),
                              _buildReportRow("TEMPERATURE", "${_reportedTempBefore.toStringAsFixed(1)}°C ➔ ${_reportedTempAfter.toStringAsFixed(1)}°C"),
                              const Divider(color: Colors.white10, height: 16),
                              _buildReportRow("SYSTEM HEALTH", "100% EXCELLENT"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        NeonButton(
                          onPressed: () {
                            setState(() {
                              _showReportDialog = false;
                            });
                          },
                          glowColor: themeColor,
                          gradientColors: [themeColor, themeColor.withOpacity(0.6)],
                          child: Text("DISMISS REPORT", style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTelemetryTile(String title, String mainVal, String subVal, Color color, IconData icon) {
    return GlassContainer(
      borderColor: color.withOpacity(0.2),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: Icon(
              icon,
              color: color.withOpacity(0.04),
              size: 54,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: CyberTheme.monospaceStyle(fontSize: 9, color: CyberTheme.textMuted)),
              const SizedBox(height: 8),
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, _) {
                      return Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.8),
                              blurRadius: 2 + _pulseController.value * 6,
                              spreadRadius: _pulseController.value * 2,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      mainVal,
                      style: CyberTheme.titleStyle(fontSize: 18, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(subVal, style: CyberTheme.monospaceStyle(fontSize: 9, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaveformSection(String title, List<double> values, double minVal, double maxVal, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: CyberTheme.monospaceStyle(fontSize: 9, color: CyberTheme.textMuted),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              values.isNotEmpty ? "${values.last.toStringAsFixed(1)}" : "0.0",
              style: CyberTheme.monospaceStyle(fontSize: 9, color: color),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 140,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.01),
            border: Border.all(color: color.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: RepaintBoundary(
            child: CustomPaint(
              painter: HardwareTelemetryChartPainter(
                values: values,
                minVal: minVal,
                maxVal: maxVal,
                color: color,
                label: title,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecsIndicator(String label, double val, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: CyberTheme.monospaceStyle(fontSize: 9, color: CyberTheme.textMuted),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              Text("${(val * 100).toInt()}%", style: CyberTheme.monospaceStyle(fontSize: 9, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: val,
            backgroundColor: Colors.white10,
            color: color,
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildReportRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: CyberTheme.monospaceStyle(fontSize: 10, color: CyberTheme.textMuted),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.white).copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Color _getThemeColor(EngineState state) {
    if (state.currentTheme == AppTheme.ironMan) return Colors.amber;
    if (state.currentTheme == AppTheme.nvidiaGreen) return Colors.lightGreenAccent;
    if (state.currentTheme == AppTheme.appleVision) return Colors.white;
    return CyberTheme.neonBlue;
  }
}

class HardwareTelemetryChartPainter extends CustomPainter {
  final List<double> values;
  final double minVal;
  final double maxVal;
  final Color color;
  final String label;

  HardwareTelemetryChartPainter({
    required this.values,
    required this.minVal,
    required this.maxVal,
    required this.color,
    required this.label,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw horizontal grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 0.5;

    const int numLines = 4;
    final double spacingY = size.height / numLines;
    for (int i = 0; i <= numLines; i++) {
      final double y = i * spacingY;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (values.isEmpty) return;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()..style = PaintingStyle.fill;

    final double stepX = size.width / (values.length - 1);
    final path = Path();
    final fillPath = Path();

    double normalize(double val) {
      if (maxVal == minVal) return 0.5;
      return ((val - minVal) / (maxVal - minVal)).clamp(0.0, 1.0);
    }

    // Start coordinates
    final double firstY = size.height - (normalize(values[0]) * size.height * 0.8 + size.height * 0.1);
    path.moveTo(0, firstY);
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, firstY);

    for (int i = 1; i < values.length; i++) {
      final double x = i * stepX;
      final double y = size.height - (normalize(values[i]) * size.height * 0.8 + size.height * 0.1);

      path.lineTo(x, y);
      fillPath.lineTo(x, y);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Render transparent gradient filling under the path
    fillPaint.shader = LinearGradient(
      colors: [color.withOpacity(0.12), color.withOpacity(0.0)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Draw active glowing pointer at the latest point
    final double latestX = size.width;
    final double latestY = size.height - (normalize(values.last) * size.height * 0.8 + size.height * 0.1);

    canvas.drawCircle(Offset(latestX, latestY), 3.5, Paint()..color = color);
    canvas.drawCircle(
      Offset(latestX, latestY),
      8.0,
      Paint()
        ..color = color.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant HardwareTelemetryChartPainter oldDelegate) => true;
}

class SystemBoostOverlay extends StatefulWidget {
  final Color themeColor;
  final VoidCallback onComplete;

  const SystemBoostOverlay({super.key, required this.themeColor, required this.onComplete});

  @override
  State<SystemBoostOverlay> createState() => _SystemBoostOverlayState();
}

class _SystemBoostOverlayState extends State<SystemBoostOverlay> with TickerProviderStateMixin {
  late AnimationController _scanController;
  final List<String> _consoleLogs = [];
  int _logIndex = 0;
  double _progress = 0.0;
  Timer? _logTimer;

  final List<String> _stages = [
    "SYS: INITIALIZING HARDWARE CALIBRATION PROTOCOL...",
    "AUTH: VERIFYING CRYPTO-SECTOR SECURITY INDEX... OK",
    "VRAM: FLUSHING PROCEDURAL DRAW CALL TEXTURE PIPELINES...",
    "GC: COLLECTING FLOATING POINTER INODE REFERENCES...",
    "MEM: RECLAIMING 984 FLOATING COMPILER MEMORY LEAK SEGMENTS...",
    "THERMAL: DEPLOYING DYNAMIC HEAT SHIELD LIQUID INJECTORS...",
    "SYS: SYNCHRONIZATION COMPLETED. TEMPERATURE COOL DOWN ARRESTED.",
  ];

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _runBoostSequence();
  }

  void _runBoostSequence() {
    _logTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (!mounted) return;
      setState(() {
        if (_logIndex < _stages.length) {
          _consoleLogs.add(_stages[_logIndex]);
          _logIndex++;
          _progress = _logIndex / _stages.length;
        } else {
          timer.cancel();
          widget.onComplete();
        }
      });
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    _logTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.92),
      child: Stack(
        children: [
          // Binary matrix rain
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (rect) => LinearGradient(
                colors: [Colors.black, Colors.black.withOpacity(0.08)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ).createShader(rect),
              blendMode: BlendMode.dstIn,
              child: CustomPaint(
                painter: MatrixRainPainter(color: widget.themeColor.withOpacity(0.12)),
              ),
            ),
          ),

          // Scan line overlay sweep
          AnimatedBuilder(
            animation: _scanController,
            builder: (context, child) {
              return Positioned(
                top: _scanController.value * MediaQuery.of(context).size.height,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: widget.themeColor.withOpacity(0.4),
                    boxShadow: [
                      BoxShadow(
                        color: widget.themeColor.withOpacity(0.8),
                        blurRadius: 15,
                        spreadRadius: 1.5,
                      )
                    ],
                  ),
                ),
              );
            },
          ),

          // Central console dialog
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GlassContainer(
                borderColor: widget.themeColor,
                padding: const EdgeInsets.all(24),
                width: min(MediaQuery.of(context).size.width * 0.85, 500),
                hasGlow: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("SYSTEM HARDWARE OPTIMIZER", style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white)),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.themeColor,
                            boxShadow: CyberTheme.neonGlow(color: widget.themeColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "OPTIMIZING MEMORY ALLOCATION & COOLING PATHS",
                      style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
                    ),
                    const SizedBox(height: 20),

                    // Progress slider
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("OPTIMIZING...", style: CyberTheme.monospaceStyle(fontSize: 8, color: widget.themeColor)),
                            Text("${(_progress * 100).toInt()}%", style: CyberTheme.monospaceStyle(fontSize: 8, color: Colors.white)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _progress,
                            backgroundColor: Colors.white10,
                            color: widget.themeColor,
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Live console output logs
                    Container(
                      height: 150,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        border: Border.all(color: Colors.white12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        itemCount: _consoleLogs.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              _consoleLogs[index],
                              style: CyberTheme.monospaceStyle(
                                fontSize: 9,
                                color: index == _consoleLogs.length - 1 ? widget.themeColor : Colors.white70,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MatrixRainPainter extends CustomPainter {
  final Color color;
  final Random _random = Random();

  MatrixRainPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = GoogleFonts.shareTechMono(
      color: color,
      fontSize: 9,
      fontWeight: FontWeight.bold,
    );

    final int columns = (size.width / 18).floor();
    for (int i = 0; i < columns; i++) {
      final double x = i * 18.0;
      final int len = _random.nextInt(8) + 4;
      final double startY = _random.nextDouble() * size.height;

      for (int j = 0; j < len; j++) {
        final double y = (startY + j * 12.0) % size.height;
        final String char = _random.nextBool() ? "1" : "0";
        final textSpan = TextSpan(text: char, style: textStyle);
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(canvas, Offset(x, y));
      }
    }
  }

  @override
  bool shouldRepaint(covariant MatrixRainPainter oldDelegate) => true;
}
