import 'package:flutter/material.dart';
import 'package:dream_engine_ai/core/theme/cyber_theme.dart';

class NeonButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? glowColor;
  final List<Color>? gradientColors;
  final double borderRadius;
  final double? width;
  final double? height;

  const NeonButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.glowColor,
    this.gradientColors,
    this.borderRadius = 8.0,
    this.width,
    this.height,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = CyberTheme.isLight;
    final themeGlowColor = widget.glowColor ?? (isLight ? const Color(0xFFCBD5E1) : CyberTheme.neonBlue);
    final themeGradientColors = widget.gradientColors ?? 
        (isLight 
            ? const [Color(0xFFE2E8F0), Color(0xFFCBD5E1)]
            : [CyberTheme.neonBlue, CyberTheme.electricPurple]);

    final hasGlow = _isHovered || _isPressed;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _animationController.forward();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _animationController.reverse();
          widget.onPressed();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _animationController.reverse();
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: LinearGradient(
                colors: themeGradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: hasGlow
                  ? CyberTheme.neonGlow(color: themeGlowColor, blurRadius: 12)
                  : [
                      BoxShadow(
                        color: themeGlowColor.withOpacity(isLight ? 0.05 : 0.2),
                        blurRadius: 4,
                        spreadRadius: 0,
                      )
                    ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            alignment: Alignment.center,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
