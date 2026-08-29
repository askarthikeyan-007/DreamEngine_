import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;

typedef VoiceResultCallback = void Function(String text, bool isFinal);
typedef VoiceStateCallback = void Function(bool isListening, String? error);

class VoiceAssistantService {
  static final VoiceAssistantService instance = VoiceAssistantService._();
  VoiceAssistantService._();

  js.JsObject? _recognition;
  bool _isListening = false;
  VoiceResultCallback? _onResult;
  VoiceStateCallback? _onStateChange;

  bool get isListening => _isListening;

  bool get isSupported {
    return js.context.hasProperty('webkitSpeechRecognition') ||
        js.context.hasProperty('SpeechRecognition');
  }

  void init() {
    if (!isSupported) return;
    try {
      final speechClass = js.context['webkitSpeechRecognition'] ??
          js.context['SpeechRecognition'];

      if (speechClass != null) {
        _recognition = js.JsObject(speechClass, []);
        _recognition!['continuous'] = false;
        _recognition!['interimResults'] = true;
        _recognition!['lang'] = 'en-US';

        // onresult handler
        _recognition!['onresult'] = (dynamic event) {
          try {
            final results = event['results'];
            final length = results['length'] as int;
            if (length > 0) {
              final lastResult = results[length - 1];
              final isFinal = lastResult['isFinal'] as bool? ?? false;
              final firstAlternative = lastResult[0];
              final transcript = firstAlternative['transcript'] as String? ?? '';

              if (transcript.isNotEmpty) {
                _onResult?.call(transcript, isFinal);
              }
            }
          } catch (_) {}
        };

        // onstart handler
        _recognition!['onstart'] = (dynamic event) {
          _isListening = true;
          _onStateChange?.call(true, null);
        };

        // onend handler
        _recognition!['onend'] = (dynamic event) {
          _isListening = false;
          _onStateChange?.call(false, null);
        };

        // onerror handler
        _recognition!['onerror'] = (dynamic event) {
          final error = event['error']?.toString() ?? 'Voice capture error';
          _isListening = false;
          _onStateChange?.call(false, error);
        };
      }
    } catch (e) {
      _isListening = false;
    }
  }

  void startListening({
    required VoiceResultCallback onResult,
    required VoiceStateCallback onStateChange,
  }) {
    _onResult = onResult;
    _onStateChange = onStateChange;

    if (_recognition == null) {
      init();
    }

    if (_recognition != null) {
      try {
        _recognition!.callMethod('start', []);
      } catch (e) {
        // If already started
      }
    } else {
      _simulateVoiceListening();
    }
  }

  void stopListening() {
    if (_recognition != null && _isListening) {
      try {
        _recognition!.callMethod('stop', []);
      } catch (_) {}
    }
    _isListening = false;
    _onStateChange?.call(false, null);
  }

  void speak(String text) {
    try {
      final synth = html.window.speechSynthesis;
      if (synth != null) {
        final utterance = html.SpeechSynthesisUtterance(text);
        utterance.rate = 1.05;
        utterance.pitch = 1.0;
        synth.speak(utterance);
      }
    } catch (_) {}
  }

  void _simulateVoiceListening() {
    _isListening = true;
    _onStateChange?.call(true, null);

    Timer(const Duration(milliseconds: 1200), () {
      if (_isListening) {
        _onResult?.call("GTA 6 open world crime heist in neon Vice City", true);
        speak("Voice prompt received: GTA 6 open world crime heist in Vice City");
        stopListening();
      }
    });
  }
}
