import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dream_engine_ai/core/state/engine_state.dart';
import 'package:dream_engine_ai/core/theme/cyber_theme.dart';
import 'package:dream_engine_ai/core/widgets/glass_container.dart';
import 'package:dream_engine_ai/core/widgets/neon_button.dart';
import 'package:dream_engine_ai/core/widgets/satellite_world_map.dart';

class _ProjectsData {
  final String title;
  final String genre;
  final double seed;
  _ProjectsData(this.title, this.genre, this.seed);

  @override
  bool operator ==(Object other) =>
      other is _ProjectsData &&
      other.title == title &&
      other.genre == genre &&
      other.seed == seed;

  @override
  int get hashCode => Object.hash(title, genre, seed);
}

class _OverridesData {
  final bool rayTracing;
  final String weather;
  _OverridesData(this.rayTracing, this.weather);

  @override
  bool operator ==(Object other) =>
      other is _OverridesData &&
      other.rayTracing == rayTracing &&
      other.weather == weather;

  @override
  int get hashCode => Object.hash(rayTracing, weather);
}

class _HeaderData {
  final String name;
  final String email;
  _HeaderData(this.name, this.email);

  @override
  bool operator ==(Object other) =>
      other is _HeaderData && other.name == name && other.email == email;

  @override
  int get hashCode => Object.hash(name, email);
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _visualizerController;
  final List<String> _terminalLogs = [];
  final ScrollController _logScrollController = ScrollController();
  Timer? _logTimer;

  // Customizable HUD layout state
  bool _isCustomizing = false;
  final List<String> _leftModules = [
    'satellite_map',
    'projects',
    'overrides',
    'news',
  ];
  final List<String> _rightModules = [
    'operators',
    'social',
    'visualizer',
    'console',
  ];

  @override
  void initState() {
    super.initState();
    _visualizerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _terminalLogs.addAll([
      "SYS: CRITICAL CORE INTERFACES ONLINE.",
      "SECURE: FIREBASE INITIALIZE COMPLETED [AUTH/FIRESTORE].",
      "SYNC: RETRIEVING REGISTERED OPERATOR DOSSIERS...",
      "SUCCESS: Synced active operator records from registry tables.",
      "PROCEDURAL: Seed compiler engine warmed and standing by.",
    ]);

    _logTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (mounted) {
        final messages = [
          "SYS: Matrix compiler cache aligned successfully.",
          "NET: Operator network latency check... Ping stable.",
          "VRAM: Procedural textures buffered without exceptions.",
          "SECURITY: Scanner protocols cleared: zero threat vectors.",
          "ENGINE: Active procedural compilation seed saved to cloud.",
          "DB: Synced operator directory records.",
        ];
        setState(() {
          _terminalLogs.add(messages[Random().nextInt(messages.length)]);
          if (_terminalLogs.length > 30) {
            _terminalLogs.removeAt(0);
          }
        });

        Future.delayed(const Duration(milliseconds: 200), () {
          if (_logScrollController.hasClients) {
            _logScrollController.animateTo(
              _logScrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
            );
          }
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EngineState>(context, listen: false).reloadOperators();
    });
  }

  @override
  void dispose() {
    _visualizerController.dispose();
    _logTimer?.cancel();
    _logScrollController.dispose();
    super.dispose();
  }

  Color _getThemeColor(AppTheme theme) {
    if (theme == AppTheme.ironMan) return Colors.amber;
    if (theme == AppTheme.nvidiaGreen) return Colors.lightGreenAccent;
    if (theme == AppTheme.appleVision) return Colors.white;
    return CyberTheme.neonBlue;
  }

  void _resetHUD() {
    setState(() {
      _leftModules.clear();
      _leftModules.addAll(['satellite_map', 'projects', 'overrides', 'news']);
      _rightModules.clear();
      _rightModules.addAll(['operators', 'social', 'visualizer', 'console']);
    });
  }

  Widget _buildEmptyDropZone(bool isLeftColumn, Color themeColor) {
    if (!_isCustomizing) return const SizedBox.shrink();

    return DragTarget<String>(
      onWillAcceptWithDetails: (details) {
        final list = isLeftColumn ? _leftModules : _rightModules;
        return !list.contains(details.data);
      },
      onAcceptWithDetails: (details) {
        final draggedModule = details.data;
        setState(() {
          _leftModules.remove(draggedModule);
          _rightModules.remove(draggedModule);
          if (isLeftColumn) {
            _leftModules.add(draggedModule);
          } else {
            _rightModules.add(draggedModule);
          }
        });
      },
      builder: (context, candidateData, rejectedData) {
        final isOver = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: isOver ? 80 : 40,
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: isOver ? themeColor : Colors.white12,
              style: BorderStyle.solid,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isOver ? themeColor.withOpacity(0.05) : Colors.transparent,
          ),
          child: Center(
            child: Text(
              "DROP MODULE HERE",
              style: CyberTheme.monospaceStyle(
                fontSize: 8,
                color: isOver ? themeColor : CyberTheme.textMuted,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _wrapWithDraggable(
    String moduleName,
    Widget child,
    bool isLeftColumn,
    Color themeColor,
  ) {
    if (!_isCustomizing) return child;

    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => details.data != moduleName,
      onAcceptWithDetails: (details) {
        final draggedModule = details.data;
        setState(() {
          _leftModules.remove(draggedModule);
          _rightModules.remove(draggedModule);

          final targetList = isLeftColumn ? _leftModules : _rightModules;
          final targetIdx = targetList.indexOf(moduleName);
          if (targetIdx >= 0) {
            targetList.insert(targetIdx, draggedModule);
          } else {
            targetList.add(draggedModule);
          }
        });
      },
      builder: (context, candidateData, rejectedData) {
        final isOver = candidateData.isNotEmpty;
        return LongPressDraggable<String>(
          data: moduleName,
          feedback: Material(
            type: MaterialType.transparency,
            child: Opacity(
              opacity: 0.75,
              child: SizedBox(
                width: 320,
                child: GlassContainer(
                  borderColor: themeColor,
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    "RECONFIGURING MESH: ${moduleName.toUpperCase()}...",
                    style: CyberTheme.monospaceStyle(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.2, child: child),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isOver ? themeColor : themeColor.withOpacity(0.25),
                style: BorderStyle.solid,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                child,
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(
                      Icons.drag_indicator_rounded,
                      color: Colors.white70,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModule(String moduleName, Color themeColor, bool isMobile) {
    switch (moduleName) {
      case 'satellite_map':
        return const SatelliteWorldMap();
      case 'projects':
        return Selector<EngineState, _ProjectsData>(
          selector: (context, state) => _ProjectsData(
            state.gameTitle,
            state.gameGenre,
            state.proceduralSeed,
          ),
          builder: (context, data, _) {
            final tempState = Provider.of<EngineState>(context, listen: false);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Procedural Projects",
                  style: CyberTheme.headingStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                _buildProjectsLayout(tempState, themeColor, isMobile),
              ],
            );
          },
        );
      case 'overrides':
        return Selector<EngineState, _OverridesData>(
          selector: (context, state) =>
              _OverridesData(state.rayTracingEnabled, state.weatherSystem),
          builder: (context, data, _) {
            final tempState = Provider.of<EngineState>(context, listen: false);
            return _buildOverridesLayout(tempState, themeColor);
          },
        );
      case 'news':
        return Selector<EngineState, List<Map<String, dynamic>>>(
          selector: (context, state) => state.gameNews,
          builder: (context, news, _) {
            final tempState = Provider.of<EngineState>(context, listen: false);
            return _buildLatestNewsWidget(tempState, themeColor);
          },
        );
      case 'operators':
        return Selector<EngineState, List<Map<String, String>>>(
          selector: (context, state) => state.activeOperators,
          builder: (context, operators, _) {
            final tempState = Provider.of<EngineState>(context, listen: false);
            return _buildRegisteredOperatorsList(tempState, themeColor);
          },
        );
      case 'social':
        return Selector<EngineState, List<Map<String, dynamic>>>(
          selector: (context, state) => state.devgramPosts,
          builder: (context, posts, _) {
            final tempState = Provider.of<EngineState>(context, listen: false);
            return _buildDevgramHighlightsWidget(tempState, themeColor);
          },
        );
      case 'visualizer':
        return _buildPerformanceVisualizer(themeColor);
      case 'console':
        return _buildLiveTerminalLogs();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<EngineState>(context);
    final theme = state.currentTheme;
    final Color themeColor = _getThemeColor(theme);
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 992;

    // Dynamic Module Layout Generation
    final List<Widget> leftChildren = [];
    for (int i = 0; i < _leftModules.length; i++) {
      leftChildren.add(
        _wrapWithDraggable(
          _leftModules[i],
          _buildModule(_leftModules[i], themeColor, isMobile),
          true,
          themeColor,
        ),
      );
      if (i < _leftModules.length - 1)
        leftChildren.add(const SizedBox(height: 16));
    }
    leftChildren.add(_buildEmptyDropZone(true, themeColor));

    final List<Widget> rightChildren = [];
    for (int i = 0; i < _rightModules.length; i++) {
      rightChildren.add(
        _wrapWithDraggable(
          _rightModules[i],
          _buildModule(_rightModules[i], themeColor, isMobile),
          false,
          themeColor,
        ),
      );
      if (i < _rightModules.length - 1)
        rightChildren.add(const SizedBox(height: 16));
    }
    rightChildren.add(_buildEmptyDropZone(false, themeColor));

    final List<Widget> mobileChildren = [];
    final List<String> combined = [..._leftModules, ..._rightModules];
    for (int i = 0; i < combined.length; i++) {
      mobileChildren.add(
        _wrapWithDraggable(
          combined[i],
          _buildModule(combined[i], themeColor, isMobile),
          true,
          themeColor,
        ),
      );
      if (i < combined.length - 1)
        mobileChildren.add(const SizedBox(height: 16));
    }
    mobileChildren.add(_buildEmptyDropZone(true, themeColor));

    // Statically lay out Metrics cards at the top
    final List<Widget> metricCards = [
      _buildMetricCard(
        "VOXEL RENDERER LOAD",
        "47.2 %",
        "120 FPS // STABLE",
        themeColor,
        Icons.speed_rounded,
      ),
      if (isMobile) const SizedBox(height: 12) else const SizedBox(width: 16),
      _buildMetricCard(
        "DEVICE RAM USAGE",
        "${(state.ramUsagePercentage * 100).toInt()}%",
        "${state.usedRamGB.toStringAsFixed(1)} / ${state.totalRamGB.toStringAsFixed(1)} GB",
        themeColor,
        Icons.memory_rounded,
      ),
      if (isMobile) const SizedBox(height: 12) else const SizedBox(width: 16),
      _buildMetricCard(
        "SYSTEM TEMPERATURE",
        "${state.realTimeTemperature.toStringAsFixed(1)}°C",
        state.hardwareStatusText,
        state.realTimeTemperature >= 38.0 ? Colors.amberAccent : themeColor,
        Icons.thermostat_rounded,
      ),
    ];

    final Widget metricsLayout = isMobile
        ? Column(children: metricCards)
        : Row(
            children: metricCards
                .map((c) => c is SizedBox ? c : Expanded(child: c))
                .toList(),
          );

    final Widget bodyLayout = isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: mobileChildren,
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: leftChildren,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: rightChildren,
                ),
              ),
            ],
          );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Bar
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "DREAMENGINE CONSOLE",
                      style: CyberTheme.titleStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Selector<EngineState, _HeaderData>(
                      selector: (context, state) =>
                          _HeaderData(state.operatorName, state.operatorEmail),
                      builder: (context, data, _) {
                        return Text(
                          "OPERATOR ID: ${data.name} // EMAIL: ${data.email}",
                          style: CyberTheme.monospaceStyle(
                            fontSize: 9,
                            color: themeColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Edit hud button
                        InkWell(
                          onTap: () =>
                              setState(() => _isCustomizing = !_isCustomizing),
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: _isCustomizing
                                  ? themeColor.withOpacity(0.12)
                                  : Colors.transparent,
                              border: Border.all(
                                color: _isCustomizing
                                    ? themeColor
                                    : Colors.white24,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isCustomizing
                                      ? Icons.dashboard_customize_rounded
                                      : Icons.edit_rounded,
                                  color: _isCustomizing
                                      ? themeColor
                                      : Colors.white70,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isCustomizing
                                      ? "FINISH HUD"
                                      : "CUSTOMIZE HUD",
                                  style: CyberTheme.monospaceStyle(
                                    fontSize: 8,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_isCustomizing)
                          InkWell(
                            onTap: _resetHUD,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFFF1E27),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.refresh_rounded,
                                    color: Color(0xFFFF1E27),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "RESET HUD",
                                    style: CyberTheme.monospaceStyle(
                                      fontSize: 8,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "DREAMENGINE CONSOLE",
                            style: CyberTheme.titleStyle(
                              fontSize: 22,
                              color: Colors.white,
                            ),
                          ),
                          Selector<EngineState, _HeaderData>(
                            selector: (context, state) => _HeaderData(
                              state.operatorName,
                              state.operatorEmail,
                            ),
                            builder: (context, data, _) {
                              return Text(
                                "OPERATOR ID: ${data.name} // EMAIL: ${data.email}",
                                style: CyberTheme.monospaceStyle(
                                  fontSize: 9,
                                  color: themeColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Customizers row
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Edit hud button
                        InkWell(
                          onTap: () =>
                              setState(() => _isCustomizing = !_isCustomizing),
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: _isCustomizing
                                  ? themeColor.withOpacity(0.12)
                                  : Colors.transparent,
                              border: Border.all(
                                color: _isCustomizing
                                    ? themeColor
                                    : Colors.white24,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isCustomizing
                                      ? Icons.dashboard_customize_rounded
                                      : Icons.edit_rounded,
                                  color: _isCustomizing
                                      ? themeColor
                                      : Colors.white70,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isCustomizing
                                      ? "FINISH HUD"
                                      : "CUSTOMIZE HUD",
                                  style: CyberTheme.monospaceStyle(
                                    fontSize: 8,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_isCustomizing) ...[
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: _resetHUD,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFFF1E27),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.refresh_rounded,
                                    color: Color(0xFFFF1E27),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "RESET HUD",
                                    style: CyberTheme.monospaceStyle(
                                      fontSize: 8,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        if (!_isCustomizing) ...[
                          const SizedBox(width: 12),
                          GlassContainer(
                            borderRadius: 8,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            borderColor: themeColor.withOpacity(0.3),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: themeColor,
                                    boxShadow: CyberTheme.neonGlow(
                                      color: themeColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "IMPELLER ACTIVE",
                                  style: CyberTheme.monospaceStyle(
                                    fontSize: 9,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
          const SizedBox(height: 12),

          // Customization mode alert bar
          if (_isCustomizing)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: GlassContainer(
                borderColor: themeColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: themeColor,
                      size: 16,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "HUD EDIT PROTOCOL INITIATED: LONG PRESS AND DRAG CARDS TO RECONFIG COGNITIVE SEGMENTS.",
                        style: CyberTheme.monospaceStyle(
                          fontSize: 9,
                          color: themeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 12),
          metricsLayout,
          const SizedBox(height: 24),
          bodyLayout,
        ],
      ),
    );
  }

  // --- Layout Helper Builders ---

  Widget _buildMetricCard(
    String title,
    String val,
    String subtitle,
    Color themeColor,
    IconData icon,
  ) {
    return GlassContainer(
      borderColor: themeColor.withOpacity(0.2),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: CyberTheme.monospaceStyle(
                    fontSize: 9,
                    color: CyberTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  val,
                  style: CyberTheme.titleStyle(
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: CyberTheme.monospaceStyle(
                    fontSize: 9,
                    color: themeColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: themeColor.withOpacity(0.4), size: 36),
        ],
      ),
    );
  }

  Widget _buildProjectsLayout(
    EngineState state,
    Color themeColor,
    bool isMobile,
  ) {
    return GridView.count(
      crossAxisCount: isMobile ? 1 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isMobile ? 2.4 : 1.7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildProjectCard(
          state.gameTitle,
          state.gameGenre,
          "PROCEDURAL SEED: ${state.proceduralSeed.toInt()}",
          themeColor,
          true,
        ),
        _buildProjectCard(
          "RETRO RUNNERS",
          "80s Outrun Racing",
          "SEED: 9812402 // COMPILED 2D",
          themeColor,
          false,
        ),
        _buildProjectCard(
          "CHRONO VOID",
          "Time-warp Stealth RPG",
          "SEED: 4182901 // BUILD READY",
          themeColor,
          false,
        ),
        _buildProjectCard(
          "AETHER WORLD",
          "Procedural Sandbox",
          "SEED: 8812904 // UNCOMPILED",
          themeColor,
          false,
        ),
      ],
    );
  }

  Widget _buildProjectCard(
    String title,
    String genre,
    String footer,
    Color themeColor,
    bool isActive,
  ) {
    final state = Provider.of<EngineState>(context, listen: false);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (isActive) {
            state.setScreenIndex(6); // Go to Preview page
          }
        },
        child: GlassContainer(
          borderColor: isActive ? themeColor : Colors.white12,
          hasGlow: isActive,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: CyberTheme.titleStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: themeColor, width: 0.5),
                      ),
                      child: Text(
                        "ACTIVE SEED",
                        style: CyberTheme.monospaceStyle(
                          fontSize: 8,
                          color: themeColor,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                genre,
                style: CyberTheme.bodyStyle(
                  fontSize: 12,
                  color: CyberTheme.textMuted,
                ),
              ),
              const Spacer(),
              Text(
                footer,
                style: CyberTheme.monospaceStyle(
                  fontSize: 9,
                  color: isActive ? themeColor : CyberTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverridesLayout(EngineState state, Color themeColor) {
    return GlassContainer(
      borderColor: themeColor.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "SYSTEM OVERRIDES",
            style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white),
          ),
          const SizedBox(height: 16),
          _buildOverrideTile(
            "RAYTRACING ENGINE",
            state.rayTracingEnabled ? "ON" : "OFF",
            () => state.toggleRayTracing(),
            state.rayTracingEnabled,
            themeColor,
          ),
          _buildOverrideTile(
            "DYNAMIC CLIMATE",
            state.weatherSystem,
            () {
              final weathers = [
                "Neon Rain",
                "Solar Storm",
                "Acid Fog",
                "Clear Voxel",
              ];
              final currIndex = weathers.indexOf(state.weatherSystem);
              final next = weathers[(currIndex + 1) % weathers.length];
              state.setWeather(next);
            },
            true,
            themeColor,
          ),
          const SizedBox(height: 20),
          NeonButton(
            onPressed: () => state.setScreenIndex(4),
            glowColor: themeColor,
            gradientColors: [themeColor, themeColor.withBlue(200).withRed(50)],
            child: Text(
              "COMPILE NEW SEED",
              style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverrideTile(
    String title,
    String val,
    VoidCallback onTap,
    bool isActive,
    Color themeColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: CyberTheme.monospaceStyle(
                  fontSize: 9,
                  color: CyberTheme.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                val,
                style: CyberTheme.headingStyle(
                  fontSize: 12,
                  color: isActive ? themeColor : Colors.white,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: onTap,
            icon: Icon(
              Icons.sync_rounded,
              color: isActive ? themeColor : CyberTheme.textMuted,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestNewsWidget(EngineState state, Color themeColor) {
    return GlassContainer(
      borderColor: themeColor.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "LATEST GAME NEWS WIRE",
                  style: CyberTheme.headingStyle(
                    fontSize: 11,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.newspaper_rounded, color: themeColor, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          if (state.gameNews.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                "CONNECTING DYNAMIC NEWS TRANSCEIVER...",
                style: CyberTheme.monospaceStyle(
                  fontSize: 9,
                  color: CyberTheme.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            Column(
              children: state.gameNews.take(2).map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 4, height: 24, color: themeColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item["title"] ?? "",
                              style: CyberTheme.monospaceStyle(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              item["pubDate"] ?? "",
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 8,
                                color: CyberTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => state.setScreenIndex(13),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: themeColor.withOpacity(0.5)),
            ),
            child: Text(
              "OPEN NEWS TERMINAL",
              style: CyberTheme.monospaceStyle(
                fontSize: 9,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisteredOperatorsList(EngineState state, Color themeColor) {
    final avatarIcons = [
      Icons.blur_on_rounded,
      Icons.face_retouching_natural_rounded,
      Icons.precision_manufacturing_rounded,
      Icons.person_pin_rounded,
    ];

    return GlassContainer(
      borderColor: themeColor.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "REGISTERED COGNITIVE DOSSIERS",
                  style: CyberTheme.headingStyle(
                    fontSize: 11,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00FF88),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00FF88).withOpacity(0.6),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "LIVE SYNCED",
                    style: CyberTheme.monospaceStyle(
                      fontSize: 8,
                      color: const Color(0xFF00FF88),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.activeOperators.length,
            itemBuilder: (context, idx) {
              final op = state.activeOperators[idx];
              final opName = op["name"] ?? "UNKNOWN";
              final opEmail = op["email"] ?? "---";
              final opPing = op["ping"] ?? "0ms";
              final opStatus = op["status"] ?? "OFFLINE";
              final opRole = op["role"] ?? "OPERATOR";
              final opAvatarIdx = int.tryParse(op["avatar"] ?? "0") ?? 0;
              final isOnline = opStatus.toUpperCase() == "ONLINE";

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: themeColor.withOpacity(0.12),
                      child: Icon(
                        avatarIcons[opAvatarIdx % avatarIcons.length],
                        color: themeColor,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            opName,
                            style: CyberTheme.monospaceStyle(
                              fontSize: 11,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            opEmail,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 9,
                              color: CyberTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          opRole,
                          style: CyberTheme.monospaceStyle(
                            fontSize: 8,
                            color: themeColor,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "$opPing • ",
                              style: CyberTheme.monospaceStyle(
                                fontSize: 8,
                                color: Colors.white30,
                              ),
                            ),
                            Text(
                              opStatus,
                              style: CyberTheme.monospaceStyle(
                                fontSize: 8,
                                color: isOnline
                                    ? const Color(0xFF00FF88)
                                    : Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDevgramHighlightsWidget(EngineState state, Color themeColor) {
    return GlassContainer(
      borderColor: themeColor.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "DEVGRAM SOCIAL OVERVIEW",
                  style: CyberTheme.headingStyle(
                    fontSize: 11,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.photo_library_rounded, color: themeColor, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          if (state.devgramPosts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                "SYNCING DEVGRAM FEED NODES...",
                style: CyberTheme.monospaceStyle(
                  fontSize: 9,
                  color: CyberTheme.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            Column(
              children: state.devgramPosts.take(2).map((post) {
                final author = post["authorName"] ?? "UNKNOWN";
                final caption = post["caption"] ?? "";
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.alternate_email_rounded,
                        size: 12,
                        color: themeColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "$author: $caption",
                          style: CyberTheme.bodyStyle(
                            fontSize: 10,
                            color: CyberTheme.textMain,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 10),
          NeonButton(
            onPressed: () => state.setScreenIndex(12),
            glowColor: themeColor,
            gradientColors: [themeColor, themeColor.withOpacity(0.5)],
            child: Text(
              "LAUNCH DEVGRAM HOLOGRAPH",
              style: CyberTheme.headingStyle(fontSize: 10, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceVisualizer(Color themeColor) {
    return GlassContainer(
      borderColor: themeColor.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "VOXEL COMPILATION FREQUENCY",
            style: CyberTheme.headingStyle(fontSize: 11, color: Colors.white),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _visualizerController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: PerformanceWavePainter(
                      progress: _visualizerController.value,
                      color: themeColor,
                    ),
                    child: Container(),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  "CORE TEMP: 62°C",
                  style: CyberTheme.monospaceStyle(
                    fontSize: 9,
                    color: CyberTheme.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  "VRAM ALLOC: 5.4GB / 8GB",
                  style: CyberTheme.monospaceStyle(
                    fontSize: 9,
                    color: CyberTheme.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveTerminalLogs() {
    return GlassContainer(
      borderColor: CyberTheme.neonBlue.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "OPERATOR SYSTEM CONSOLE",
                  style: CyberTheme.headingStyle(
                    fontSize: 11,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_right_rounded,
                color: Colors.white30,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              controller: _logScrollController,
              itemCount: _terminalLogs.length,
              itemBuilder: (context, idx) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text(
                    "> ${_terminalLogs[idx]}",
                    style: CyberTheme.monospaceStyle(
                      fontSize: 10,
                      color: CyberTheme.cyanGlow.withOpacity(0.85),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PerformanceWavePainter extends CustomPainter {
  final double progress;
  final Color color;

  PerformanceWavePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final path = Path();
    final linePath = Path();

    path.moveTo(0, size.height);
    bool first = true;

    // Step by 3 pixels to reduce calculations, curve remains visually smooth
    for (double x = 0; x <= size.width; x += 3) {
      final double angle1 = (x / size.width * 2 * pi * 2.2) + progress * 2 * pi;
      final double angle2 = (x / size.width * 2 * pi * 1.1) - progress * 2 * pi;
      final double y = size.height / 2 + sin(angle1) * 12 + cos(angle2) * 6;

      if (first) {
        path.lineTo(x, y);
        linePath.moveTo(x, y);
        first = false;
      } else {
        path.lineTo(x, y);
        linePath.lineTo(x, y);
      }
    }

    // Ensure smooth connection to exactly the right boundary
    final double endX = size.width;
    final double angle1 =
        (endX / size.width * 2 * pi * 2.2) + progress * 2 * pi;
    final double angle2 =
        (endX / size.width * 2 * pi * 1.1) - progress * 2 * pi;
    final double endY = size.height / 2 + sin(angle1) * 12 + cos(angle2) * 6;
    path.lineTo(endX, endY);
    linePath.lineTo(endX, endY);

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant PerformanceWavePainter oldDelegate) => true;
}
