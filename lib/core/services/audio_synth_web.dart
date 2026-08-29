import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:math';
import 'dart:typed_data';
import 'package:dream_engine_ai/core/models/sound_theme.dart';

class AudioSynthesizer {
  static final AudioSynthesizer instance = AudioSynthesizer._();
  AudioSynthesizer._();

  html.AudioElement? _audioElement;
  Timer? _visualizerTimer;
  bool _isPlaying = false;
  int _animFrame = 0;
  SoundTheme _activeTheme = SoundTheme.synthwave;

  final List<double> _visualizerFrequencies = List.filled(45, 0.0);

  bool get isPlaying => _isPlaying;
  SoundTheme get activeTheme => _activeTheme;
  List<double> get visualizerFrequencies => _visualizerFrequencies;

  void init() {
    _audioElement ??= html.AudioElement()..loop = true;
  }

  void play(SoundTheme theme) {
    init();
    _activeTheme = theme;
    _isPlaying = true;
    _animFrame = 0;

    // Generate procedural PCM WAV audio bytes for this theme
    final wavBytes = _generateThemeWav(theme);
    final base64Audio = base64Encode(wavBytes);
    final dataUri = "data:audio/wav;base64,$base64Audio";

    if (_audioElement != null) {
      _audioElement!.src = dataUri;
      _audioElement!.play().catchError((e) {
        // Autoplay policy or interaction handled
      });
    }

    _startVisualizer(theme.bpm);
  }

  void stop() {
    _isPlaying = false;
    _visualizerTimer?.cancel();
    _visualizerTimer = null;
    if (_audioElement != null) {
      _audioElement!.pause();
      _audioElement!.currentTime = 0;
    }
    for (int i = 0; i < _visualizerFrequencies.length; i++) {
      _visualizerFrequencies[i] = 0.0;
    }
  }

  void _startVisualizer(double bpm) {
    _visualizerTimer?.cancel();
    final intervalMs = (60000 / (bpm * 4)).round().clamp(50, 200);

    _visualizerTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }
      final random = Random();
      for (int i = 0; i < _visualizerFrequencies.length; i++) {
        final target = (sin((_animFrame * 0.4) + (i * 0.3)).abs() * 0.6) + (random.nextDouble() * 0.4);
        _visualizerFrequencies[i] = target.clamp(0.1, 1.0);
      }
      _animFrame++;
    });
  }

  Uint8List _generateThemeWav(SoundTheme theme) {
    const int sampleRate = 22050;
    // 4 bars loop duration in seconds
    final double duration = (60.0 / theme.bpm) * 4.0;
    final int numSamples = (sampleRate * duration).round();
    final int numChannels = 1;
    final int bytesPerSample = 2; // 16-bit
    final int byteRate = sampleRate * numChannels * bytesPerSample;
    final int blockAlign = numChannels * bytesPerSample;
    final int subChunk2Size = numSamples * numChannels * bytesPerSample;
    final int chunkSize = 36 + subChunk2Size;

    final ByteData byteData = ByteData(44 + subChunk2Size);

    // RIFF header
    byteData.setUint8(0, 0x52); // 'R'
    byteData.setUint8(1, 0x49); // 'I'
    byteData.setUint8(2, 0x46); // 'F'
    byteData.setUint8(3, 0x46); // 'F'
    byteData.setUint32(4, chunkSize, Endian.little);
    byteData.setUint8(8, 0x57);  // 'W'
    byteData.setUint8(9, 0x41);  // 'A'
    byteData.setUint8(10, 0x56); // 'V'
    byteData.setUint8(11, 0x45); // 'E'

    // fmt subchunk
    byteData.setUint8(12, 0x66); // 'f'
    byteData.setUint8(13, 0x6D); // 'm'
    byteData.setUint8(14, 0x74); // 't'
    byteData.setUint8(15, 0x20); // ' '
    byteData.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
    byteData.setUint16(20, 1, Endian.little);  // AudioFormat (1 = PCM)
    byteData.setUint16(22, numChannels, Endian.little);
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, byteRate, Endian.little);
    byteData.setUint16(32, blockAlign, Endian.little);
    byteData.setUint16(34, 16, Endian.little); // BitsPerSample (16)

    // data subchunk
    byteData.setUint8(36, 0x64); // 'd'
    byteData.setUint8(37, 0x61); // 'a'
    byteData.setUint8(38, 0x74); // 't'
    byteData.setUint8(39, 0x61); // 'a'
    byteData.setUint32(40, subChunk2Size, Endian.little);

    // Audio synthesis sample generation loop
    final double beatDuration = 60.0 / theme.bpm;

    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;
      final double totalBeats = t / beatDuration;
      final int step = (totalBeats * 4).floor() % 16;
      final int chordIdx = (step ~/ 4) % theme.chordFrequencies.length;
      final double stepFraction = (totalBeats * 4) - (totalBeats * 4).floor();

      // 1. Bassline (Saw/Square/Sine)
      final double bassFreq = theme.bassFrequencies[chordIdx % theme.bassFrequencies.length];
      double bassSample = 0.0;
      if (theme.waveform == "square") {
        bassSample = sin(2 * pi * bassFreq * t) > 0 ? 0.35 : -0.35;
      } else if (theme.waveform == "sawtooth") {
        bassSample = ((2.0 * (t * bassFreq - (t * bassFreq).floor())) - 1.0) * 0.35;
      } else {
        bassSample = sin(2 * pi * bassFreq * t) * 0.4;
      }

      // 2. Lead melody note
      final int melIdx = (step % theme.leadMelody.length);
      final double leadFreq = theme.leadMelody[melIdx];
      double leadSample = 0.0;
      final double leadEnvelope = (1.0 - stepFraction).clamp(0.0, 1.0);
      if (theme.waveform == "square") {
        leadSample = (sin(2 * pi * leadFreq * t) > 0 ? 0.25 : -0.25) * leadEnvelope;
      } else {
        leadSample = sin(2 * pi * leadFreq * t) * 0.28 * leadEnvelope;
      }

      // 3. Chord harmonics
      final chord = theme.chordFrequencies[chordIdx];
      double chordSample = 0.0;
      for (final f in chord) {
        chordSample += sin(2 * pi * f * t) * 0.06;
      }

      // 4. Kick drum (Steps 0, 8)
      double kickSample = 0.0;
      if (step == 0 || step == 8 || (theme.id == "matrix_techno" && (step == 4 || step == 12))) {
        final double kickEnv = (1.0 - stepFraction * 2.5).clamp(0.0, 1.0);
        final double kickFreq = 120.0 * (1.0 - stepFraction * 0.7);
        kickSample = sin(2 * pi * kickFreq * t) * 0.45 * kickEnv;
      }

      // 5. Snare / Clack (Steps 4, 12)
      double snareSample = 0.0;
      if (step == 4 || step == 12) {
        final double snareEnv = (1.0 - stepFraction * 3.0).clamp(0.0, 1.0);
        snareSample = ((Random(i).nextDouble() * 2.0) - 1.0) * 0.22 * snareEnv;
      }

      // Mix and clamp
      final double mixed = (bassSample * 0.5) + (leadSample * 0.4) + (chordSample * 0.3) + (kickSample * 0.6) + (snareSample * 0.4);
      final double clamped = mixed.clamp(-1.0, 1.0);
      final int intSample = (clamped * 32000).round();

      byteData.setInt16(44 + (i * 2), intSample, Endian.little);
    }

    return byteData.buffer.asUint8List();
  }
}
