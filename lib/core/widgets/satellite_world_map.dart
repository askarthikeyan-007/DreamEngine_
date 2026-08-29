
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:dream_engine_ai/core/state/engine_state.dart';
import 'package:dream_engine_ai/core/theme/cyber_theme.dart';
import 'package:dream_engine_ai/core/widgets/glass_container.dart';

class SatelliteWorldMap extends StatefulWidget {
  const SatelliteWorldMap({super.key});

  @override
  State<SatelliteWorldMap> createState() => _SatelliteWorldMapState();
}

class _SatelliteWorldMapState extends State<SatelliteWorldMap> with TickerProviderStateMixin {
  String _selectedCompany = "Rockstar Games";
  MapMarker? _focusedBranch;
  late AnimationController _pulseController;
  final MapController _mapController = MapController();
  
  String _mapStyle = "Roadmap"; // "Roadmap", "Satellite", "Terrain"

  final List<String> _companies = [
    "Rockstar Games",
    "CD Projekt Red",
    "Ubisoft",
    "Valve",
    "Epic Games",
    "Nintendo",
    "Capcom",
  ];

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

  void _selectBranch(MapMarker branch, EngineState state, Size size) {
    setState(() {
      _focusedBranch = branch;
    });

    if (branch.code != null) {
      state.selectRegionByCode(branch.code!);
    }

    _animateToMarker(branch, size);
  }

  void _animateToMarker(MapMarker branch, Size size) {
    _mapController.move(LatLng(branch.latitude, branch.longitude), 5.0);
  }

  @override
  Widget build(BuildContext context) {
    final mapMarkers = context.select<EngineState, List<MapMarker>>((s) => s.mapMarkers);
    final state = Provider.of<EngineState>(context, listen: false);
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 768;

    // Filter markers based on selected company
    final List<MapMarker> companyBranches = mapMarkers
        .where((m) => m.type == "studio" && m.company == _selectedCompany)
        .toList();

    // Default to the first branch of the selected company if no branch is focused
    final activeBranch = _focusedBranch != null && _focusedBranch!.company == _selectedCompany
        ? _focusedBranch!
        : (companyBranches.isNotEmpty ? companyBranches[0] : null);

    return RepaintBoundary(
      child: GlassContainer(
        borderColor: CyberTheme.neonBlue.withOpacity(0.2),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 5,
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: CyberTheme.neonBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "GOOGLE MAPS TELEMETRY HUD",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (activeBranch != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 5,
                    child: Text(
                      "TARGET: ${activeBranch.name.toUpperCase()} // LAT: ${activeBranch.latitude.toStringAsFixed(2)} LNG: ${activeBranch.longitude.toStringAsFixed(2)}",
                      style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Horizontal layout for wide screen, vertical for mobile
            isMobile
                ? Column(
                    children: [
                      _buildMapStack(state, companyBranches, activeBranch),
                      const SizedBox(height: 16),
                      _buildCompanyExplorer(state, companyBranches, activeBranch, width),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: _buildMapStack(state, companyBranches, activeBranch),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 4,
                        child: _buildCompanyExplorer(state, companyBranches, activeBranch, width),
                      ),
                    ],
                  ),
            const SizedBox(height: 12),
            _buildOptionsBar(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildMapStack(EngineState state, List<MapMarker> visibleMarkers, MapMarker? activeBranch) {
    String urlTemplate;
    List<String> subdomains = const [];

    if (_mapStyle == "Roadmap") {
      // OpenStreetMap - 100% free, high-detail roadmap tiles with no API key or watermark
      urlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    } else if (_mapStyle == "Satellite") {
      // ESRI World Imagery - clean natural satellite view (no API key required)
      urlTemplate = 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
    } else if (_mapStyle == "Dark") {
      // ESRI World Dark Gray Canvas - cyber dark mode map (no API key required)
      urlTemplate = 'https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Dark_Gray_Base/MapServer/tile/{z}/{y}/{x}';
    } else { // Terrain
      // ESRI World Topo Map - clean light topographic terrain mapping (no API key required)
      urlTemplate = 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}';
    }

    return AspectRatio(
      aspectRatio: 2.0, // Standard equirectangular flat projection aspect ratio
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Real-time interactive map widget
            Positioned.fill(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(activeBranch?.latitude ?? 20.0, activeBranch?.longitude ?? 0.0),
                  initialZoom: 1.5,
                  maxZoom: 18.0,
                  minZoom: 1.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: urlTemplate,
                    subdomains: subdomains,
                    userAgentPackageName: 'com.dreamengine.ai',
                  ),
                  MarkerLayer(
                    markers: visibleMarkers.map((branch) {
                      final isSelected = activeBranch != null && activeBranch.name == branch.name;
                      return Marker(
                        point: LatLng(branch.latitude, branch.longitude),
                        width: isSelected ? 48 : 32,
                        height: isSelected ? 48 : 32,
                        alignment: Alignment.topCenter,
                        child: GestureDetector(
                          onTap: () {
                            _selectBranch(branch, state, const Size(400, 200));
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (isSelected)
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return Container(
                                      width: 28 + _pulseController.value * 16,
                                      height: 28 + _pulseController.value * 16,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFFFF1E27).withOpacity(0.3 * (1 - _pulseController.value)),
                                      ),
                                    );
                                  },
                                ),
                              Icon(
                                Icons.location_on_rounded,
                                color: isSelected ? const Color(0xFFFF1E27) : CyberTheme.neonBlue,
                                size: isSelected ? 28 : 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            
            // Map Type Selector Control (Roadmap / Satellite / Terrain overlay on the map)
            Positioned(
              top: 10,
              left: 10,
              child: Row(
                children: ["Roadmap", "Satellite", "Terrain", "Dark"].map((style) {
                  final isSelected = _mapStyle == style;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _mapStyle = style;
                        });
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? CyberTheme.neonBlue.withOpacity(0.2) : Colors.black87,
                          border: Border.all(
                            color: isSelected ? CyberTheme.neonBlue : Colors.white24,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          style.toUpperCase(),
                          style: CyberTheme.monospaceStyle(
                            fontSize: 7,
                            color: isSelected ? Colors.white : CyberTheme.textMuted,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Google Maps Logo overlay (bottom left)
            Positioned(
              bottom: 8,
              left: 8,
              child: IgnorePointer(
                child: Row(
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: "G", style: TextStyle(color: Colors.blue[400], fontWeight: FontWeight.bold)),
                          TextSpan(text: "o", style: TextStyle(color: Colors.red[400], fontWeight: FontWeight.bold)),
                          TextSpan(text: "o", style: TextStyle(color: Colors.yellow[600], fontWeight: FontWeight.bold)),
                          TextSpan(text: "g", style: TextStyle(color: Colors.blue[400], fontWeight: FontWeight.bold)),
                          TextSpan(text: "l", style: TextStyle(color: Colors.green[400], fontWeight: FontWeight.bold)),
                          TextSpan(text: "e", style: TextStyle(color: Colors.red[400], fontWeight: FontWeight.bold)),
                        ],
                      ),
                      style: GoogleFonts.openSans(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Maps",
                      style: CyberTheme.monospaceStyle(fontSize: 8, color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ),
            
            // Zoom +/- Controls overlay (bottom right)
            Positioned(
              bottom: 10,
              right: 10,
              child: Column(
                children: [
                  _buildZoomButton(Icons.add, () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, (currentZoom + 1.0).clamp(1.0, 18.0));
                  }),
                  const SizedBox(height: 6),
                  _buildZoomButton(Icons.remove, () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, (currentZoom - 1.0).clamp(1.0, 18.0));
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.black87,
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, color: Colors.white70, size: 14),
      ),
    );
  }

  Widget _buildCompanyExplorer(EngineState state, List<MapMarker> branches, MapMarker? activeBranch, double width) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Company Dropdown selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: Colors.white.withOpacity(0.02),
            height: 38,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCompany,
                isExpanded: true,
                dropdownColor: const Color(0xFF020204),
                icon: Icon(Icons.business_rounded, color: CyberTheme.neonBlue, size: 14),
                style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.white),
                onChanged: (newCompany) {
                  if (newCompany != null) {
                    setState(() {
                      _selectedCompany = newCompany;
                      _focusedBranch = null; // Reset focused branch on company change
                    });
                  }
                },
                items: _companies.map((String c) {
                  return DropdownMenuItem<String>(
                    value: c,
                    child: Text(c.toUpperCase()),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(color: Colors.white10, height: 1),

          // Scrollable list of branches
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double mapW = width * 0.6; // Approximate map layout width
                final double mapH = mapW / 2.0;
                return ListView.builder(
                  itemCount: branches.length,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemBuilder: (context, idx) {
                    final branch = branches[idx];
                    final isSelected = activeBranch != null && activeBranch.name == branch.name;

                    return InkWell(
                      onTap: () {
                        _selectBranch(branch, state, Size(mapW, mapH));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        color: isSelected ? CyberTheme.neonBlue.withOpacity(0.08) : Colors.transparent,
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: isSelected ? const Color(0xFFFF1E27) : CyberTheme.textMuted,
                              size: 14,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    branch.name.toUpperCase(),
                                    style: CyberTheme.headingStyle(fontSize: 9, color: Colors.white),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    branch.details,
                                    style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (branch.code != null)
                              Text(
                                branch.code!,
                                style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.cyberPink),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsBar(BuildContext context, EngineState state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          _buildOptionButton(
            icon: Icons.calendar_month_rounded,
            label: "CALENDAR",
            onTap: () {
              state.setScreenIndex(16); // Navigate to Calendar tab
            },
          ),
          _buildOptionButton(
            icon: Icons.videogame_asset_rounded,
            label: "RENDER",
            onTap: () {
              state.setScreenIndex(5); // Navigate to Realtime Render View
            },
          ),
          _buildOptionButton(
            icon: Icons.add_location_alt_rounded,
            label: "ADD LOCATION",
            onTap: () {
              _showAddLocationDialog(context, state);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: CyberTheme.neonBlue, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: CyberTheme.monospaceStyle(fontSize: 8, color: Colors.white).copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLocationDialog(BuildContext context, EngineState state) {
    final nameCtrl = TextEditingController();
    final latCtrl = TextEditingController();
    final lngCtrl = TextEditingController();
    final detailsCtrl = TextEditingController();
    String selectedCompany = _selectedCompany;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0C0E14),
          title: Text(
            "REGISTER CUSTOM VECTOR LOCATION",
            style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCompany,
                  dropdownColor: const Color(0xFF020204),
                  style: CyberTheme.monospaceStyle(fontSize: 11, color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "PUBLISHER COMPANY",
                    labelStyle: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
                  ),
                  items: _companies.map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase()))).toList(),
                  onChanged: (val) {
                    if (val != null) selectedCompany = val;
                  },
                ),
                TextField(
                  controller: nameCtrl,
                  style: CyberTheme.monospaceStyle(fontSize: 11, color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "BRANCH NAME (e.g. Rockstar London)",
                    labelStyle: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
                  ),
                ),
                TextField(
                  controller: latCtrl,
                  keyboardType: TextInputType.number,
                  style: CyberTheme.monospaceStyle(fontSize: 11, color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "LATITUDE (-90.0 to 90.0)",
                    labelStyle: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
                  ),
                ),
                TextField(
                  controller: lngCtrl,
                  keyboardType: TextInputType.number,
                  style: CyberTheme.monospaceStyle(fontSize: 11, color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "LONGITUDE (-180.0 to 180.0)",
                    labelStyle: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
                  ),
                ),
                TextField(
                  controller: detailsCtrl,
                  style: CyberTheme.monospaceStyle(fontSize: 11, color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "BRANCH DETAILS",
                    labelStyle: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("CANCEL", style: CyberTheme.monospaceStyle(fontSize: 10, color: CyberTheme.textMuted)),
            ),
            TextButton(
              onPressed: () {
                final double? lat = double.tryParse(latCtrl.text);
                final double? lng = double.tryParse(lngCtrl.text);
                if (nameCtrl.text.isNotEmpty && lat != null && lng != null) {
                  final newMarker = MapMarker(
                    name: nameCtrl.text,
                    type: "studio",
                    latitude: lat,
                    longitude: lng,
                    details: detailsCtrl.text.isEmpty ? "Custom added studio branch." : detailsCtrl.text,
                    company: selectedCompany,
                    code: "US", // Default country code
                  );
                  state.addCustomMapMarker(newMarker);
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF00FF88).withOpacity(0.2),
                      content: Text(
                        "SUCCESS: REGISTERED ${nameCtrl.text.toUpperCase()} IN HUD VECTOR MAP.",
                        style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  );
                }
              },
              child: Text("REGISTER", style: CyberTheme.monospaceStyle(fontSize: 10, color: const Color(0xFF00FF88))),
            ),
          ],
        );
      },
    );
  }
}


