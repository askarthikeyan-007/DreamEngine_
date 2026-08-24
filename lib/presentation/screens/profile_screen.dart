import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dream_engine_ai/core/state/engine_state.dart';
import 'package:dream_engine_ai/core/theme/cyber_theme.dart';
import 'package:dream_engine_ai/core/widgets/glass_container.dart';
import 'package:dream_engine_ai/core/widgets/neon_button.dart';
import 'package:dream_engine_ai/core/widgets/responsive_image.dart';

class _ProfileScreenData {
  final String operatorName;
  final String operatorRole;
  final String operatorEmail;
  final String operatorBio;
  final String? customProfileImagePath;
  final int selectedAvatarIndex;
  final List<String> avatarNames;
  final AppTheme currentTheme;

  _ProfileScreenData({
    required this.operatorName,
    required this.operatorRole,
    required this.operatorEmail,
    required this.operatorBio,
    this.customProfileImagePath,
    required this.selectedAvatarIndex,
    required this.avatarNames,
    required this.currentTheme,
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
          currentTheme == other.currentTheme;

  @override
  int get hashCode => Object.hash(
        operatorName,
        operatorRole,
        operatorEmail,
        operatorBio,
        customProfileImagePath,
        selectedAvatarIndex,
        avatarNames,
        currentTheme,
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
        currentTheme: state.currentTheme,
      ),
      builder: (context, data, _) {
        final state = Provider.of<EngineState>(context, listen: false);
        final themeColor = _getThemeColor(data.currentTheme);
        final double width = MediaQuery.of(context).size.width;
        final bool isMobile = width < 768;

        final Widget leftColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Operator Profile Card
            GlassContainer(
              borderColor: themeColor.withOpacity(0.2),
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
                                border: Border.all(color: themeColor.withOpacity(0.4), width: 2),
                                color: themeColor.withOpacity(0.08),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: data.customProfileImagePath != null
                                    ? ResponsiveImage(
                                        imagePath: data.customProfileImagePath!,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(
                                        data.selectedAvatarIndex == 0
                                            ? Icons.blur_on_rounded
                                            : data.selectedAvatarIndex == 1
                                                ? Icons.face_retouching_natural_rounded
                                                : data.selectedAvatarIndex == 2
                                                    ? Icons.precision_manufacturing_rounded
                                                    : Icons.person_pin_rounded,
                                        color: themeColor,
                                        size: 40,
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
                              border: Border.all(color: themeColor.withOpacity(0.15), width: 1),
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
                            Text(
                              "AGENT ${data.operatorName}",
                              style: CyberTheme.titleStyle(fontSize: 20, color: Colors.white),
                            ),
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
                  // Selector Row
                  Text(
                    "SELECT COGNITIVE PORTRAIT MATRIX",
                    style: CyberTheme.monospaceStyle(fontSize: 9, color: themeColor),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(data.avatarNames.length, (idx) {
                      final isSel = data.selectedAvatarIndex == idx;
                      return Expanded(
                        child: InkWell(
                          onTap: () => state.setAvatarIndex(idx),
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel ? themeColor.withOpacity(0.12) : Colors.white.withOpacity(0.02),
                              border: Border.all(
                                color: isSel ? themeColor : Colors.white10,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              data.avatarNames[idx].toUpperCase(),
                              style: CyberTheme.monospaceStyle(
                                fontSize: 9,
                                color: isSel ? Colors.white : CyberTheme.textMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }),
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
                    onPressed: () {
                      if (_nameEditController.text.isNotEmpty && _emailEditController.text.isNotEmpty) {
                        state.updateOperatorProfile(
                          name: _nameEditController.text.trim(),
                          role: _roleEditController.text.trim(),
                          email: _emailEditController.text.trim(),
                          bio: _bioEditController.text.trim(),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: themeColor,
                            content: Text(
                              "DOSSIER SECURELY REWRITTEN TO SECTOR 0x0A",
                              style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.black),
                            ),
                          ),
                        );
                      }
                    },
                    glowColor: themeColor,
                    gradientColors: [themeColor, themeColor.withOpacity(0.5)],
                    child: Text(
                      "SAVE SECURITY DOSSIER",
                      style: CyberTheme.headingStyle(fontSize: 11, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Achievements list
            Text(
              "SYSTEM ACHIEVEMENTS",
              style: CyberTheme.headingStyle(fontSize: 14, color: Colors.white),
            ),
            const SizedBox(height: 10),
            _buildAchievementTile("VOXEL COMPILER LEGEND", "Generate a cyberpunk city with 50,000+ nodes", true, themeColor),
            _buildAchievementTile("NPC SYNAPSE OVERLORD", "Establish dialogue networks across 4 distinct factions", true, themeColor),
            _buildAchievementTile("SHIELD PROTOCOL DEPLOYED", "Acquire threat bypass certification on cloud nodes", true, themeColor),
            _buildAchievementTile("GRAVITY WARPER", "Override planetary physics engines under zero-G load", false, themeColor),
          ],
        );

        final Widget rightColumn = GlassContainer(
          borderColor: themeColor.withOpacity(0.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("3D BIO-AVATAR INTEGRATION", style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white)),
              const SizedBox(height: 4),
              Text(
                "DRAG TO ROTATE HOLOGRAM MESH",
                style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
              ),
              const SizedBox(height: 12),

              // Interactive 3D Avatar canvas
              SizedBox(
                height: 250,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    border: Border.all(color: Colors.white10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: GestureDetector(
                      onPanUpdate: _onAvatarPanUpdate,
                      child: AnimatedBuilder(
                        animation: _rotationController,
                        builder: (context, _) {
                          final currentYaw = _avatarYaw + (_rotationController.value * 2 * pi);
                          return RepaintBoundary(
                            child: CustomPaint(
                              painter: Avatar3DPainter(
                                yaw: currentYaw,
                                pitch: _avatarPitch,
                                color: themeColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  "AVATAR SEED: 0xFF24A8",
                  style: CyberTheme.monospaceStyle(fontSize: 10, color: themeColor),
                ),
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
                  height: MediaQuery.of(context).size.height * 0.72,
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

  Widget _buildAchievementTile(String title, String desc, bool unlocked, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border.all(color: unlocked ? color.withOpacity(0.25) : Colors.white10),
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
                Text(
                  title,
                  style: CyberTheme.headingStyle(fontSize: 11, color: unlocked ? Colors.white : CyberTheme.textMuted),
                ),
                Text(
                  desc,
                  style: CyberTheme.bodyStyle(fontSize: 10, color: CyberTheme.textMuted),
                ),
              ],
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
            fillColor: Colors.black.withOpacity(0.25),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: themeColor.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: themeColor),
            ),
          ),
        ),
      ],
    );
  }

  Color _getThemeColor(AppTheme theme) {
    if (theme == AppTheme.ironMan) return Colors.amber;
    if (theme == AppTheme.nvidiaGreen) return Colors.lightGreenAccent;
    if (theme == AppTheme.appleVision) return Colors.white;
    return CyberTheme.neonBlue;
  }
}

// CustomPainter to draw a 3D rotating cyber-head/sphere model using vector projection math!
class Avatar3DPainter extends CustomPainter {
  final double yaw;
  final double pitch;
  final Color color;

  Avatar3DPainter({required this.yaw, required this.pitch, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final nodePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Define 3D points representing a cyber sphere (latitude / longitude grid)
    final List<List<double>> points3D = [];
    final int latCount = 6;
    final int lonCount = 10;
    final double radius = min(size.width, size.height) * 0.32;

    for (int lat = 0; lat <= latCount; lat++) {
      final double latAngle = (lat * pi) / latCount;
      for (int lon = 0; lon < lonCount; lon++) {
        final double lonAngle = (lon * 2 * pi) / lonCount;

        // Spherical to Cartesian coordinates conversion
        final double x = radius * sin(latAngle) * cos(lonAngle);
        final double y = radius * cos(latAngle);
        final double z = radius * sin(latAngle) * sin(lonAngle);

        points3D.add([x, y, z]);
      }
    }

    // 3D rotation math using trigonometric matrices (yaw & pitch)
    final double cosYaw = cos(yaw);
    final double sinYaw = sin(yaw);
    final double cosPitch = cos(pitch);
    final double sinPitch = sin(pitch);

    final List<Offset> points2D = [];
    final List<double> depths = []; // For simple depth rendering cues

    for (var pt in points3D) {
      double x = pt[0];
      double y = pt[1];
      double z = pt[2];

      // Rotate around Y-axis (Yaw)
      double rx1 = x * cosYaw - z * sinYaw;
      double rz1 = x * sinYaw + z * cosYaw;

      // Rotate around X-axis (Pitch)
      double ry2 = y * cosPitch - rz1 * sinPitch;
      double rz2 = y * sinPitch + rz1 * cosPitch;

      // Perspective divide projection
      final double cameraDist = radius * 2.5;
      final double focalLength = radius * 2.2;
      final double scale = focalLength / (rz2 + cameraDist);

      final double px = center.dx + rx1 * scale;
      final double py = center.dy + ry2 * scale;

      points2D.add(Offset(px, py));
      depths.add(rz2);
    }

    // Draw grid connections (Lines between neighbors in the mesh)
    for (int lat = 0; lat <= latCount; lat++) {
      for (int lon = 0; lon < lonCount; lon++) {
        final int idx = lat * lonCount + lon;
        final int nextLonIdx = lat * lonCount + ((lon + 1) % lonCount);
        final int nextLatIdx = (lat + 1) * lonCount + lon;

        // Draw horizontal ring line
        if (idx < points2D.length && nextLonIdx < points2D.length) {
          // Adjust opacity based on depth to create a gorgeous 3D volumetric effect!
          final double avgDepth = (depths[idx] + depths[nextLonIdx]) / 2;
          final double opacity = ((avgDepth + radius) / (2 * radius)).clamp(0.08, 0.7);
          canvas.drawLine(
            points2D[idx],
            points2D[nextLonIdx],
            paint..color = color.withOpacity(opacity),
          );
        }

        // Draw vertical longitudinal line
        if (lat < latCount && idx < points2D.length && nextLatIdx < points2D.length) {
          final double avgDepth = (depths[idx] + depths[nextLatIdx]) / 2;
          final double opacity = ((avgDepth + radius) / (2 * radius)).clamp(0.08, 0.7);
          canvas.drawLine(
            points2D[idx],
            points2D[nextLatIdx],
            paint..color = color.withOpacity(opacity),
          );
        }
      }
    }

    // Draw vertex dots
    for (int i = 0; i < points2D.length; i++) {
      final double depth = depths[i];
      final double opacity = ((depth + radius) / (2 * radius)).clamp(0.1, 0.85);
      canvas.drawCircle(
        points2D[i],
        2 + (opacity * 2.5),
        nodePaint..color = color.withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
