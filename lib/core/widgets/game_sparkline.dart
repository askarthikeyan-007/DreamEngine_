import 'dart:math';
import 'package:flutter/material.dart';

class GameSparkline extends StatelessWidget {
  final List<double> data;
  final bool isPositive;
  final double width;
  final double height;

  const GameSparkline({
    super.key,
    required this.data,
    required this.isPositive,
    this.width = 100,
    this.height = 36,
  });

  @override
  Widget build(BuildContext context) {
    if (data.length < 2) return SizedBox(width: width, height: height);

    return CustomPaint(
      size: Size(width, height),
      painter: _SparklinePainter(
        data: data,
        color: isPositive ? const Color(0xFF00FF88) : const Color(0xFFFF1E27),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  // Cached Paint objects to prevent heap allocations during repaint cycles
  final Paint _paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0
    ..strokeCap = StrokeCap.round;

  final Paint _glowPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4.0
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

  _SparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    _paint.color = color;
    _glowPaint.color = color.withOpacity(0.35);

    double minVal = data.reduce(min);
    double maxVal = data.reduce(max);
    double valRange = maxVal - minVal;
    if (valRange == 0) valRange = 1.0;

    final double stepX = size.width / (data.length - 1);
    final Path path = Path();

    for (int i = 0; i < data.length; i++) {
      double x = i * stepX;
      double normalizedY = (data[i] - minVal) / valRange;
      double y = size.height - (normalizedY * (size.height - 4) + 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, _glowPaint);
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.color != color;
  }
}
