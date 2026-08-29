import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dream_engine_ai/core/models/bio_avatar.dart';
import 'package:dream_engine_ai/core/theme/cyber_theme.dart';

class BioAvatarCanvas extends StatelessWidget {
  final BioAvatarConfig config;
  final double yaw; // -1.0 to 1.0 (rotation around Y axis)
  final double pitch; // -1.0 to 1.0 (tilt around X axis)
  final bool showBackground;
  final bool isInteractive;
  final double size;

  const BioAvatarCanvas({
    super.key,
    required this.config,
    this.yaw = 0.0,
    this.pitch = 0.0,
    this.showBackground = true,
    this.isInteractive = false,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: BioAvatarPainter(
          config: config,
          yaw: yaw,
          pitch: pitch,
          showBackground: showBackground,
        ),
      ),
    );
  }
}

class BioAvatarPainter extends CustomPainter {
  final BioAvatarConfig config;
  final double yaw;
  final double pitch;
  final bool showBackground;

  BioAvatarPainter({
    required this.config,
    this.yaw = 0.0,
    this.pitch = 0.0,
    this.showBackground = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double scale = size.width / 220;

    // Background gradient glow if enabled
    if (showBackground) {
      final bgPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            config.clothingColor.withOpacity(0.25),
            const Color(0xFF0C0E14).withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: size.width * 0.5));
      canvas.drawCircle(Offset(cx, cy), size.width * 0.48, bgPaint);
    }

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(scale);

    // Parallax offset based on yaw & pitch
    final double parallaxX = (yaw.clamp(-1.0, 1.0)) * 14.0;
    final double parallaxY = (pitch.clamp(-1.0, 1.0)) * 10.0;

    // 1. Draw Body & Clothing (Base Layer)
    _drawBodyAndOutfit(canvas, parallaxX, parallaxY);

    // 2. Draw Back Hair (if long hair like blonde waves or ponytail)
    _drawBackHair(canvas, parallaxX, parallaxY);

    // 3. Draw Neck & Shadow
    _drawNeck(canvas, parallaxX, parallaxY);

    // 4. Draw Head Base (Face shape, ears, cheeks)
    _drawHead(canvas, parallaxX, parallaxY);

    // 5. Draw Facial Features (Eyes, Eyebrows, Nose, Mouth, Beard)
    _drawFaceFeatures(canvas, parallaxX, parallaxY);

    // 6. Draw Front Hair / Hijab / Cap
    _drawFrontHairAndHeadwear(canvas, parallaxX, parallaxY);

    // 7. Draw Glasses / Accessories
    _drawGlassesAndAccessories(canvas, parallaxX, parallaxY);

    canvas.restore();
  }

  void _drawBodyAndOutfit(Canvas canvas, double px, double py) {
    final bodyPaint = Paint()..color = config.clothingColor;
    final secPaint = Paint()..color = config.secondaryColor;
    final shadowPaint = Paint()..color = Colors.black.withOpacity(0.25);

    final double bodyY = 55 + py * 0.3;
    final double bodyX = px * 0.3;

    final bodyRect = Rect.fromCenter(center: Offset(bodyX, bodyY + 45), width: 130, height: 80);
    final rrect = RRect.fromRectAndRadius(bodyRect, const Radius.circular(24));
    canvas.drawRRect(rrect, bodyPaint);

    // Specific outfit details matching the 1st picture characters:
    if (config.clothingStyle == 'flannel_plaid') {
      // Red checked flannel with undershirt
      final underRect = Rect.fromCenter(center: Offset(bodyX, bodyY + 30), width: 44, height: 40);
      canvas.drawRRect(RRect.fromRectAndRadius(underRect, const Radius.circular(8)), secPaint);

      // Plaid dark stripes
      final linePaint = Paint()
        ..color = config.secondaryColor.withOpacity(0.4)
        ..strokeWidth = 3;
      canvas.drawLine(Offset(bodyX - 35, bodyY + 15), Offset(bodyX - 35, bodyY + 75), linePaint);
      canvas.drawLine(Offset(bodyX + 35, bodyY + 15), Offset(bodyX + 35, bodyY + 75), linePaint);
      canvas.drawLine(Offset(bodyX - 60, bodyY + 45), Offset(bodyX + 60, bodyY + 45), linePaint);
      canvas.drawLine(Offset(bodyX - 60, bodyY + 65), Offset(bodyX + 60, bodyY + 65), linePaint);

      // Flannel collar folds
      final colPath = Path()
        ..moveTo(bodyX - 25, bodyY + 15)
        ..lineTo(bodyX - 10, bodyY + 38)
        ..lineTo(bodyX - 30, bodyY + 35)
        ..close();
      canvas.drawPath(colPath, Paint()..color = config.clothingColor.withOpacity(0.85));
      final colPath2 = Path()
        ..moveTo(bodyX + 25, bodyY + 15)
        ..lineTo(bodyX + 10, bodyY + 38)
        ..lineTo(bodyX + 30, bodyY + 35)
        ..close();
      canvas.drawPath(colPath2, Paint()..color = config.clothingColor.withOpacity(0.85));

    } else if (config.clothingStyle == 'navy_suit') {
      // Navy tailored business suit with white shirt & collar
      final shirtPath = Path()
        ..moveTo(bodyX - 18, bodyY + 15)
        ..lineTo(bodyX, bodyY + 50)
        ..lineTo(bodyX + 18, bodyY + 15)
        ..close();
      canvas.drawPath(shirtPath, Paint()..color = Colors.white);

      // Lapels
      final lapelPath = Path()
        ..moveTo(bodyX - 28, bodyY + 18)
        ..lineTo(bodyX - 6, bodyY + 52)
        ..lineTo(bodyX - 28, bodyY + 52)
        ..close();
      canvas.drawPath(lapelPath, Paint()..color = config.clothingColor.withBlue(config.clothingColor.blue + 25));

      final lapelPath2 = Path()
        ..moveTo(bodyX + 28, bodyY + 18)
        ..lineTo(bodyX + 6, bodyY + 52)
        ..lineTo(bodyX + 28, bodyY + 52)
        ..close();
      canvas.drawPath(lapelPath2, Paint()..color = config.clothingColor.withBlue(config.clothingColor.blue + 25));

      // Red pocket square
      canvas.drawRect(Rect.fromLTWH(bodyX + 28, bodyY + 45, 10, 3), Paint()..color = const Color(0xFFFF1E27));

    } else if (config.clothingStyle == 'hoodie_dress') {
      // Dusty rose hoodie dress with white zipper/drawstrings
      final stringPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(bodyX - 6, bodyY + 28), Offset(bodyX - 6, bodyY + 60), stringPaint);
      canvas.drawLine(Offset(bodyX + 6, bodyY + 28), Offset(bodyX + 6, bodyY + 60), stringPaint);
      
      // Drawstring lace aglets
      canvas.drawCircle(Offset(bodyX - 6, bodyY + 61), 2.5, Paint()..color = Colors.white70);
      canvas.drawCircle(Offset(bodyX + 6, bodyY + 61), 2.5, Paint()..color = Colors.white70);

      // Soft hood neckline curve
      final hoodNeck = Path()
        ..moveTo(bodyX - 35, bodyY + 18)
        ..quadraticBezierTo(bodyX, bodyY + 36, bodyX + 35, bodyY + 18)
        ..quadraticBezierTo(bodyX, bodyY + 24, bodyX - 35, bodyY + 18);
      canvas.drawPath(hoodNeck, shadowPaint);

    } else if (config.clothingStyle == 'leather_jacket') {
      // Black biker leather jacket with inner white tee and silver zip
      final innerTee = Path()
        ..moveTo(bodyX - 16, bodyY + 15)
        ..lineTo(bodyX, bodyY + 42)
        ..lineTo(bodyX + 16, bodyY + 15)
        ..close();
      canvas.drawPath(innerTee, Paint()..color = Colors.white);

      // Silver zipper
      final zipPaint = Paint()
        ..color = const Color(0xFFB0BEC5)
        ..strokeWidth = 2;
      canvas.drawLine(Offset(bodyX - 2, bodyY + 38), Offset(bodyX - 2, bodyY + 75), zipPaint);

      // Silver biker studs
      canvas.drawCircle(Offset(bodyX - 26, bodyY + 32), 2, Paint()..color = Colors.white70);
      canvas.drawCircle(Offset(bodyX + 26, bodyY + 32), 2, Paint()..color = Colors.white70);

    } else if (config.clothingStyle == 'knit_cardigan') {
      // Cream turtleneck under cardigan
      final turtlePath = Path()
        ..moveTo(bodyX - 18, bodyY + 12)
        ..quadraticBezierTo(bodyX, bodyY + 28, bodyX + 18, bodyY + 12)
        ..lineTo(bodyX + 18, bodyY + 40)
        ..lineTo(bodyX - 18, bodyY + 40)
        ..close();
      canvas.drawPath(turtlePath, Paint()..color = config.secondaryColor);

      // Patterned scarf / knit folds
      final scarfPath = Path()
        ..moveTo(bodyX - 22, bodyY + 20)
        ..quadraticBezierTo(bodyX, bodyY + 45, bodyX + 22, bodyY + 20)
        ..lineTo(bodyX + 16, bodyY + 35)
        ..quadraticBezierTo(bodyX, bodyY + 52, bodyX - 16, bodyY + 35)
        ..close();
      canvas.drawPath(scarfPath, Paint()..color = const Color(0xFFE91E63).withOpacity(0.8));
    }
  }

  void _drawBackHair(Canvas canvas, double px, double py) {
    final hairPaint = Paint()..color = config.hairColor;
    final shadowHairPaint = Paint()..color = config.hairColor.withOpacity(0.8);

    if (config.hairStyle == 'blonde_waves' || config.hairStyle == 'grey_wavy') {
      // Long flowing side waves cascading down shoulders
      final leftWaves = Path()
        ..moveTo(-48 + px * 0.7, -20 + py * 0.7)
        ..cubicTo(-68 + px * 0.5, 10, -62 + px * 0.4, 55, -42 + px * 0.4, 75 + py * 0.4)
        ..cubicTo(-32 + px * 0.5, 60, -38 + px * 0.6, 25, -34 + px * 0.7, 5 + py * 0.7)
        ..close();
      canvas.drawPath(leftWaves, hairPaint);

      final rightWaves = Path()
        ..moveTo(48 + px * 0.7, -20 + py * 0.7)
        ..cubicTo(68 + px * 0.5, 10, 62 + px * 0.4, 55, 42 + px * 0.4, 75 + py * 0.4)
        ..cubicTo(32 + px * 0.5, 60, 38 + px * 0.6, 25, 34 + px * 0.7, 5 + py * 0.7)
        ..close();
      canvas.drawPath(rightWaves, hairPaint);

    } else if (config.hairStyle == 'ponytail') {
      // High swept side ponytail flowing down over right shoulder
      final ponyPath = Path()
        ..moveTo(25 + px * 0.8, -45 + py * 0.8)
        ..cubicTo(55 + px * 0.6, -30, 65 + px * 0.5, 20, 52 + px * 0.4, 65 + py * 0.4)
        ..cubicTo(42 + px * 0.4, 55, 48 + px * 0.5, 0, 20 + px * 0.7, -35 + py * 0.8)
        ..close();
      canvas.drawPath(ponyPath, shadowHairPaint);
    }
  }

  void _drawNeck(Canvas canvas, double px, double py) {
    final skinPaint = Paint()..color = config.skinTone;
    final neckShadowPaint = Paint()..color = Colors.black.withOpacity(0.18);

    final neckPath = Path()
      ..moveTo(-16 + px * 0.5, 20 + py * 0.5)
      ..lineTo(-16 + px * 0.4, 55 + py * 0.4)
      ..lineTo(16 + px * 0.4, 55 + py * 0.4)
      ..lineTo(16 + px * 0.5, 20 + py * 0.5)
      ..close();
    canvas.drawPath(neckPath, skinPaint);

    // Chin shadow under jaw
    final chinShadow = Path()
      ..moveTo(-16 + px * 0.5, 20 + py * 0.5)
      ..quadraticBezierTo(px * 0.7, 36 + py * 0.7, 16 + px * 0.5, 20 + py * 0.5)
      ..lineTo(16 + px * 0.5, 26 + py * 0.5)
      ..quadraticBezierTo(px * 0.7, 42 + py * 0.7, -16 + px * 0.5, 26 + py * 0.5)
      ..close();
    canvas.drawPath(chinShadow, neckShadowPaint);
  }

  void _drawHead(Canvas canvas, double px, double py) {
    final skinPaint = Paint()..color = config.skinTone;
    final earShadow = Paint()..color = Colors.black.withOpacity(0.12);

    final headCenterX = px * 0.8;
    final headCenterY = -15 + py * 0.8;

    // Ears (drawn slightly behind head)
    if (config.headwear != 'hijab_wrap') {
      final leftEar = Path()
        ..addOval(Rect.fromCenter(center: Offset(-44 + px * 0.6, -10 + py * 0.8), width: 14, height: 22));
      canvas.drawPath(leftEar, skinPaint);
      canvas.drawCircle(Offset(-44 + px * 0.6, -10 + py * 0.8), 4, earShadow);

      final rightEar = Path()
        ..addOval(Rect.fromCenter(center: Offset(44 + px * 0.6, -10 + py * 0.8), width: 14, height: 22));
      canvas.drawPath(rightEar, skinPaint);
      canvas.drawCircle(Offset(44 + px * 0.6, -10 + py * 0.8), 4, earShadow);
    }

    // 3D Cartoon Head Shape (Soft egg/oval contour with rounded chin)
    final headPath = Path();
    headPath.moveTo(headCenterX, headCenterY - 45); // Top of head
    headPath.cubicTo(
      headCenterX + 45, headCenterY - 45,
      headCenterX + 44, headCenterY + 15,
      headCenterX + 24, headCenterY + 36, // Right jaw
    );
    headPath.cubicTo(
      headCenterX + 14, headCenterY + 44, // Chin curve right
      headCenterX - 14, headCenterY + 44, // Chin curve left
      headCenterX - 24, headCenterY + 36, // Left jaw
    );
    headPath.cubicTo(
      headCenterX - 44, headCenterY + 15,
      headCenterX - 45, headCenterY - 45,
      headCenterX, headCenterY - 45, // Back to top
    );
    canvas.drawPath(headPath, skinPaint);

    // Warm blush on cheeks
    final blushPaint = Paint()
      ..color = const Color(0xFFFF5252).withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(headCenterX - 24, headCenterY + 8), 10, blushPaint);
    canvas.drawCircle(Offset(headCenterX + 24, headCenterY + 8), 10, blushPaint);

    // Freckles for Blonde Sophia
    if (config.id == 'blonde_sophia') {
      final frecklePaint = Paint()..color = const Color(0xFF8D5836).withOpacity(0.4);
      canvas.drawCircle(Offset(headCenterX - 20, headCenterY + 6), 0.8, frecklePaint);
      canvas.drawCircle(Offset(headCenterX - 16, headCenterY + 8), 0.8, frecklePaint);
      canvas.drawCircle(Offset(headCenterX - 22, headCenterY + 10), 0.8, frecklePaint);
      canvas.drawCircle(Offset(headCenterX + 20, headCenterY + 6), 0.8, frecklePaint);
      canvas.drawCircle(Offset(headCenterX + 16, headCenterY + 8), 0.8, frecklePaint);
      canvas.drawCircle(Offset(headCenterX + 22, headCenterY + 10), 0.8, frecklePaint);
    }
  }

  void _drawFaceFeatures(Canvas canvas, double px, double py) {
    final double fx = px * 0.9;
    final double fy = -15 + py * 0.9;

    // Eyebrows
    final browPaint = Paint()
      ..color = config.facialHairColor.withOpacity(0.85)
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    final leftBrow = Path()
      ..moveTo(fx - 28, fy - 14)
      ..quadraticBezierTo(fx - 18, fy - 18, fx - 8, fy - 14);
    canvas.drawPath(leftBrow, browPaint);

    final rightBrow = Path()
      ..moveTo(fx + 8, fy - 14)
      ..quadraticBezierTo(fx + 18, fy - 18, fx + 28, fy - 14);
    canvas.drawPath(rightBrow, browPaint);

    // 3D Cartoon Eyes (Sclera white + Iris + Pupils + Specular Highlights)
    final eyeWhitePaint = Paint()..color = Colors.white;
    final irisPaint = Paint()..color = config.eyeColor;
    final pupilPaint = Paint()..color = const Color(0xFF101010);
    final highlightPaint = Paint()..color = Colors.white;

    // Left Eye
    final leftEyeRect = Rect.fromCenter(center: Offset(fx - 18, fy - 4), width: 18, height: 14);
    canvas.drawOval(leftEyeRect, eyeWhitePaint);
    canvas.drawCircle(Offset(fx - 18 + px * 0.1, fy - 4 + py * 0.1), 5.2, irisPaint);
    canvas.drawCircle(Offset(fx - 18 + px * 0.1, fy - 4 + py * 0.1), 2.8, pupilPaint);
    canvas.drawCircle(Offset(fx - 20, fy - 6), 1.8, highlightPaint); // Sparkle

    // Right Eye
    final rightEyeRect = Rect.fromCenter(center: Offset(fx + 18, fy - 4), width: 18, height: 14);
    canvas.drawOval(rightEyeRect, eyeWhitePaint);
    canvas.drawCircle(Offset(fx + 18 + px * 0.1, fy - 4 + py * 0.1), 5.2, irisPaint);
    canvas.drawCircle(Offset(fx + 18 + px * 0.1, fy - 4 + py * 0.1), 2.8, pupilPaint);
    canvas.drawCircle(Offset(fx + 16, fy - 6), 1.8, highlightPaint); // Sparkle

    // Eyelash contour
    final lashPaint = Paint()
      ..color = const Color(0xFF212121)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    canvas.drawArc(leftEyeRect, 3.4, 2.4, false, lashPaint);
    canvas.drawArc(rightEyeRect, 3.4, 2.4, false, lashPaint);

    // 3D Soft Nose
    final nosePaint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final nosePath = Path()
      ..moveTo(fx - 1, fy + 2)
      ..lineTo(fx, fy + 10)
      ..quadraticBezierTo(fx + 5, fy + 12, fx + 2, fy + 14)
      ..quadraticBezierTo(fx - 2, fy + 14, fx - 4, fy + 12);
    canvas.drawPath(nosePath, nosePaint);

    // Mouth & Expression
    final mouthPaint = Paint()
      ..color = const Color(0xFFB71C1C)
      ..style = PaintingStyle.fill;
    final teethPaint = Paint()..color = Colors.white;

    if (config.expression == 'laugh' || config.expression == 'smile' || config.expression == 'grin') {
      // Big friendly cartoon smile with white teeth
      final smilePath = Path()
        ..moveTo(fx - 16, fy + 22)
        ..quadraticBezierTo(fx, fy + 34, fx + 16, fy + 22)
        ..quadraticBezierTo(fx, fy + 24, fx - 16, fy + 22)
        ..close();
      canvas.drawPath(smilePath, mouthPaint);

      // Teeth row
      final teethPath = Path()
        ..moveTo(fx - 12, fy + 23)
        ..quadraticBezierTo(fx, fy + 27, fx + 12, fy + 23)
        ..quadraticBezierTo(fx, fy + 24, fx - 12, fy + 23)
        ..close();
      canvas.drawPath(teethPath, teethPaint);
    }

    // Facial Hair (Beard, Goatee, Stubble)
    if (config.facialHair == 'goatee') {
      final goateePaint = Paint()..color = config.facialHairColor.withOpacity(0.9);
      // Small neat chin goatee & mustache
      final mustPath = Path()
        ..moveTo(fx - 10, fy + 19)
        ..quadraticBezierTo(fx, fy + 17, fx + 10, fy + 19)
        ..quadraticBezierTo(fx, fy + 21, fx - 10, fy + 19)
        ..close();
      canvas.drawPath(mustPath, goateePaint);

      final chinGoatee = Path()
        ..moveTo(fx - 6, fy + 32)
        ..quadraticBezierTo(fx, fy + 42, fx + 6, fy + 32)
        ..lineTo(fx + 8, fy + 40)
        ..quadraticBezierTo(fx, fy + 45, fx - 8, fy + 40)
        ..close();
      canvas.drawPath(chinGoatee, goateePaint);

    } else if (config.facialHair == 'full_beard') {
      final beardPaint = Paint()..color = config.facialHairColor;
      // Contoured full jawline beard
      final fullBeard = Path()
        ..moveTo(fx - 36, fy + 14)
        ..quadraticBezierTo(fx - 40, fy + 36, fx, fy + 46)
        ..quadraticBezierTo(fx + 40, fy + 36, fx + 36, fy + 14)
        ..quadraticBezierTo(fx + 22, fy + 26, fx + 16, fy + 20)
        ..quadraticBezierTo(fx, fy + 38, fx - 16, fy + 20)
        ..quadraticBezierTo(fx - 22, fy + 26, fx - 36, fy + 14)
        ..close();
      canvas.drawPath(fullBeard, beardPaint);
    }
  }

  void _drawFrontHairAndHeadwear(Canvas canvas, double px, double py) {
    final hairPaint = Paint()..color = config.hairColor;
    final headwearPaint = Paint()..color = config.headwearColor;
    final hx = px * 0.85;
    final hy = -15 + py * 0.85;

    if (config.headwear == 'hijab_wrap' || config.hairStyle == 'hijab') {
      // Elegant draped silk hijab wrap framing the face
      final hijabOuter = Path()
        ..moveTo(hx, hy - 58)
        ..cubicTo(hx + 56, hy - 58, hx + 52, hy + 30, hx + 44, hy + 68)
        ..cubicTo(hx + 20, hy + 76, hx - 20, hy + 76, hx - 44, hy + 68)
        ..cubicTo(hx - 52, hy + 30, hx - 56, hy - 58, hx, hy - 58)
        ..close();
      canvas.drawPath(hijabOuter, headwearPaint);

      // Inner face opening cutout
      final faceOpening = Path()
        ..moveTo(hx, hy - 40)
        ..cubicTo(hx + 38, hy - 40, hx + 36, hy + 18, hx + 22, hy + 36)
        ..cubicTo(hx + 12, hy + 44, hx - 12, hy + 44, hx - 22, hy + 36)
        ..cubicTo(hx - 36, hy + 18, hx - 38, hy - 40, hx, hy - 40)
        ..close();
      canvas.drawPath(faceOpening, Paint()..color = config.skinTone);

      // Hijab fabric fold shadow lines
      final foldPaint = Paint()
        ..color = Colors.black.withOpacity(0.18)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(hx - 30, hy + 30), Offset(hx - 15, hy + 65), foldPaint);
      canvas.drawLine(Offset(hx + 30, hy + 30), Offset(hx + 15, hy + 65), foldPaint);

    } else if (config.headwear == 'backward_cap' || config.hairStyle == 'skater_cap') {
      // Backwards baseball cap with front crown and curved back brim
      final capCrown = Path()
        ..moveTo(hx - 46, hy - 18)
        ..cubicTo(hx - 48, hy - 56, hx + 48, hy - 56, hx + 46, hy - 18)
        ..quadraticBezierTo(hx, hy - 26, hx - 46, hy - 18)
        ..close();
      canvas.drawPath(capCrown, headwearPaint);

      // Cap back adjustable strap opening and button
      final strapCutout = Path()
        ..addOval(Rect.fromCenter(center: Offset(hx, hy - 24), width: 22, height: 10));
      canvas.drawPath(strapCutout, Paint()..color = config.skinTone);

      final buttonPaint = Paint()..color = config.headwearColor.withOpacity(0.8);
      canvas.drawCircle(Offset(hx, hy - 54), 3.5, buttonPaint);

      // Sideburn hair tufts under cap
      final sideburn = Path()
        ..moveTo(hx - 43, hy - 15)
        ..lineTo(hx - 40, hy + 8)
        ..lineTo(hx - 36, hy - 10)
        ..close();
      canvas.drawPath(sideburn, hairPaint);

      final sideburn2 = Path()
        ..moveTo(hx + 43, hy - 15)
        ..lineTo(hx + 40, hy + 8)
        ..lineTo(hx + 36, hy - 10)
        ..close();
      canvas.drawPath(sideburn2, hairPaint);

    } else if (config.hairStyle == 'short_braids') {
      // Braided rows / Dreadlock texture
      final braidPaint = Paint()
        ..color = config.hairColor
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round;

      for (int i = -4; i <= 4; i++) {
        final double bx = hx + i * 9.5;
        final braidPath = Path()
          ..moveTo(bx, hy - 48)
          ..quadraticBezierTo(bx * 0.8, hy - 32, bx, hy - 18);
        canvas.drawPath(braidPath, braidPaint);
      }

    } else if (config.hairStyle == 'teal_undercut') {
      // Modern voluminous rocker quiff with darkened side fade
      final quiffPath = Path()
        ..moveTo(hx - 42, hy - 24)
        ..cubicTo(hx - 50, hy - 60, hx + 10, hy - 68, hx + 48, hy - 48)
        ..cubicTo(hx + 40, hy - 36, hx + 20, hy - 24, hx - 42, hy - 24)
        ..close();
      canvas.drawPath(quiffPath, hairPaint);

      // Side fade texture
      final fadePaint = Paint()..color = config.hairColor.withOpacity(0.4);
      canvas.drawRect(Rect.fromLTWH(hx - 44, hy - 24, 12, 20), fadePaint);
      canvas.drawRect(Rect.fromLTWH(hx + 32, hy - 24, 12, 20), fadePaint);

    } else if (config.hairStyle == 'ponytail') {
      // Sleek front fringe bangs
      final bangs = Path()
        ..moveTo(hx - 44, hy - 20)
        ..cubicTo(hx - 30, hy - 48, hx + 30, hy - 48, hx + 44, hy - 20)
        ..quadraticBezierTo(hx + 10, hy - 28, hx - 44, hy - 20)
        ..close();
      canvas.drawPath(bangs, hairPaint);

    } else if (config.hairStyle == 'blonde_waves' || config.hairStyle == 'grey_wavy') {
      // Voluminous parted waves framing top forehead
      final frontWaves = Path()
        ..moveTo(hx - 46, hy - 18)
        ..cubicTo(hx - 40, hy - 58, hx + 10, hy - 56, hx + 46, hy - 18)
        ..cubicTo(hx + 20, hy - 32, hx - 10, hy - 34, hx - 46, hy - 18)
        ..close();
      canvas.drawPath(frontWaves, hairPaint);
    }
  }

  void _drawGlassesAndAccessories(Canvas canvas, double px, double py) {
    final gx = px * 0.95;
    final gy = -15 + py * 0.95;

    if (config.glasses == 'black_frames') {
      // Stylish thick black nerd/hipster glasses (like Skater Leo)
      final framePaint = Paint()
        ..color = const Color(0xFF1E1E1E)
        ..strokeWidth = 3.2
        ..style = PaintingStyle.stroke;
      final lensGlass = Paint()..color = Colors.white.withOpacity(0.12);

      // Left lens frame
      final leftLens = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(gx - 18, gy - 3), width: 26, height: 18),
        const Radius.circular(4),
      );
      canvas.drawRRect(leftLens, lensGlass);
      canvas.drawRRect(leftLens, framePaint);

      // Right lens frame
      final rightLens = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(gx + 18, gy - 3), width: 26, height: 18),
        const Radius.circular(4),
      );
      canvas.drawRRect(rightLens, lensGlass);
      canvas.drawRRect(rightLens, framePaint);

      // Center bridge & temples
      final bridgePaint = Paint()
        ..color = const Color(0xFF1E1E1E)
        ..strokeWidth = 3.0;
      canvas.drawLine(Offset(gx - 5, gy - 3), Offset(gx + 5, gy - 3), bridgePaint);
      canvas.drawLine(Offset(gx - 31, gy - 3), Offset(gx - 44, gy - 7), bridgePaint);
      canvas.drawLine(Offset(gx + 31, gy - 3), Offset(gx + 44, gy - 7), bridgePaint);

    } else if (config.glasses == 'cyber_visor') {
      // Glowing HUD Visor
      final visorPaint = Paint()
        ..color = CyberTheme.neonBlue.withOpacity(0.65)
        ..style = PaintingStyle.fill;
      final glowBorder = Paint()
        ..color = CyberTheme.neonBlue
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      final visorRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(gx, gy - 3), width: 72, height: 16),
        const Radius.circular(4),
      );
      canvas.drawRRect(visorRect, visorPaint);
      canvas.drawRRect(visorRect, glowBorder);

      // Visor digital scan line
      final scanPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 1;
      canvas.drawLine(Offset(gx - 30, gy - 3), Offset(gx + 30, gy - 3), scanPaint);
    }
  }

  @override
  bool shouldRepaint(covariant BioAvatarPainter oldDelegate) {
    return oldDelegate.config != config ||
        oldDelegate.yaw != yaw ||
        oldDelegate.pitch != pitch ||
        oldDelegate.showBackground != showBackground;
  }
}
