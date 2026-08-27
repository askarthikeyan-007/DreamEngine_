import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dream_engine_ai/core/state/engine_state.dart';
import 'package:dream_engine_ai/core/theme/cyber_theme.dart';
import 'package:dream_engine_ai/core/widgets/glass_container.dart';
import 'package:dream_engine_ai/core/widgets/neon_button.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isConnected = true;

  Color _getThemeColor(EngineState state) {
    if (state.currentTheme == AppTheme.ironMan) return Colors.amber;
    if (state.currentTheme == AppTheme.nvidiaGreen) return Colors.lightGreenAccent;
    if (state.currentTheme == AppTheme.appleVision) return Colors.white;
    return CyberTheme.neonBlue;
  }

  void _showPostDialog(BuildContext context, Map<String, dynamic> post, Color themeColor) {
    final avatarIcons = [
      Icons.blur_on_rounded,
      Icons.face_retouching_natural_rounded,
      Icons.precision_manufacturing_rounded,
      Icons.person_pin_rounded,
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            child: GlassContainer(
              borderColor: themeColor.withOpacity(0.3),
              padding: const EdgeInsets.all(0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: themeColor.withOpacity(0.12),
                            child: Icon(avatarIcons[post["avatarIndex"] % avatarIcons.length], color: themeColor, size: 14),
                          ),
                          const SizedBox(width: 8),
                          Text(post["authorName"] ?? "UNKNOWN", style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.white)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.clear_rounded, color: Colors.white54, size: 16),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                    ),

                    // Media
                    if (post["imageUrl"] != null && post["imageUrl"].toString().isNotEmpty)
                      Image.network(
                        post["imageUrl"],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          color: Colors.white.withOpacity(0.05),
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image, color: Colors.white24, size: 32),
                        ),
                      ),

                    // Caption
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post["caption"] ?? "",
                            style: CyberTheme.bodyStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            post["timestamp"]?.toString().split('T')[0] ?? "",
                            style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<EngineState>(context);
    final themeColor = _getThemeColor(state);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    final profile = state.exploredUserProfile;
    if (profile == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Text(
            "ERROR: NO COGNITIVE DOSSIER ACTIVE FOR DISPLAY",
            style: CyberTheme.monospaceStyle(fontSize: 11, color: Colors.redAccent),
          ),
        ),
      );
    }

    final String name = profile["name"] ?? "UNKNOWN";
    final String email = profile["email"] ?? "";
    final String role = profile["role"] ?? "OPERATOR";
    final String status = profile["status"] ?? "OFFLINE";
    final int avatarIdx = int.tryParse(profile["avatar"] ?? "0") ?? 0;
    final isOnline = status.toUpperCase() == "ONLINE";
    final realAvatarIcons = [
      Icons.blur_on_rounded,
      Icons.face_retouching_natural_rounded,
      Icons.precision_manufacturing_rounded,
      Icons.person_pin_rounded,
    ];

    // Filter posts for this specific user
    final operatorPosts = state.devgramPosts.where((post) {
      final postEmail = post["authorEmail"]?.toString().toLowerCase().trim() ?? "";
      return postEmail == email.toLowerCase().trim();
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text("OPERATOR DOSSIER INDEX", style: CyberTheme.headingStyle(fontSize: 13)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 16),
          onPressed: () {
            // Navigate back to DevGram screen (Index 12)
            state.setScreenIndex(12);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Glassmorphic User Profile HUD Header Card
            GlassContainer(
              borderColor: themeColor.withOpacity(0.2),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                    children: [
                      // Profile Avatar Icon
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: isOnline ? const Color(0xFF00FF88) : themeColor.withOpacity(0.4), width: 2),
                              color: themeColor.withOpacity(0.06),
                            ),
                            child: Icon(
                              realAvatarIcons[avatarIdx % realAvatarIcons.length],
                              color: isOnline ? Colors.white : themeColor,
                              size: 34,
                            ),
                          ),
                          Positioned(
                            bottom: 1,
                            right: 1,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isOnline ? const Color(0xFF00FF88) : Colors.amber,
                                border: Border.all(color: const Color(0xFF020204), width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),

                      // User Identity
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: CyberTheme.titleStyle(fontSize: 18),
                            ),
                            Text(
                              "ROLE: $role",
                              style: CyberTheme.monospaceStyle(fontSize: 9, color: themeColor),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: GoogleFonts.spaceGrotesk(fontSize: 10, color: CyberTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Connection stats bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat("POSTS", operatorPosts.length.toString(), themeColor),
                      _buildStat("CONNECTIONS", _isConnected ? "324" : "323", themeColor),
                      _buildStat("SIGNAL PING", isOnline ? "18ms" : "---", themeColor),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 16),

                  // Biography
                  Text("COGNITIVE PROFILE SYNC:", style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted)),
                  const SizedBox(height: 6),
                  Text(
                    profile["bio"] ?? "Operator dossier logged in secure segment table index.",
                    style: CyberTheme.bodyStyle(fontSize: 12, color: CyberTheme.textMain),
                  ),
                  const SizedBox(height: 24),

                  // Actions row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _isConnected = !_isConnected;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: _isConnected ? Colors.white30 : themeColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            _isConnected ? "TERMINATE LINK" : "ESTABLISH LINK",
                            style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: NeonButton(
                          onPressed: () {
                            // Redirect to messaging screen with this contact selected
                            state.selectUserProfile(profile);
                            state.setScreenIndex(14); // DevChatScreen index
                          },
                          glowColor: themeColor,
                          gradientColors: [themeColor, themeColor.withOpacity(0.5)],
                          child: Text(
                            "DIRECT SIGNAL",
                            style: CyberTheme.headingStyle(fontSize: 10, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Work grid titles
            Text(
              "PIPELINE WORK ARCHIVES",
              style: CyberTheme.headingStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),

            // Work showcase grid
            if (operatorPosts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Center(
                  child: Text(
                    "NO MESH CAPTURES BROADCAST FROM THIS OPERATOR",
                    style: CyberTheme.monospaceStyle(fontSize: 9, color: CyberTheme.textMuted),
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: operatorPosts.length,
                itemBuilder: (context, idx) {
                  final post = operatorPosts[idx];
                  final String imageUrl = post["imageUrl"] ?? "";

                  return InkWell(
                    onTap: () => _showPostDialog(context, post, themeColor),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.white.withOpacity(0.02),
                                  child: Center(
                                    child: Icon(Icons.broken_image_rounded, color: themeColor.withOpacity(0.4)),
                                  ),
                                ),
                              )
                            : Container(
                                color: Colors.white.withOpacity(0.02),
                                child: Center(
                                  child: Icon(Icons.code_rounded, color: themeColor.withOpacity(0.4)),
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color themeColor) {
    return Column(
      children: [
        Text(value, style: CyberTheme.titleStyle(fontSize: 16)),
        const SizedBox(height: 2),
        Text(label, style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted)),
      ],
    );
  }
}
