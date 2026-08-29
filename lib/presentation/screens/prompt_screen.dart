import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dream_engine_ai/core/state/engine_state.dart';
import 'package:dream_engine_ai/core/theme/cyber_theme.dart';
import 'package:dream_engine_ai/core/widgets/glass_container.dart';
import 'package:dream_engine_ai/core/widgets/neon_button.dart';
import 'package:dream_engine_ai/core/services/voice_assistant_helper.dart';

class _PromptScreenData {
  final bool isGenerating;
  final double generationProgress;
  final String generationStatus;
  final String gameTitle;
  final String gameGenre;
  final String weatherSystem;
  final double proceduralSeed;
  final AppTheme currentTheme;

  _PromptScreenData({
    required this.isGenerating,
    required this.generationProgress,
    required this.generationStatus,
    required this.gameTitle,
    required this.gameGenre,
    required this.weatherSystem,
    required this.proceduralSeed,
    required this.currentTheme,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _PromptScreenData &&
          runtimeType == other.runtimeType &&
          isGenerating == other.isGenerating &&
          generationProgress == other.generationProgress &&
          generationStatus == other.generationStatus &&
          gameTitle == other.gameTitle &&
          gameGenre == other.gameGenre &&
          weatherSystem == other.weatherSystem &&
          proceduralSeed == other.proceduralSeed &&
          currentTheme == other.currentTheme;

  @override
  int get hashCode => Object.hash(
        isGenerating,
        generationProgress,
        generationStatus,
        gameTitle,
        gameGenre,
        weatherSystem,
        proceduralSeed,
        currentTheme,
      );
}

class PromptScreen extends StatefulWidget {
  const PromptScreen({super.key});

  @override
  State<PromptScreen> createState() => _PromptScreenState();
}

class _PromptScreenState extends State<PromptScreen> with SingleTickerProviderStateMixin {
  final _promptController = TextEditingController();
  late AnimationController _waveController;
  bool _isListening = false;
  String _voiceStatusText = "";

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _toggleVoiceListening() {
    if (_isListening) {
      VoiceAssistantService.instance.stopListening();
      setState(() {
        _isListening = false;
        _waveController.stop();
        _voiceStatusText = "";
      });
    } else {
      setState(() {
        _isListening = true;
        _waveController.repeat();
        _voiceStatusText = "VOICE ASSISTANT LISTENING... [ Speak your game prompt, Operator ]";
      });

      VoiceAssistantService.instance.startListening(
        onResult: (text, isFinal) {
          if (!mounted) return;
          setState(() {
            _promptController.text = text;
            _voiceStatusText = isFinal ? "PROMPT CAPTURED: \"$text\"" : "TRANSCRIPTION: \"$text\"";
          });

          if (isFinal && text.trim().isNotEmpty) {
            VoiceAssistantService.instance.speak("Synthesizing $text now.");
            Future.delayed(const Duration(milliseconds: 700), () {
              if (mounted) {
                _triggerGeneration(context);
              }
            });
          }
        },
        onStateChange: (isListening, error) {
          if (!mounted) return;
          setState(() {
            _isListening = isListening;
            if (isListening) {
              _waveController.repeat();
            } else {
              _waveController.stop();
              if (error != null) {
                _voiceStatusText = "VOICE ERROR: $error";
              }
            }
          });
        },
      );
    }
  }

  void _triggerGeneration(BuildContext context) {
    if (_promptController.text.trim().isEmpty) return;
    final state = Provider.of<EngineState>(context, listen: false);
    state.generateGame(_promptController.text.trim()).then((_) {
      // Once generation finishes, automatically go to the Realtime rendering view!
      if (mounted) {
        state.setScreenIndex(5);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<EngineState, _PromptScreenData>(
      selector: (context, state) => _PromptScreenData(
        isGenerating: state.isGenerating,
        generationProgress: state.generationProgress,
        generationStatus: state.generationStatus,
        gameTitle: state.gameTitle,
        gameGenre: state.gameGenre,
        weatherSystem: state.weatherSystem,
        proceduralSeed: state.proceduralSeed,
        currentTheme: state.currentTheme,
      ),
      builder: (context, data, _) {
        final themeColor = _getSelectedThemeColor(data.currentTheme);
        final double screenWidth = MediaQuery.of(context).size.width;
        final bool isMobile = screenWidth < 768;

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
          child: Stack(
            children: [
              // Main Input Interface (shows when NOT generating)
              if (!data.isGenerating)
                isMobile
                    ? SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Top Header
                            Text(
                              "AI COMPILER PORT",
                              style: CyberTheme.titleStyle(fontSize: 20, color: Colors.white),
                            ),
                            Text(
                              "INPUT NATURAL LANGUAGE CORE SPECIFICATION PROTOCOL",
                              style: CyberTheme.monospaceStyle(fontSize: 8, color: themeColor),
                            ),
                            const SizedBox(height: 16),

                            // Large Input Box (Fixed Height on Mobile)
                            SizedBox(
                              height: 180,
                              child: GlassContainer(
                                borderColor: themeColor.withOpacity(0.2),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      "PROMPT MATRIX INJECTOR",
                                      style: CyberTheme.monospaceStyle(fontSize: 10, color: themeColor),
                                    ),
                                    const SizedBox(height: 12),
                                    Expanded(
                                      child: TextField(
                                        controller: _promptController,
                                        maxLines: null,
                                        style: CyberTheme.bodyStyle(fontSize: 14, color: Colors.white),
                                        decoration: InputDecoration(
                                          hintText: "State the environment, NPCs, narrative parameters...",
                                          hintStyle: CyberTheme.bodyStyle(fontSize: 13, color: CyberTheme.textMuted),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Live Voice Status indicator (mobile)
                            if (_voiceStatusText.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: CyberTheme.cyberPink.withValues(alpha: 0.12),
                                  border: Border.all(color: CyberTheme.cyberPink.withValues(alpha: 0.4)),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _voiceStatusText,
                                  style: CyberTheme.monospaceStyle(fontSize: 8.5, color: CyberTheme.cyberPink),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Controls row (Voice mic + Generate button)
                            Row(
                              children: [
                                // Voice Mic
                                GestureDetector(
                                  onTap: _toggleVoiceListening,
                                  child: Container(
                                    height: 44,
                                    width: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: _isListening ? CyberTheme.cyberPink : themeColor.withValues(alpha: 0.3)),
                                      color: (_isListening ? CyberTheme.cyberPink : themeColor).withValues(alpha: _isListening ? 0.25 : 0.1),
                                      boxShadow: [
                                        if (_isListening)
                                          BoxShadow(
                                            color: CyberTheme.cyberPink.withValues(alpha: 0.4),
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                          ),
                                      ],
                                    ),
                                    child: Icon(
                                      _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                                      color: _isScanningOrListeningColor(themeColor),
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                if (_isListening)
                                  Expanded(
                                    child: SizedBox(
                                      height: 44,
                                      child: AnimatedBuilder(
                                        animation: _waveController,
                                        builder: (context, _) {
                                          return RepaintBoundary(
                                            child: CustomPaint(
                                              painter: SoundWavePainter(
                                                progress: _waveController.value,
                                                waveColor: CyberTheme.cyberPink,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                else
                                  Expanded(
                                    flex: 2,
                                    child: NeonButton(
                                      onPressed: () => _triggerGeneration(context),
                                      glowColor: themeColor,
                                      gradientColors: [themeColor, themeColor.withBlue(210).withRed(40)],
                                      borderRadius: 8.0,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text("SYNTHESIZE", style: CyberTheme.headingStyle(fontSize: 11, color: Colors.white)),
                                            const SizedBox(width: 4),
                                            const Icon(Icons.bolt_rounded, color: Colors.white, size: 14),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (data.gameTitle != "NEO-GRID 2099") ...[
                              const SizedBox(height: 20),
                              GlassContainer(
                                borderColor: themeColor.withOpacity(0.15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "LAST PROCEDURAL COMPILER NLP TOKEN MAP",
                                      style: CyberTheme.monospaceStyle(fontSize: 9, color: themeColor).copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _buildNLPTokenPill("VERB: SYNTHESIZE", themeColor),
                                        _buildNLPTokenPill("TARGET: GAME ENGINE", themeColor),
                                        _buildNLPTokenPill("GENRE: ${data.gameGenre.toUpperCase()}", themeColor),
                                        _buildNLPTokenPill("CLIMATE: ${data.weatherSystem.toUpperCase()}", themeColor),
                                        _buildNLPTokenPill("SEED: 0x${data.proceduralSeed.toInt().toRadixString(16).toUpperCase()}", themeColor),
                                        _buildNLPTokenPill("NLP ENCODING: UTF-8", themeColor),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top Header
                          Text(
                            "AI COMPILER PORT",
                            style: CyberTheme.titleStyle(fontSize: 22, color: Colors.white),
                          ),
                          Text(
                            "INPUT NATURAL LANGUAGE CORE SPECIFICATION PROTOCOL",
                            style: CyberTheme.monospaceStyle(fontSize: 10, color: themeColor),
                          ),
                          const SizedBox(height: 24),

                          // Large Input Box
                          Expanded(
                            flex: 3,
                            child: GlassContainer(
                              borderColor: themeColor.withOpacity(0.2),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    "PROMPT MATRIX INJECTOR",
                                    style: CyberTheme.monospaceStyle(fontSize: 10, color: themeColor),
                                  ),
                                  const SizedBox(height: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: _promptController,
                                      maxLines: null,
                                      style: CyberTheme.bodyStyle(fontSize: 15, color: Colors.white),
                                      decoration: InputDecoration(
                                        hintText: "State the environment, NPCs, narrative parameters...",
                                        hintStyle: CyberTheme.bodyStyle(fontSize: 14, color: CyberTheme.textMuted),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Live Voice Status indicator (desktop)
                          if (_voiceStatusText.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: CyberTheme.cyberPink.withValues(alpha: 0.12),
                                border: Border.all(color: CyberTheme.cyberPink.withValues(alpha: 0.4)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.record_voice_over_rounded, color: CyberTheme.cyberPink, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _voiceStatusText,
                                      style: CyberTheme.monospaceStyle(fontSize: 9.5, color: CyberTheme.cyberPink).copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],

                          // Controls row (Voice mic + Generate button)
                          Row(
                            children: [
                              // Voice Mic
                              GestureDetector(
                                onTap: _toggleVoiceListening,
                                child: Container(
                                  height: 52,
                                  width: 52,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: _isListening ? CyberTheme.cyberPink : themeColor.withValues(alpha: 0.4)),
                                    color: (_isListening ? CyberTheme.cyberPink : themeColor).withValues(alpha: _isListening ? 0.25 : 0.1),
                                    boxShadow: [
                                      if (_isListening)
                                        BoxShadow(
                                          color: CyberTheme.cyberPink.withValues(alpha: 0.5),
                                          blurRadius: 16,
                                          spreadRadius: 3,
                                        ),
                                    ],
                                  ),
                                  child: Icon(
                                    _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                                    color: _isScanningOrListeningColor(themeColor),
                                    size: 26,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              if (_isListening)
                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    child: AnimatedBuilder(
                                      animation: _waveController,
                                      builder: (context, _) {
                                        return RepaintBoundary(
                                          child: CustomPaint(
                                            painter: SoundWavePainter(
                                              progress: _waveController.value,
                                              waveColor: CyberTheme.cyberPink,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                              else
                                const Spacer(),

                              NeonButton(
                                onPressed: () => _triggerGeneration(context),
                                glowColor: themeColor,
                                gradientColors: [themeColor, themeColor.withBlue(210).withRed(40)],
                                width: 200,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("SYNTHESIZE", style: CyberTheme.headingStyle(fontSize: 13, color: Colors.white)),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.bolt_rounded, color: Colors.white, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (data.gameTitle != "NEO-GRID 2099") ...[
                            const SizedBox(height: 24),
                            GlassContainer(
                              borderColor: themeColor.withOpacity(0.15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "LAST PROCEDURAL COMPILER NLP TOKEN MAP",
                                    style: CyberTheme.monospaceStyle(fontSize: 9, color: themeColor).copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _buildNLPTokenPill("VERB: SYNTHESIZE", themeColor),
                                      _buildNLPTokenPill("TARGET: GAME ENGINE", themeColor),
                                      _buildNLPTokenPill("GENRE: ${data.gameGenre.toUpperCase()}", themeColor),
                                      _buildNLPTokenPill("CLIMATE: ${data.weatherSystem.toUpperCase()}", themeColor),
                                      _buildNLPTokenPill("SEED: 0x${data.proceduralSeed.toInt().toRadixString(16).toUpperCase()}", themeColor),
                                      _buildNLPTokenPill("NLP ENCODING: UTF-8", themeColor),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),

              // Compile Loader screen (shows when isGenerating is true)
              if (data.isGenerating)
                Center(
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: GlassContainer(
                      borderColor: themeColor.withOpacity(0.3),
                      hasGlow: true,
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Loading graphics
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: CircularProgressIndicator(
                                  value: data.generationProgress,
                                  strokeWidth: 6,
                                  backgroundColor: Colors.white10,
                                  valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                                ),
                              ),
                              // Dynamic core pulsing icon
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.8, end: 1.2),
                                duration: const Duration(milliseconds: 600),
                                builder: (context, val, child) {
                                  return Transform.scale(
                                    scale: val,
                                    child: Icon(Icons.blur_on_rounded, color: themeColor, size: 48),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Text compiling logs
                          Text(
                            "DREAMENGINE PROCEDURAL COMPILER",
                            style: CyberTheme.headingStyle(fontSize: 14, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data.generationStatus,
                            style: CyberTheme.monospaceStyle(fontSize: 12, color: themeColor),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // Progress bar
                          LinearProgressIndicator(
                            value: data.generationProgress,
                            backgroundColor: Colors.white10,
                            color: themeColor,
                            minHeight: 4,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("COMPILING SEED VECTORS", style: CyberTheme.monospaceStyle(fontSize: 9, color: CyberTheme.textMuted)),
                              Text(
                                "${(data.generationProgress * 100).toInt()}%",
                                style: CyberTheme.monospaceStyle(fontSize: 9, color: themeColor),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              border: Border.all(color: themeColor.withOpacity(0.2)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "NLP PARSER LOGIC STACK",
                                      style: CyberTheme.monospaceStyle(fontSize: 9, color: themeColor),
                                    ),
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: themeColor,
                                        boxShadow: CyberTheme.neonGlow(color: themeColor),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildNLPLogLine("TOKENIZER", "Separating vocabulary inputs...", data.generationProgress > 0.1, themeColor),
                                _buildNLPLogLine("POS TAGGING", "Identified Nouns & Verbs...", data.generationProgress > 0.35, themeColor),
                                _buildNLPLogLine("SEMANTIC RESOLVER", "Mapping theme vectors...", data.generationProgress > 0.55, themeColor),
                                _buildNLPLogLine("SYNTAX DEPTH", "Analyzing syntactic hierarchy...", data.generationProgress > 0.75, themeColor),
                                _buildNLPLogLine("PROCEDURAL INJECTION", "Injecting semantic tokens to seed...", data.generationProgress > 0.9, themeColor),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Color _getSelectedThemeColor(AppTheme theme) {
    if (theme == AppTheme.ironMan) return Colors.amber;
    if (theme == AppTheme.nvidiaGreen) return Colors.lightGreenAccent;
    if (theme == AppTheme.appleVision) return Colors.white;
    return CyberTheme.neonBlue;
  }

  Color _isScanningOrListeningColor(Color themeColor) {
    return _isListening ? CyberTheme.cyberPink : themeColor;
  }

  Widget _buildNLPLogLine(String stage, String action, bool active, Color themeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                active ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                size: 11,
                color: active ? themeColor : Colors.white30,
              ),
              const SizedBox(width: 8),
              Text(
                "$stage:",
                style: CyberTheme.monospaceStyle(
                  fontSize: 9,
                  color: active ? Colors.white : Colors.white30,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(
            action,
            style: CyberTheme.monospaceStyle(
              fontSize: 9,
              color: active ? themeColor : Colors.white30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNLPTokenPill(String label, Color themeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.08),
        border: Border.all(color: themeColor.withOpacity(0.25)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: CyberTheme.monospaceStyle(fontSize: 8, color: Colors.white70),
      ),
    );
  }
}

class SoundWavePainter extends CustomPainter {
  final double progress;
  final Color waveColor;

  SoundWavePainter({required this.progress, required this.waveColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final double midY = size.height / 2;
    final int numBars = 18;
    final double spacing = size.width / numBars;

    for (int i = 0; i < numBars; i++) {
      // Calculate dynamic waves heights using sine function
      final double waveFactor = sin((progress * 2 * pi) + (i * 0.5));
      final double height = (size.height * 0.3) + (waveFactor.abs() * size.height * 0.6);

      final double x = (i * spacing) + (spacing / 2);
      canvas.drawLine(
        Offset(x, midY - (height / 2)),
        Offset(x, midY + (height / 2)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
