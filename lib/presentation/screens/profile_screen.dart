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
                                avatarIndex: data.selectedAvatarIndex,
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

// CustomPainter to draw a dynamic 3D wireframe mesh based on the selected avatar type using vector projection math!
class Avatar3DPainter extends CustomPainter {
  final double yaw;
  final double pitch;
  final Color color;
  final int avatarIndex;

  Avatar3DPainter({
    required this.yaw,
    required this.pitch,
    required this.color,
    required this.avatarIndex,
  });

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

    final double radius = min(size.width, size.height) * 0.32;
    final List<List<double>> points3D = [];
    final List<List<int>> edges = [];

    if (avatarIndex == 0) {
      // 1. Cyber Core (3D Tesseract / Hypercube mesh)
      final double R = radius * 0.8;
      // Vertices 0-7: Outer Cube
      for (int x = -1; x <= 1; x += 2) {
        for (int y = -1; y <= 1; y += 2) {
          for (int z = -1; z <= 1; z += 2) {
            points3D.add([x * R, y * R, z * R]);
          }
        }
      }
      // Vertices 8-15: Inner Cube
      for (int x = -1; x <= 1; x += 2) {
        for (int y = -1; y <= 1; y += 2) {
          for (int z = -1; z <= 1; z += 2) {
            points3D.add([x * R * 0.45, y * R * 0.45, z * R * 0.45]);
          }
        }
      }
      // Connect outer cube edges
      for (int i = 0; i < 8; i++) {
        for (int j = i + 1; j < 8; j++) {
          int diff = 0;
          for (int k = 0; k < 3; k++) {
            if (points3D[i][k] != points3D[j][k]) diff++;
          }
          if (diff == 1) edges.add([i, j]);
        }
      }
      // Connect inner cube edges
      for (int i = 0; i < 8; i++) {
        for (int j = i + 1; j < 8; j++) {
          int diff = 0;
          for (int k = 0; k < 3; k++) {
            if ((points3D[i + 8][k] / 0.45) != (points3D[j + 8][k] / 0.45)) diff++;
          }
          if (diff == 1) edges.add([i + 8, j + 8]);
        }
      }
      // Connect corresponding outer & inner corners
      for (int i = 0; i < 8; i++) {
        edges.add([i, i + 8]);
      }
    } else if (avatarIndex == 1) {
      // 2. Vesper Net (3D Torus Ring Topology)
      final double R_torus = radius * 0.8;
      final double r_torus = radius * 0.28;
      final int latCount = 8;
      final int lonCount = 14;

      for (int lat = 0; lat < latCount; lat++) {
        final double u = (lat * 2 * pi) / latCount;
        for (int lon = 0; lon < lonCount; lon++) {
          final double v = (lon * 2 * pi) / lonCount;
          final double x = (R_torus + r_torus * cos(u)) * cos(v);
          final double y = r_torus * sin(u);
          final double z = (R_torus + r_torus * cos(u)) * sin(v);
          points3D.add([x, y, z]);
        }
      }
      // Connect torus edges
      for (int lat = 0; lat < latCount; lat++) {
        for (int lon = 0; lon < lonCount; lon++) {
          final int idx = lat * lonCount + lon;
          final int nextLonIdx = lat * lonCount + ((lon + 1) % lonCount);
          final int nextLatIdx = ((lat + 1) % latCount) * lonCount + lon;
          edges.add([idx, nextLonIdx]);
          edges.add([idx, nextLatIdx]);
        }
      }
    } else if (avatarIndex == 2) {
      // 3. Tactical Drone (Double-pyramid octahedron core with rotor arms and blade frames)
      final double R = radius;
      // Core body
      points3D.add([0, R * 0.6, 0]);   // 0: Top
      points3D.add([0, -R * 0.6, 0]);  // 1: Bottom
      points3D.add([R * 0.35, 0, 0]);  // 2: Front
      points3D.add([-R * 0.35, 0, 0]); // 3: Back
      points3D.add([0, 0, R * 0.35]);  // 4: Right
      points3D.add([0, 0, -R * 0.35]); // 5: Left

      edges.addAll([
        [0, 2], [0, 3], [0, 4], [0, 5],
        [1, 2], [1, 3], [1, 4], [1, 5],
        [2, 4], [4, 3], [3, 5], [5, 2]
      ]);

      // Rotor Arm Tips
      points3D.add([R * 0.85, R * 0.1, R * 0.85]);   // 6: Front Right
      points3D.add([-R * 0.85, R * 0.1, R * 0.85]);  // 7: Back Right
      points3D.add([-R * 0.85, R * 0.1, -R * 0.85]); // 8: Back Left
      points3D.add([R * 0.85, R * 0.1, -R * 0.85]);  // 9: Front Left

      edges.addAll([[4, 6], [3, 7], [5, 8], [2, 9]]);

      // Rotor ring coordinates
      int startIdx = 10;
      for (int arm = 0; arm < 4; arm++) {
        final double ax = points3D[6 + arm][0];
        final double ay = points3D[6 + arm][1];
        final double az = points3D[6 + arm][2];

        for (int b = 0; b < 4; b++) {
          final double bx = ax + R * 0.22 * cos(b * pi / 2);
          final double bz = az + R * 0.22 * sin(b * pi / 2);
          points3D.add([bx, ay, bz]);
        }

        final int c0 = startIdx + arm * 4;
        edges.addAll([
          [6 + arm, c0], [6 + arm, c0 + 1], [6 + arm, c0 + 2], [6 + arm, c0 + 3],
          [c0, c0 + 1], [c0 + 1, c0 + 2], [c0 + 2, c0 + 3], [c0 + 3, c0]
        ]);
      }
    } else {
      // 4. Aegis Pilot (Cyber-Helmet mesh with visor plate cut-out)
      final double R = radius;
      final int latCount = 5;
      final int lonCount = 8;

      for (int lat = 0; lat <= latCount; lat++) {
        final double latAngle = (lat * pi) / (latCount + 1);
        for (int lon = 0; lon < lonCount; lon++) {
          final double lonAngle = (lon * 2 * pi) / lonCount;
          final double x = R * 0.75 * sin(latAngle) * cos(lonAngle);
          final double y = R * 0.85 * cos(latAngle);
          final double z = R * 0.75 * sin(latAngle) * sin(lonAngle);

          // Visor front cut-out to make it a helmet shell
          final bool isFrontVisorArea = (z > R * 0.3 && y > -R * 0.3 && y < R * 0.3 && x > -R * 0.5 && x < R * 0.5);
          if (!isFrontVisorArea) {
            points3D.add([x, y, z]);
          }
        }
      }

      // Visor shield panel front vertices
      final int visorStartIdx = points3D.length;
      points3D.addAll([
        [-R * 0.45, R * 0.25, R * 0.65],  // Top Left Visor
        [R * 0.45, R * 0.25, R * 0.65],   // Top Right Visor
        [R * 0.45, -R * 0.28, R * 0.65],  // Bottom Right Visor
        [-R * 0.45, -R * 0.28, R * 0.65], // Bottom Left Visor
        [0.0, R * 0.35, R * 0.72],        // Visor Peak Crest
        [0.0, -R * 0.38, R * 0.72],       // Visor Chin Point
      ]);

      // Connect visor visor
      edges.addAll([
        [visorStartIdx, visorStartIdx + 1],
        [visorStartIdx + 1, visorStartIdx + 2],
        [visorStartIdx + 2, visorStartIdx + 3],
        [visorStartIdx + 3, visorStartIdx],
        [visorStartIdx, visorStartIdx + 4],
        [visorStartIdx + 1, visorStartIdx + 4],
        [visorStartIdx + 2, visorStartIdx + 5],
        [visorStartIdx + 3, visorStartIdx + 5],
        [visorStartIdx + 4, visorStartIdx + 5],
      ]);

      // Connect skull dome vertices using proximity-based neighboring
      for (int i = 0; i < visorStartIdx; i++) {
        for (int j = i + 1; j < visorStartIdx; j++) {
          final double dx = points3D[i][0] - points3D[j][0];
          final double dy = points3D[i][1] - points3D[j][1];
          final double dz = points3D[i][2] - points3D[j][2];
          final double dist = sqrt(dx * dx + dy * dy + dz * dz);
          if (dist > R * 0.1 && dist < R * 0.48) {
            edges.add([i, j]);
          }
        }
      }

      // Connect visor frame to nearby helmet body points
      for (int v = 0; v < 6; v++) {
        final int vIdx = visorStartIdx + v;
        double minDist = double.infinity;
        int nearestIdx = -1;

        for (int i = 0; i < visorStartIdx; i++) {
          final double dx = points3D[vIdx][0] - points3D[i][0];
          final double dy = points3D[vIdx][1] - points3D[i][1];
          final double dz = points3D[vIdx][2] - points3D[i][2];
          final double dist = sqrt(dx * dx + dy * dy + dz * dz);
          if (dist < minDist) {
            minDist = dist;
            nearestIdx = i;
          }
        }
        if (nearestIdx != -1) {
          edges.add([vIdx, nearestIdx]);
        }
      }
    }

    // 3D vector rotation projection (yaw & pitch rotation matrices)
    final double cosYaw = cos(yaw);
    final double sinYaw = sin(yaw);
    final double cosPitch = cos(pitch);
    final double sinPitch = sin(pitch);

    final List<Offset> points2D = [];
    final List<double> depths = [];

    for (var pt in points3D) {
      final double x = pt[0];
      final double y = pt[1];
      final double z = pt[2];

      // Yaw rotation (Y-axis)
      final double rx1 = x * cosYaw - z * sinYaw;
      final double rz1 = x * sinYaw + z * cosYaw;

      // Pitch rotation (X-axis)
      final double ry2 = y * cosPitch - rz1 * sinPitch;
      final double rz2 = y * sinPitch + rz1 * cosPitch;

      // Perspective scale division
      final double cameraDist = radius * 2.5;
      final double focalLength = radius * 2.2;
      final double scale = focalLength / (rz2 + cameraDist);

      final double px = center.dx + rx1 * scale;
      final double py = center.dy + ry2 * scale;

      points2D.add(Offset(px, py));
      depths.add(rz2);
    }

    // Draw projected connecting lines
    for (var edge in edges) {
      final int i = edge[0];
      final int j = edge[1];

      if (i < points2D.length && j < points2D.length) {
        final double avgDepth = (depths[i] + depths[j]) / 2;
        final double opacity = ((avgDepth + radius) / (2 * radius)).clamp(0.08, 0.75);
        canvas.drawLine(
          points2D[i],
          points2D[j],
          paint..color = color.withOpacity(opacity),
        );
      }
    }

    // Draw vertex node dots
    for (int i = 0; i < points2D.length; i++) {
      final double depth = depths[i];
      final double opacity = ((depth + radius) / (2 * radius)).clamp(0.1, 0.9);
      canvas.drawCircle(
        points2D[i],
        1.5 + (opacity * 2.0),
        nodePaint..color = color.withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
