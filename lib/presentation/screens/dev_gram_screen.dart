import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dream_engine_ai/core/state/engine_state.dart';
import 'package:dream_engine_ai/core/theme/cyber_theme.dart';
import 'package:dream_engine_ai/core/models/bio_avatar.dart';
import 'package:dream_engine_ai/core/widgets/bio_avatar_canvas.dart';
import 'package:dream_engine_ai/core/widgets/glass_container.dart';
import 'package:dream_engine_ai/core/widgets/neon_button.dart';
import 'package:dream_engine_ai/core/widgets/responsive_image.dart';

class DevGramScreen extends StatefulWidget {
  const DevGramScreen({super.key});

  @override
  State<DevGramScreen> createState() => _DevGramScreenState();
}

class _DevGramScreenState extends State<DevGramScreen> {
  final Map<String, TextEditingController> _postCommentControllers = {};
  final Map<String, bool> _doubleTapHeartVisible = {}; // Track like pop-ups for posts

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<EngineState>(context, listen: false);
      state.fetchDevgramPosts();
      state.fetchDevgramStories();
    });
  }

  @override
  void dispose() {
    for (var controller in _postCommentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _getCommentController(String postId) {
    if (!_postCommentControllers.containsKey(postId)) {
      _postCommentControllers[postId] = TextEditingController();
    }
    return _postCommentControllers[postId]!;
  }

  Future<String?> _pickDeviceImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image?.path;
    } catch (e) {
      debugPrint("Error picking custom post/story image: $e");
      return null;
    }
  }

  Color _getThemeColor(EngineState state) {
    if (state.currentTheme == AppTheme.ironMan) return Colors.amber;
    if (state.currentTheme == AppTheme.nvidiaGreen) return Colors.lightGreenAccent;
    if (state.currentTheme == AppTheme.appleVision) return Colors.white;
    return CyberTheme.neonBlue;
  }

  Widget _buildOperatorAvatar({
    required String email,
    required String name,
    required int avatarIdx,
    required EngineState state,
    double radius = 16,
    Color? borderColor,
  }) {
    final isMe = email.toLowerCase().trim() == state.operatorEmail.toLowerCase().trim();
    if (isMe && state.customProfileImagePath != null && state.customProfileImagePath!.isNotEmpty) {
      return Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: borderColor != null ? Border.all(color: borderColor, width: 1.5) : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: ResponsiveImage(
            imagePath: state.customProfileImagePath!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    if (isMe) {
      return Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF141A28),
          border: borderColor != null ? Border.all(color: borderColor, width: 1.5) : null,
        ),
        child: ClipOval(
          child: BioAvatarCanvas(
            config: state.activeBioAvatar,
            size: radius * 2,
            showBackground: false,
          ),
        ),
      );
    }

    // Other operator avatar
    final avatarConfig = avatarIdx < BioAvatarConfig.presets.length
        ? BioAvatarConfig.presets[avatarIdx]
        : BioAvatarConfig.presets[0];

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF141A28),
        border: borderColor != null ? Border.all(color: borderColor, width: 1.5) : null,
      ),
      child: ClipOval(
        child: BioAvatarCanvas(
          config: avatarConfig,
          size: radius * 2,
          showBackground: false,
        ),
      ),
    );
  }

  void _showCreatePostModal(BuildContext context, EngineState state, Color themeColor) {
    final captionController = TextEditingController();
    String? selectedImagePath;
    bool isAvatarCard = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0A0E),
                  border: Border(top: BorderSide(color: themeColor.withValues(alpha: 0.3), width: 1.5)),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text("TRANSMIT COGNITIVE GRID CAPTURE", style: CyberTheme.headingStyle(fontSize: 14)),
                      Text(
                        "DISPATCH REAL TRANSMISSION TO THE LIVE DEVGRAM MATRIX",
                        style: CyberTheme.monospaceStyle(fontSize: 8, color: themeColor),
                      ),
                      const SizedBox(height: 20),

                      // Image Source Action Buttons
                      Text("ATTACH OPERATOR MEDIA:", style: CyberTheme.monospaceStyle(fontSize: 9, color: CyberTheme.textMuted)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          // Gallery Button
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final path = await _pickDeviceImage(source: ImageSource.gallery);
                                if (path != null) {
                                  setModalState(() {
                                    selectedImagePath = path;
                                    isAvatarCard = false;
                                  });
                                }
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: (selectedImagePath != null && !isAvatarCard) ? themeColor.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.03),
                                  border: Border.all(
                                    color: (selectedImagePath != null && !isAvatarCard) ? themeColor : Colors.white12,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.photo_library_rounded, color: themeColor, size: 20),
                                    const SizedBox(height: 6),
                                    Text(
                                      "GALLERY",
                                      style: CyberTheme.monospaceStyle(fontSize: 8.5, color: Colors.white).copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Camera Button
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final path = await _pickDeviceImage(source: ImageSource.camera);
                                if (path != null) {
                                  setModalState(() {
                                    selectedImagePath = path;
                                    isAvatarCard = false;
                                  });
                                }
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.03),
                                  border: Border.all(color: Colors.white12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.camera_alt_rounded, color: themeColor, size: 20),
                                    const SizedBox(height: 6),
                                    Text(
                                      "CAMERA",
                                      style: CyberTheme.monospaceStyle(fontSize: 8.5, color: Colors.white).copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // 3D Avatar Card Option
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setModalState(() {
                                  selectedImagePath = "avatar_snapshot";
                                  isAvatarCard = true;
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: isAvatarCard ? themeColor.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.03),
                                  border: Border.all(
                                    color: isAvatarCard ? themeColor : Colors.white12,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.person_pin_rounded, color: themeColor, size: 20),
                                    const SizedBox(height: 6),
                                    Text(
                                      "3D AVATAR",
                                      style: CyberTheme.monospaceStyle(fontSize: 8.5, color: Colors.white).copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Preview Selected Image / Avatar / Code DevLog
                      if (selectedImagePath != null && !isAvatarCard) ...[
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: ResponsiveImage(
                                imagePath: selectedImagePath!,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setModalState(() {
                                  selectedImagePath = null;
                                });
                              },
                              icon: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.black87,
                                child: Icon(Icons.close_rounded, size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ] else if (isAvatarCard) ...[
                        Container(
                          height: 160,
                          decoration: BoxDecoration(
                            color: const Color(0xFF141A28),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: themeColor.withValues(alpha: 0.4)),
                          ),
                          alignment: Alignment.center,
                          child: BioAvatarCanvas(
                            config: state.activeBioAvatar,
                            size: 140,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Caption Field
                      TextField(
                        controller: captionController,
                        maxLines: 3,
                        style: CyberTheme.bodyStyle(fontSize: 13, color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "WRITE CAPTION, DEVLOG NOTES, OR #HASHTAGS...",
                          hintStyle: CyberTheme.bodyStyle(fontSize: 12, color: Colors.white24),
                          filled: true,
                          fillColor: Colors.black.withValues(alpha: 0.3),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: themeColor.withValues(alpha: 0.2)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: themeColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Transmit Post Button
                      NeonButton(
                        onPressed: () async {
                          final caption = captionController.text.trim();
                          if (caption.isEmpty && selectedImagePath == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.redAccent,
                                content: Text(
                                  "PLEASE WRITE A TRANSMISSION CAPTION OR ATTACH MEDIA",
                                  style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.white),
                                ),
                              ),
                            );
                            return;
                          }

                          // Dispatch post
                          await state.createDevgramPost(
                            caption.isNotEmpty ? caption : "Transmission broadcast from ${state.operatorName}.",
                            selectedImagePath ?? "",
                          );

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: themeColor,
                                content: Text(
                                  "TRANSMISSION BROADCASTED TO LIVE DEVGRAM MATRIX",
                                  style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.black),
                                ),
                              ),
                            );
                          }
                        },
                        glowColor: themeColor,
                        gradientColors: [themeColor, themeColor.withValues(alpha: 0.5)],
                        child: Text("TRANSMIT TO DEVGRAM", style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white)),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showStoryViewer(BuildContext context, Map<String, dynamic> story, Color themeColor) {
    double progress = 0.0;
    Timer? storyTimer;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Start timer once
            if (storyTimer == null) {
              storyTimer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
                setModalState(() {
                  if (progress < 1.0) {
                    progress += 0.01;
                  } else {
                    timer.cancel();
                    Navigator.of(ctx).pop();
                  }
                });
              });
            }

            final authorName = story["authorName"] ?? "OPERATOR";
            final authorEmail = story["authorEmail"] ?? "";
            final avatarIndex = story["avatarIndex"] ?? 0;
            final imageUrl = story["imageUrl"]?.toString() ?? "";
            final isAvatarStory = imageUrl == "avatar_snapshot" || imageUrl.isEmpty;

            return Dialog(
              backgroundColor: Colors.black,
              insetPadding: EdgeInsets.zero,
              child: GestureDetector(
                onTap: () {
                  storyTimer?.cancel();
                  Navigator.of(ctx).pop();
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Full screen story image or 3D Avatar view
                    if (isAvatarStory)
                      Container(
                        color: const Color(0xFF0A0E17),
                        child: Center(
                          child: BioAvatarCanvas(
                            config: Provider.of<EngineState>(context, listen: false).activeBioAvatar,
                            size: 280,
                          ),
                        ),
                      )
                    else
                      ResponsiveImage(
                        imagePath: imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorWidget: Container(color: Colors.black26),
                      ),

                    // Dark gradient at top
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 100,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),

                    // Top Bar info and progress
                    Positioned(
                      top: 24,
                      left: 16,
                      right: 16,
                      child: Column(
                        children: [
                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white24,
                              valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                              minHeight: 3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // User Info
                          Row(
                            children: [
                              _buildOperatorAvatar(
                                email: authorEmail,
                                name: authorName,
                                avatarIdx: avatarIndex,
                                state: Provider.of<EngineState>(context, listen: false),
                                radius: 14,
                                borderColor: themeColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                authorName,
                                style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.white),
                              ),
                              const Spacer(),
                              Text(
                                "TAP TO CLOSE",
                                style: CyberTheme.monospaceStyle(fontSize: 8, color: Colors.white54),
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
        );
      },
    ).then((_) => storyTimer?.cancel());
  }

  void _showUploadStoryModal(BuildContext context, EngineState state, Color themeColor) {
    String? selectedImagePath;
    bool isAvatarStory = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: GlassContainer(
                borderColor: themeColor.withValues(alpha: 0.3),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("BROADCAST 24H OPERATOR STORY", style: CyberTheme.headingStyle(fontSize: 12)),
                      Text(
                        "DISPATCH REAL-TIME OPERATOR HUD SNAPSHOT",
                        style: CyberTheme.monospaceStyle(fontSize: 8, color: themeColor),
                      ),
                      const SizedBox(height: 20),

                      // Image Pick Options
                      Row(
                        children: [
                          // Gallery Button
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final path = await _pickDeviceImage(source: ImageSource.gallery);
                                if (path != null) {
                                  setModalState(() {
                                    selectedImagePath = path;
                                    isAvatarStory = false;
                                  });
                                }
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: (selectedImagePath != null && !isAvatarStory) ? themeColor.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.03),
                                  border: Border.all(
                                    color: (selectedImagePath != null && !isAvatarStory) ? themeColor : Colors.white12,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.photo_library_rounded, color: themeColor, size: 20),
                                    const SizedBox(height: 6),
                                    Text(
                                      "GALLERY",
                                      style: CyberTheme.monospaceStyle(fontSize: 8, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Camera Button
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final path = await _pickDeviceImage(source: ImageSource.camera);
                                if (path != null) {
                                  setModalState(() {
                                    selectedImagePath = path;
                                    isAvatarStory = false;
                                  });
                                }
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.03),
                                  border: Border.all(color: Colors.white12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.camera_alt_rounded, color: themeColor, size: 20),
                                    const SizedBox(height: 6),
                                    Text(
                                      "CAMERA",
                                      style: CyberTheme.monospaceStyle(fontSize: 8, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // 3D Avatar Option
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setModalState(() {
                                  selectedImagePath = "avatar_snapshot";
                                  isAvatarStory = true;
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isAvatarStory ? themeColor.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.03),
                                  border: Border.all(
                                    color: isAvatarStory ? themeColor : Colors.white12,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.person_pin_rounded, color: themeColor, size: 20),
                                    const SizedBox(height: 6),
                                    Text(
                                      "3D AVATAR",
                                      style: CyberTheme.monospaceStyle(fontSize: 8, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Preview Story image
                      if (selectedImagePath != null && !isAvatarStory)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: ResponsiveImage(
                            imagePath: selectedImagePath!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      else if (isAvatarStory)
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            color: const Color(0xFF141A28),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: themeColor.withValues(alpha: 0.4)),
                          ),
                          alignment: Alignment.center,
                          child: BioAvatarCanvas(
                            config: state.activeBioAvatar,
                            size: 150,
                          ),
                        )
                      else
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.02),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Center(
                            child: Text(
                              "CHOOSE MEDIA TO BROADCAST STORY",
                              style: CyberTheme.monospaceStyle(fontSize: 8.5, color: CyberTheme.textMuted),
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),
                      NeonButton(
                        onPressed: () async {
                          if (selectedImagePath == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.redAccent,
                                content: Text(
                                  "PLEASE ATTACH AN IMAGE OR 3D AVATAR FOR YOUR STORY",
                                  style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.white),
                                ),
                              ),
                            );
                            return;
                          }

                          await state.uploadDevgramStory(selectedImagePath!);
                          if (context.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: themeColor,
                                content: Text(
                                  "STORY BROADCASTED TO LIVE DEVGRAM MATRIX",
                                  style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.black),
                                ),
                              ),
                            );
                          }
                        },
                        glowColor: themeColor,
                        gradientColors: [themeColor, themeColor.withValues(alpha: 0.5)],
                        child: Text("BROADCAST STORY", style: CyberTheme.headingStyle(fontSize: 10, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToProfile(BuildContext context, EngineState state, String authorName, String email, int avatarIdx) {
    final op = state.activeOperators.firstWhere(
      (element) => (element["email"] ?? "").toLowerCase().trim() == email.toLowerCase().trim(),
      orElse: () => {
        "name": authorName,
        "email": email,
        "role": "SYSTEM OPERATOR",
        "avatar": avatarIdx.toString(),
        "status": "ONLINE",
        "bio": "Operator synchronized with the live DevGram network.",
        "ping": "12ms",
      },
    );
    state.selectUserProfile(op);
    state.setScreenIndex(15); // Navigate to UserProfileScreen (Index 15)
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<EngineState>(context);
    final themeColor = _getThemeColor(state);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    // Build horizontal stories row
    List<Widget> storyBubbles = [];

    // 1. My Story (Add Story) Button
    storyBubbles.add(
      Padding(
        padding: const EdgeInsets.only(right: 14.0),
        child: Column(
          children: [
            InkWell(
              onTap: () => _showUploadStoryModal(context, state, themeColor),
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: themeColor.withValues(alpha: 0.6), width: 1.5),
                    ),
                  ),
                  _buildOperatorAvatar(
                    email: state.operatorEmail,
                    name: state.operatorName,
                    avatarIdx: state.selectedAvatarIndex,
                    state: state,
                    radius: 24,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: themeColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.black, size: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "My Story",
              style: CyberTheme.monospaceStyle(fontSize: 8, color: themeColor),
            ),
          ],
        ),
      ),
    );

    // 2. Real Active Stories ONLY (No fake generated ones)
    for (var story in state.devgramStories) {
      final author = story["authorName"]?.toString() ?? "OPERATOR";
      final avatar = story["avatarIndex"] ?? 0;
      final authorEmail = story["authorEmail"]?.toString() ?? "";

      storyBubbles.add(
        Padding(
          padding: const EdgeInsets.only(right: 14.0),
          child: Column(
            children: [
              InkWell(
                onTap: () => _showStoryViewer(context, story, themeColor),
                borderRadius: BorderRadius.circular(32),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF00FF88), width: 2),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF00FF88).withValues(alpha: 0.3), blurRadius: 6),
                        ],
                      ),
                    ),
                    _buildOperatorAvatar(
                      email: authorEmail,
                      name: authorNameFrom(author),
                      avatarIdx: avatar,
                      state: state,
                      radius: 24,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                author.length > 9 ? "${author.substring(0, 7)}..." : author,
                style: CyberTheme.monospaceStyle(fontSize: 8, color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
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
                    Text("DEVGRAM CORE", style: CyberTheme.titleStyle(fontSize: isMobile ? 18 : 22)),
                    Text(
                      "LIVE OPERATOR TRANSMISSIONS ONLY • AUTHENTIC GRID LOGS",
                      style: CyberTheme.monospaceStyle(fontSize: 8, color: themeColor),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => state.setScreenIndex(14), // DevChatScreen index
                      icon: Icon(Icons.messenger_outline_rounded, color: themeColor, size: 22),
                      tooltip: "Direct Signals",
                    ),
                    IconButton(
                      onPressed: state.isFetchingPosts
                          ? null
                          : () {
                              state.fetchDevgramPosts();
                              state.fetchDevgramStories();
                            },
                      icon: state.isFetchingPosts
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                            )
                          : Icon(Icons.sync_rounded, color: themeColor, size: 22),
                      tooltip: "Sync Live Network",
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Stories Bubble Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: storyBubbles,
              ),
            ),
            const SizedBox(height: 24),

            // Posts feed
            if (state.isFetchingPosts && state.devgramPosts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
                ),
              )
            else if (state.devgramPosts.isEmpty)
              // Sleek Cyber Empty State
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: themeColor.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: themeColor.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                          border: Border.all(color: themeColor.withValues(alpha: 0.4)),
                        ),
                        child: Icon(Icons.rss_feed_rounded, color: themeColor, size: 36),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        "NO TRANSMISSIONS YET",
                        style: CyberTheme.headingStyle(fontSize: 14, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Real-time grid feed is online. Only authentic posts created by logged-in operators will appear here. No generated or mock content.",
                        style: CyberTheme.bodyStyle(fontSize: 11, color: CyberTheme.textMuted),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      NeonButton(
                        onPressed: () => _showCreatePostModal(context, state, themeColor),
                        glowColor: themeColor,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Text("BROADCAST FIRST TRANSMISSION", style: CyberTheme.headingStyle(fontSize: 9.5, color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.devgramPosts.length,
                itemBuilder: (context, index) {
                  final post = state.devgramPosts[index];
                  final String postId = post["id"] ?? "post_$index";
                  final String author = post["authorName"] ?? "OPERATOR";
                  final String email = post["authorEmail"] ?? "";
                  final int avatarIdx = post["avatarIndex"] ?? 0;
                  final String caption = post["caption"] ?? "";
                  final String imageUrl = post["imageUrl"] ?? "";
                  final List<String> likes = List<String>.from(post["likes"] ?? []);
                  final List<Map<String, dynamic>> comments = List<Map<String, dynamic>>.from(post["comments"] ?? []);
                  final String timestamp = post["timestamp"] ?? "";

                  final isLiked = likes.contains(state.operatorEmail);
                  final isMyPost = email.toLowerCase().trim() == state.operatorEmail.toLowerCase().trim();
                  final commentCtrl = _getCommentController(postId);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    child: GlassContainer(
                      borderColor: themeColor.withValues(alpha: 0.15),
                      padding: const EdgeInsets.all(0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Post Header
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () => _navigateToProfile(context, state, author, email, avatarIdx),
                                  borderRadius: BorderRadius.circular(4),
                                  child: Row(
                                    children: [
                                      _buildOperatorAvatar(
                                        email: email,
                                        name: author,
                                        avatarIdx: avatarIdx,
                                        state: state,
                                        radius: 16,
                                        borderColor: themeColor.withValues(alpha: 0.4),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                author,
                                                style: CyberTheme.monospaceStyle(fontSize: 11, color: Colors.white),
                                              ),
                                              if ((isMyPost && state.isOperatorVerified) ||
                                                  state.activeOperators.any((op) => op["email"] == email && op["is_verified"]?.toString() == "1")) ...[
                                                const SizedBox(width: 4),
                                                const Icon(Icons.verified_rounded, color: Color(0xFF00E5FF), size: 12),
                                              ],
                                            ],
                                          ),
                                          Text(
                                            email,
                                            style: GoogleFonts.spaceGrotesk(fontSize: 8, color: CyberTheme.textMuted),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),

                                // Delete option if my post
                                if (isMyPost)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 16),
                                    tooltip: "Delete Transmission",
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (c) => AlertDialog(
                                          backgroundColor: const Color(0xFF0D1117),
                                          title: Text("PURGE TRANSMISSION?", style: CyberTheme.headingStyle(fontSize: 12, color: Colors.redAccent)),
                                          content: Text("Are you sure you want to permanently delete this post?", style: CyberTheme.bodyStyle(fontSize: 11, color: Colors.white70)),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(c, false),
                                              child: Text("CANCEL", style: CyberTheme.monospaceStyle(fontSize: 9, color: Colors.white54)),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(c, true),
                                              child: Text("PURGE", style: CyberTheme.monospaceStyle(fontSize: 9, color: Colors.redAccent)),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        await state.deleteDevgramPost(postId);
                                      }
                                    },
                                  ),

                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00FF88).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFF00FF88).withValues(alpha: 0.3), width: 0.5),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.fiber_manual_record_rounded, color: Color(0xFF00FF88), size: 6),
                                      const SizedBox(width: 4),
                                      Text(
                                        "AUTHENTIC",
                                        style: CyberTheme.monospaceStyle(fontSize: 7.5, color: const Color(0xFF00FF88)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Post Image / 3D Avatar / Code Box
                          if (imageUrl.isNotEmpty)
                            GestureDetector(
                              onDoubleTap: () {
                                state.likeDevgramPost(postId);
                                setState(() {
                                  _doubleTapHeartVisible[postId] = true;
                                });
                                Future.delayed(const Duration(milliseconds: 600), () {
                                  if (mounted) {
                                    setState(() {
                                      _doubleTapHeartVisible[postId] = false;
                                    });
                                  }
                                });
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (imageUrl == "avatar_snapshot")
                                    Container(
                                      height: 240,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0D1420),
                                        border: Border.symmetric(
                                          horizontal: BorderSide(color: themeColor.withValues(alpha: 0.2), width: 0.5),
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: BioAvatarCanvas(
                                        config: state.activeBioAvatar,
                                        size: 200,
                                      ),
                                    )
                                  else
                                    ResponsiveImage(
                                      imagePath: imageUrl,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorWidget: Container(
                                        height: 200,
                                        color: Colors.white.withValues(alpha: 0.01),
                                        child: Center(
                                          child: Icon(Icons.image_not_supported_rounded, color: themeColor.withValues(alpha: 0.2)),
                                        ),
                                      ),
                                    ),
                                  // Double tap heart pop-up animation
                                  if (_doubleTapHeartVisible[postId] == true)
                                    AnimatedOpacity(
                                      opacity: _doubleTapHeartVisible[postId]! ? 1.0 : 0.0,
                                      duration: const Duration(milliseconds: 150),
                                      child: Icon(
                                        Icons.favorite_rounded,
                                        size: 80,
                                        color: themeColor.withValues(alpha: 0.9),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          else
                            // Text / DevLog Code Container
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF060910),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: themeColor.withValues(alpha: 0.2), width: 0.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.terminal_rounded, size: 12, color: themeColor),
                                      const SizedBox(width: 6),
                                      Text(
                                        "DEVLOG SIGNAL // TRANSMISSION",
                                        style: CyberTheme.monospaceStyle(fontSize: 7.5, color: themeColor),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    caption,
                                    style: GoogleFonts.firaCode(fontSize: 11, color: Colors.white, height: 1.4),
                                  ),
                                ],
                              ),
                            ),

                          // Post Action Buttons
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    color: isLiked ? themeColor : Colors.white70,
                                  ),
                                  onPressed: () => state.likeDevgramPost(postId),
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.only(right: 12),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.mode_comment_outlined, color: Colors.white70),
                                  onPressed: () {},
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.only(right: 12),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.share_outlined, color: Colors.white70),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: themeColor.withValues(alpha: 0.2),
                                        content: Text(
                                          "TRANSMISSION LINK COPIED TO OPERATOR CLIPBOARD",
                                          style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.white),
                                        ),
                                      ),
                                    );
                                  },
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                                const Spacer(),
                                Text(
                                  timestamp.contains('T') ? timestamp.split('T')[0] : timestamp,
                                  style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
                                ),
                              ],
                            ),
                          ),

                          // Likes Counter
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              likes.isEmpty
                                  ? "BE THE FIRST OPERATOR TO SIGNAL"
                                  : likes.length == 1
                                      ? "SIGNALED BY 1 OPERATOR"
                                      : "SIGNALED BY ${likes.length} OPERATORS",
                              style: CyberTheme.monospaceStyle(fontSize: 9, color: themeColor),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Caption Description (if image was present)
                          if (imageUrl.isNotEmpty && caption.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "$author: ",
                                      style: GoogleFonts.shareTechMono(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    TextSpan(
                                      text: caption,
                                      style: GoogleFonts.spaceGrotesk(
                                        color: CyberTheme.textMain,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),

                          // Comments List
                          if (comments.isNotEmpty) ...[
                            const Divider(color: Colors.white10, height: 1),
                            Container(
                              padding: const EdgeInsets.all(12),
                              color: Colors.black.withValues(alpha: 0.12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: comments.map((comm) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6.0),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "${comm['author']}: ",
                                            style: CyberTheme.monospaceStyle(fontSize: 10, color: themeColor),
                                          ),
                                          TextSpan(
                                            text: comm['text'] ?? "",
                                            style: CyberTheme.bodyStyle(fontSize: 11, color: CyberTheme.textMain),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],

                          // Comment Input Box
                          Container(
                            decoration: const BoxDecoration(
                              border: Border(top: BorderSide(color: Colors.white10)),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: commentCtrl,
                                    style: CyberTheme.bodyStyle(fontSize: 11, color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: "LOG FEEDBACK SIGNAL...",
                                      hintStyle: CyberTheme.bodyStyle(fontSize: 10, color: Colors.white24),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    ),
                                    onSubmitted: (val) {
                                      if (val.trim().isNotEmpty) {
                                        state.addCommentToDevgramPost(postId, val.trim());
                                        commentCtrl.clear();
                                      }
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.send_rounded, color: themeColor, size: 16),
                                  onPressed: () {
                                    final text = commentCtrl.text.trim();
                                    if (text.isNotEmpty) {
                                      state.addCommentToDevgramPost(postId, text);
                                      commentCtrl.clear();
                                    }
                                  },
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostModal(context, state, themeColor),
        backgroundColor: themeColor,
        child: const Icon(Icons.add_a_photo_rounded, color: Colors.black),
      ),
    );
  }

  String authorNameFrom(String raw) {
    if (raw.isEmpty) return "OPERATOR";
    return raw;
  }
}
