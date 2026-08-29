import 'dart:async';
import 'dart:math';
import 'package:dream_engine_ai/core/models/sound_theme.dart';

class AudioSynthesizer {
  static final AudioSynthesizer instance = AudioSynthesizer._();
  AudioSynthesizer._();

  Timer? _sequenceTimer;
  bool _isPlaying = false;
  int _currentStep = 0;
  SoundTheme _activeTheme = SoundTheme.synthwave;

  final List<double> _visualizerFrequencies = List.filled(45, 0.0);

  bool get isPlaying => _isPlaying;
  SoundTheme get activeTheme => _activeTheme;
  List<double> get visualizerFrequencies => _visualizerFrequencies;

  void init() {}

  void play(SoundTheme theme) {
    _activeTheme = theme;
    _isPlaying = true;
    _currentStep = 0;
    _sequenceTimer?.cancel();

    final stepMs = (60000 / (theme.bpm * 4)).round();

    _sequenceTimer = Timer.periodic(Duration(milliseconds: stepMs), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }
      _stepSequencer();
    });
  }

  void stop() {
    _isPlaying = false;
    _sequenceTimer?.cancel();
    _sequenceTimer = null;
    for (int i = 0; i < _visualizerFrequencies.length; i++) {
      _visualizerFrequencies[i] = 0.0;
    }
  }

  void _stepSequencer() {
    final random = Random();
    for (int i = 0; i < _visualizerFrequencies.length; i++) {
      final target = (sin((_currentStep * 0.4) + (i * 0.3)).abs() * 0.6) + (random.nextDouble() * 0.4);
      _visualizerFrequencies[i] = target.clamp(0.1, 1.0);
    }
    _currentStep++;
  }
}
