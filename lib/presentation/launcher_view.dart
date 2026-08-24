import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dream_engine_ai/core/state/engine_state.dart';
import 'package:dream_engine_ai/core/theme/cyber_theme.dart';
import 'package:dream_engine_ai/core/widgets/glass_container.dart';
import 'package:dream_engine_ai/presentation/screens/splash_screen.dart';
import 'package:dream_engine_ai/presentation/screens/onboarding_screen.dart';
import 'package:dream_engine_ai/presentation/screens/login_screen.dart';
import 'package:dream_engine_ai/presentation/screens/dashboard_screen.dart';
import 'package:dream_engine_ai/presentation/screens/prompt_screen.dart';
import 'package:dream_engine_ai/presentation/screens/realtime_render_view.dart';
import 'package:dream_engine_ai/presentation/screens/game_preview_screen.dart';
import 'package:dream_engine_ai/presentation/screens/multiplayer_lobby_screen.dart';
import 'package:dream_engine_ai/presentation/screens/marketplace_screen.dart';
import 'package:dream_engine_ai/presentation/screens/analytics_screen.dart';
import 'package:dream_engine_ai/presentation/screens/settings_screen.dart';
import 'package:dream_engine_ai/presentation/screens/profile_screen.dart';
import 'package:dream_engine_ai/presentation/screens/dev_gram_screen.dart';
import 'package:dream_engine_ai/presentation/screens/game_news_screen.dart';
import 'package:dream_engine_ai/presentation/screens/dev_chat_screen.dart';
import 'package:dream_engine_ai/presentation/screens/user_profile_screen.dart';
import 'package:dream_engine_ai/presentation/screens/game_price_predictor_screen.dart';

class _LauncherViewData {
  final int index;
  final AppTheme theme;

  _LauncherViewData(this.index, this.theme);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _LauncherViewData &&
          runtimeType == other.runtimeType &&
          index == other.index &&
          theme == other.theme;

  @override
  int get hashCode => Object.hash(index, theme);
}

class LauncherView extends StatelessWidget {
  const LauncherView({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<EngineState, _LauncherViewData>(
      selector: (context, state) => _LauncherViewData(state.currentScreenIndex, state.currentTheme),
      builder: (context, data, _) {
        final int index = data.index;
        final AppTheme currentTheme = data.theme;

        // Map screen indices to widgets
        final List<Widget> screens = [
          const SplashScreen(),            // 0
          const OnboardingScreen(),        // 1
          const LoginScreen(),            // 2
          const DashboardScreen(),        // 3
          const PromptScreen(),           // 4
          const RealtimeRenderView(),     // 5
          const GamePreviewScreen(),      // 6
          const MultiplayerLobbyScreen(), // 7
          const MarketplaceScreen(),      // 8
          const AnalyticsScreen(),        // 9
          const SettingsScreen(),         // 10
          const ProfileScreen(),          // 11
          const DevGramScreen(),          // 12
          const GameNewsScreen(),         // 13
          const DevChatScreen(),          // 14
          const UserProfileScreen(),      // 15
          const GamePricePredictorScreen(), // 16
        ];

        // Update global static theme flag
        CyberTheme.isLight = (currentTheme == AppTheme.appleVision);

        // Determine target theme glow color
        Color glowColor = CyberTheme.neonBlue;

        final showNavbar = index >= 3;
        final isLight = CyberTheme.isLight;
        final bgColor = isLight ? const Color(0xFFF1F5F9) : const Color(0xFF020204);

        return Scaffold(
          backgroundColor: bgColor,
          body: Container(
            color: bgColor,
            child: SafeArea(
              child: Stack(
                children: [
                  // Page view or Animated switcher for screens
                  Positioned.fill(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          ),
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.05),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey<int>(index),
                        child: screens[index],
                      ),
                    ),
                  ),

                  // Floating Navigation Bar (Only for Dashboard onwards)
                  if (showNavbar)
                    Positioned(
                      bottom: 24,
                      left: 24,
                      right: 24,
                      child: Center(
                        child: Hero(
                          tag: 'launcher_navbar',
                          child: Material(
                            type: MaterialType.transparency,
                            child: GlassContainer(
                              borderRadius: 30,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              borderColor: glowColor.withOpacity(0.3),
                              hasGlow: true,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildNavItem(context, index, 3, Icons.dashboard_rounded, "Dashboard", glowColor),
                                    _buildNavItem(context, index, 4, Icons.terminal_rounded, "Prompt", glowColor),
                                    _buildNavItem(context, index, 5, Icons.videogame_asset_rounded, "Render", glowColor),
                                    _buildNavItem(context, index, 6, Icons.visibility_rounded, "Preview", glowColor),
                                    _buildNavItem(context, index, 7, Icons.people_rounded, "Multiplayer", glowColor),
                                    _buildNavItem(context, index, 8, Icons.shopping_bag_rounded, "Marketplace", glowColor),
                                    _buildNavItem(context, index, 9, Icons.bar_chart_rounded, "Analytics", glowColor),
                                    _buildNavItem(context, index, 10, Icons.settings_rounded, "Settings", glowColor),
                                    _buildNavItem(context, index, 11, Icons.person_rounded, "Profile", glowColor),
                                    _buildNavItem(context, index, 12, Icons.photo_library_rounded, "DevGram", glowColor),
                                    _buildNavItem(context, index, 13, Icons.newspaper_rounded, "News", glowColor),
                                    _buildNavItem(context, index, 16, Icons.calendar_month_rounded, "Calendar", glowColor),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(BuildContext context, int activeIndex, int itemIndex, IconData icon, String label, Color glowColor) {
    final state = Provider.of<EngineState>(context, listen: false);
    final isSelected = activeIndex == itemIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Tooltip(
        message: label,
        textStyle: CyberTheme.bodyStyle(fontSize: 12, color: Colors.black),
        decoration: BoxDecoration(
          color: glowColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: InkWell(
          onTap: () => state.setScreenIndex(itemIndex),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isSelected ? glowColor.withOpacity(0.15) : Colors.transparent,
              border: Border.all(
                color: isSelected ? glowColor.withOpacity(0.4) : Colors.transparent,
                width: 1.0,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? glowColor : CyberTheme.textMuted,
                  size: 22,
                ),
                const SizedBox(height: 2),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isSelected ? 4 : 0,
                  height: 4,
                  decoration: BoxDecoration(
                    color: glowColor,
                    shape: BoxShape.circle,
                    boxShadow: isSelected ? CyberTheme.neonGlow(color: glowColor) : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
