import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dream_engine_ai/core/state/engine_state.dart';
import 'package:dream_engine_ai/core/models/bio_avatar.dart';
import 'package:dream_engine_ai/core/theme/cyber_theme.dart';
import 'package:dream_engine_ai/core/widgets/glass_container.dart';
import 'package:dream_engine_ai/core/widgets/neon_button.dart';
import 'package:dream_engine_ai/core/widgets/responsive_image.dart';
import 'package:dream_engine_ai/core/widgets/bio_avatar_canvas.dart';
import 'package:dream_engine_ai/core/widgets/avatar_studio_dialog.dart';
import 'package:dream_engine_ai/core/services/sqlite_service.dart';

class _ProfileScreenData {
  final String operatorName;
  final String operatorRole;
  final String operatorEmail;
  final String operatorBio;
  final String? customProfileImagePath;
  final int selectedAvatarIndex;
  final List<String> avatarNames;
  final BioAvatarConfig activeBioAvatar;
  final AppTheme currentTheme;
  final bool isOperatorVerified;
  final RegionalMarket selectedRegion;

  _ProfileScreenData({
    required this.operatorName,
    required this.operatorRole,
    required this.operatorEmail,
    required this.operatorBio,
    this.customProfileImagePath,
    required this.selectedAvatarIndex,
    required this.avatarNames,
    required this.activeBioAvatar,
    required this.currentTheme,
    required this.isOperatorVerified,
    required this.selectedRegion,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ProfileScreenData &&
          runtimeType == other.runtimeType &&
          operatorName == other.operatorName &&
          operatorRole == other.operatorRole &&
          operatorEmail == other.operatorEmail &&
          operatorBio == other.operatorBio &&
          customProfileImagePath == other.customProfileImagePath &&
          selectedAvatarIndex == other.selectedAvatarIndex &&
          avatarNames == other.avatarNames &&
          activeBioAvatar == other.activeBioAvatar &&
          currentTheme == other.currentTheme &&
          isOperatorVerified == other.isOperatorVerified &&
          selectedRegion == other.selectedRegion;

  @override
  int get hashCode => Object.hash(
        operatorName,
        operatorRole,
        operatorEmail,
        operatorBio,
        customProfileImagePath,
        selectedAvatarIndex,
        avatarNames,
        activeBioAvatar,
        currentTheme,
        isOperatorVerified,
        selectedRegion,
      );
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  double _avatarYaw = 0.0;
  double _avatarPitch = 0.0;
  
  late TextEditingController _nameEditController;
  late TextEditingController _roleEditController;
  late TextEditingController _bioEditController;
  late TextEditingController _emailEditController;
  String _lastSyncedEmail = "";

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    final state = Provider.of<EngineState>(context, listen: false);
    _nameEditController = TextEditingController(text: state.operatorName);
    _roleEditController = TextEditingController(text: state.operatorRole);
    _bioEditController = TextEditingController(text: state.operatorBio);
    _emailEditController = TextEditingController(text: state.operatorEmail);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _nameEditController.dispose();
    _roleEditController.dispose();
    _bioEditController.dispose();
    _emailEditController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage(EngineState state) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        state.updateCustomProfileImage(image.path);
      }
    } catch (e) {
      debugPrint("Error picking profile image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              "FAILED TO PICK IMAGE FROM DEVICE: $e",
              style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  void _onAvatarPanUpdate(DragUpdateDetails details) {
    setState(() {
      _avatarYaw += details.delta.dx * 0.01;
      _avatarPitch = (_avatarPitch + details.delta.dy * 0.01).clamp(-0.8, 0.8);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<EngineState, _ProfileScreenData>(
      selector: (context, state) => _ProfileScreenData(
        operatorName: state.operatorName,
        operatorRole: state.operatorRole,
        operatorEmail: state.operatorEmail,
        operatorBio: state.operatorBio,
        customProfileImagePath: state.customProfileImagePath,
        selectedAvatarIndex: state.selectedAvatarIndex,
        avatarNames: state.avatarNames,
        activeBioAvatar: state.activeBioAvatar,
        currentTheme: state.currentTheme,
        isOperatorVerified: state.isOperatorVerified,
        selectedRegion: state.selectedRegion,
      ),
      builder: (context, data, _) {
        if (_lastSyncedEmail != data.operatorEmail) {
          _lastSyncedEmail = data.operatorEmail;
          _nameEditController.text = data.operatorName;
          _roleEditController.text = data.operatorRole;
          _bioEditController.text = data.operatorBio;
          _emailEditController.text = data.operatorEmail;
        }

        final state = Provider.of<EngineState>(context, listen: false);
        final themeColor = _getThemeColor(data.currentTheme);
        final double width = MediaQuery.of(context).size.width;
        final bool isMobile = width < 768;

        final Widget leftColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Operator Profile Card
            GlassContainer(
              borderColor: themeColor.withValues(alpha: 0.2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      // Profile Picture Circle with holographic rings and upload overlay
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => _pickProfileImage(state),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF141A28),
                                border: Border.all(
                                  color: data.isOperatorVerified ? const Color(0xFF00E5FF) : themeColor,
                                  width: 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (data.isOperatorVerified ? const Color(0xFF00E5FF) : themeColor).withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: data.customProfileImagePath != null
                                    ? ResponsiveImage(
                                        imagePath: data.customProfileImagePath!,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      )
                                    : BioAvatarCanvas(
                                        config: data.activeBioAvatar,
                                        size: 80,
                                        showBackground: false,
                                      ),
                              ),
                            ),
                          ),
                          // Hologram scanning circle overlay
                          Container(
                            width: 86,
                            height: 86,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: themeColor.withValues(alpha: 0.15), width: 1),
                            ),
                          ),
                          // Camera edit icon badge
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _pickProfileImage(state),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: themeColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF030712), width: 1.5),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      // Identity Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    "AGENT ${data.operatorName}",
                                    style: CyberTheme.titleStyle(fontSize: 20, color: Colors.white),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (data.isOperatorVerified)
                                  Tooltip(
                                    message: "AUTHENTICATED VERIFIED OPERATOR",
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.4)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.verified_rounded, color: Color(0xFF00E5FF), size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            "VERIFIED",
                                            style: CyberTheme.monospaceStyle(fontSize: 8, color: const Color(0xFF00E5FF)).copyWith(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "ROLE: ${data.operatorRole} // ${data.operatorEmail}",
                              style: CyberTheme.monospaceStyle(fontSize: 9, color: themeColor),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data.operatorBio,
                              style: CyberTheme.bodyStyle(fontSize: 12, color: CyberTheme.textMuted),
                            ),
                            if (data.customProfileImagePath != null) ...[
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => state.updateCustomProfileImage(null),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent, size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      "REMOVE CUSTOM PHOTO",
                                      style: CyberTheme.monospaceStyle(fontSize: 8, color: Colors.redAccent),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 12),
                  Text(
                    "EDIT OPERATOR SECURE DOSSIER",
                    style: CyberTheme.monospaceStyle(fontSize: 9, color: themeColor),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDossierField("NAME ID", _nameEditController, themeColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDossierField("ROLE POSITION", _roleEditController, themeColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDossierField("SECURITY EMAIL ID", _emailEditController, themeColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDossierField("COGNITIVE DOSSIER BIO", _bioEditController, themeColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  NeonButton(
                    onPressed: () async {
                      final name = _nameEditController.text.trim();
                      final role = _roleEditController.text.trim();
                      final email = _emailEditController.text.trim();
                      final bio = _bioEditController.text.trim();

                      if (name.isEmpty || email.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.redAccent,
                            content: Text(
                              "ERROR: NAME AND SECURITY EMAIL CANNOT BE EMPTY",
                              style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.white),
                            ),
                          ),
                        );
                        return;
                      }

                      // Check if new username is already taken by another operator
                      final isTaken = await SqliteService.isUsernameTaken(name, excludeEmail: data.operatorEmail);
                      if (isTaken) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.redAccent,
                              content: Text(
                                "ERROR: USERNAME '$name' IS ALREADY TAKEN BY ANOTHER OPERATOR",
                                style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.white),
                              ),
                            ),
                          );
                        }
                        return;
                      }

                      final success = await state.updateOperatorProfile(
                        name: name,
                        role: role,
                        email: email,
                        bio: bio,
                      );

                      if (context.mounted) {
                        if (success) {
                          _lastSyncedEmail = email;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: themeColor,
                              content: Text(
                                "DOSSIER SECURELY REWRITTEN & PERSISTED TO SQLITE",
                                style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.black),
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.redAccent,
                              content: Text(
                                "ERROR: FAILED TO PERSIST OPERATOR DOSSIER",
                                style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.white),
                              ),
                            ),
                          );
                        }
                      }
                    },
                    glowColor: themeColor,
                    gradientColors: [themeColor, themeColor.withValues(alpha: 0.5)],
                    child: Text(
                      "SAVE SECURITY DOSSIER",
                      style: CyberTheme.headingStyle(fontSize: 11, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Verified Badge Upgrade Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: data.isOperatorVerified
                      ? [
                          const Color(0xFF00E5FF).withValues(alpha: 0.15),
                          const Color(0xFF071220),
                        ]
                      : [
                          const Color(0xFFFF1E27).withValues(alpha: 0.12),
                          const Color(0xFF14080A),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: data.isOperatorVerified
                      ? const Color(0xFF00E5FF).withValues(alpha: 0.4)
                      : const Color(0xFFFF1E27).withValues(alpha: 0.35),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (data.isOperatorVerified ? const Color(0xFF00E5FF) : const Color(0xFFFF1E27)).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: data.isOperatorVerified ? const Color(0xFF00E5FF) : const Color(0xFFFF1E27),
                      ),
                    ),
                    child: Icon(
                      data.isOperatorVerified ? Icons.verified_rounded : Icons.verified_user_outlined,
                      color: data.isOperatorVerified ? const Color(0xFF00E5FF) : const Color(0xFFFF1E27),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              data.isOperatorVerified ? "AUTHENTICATED OPERATOR STATUS" : "OFFICIAL VERIFIED BADGE",
                              style: CyberTheme.headingStyle(
                                fontSize: 11.5,
                                color: data.isOperatorVerified ? const Color(0xFF00E5FF) : Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                data.isOperatorVerified
                                    ? "ACTIVE"
                                    : "BASE: ₹1,000 INR (${state.getFormattedVerifiedBadgePrice()})",
                                style: CyberTheme.monospaceStyle(
                                  fontSize: 7.5,
                                  color: data.isOperatorVerified ? const Color(0xFF00E5FF) : themeColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          data.isOperatorVerified
                              ? "Verified checkmark active across DevGram, DevChat, Achievements, and Operator dossiers."
                              : "Unlock verified blue badge, high-throughput cloud compilation, and unlock all achievements.",
                          style: CyberTheme.bodyStyle(fontSize: 10, color: CyberTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (!data.isOperatorVerified)
                    InkWell(
                      onTap: () => _showVerifiedBadgePurchaseDialog(context, state, themeColor),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.18),
                          border: Border.all(color: const Color(0xFF00E5FF)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.shield_rounded, size: 14, color: Color(0xFF00E5FF)),
                            const SizedBox(width: 6),
                            Text(
                              "GET VERIFIED",
                              style: CyberTheme.monospaceStyle(fontSize: 9, color: Colors.white).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Achievements list
            Text(
              "SYSTEM ACHIEVEMENTS",
              style: CyberTheme.headingStyle(fontSize: 14, color: Colors.white),
            ),
            const SizedBox(height: 10),
            _buildAchievementTile("VOXEL COMPILER LEGEND", "Generate a cyberpunk city with 50,000+ nodes", true, themeColor),
            _buildAchievementTile("NPC SYNAPSE OVERLORD", "Establish dialogue networks across 4 distinct factions", true, themeColor),
            _buildAchievementTile("SHIELD PROTOCOL DEPLOYED", "Acquire threat bypass certification on cloud nodes", true, themeColor),
            _buildAchievementTile(
              "GRAVITY WARPER",
              "Override planetary physics engines under zero-G load",
              data.isOperatorVerified,
              const Color(0xFF00E5FF),
              isVerifiedReq: true,
              onUnlock: () => _showVerifiedBadgePurchaseDialog(context, state, themeColor),
            ),
            _buildAchievementTile(
              "VERIFIED OPERATOR PROTOCOL",
              "Certified official neural system operator node (₹1,000 INR)",
              data.isOperatorVerified,
              const Color(0xFF00E5FF),
              isVerifiedReq: true,
              onUnlock: () => _showVerifiedBadgePurchaseDialog(context, state, themeColor),
            ),
          ],
        );

        final Widget rightColumn = GlassContainer(
          borderColor: themeColor.withValues(alpha: 0.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("3D BIO-AVATAR INTEGRATION", style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text(
                        "INTERACTIVE 3D CHARACTER RENDERING",
                        style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FF88).withValues(alpha: 0.12),
                      border: Border.all(color: const Color(0xFF00FF88).withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "LIVE 3D",
                      style: CyberTheme.monospaceStyle(fontSize: 7, color: const Color(0xFF00FF88)).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Interactive 3D Avatar canvas
              SizedBox(
                height: 250,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    border: Border.all(color: Colors.white10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: GestureDetector(
                      onPanUpdate: _onAvatarPanUpdate,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _rotationController,
                            builder: (context, _) {
                              final double idleFloat = sin(_rotationController.value * 2 * pi) * 0.04;
                              return BioAvatarCanvas(
                                config: data.activeBioAvatar,
                                yaw: _avatarYaw,
                                pitch: _avatarPitch + idleFloat,
                                size: 240,
                                showBackground: true,
                              );
                            },
                          ),
                          Positioned(
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white24, width: 0.5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.threed_rotation_rounded, color: themeColor, size: 10),
                                  const SizedBox(width: 4),
                                  Text(
                                    "DRAG TO ROTATE 3D MESH",
                                    style: CyberTheme.monospaceStyle(fontSize: 7, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Trait Details
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.activeBioAvatar.name.toUpperCase(),
                          style: CyberTheme.headingStyle(fontSize: 10, color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "STYLE: ${data.activeBioAvatar.clothingStyle.replaceAll('_', ' ').toUpperCase()}",
                          style: CyberTheme.monospaceStyle(fontSize: 7.5, color: CyberTheme.textMuted),
                        ),
                      ],
                    ),
                    Text(
                      "SEED: 0x${data.activeBioAvatar.name.hashCode.toRadixString(16).toUpperCase().padLeft(6, '0')}",
                      style: CyberTheme.monospaceStyle(fontSize: 8, color: themeColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: NeonButton(
                      onPressed: () async {
                        final updated = await AvatarStudioDialog.show(context, data.activeBioAvatar);
                        if (updated != null) {
                          state.updateBioAvatar(updated);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFF00FF88).withValues(alpha: 0.2),
                                content: Text(
                                  "SUCCESS: UPDATED 3D BIO-AVATAR FOR ${data.operatorName.toUpperCase()}.",
                                  style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.white),
                                ),
                              ),
                            );
                          }
                        }
                      },
                      glowColor: themeColor,
                      gradientColors: [themeColor, themeColor.withValues(alpha: 0.7)],
                      borderRadius: 6,
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.palette_rounded, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            "CUSTOMIZE AVATAR",
                            style: CyberTheme.headingStyle(fontSize: 9.5, color: Colors.white).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 4,
                    child: InkWell(
                      onTap: () {
                        final randomAvatar = BioAvatarConfig.randomize();
                        state.updateBioAvatar(randomAvatar);
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.purpleAccent.withValues(alpha: 0.12),
                          border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.auto_awesome_rounded, color: Colors.purpleAccent, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              "AI RANDOM",
                              style: CyberTheme.monospaceStyle(fontSize: 8.5, color: Colors.white).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 110), // Scroll padding for navbar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text("OPERATOR DOSSIER", style: CyberTheme.titleStyle(fontSize: isMobile ? 18 : 22)),
              Text(
                "AGENT CREDENTIALS AND INTERACTIVE PROFILE HUD",
                style: CyberTheme.monospaceStyle(fontSize: 9, color: themeColor),
              ),
              const SizedBox(height: 20),

              if (isMobile) ...[
                rightColumn,
                const SizedBox(height: 24),
                leftColumn,
              ] else ...[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.76,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 6,
                        child: SingleChildScrollView(child: leftColumn),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 4,
                        child: rightColumn,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAchievementTile(
    String title,
    String desc,
    bool unlocked,
    Color color, {
    bool isVerifiedReq = false,
    VoidCallback? onUnlock,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        border: Border.all(color: unlocked ? color.withValues(alpha: 0.25) : Colors.white10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            unlocked ? Icons.verified_rounded : Icons.lock_rounded,
            color: unlocked ? color : CyberTheme.textMuted,
            size: 20,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: CyberTheme.headingStyle(fontSize: 11, color: unlocked ? Colors.white : CyberTheme.textMuted),
                    ),
                    if (isVerifiedReq && !unlocked) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          "VERIFICATION REQ",
                          style: CyberTheme.monospaceStyle(fontSize: 7, color: const Color(0xFF00E5FF)),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: CyberTheme.bodyStyle(fontSize: 10, color: CyberTheme.textMuted),
                ),
              ],
            ),
          ),
          if (isVerifiedReq && !unlocked && onUnlock != null)
            TextButton(
              onPressed: onUnlock,
              child: Text(
                "UNLOCK",
                style: CyberTheme.monospaceStyle(fontSize: 9, color: const Color(0xFF00E5FF)).copyWith(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDossierField(String label, TextEditingController controller, Color themeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: CyberTheme.bodyStyle(fontSize: 12, color: Colors.white),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            filled: true,
            fillColor: Colors.black.withValues(alpha: 0.25),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: themeColor.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: themeColor),
            ),
          ),
        ),
      ],
    );
  }

  void _showVerifiedBadgePurchaseDialog(BuildContext context, EngineState state, Color themeColor) {
    RegionalMarket chosenMarket = state.selectedRegion;
    String selectedPaymentMethod = chosenMarket.countryCode == "IN" ? "UPI / GPAY / PHONEPE" : "CREDIT / DEBIT CARD";
    bool isProcessing = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          final formattedPrice = state.getFormattedVerifiedBadgePrice(chosenMarket);

          return AlertDialog(
            backgroundColor: const Color(0xFF080C16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: const Color(0xFF00E5FF).withValues(alpha: 0.4)),
            ),
            title: Row(
              children: [
                const Icon(Icons.verified_rounded, color: Color(0xFF00E5FF), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "VERIFIED OPERATOR PROTOCOL",
                        style: CyberTheme.headingStyle(fontSize: 13, color: Colors.white),
                      ),
                      Text(
                        "BASE: 1,000 INR (DYNAMIC LOCATION CONVERSION)",
                        style: CyberTheme.monospaceStyle(fontSize: 8, color: const Color(0xFF00E5FF)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 460,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Location selector
                    Text(
                      "SELECT BILLING LOCATION / CURRENCY MATRIX",
                      style: CyberTheme.monospaceStyle(fontSize: 8.5, color: CyberTheme.textMuted),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<RegionalMarket>(
                          value: chosenMarket,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF090D18),
                          style: CyberTheme.monospaceStyle(fontSize: 11, color: Colors.white),
                          items: state.regionalMarkets.map((m) {
                            return DropdownMenuItem<RegionalMarket>(
                              value: m,
                              child: Row(
                                children: [
                                  Text("${m.countryCode}  ${m.regionName}", style: const TextStyle(color: Colors.white)),
                                  const Spacer(),
                                  Text(
                                    state.getFormattedVerifiedBadgePrice(m),
                                    style: TextStyle(color: const Color(0xFF00E5FF), fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDlgState(() {
                                chosenMarket = val;
                                if (chosenMarket.countryCode == "IN") {
                                  selectedPaymentMethod = "UPI / GPAY / PHONEPE";
                                } else {
                                  selectedPaymentMethod = "CREDIT / DEBIT CARD";
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Big Price Amount Display
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.08),
                        border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "TOTAL AMOUNT DUE",
                                style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formattedPrice,
                                style: CyberTheme.titleStyle(fontSize: 22, color: const Color(0xFF00E5FF)),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00FF88).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF00FF88).withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              "LIFETIME ACCESS",
                              style: CyberTheme.monospaceStyle(fontSize: 8, color: const Color(0xFF00FF88)).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Perks List
                    Text("VERIFICATION PERKS INCLUDED:", style: CyberTheme.monospaceStyle(fontSize: 8.5, color: Colors.white70)),
                    const SizedBox(height: 6),
                    _buildPerkRow("Official Cyan Verified Badge beside name across DevGram & DevChat"),
                    _buildPerkRow("Unlock exclusive achievements: 'Gravity Warper' & 'Verified Protocol'"),
                    _buildPerkRow("Priority AI neural mesh compiler throughput and VRAM allocation"),
                    _buildPerkRow("+500 Bonus Rusty Tokens added to operator wallet immediately"),
                    const SizedBox(height: 16),

                    // Payment Method Options
                    Text("SELECT PAYMENT ROUTE:", style: CyberTheme.monospaceStyle(fontSize: 8.5, color: Colors.white70)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (chosenMarket.countryCode == "IN")
                          _buildPayOption("UPI / GPAY / PHONEPE", Icons.qr_code_scanner_rounded, selectedPaymentMethod, (val) => setDlgState(() => selectedPaymentMethod = val)),
                        _buildPayOption("CREDIT / DEBIT CARD", Icons.credit_card_rounded, selectedPaymentMethod, (val) => setDlgState(() => selectedPaymentMethod = val)),
                        _buildPayOption("RUSTY TOKENS", Icons.toll_rounded, selectedPaymentMethod, (val) => setDlgState(() => selectedPaymentMethod = val)),
                        _buildPayOption("CRYPTO / WEB3", Icons.currency_bitcoin_rounded, selectedPaymentMethod, (val) => setDlgState(() => selectedPaymentMethod = val)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isProcessing ? null : () => Navigator.pop(ctx),
                child: Text("CANCEL", style: CyberTheme.monospaceStyle(fontSize: 10, color: CyberTheme.textMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: isProcessing
                    ? null
                    : () async {
                        setDlgState(() => isProcessing = true);
                        final success = await state.purchaseVerifiedBadge(
                          paymentMethod: selectedPaymentMethod,
                          market: chosenMarket,
                        );
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFF00E5FF),
                                content: Text(
                                  "SUCCESS: VERIFIED OPERATOR BADGE ACTIVATED FOR ${state.operatorName.toUpperCase()}! (+500 RUSTY TOKENS REWARDED)",
                                  style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.black).copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          }
                        }
                      },
                child: isProcessing
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : Text(
                        "PAY $formattedPrice & ACTIVATE",
                        style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.black).copyWith(fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPerkRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline_rounded, size: 13, color: Color(0xFF00E5FF)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: CyberTheme.bodyStyle(fontSize: 9.5, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayOption(String label, IconData icon, String current, Function(String) onSelect) {
    final isSel = current == label;
    return InkWell(
      onTap: () => onSelect(label),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFF00E5FF).withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.03),
          border: Border.all(
            color: isSel ? const Color(0xFF00E5FF) : Colors.white12,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: isSel ? const Color(0xFF00E5FF) : Colors.white60),
            const SizedBox(width: 6),
            Text(
              label,
              style: CyberTheme.monospaceStyle(
                fontSize: 8,
                color: isSel ? Colors.white : Colors.white60,
              ).copyWith(fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  Color _getThemeColor(AppTheme theme) {
    if (theme == AppTheme.ironMan) return Colors.amber;
    if (theme == AppTheme.nvidiaGreen) return Colors.lightGreenAccent;
    if (theme == AppTheme.appleVision) return Colors.white;
    return CyberTheme.neonBlue;
  }
}
