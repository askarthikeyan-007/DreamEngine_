import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dream_engine_ai/core/state/engine_state.dart';
import 'package:dream_engine_ai/core/theme/cyber_theme.dart';
import 'package:dream_engine_ai/core/widgets/glass_container.dart';

class HudWorldMap extends StatefulWidget {
  final double height;

  const HudWorldMap({super.key, this.height = 180});

  @override
  State<HudWorldMap> createState() => _HudWorldMapState();
}

class _HudWorldMapState extends State<HudWorldMap> with SingleTickerProviderStateMixin {
  MapMarker? _hoveredMarker;
  late AnimationController _pulseController;

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

  void _handleTap(TapUpDetails details, Size size, EngineState state) {
    final double x = details.localPosition.dx;
    final double y = details.localPosition.dy;

    // Find if a marker is clicked (within 16 pixels)
    MapMarker? tappedMarker;
    double minMarkerDist = double.infinity;

    for (var marker in state.mapMarkers) {
      final double mx = (marker.longitude + 180) * (size.width / 360);
      final double my = (90 - marker.latitude) * (size.height / 180);

      final double dist = sqrt(pow(mx - x, 2) + pow(my - y, 2));
      if (dist < 16.0 && dist < minMarkerDist) {
        minMarkerDist = dist;
        tappedMarker = marker;
      }
    }

    if (tappedMarker != null) {
      setState(() {
        _hoveredMarker = tappedMarker;
      });

      if (tappedMarker.code != null) {
        state.selectRegionByCode(tappedMarker.code!);
      }
    } else {
      // Find the closest region marker if not directly clicking a marker
      MapMarker? closestRegion;
      double minRegionDist = double.infinity;

      for (var marker in state.mapMarkers) {
        if (marker.type != "region") continue;
        
        final double mx = (marker.longitude + 180) * (size.width / 360);
        final double my = (90 - marker.latitude) * (size.height / 180);
        
        final double dist = sqrt(pow(mx - x, 2) + pow(my - y, 2));
        if (dist < minRegionDist) {
          minRegionDist = dist;
          closestRegion = marker;
        }
      }

      if (closestRegion != null && minRegionDist < 60.0) {
        setState(() {
          _hoveredMarker = closestRegion;
        });
        if (closestRegion.code != null) {
          state.selectRegionByCode(closestRegion.code!);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EngineState>(
      builder: (context, state, child) {
        // Default to the selected region marker if nothing is hovered/selected
        final activeRegionMarker = state.mapMarkers.firstWhere(
          (m) => m.type == "region" && m.code == state.selectedRegion.countryCode,
          orElse: () => state.mapMarkers.isNotEmpty 
              ? state.mapMarkers.firstWhere((m) => m.type == "region")
              : MapMarker(name: "US", type: "region", latitude: 37.0, longitude: -95.0, details: "Default"),
        );

        final MapMarker activeMarker = _hoveredMarker ?? activeRegionMarker;

        return GlassContainer(
          height: widget.height + 64,
          padding: EdgeInsets.zero,
          borderColor: CyberTheme.neonBlue.withOpacity(0.2),
          child: Column(
            children: [
              // HUD Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: CyberTheme.neonBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "GLOBAL MARKET SATELLITE HUD",
                          style: CyberTheme.headingStyle(fontSize: 10, color: CyberTheme.neonBlue),
                        ),
                      ],
                    ),
                    Text(
                      "LAT: ${activeMarker.latitude.toStringAsFixed(2)} | LNG: ${activeMarker.longitude.toStringAsFixed(2)}",
                      style: CyberTheme.monospaceStyle(fontSize: 9, color: CyberTheme.textMuted),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10, height: 1, thickness: 1),

              // Interactive world map area
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = Size(constraints.maxWidth, constraints.maxHeight);

                    return GestureDetector(
                      onTapUp: (details) => _handleTap(details, size, state),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return CustomPaint(
                                  size: size,
                                  painter: _WorldMapPainter(
                                    state: state,
                                    pulseValue: _pulseController.value,
                                    activeMarker: activeMarker,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const Divider(color: Colors.white10, height: 1, thickness: 1),
              
              // Telemetry footer
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                color: Colors.black26,
                child: Row(
                  children: [
                    Icon(
                      activeMarker.type == "studio" ? Icons.business : Icons.public,
                      color: activeMarker.type == "studio" ? const Color(0xFF00FF88) : CyberTheme.cyberPink,
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activeMarker.name.toUpperCase(),
                            style: CyberTheme.headingStyle(fontSize: 9, color: CyberTheme.textMain),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            activeMarker.details,
                            style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const VerticalDivider(color: Colors.white10, width: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "SELECTED STORE",
                          style: CyberTheme.monospaceStyle(fontSize: 7, color: CyberTheme.textMuted),
                        ),
                        Text(
                          "${state.selectedRegion.regionName} (${state.selectedRegion.currency})",
                          style: CyberTheme.headingStyle(fontSize: 9, color: CyberTheme.cyberPink),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WorldMapPainter extends CustomPainter {
  final EngineState state;
  final double pulseValue;
  final MapMarker activeMarker;

  _WorldMapPainter({
    required this.state,
    required this.pulseValue,
    required this.activeMarker,
  });

  // World map abstract land representation (22 rows x 48 cols)
  static const List<String> _worldMapGrid = [
    "................................................",
    "......................###.......................",
    "......##............######......................",
    "....#####..........########.........#######....",
    "..#########.......##########.......#########....",
    "############.....############....#############..",
    "############.....############...##############..",
    "###########.......##########...###############..",
    "##########.........########....##############...",
    ".#######............######......############....",
    "..#####.............#####.......##########......",
    "...###..............######.......########.......",
    "....#..............#######........######........",
    "..................########.........####.........",
    "..................########..........#...........",
    "..................#######.......................",
    "...................#####........................",
    "...................####..............#####......",
    "....................##..............#######.....",
    "....................................#######.....",
    ".....................................#####......",
    "................................................",
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final double cellWidth = size.width / 48;
    final double cellHeight = size.height / 22;

    // Draw Grid Lines (thin HUD grid)
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= 22; i++) {
      double y = i * cellHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (int i = 0; i <= 48; i++) {
      double x = i * cellWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Draw land dots
    final dotPaint = Paint()
      ..color = CyberTheme.neonBlue.withOpacity(0.07)
      ..style = PaintingStyle.fill;

    for (int y = 0; y < _worldMapGrid.length; y++) {
      final row = _worldMapGrid[y];
      for (int x = 0; x < row.length; x++) {
        if (row[x] != '.') {
          final cx = x * cellWidth + cellWidth / 2;
          final cy = y * cellHeight + cellHeight / 2;
          canvas.drawCircle(Offset(cx, cy), min(cellWidth, cellHeight) * 0.32, dotPaint);
        }
      }
    }

    // Draw Map Markers
    for (var marker in state.mapMarkers) {
      // Map to screen space using equirectangular projection
      final double mx = (marker.longitude + 180) * (size.width / 360);
      final double my = (90 - marker.latitude) * (size.height / 180);

      final isSelected = marker.name == activeMarker.name;

      if (marker.type == "studio") {
        // Studio Node (Green)
        final markerPaint = Paint()
          ..color = isSelected ? const Color(0xFF00FF88) : const Color(0x9900FF88)
          ..style = PaintingStyle.fill;
        
        canvas.drawRect(
          Rect.fromCenter(center: Offset(mx, my), width: isSelected ? 6 : 4, height: isSelected ? 6 : 4),
          markerPaint,
        );

        if (isSelected) {
          // Draw outer target circle
          final ringPaint = Paint()
            ..color = const Color(0xFF00FF88).withOpacity(0.6)
            ..strokeWidth = 1.0
            ..style = PaintingStyle.stroke;
          canvas.drawCircle(Offset(mx, my), 6.0 + pulseValue * 6.0, ringPaint);
        }
      } else {
        // Region Node (Cyan/Red depending on selection)
        final markerPaint = Paint()
          ..color = isSelected ? CyberTheme.cyberPink : Colors.white30
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(mx, my), isSelected ? 4.0 : 2.5, markerPaint);

        if (isSelected) {
          // Draw pulsing crosshair
          final ringPaint = Paint()
            ..color = CyberTheme.cyberPink.withOpacity(0.6)
            ..strokeWidth = 1.0
            ..style = PaintingStyle.stroke;
          canvas.drawCircle(Offset(mx, my), 5.0 + pulseValue * 8.0, ringPaint);

          // Draw crosshair lines
          final linePaint = Paint()
            ..color = CyberTheme.cyberPink.withOpacity(0.4)
            ..strokeWidth = 0.8;
          
          canvas.drawLine(Offset(mx - 8, my), Offset(mx - 3, my), linePaint);
          canvas.drawLine(Offset(mx + 3, my), Offset(mx + 8, my), linePaint);
          canvas.drawLine(Offset(mx, my - 8), Offset(mx, my - 3), linePaint);
          canvas.drawLine(Offset(mx, my + 3), Offset(mx, my + 8), linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WorldMapPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue ||
        oldDelegate.activeMarker != activeMarker ||
        oldDelegate.state.selectedRegion != state.selectedRegion;
  }
}
