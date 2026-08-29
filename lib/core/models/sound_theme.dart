import 'package:flutter/material.dart';
import 'package:dream_engine_ai/core/state/engine_state.dart';

class SoundTheme {
  final String id;
  final String title;
  final String genre;
  final double bpm;
  final String waveform; // "sawtooth", "square", "sine", "triangle"
  final List<double> bassFrequencies;
  final List<double> leadMelody;
  final List<List<double>> chordFrequencies;
  final Color primaryColor;
  final Color accentColor;
  final AppTheme appTheme;
  final String description;

  const SoundTheme({
    required this.id,
    required this.title,
    required this.genre,
    required this.bpm,
    required this.waveform,
    required this.bassFrequencies,
    required this.leadMelody,
    required this.chordFrequencies,
    required this.primaryColor,
    required this.accentColor,
    required this.appTheme,
    required this.description,
  });

  // Preset library
  static const SoundTheme synthwave = SoundTheme(
    id: "synthwave",
    title: "GRID SYNTHWAVES - RETROFUTURE",
    genre: "Synthwave / Cyberpunk",
    bpm: 120.0,
    waveform: "sawtooth",
    bassFrequencies: [110.0, 87.31, 130.81, 98.0], // A2, F2, C3, G2
    leadMelody: [440.0, 523.25, 659.25, 587.33, 523.25, 440.0, 392.0, 440.0],
    chordFrequencies: [
      [220.0, 261.63, 329.63], // Am
      [174.61, 220.0, 261.63], // F
      [261.63, 329.63, 392.0], // C
      [196.0, 246.94, 293.66], // G
    ],
    primaryColor: Color(0xFF00E5FF),
    accentColor: Color(0xFFFF007F),
    appTheme: AppTheme.cyberNeon,
    description: "Driving neon synth leads with punchy sub-bass arpeggios.",
  );

  static const SoundTheme arcade8Bit = SoundTheme(
    id: "arcade_8bit",
    title: "PIXEL ODYSSEY - 8-BIT ARCADE",
    genre: "Chiptune / Retro Arcade",
    bpm: 144.0,
    waveform: "square",
    bassFrequencies: [130.81, 196.0, 220.0, 174.61], // C3, G3, A3, F3
    leadMelody: [523.25, 659.25, 783.99, 880.0, 783.99, 659.25, 587.33, 523.25],
    chordFrequencies: [
      [261.63, 329.63, 392.0], // C
      [196.0, 246.94, 293.66], // G
      [220.0, 261.63, 329.63], // Am
      [174.61, 220.0, 261.63], // F
    ],
    primaryColor: Color(0xFFFFB300),
    accentColor: Color(0xFFFF3D00),
    appTheme: AppTheme.ironMan,
    description: "Fast hyperactive square-wave chiptune with bouncing arcade arpeggios.",
  );

  static const SoundTheme matrixTechno = SoundTheme(
    id: "matrix_techno",
    title: "NEURAL MAINFRAME - ACID TECHNO",
    genre: "Matrix / Dark Techno",
    bpm: 134.0,
    waveform: "sawtooth",
    bassFrequencies: [73.42, 73.42, 87.31, 65.41], // D2, D2, F2, C2
    leadMelody: [293.66, 349.23, 440.0, 293.66, 587.33, 523.25, 440.0, 349.23],
    chordFrequencies: [
      [146.83, 174.61, 220.0], // Dm
      [146.83, 174.61, 220.0], // Dm
      [174.61, 220.0, 261.63], // F
      [130.81, 164.81, 196.0], // C
    ],
    primaryColor: Color(0xFF00FF66),
    accentColor: Color(0xFF00E5FF),
    appTheme: AppTheme.nvidiaGreen,
    description: "Heavy driving industrial acid bassline with resonant cyber pulses.",
  );

  static const SoundTheme deepSpace = SoundTheme(
    id: "deep_space",
    title: "COSMIC HORIZON - STELLAR AMBIENT",
    genre: "Ambient / Sci-Fi Cosmos",
    bpm: 72.0,
    waveform: "sine",
    bassFrequencies: [87.31, 65.41, 110.0, 98.0], // F2, C2, A2, G2
    leadMelody: [349.23, 440.0, 523.25, 659.25, 523.25, 440.0, 392.0, 349.23],
    chordFrequencies: [
      [174.61, 220.0, 261.63, 329.63], // Fmaj7
      [130.81, 164.81, 196.0, 246.94], // Cmaj7
      [220.0, 261.63, 329.63],         // Am
      [196.0, 246.94, 293.66],         // G
    ],
    primaryColor: Color(0xFFE0E6ED),
    accentColor: Color(0xFF7B61FF),
    appTheme: AppTheme.appleVision,
    description: "Lush harmonic sine pads with slow cosmic resonance and starlight shimmer.",
  );

  static const SoundTheme lofiChill = SoundTheme(
    id: "lofi_chill",
    title: "MIDNIGHT TERMINAL - LO-FI HOP",
    genre: "Lo-Fi / Chill Beats",
    bpm: 82.0,
    waveform: "triangle",
    bassFrequencies: [82.41, 110.0, 73.42, 98.0], // E2, A2, D2, G2
    leadMelody: [329.63, 392.0, 493.88, 587.33, 493.88, 392.0, 329.63, 293.66],
    chordFrequencies: [
      [164.81, 196.0, 246.94, 293.66], // Em7
      [220.0, 277.18, 329.63, 392.0],  // A7
      [146.83, 185.0, 220.0, 277.18],  // Dmaj7
      [196.0, 246.94, 293.66, 369.99], // Gmaj7
    ],
    primaryColor: Color(0xFFB388FF),
    accentColor: Color(0xFFFF80AB),
    appTheme: AppTheme.cyberNeon,
    description: "Warm Rhodes chords, vinyl crackle warmth, and relaxed late-night coding groove.",
  );

  static const SoundTheme darkHorror = SoundTheme(
    id: "dark_horror",
    title: "SHADOW SECTOR - BLOOD RESIDUE",
    genre: "Horror / Dark Industrial",
    bpm: 96.0,
    waveform: "sawtooth",
    bassFrequencies: [69.30, 98.0, 116.54, 82.41], // C#2, G2, A#2, E2
    leadMelody: [277.18, 392.0, 466.16, 329.63, 277.18, 311.13, 392.0, 277.18],
    chordFrequencies: [
      [138.59, 196.0, 233.08], // C#dim
      [196.0, 233.08, 277.18], // Gdim
      [116.54, 164.81, 196.0], // A#dim
      [164.81, 220.0, 261.63], // Em
    ],
    primaryColor: Color(0xFFFF1E27),
    accentColor: Color(0xFFFF6E40),
    appTheme: AppTheme.cyberNeon,
    description: "Tense cinematic dissonance, heavy industrial sub-drops, and dark pulse.",
  );

  static const SoundTheme epicBattle = SoundTheme(
    id: "epic_battle",
    title: "VALOR ASCENDING - ORCHESTRAL CLASH",
    genre: "Cinematic / Epic Battle",
    bpm: 114.0,
    waveform: "sawtooth",
    bassFrequencies: [98.0, 77.78, 87.31, 73.42], // G2, Eb2, F2, D2
    leadMelody: [392.0, 466.16, 587.33, 783.99, 698.46, 587.33, 466.16, 392.0],
    chordFrequencies: [
      [196.0, 233.08, 293.66], // Gm
      [155.56, 196.0, 233.08], // Eb
      [174.61, 220.0, 261.63], // F
      [146.83, 174.61, 220.0], // Dm
    ],
    primaryColor: Color(0xFFFFD700),
    accentColor: Color(0xFF00E5FF),
    appTheme: AppTheme.ironMan,
    description: "Driving timpani march, heroic brass fanfare, and thunderous battle rhythm.",
  );

  static List<SoundTheme> get allPresets => [
    synthwave,
    arcade8Bit,
    matrixTechno,
    deepSpace,
    lofiChill,
    darkHorror,
    epicBattle,
  ];

  /// NLP prompt parser that determines the best audio theme matching user prompt
  static SoundTheme parsePrompt(String prompt) {
    final clean = prompt.toLowerCase();

    if (clean.contains("8bit") ||
        clean.contains("8-bit") ||
        clean.contains("arcade") ||
        clean.contains("pixel") ||
        clean.contains("chiptune") ||
        clean.contains("mario") ||
        clean.contains("nintendo") ||
        clean.contains("retro game")) {
      return arcade8Bit;
    }

    if (clean.contains("matrix") ||
        clean.contains("techno") ||
        clean.contains("acid") ||
        clean.contains("hacker") ||
        clean.contains("cyber") ||
        clean.contains("industrial") ||
        clean.contains("bass drop") ||
        clean.contains("rave")) {
      return matrixTechno;
    }

    if (clean.contains("space") ||
        clean.contains("ambient") ||
        clean.contains("cosmic") ||
        clean.contains("orbit") ||
        clean.contains("galaxy") ||
        clean.contains("stars") ||
        clean.contains("ethereal") ||
        clean.contains("dream") ||
        clean.contains("zen")) {
      return deepSpace;
    }

    if (clean.contains("lofi") ||
        clean.contains("lo-fi") ||
        clean.contains("chill") ||
        clean.contains("relax") ||
        clean.contains("study") ||
        clean.contains("coffee") ||
        clean.contains("jazz") ||
        clean.contains("hip hop")) {
      return lofiChill;
    }

    if (clean.contains("horror") ||
        clean.contains("dark") ||
        clean.contains("doom") ||
        clean.contains("fear") ||
        clean.contains("zombie") ||
        clean.contains("blood") ||
        clean.contains("evil") ||
        clean.contains("nightmare")) {
      return darkHorror;
    }

    if (clean.contains("epic") ||
        clean.contains("orchestral") ||
        clean.contains("battle") ||
        clean.contains("cinematic") ||
        clean.contains("war") ||
        clean.contains("hero") ||
        clean.contains("clash") ||
        clean.contains("glory")) {
      return epicBattle;
    }

    // Default fallback
    return synthwave;
  }
}
