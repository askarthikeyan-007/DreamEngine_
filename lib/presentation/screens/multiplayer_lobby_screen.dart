import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dream_engine_ai/core/state/engine_state.dart';
import 'package:dream_engine_ai/core/theme/cyber_theme.dart';
import 'package:dream_engine_ai/core/widgets/glass_container.dart';
import 'package:dream_engine_ai/core/widgets/neon_button.dart';

class MultiplayerLobbyScreen extends StatelessWidget {
  const MultiplayerLobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<EngineState>(context);
    final themeColor = _getThemeColor(state);

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    final Widget leftCard = GlassContainer(
      borderColor: themeColor.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ACTIVE PLAYERS (${state.lobbyPlayers.length} / 8)",
                style: CyberTheme.headingStyle(fontSize: 13, color: Colors.white),
              ),
              if (state.lobbyPlayers.isNotEmpty)
                Text(
                  "PING: ${state.lobbyPing}ms // SECTOR: US-EAST",
                  style: CyberTheme.monospaceStyle(fontSize: 9, color: themeColor),
                ),
            ],
          ),
          const SizedBox(height: 16),
          isMobile
              ? (state.lobbyPlayers.isEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "CONNECTED OPERATORS (EMAIL DIRECTORY)",
                          style: CyberTheme.monospaceStyle(fontSize: 10, color: themeColor),
                        ),
                        const SizedBox(height: 12),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.activeOperators.length,
                          itemBuilder: (context, idx) {
                            final op = state.activeOperators[idx];
                            final isAway = op["status"] == "AWAY";
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.02),
                                border: Border.all(color: Colors.white10),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: themeColor.withOpacity(0.1),
                                    child: Icon(
                                      idx == 0
                                          ? Icons.blur_on_rounded
                                          : idx == 1
                                              ? Icons.face_retouching_natural_rounded
                                              : idx == 2
                                                  ? Icons.precision_manufacturing_rounded
                                                  : Icons.person_pin_rounded,
                                      color: themeColor,
                                      size: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          op["name"]!.toUpperCase(),
                                          style: CyberTheme.headingStyle(fontSize: 11, color: Colors.white),
                                        ),
                                        Text(
                                          op["email"]!,
                                          style: CyberTheme.monospaceStyle(fontSize: 9, color: CyberTheme.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (isAway ? Colors.orangeAccent : Colors.greenAccent).withOpacity(0.08),
                                      border: Border.all(color: (isAway ? Colors.orangeAccent : Colors.greenAccent).withOpacity(0.3)),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      op["status"]!,
                                      style: CyberTheme.monospaceStyle(
                                        fontSize: 8,
                                        color: isAway ? Colors.orangeAccent : Colors.greenAccent,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    op["ping"]!,
                                    style: CyberTheme.monospaceStyle(fontSize: 9, color: themeColor),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.lobbyPlayers.length,
                      itemBuilder: (context, index) {
                        final name = state.lobbyPlayers[index];
                        final isHost = index == 0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.02),
                            border: Border.all(color: isHost ? themeColor.withOpacity(0.4) : Colors.white10),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isHost ? Icons.military_tech_rounded : Icons.sports_esports_rounded,
                                    color: isHost ? themeColor : CyberTheme.textMuted,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    name,
                                    style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white),
                                  ),
                                ],
                              ),
                              Text(
                                isHost ? "LOBBY HOST" : "READY",
                                style: CyberTheme.monospaceStyle(
                                  fontSize: 9,
                                  color: isHost ? themeColor : Colors.greenAccent,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ))
              : Expanded(
                  child: state.lobbyPlayers.isEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "CONNECTED OPERATORS (EMAIL DIRECTORY)",
                              style: CyberTheme.monospaceStyle(fontSize: 10, color: themeColor),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: ListView.builder(
                                itemCount: state.activeOperators.length,
                                itemBuilder: (context, idx) {
                                  final op = state.activeOperators[idx];
                                  final isAway = op["status"] == "AWAY";
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.02),
                                      border: Border.all(color: Colors.white10),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 14,
                                          backgroundColor: themeColor.withOpacity(0.1),
                                          child: Icon(
                                            idx == 0
                                                ? Icons.blur_on_rounded
                                                : idx == 1
                                                    ? Icons.face_retouching_natural_rounded
                                                    : idx == 2
                                                        ? Icons.precision_manufacturing_rounded
                                                        : Icons.person_pin_rounded,
                                            color: themeColor,
                                            size: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                op["name"]!.toUpperCase(),
                                                style: CyberTheme.headingStyle(fontSize: 11, color: Colors.white),
                                              ),
                                              Text(
                                                op["email"]!,
                                                style: CyberTheme.monospaceStyle(fontSize: 9, color: CyberTheme.textMuted),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: (isAway ? Colors.orangeAccent : Colors.greenAccent).withOpacity(0.08),
                                            border: Border.all(color: (isAway ? Colors.orangeAccent : Colors.greenAccent).withOpacity(0.3)),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            op["status"]!,
                                            style: CyberTheme.monospaceStyle(
                                              fontSize: 8,
                                              color: isAway ? Colors.orangeAccent : Colors.greenAccent,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          op["ping"]!,
                                          style: CyberTheme.monospaceStyle(fontSize: 9, color: themeColor),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          itemCount: state.lobbyPlayers.length,
                          itemBuilder: (context, index) {
                            final name = state.lobbyPlayers[index];
                            final isHost = index == 0;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.02),
                                border: Border.all(color: isHost ? themeColor.withOpacity(0.4) : Colors.white10),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        isHost ? Icons.military_tech_rounded : Icons.sports_esports_rounded,
                                        color: isHost ? themeColor : CyberTheme.textMuted,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        name,
                                        style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    isHost ? "LOBBY HOST" : "READY",
                                    style: CyberTheme.monospaceStyle(
                                      fontSize: 9,
                                      color: isHost ? themeColor : Colors.greenAccent,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
        ],
      ),
    );

    final Widget rightCard = GlassContainer(
      borderColor: themeColor.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("CONNECTION HUB", style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white)),
          const SizedBox(height: 16),

          // Search progress loaders
          if (state.isSearchingLobby)
            Column(
              children: [
                const SizedBox(height: 32),
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    value: state.matchmakingProgress,
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "COMPILING NODES...",
                  style: CyberTheme.monospaceStyle(fontSize: 11, color: themeColor),
                ),
                const SizedBox(height: 4),
                Text(
                  "${(state.matchmakingProgress * 100).toInt()}%",
                  style: CyberTheme.monospaceStyle(fontSize: 9, color: CyberTheme.textMuted),
                ),
              ],
            )
          else if (state.lobbyPlayers.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _buildServerParam("CONNECTED PORT", "30482"),
                _buildServerParam("PROTOCOL STATE", "STABLE"),
                _buildServerParam("ENCRYPTION", "AES-256-GCM"),
                _buildServerParam("TICK RATE", "128 Hz"),
                const SizedBox(height: 32),
              ],
            )
          else
            Column(
              children: [
                const SizedBox(height: 40),
                Icon(Icons.wifi_tethering_rounded, color: themeColor.withOpacity(0.3), size: 48),
                const SizedBox(height: 12),
                Text(
                  "NO ACTIVE DEPLOYMENT",
                  style: CyberTheme.monospaceStyle(fontSize: 11, color: CyberTheme.textMuted),
                ),
                const SizedBox(height: 40),
              ],
            ),

          if (!isMobile) const Spacer(),
          if (isMobile) const SizedBox(height: 24),

          // Control Button
          if (state.isSearchingLobby)
            NeonButton(
              onPressed: () => state.cancelMatchmaking(),
              glowColor: CyberTheme.cyberPink,
              gradientColors: [CyberTheme.cyberPink, Colors.redAccent],
              child: Text(
                "CANCEL PROTOCOL",
                style: CyberTheme.headingStyle(fontSize: 11, color: Colors.white),
              ),
            )
          else if (state.lobbyPlayers.isEmpty)
            NeonButton(
              onPressed: () => state.startMatchmaking(),
              glowColor: themeColor,
              gradientColors: [themeColor, themeColor.withBlue(210).withRed(40)],
              child: Text(
                "SEARCH SERVERS",
                style: CyberTheme.headingStyle(fontSize: 11, color: Colors.white),
              ),
            )
          else
            NeonButton(
              onPressed: () => state.cancelMatchmaking(),
              glowColor: CyberTheme.cyberPink,
              gradientColors: [CyberTheme.cyberPink, Colors.redAccent],
              child: Text(
                "DISCONNECT HOST",
                style: CyberTheme.headingStyle(fontSize: 11, color: Colors.white),
              ),
            ),
        ],
      ),
    );

    final Widget lobbyBody = isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              rightCard,
              const SizedBox(height: 20),
              leftCard,
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 6,
                child: leftCard,
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 4,
                child: rightCard,
              ),
            ],
          );

    return isMobile
        ? SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("MULTIPLAYER MATCHMAKING", style: CyberTheme.titleStyle(fontSize: 18)),
                    Text(
                      "SERVER CLOUD DEPLOYMENT GATEWAY",
                      style: CyberTheme.monospaceStyle(fontSize: 8, color: themeColor),
                    ),
                    if (state.lobbyPlayers.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withOpacity(0.1),
                          border: Border.all(color: Colors.greenAccent),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "LOBBY CONNECTED",
                          style: CyberTheme.monospaceStyle(fontSize: 9, color: Colors.greenAccent),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                lobbyBody,
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
                        Text("MULTIPLAYER MATCHMAKING HUB", style: CyberTheme.titleStyle(fontSize: 22)),
                        Text(
                          "SERVER CLOUD DEPLOYMENT GATEWAY",
                          style: CyberTheme.monospaceStyle(fontSize: 10, color: themeColor),
                        ),
                      ],
                    ),
                    if (state.lobbyPlayers.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withOpacity(0.1),
                          border: Border.all(color: Colors.greenAccent),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "LOBBY CONNECTED",
                          style: CyberTheme.monospaceStyle(fontSize: 9, color: Colors.greenAccent),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(child: lobbyBody),
              ],
            ),
          );
  }

  Widget _buildServerParam(String key, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: CyberTheme.monospaceStyle(fontSize: 10, color: CyberTheme.textMuted)),
          Text(val, style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.white)),
        ],
      ),
    );
  }

  Color _getThemeColor(EngineState state) {
    if (state.currentTheme == AppTheme.ironMan) return Colors.amber;
    if (state.currentTheme == AppTheme.nvidiaGreen) return Colors.lightGreenAccent;
    if (state.currentTheme == AppTheme.appleVision) return Colors.white;
    return CyberTheme.neonBlue;
  }
}
