import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:dream_engine_ai/core/state/engine_state.dart';
import 'package:dream_engine_ai/core/theme/cyber_theme.dart';
import 'package:dream_engine_ai/core/widgets/neon_button.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  final List<String> _consoleLogs = [];
  int _logIndex = 0;
  double _progress = 0.0;
  Timer? _logTimer;
  Timer? _progressTimer;

  VideoPlayerController? _videoController;
  bool _showLogo = true;
  bool _showVideo = false;
  bool _isVideoInitialized = false;

  final List<String> _bootSequence = [
    "SYSTEM BOOT INITIATED...",
    "VERIFYING ENGINE ENCRYPTION KEYS... [SUCCESS]",
    "MAPPING PROCEDURAL VOXEL GRAPHICS ENGINE... [OK]",
    "ALLOCATING SHADER REPOSITORIES ON DEVICE ENGINE...",
    "ESTABLISHING SECURE CONNECTION TO LLM FRAMEWORK...",
    "SPAWNING EMOTION-AWARE NPC DIALOGUE NETWORKS...",
    "STARTING STABLE DIFFUSION RENDER PIPELINES...",
    "DREAMENGINE AI CORE: STATUS GREEN. WELCOME OPERATOR."
  ];

  @override
  void initState() {
    super.initState();
    // Show the logo screen first for 2 seconds, then transition to video
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showLogo = false;
          _showVideo = true;
        });
        _initializeVideo();
      }
    });
  }

  void _initializeVideo() {
    _videoController = VideoPlayerController.asset('assets/cinematic_videos/render_this_8.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
          _videoController!.play();
          _videoController!.addListener(_videoListener);
        }
      }).catchError((error) {
        debugPrint("Video initialization failed: $error");
        _skipVideo();
      });
  }

  void _videoListener() {
    if (_videoController == null) return;
    if (_videoController!.value.position >= _videoController!.value.duration) {
      _skipVideo();
    }
  }

  void _skipVideo() {
    if (!_showVideo) return;
    _videoController?.removeListener(_videoListener);
    _videoController?.pause();
    setState(() {
      _showVideo = false;
    });
    _startBootSequence();
  }

  void _startBootSequence() {
    // Print logs step by step
    _logTimer = Timer.periodic(const Duration(milliseconds: 350), (timer) {
      if (_logIndex < _bootSequence.length) {
        setState(() {
          _consoleLogs.add(_bootSequence[_logIndex]);
          _logIndex++;
        });
      } else {
        timer.cancel();
      }
    });

    // Animate progress bar
    _progressTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        if (_progress < 1.0) {
          _progress += 0.01;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _logTimer?.cancel();
    _progressTimer?.cancel();
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    super.dispose();
  }

  void _enterPlatform() {
    final state = Provider.of<EngineState>(context, listen: false);
    state.setScreenIndex(1); // Go to Onboarding
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      child: _showLogo
          ? _buildLogoScreen()
          : (_showVideo ? _buildVideoScreen() : _buildBootSequence(context)),
    );
  }

  Widget _buildLogoScreen() {
    return Scaffold(
      key: const ValueKey('logo_screen'),
      backgroundColor: Colors.black,
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1000),
          builder: (context, val, child) {
            return Opacity(
              opacity: val,
              child: child,
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo image with a glowing border or frame
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: CyberTheme.neonBlue.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.blur_on_rounded,
                        color: CyberTheme.neonBlue,
                        size: 60,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Brand Text
              Text(
                "DREAMENGINE AI",
                style: CyberTheme.titleStyle(fontSize: 28),
              ),
              const SizedBox(height: 8),
              Text(
                "INITIALIZING PLATFORM SEGMENTS...",
                style: CyberTheme.monospaceStyle(
                  fontSize: 10,
                  color: CyberTheme.neonBlue,
                ).copyWith(letterSpacing: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoScreen() {
    return Scaffold(
      key: const ValueKey('video_screen'),
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // The video player with BoxFit.cover to cover the screen
          if (_isVideoInitialized && _videoController != null)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            )
          else
            // Futuristic loader
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(CyberTheme.neonBlue),
                    strokeWidth: 2,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "INITIALIZING SYSTEM CORE...",
                    style: CyberTheme.monospaceStyle(
                      fontSize: 12,
                      color: CyberTheme.neonBlue,
                    ).copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBootSequence(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Padding(
      key: const ValueKey('boot_sequence'),
      padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          // Glowing Neon logo with glitch effect
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 1),
            builder: (context, val, child) {
              return Opacity(
                opacity: val,
                child: child,
              );
            },
            child: Column(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => CyberTheme.cyberGradient.createShader(bounds),
                  child: Text(
                    "DREAMENGINE AI",
                    textAlign: TextAlign.center,
                    style: CyberTheme.titleStyle(fontSize: isMobile ? 32 : 48),
                  ),
                ),
                Text(
                  "NEXT-GEN PROCEDURAL GENERATOR",
                  style: CyberTheme.headingStyle(
                    fontSize: isMobile ? 10 : 12,
                    color: CyberTheme.neonBlue.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Console boot logs window
          Container(
            height: isMobile ? 140 : 180,
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              border: Border.all(color: CyberTheme.neonBlue.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              itemCount: _consoleLogs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text(
                    "> ${_consoleLogs[index]}",
                    style: CyberTheme.monospaceStyle(
                      fontSize: 11,
                      color: index == _consoleLogs.length - 1
                          ? CyberTheme.neonBlue
                          : CyberTheme.textMuted,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Progress line
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.white10,
                  color: CyberTheme.neonBlue,
                  minHeight: 4,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("SYSTEM BOOTING", style: CyberTheme.monospaceStyle(fontSize: 10)),
                    Text("${(_progress * 100).toInt()}%", style: CyberTheme.monospaceStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),

          // Enter Button (visible when loading is complete, or Skip option)
          AnimatedOpacity(
            opacity: _progress >= 1.0 ? 1.0 : 0.4,
            duration: const Duration(milliseconds: 300),
            child: NeonButton(
              onPressed: _enterPlatform,
              width: 250,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _progress >= 1.0 ? "INITIALIZE SHELL" : "BYPASS BOOT SYSTEM",
                      style: CyberTheme.headingStyle(fontSize: 14, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
