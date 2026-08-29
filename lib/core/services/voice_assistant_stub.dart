import 'dart:async';

typedef VoiceResultCallback = void Function(String text, bool isFinal);
typedef VoiceStateCallback = void Function(bool isListening, String? error);

class VoiceAssistantService {
  static final VoiceAssistantService instance = VoiceAssistantService._();
  VoiceAssistantService._();

  bool _isListening = false;
  bool get isListening => _isListening;
  bool get isSupported => true;

  void init() {}

  void startListening({
    required VoiceResultCallback onResult,
    required VoiceStateCallback onStateChange,
  }) {
    _isListening = true;
    onStateChange(true, null);

    Timer(const Duration(milliseconds: 1400), () {
      if (_isListening) {
        onResult("GTA 6 open world crime heist in neon Vice City", true);
        _isListening = false;
        onStateChange(false, null);
      }
    });
  }

  void stopListening() {
    _isListening = false;
  }

  void speak(String text) {}
}
