import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dream_engine_ai/core/state/engine_state.dart';
import 'package:dream_engine_ai/core/theme/cyber_theme.dart';
import 'package:dream_engine_ai/core/widgets/glass_container.dart';
import 'package:dream_engine_ai/core/widgets/neon_button.dart';
import 'package:dream_engine_ai/core/widgets/game_sparkline.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getThemeColor(EngineState state) {
    if (state.currentTheme == AppTheme.ironMan) return Colors.amber;
    if (state.currentTheme == AppTheme.nvidiaGreen) return Colors.lightGreenAccent;
    if (state.currentTheme == AppTheme.appleVision) return Colors.white;
    return CyberTheme.neonBlue;
  }

  void _showTradeDialog(BuildContext context, GameStock stock, EngineState state, Color themeColor) {
    final TextEditingController qtyController = TextEditingController(text: "10");
    
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: GlassContainer(
              borderColor: themeColor.withOpacity(0.3),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "TRADE PROTOCOL: ${stock.symbol}",
                        style: CyberTheme.headingStyle(fontSize: 14, color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    stock.name,
                    style: CyberTheme.bodyStyle(fontSize: 12, color: CyberTheme.textMuted),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("CURRENT UNIT PRICE:", style: CyberTheme.monospaceStyle(fontSize: 9, color: CyberTheme.textMuted)),
                      Text(
                        "\$${stock.currentPrice.toStringAsFixed(2)}",
                        style: CyberTheme.titleStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("LIQUID CASH AVAILABLE:", style: CyberTheme.monospaceStyle(fontSize: 9, color: CyberTheme.textMuted)),
                      Text(
                        "\$${state.operatorCredits.toStringAsFixed(2)}",
                        style: CyberTheme.monospaceStyle(fontSize: 11, color: themeColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("CURRENT HOLDINGS:", style: CyberTheme.monospaceStyle(fontSize: 9, color: CyberTheme.textMuted)),
                      Text(
                        "${state.ownedStocks[stock.symbol] ?? 0} Shares",
                        style: CyberTheme.monospaceStyle(fontSize: 11, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    style: CyberTheme.monospaceStyle(fontSize: 14, color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "SHARES QUANTITY",
                      labelStyle: CyberTheme.monospaceStyle(fontSize: 9, color: CyberTheme.textMuted),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: themeColor.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: themeColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            final qty = int.tryParse(qtyController.text) ?? 0;
                            if (qty <= 0) return;
                            final success = state.sellStock(stock.symbol, qty);
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: success ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                content: Text(
                                  success 
                                      ? "TRANSACTION CONFIRMED: SOLD $qty SHARES OF ${stock.symbol}."
                                      : "TRANSACTION FAILED: INSUFFICIENT HOLDINGS FOR SALE.",
                                  style: CyberTheme.monospaceStyle(fontSize: 11, color: Colors.white),
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFF1E27)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text("SELL", style: CyberTheme.monospaceStyle(fontSize: 10, color: const Color(0xFFFF1E27))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: NeonButton(
                          onPressed: () {
                            final qty = int.tryParse(qtyController.text) ?? 0;
                            if (qty <= 0) return;
                            final success = state.buyStock(stock.symbol, qty);
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: success ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                content: Text(
                                  success 
                                      ? "TRANSACTION CONFIRMED: PURCHASED $qty SHARES OF ${stock.symbol}."
                                      : "TRANSACTION FAILED: INSUFFICIENT OPERATOR CREDITS.",
                                  style: CyberTheme.monospaceStyle(fontSize: 11, color: Colors.white),
                                ),
                              ),
                            );
                          },
                          glowColor: themeColor,
                          gradientColors: [themeColor, themeColor.withOpacity(0.5)],
                          child: Text("BUY", style: CyberTheme.headingStyle(fontSize: 10, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRechargeDialog(BuildContext context, EngineState state, Color themeColor) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => RechargePortalDialog(state: state, themeColor: themeColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<EngineState>(context);
    final themeColor = _getThemeColor(state);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text("HUD MATRIX MARKETPLACE", style: CyberTheme.headingStyle(fontSize: 14)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: themeColor,
          labelColor: Colors.white,
          unselectedLabelColor: CyberTheme.textMuted,
          labelStyle: CyberTheme.monospaceStyle(fontSize: 9).copyWith(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "AI ASSETS"),
            Tab(text: "GAME STORE"),
            Tab(text: "GAME STOCKS"),
            Tab(text: "DEALS WIRE"),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "LIQUID CREDITS: \$${state.operatorCredits.toStringAsFixed(2)}",
              style: CyberTheme.monospaceStyle(fontSize: 10, color: themeColor),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
            child: InkWell(
              onTap: () => _showRechargeDialog(context, state, themeColor),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.amber.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars_rounded, color: Colors.amber, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      "${state.rustyTokens.toStringAsFixed(0)} RT",
                      style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.amber).copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.add_circle_outline, color: Colors.amber, size: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: AI ASSETS
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
            child: GridView.builder(
              itemCount: state.marketplaceAssets.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 1 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isMobile ? 1.8 : 1.4,
              ),
              itemBuilder: (context, index) {
                final asset = state.marketplaceAssets[index];
                final bool isGratis = asset.tokenCost == 0.0;
                final bool alreadyOwned = asset.isAcquired || isGratis;

                return GlassContainer(
                  borderColor: themeColor.withOpacity(0.18),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: themeColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: themeColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              asset.category.toUpperCase(),
                              style: CyberTheme.monospaceStyle(fontSize: 8, color: themeColor),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                              const SizedBox(width: 2),
                              Text(
                                asset.rating,
                                style: CyberTheme.monospaceStyle(fontSize: 9, color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        asset.title,
                        style: CyberTheme.headingStyle(fontSize: 14, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "AUTHOR: ${asset.creator.toUpperCase()}",
                        style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (!isGratis) const Icon(Icons.stars_rounded, color: Colors.amber, size: 16),
                              if (!isGratis) const SizedBox(width: 4),
                              Text(
                                isGratis ? "GRATIS" : "${asset.tokenCost.toStringAsFixed(0)} RT",
                                style: CyberTheme.titleStyle(fontSize: 15, color: isGratis ? Colors.white : Colors.amber),
                              ),
                            ],
                          ),
                          NeonButton(
                            onPressed: () {
                              if (alreadyOwned) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.green.withOpacity(0.2),
                                    content: Text(
                                      "DOWNLOADING ${asset.title.toUpperCase()}...",
                                      style: CyberTheme.monospaceStyle(fontSize: 11, color: Colors.white),
                                    ),
                                  ),
                                );
                              } else {
                                final success = state.purchaseAsset(asset.title);
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.green.withOpacity(0.2),
                                      content: Text(
                                        "SUCCESS: PURCHASED & DOWNLOAD STARTED FOR ${asset.title.toUpperCase()}.",
                                        style: CyberTheme.monospaceStyle(fontSize: 11, color: Colors.white),
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.red.withOpacity(0.2),
                                      action: SnackBarAction(
                                        label: "RECHARGE",
                                        textColor: Colors.amber,
                                        onPressed: () => _showRechargeDialog(context, state, themeColor),
                                      ),
                                      content: Text(
                                        "TRANSACTION FAILED: INSUFFICIENT RUSTY TOKENS.",
                                        style: CyberTheme.monospaceStyle(fontSize: 11, color: Colors.white),
                                      ),
                                    ),
                                  );
                                  // Open recharge portal immediately
                                  _showRechargeDialog(context, state, themeColor);
                                }
                              }
                            },
                            glowColor: alreadyOwned ? const Color(0xFF00FF88) : themeColor,
                            gradientColors: alreadyOwned
                                ? [const Color(0xFF00FF88), const Color(0xFF00FF88).withOpacity(0.5)]
                                : [themeColor, themeColor.withBlue(210).withRed(40)],
                            borderRadius: 4,
                            child: Text(
                              alreadyOwned ? "DOWNLOAD" : "ACQUIRE",
                              style: CyberTheme.headingStyle(fontSize: 9, color: alreadyOwned ? Colors.black : Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // TAB 2: GAME STORE
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
            child: ListView.builder(
              itemCount: state.storeGames.length,
              itemBuilder: (context, index) {
                final game = state.storeGames[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: GlassContainer(
                    borderColor: themeColor.withOpacity(0.15),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Game Cover Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            game.imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 100,
                              height: 100,
                              color: Colors.white.withOpacity(0.05),
                              alignment: Alignment.center,
                              child: const Icon(Icons.broken_image, size: 24, color: Colors.white24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Game info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    game.title.toUpperCase(),
                                    style: CyberTheme.headingStyle(fontSize: 13, color: Colors.white),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: themeColor.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: themeColor.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      game.genre.toUpperCase(),
                                      style: CyberTheme.monospaceStyle(fontSize: 8, color: themeColor),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                game.description,
                                style: CyberTheme.bodyStyle(fontSize: 11, color: CyberTheme.textMuted),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    game.price == 0 ? "GRATIS" : "\$${game.price.toStringAsFixed(2)}",
                                    style: CyberTheme.titleStyle(fontSize: 14, color: Colors.white),
                                  ),
                                  if (!game.isPurchased)
                                    NeonButton(
                                      onPressed: () {
                                        final success = state.purchaseGame(game.title);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: success ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                            content: Text(
                                              success 
                                                  ? "SUCCESS: RETRIEVED LICENSE TO ${game.title.toUpperCase()}."
                                                  : "ERROR: INSUFFICIENT OPERATOR BALANCES.",
                                              style: CyberTheme.monospaceStyle(fontSize: 11, color: Colors.white),
                                            ),
                                          ),
                                        );
                                      },
                                      glowColor: themeColor,
                                      gradientColors: [themeColor, themeColor.withOpacity(0.5)],
                                      borderRadius: 4,
                                      child: Text("BUY LICENSE", style: CyberTheme.headingStyle(fontSize: 9, color: Colors.white)),
                                    )
                                  else
                                    NeonButton(
                                      onPressed: () {
                                        // Launch / compile game
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: themeColor.withOpacity(0.2),
                                            content: Text(
                                              "TRANSMITTING LAUNCH INSTRUCTION TO PROCEDURAL COMPILE ENGINE...",
                                              style: CyberTheme.monospaceStyle(fontSize: 11, color: Colors.white),
                                            ),
                                          ),
                                        );
                                        // Generate and open in render view
                                        state.generateGame(game.title);
                                        state.setScreenIndex(5); // Render View screen index
                                      },
                                      glowColor: const Color(0xFF00FF88),
                                      gradientColors: [const Color(0xFF00FF88), const Color(0xFF00FF88).withOpacity(0.5)],
                                      borderRadius: 4,
                                      child: Text("LAUNCH GAME", style: CyberTheme.headingStyle(fontSize: 9, color: Colors.black)),
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
          ),

          // TAB 3: GAME STOCKS
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Portfolio Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: GlassContainer(
                          borderColor: themeColor.withOpacity(0.2),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("PORTFOLIO VALUE", style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted)),
                              const SizedBox(height: 4),
                              Text("\$${state.getPortfolioValue().toStringAsFixed(2)}", style: CyberTheme.titleStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassContainer(
                          borderColor: themeColor.withOpacity(0.2),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("LIQUID CASH", style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted)),
                              const SizedBox(height: 4),
                              Text("\$${state.operatorCredits.toStringAsFixed(2)}", style: CyberTheme.titleStyle(fontSize: 16, color: themeColor)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Holdings Overview
                  GlassContainer(
                    borderColor: themeColor.withOpacity(0.1),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("ACTIVE ASSETS HOLDINGS", style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted)),
                        const SizedBox(height: 6),
                        state.ownedStocks.isEmpty
                            ? Text(
                                "NO ACTIVE SHARE HOLDINGS DETECTED IN PORTFOLIO",
                                style: CyberTheme.monospaceStyle(fontSize: 9, color: Colors.white30),
                              )
                            : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: state.ownedStocks.entries.map((entry) {
                                  final stock = state.stocksList.firstWhere((s) => s.symbol == entry.key);
                                  double currentHoldingsValue = stock.currentPrice * entry.value;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.03),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Colors.white10),
                                    ),
                                    child: Text(
                                      "${entry.key} x ${entry.value} (\$${currentHoldingsValue.toStringAsFixed(2)})",
                                      style: CyberTheme.monospaceStyle(fontSize: 9, color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stocks Ticker board
                  Text("STUDIO STOCK MARKET TICKERS", style: CyberTheme.headingStyle(fontSize: 11)),
                  const SizedBox(height: 8),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.stocksList.length,
                    itemBuilder: (context, index) {
                      final stock = state.stocksList[index];
                      final isPositive = stock.changePercent >= 0;
                      final trendColor = isPositive ? const Color(0xFF00FF88) : const Color(0xFFFF1E27);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: GlassContainer(
                          borderColor: themeColor.withOpacity(0.12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              // Ticker & Name
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          stock.symbol,
                                          style: CyberTheme.headingStyle(fontSize: 13, color: Colors.white),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "// ${stock.sector}",
                                          style: CyberTheme.monospaceStyle(fontSize: 7, color: CyberTheme.textMuted),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      stock.name,
                                      style: CyberTheme.bodyStyle(fontSize: 10, color: CyberTheme.textMuted),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),

                              // Sparkline history graph
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: GameSparkline(
                                    data: stock.priceHistory,
                                    isPositive: isPositive,
                                    width: 80,
                                    height: 28,
                                  ),
                                ),
                              ),

                              // Price & Change
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "\$${stock.currentPrice.toStringAsFixed(2)}",
                                      style: CyberTheme.titleStyle(fontSize: 13),
                                    ),
                                    Text(
                                      "${isPositive ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%",
                                      style: CyberTheme.monospaceStyle(
                                        fontSize: 9,
                                        color: trendColor,
                                      ).copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Trade btn
                              NeonButton(
                                onPressed: () => _showTradeDialog(context, stock, state, themeColor),
                                glowColor: themeColor,
                                gradientColors: [themeColor, themeColor.withOpacity(0.5)],
                                borderRadius: 4,
                                width: 76,
                                height: 30,
                                child: Text("TRADE", style: CyberTheme.headingStyle(fontSize: 8, color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Monospace ticker output console
                  Text("STUDIO NEWS & TRADING TICKER FEED", style: CyberTheme.headingStyle(fontSize: 10, color: CyberTheme.textMuted)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      border: Border.all(color: Colors.white10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    height: 100,
                    child: ListView.builder(
                      itemCount: state.stockMarketLogs.length,
                      reverse: true, // Show newest at the bottom
                      itemBuilder: (context, idx) {
                        final logText = state.stockMarketLogs[state.stockMarketLogs.length - 1 - idx];
                        Color logColor = CyberTheme.textMuted;
                        if (logText.contains("[TRADE]")) logColor = themeColor;
                        if (logText.contains("[STORE]")) logColor = const Color(0xFF00FF88);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            logText,
                            style: CyberTheme.monospaceStyle(fontSize: 9, color: logColor),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // TAB 4: DEALS WIRE (Steam & Epic 90% discount deals)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top header for deals
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("TODAY'S HOT DEALS WIRE (90% OFF)", style: CyberTheme.headingStyle(fontSize: 11)),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 16),
                      onPressed: () => state.fetchSteamAndEpicDeals(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (state.isFetchingDeals)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent)),
                    ),
                  )
                else if (state.dealsError.isNotEmpty && state.dealGames.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        "ERROR: ${state.dealsError}\nPLEASE VERIFY YOUR MATRIX CONNECTION.",
                        style: CyberTheme.monospaceStyle(fontSize: 9, color: const Color(0xFFFF1E27)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.dealGames.length,
                      itemBuilder: (context, index) {
                        final deal = state.dealGames[index];
                        final isSteam = deal.storeID == "1";
                        final savingsPercent = deal.savingsPercent.toInt();
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: GlassContainer(
                            borderColor: themeColor.withOpacity(0.15),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Thumbnail image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    deal.thumbnail,
                                    width: 120,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 120,
                                      height: 60,
                                      color: Colors.white.withOpacity(0.05),
                                      child: const Icon(Icons.broken_image, size: 16, color: Colors.white24),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Deal details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              deal.title.toUpperCase(),
                                              style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isSteam ? Colors.blue.withOpacity(0.08) : Colors.amber.withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(
                                                color: isSteam ? Colors.blueAccent : Colors.amberAccent,
                                                width: 0.5,
                                              ),
                                            ),
                                            child: Text(
                                              isSteam ? "STEAM" : "EPIC GAMES",
                                              style: CyberTheme.monospaceStyle(
                                                fontSize: 7,
                                                color: isSteam ? Colors.blueAccent : Colors.amberAccent,
                                              ).copyWith(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              // Sale Price
                                              Text(
                                                "\$${deal.salePrice.toStringAsFixed(2)}",
                                                style: CyberTheme.titleStyle(fontSize: 14, color: Colors.white),
                                              ),
                                              const SizedBox(width: 8),
                                              // Original Price Strikethrough
                                              Text(
                                                "\$${deal.normalPrice.toStringAsFixed(2)}",
                                                style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.white30).copyWith(
                                                  decoration: TextDecoration.lineThrough,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              // Savings neon tag
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFF1E27).withOpacity(0.15),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  "-$savingsPercent%",
                                                  style: CyberTheme.monospaceStyle(fontSize: 8, color: const Color(0xFFFF1E27)).copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          NeonButton(
                                            onPressed: () async {
                                              final url = Uri.parse("https://www.cheapshark.com/redirect?dealID=${deal.dealID}");
                                              if (await canLaunchUrl(url)) {
                                                await launchUrl(url, mode: LaunchMode.externalApplication);
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    backgroundColor: const Color(0xFFFF1E27).withOpacity(0.2),
                                                    content: Text(
                                                      "COULD NOT RESOLVE CHEAPSHARK REDIRECT ROUTE.",
                                                      style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.white),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            glowColor: const Color(0xFFFF1E27),
                                            gradientColors: [const Color(0xFFFF1E27), const Color(0xFFFF1E27).withOpacity(0.5)],
                                            borderRadius: 4,
                                            width: 76,
                                            height: 30,
                                            child: Text("CLAIM DEAL", style: CyberTheme.headingStyle(fontSize: 8, color: Colors.white)),
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
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Stateful Dialog to handle simulated Razorpay Recharge portal
class RechargePortalDialog extends StatefulWidget {
  final EngineState state;
  final Color themeColor;

  const RechargePortalDialog({
    super.key,
    required this.state,
    required this.themeColor,
  });

  @override
  State<RechargePortalDialog> createState() => _RechargePortalDialogState();
}

class _RechargePortalDialogState extends State<RechargePortalDialog> {
  int currentStep = 0; // 0: Selection & Region, 1: Razorpay Methods, 2: Loading, 3: Simulated OTP, 4: Receipt
  int selectedTier = 1000; // default to 1000 RT package

  String selectedMethod = "upi"; // "card", "upi", "netbank"
  
  final _cardNumberController = TextEditingController(text: "4321 6789 2345 4242");
  final _cardExpiryController = TextEditingController(text: "12/29");
  final _cardCvvController = TextEditingController(text: "888");
  final _cardNameController = TextEditingController(text: "OPERATOR ANTIMATTER");
  
  final _upiIdController = TextEditingController(text: "operator@upi");
  final _otpController = TextEditingController();
  String _otpError = "";

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _cardNameController.dispose();
    _upiIdController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  double _getUsdPrice(int tokens) {
    return tokens / 100.0;
  }

  @override
  Widget build(BuildContext context) {
    final double usdPrice = _getUsdPrice(selectedTier);
    final String formattedPrice = widget.state.formatRegionalPrice(usdPrice);
    final String currencyCode = widget.state.selectedRegion.currency;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        child: GlassContainer(
          borderColor: widget.themeColor.withOpacity(0.3),
          padding: const EdgeInsets.all(0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(formattedPrice),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _buildStepBody(formattedPrice, currencyCode),
                ),
              ),
              _buildFooter(formattedPrice),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String formattedPrice) {
    if (currentStep >= 1 && currentStep <= 3) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF0F2537), // Razorpay brand slate blue
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0052FF),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.payment_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "DREAMENGINE AI STORE",
                  style: CyberTheme.headingStyle(fontSize: 11, color: Colors.white),
                ),
                Text(
                  "Razorpay Secure Checkout",
                  style: CyberTheme.monospaceStyle(fontSize: 7, color: Colors.blueAccent),
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formattedPrice,
                  style: CyberTheme.titleStyle(fontSize: 13, color: Colors.white),
                ),
                Text(
                  widget.state.operatorEmail.toLowerCase(),
                  style: CyberTheme.monospaceStyle(fontSize: 7, color: CyberTheme.textMuted),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.themeColor.withOpacity(0.05),
        border: Border(bottom: BorderSide(color: widget.themeColor.withOpacity(0.2))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.stars_rounded, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                "TOKEN RECHARGE SYSTEMS",
                style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white54, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStepBody(String formattedPrice, String currencyCode) {
    switch (currentStep) {
      case 0:
        return _buildSelectionStep();
      case 1:
        return _buildRazorpayCheckoutStep(formattedPrice, currencyCode);
      case 2:
        return _buildProcessingStep();
      case 3:
        return _buildOtpVerificationStep(formattedPrice);
      case 4:
        return _buildSuccessStep(formattedPrice, currencyCode);
      default:
        return const SizedBox();
    }
  }

  Widget _buildSelectionStep() {
    final tiers = [500, 1000, 2000, 5000];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "BILLING REGION MATRIX DETECTED",
          style: CyberTheme.monospaceStyle(fontSize: 8, color: widget.themeColor),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<RegionalMarket>(
          dropdownColor: const Color(0xFF0C0C0F),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: Colors.black.withOpacity(0.3),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: widget.themeColor.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: widget.themeColor),
            ),
          ),
          value: widget.state.selectedRegion,
          items: widget.state.regionalMarkets.map((m) {
            return DropdownMenuItem<RegionalMarket>(
              value: m,
              child: Text(
                "${m.regionName.toUpperCase()} (${m.currency})",
                style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                widget.state.setSelectedRegion(val);
              });
            }
          },
        ),
        const SizedBox(height: 16),
        Text(
          "SELECT TOKEN TIER",
          style: CyberTheme.monospaceStyle(fontSize: 8, color: widget.themeColor),
        ),
        const SizedBox(height: 8),
        Column(
          children: tiers.map((tier) {
            final isSel = selectedTier == tier;
            final usd = _getUsdPrice(tier);
            final localFmt = widget.state.formatRegionalPrice(usd);
            
            return InkWell(
              onTap: () {
                setState(() {
                  selectedTier = tier;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSel ? Colors.amber.withOpacity(0.06) : Colors.white.withOpacity(0.01),
                  border: Border.all(
                    color: isSel ? Colors.amber : Colors.white10,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.stars_rounded,
                          color: isSel ? Colors.amber : Colors.white54,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${tier.toString()} RT",
                          style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white),
                        ),
                      ],
                    ),
                    Text(
                      localFmt,
                      style: CyberTheme.titleStyle(fontSize: 12, color: isSel ? Colors.amber : Colors.white70),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white30, size: 14),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Exchange rates dynamically adapt to PPP indices to equalize developer options globally.",
                  style: CyberTheme.bodyStyle(fontSize: 9, color: CyberTheme.textMuted),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRazorpayCheckoutStep(String formattedPrice, String currencyCode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _buildMethodTab("upi", Icons.qr_code_2_rounded, "UPI / GPay"),
            const SizedBox(width: 8),
            _buildMethodTab("card", Icons.credit_card_rounded, "CARD"),
            const SizedBox(width: 8),
            _buildMethodTab("netbank", Icons.account_balance_rounded, "BANK TRANSFER"),
          ],
        ),
        const SizedBox(height: 16),
        
        if (selectedMethod == "card") ...[
          _buildTextField("CREDIT CARD NUMBER", _cardNumberController, placeholder: "4321 6789 2345 4242"),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTextField("EXPIRY DATE", _cardExpiryController, placeholder: "MM/YY"),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField("CVV", _cardCvvController, placeholder: "888"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildTextField("CARDHOLDER FULL NAME", _cardNameController, placeholder: "OPERATOR ANTIMATTER"),
        ] else if (selectedMethod == "upi") ...[
          Text(
            "SELECT UPI PLATFORM ROUTER",
            style: CyberTheme.monospaceStyle(fontSize: 8, color: widget.themeColor),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildUpiAppButton("Google Pay", Icons.g_mobiledata),
              const SizedBox(width: 8),
              _buildUpiAppButton("PhonePe", Icons.stars_rounded),
              const SizedBox(width: 8),
              _buildUpiAppButton("Paytm Wallet", Icons.wallet_rounded),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField("OR SPECIFY VIRTUAL PAYMENT ADDRESS (UPI ID)", _upiIdController, placeholder: "operator@upi"),
        ] else ...[
          Text(
            "CHOOSE BANK GATEWAY FOR ROUTING NETBANKING TRANSACTION",
            style: CyberTheme.monospaceStyle(fontSize: 8, color: widget.themeColor),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBankChip("HDFC Bank"),
              _buildBankChip("ICICI Bank"),
              _buildBankChip("State Bank of India"),
              _buildBankChip("Axis Bank"),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "We will securely redirect you to your bank's secure validation node to authorize this transfer.",
            style: CyberTheme.bodyStyle(fontSize: 10, color: CyberTheme.textMuted),
          ),
        ],
        
        const SizedBox(height: 20),
        Row(
          children: [
            const Icon(Icons.shield_rounded, color: Colors.blueAccent, size: 14),
            const SizedBox(width: 6),
            Text(
              "Razorpay Secure Checkout. Encrypted 256-bit SSL Tunnel.",
              style: CyberTheme.monospaceStyle(fontSize: 8, color: Colors.blueAccent),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMethodTab(String method, IconData icon, String label) {
    final isSel = selectedMethod == method;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedMethod = method;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSel ? const Color(0xFF0052FF).withOpacity(0.08) : Colors.transparent,
            border: Border.all(
              color: isSel ? const Color(0xFF0052FF) : Colors.white10,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSel ? Colors.white : CyberTheme.textMuted, size: 16),
              const SizedBox(height: 4),
              Text(
                label,
                style: CyberTheme.monospaceStyle(fontSize: 7, color: isSel ? Colors.white : CyberTheme.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpiAppButton(String name, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          border: Border.all(color: Colors.white10),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(height: 4),
            Text(
              name.toUpperCase(),
              style: CyberTheme.monospaceStyle(fontSize: 7, color: CyberTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankChip(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        name.toUpperCase(),
        style: CyberTheme.monospaceStyle(fontSize: 8, color: Colors.white70),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {required String placeholder}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: CyberTheme.monospaceStyle(fontSize: 7, color: CyberTheme.textMuted),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: CyberTheme.monospaceStyle(fontSize: 11, color: Colors.white),
          decoration: InputDecoration(
            isDense: true,
            hintText: placeholder,
            hintStyle: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.white30),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            filled: true,
            fillColor: Colors.black.withOpacity(0.3),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF0052FF)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingStep() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0052FF)),
            strokeWidth: 2,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "SECURE ROUTING PROCESSING",
          style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          "Contacting payment servers via encrypted Razorpay proxy... Do not close this panel.",
          style: CyberTheme.monospaceStyle(fontSize: 9, color: CyberTheme.textMuted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildOtpVerificationStep(String formattedPrice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "SECURE BANK OTP VERIFICATION",
          style: CyberTheme.headingStyle(fontSize: 11, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          "A secure 6-digit passcode has been transmitted via SMS to authorize the debit of $formattedPrice by DreamEngine AI Store.",
          style: CyberTheme.bodyStyle(fontSize: 10, color: CyberTheme.textMuted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: CyberTheme.titleStyle(fontSize: 18, color: Colors.white),
          decoration: InputDecoration(
            counterText: "",
            hintText: "••••••",
            hintStyle: CyberTheme.titleStyle(fontSize: 18, color: Colors.white24),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            filled: true,
            fillColor: Colors.black.withOpacity(0.3),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: widget.themeColor.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: widget.themeColor),
            ),
          ),
        ),
        if (_otpError.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            _otpError,
            style: CyberTheme.monospaceStyle(fontSize: 9, color: Colors.redAccent),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.themeColor.withOpacity(0.04),
            border: Border.all(color: widget.themeColor.withOpacity(0.15)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            "GATEWAY SIMULATOR ACTIVE: Input secure passcode '123456' to approve.",
            style: CyberTheme.monospaceStyle(fontSize: 8, color: Colors.amber),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessStep(String formattedPrice, String currencyCode) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF00FF88).withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.3), width: 2),
          ),
          child: const Icon(
            Icons.check_circle_outline_rounded,
            color: Color(0xFF00FF88),
            size: 44,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "TRANSACTION AUTHENTICATED & APPROVED",
          style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          "Razorpay Payment ID: PAY_RZP_${Random().nextInt(900000) + 100000}",
          style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              _buildReceiptRow("CREDIT AMOUNT:", "${selectedTier.toString()} RT"),
              const SizedBox(height: 8),
              _buildReceiptRow("BILLING LOCATION:", widget.state.selectedRegion.regionName.toUpperCase()),
              const SizedBox(height: 8),
              _buildReceiptRow("CHARGED AMOUNT:", "$formattedPrice $currencyCode"),
              const SizedBox(height: 8),
              _buildReceiptRow("INTEGRATED GATEWAY:", "RAZORPAY SIMULATED GATEWAY"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted)),
        Text(val, style: CyberTheme.monospaceStyle(fontSize: 9, color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFooter(String formattedPrice) {
    if (currentStep == 2) return const SizedBox();
    
    String actionLabel = "PROCEED";
    VoidCallback? actionCall;

    if (currentStep == 0) {
      actionLabel = "CHECKOUT VIA RAZORPAY";
      actionCall = () {
        setState(() {
          currentStep = 1;
        });
      };
    } else if (currentStep == 1) {
      actionLabel = "PAY $formattedPrice";
      actionCall = () {
        setState(() {
          currentStep = 2;
        });
        Timer(const Duration(milliseconds: 2200), () {
          if (mounted) {
            setState(() {
              currentStep = 3;
            });
          }
        });
      };
    } else if (currentStep == 3) {
      actionLabel = "CONFIRM CODE";
      actionCall = () {
        final code = _otpController.text.trim();
        if (code == "123456") {
          setState(() {
            _otpError = "";
            currentStep = 4;
          });
        } else {
          setState(() {
            _otpError = "SECURE PASSCODE ERROR. VERIFICATION FAILED.";
          });
        }
      };
    } else if (currentStep == 4) {
      actionLabel = "ACQUIRE TOKENS";
      actionCall = () {
        widget.state.rechargeRustyTokens(selectedTier.toDouble());
        Navigator.pop(context);
      };
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        border: Border(top: BorderSide(color: widget.themeColor.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (currentStep > 0 && currentStep < 4) 
            OutlinedButton(
              onPressed: () {
                setState(() {
                  currentStep = currentStep - 1;
                  if (currentStep == 2) currentStep = 1;
                });
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: widget.themeColor.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Text(
                "BACK", 
                style: CyberTheme.monospaceStyle(fontSize: 10, color: widget.themeColor),
              ),
            )
          else if (currentStep == 0)
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white30),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Text(
                "ABORT", 
                style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.white54),
              ),
            )
          else
            const SizedBox(),
          
          NeonButton(
            onPressed: actionCall ?? () {},
            glowColor: currentStep == 4 ? const Color(0xFF00FF88) : (currentStep == 1 ? const Color(0xFF0052FF) : widget.themeColor),
            gradientColors: currentStep == 4
                ? [const Color(0xFF00FF88), const Color(0xFF00FF88).withOpacity(0.5)]
                : (currentStep == 1
                    ? [const Color(0xFF0052FF), const Color(0xFF0052FF).withOpacity(0.6)]
                    : [widget.themeColor, widget.themeColor.withOpacity(0.5)]),
            borderRadius: 4,
            child: Text(
              actionLabel,
              style: CyberTheme.headingStyle(fontSize: 10, color: currentStep == 4 ? Colors.black : Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
