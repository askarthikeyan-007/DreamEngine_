import 'dart:math';
import 'package:flutter/material.dart';

class BioAvatarConfig {
  final String id;
  final String name;
  final String gender; // 'male', 'female', 'neutral'
  final Color skinTone;
  final String hairStyle; // 'skater_cap', 'short_braids', 'ponytail', 'teal_undercut', 'blonde_waves', 'hijab', 'grey_wavy', 'curly_afro', 'buzz_cut'
  final Color hairColor;
  final String eyeStyle;
  final Color eyeColor;
  final String expression; // 'smile', 'grin', 'laugh', 'chill', 'wink'
  final String facialHair; // 'none', 'goatee', 'full_beard', 'mustache', 'stubble'
  final Color facialHairColor;
  final String clothingStyle; // 'flannel_plaid', 'navy_suit', 'hoodie_dress', 'leather_jacket', 'hijab_robe', 'knit_cardigan', 'cyber_armor'
  final Color clothingColor;
  final Color secondaryColor;
  final String glasses; // 'none', 'black_frames', 'sunglasses', 'cyber_visor', 'round_frames'
  final String headwear; // 'none', 'backward_cap', 'hijab_wrap', 'beanie', 'cyber_headset'
  final Color headwearColor;

  const BioAvatarConfig({
    required this.id,
    required this.name,
    this.gender = 'male',
    this.skinTone = const Color(0xFFECC0A0),
    this.hairStyle = 'skater_cap',
    this.hairColor = const Color(0xFF2B1D14),
    this.eyeStyle = 'smile',
    this.eyeColor = const Color(0xFF3B2F2F),
    this.expression = 'smile',
    this.facialHair = 'goatee',
    this.facialHairColor = const Color(0xFF2B1D14),
    this.clothingStyle = 'flannel_plaid',
    this.clothingColor = const Color(0xFFB71C1C),
    this.secondaryColor = const Color(0xFF424242),
    this.glasses = 'black_frames',
    this.headwear = 'backward_cap',
    this.headwearColor = const Color(0xFF212121),
  });

  BioAvatarConfig copyWith({
    String? id,
    String? name,
    String? gender,
    Color? skinTone,
    String? hairStyle,
    Color? hairColor,
    String? eyeStyle,
    Color? eyeColor,
    String? expression,
    String? facialHair,
    Color? facialHairColor,
    String? clothingStyle,
    Color? clothingColor,
    Color? secondaryColor,
    String? glasses,
    String? headwear,
    Color? headwearColor,
  }) {
    return BioAvatarConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      skinTone: skinTone ?? this.skinTone,
      hairStyle: hairStyle ?? this.hairStyle,
      hairColor: hairColor ?? this.hairColor,
      eyeStyle: eyeStyle ?? this.eyeStyle,
      eyeColor: eyeColor ?? this.eyeColor,
      expression: expression ?? this.expression,
      facialHair: facialHair ?? this.facialHair,
      facialHairColor: facialHairColor ?? this.facialHairColor,
      clothingStyle: clothingStyle ?? this.clothingStyle,
      clothingColor: clothingColor ?? this.clothingColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      glasses: glasses ?? this.glasses,
      headwear: headwear ?? this.headwear,
      headwearColor: headwearColor ?? this.headwearColor,
    );
  }

  // Pre-configured avatars matching the exact 7 characters in the reference picture
  static List<BioAvatarConfig> get presets => [
    // 1. Skater Leo (Glasses, backward cap, goatee, red flannel plaid shirt)
    const BioAvatarConfig(
      id: 'skater_leo',
      name: 'Skater Leo',
      gender: 'male',
      skinTone: Color(0xFFE8BD9B),
      hairStyle: 'skater_cap',
      hairColor: Color(0xFF2E1C14),
      eyeColor: Color(0xFF382319),
      expression: 'smile',
      facialHair: 'goatee',
      facialHairColor: Color(0xFF2E1C14),
      clothingStyle: 'flannel_plaid',
      clothingColor: Color(0xFFB71C1C), // Crimson Red Plaid
      secondaryColor: Color(0xFF212121),
      glasses: 'black_frames',
      headwear: 'backward_cap',
      headwearColor: Color(0xFF212121),
    ),
    // 2. Executive Marcus (Short dreads/braids, neat full beard, navy suit)
    const BioAvatarConfig(
      id: 'exec_marcus',
      name: 'Executive Marcus',
      gender: 'male',
      skinTone: Color(0xFF704428),
      hairStyle: 'short_braids',
      hairColor: Color(0xFF1A1A1A),
      eyeColor: Color(0xFF261810),
      expression: 'smile',
      facialHair: 'full_beard',
      facialHairColor: Color(0xFF1A1A1A),
      clothingStyle: 'navy_suit',
      clothingColor: Color(0xFF1A2A5E), // Navy Blue Tailored Suit
      secondaryColor: Color(0xFFFFFFFF),
      glasses: 'none',
      headwear: 'none',
      headwearColor: Colors.transparent,
    ),
    // 3. Casual Maya (Ponytail & bangs, rosy hoodie dress, warm smile)
    const BioAvatarConfig(
      id: 'casual_maya',
      name: 'Casual Maya',
      gender: 'female',
      skinTone: Color(0xFFFDE8DC),
      hairStyle: 'ponytail',
      hairColor: Color(0xFF2E1C14),
      eyeColor: Color(0xFF38251C),
      expression: 'laugh',
      facialHair: 'none',
      facialHairColor: Colors.transparent,
      clothingStyle: 'hoodie_dress',
      clothingColor: Color(0xFFBA7A7E), // Dusty Rose Pink Hoodie
      secondaryColor: Color(0xFFECEFF1),
      glasses: 'none',
      headwear: 'none',
      headwearColor: Colors.transparent,
    ),
    // 4. Cyber Punk Kai (Teal rocker fade, black leather biker jacket)
    const BioAvatarConfig(
      id: 'punk_kai',
      name: 'Cyber Punk Kai',
      gender: 'male',
      skinTone: Color(0xFFE5BFA4),
      hairStyle: 'teal_undercut',
      hairColor: Color(0xFF009688), // Cyber Teal
      eyeColor: Color(0xFF2C241E),
      expression: 'grin',
      facialHair: 'none',
      facialHairColor: Colors.transparent,
      clothingStyle: 'leather_jacket',
      clothingColor: Color(0xFF1E1E24), // Biker Black Leather
      secondaryColor: Color(0xFFE0E0E0),
      glasses: 'none',
      headwear: 'none',
      headwearColor: Colors.transparent,
    ),
    // 5. Blonde Sophia (Flowing golden waves, patterned scarf & cardigan)
    const BioAvatarConfig(
      id: 'blonde_sophia',
      name: 'Blonde Sophia',
      gender: 'female',
      skinTone: Color(0xFFFFF0E6),
      hairStyle: 'blonde_waves',
      hairColor: Color(0xFFF7D57F), // Warm Golden Blonde
      eyeColor: Color(0xFF2962FF), // Blue eyes
      expression: 'smile',
      facialHair: 'none',
      facialHairColor: Colors.transparent,
      clothingStyle: 'knit_cardigan',
      clothingColor: Color(0xFFC2185B), // Magenta & Scarf
      secondaryColor: Color(0xFFFFF8E1),
      glasses: 'none',
      headwear: 'none',
      headwearColor: Colors.transparent,
    ),
    // 6. Elegant Aisha (Rose pink hijab wrap, modest steel blue gown)
    const BioAvatarConfig(
      id: 'hijab_aisha',
      name: 'Elegant Aisha',
      gender: 'female',
      skinTone: Color(0xFFE0AF88),
      hairStyle: 'hijab',
      hairColor: Color(0xFF1E1E1E),
      eyeColor: Color(0xFF332014),
      expression: 'smile',
      facialHair: 'none',
      facialHairColor: Colors.transparent,
      clothingStyle: 'hijab_robe',
      clothingColor: Color(0xFF455A64), // Steel Blue Abaya
      secondaryColor: Color(0xFFF48FB1),
      glasses: 'none',
      headwear: 'hijab_wrap',
      headwearColor: Color(0xFFF48FB1), // Rose Pink Hijab
    ),
    // 7. Distinguished Elena (Silver wavy bob, warm magenta turtleneck)
    const BioAvatarConfig(
      id: 'elder_elena',
      name: 'Distinguished Elena',
      gender: 'female',
      skinTone: Color(0xFFE2B799),
      hairStyle: 'grey_wavy',
      hairColor: Color(0xFF9E9E9E), // Platinum Silver Fox
      eyeColor: Color(0xFF3E2723),
      expression: 'smile',
      facialHair: 'none',
      facialHairColor: Colors.transparent,
      clothingStyle: 'knit_cardigan',
      clothingColor: Color(0xFFAD1457), // Deep Rose Magenta
      secondaryColor: Color(0xFFECEFF1),
      glasses: 'none',
      headwear: 'none',
      headwearColor: Colors.transparent,
    ),
  ];

  static List<Color> get skinTones => const [
    Color(0xFFFFF0E6), // Porcelain Light
    Color(0xFFFDE8DC), // Fair Warm
    Color(0xFFE8BD9B), // Natural Beige
    Color(0xFFE0AF88), // Honey Bronze
    Color(0xFFC68A60), // Caramel Tan
    Color(0xFF8D5836), // Rich Chestnut
    Color(0xFF704428), // Deep Espresso
    Color(0xFF3E2314), // Ebony Dark
  ];

  static List<Color> get hairColors => const [
    Color(0xFF1B1B1B), // Jet Black
    Color(0xFF2E1C14), // Espresso Brown
    Color(0xFF6D4C41), // Chestnut Brown
    Color(0xFFF7D57F), // Golden Blonde
    Color(0xFFD7CCC8), // Platinum White
    Color(0xFF9E9E9E), // Silver Grey
    Color(0xFF009688), // Cyber Teal
    Color(0xFF00E5FF), // Electric Cyan
    Color(0xFFE91E63), // Neon Pink
    Color(0xFFD32F2F), // Ruby Crimson
    Color(0xFF7C4DFF), // Royal Purple
  ];

  static List<Color> get eyeColors => const [
    Color(0xFF261810), // Deep Brown
    Color(0xFF2962FF), // Vivid Blue
    Color(0xFF2E7D32), // Emerald Green
    Color(0xFFFF8F00), // Amber Hazel
    Color(0xFF00E5FF), // Cyber Cyan Glowing
    Color(0xFFAB47BC), // Violet Amethyst
  ];

  static List<Color> get outfitColors => const [
    Color(0xFFB71C1C), // Crimson Red
    Color(0xFF1A2A5E), // Navy Blue
    Color(0xFFBA7A7E), // Dusty Rose
    Color(0xFF1E1E24), // Biker Black
    Color(0xFF00897B), // Deep Teal
    Color(0xFFAD1457), // Royal Magenta
    Color(0xFF455A64), // Slate Grey
    Color(0xFF2E7D32), // Military Olive
    Color(0xFFFFB300), // Amber Gold
    Color(0xFF6A1B9A), // Deep Violet
  ];

  static BioAvatarConfig randomize() {
    final rand = Random();
    final skin = skinTones[rand.nextInt(skinTones.length)];
    final hairCol = hairColors[rand.nextInt(hairColors.length)];
    final eyeCol = eyeColors[rand.nextInt(eyeColors.length)];
    final outfitCol = outfitColors[rand.nextInt(outfitColors.length)];
    
    final hairStyles = ['skater_cap', 'short_braids', 'ponytail', 'teal_undercut', 'blonde_waves', 'hijab', 'grey_wavy', 'curly_afro', 'buzz_cut'];
    final beards = ['none', 'none', 'goatee', 'full_beard', 'mustache', 'stubble'];
    final outfits = ['flannel_plaid', 'navy_suit', 'hoodie_dress', 'leather_jacket', 'hijab_robe', 'knit_cardigan', 'cyber_armor'];
    final glassesList = ['none', 'none', 'black_frames', 'sunglasses', 'cyber_visor', 'round_frames'];

    final selectedHair = hairStyles[rand.nextInt(hairStyles.length)];
    final selectedHeadwear = selectedHair == 'skater_cap' 
        ? 'backward_cap' 
        : (selectedHair == 'hijab' ? 'hijab_wrap' : 'none');

    return BioAvatarConfig(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Operator Vector ${rand.nextInt(900) + 100}',
      gender: rand.nextBool() ? 'male' : 'female',
      skinTone: skin,
      hairStyle: selectedHair,
      hairColor: hairCol,
      eyeColor: eyeCol,
      expression: rand.nextBool() ? 'smile' : 'grin',
      facialHair: selectedHair == 'hijab' || selectedHair == 'ponytail' ? 'none' : beards[rand.nextInt(beards.length)],
      facialHairColor: hairCol,
      clothingStyle: outfits[rand.nextInt(outfits.length)],
      clothingColor: outfitCol,
      secondaryColor: Colors.white,
      glasses: glassesList[rand.nextInt(glassesList.length)],
      headwear: selectedHeadwear,
      headwearColor: selectedHeadwear == 'backward_cap' ? const Color(0xFF212121) : outfitCol,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'skinTone': skinTone.value,
      'hairStyle': hairStyle,
      'hairColor': hairColor.value,
      'eyeStyle': eyeStyle,
      'eyeColor': eyeColor.value,
      'expression': expression,
      'facialHair': facialHair,
      'facialHairColor': facialHairColor.value,
      'clothingStyle': clothingStyle,
      'clothingColor': clothingColor.value,
      'secondaryColor': secondaryColor.value,
      'glasses': glasses,
      'headwear': headwear,
      'headwearColor': headwearColor.value,
    };
  }

  factory BioAvatarConfig.fromJson(Map<String, dynamic> json) {
    return BioAvatarConfig(
      id: json['id'] as String? ?? 'custom_avatar',
      name: json['name'] as String? ?? 'Custom Avatar',
      gender: json['gender'] as String? ?? 'male',
      skinTone: Color(json['skinTone'] as int? ?? 0xFFECC0A0),
      hairStyle: json['hairStyle'] as String? ?? 'skater_cap',
      hairColor: Color(json['hairColor'] as int? ?? 0xFF2B1D14),
      eyeStyle: json['eyeStyle'] as String? ?? 'smile',
      eyeColor: Color(json['eyeColor'] as int? ?? 0xFF3B2F2F),
      expression: json['expression'] as String? ?? 'smile',
      facialHair: json['facialHair'] as String? ?? 'goatee',
      facialHairColor: Color(json['facialHairColor'] as int? ?? 0xFF2B1D14),
      clothingStyle: json['clothingStyle'] as String? ?? 'flannel_plaid',
      clothingColor: Color(json['clothingColor'] as int? ?? 0xFFB71C1C),
      secondaryColor: Color(json['secondaryColor'] as int? ?? 0xFF424242),
      glasses: json['glasses'] as String? ?? 'black_frames',
      headwear: json['headwear'] as String? ?? 'backward_cap',
      headwearColor: Color(json['headwearColor'] as int? ?? 0xFF212121),
    );
  }
}
