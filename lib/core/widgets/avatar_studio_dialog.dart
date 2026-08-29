import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dream_engine_ai/core/models/bio_avatar.dart';
import 'package:dream_engine_ai/core/state/engine_state.dart';
import 'package:dream_engine_ai/core/theme/cyber_theme.dart';
import 'package:dream_engine_ai/core/widgets/glass_container.dart';
import 'package:dream_engine_ai/core/widgets/neon_button.dart';
import 'package:dream_engine_ai/core/widgets/bio_avatar_canvas.dart';

class AvatarStudioDialog extends StatefulWidget {
  final BioAvatarConfig initialConfig;

  const AvatarStudioDialog({
    super.key,
    required this.initialConfig,
  });

  static Future<BioAvatarConfig?> show(BuildContext context, BioAvatarConfig current) {
    return showDialog<BioAvatarConfig>(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => AvatarStudioDialog(initialConfig: current),
    );
  }

  @override
  State<AvatarStudioDialog> createState() => _AvatarStudioDialogState();
}

class _AvatarStudioDialogState extends State<AvatarStudioDialog> with SingleTickerProviderStateMixin {
  late BioAvatarConfig _avatar;
  int _currentTab = 0; // 0: Presets, 1: Face/Skin, 2: Hair/Beard, 3: Outfit, 4: Accessories
  double _yaw = 0.0;
  double _pitch = 0.0;
  late AnimationController _idleController;

  final List<String> _tabs = [
    "PRESETS",
    "SKIN & EYES",
    "HAIR & BEARD",
    "OUTFIT",
    "ACCESSORIES",
  ];

  @override
  void initState() {
    super.initState();
    _avatar = widget.initialConfig;
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _idleController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _yaw = (_yaw + details.delta.dx * 0.015).clamp(-1.0, 1.0);
      _pitch = (_pitch + details.delta.dy * 0.015).clamp(-0.6, 0.6);
    });
  }

  void _resetView() {
    setState(() {
      _yaw = 0.0;
      _pitch = 0.0;
    });
  }

  void _randomize() {
    setState(() {
      _avatar = BioAvatarConfig.randomize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final bool isMobile = width < 780;
    final themeColor = CyberTheme.neonBlue;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 32,
        vertical: isMobile ? 16 : 28,
      ),
      child: GlassContainer(
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        borderColor: themeColor.withOpacity(0.3),
        child: Container(
          width: isMobile ? double.infinity : 920,
          height: isMobile ? height * 0.88 : 640,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: themeColor.withOpacity(0.3)),
                        ),
                        child: Icon(Icons.face_retouching_natural_rounded, color: themeColor, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "3D BIO-AVATAR CREATOR STUDIO",
                            style: CyberTheme.headingStyle(fontSize: 13, color: Colors.white),
                          ),
                          Text(
                            "CUSTOMIZE TRAITS & VECTOR MESH RENDERING",
                            style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // AI Randomize Button
                      InkWell(
                        onTap: _randomize,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.purpleAccent.withOpacity(0.15),
                            border: Border.all(color: Colors.purpleAccent.withOpacity(0.4)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_awesome_rounded, color: Colors.purpleAccent, size: 12),
                              const SizedBox(width: 6),
                              Text(
                                "AI RANDOMIZE",
                                style: CyberTheme.monospaceStyle(fontSize: 9, color: Colors.white).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 12),

              // Main body
              Expanded(
                child: isMobile
                    ? SingleChildScrollView(
                        child: Column(
                          children: [
                            _build3DViewport(themeColor, isMobile),
                            const SizedBox(height: 16),
                            _buildCustomizationPanel(themeColor),
                          ],
                        ),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left 3D Viewport
                          Expanded(
                            flex: 5,
                            child: _build3DViewport(themeColor, isMobile),
                          ),
                          const SizedBox(width: 16),
                          // Right Traits Panel
                          Expanded(
                            flex: 6,
                            child: _buildCustomizationPanel(themeColor),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 12),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 12),

              // Footer Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _resetView,
                    icon: const Icon(Icons.refresh_rounded, size: 14, color: Colors.white54),
                    label: Text(
                      "RESET 3D VIEW",
                      style: CyberTheme.monospaceStyle(fontSize: 9, color: Colors.white70),
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("CANCEL", style: CyberTheme.monospaceStyle(fontSize: 10, color: CyberTheme.textMuted)),
                      ),
                      const SizedBox(width: 8),
                      NeonButton(
                        onPressed: () {
                          Navigator.pop(context, _avatar);
                        },
                        glowColor: const Color(0xFF00FF88),
                        gradientColors: [const Color(0xFF00FF88), const Color(0xFF00B0FF)],
                        borderRadius: 6,
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.black, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              "APPLY TO OPERATOR DOSSIER",
                              style: CyberTheme.headingStyle(fontSize: 10, color: Colors.black).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build3DViewport(Color themeColor, bool isMobile) {
    return Container(
      height: isMobile ? 240 : double.infinity,
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circular grid lines
          CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: _RadarGridPainter(color: themeColor.withOpacity(0.1)),
          ),

          // Interactive 3D avatar canvas
          GestureDetector(
            onPanUpdate: _onPanUpdate,
            child: AnimatedBuilder(
              animation: _idleController,
              builder: (context, _) {
                final double idleFloat = sin(_idleController.value * 2 * pi) * 0.03;
                return Center(
                  child: BioAvatarCanvas(
                    config: _avatar,
                    yaw: _yaw,
                    pitch: _pitch + idleFloat,
                    size: isMobile ? 210 : 280,
                    showBackground: true,
                  ),
                );
              },
            ),
          ),

          // 3D Orbit Drag Hint Badge
          Positioned(
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                border: Border.all(color: Colors.white24, width: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.threed_rotation_rounded, color: themeColor, size: 12),
                  const SizedBox(width: 6),
                  Text(
                    "DRAG TO ROTATE 360°",
                    style: CyberTheme.monospaceStyle(fontSize: 8, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          // Active Avatar Name Badge
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.15),
                border: Border.all(color: themeColor.withOpacity(0.4), width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _avatar.name.toUpperCase(),
                style: CyberTheme.monospaceStyle(fontSize: 8, color: Colors.white).copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizationPanel(Color themeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Category Tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_tabs.length, (idx) {
              final isSel = _currentTab == idx;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: InkWell(
                  onTap: () => setState(() => _currentTab = idx),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSel ? themeColor.withOpacity(0.2) : Colors.white.withOpacity(0.04),
                      border: Border.all(color: isSel ? themeColor : Colors.white10),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _tabs[idx],
                      style: CyberTheme.monospaceStyle(
                        fontSize: 8.5,
                        color: isSel ? Colors.white : CyberTheme.textMuted,
                      ).copyWith(fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),

        // Tab Content
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black26,
              border: Border.all(color: Colors.white10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildSelectedTabContent(themeColor),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedTabContent(Color themeColor) {
    switch (_currentTab) {
      case 0:
        return _buildPresetsTab(themeColor);
      case 1:
        return _buildSkinAndEyesTab(themeColor);
      case 2:
        return _buildHairAndBeardTab(themeColor);
      case 3:
        return _buildOutfitTab(themeColor);
      case 4:
        return _buildAccessoriesTab(themeColor);
      default:
        return _buildPresetsTab(themeColor);
    }
  }

  // 0. Presets Tab (7 distinct archetypes from the 1st picture)
  Widget _buildPresetsTab(Color themeColor) {
    final presets = BioAvatarConfig.presets;
    return ListView.builder(
      itemCount: presets.length,
      itemBuilder: (context, idx) {
        final p = presets[idx];
        final isSel = _avatar.id == p.id;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              setState(() {
                _avatar = p;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSel ? themeColor.withOpacity(0.12) : Colors.white.withOpacity(0.02),
                border: Border.all(color: isSel ? themeColor : Colors.white10, width: isSel ? 1.5 : 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // Mini Avatar thumbnail
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black38,
                      border: Border.all(color: isSel ? themeColor : Colors.white24),
                    ),
                    child: ClipOval(
                      child: BioAvatarCanvas(
                        config: p,
                        size: 44,
                        showBackground: false,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name.toUpperCase(),
                          style: CyberTheme.headingStyle(fontSize: 10, color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Style: ${p.clothingStyle.replaceAll('_', ' ')} // Hair: ${p.hairStyle.replaceAll('_', ' ')}",
                          style: CyberTheme.monospaceStyle(fontSize: 8, color: CyberTheme.textMuted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isSel)
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF00FF88), size: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 1. Skin & Eyes Tab
  Widget _buildSkinAndEyesTab(Color themeColor) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("SKIN TONE COMPLEXION"),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: BioAvatarConfig.skinTones.map((color) {
              final isSel = _avatar.skinTone.value == color.value;
              return InkWell(
                onTap: () => setState(() => _avatar = _avatar.copyWith(skinTone: color)),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: isSel ? themeColor : Colors.white24, width: isSel ? 2.5 : 1),
                    boxShadow: isSel ? [BoxShadow(color: themeColor.withOpacity(0.5), blurRadius: 6)] : null,
                  ),
                  child: isSel ? const Icon(Icons.check, size: 16, color: Colors.black87) : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 12),

          _buildSectionHeader("EYE IRIS COLOR"),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: BioAvatarConfig.eyeColors.map((color) {
              final isSel = _avatar.eyeColor.value == color.value;
              return InkWell(
                onTap: () => setState(() => _avatar = _avatar.copyWith(eyeColor: color)),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: isSel ? themeColor : Colors.white24, width: isSel ? 2 : 1),
                  ),
                  child: isSel ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 12),

          _buildSectionHeader("FACIAL EXPRESSION"),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              {"id": "smile", "label": "WARM SMILE"},
              {"id": "grin", "label": "CONFIDENT GRIN"},
              {"id": "laugh", "label": "JOYFUL LAUGH"},
              {"id": "chill", "label": "CALM FOCUS"},
            ].map((exp) {
              final isSel = _avatar.expression == exp["id"];
              return ChoiceChip(
                label: Text(exp["label"]!, style: CyberTheme.monospaceStyle(fontSize: 8, color: isSel ? Colors.white : CyberTheme.textMuted)),
                selected: isSel,
                selectedColor: themeColor.withOpacity(0.3),
                backgroundColor: Colors.white.withOpacity(0.04),
                side: BorderSide(color: isSel ? themeColor : Colors.white10),
                onSelected: (val) => setState(() => _avatar = _avatar.copyWith(expression: exp["id"])),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 2. Hair & Beard Tab
  Widget _buildHairAndBeardTab(Color themeColor) {
    final hairOptions = [
      {"id": "skater_cap", "label": "Backwards Skate Cap"},
      {"id": "short_braids", "label": "Cornrow Braids / Dreads"},
      {"id": "ponytail", "label": "Sleek Ponytail & Fringe"},
      {"id": "teal_undercut", "label": "Modern Rocker Undercut"},
      {"id": "blonde_waves", "label": "Long Flowing Waves"},
      {"id": "hijab", "label": "Silk Hijab Wrap"},
      {"id": "grey_wavy", "label": "Distinguished Bob Waves"},
      {"id": "curly_afro", "label": "Voluminous Curls"},
      {"id": "buzz_cut", "label": "Clean Buzz Fade"},
    ];

    final beardOptions = [
      {"id": "none", "label": "Clean Shaven"},
      {"id": "goatee", "label": "Trimmed Goatee"},
      {"id": "full_beard", "label": "Full Contoured Beard"},
      {"id": "mustache", "label": "Classic Mustache"},
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("HAIRSTYLE & COIFFURE"),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: hairOptions.map((h) {
              final isSel = _avatar.hairStyle == h["id"];
              return ChoiceChip(
                label: Text(h["label"]!, style: CyberTheme.monospaceStyle(fontSize: 8, color: isSel ? Colors.white : CyberTheme.textMuted)),
                selected: isSel,
                selectedColor: themeColor.withOpacity(0.3),
                backgroundColor: Colors.white.withOpacity(0.04),
                side: BorderSide(color: isSel ? themeColor : Colors.white10),
                onSelected: (val) {
                  final String headwear = h["id"] == 'skater_cap' 
                      ? 'backward_cap' 
                      : (h["id"] == 'hijab' ? 'hijab_wrap' : 'none');
                  setState(() {
                    _avatar = _avatar.copyWith(
                      hairStyle: h["id"],
                      headwear: headwear,
                    );
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 12),

          _buildSectionHeader("HAIR COLOR TINT"),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: BioAvatarConfig.hairColors.map((color) {
              final isSel = _avatar.hairColor.value == color.value;
              return InkWell(
                onTap: () => setState(() => _avatar = _avatar.copyWith(
                  hairColor: color,
                  facialHairColor: color,
                )),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: isSel ? themeColor : Colors.white24, width: isSel ? 2 : 1),
                  ),
                  child: isSel ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 12),

          _buildSectionHeader("FACIAL HAIR & BEARDS"),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: beardOptions.map((b) {
              final isSel = _avatar.facialHair == b["id"];
              return ChoiceChip(
                label: Text(b["label"]!, style: CyberTheme.monospaceStyle(fontSize: 8, color: isSel ? Colors.white : CyberTheme.textMuted)),
                selected: isSel,
                selectedColor: themeColor.withOpacity(0.3),
                backgroundColor: Colors.white.withOpacity(0.04),
                side: BorderSide(color: isSel ? themeColor : Colors.white10),
                onSelected: (val) => setState(() => _avatar = _avatar.copyWith(facialHair: b["id"])),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 3. Outfit Tab
  Widget _buildOutfitTab(Color themeColor) {
    final outfitOptions = [
      {"id": "flannel_plaid", "label": "Red Plaid Flannel & Undershirt"},
      {"id": "navy_suit", "label": "Executive Tailored Navy Suit"},
      {"id": "hoodie_dress", "label": "Dusty Rose Hoodie Dress"},
      {"id": "leather_jacket", "label": "Biker Leather Jacket & Zip"},
      {"id": "hijab_robe", "label": "Silk Abaya Robe"},
      {"id": "knit_cardigan", "label": "Magenta Cardigan & Scarf"},
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("WARDROBE & APPAREL STYLE"),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: outfitOptions.map((o) {
              final isSel = _avatar.clothingStyle == o["id"];
              return ChoiceChip(
                label: Text(o["label"]!, style: CyberTheme.monospaceStyle(fontSize: 8, color: isSel ? Colors.white : CyberTheme.textMuted)),
                selected: isSel,
                selectedColor: themeColor.withOpacity(0.3),
                backgroundColor: Colors.white.withOpacity(0.04),
                side: BorderSide(color: isSel ? themeColor : Colors.white10),
                onSelected: (val) => setState(() => _avatar = _avatar.copyWith(clothingStyle: o["id"])),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 12),

          _buildSectionHeader("PRIMARY FABRIC COLOR"),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: BioAvatarConfig.outfitColors.map((color) {
              final isSel = _avatar.clothingColor.value == color.value;
              return InkWell(
                onTap: () => setState(() => _avatar = _avatar.copyWith(clothingColor: color)),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: isSel ? Colors.white : Colors.white24, width: isSel ? 2 : 1),
                  ),
                  child: isSel ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 4. Accessories Tab
  Widget _buildAccessoriesTab(Color themeColor) {
    final glassesOptions = [
      {"id": "none", "label": "No Eyewear"},
      {"id": "black_frames", "label": "Modern Black Nerd Frames"},
      {"id": "cyber_visor", "label": "Cyber Neon HUD Visor"},
    ];

    final headwearOptions = [
      {"id": "none", "label": "No Headwear"},
      {"id": "backward_cap", "label": "Backwards Baseball Cap"},
      {"id": "hijab_wrap", "label": "Silk Modest Hijab Wrap"},
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("EYEWEAR & GLASSES"),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: glassesOptions.map((g) {
              final isSel = _avatar.glasses == g["id"];
              return ChoiceChip(
                label: Text(g["label"]!, style: CyberTheme.monospaceStyle(fontSize: 8, color: isSel ? Colors.white : CyberTheme.textMuted)),
                selected: isSel,
                selectedColor: themeColor.withOpacity(0.3),
                backgroundColor: Colors.white.withOpacity(0.04),
                side: BorderSide(color: isSel ? themeColor : Colors.white10),
                onSelected: (val) => setState(() => _avatar = _avatar.copyWith(glasses: g["id"])),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 12),

          _buildSectionHeader("HEADWEAR & WRAPS"),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: headwearOptions.map((h) {
              final isSel = _avatar.headwear == h["id"];
              return ChoiceChip(
                label: Text(h["label"]!, style: CyberTheme.monospaceStyle(fontSize: 8, color: isSel ? Colors.white : CyberTheme.textMuted)),
                selected: isSel,
                selectedColor: themeColor.withOpacity(0.3),
                backgroundColor: Colors.white.withOpacity(0.04),
                side: BorderSide(color: isSel ? themeColor : Colors.white10),
                onSelected: (val) {
                  setState(() {
                    _avatar = _avatar.copyWith(
                      headwear: h["id"],
                      headwearColor: h["id"] == 'backward_cap' ? const Color(0xFF212121) : const Color(0xFFF48FB1),
                    );
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 10, color: CyberTheme.neonBlue),
        const SizedBox(width: 6),
        Text(
          title,
          style: CyberTheme.headingStyle(fontSize: 9, color: Colors.white).copyWith(letterSpacing: 1.1),
        ),
      ],
    );
  }
}

class _RadarGridPainter extends CustomPainter {
  final Color color;

  _RadarGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    final center = Offset(size.width / 2, size.height / 2);
    final maxR = min(size.width, size.height) * 0.45;

    canvas.drawCircle(center, maxR * 0.4, paint);
    canvas.drawCircle(center, maxR * 0.75, paint);
    canvas.drawCircle(center, maxR, paint);

    canvas.drawLine(Offset(center.dx - maxR, center.dy), Offset(center.dx + maxR, center.dy), paint);
    canvas.drawLine(Offset(center.dx, center.dy - maxR), Offset(center.dx, center.dy + maxR), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
