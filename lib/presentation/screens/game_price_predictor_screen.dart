import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dream_engine_ai/core/state/engine_state.dart';
import 'package:dream_engine_ai/core/theme/cyber_theme.dart';
import 'package:dream_engine_ai/core/widgets/glass_container.dart';
import 'package:dream_engine_ai/core/widgets/neon_button.dart';
// import 'package:dream_engine_ai/core/widgets/hud_world_map.dart';
import 'package:dream_engine_ai/core/widgets/game_sparkline.dart';

class GamePricePredictorScreen extends StatefulWidget {
  const GamePricePredictorScreen({super.key});

  @override
  State<GamePricePredictorScreen> createState() => _GamePricePredictorScreenState();
}

class _GamePricePredictorScreenState extends State<GamePricePredictorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _calendarFilter = "ALL";
  int? _expandedGameIndex;
  final TextEditingController _searchController = TextEditingController();

  // New Game Forecaster form state
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _publisherController = TextEditingController();
  String _selectedCategory = "AAA";
  String _selectedGenre = "RPG";
  final TextEditingController _basePriceController = TextEditingController(text: "69.99");

  bool _isAnalyzing = false;
  double _analysisProgress = 0.0;
  String _analysisStatus = "";
  Map<String, dynamic>? _predictionResults;
  Timer? _analysisTimer;
  int _selectedMatrixGameIndex = 0;

  static const Map<String, double> nominalExchangeRates = {
    "US": 1.0,
    "EU": 0.92,
    "GB": 0.78,
    "IN": 83.3,
    "JP": 155.0,
    "BR": 5.15,
    "CA": 1.37,
    "AU": 1.51,
    "CN": 7.24,
    "TR": 32.2,
    "AR": 895.0,
    "MX": 16.7,
    "KR": 1365.0,
    "ZA": 18.4,
    "CH": 0.91,
    "SG": 1.35,
    "HK": 7.81,
    "NZ": 1.64,
    "SE": 10.6,
    "NO": 10.7,
    "DK": 6.88,
    "PL": 3.95,
    "CZ": 22.8,
    "HU": 355.0,
    "IL": 3.72,
    "CL": 910.0,
    "CO": 3850.0,
    "PE": 3.73,
    "PH": 57.8,
    "MY": 4.71,
    "ID": 16100.0,
    "TH": 36.6,
    "VN": 25400.0,
    "SA": 3.75,
    "AE": 3.67,
    "EG": 47.4,
    "TW": 32.3,
    "UA": 40.2,
    "RU": 91.5,
    "NG": 1450.0,
    "KE": 131.0,
    "PK": 278.0,
    "BD": 117.0,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _publisherController.dispose();
    _basePriceController.dispose();
    _searchController.dispose();
    _analysisTimer?.cancel();
    super.dispose();
  }

  String _formatRecommendation(String rec, EngineState state) {
    final regExp = RegExp(r'\$?\$([0-9.]+)');
    return rec.replaceAllMapped(regExp, (match) {
      final usdAmount = double.tryParse(match.group(1) ?? "") ?? 0.0;
      return state.formatRegionalPrice(usdAmount);
    });
  }

  String _formatLocalAmount(double amount, EngineState state) {
    if (state.selectedRegion.currency == "JPY" || state.selectedRegion.currency == "KRW") {
      return "${state.selectedRegion.currencySymbol}${amount.toStringAsFixed(0)}";
    }
    return "${state.selectedRegion.currencySymbol}${amount.toStringAsFixed(2)}";
  }

  Color _getThemeColor(EngineState state) {
    if (state.currentTheme == AppTheme.ironMan) return Colors.amber;
    if (state.currentTheme == AppTheme.nvidiaGreen) return Colors.lightGreenAccent;
    if (state.currentTheme == AppTheme.appleVision) return Colors.white;
    return CyberTheme.neonBlue;
  }

  void _triggerAnalysis(EngineState state) {
    if (_titleController.text.trim().isEmpty || _publisherController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFFF1E27).withOpacity(0.2),
          content: Text(
            "ERROR: Dossier incomplete. Please specify Game Title & Publisher.",
            style: CyberTheme.monospaceStyle(fontSize: 11, color: Colors.white),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisProgress = 0.0;
      _predictionResults = null;
    });

    final steps = [
      "Analyzing publisher discounting index...",
      "Resolving category pricing margins...",
      "Simulating pricing decay curves...",
      "Compiling prediction model matrix...",
      "Finalizing game price projection data!"
    ];

    int stepIdx = 0;
    _analysisTimer = Timer.periodic(const Duration(milliseconds: 350), (timer) async {
      if (stepIdx < steps.length) {
        setState(() {
          _analysisStatus = steps[stepIdx];
          _analysisProgress = (stepIdx + 1) / steps.length;
        });
        stepIdx++;
      } else {
        timer.cancel();
        final double basePrice = double.tryParse(_basePriceController.text) ?? 69.99;
        final results = await state.predictNewGamePrice(
          title: _titleController.text.trim(),
          publisher: _publisherController.text.trim(),
          category: _selectedCategory,
          genre: _selectedGenre,
          basePrice: basePrice,
        );
        setState(() {
          _isAnalyzing = false;
          _predictionResults = results;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<EngineState>(context);
    final themeColor = _getThemeColor(state);
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 768;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text("HUD RELEASE & SALES TELEMETRY", style: CyberTheme.headingStyle(fontSize: 14)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<RegionalMarket>(
                value: state.selectedRegion,
                dropdownColor: const Color(0xFF020204),
                icon: Icon(Icons.language_rounded, color: themeColor, size: 16),
                style: CyberTheme.monospaceStyle(fontSize: 9, color: Colors.white),
                onChanged: (RegionalMarket? newRegion) {
                  if (newRegion != null) {
                    state.setSelectedRegion(newRegion);
                    double baseUsd = 69.99;
                    if (_selectedCategory == "AA") baseUsd = 39.99;
                    else if (_selectedCategory == "INDIE") baseUsd = 24.99;
                    _basePriceController.text = state.convertPrice(baseUsd).toStringAsFixed(2);
                  }
                },
                items: state.regionalMarkets.map((RegionalMarket market) {
                  return DropdownMenuItem<RegionalMarket>(
                    value: market,
                    child: Text("${market.regionName} (${market.currency})"),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: themeColor,
          labelColor: Colors.white,
          unselectedLabelColor: CyberTheme.textMuted,
          labelStyle: CyberTheme.monospaceStyle(fontSize: 9).copyWith(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "RELEASE & SALE CALENDAR"),
            Tab(text: "PRICE TRACKER & FORECASTER"),
            Tab(text: "NEW GAME PREDICTOR"),
            Tab(text: "GLOBAL LOCATION MATRIX"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: CALENDAR
          _buildCalendarTab(state, themeColor, isMobile),

          // TAB 2: PRICE FORECASTER
          _buildPriceTrackerTab(state, themeColor, isMobile),

          // TAB 3: NEW GAME PREDICTOR
          _buildNewGamePredictorTab(state, themeColor, isMobile),

          // TAB 4: GLOBAL LOCATION MATRIX
          _buildGlobalLocationMatrixTab(state, themeColor, isMobile),
        ],
      ),
    );
  }

  // --- CALENDAR TAB BUILDER ---
  Widget _buildCalendarTab(EngineState state, Color themeColor, bool isMobile) {
    final filteredEvents = state.calendarEvents.where((e) {
      if (_calendarFilter == "ALL") return true;
      if (_calendarFilter == "RELEASES") return e.type == "release";
      if (_calendarFilter == "SALES") return e.type == "sale";
      return true;
    }).toList();

    // Sort events chronologically
    filteredEvents.sort((a, b) => a.date.compareTo(b.date));

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter badges
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ["ALL", "RELEASES", "SALES"].map((filter) {
                final isSelected = _calendarFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _calendarFilter = filter;
                      });
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? themeColor.withOpacity(0.18) : Colors.white.withOpacity(0.02),
                        border: Border.all(
                          color: isSelected ? themeColor : Colors.white10,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        filter + (filter == "ALL" ? " EVENTS" : " ONLY"),
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
          const SizedBox(height: 16),

          // Events Timeline list
          Expanded(
            child: filteredEvents.isEmpty
                ? Center(
                    child: Text(
                      "NO TIMELINE VECTORS RECORDED.",
                      style: CyberTheme.monospaceStyle(fontSize: 10, color: CyberTheme.textMuted),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      final isSale = event.type == "sale";
                      final eventColor = isSale ? const Color(0xFFFF1E27) : const Color(0xFF00FF88);

                      final months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
                      final monthStr = months[event.date.month - 1];
                      final dayStr = event.date.day.toString().padLeft(2, '0');

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: GlassContainer(
                          borderColor: themeColor.withOpacity(0.12),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Big Date Card
                              Container(
                                width: 68,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.03),
                                  border: Border.all(color: Colors.white10),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      monthStr,
                                      style: CyberTheme.monospaceStyle(fontSize: 10, color: themeColor),
                                    ),
                                    Text(
                                      dayStr,
                                      style: CyberTheme.titleStyle(fontSize: 22, color: Colors.white).copyWith(shadows: []),
                                    ),
                                    Text(
                                      event.date.year.toString(),
                                      style: CyberTheme.monospaceStyle(fontSize: 7, color: CyberTheme.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Info Column
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: eventColor.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: eventColor.withOpacity(0.3)),
                                          ),
                                          child: Text(
                                            event.type.toUpperCase(),
                                            style: CyberTheme.monospaceStyle(fontSize: 8, color: eventColor),
                                          ),
                                        ),
                                        Text(
                                          "// ${event.platform}",
                                          style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      event.title.toUpperCase(),
                                      style: CyberTheme.headingStyle(fontSize: 13, color: Colors.white),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      event.description,
                                      style: CyberTheme.bodyStyle(fontSize: 11, color: CyberTheme.textMuted),
                                    ),
                                    if (event.expectedPrice != null || event.expectedDiscount != null) ...[
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Icon(Icons.tag_rounded, size: 12, color: themeColor),
                                          const SizedBox(width: 4),
                                          Text(
                                            event.expectedPrice != null
                                                ? "EST. MSRP: ${state.formatRegionalPrice(event.expectedPrice!)}"
                                                : "EST. SCOPE: Up to ${event.expectedDiscount!}% OFF",
                                            style: CyberTheme.monospaceStyle(fontSize: 9, color: themeColor),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
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

  Widget _buildPriceTrackerTab(EngineState state, Color themeColor, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
      child: Column(
        children: [
          // Cyberpunk Search bar for live CheapShark predictions
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: CyberTheme.bodyStyle(fontSize: 12, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "ENTER GAME TITLE FOR LIVE FORECAST...",
                    hintStyle: CyberTheme.monospaceStyle(fontSize: 9, color: Colors.white30),
                    prefixIcon: Icon(Icons.search, color: themeColor, size: 16),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: themeColor.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: themeColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  ),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      state.predictLiveGamePrice(val.trim());
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              state.isSearchingLiveGame
                  ? SizedBox(
                      width: 40,
                      height: 40,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                        ),
                      ),
                    )
                  : NeonButton(
                      width: 80,
                      height: 40,
                      onPressed: () {
                        if (_searchController.text.trim().isNotEmpty) {
                          state.predictLiveGamePrice(_searchController.text.trim());
                        }
                      },
                      glowColor: themeColor,
                      gradientColors: [themeColor, themeColor.withOpacity(0.6)],
                      child: Text(
                        "SEARCH",
                        style: CyberTheme.monospaceStyle(fontSize: 9, color: Colors.white),
                      ),
                    ),
            ],
          ),
          if (state.liveGameSearchError.isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "WARNING: ${state.liveGameSearchError}",
                style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.neonBlue),
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Expanded price forecast list
          Expanded(
            child: ListView.builder(
              itemCount: state.predictorGames.length,
              itemBuilder: (context, index) {
          final game = state.predictorGames[index];
          final isExpanded = _expandedGameIndex == index;
          final waitWarning = game.recommendation.contains("WAIT");
          final recColor = waitWarning ? Colors.orangeAccent : const Color(0xFF00FF88);

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: GlassContainer(
              borderColor: isExpanded ? themeColor.withOpacity(0.4) : themeColor.withOpacity(0.12),
              hasGlow: isExpanded,
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  // Main row
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        game.imageUrl,
                        width: 70,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 70,
                          height: 50,
                          color: Colors.white.withOpacity(0.05),
                          child: const Icon(Icons.videogame_asset, size: 20, color: Colors.white30),
                        ),
                      ),
                    ),
                    title: Text(
                      game.title.toUpperCase(),
                      style: CyberTheme.headingStyle(fontSize: 13, color: Colors.white),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: game.store == "Steam" ? Colors.blue.withOpacity(0.1) : Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: game.store == "Steam" ? Colors.blueAccent : Colors.amberAccent,
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              game.store.toUpperCase(),
                              style: CyberTheme.monospaceStyle(
                                fontSize: 7,
                                color: game.store == "Steam" ? Colors.blueAccent : Colors.amberAccent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "MSRP: ${state.formatRegionalPrice(game.basePrice)}",
                            style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          state.formatRegionalPrice(game.currentPrice),
                          style: CyberTheme.titleStyle(fontSize: 14, color: Colors.white).copyWith(shadows: []),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isExpanded ? "COLLAPSE" : "FORECAST",
                          style: CyberTheme.monospaceStyle(fontSize: 8, color: themeColor),
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        _expandedGameIndex = isExpanded ? null : index;
                      });
                    },
                  ),

                  // Expandable panel
                  if (isExpanded) ...[
                    const Divider(color: Colors.white10, height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Sparkline history chart
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "12-MONTH HISTORICAL PRICE WAVEFORM",
                                style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
                              ),
                              Text(
                                "HISTORIC LOW: ${state.formatRegionalPrice(game.historicalLow)}",
                                style: CyberTheme.monospaceStyle(fontSize: 8, color: themeColor),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 60,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              border: Border.all(color: Colors.white.withOpacity(0.05)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: GameSparkline(
                                data: game.priceHistory.map((p) => state.convertPrice(p)).toList(),
                                isPositive: game.currentPrice <= game.priceHistory.first,
                                width: isMobile ? 240 : 400,
                                height: 44,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // AI price prediction details grid
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildPredictionMetricsCard(
                                  "NEXT DISCOUNT ESTIMATE",
                                  game.nextPredictedSale.toUpperCase(),
                                  Icons.calendar_today_rounded,
                                  themeColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildPredictionMetricsCard(
                                  "FORECASTED DISCOUNT PRICE",
                                  "${state.formatRegionalPrice(game.basePrice * (1 - (game.predictedDiscountPercent / 100)))} (-${game.predictedDiscountPercent.toInt()}%)",
                                  Icons.trending_down_rounded,
                                  themeColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildPredictionMetricsCard(
                                  "PREDICTION CONFIDENCE",
                                  game.confidence,
                                  Icons.online_prediction_rounded,
                                  themeColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildPredictionMetricsCard(
                                  "LAST SALE REGISTERED",
                                  game.lastDiscountDate.toUpperCase(),
                                  Icons.history_rounded,
                                  themeColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Advice block
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: recColor.withOpacity(0.05),
                              border: Border.all(color: recColor.withOpacity(0.2)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  waitWarning ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                                  color: recColor,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        waitWarning ? "SYSTEM RECOMMENDATION: WAITING PROTOCOL" : "SYSTEM RECOMMENDATION: ACQUIRE LICENSE",
                                        style: CyberTheme.monospaceStyle(fontSize: 9, color: recColor).copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatRecommendation(game.recommendation, state),
                                        style: CyberTheme.bodyStyle(fontSize: 11, color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
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

  Widget _buildPredictionMetricsCard(String title, String val, IconData icon, Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: themeColor.withOpacity(0.6)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: CyberTheme.monospaceStyle(fontSize: 7, color: CyberTheme.textMuted)),
                const SizedBox(height: 2),
                Text(
                  val,
                  style: CyberTheme.monospaceStyle(fontSize: 9, color: Colors.white).copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- NEW GAME PREDICTOR TAB BUILDER ---
  Widget _buildNewGamePredictorTab(EngineState state, Color themeColor, bool isMobile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_isAnalyzing && _predictionResults == null)
            GlassContainer(
              borderColor: themeColor.withOpacity(0.15),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("SIMULATE NEW GAME DECAY PROJECTION", style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white)),
                  const SizedBox(height: 6),
                  Text(
                    "Input target specifications to compile estimated MSRP launch prices and sale calendars based on publisher profiles.",
                    style: CyberTheme.bodyStyle(fontSize: 11, color: CyberTheme.textMuted),
                  ),
                  const SizedBox(height: 20),

                  // Title Input
                  TextField(
                    controller: _titleController,
                    style: CyberTheme.bodyStyle(fontSize: 13, color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "TARGET GAME TITLE",
                      labelStyle: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: themeColor.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: themeColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Publisher Input
                  TextField(
                    controller: _publisherController,
                    style: CyberTheme.bodyStyle(fontSize: 13, color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "PUBLISHER / STUDIO NAME",
                      labelStyle: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
                      hintText: "Rockstar, Ubisoft, EA, Capcom, Indie...",
                      hintStyle: CyberTheme.bodyStyle(fontSize: 11, color: Colors.white24),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: themeColor.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: themeColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Row for Dropdowns
                  Row(
                    children: [
                      // Studio Category
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          dropdownColor: const Color(0xFF020204),
                          style: CyberTheme.monospaceStyle(fontSize: 12, color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "STUDIO CATEGORY",
                            labelStyle: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: themeColor.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: ["AAA", "AA", "INDIE"].map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat,
                              child: Text(cat),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedCategory = val;
                                double baseUsd = 69.99;
                                if (val == "AA") baseUsd = 39.99;
                                else if (val == "INDIE") baseUsd = 24.99;
                                _basePriceController.text = state.convertPrice(baseUsd).toStringAsFixed(2);
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Genre
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedGenre,
                          dropdownColor: const Color(0xFF020204),
                          style: CyberTheme.monospaceStyle(fontSize: 12, color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "GENRE VECTOR",
                            labelStyle: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: themeColor.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: ["RPG", "FPS/Action", "Strategy", "Adventure"].map((g) {
                            return DropdownMenuItem<String>(
                              value: g,
                              child: Text(g.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedGenre = val;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Base Price Input
                  TextField(
                    controller: _basePriceController,
                    keyboardType: TextInputType.number,
                    style: CyberTheme.monospaceStyle(fontSize: 13, color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "BASE MSRP PROJECTED PRICE (${state.selectedRegion.currencySymbol})",
                      labelStyle: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: themeColor.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: themeColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  NeonButton(
                    onPressed: () => _triggerAnalysis(state),
                    glowColor: themeColor,
                    gradientColors: [themeColor, themeColor.withOpacity(0.5)],
                    child: Text(
                      "SIMULATE PRICE FORECAST",
                      style: CyberTheme.headingStyle(fontSize: 11, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

          // LOADING STATE
          if (_isAnalyzing)
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: GlassContainer(
                borderColor: themeColor,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                child: Column(
                  children: [
                    const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    const SizedBox(height: 24),
                    Text(
                      _analysisStatus.toUpperCase(),
                      style: CyberTheme.monospaceStyle(fontSize: 10, color: themeColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _analysisProgress,
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // RESULTS STATE
          if (!_isAnalyzing && _predictionResults != null) ...[
            GlassContainer(
              borderColor: themeColor.withOpacity(0.4),
              hasGlow: true,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _predictionResults!["title"].toString().toUpperCase(),
                          style: CyberTheme.titleStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white54),
                        onPressed: () {
                          setState(() {
                            _predictionResults = null;
                          });
                        },
                      ),
                    ],
                  ),
                  Text(
                    "PREDICTION DOSSIER COMPLETED // AUTHOR: DREAMENGINE NEURAL MATRIX",
                    style: CyberTheme.monospaceStyle(fontSize: 8, color: themeColor),
                  ),
                  const Divider(color: Colors.white12, height: 24),

                  // Results Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildResultStat(
                          "ESTIMATED RELEASE MSRP",
                          _formatLocalAmount(_predictionResults!["launchPrice"], state),
                          themeColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildResultStat(
                          "PUBLISHER PRICE DECAY SPEED",
                          _predictionResults!["decaySpeed"].toString(),
                          themeColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildResultStat(
                          "EST. DAYS UNTIL FIRST SALE",
                          "${_predictionResults!["monthsToFirstDiscount"] * 30} DAYS",
                          themeColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildResultStat(
                          "ESTIMATED FIRST DISCOUNT PRICE",
                          "${_formatLocalAmount(_predictionResults!["predictedDiscountedPrice"], state)} (-${_predictionResults!["firstDiscountPercent"].toInt()}%)",
                          themeColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Pre-order advisory block
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.05),
                      border: Border.all(color: themeColor.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.gavel_rounded, color: themeColor, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              "INTELLIGENT PRE-ORDER ADVISORY",
                              style: CyberTheme.monospaceStyle(fontSize: 9, color: themeColor).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatRecommendation(_predictionResults!["advise"].toString(), state),
                          style: CyberTheme.bodyStyle(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _predictionResults = null;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: themeColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      "SIMULATE ANOTHER VECTOR",
                      style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultStat(String label, String value, Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted)),
          const SizedBox(height: 6),
          Text(
            value,
            style: CyberTheme.titleStyle(fontSize: 14, color: Colors.white).copyWith(shadows: []),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalLocationMatrixTab(EngineState state, Color themeColor, bool isMobile) {
    if (state.predictorGames.isEmpty) {
      return Center(
        child: Text(
          "NO PREDICTOR GAMES AVAILABLE.\nPLEASE SEARCH A GAME IN THE TRACKER TAB FIRST.",
          style: CyberTheme.monospaceStyle(fontSize: 11, color: CyberTheme.textMuted),
          textAlign: TextAlign.center,
        ),
      );
    }

    final gameIdx = _selectedMatrixGameIndex < state.predictorGames.length ? _selectedMatrixGameIndex : 0;
    final game = state.predictorGames[gameIdx];
    final baseUsdPrice = game.currentPrice;

    final List<Map<String, dynamic>> marketData = [];
    
    for (var market in state.regionalMarkets) {
      final countryCode = market.countryCode;
      final nominalRate = nominalExchangeRates[countryCode] ?? 1.0;
      final double localPrice = baseUsdPrice * market.pppMultiplier;
      final double usdEquivalent = localPrice / nominalRate;
      final double savingsPercent = baseUsdPrice > 0 
          ? ((baseUsdPrice - usdEquivalent) / baseUsdPrice) * 100.0 
          : 0.0;
          
      marketData.add({
        "market": market,
        "localPrice": localPrice,
        "usdEquivalent": usdEquivalent,
        "savingsPercent": savingsPercent,
      });
    }

    marketData.sort((a, b) => (a["usdEquivalent"] as double).compareTo(b["usdEquivalent"] as double));

    final cheapest = marketData.first;
    final mostExpensive = marketData.last;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassContainer(
            borderColor: themeColor.withOpacity(0.15),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<int>(
                    value: gameIdx,
                    dropdownColor: const Color(0xFF020204),
                    style: CyberTheme.monospaceStyle(fontSize: 11, color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "SELECT TELEMETRY VECTOR (TARGET GAME)",
                      labelStyle: CyberTheme.monospaceStyle(fontSize: 8, color: themeColor),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: themeColor.withOpacity(0.3)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: themeColor),
                      ),
                    ),
                    items: List.generate(state.predictorGames.length, (idx) {
                      final g = state.predictorGames[idx];
                      return DropdownMenuItem<int>(
                        value: idx,
                        child: Text(g.title.toUpperCase()),
                      );
                    }),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedMatrixGameIndex = val;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        game.imageUrl,
                        width: 60,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 60,
                          height: 40,
                          color: Colors.white10,
                          child: const Icon(Icons.videogame_asset, size: 16, color: Colors.white30),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            game.title.toUpperCase(),
                            style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "BASE STORE PRICE: \$${baseUsdPrice.toStringAsFixed(2)} USD // STORE: ${game.store.toUpperCase()}",
                            style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildArbitrageSummaryCard(
                  "OPTIMAL REGIONAL PURCHASE",
                  "${(cheapest["market"] as RegionalMarket).regionName.toUpperCase()}",
                  "COST: \$${(cheapest["usdEquivalent"] as double).toStringAsFixed(2)} USD",
                  "SAVINGS: ${cheapest["savingsPercent"].toStringAsFixed(1)}%",
                  const Color(0xFF00FF88),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildArbitrageSummaryCard(
                  "MAX COST REGION",
                  "${(mostExpensive["market"] as RegionalMarket).regionName.toUpperCase()}",
                  "COST: \$${(mostExpensive["usdEquivalent"] as double).toStringAsFixed(2)} USD",
                  "LOSS/SURCHARGE",
                  const Color(0xFFFF1E27),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              border: Border.all(color: Colors.white10),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text("REGION / CURRENCY", style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted)),
                ),
                Expanded(
                  flex: 2,
                  child: Text("LOCAL PRICE", style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted), textAlign: TextAlign.right),
                ),
                Expanded(
                  flex: 2,
                  child: Text("USD EQUIV", style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted), textAlign: TextAlign.right),
                ),
                Expanded(
                  flex: 2,
                  child: Text("SAVINGS %", style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted), textAlign: TextAlign.right),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white10),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                color: Colors.white.withOpacity(0.01),
              ),
              child: ListView.separated(
                itemCount: marketData.length,
                separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
                itemBuilder: (context, index) {
                  final data = marketData[index];
                  final RegionalMarket market = data["market"];
                  final double localPrice = data["localPrice"];
                  final double usdEquivalent = data["usdEquivalent"];
                  final double savingsPercent = data["savingsPercent"];
                  
                  final isCheapest = market.countryCode == (cheapest["market"] as RegionalMarket).countryCode;
                  
                  Color savingsColor = CyberTheme.textMuted;
                  if (savingsPercent > 30) {
                    savingsColor = const Color(0xFF00FF88);
                  } else if (savingsPercent > 10) {
                    savingsColor = Colors.orangeAccent;
                  } else if (savingsPercent < 0) {
                    savingsColor = const Color(0xFFFF1E27);
                  }

                  String formattedLocal = "";
                  if (market.currency == "JPY" || market.currency == "KRW" || market.currency == "VND" || market.currency == "IDR") {
                    formattedLocal = "${market.currencySymbol}${localPrice.toStringAsFixed(0)}";
                  } else {
                    formattedLocal = "${market.currencySymbol}${localPrice.toStringAsFixed(2)}";
                  }

                  return InkWell(
                    onTap: () {
                      state.setSelectedRegion(market);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: themeColor.withOpacity(0.2),
                          content: Text(
                            "ACTIVE MATRIX LOCALIZATION SWITCHED TO: ${market.regionName.toUpperCase()}",
                            style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.white),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: isCheapest ? const Color(0xFF00FF88).withOpacity(0.04) : Colors.transparent,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                Text(
                                  market.countryCode,
                                  style: CyberTheme.monospaceStyle(fontSize: 8, color: themeColor).copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    market.regionName.toUpperCase(),
                                    style: CyberTheme.headingStyle(fontSize: 9, color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              formattedLocal,
                              style: CyberTheme.monospaceStyle(fontSize: 9, color: Colors.white),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "\$${usdEquivalent.toStringAsFixed(2)}",
                              style: CyberTheme.monospaceStyle(fontSize: 9, color: Colors.white70),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (savingsPercent > 30)
                                  const Icon(Icons.arrow_downward_rounded, size: 10, color: Color(0xFF00FF88))
                                else if (savingsPercent < 0)
                                  const Icon(Icons.arrow_upward_rounded, size: 10, color: Color(0xFFFF1E27)),
                                const SizedBox(width: 2),
                                Text(
                                  "${savingsPercent >= 0 ? '+' : ''}${savingsPercent.toStringAsFixed(1)}%",
                                  style: CyberTheme.monospaceStyle(fontSize: 9, color: savingsColor).copyWith(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.right,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArbitrageSummaryCard(String title, String val, String subtitle1, String subtitle2, Color accentColor) {
    return GlassContainer(
      borderColor: accentColor.withOpacity(0.2),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted)),
          const SizedBox(height: 6),
          Text(
            val,
            style: CyberTheme.titleStyle(fontSize: 12, color: Colors.white).copyWith(shadows: []),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(subtitle1, style: CyberTheme.monospaceStyle(fontSize: 8, color: accentColor)),
              Text(subtitle2, style: CyberTheme.monospaceStyle(fontSize: 8, color: Colors.white60)),
            ],
          ),
        ],
      ),
    );
  }
}
