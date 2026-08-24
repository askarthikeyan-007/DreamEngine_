import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dream_engine_ai/core/state/engine_state.dart';
import 'package:dream_engine_ai/core/theme/cyber_theme.dart';
import 'package:dream_engine_ai/core/widgets/glass_container.dart';
import 'package:dream_engine_ai/core/widgets/neon_button.dart';
import 'package:dream_engine_ai/core/widgets/responsive_image.dart';

class DevGramScreen extends StatefulWidget {
  const DevGramScreen({super.key});

  @override
  State<DevGramScreen> createState() => _DevGramScreenState();
}

class _DevGramScreenState extends State<DevGramScreen> {
  final TextEditingController _commentController = TextEditingController();
  final Map<String, bool> _doubleTapHeartVisible = {}; // Track like pop-ups for posts

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<EngineState>(context, listen: false);
      if (state.devgramPosts.isEmpty) {
        state.fetchDevgramPosts();
      }
      if (state.devgramStories.isEmpty) {
        state.fetchDevgramStories();
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<String?> _pickDeviceImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
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

  void _showCreatePostModal(BuildContext context, EngineState state, Color themeColor) {
    final captionController = TextEditingController();
    String selectedImage = "https://picsum.photos/seed/voxeldev/600/400";
    
    final List<Map<String, String>> presets = [
      {"name": "VOXEL CITY", "url": "https://picsum.photos/seed/voxel/600/400"},
      {"name": "VEHICLE PHYSICS", "url": "https://picsum.photos/seed/racing/600/400"},
      {"name": "NETCODE CLUSTER", "url": "https://picsum.photos/seed/cyber/600/400"},
      {"name": "SOUND WAVEFORM", "url": "https://picsum.photos/seed/synth/600/400"},
    ];

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
                  border: Border(top: BorderSide(color: themeColor.withOpacity(0.3), width: 1.5)),
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
                        "DISPATCH SCREENSHOT OR PIPELINE CODE TO THE DEVGRAM MATRIX",
                        style: CyberTheme.monospaceStyle(fontSize: 8, color: themeColor),
                      ),
                      const SizedBox(height: 20),

                      // Image Selector
                      Text("SELECT PROCEDURAL HUD CAPTURE:", style: CyberTheme.monospaceStyle(fontSize: 9, color: CyberTheme.textMuted)),
                      const SizedBox(height: 10),
                      Row(
                        children: presets.map((preset) {
                          final isSel = selectedImage == preset["url"];
                          return Expanded(
                            child: InkWell(
                              onTap: () {
                                setModalState(() {
                                  selectedImage = preset["url"]!;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSel ? themeColor.withOpacity(0.12) : Colors.white.withOpacity(0.02),
                                  border: Border.all(color: isSel ? themeColor : Colors.white10),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  preset["name"]!,
                                  style: CyberTheme.monospaceStyle(fontSize: 8, color: isSel ? Colors.white : CyberTheme.textMuted),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      // Upload from device button
                      NeonButton(
                        onPressed: () async {
                          final path = await _pickDeviceImage();
                          if (path != null) {
                            setModalState(() {
                              selectedImage = path;
                            });
                          }
                        },
                        glowColor: themeColor,
                        gradientColors: [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.1)],
                        height: 36,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload_file_rounded, color: themeColor, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              "UPLOAD FROM DEVICE",
                              style: CyberTheme.headingStyle(fontSize: 9, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Preview Selected Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ResponsiveImage(
                          imagePath: selectedImage,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Caption
                      TextField(
                        controller: captionController,
                        maxLines: 3,
                        style: CyberTheme.bodyStyle(fontSize: 13, color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "WRITE CAPTION AND ATTACH #HASHTAGS...",
                          hintStyle: CyberTheme.bodyStyle(fontSize: 12, color: Colors.white24),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.3),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: themeColor.withOpacity(0.2)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: themeColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      NeonButton(
                        onPressed: () async {
                          if (captionController.text.trim().isEmpty) return;
                          
                          // Dispatch post
                          await state.createDevgramPost(
                            captionController.text.trim(),
                            selectedImage,
                          );
                          
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: themeColor,
                                content: Text(
                                  "GRID CAPTURE BROADCASTED TO DEVGRAM CHANNELS",
                                  style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.black),
                                ),
                              ),
                            );
                          }
                        },
                        glowColor: themeColor,
                        gradientColors: [themeColor, themeColor.withOpacity(0.5)],
                        child: Text("TRANSMIT PIPELINE RECORD", style: CyberTheme.headingStyle(fontSize: 12, color: Colors.white)),
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
                    // Full screen story image
                    ResponsiveImage(
                      imagePath: story["imageUrl"] ?? "",
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
                            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
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
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: themeColor.withOpacity(0.12),
                                child: Icon(Icons.person_pin_rounded, color: themeColor, size: 14),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                story["authorName"] ?? "UNKNOWN",
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
    final List<Map<String, String>> presets = [
      {"name": "CYBER WORLD STORY", "url": "https://picsum.photos/seed/cyberstory/600/1000"},
      {"name": "VOXEL CITY STORY", "url": "https://picsum.photos/seed/voxelstory/600/1000"},
      {"name": "RACING SIM STORY", "url": "https://picsum.photos/seed/racingstory/600/1000"},
      {"name": "MULTIPLATE LOG STORY", "url": "https://picsum.photos/seed/synthstory/600/1000"},
    ];
    String selectedUrl = presets[0]["url"]!;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: GlassContainer(
                borderColor: themeColor.withOpacity(0.3),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("TRANSMIT COGNITIVE GRID STORY", style: CyberTheme.headingStyle(fontSize: 12)),
                      Text(
                        "DISPATCH HUD LOG STORY COMPILATION SEGMENT",
                        style: CyberTheme.monospaceStyle(fontSize: 8, color: themeColor),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: presets.map((preset) {
                          final isSel = selectedUrl == preset["url"];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: InkWell(
                              onTap: () {
                                setModalState(() {
                                  selectedUrl = preset["url"]!;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSel ? themeColor.withOpacity(0.12) : Colors.white.withOpacity(0.02),
                                  border: Border.all(color: isSel ? themeColor : Colors.white10),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.photo_rounded, color: isSel ? themeColor : Colors.white54, size: 16),
                                    const SizedBox(width: 12),
                                    Text(
                                      preset["name"]!,
                                      style: CyberTheme.monospaceStyle(fontSize: 9, color: isSel ? Colors.white : CyberTheme.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      // Upload from device button
                      NeonButton(
                        onPressed: () async {
                          final path = await _pickDeviceImage();
                          if (path != null) {
                            setModalState(() {
                              selectedUrl = path;
                            });
                          }
                        },
                        glowColor: themeColor,
                        gradientColors: [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.1)],
                        height: 36,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload_file_rounded, color: themeColor, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              "UPLOAD FROM DEVICE",
                              style: CyberTheme.headingStyle(fontSize: 9, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Preview Story image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ResponsiveImage(
                          imagePath: selectedUrl,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 20),
                      NeonButton(
                        onPressed: () async {
                          await state.uploadDevgramStory(selectedUrl);
                          if (context.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: themeColor,
                                content: Text(
                                  "STORY UPLOADED TO OPERATORS MATRIX NODE",
                                  style: CyberTheme.monospaceStyle(fontSize: 10, color: Colors.black),
                                ),
                              ),
                            );
                          }
                        },
                        glowColor: themeColor,
                        gradientColors: [themeColor, themeColor.withOpacity(0.5)],
                        child: Text("TRANSMIT STORY", style: CyberTheme.headingStyle(fontSize: 10, color: Colors.white)),
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
        "role": "SYSTEM CODER",
        "avatar": avatarIdx.toString(),
        "status": "ONLINE",
        "bio": "Dossier synchronized from secure memory registry.",
        "ping": "15ms",
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

    final avatarIcons = [
      Icons.blur_on_rounded,
      Icons.face_retouching_natural_rounded,
      Icons.precision_manufacturing_rounded,
      Icons.person_pin_rounded,
    ];

    // Build horizontal stories row including "Add Story" option and dynamic stories
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
                      border: Border.all(color: themeColor.withOpacity(0.5), width: 1.5),
                    ),
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white.withOpacity(0.04),
                    child: Icon(Icons.add_rounded, color: themeColor, size: 24),
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

    // 2. Active Stories or fallbacks
    if (state.devgramStories.isNotEmpty) {
      for (var story in state.devgramStories) {
        final author = story["authorName"] ?? "UNKNOWN";
        final avatar = story["avatarIndex"] ?? 0;
        final authorEmail = story["authorEmail"] ?? "";
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
                            BoxShadow(color: const Color(0xFF00FF88).withOpacity(0.25), blurRadius: 6),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white.withOpacity(0.04),
                        child: (authorEmail == state.operatorEmail && state.customProfileImagePath != null)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: ResponsiveImage(
                                  imagePath: state.customProfileImagePath!,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(avatarIcons[avatar % avatarIcons.length], color: Colors.white, size: 20),
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
    } else {
      // Fallback bubbles matching active operators
      for (var op in state.activeOperators) {
        final name = op["name"] ?? "UNKNOWN";
        final avatarIdx = int.tryParse(op["avatar"] ?? "0") ?? 0;
        final email = op["email"] ?? "";
        if (email == state.operatorEmail) continue;

        storyBubbles.add(
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    // Launch mock story player
                    final mockStory = {
                      "authorName": name,
                      "imageUrl": "https://picsum.photos/seed/${name}story/600/1000",
                    };
                    _showStoryViewer(context, mockStory, themeColor);
                  },
                  borderRadius: BorderRadius.circular(32),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: themeColor.withOpacity(0.4), width: 1.5),
                        ),
                      ),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white.withOpacity(0.03),
                        child: Icon(avatarIcons[avatarIdx % avatarIcons.length], color: CyberTheme.textMuted, size: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  name.length > 9 ? "${name.substring(0, 7)}..." : name,
                  style: CyberTheme.monospaceStyle(fontSize: 8, color: Colors.white70),
                ),
              ],
            ),
          ),
        );
      }
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
                      "CONNECTING OPERATORS WORLDWIDE IN PROCEDURAL CHANNELS",
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
                      onPressed: state.isFetchingPosts ? null : () {
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
                      tooltip: "Sync Social Nodes",
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

            // Scrollable posts feed
            if (state.isFetchingPosts && state.devgramPosts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
                ),
              )
            else if (state.devgramPosts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Text("NO SIGNALS IN DEVGRAM NODE.", style: CyberTheme.monospaceStyle(color: CyberTheme.textMuted)),
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
                  final String author = post["authorName"] ?? "UNKNOWN";
                  final String email = post["authorEmail"] ?? "";
                  final int avatarIdx = post["avatarIndex"] ?? 0;
                  final String caption = post["caption"] ?? "";
                  final String imageUrl = post["imageUrl"] ?? "";
                  final List<String> likes = List<String>.from(post["likes"] ?? []);
                  final List<Map<String, dynamic>> comments = List<Map<String, dynamic>>.from(post["comments"] ?? []);
                  final String timestamp = post["timestamp"] ?? "";

                  final isLiked = likes.contains(state.operatorEmail);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    child: GlassContainer(
                      borderColor: themeColor.withOpacity(0.15),
                      padding: const EdgeInsets.all(0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Post Header (links to profile explorer)
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () => _navigateToProfile(context, state, author, email, avatarIdx),
                                  borderRadius: BorderRadius.circular(4),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: themeColor.withOpacity(0.1),
                                        child: (email == state.operatorEmail && state.customProfileImagePath != null)
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(16),
                                                child: ResponsiveImage(
                                                  imagePath: state.customProfileImagePath!,
                                                  width: 32,
                                                  height: 32,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Icon(avatarIcons[avatarIdx % avatarIcons.length], color: themeColor, size: 16),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            author,
                                            style: CyberTheme.monospaceStyle(fontSize: 11, color: Colors.white),
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
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.04),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.link_rounded, color: Colors.white30, size: 10),
                                      const SizedBox(width: 4),
                                      Text(
                                        "CONNECTED",
                                        style: CyberTheme.monospaceStyle(fontSize: 8, color: Colors.white30),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Post Image (with Double-Tap support)
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
                                  ResponsiveImage(
                                    imagePath: imageUrl,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorWidget: Container(
                                      height: 200,
                                      color: Colors.white.withOpacity(0.01),
                                      child: Center(
                                        child: Icon(Icons.image_not_supported_rounded, color: themeColor.withOpacity(0.2)),
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
                                        color: themeColor.withOpacity(0.9),
                                      ),
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
                                        backgroundColor: themeColor.withOpacity(0.2),
                                        content: Text(
                                          "COGNITIVE LOG DEEP-LINK COMPILING TO CLIPBOARD",
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
                                  timestamp.split('T')[0],
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
                                  ? "BE THE FIRST TO SIGNAL DISPATCH"
                                  : likes.length == 1
                                      ? "SIGNALED BY 1 OPERATOR"
                                      : "SIGNALED BY ${likes.length} OPERATORS",
                              style: CyberTheme.monospaceStyle(fontSize: 9, color: themeColor),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Caption Description
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
                              color: Colors.black.withOpacity(0.12),
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
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
                                        state.addCommentToDevgramPost(postId, val);
                                      }
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.send_rounded, color: themeColor, size: 16),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: themeColor.withOpacity(0.2),
                                        content: Text(
                                          "TAP RETURN/ENTER KEY ON KEYBOARD TO LOG FEEDBACK SIGNAL",
                                          style: CyberTheme.monospaceStyle(fontSize: 9, color: Colors.white),
                                        ),
                                      ),
                                    );
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
}
