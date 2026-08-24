import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dream_engine_ai/core/state/engine_state.dart';
import 'package:dream_engine_ai/core/theme/cyber_theme.dart';
import 'package:dream_engine_ai/core/widgets/glass_container.dart';

class GameNewsScreen extends StatefulWidget {
  const GameNewsScreen({super.key});

  @override
  State<GameNewsScreen> createState() => _GameNewsScreenState();
}

class _GameNewsScreenState extends State<GameNewsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = "ALL";
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<EngineState>(context, listen: false);
      if (state.gameNews.isEmpty) {
        state.fetchGameNews();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getThemeColor(EngineState state) {
    if (state.currentTheme == AppTheme.ironMan) return Colors.amber;
    if (state.currentTheme == AppTheme.nvidiaGreen) return Colors.lightGreenAccent;
    if (state.currentTheme == AppTheme.appleVision) return Colors.white;
    return CyberTheme.neonBlue;
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("Could not launch $urlString");
      }
    } catch (e) {
      debugPrint("Error launching url: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<EngineState>(context);
    final themeColor = _getThemeColor(state);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    // Filter items based on search and category
    final filteredNews = state.gameNews.where((item) {
      final title = item["title"]?.toString().toLowerCase() ?? "";
      final desc = item["description"]?.toString().toLowerCase() ?? "";
      final matchesSearch = title.contains(_searchQuery) || desc.contains(_searchQuery);

      if (_selectedCategory == "ALL") return matchesSearch;
      
      // Categorize by keywords in title/desc
      if (_selectedCategory == "VOXEL") {
        return matchesSearch && (title.contains("voxel") || title.contains("procedural") || desc.contains("voxel") || desc.contains("procedural"));
      } else if (_selectedCategory == "PLAYSTATION") {
        return matchesSearch && (title.contains("ps5") || title.contains("playstation") || desc.contains("ps5") || desc.contains("playstation"));
      } else if (_selectedCategory == "XBOX") {
        return matchesSearch && (title.contains("xbox") || desc.contains("xbox"));
      } else if (_selectedCategory == "PC") {
        return matchesSearch && (title.contains("pc") || title.contains("steam") || desc.contains("pc") || desc.contains("steam"));
      } else if (_selectedCategory == "NINTENDO") {
        return matchesSearch && (title.contains("switch") || title.contains("nintendo") || desc.contains("switch") || desc.contains("nintendo"));
      } else if (_selectedCategory == "MOBILE") {
        return matchesSearch && (title.contains("mobile") || title.contains("android") || title.contains("ios") || desc.contains("mobile"));
      }
      return matchesSearch;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
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
                  Text("OPERATOR DAILY FEED", style: CyberTheme.titleStyle(fontSize: isMobile ? 18 : 22)),
                  Text(
                    "DAILY SYNAPSE SYNC: GAMES NEWS AGGREGATED VIA SECURE API",
                    style: CyberTheme.monospaceStyle(fontSize: 8, color: themeColor),
                  ),
                ],
              ),
              IconButton(
                onPressed: state.isFetchingNews ? null : () => state.fetchGameNews(),
                icon: state.isFetchingNews
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                      )
                    : Icon(Icons.sync_rounded, color: themeColor, size: 24),
                tooltip: "Resync News Channels",
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search and Category selectors
          GlassContainer(
            borderColor: themeColor.withOpacity(0.15),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  style: CyberTheme.bodyStyle(fontSize: 13, color: Colors.white),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim().toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "SEARCH NEWS VECTORS...",
                    hintStyle: CyberTheme.bodyStyle(fontSize: 12, color: Colors.white24),
                    prefixIcon: Icon(Icons.search_rounded, color: themeColor, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: Colors.white54, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = "";
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.3),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: themeColor.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: themeColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Category badges
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ["ALL", "VOXEL", "PLAYSTATION", "XBOX", "PC", "NINTENDO", "MOBILE"].map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? themeColor.withOpacity(0.2) : Colors.white.withOpacity(0.02),
                              border: Border.all(
                                color: isSelected ? themeColor : Colors.white10,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              cat,
                              style: CyberTheme.monospaceStyle(
                                fontSize: 9,
                                color: isSelected ? Colors.white : CyberTheme.textMuted,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // News Feed List
          if (state.isFetchingNews && state.gameNews.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
                    const SizedBox(height: 12),
                    Text(
                      "CONNECTING NEWS TERMINALS...",
                      style: CyberTheme.monospaceStyle(fontSize: 10, color: CyberTheme.textMuted),
                    ),
                  ],
                ),
              ),
            )
          else if (filteredNews.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.satellite_alt_rounded, size: 48, color: CyberTheme.textMuted.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text(
                      "NO SIGNALS RECEIVED.",
                      style: CyberTheme.titleStyle(fontSize: 14, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "CALIBRATE SEARCH VECTOR OR FLUSH CACHE FILTER.",
                      style: CyberTheme.monospaceStyle(fontSize: 9, color: CyberTheme.textMuted),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredNews.length,
              itemBuilder: (context, index) {
                final item = filteredNews[index];
                final String title = item["title"] ?? "Untitled Signal";
                final String date = item["pubDate"] ?? "";
                final String author = item["author"] ?? "Unknown Operator";
                final String desc = item["description"] ?? "";
                final String thumbnail = item["thumbnail"] ?? "";
                final String link = item["link"] ?? "";

                // Strip HTML tags from description if present
                final cleanDesc = desc.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), ' ').trim();

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: GlassContainer(
                    borderColor: themeColor.withOpacity(0.15),
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Card Header image with overlays
                        if (thumbnail.isNotEmpty)
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                child: Image.network(
                                  thumbnail,
                                  height: isMobile ? 160 : 220,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      height: isMobile ? 160 : 220,
                                      color: Colors.white.withOpacity(0.02),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                              : null,
                                          valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: isMobile ? 160 : 220,
                                      color: Colors.white.withOpacity(0.02),
                                      child: Center(
                                        child: Icon(Icons.broken_image_rounded, color: themeColor.withOpacity(0.4), size: 40),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // Neon shade overlay
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ),
                              // Date overlay
                              Positioned(
                                bottom: 10,
                                right: 12,
                                child: Text(
                                  date,
                                  style: CyberTheme.monospaceStyle(fontSize: 9, color: themeColor),
                                ),
                              ),
                            ],
                          ),

                        // Card Content
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: CyberTheme.titleStyle(fontSize: 16, color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.edit_note_rounded, size: 14, color: themeColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    "AGENT: ${author.toUpperCase()}",
                                    style: CyberTheme.monospaceStyle(fontSize: 9, color: CyberTheme.textMuted),
                                  ),
                                  if (thumbnail.isEmpty) ...[
                                    const Spacer(),
                                    Text(
                                      date,
                                      style: CyberTheme.monospaceStyle(fontSize: 9, color: themeColor),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                cleanDesc,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: CyberTheme.bodyStyle(fontSize: 12, color: CyberTheme.textMuted),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    onPressed: link.isEmpty ? null : () => _launchUrl(link),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: themeColor.withOpacity(0.5)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          "LAUNCH WIRE",
                                          style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.white),
                                        ),
                                        const SizedBox(width: 6),
                                        Icon(Icons.launch_rounded, size: 12, color: themeColor),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
