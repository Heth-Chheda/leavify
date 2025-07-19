import 'package:flutter/material.dart';
import 'dart:math' as math;

class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter({this.animationValue = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    // Full screen background gradient
    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.blue.shade600,
          Colors.blue.shade400,
          Colors.cyan.shade300,
          Colors.blue.shade200,
          Colors.blue.shade100,
          Colors.grey.shade50,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // Main diagonal wave layer
    _drawMainDiagonalWave(canvas, size);

    // Secondary diagonal wave layer
    _drawSecondaryDiagonalWave(canvas, size);

    // Tertiary diagonal wave layer
    _drawTertiaryDiagonalWave(canvas, size);

    // Add foam/bubble effects along diagonal
    _drawDiagonalFoamEffect(canvas, size);

    // Add sparkles throughout
    _drawDiagonalSparkles(canvas, size);

    // Add flowing particles along diagonal
    _drawDiagonalFlowingParticles(canvas, size);
  }

  void _drawMainDiagonalWave(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.blue.shade800,
          Colors.blue.shade600,
          Colors.cyan.shade400,
          Colors.blue.shade300.withOpacity(0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final waveOffset = math.sin(animationValue * 2 * math.pi) * 20;

    // Start from top left corner
    path.moveTo(0, 0);

    // Create diagonal wave flowing from top-left to bottom-right
    final points = <Offset>[];

    // Generate points along diagonal with wave distortion
    for (int i = 0; i <= 20; i++) {
      final t = i / 20.0;
      final baseX = t * size.width;
      final baseY = t * size.height * 0.7; // Cover 70% of diagonal

      // Add wave distortion perpendicular to diagonal
      final wavePhase = t * 4 * math.pi + animationValue * 2 * math.pi;
      final amplitude = 30 + 20 * math.sin(t * 2 * math.pi);
      final perpOffset = math.sin(wavePhase) * amplitude;

      // Calculate perpendicular direction to diagonal
      final diagAngle = math.atan2(size.height, size.width);
      final perpAngle = diagAngle + math.pi / 2;

      final x = baseX + math.cos(perpAngle) * perpOffset;
      final y = baseY + math.sin(perpAngle) * perpOffset;

      points.add(Offset(x, y));
    }

    // Create smooth curve through points
    if (points.isNotEmpty) {
      path.lineTo(points[0].dx, points[0].dy);

      for (int i = 1; i < points.length - 1; i++) {
        final current = points[i];
        final next = points[i + 1];
        final controlX = current.dx + (next.dx - current.dx) * 0.5;
        final controlY = current.dy + (next.dy - current.dy) * 0.5;

        path.quadraticBezierTo(current.dx, current.dy, controlX, controlY);
      }

      if (points.length > 1) {
        path.lineTo(points.last.dx, points.last.dy);
      }
    }

    // Complete the shape by going to corners
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Add wave highlight along the diagonal
    final highlightPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.white.withOpacity(0.4), Colors.transparent],
        begin: Alignment.topLeft,
        end: Alignment.center,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final highlightPath = Path();
    highlightPath.moveTo(0, 0);

    // Create highlight along upper part of diagonal
    for (int i = 0; i <= 10; i++) {
      final t = i / 10.0;
      final x = t * size.width;
      final y = t * size.height * 0.4;
      final wavePhase = t * 3 * math.pi + animationValue * 2 * math.pi;
      final perpOffset = math.sin(wavePhase) * 15;

      final diagAngle = math.atan2(size.height, size.width);
      final perpAngle = diagAngle + math.pi / 2;

      final finalX = x + math.cos(perpAngle) * perpOffset;
      final finalY = y + math.sin(perpAngle) * perpOffset;

      if (i == 0) {
        highlightPath.lineTo(finalX, finalY);
      } else {
        highlightPath.lineTo(finalX, finalY);
      }
    }

    highlightPath.lineTo(size.width, 0);
    highlightPath.close();

    canvas.drawPath(highlightPath, highlightPaint);
  }

  void _drawSecondaryDiagonalWave(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.blue.shade500.withOpacity(0.8),
          Colors.cyan.shade300.withOpacity(0.6),
          Colors.teal.shade200.withOpacity(0.4),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();

    // Start from top left
    path.moveTo(0, 0);

    // Secondary wave with different phase and smaller coverage
    for (int i = 0; i <= 15; i++) {
      final t = i / 15.0;
      final baseX = t * size.width;
      final baseY = t * size.height * 0.5; // Cover 50% of diagonal

      final wavePhase = t * 3 * math.pi + (animationValue + 0.3) * 2 * math.pi;
      final amplitude = 20 + 15 * math.sin(t * 3 * math.pi);
      final perpOffset = math.sin(wavePhase) * amplitude;

      final diagAngle = math.atan2(size.height, size.width);
      final perpAngle = diagAngle + math.pi / 2;

      final x = baseX + math.cos(perpAngle) * perpOffset;
      final y = baseY + math.sin(perpAngle) * perpOffset;

      path.lineTo(x, y);
    }

    // Complete the shape
    path.lineTo(size.width * 0.5, size.height * 0.5);
    path.lineTo(size.width * 0.3, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawTertiaryDiagonalWave(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.cyan.shade200.withOpacity(0.6),
          Colors.blue.shade200.withOpacity(0.4),
          Colors.white.withOpacity(0.3),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();

    path.moveTo(0, 0);

    // Tertiary wave with smallest coverage
    for (int i = 0; i <= 12; i++) {
      final t = i / 12.0;
      final baseX = t * size.width;
      final baseY = t * size.height * 0.3; // Cover 30% of diagonal

      final wavePhase = t * 5 * math.pi + (animationValue + 0.6) * 2 * math.pi;
      final amplitude = 15 + 10 * math.sin(t * 4 * math.pi);
      final perpOffset = math.sin(wavePhase) * amplitude;

      final diagAngle = math.atan2(size.height, size.width);
      final perpAngle = diagAngle + math.pi / 2;

      final x = baseX + math.cos(perpAngle) * perpOffset;
      final y = baseY + math.sin(perpAngle) * perpOffset;

      path.lineTo(x, y);
    }

    path.lineTo(size.width * 0.3, size.height * 0.3);
    path.lineTo(size.width * 0.2, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawDiagonalFoamEffect(Canvas canvas, Size size) {
    final foamPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // Create foam bubbles along diagonal wave crests
    for (int i = 0; i < 20; i++) {
      final t = i / 20.0;
      final progress = (t + animationValue * 0.5) % 1.0;

      // Position along diagonal
      final baseX = progress * size.width;
      final baseY = progress * size.height * 0.6;

      // Add wave distortion
      final wavePhase = progress * 4 * math.pi + animationValue * 2 * math.pi;
      final perpOffset = math.sin(wavePhase) * 25;

      final diagAngle = math.atan2(size.height, size.width);
      final perpAngle = diagAngle + math.pi / 2;

      final x = baseX + math.cos(perpAngle) * perpOffset;
      final y = baseY + math.sin(perpAngle) * perpOffset;

      final radius =
          1.5 + math.sin((animationValue + i * 0.2) * 3 * math.pi) * 1.0;

      canvas.drawCircle(Offset(x, y), radius, foamPaint);
    }
  }

  void _drawDiagonalSparkles(Canvas canvas, Size size) {
    final sparklePaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Draw sparkles along diagonal flow
    for (int i = 0; i < 12; i++) {
      final t = i / 12.0;
      final progress = (t + animationValue * 0.3) % 1.0;

      final x = progress * size.width;
      final y = progress * size.height * 0.4;

      final sparklePhase = (animationValue + i * 0.25) * 6 * math.pi;
      final sparkleSize = 2.0 + math.sin(sparklePhase) * 1.5;
      final opacity = 0.6 + 0.4 * math.sin(sparklePhase);

      sparklePaint.color = Colors.white.withOpacity(opacity * 0.9);

      // Draw sparkle as a cross
      canvas.drawLine(
        Offset(x - sparkleSize, y),
        Offset(x + sparkleSize, y),
        sparklePaint,
      );
      canvas.drawLine(
        Offset(x, y - sparkleSize),
        Offset(x, y + sparkleSize),
        sparklePaint,
      );
    }
  }

  void _drawDiagonalFlowingParticles(Canvas canvas, Size size) {
    final particlePaint = Paint()
      ..color = Colors.cyan.shade100.withOpacity(0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    // Create flowing particles along diagonal
    for (int i = 0; i < 25; i++) {
      final t = i / 25.0;
      final progress = (t + animationValue * 0.8 + i * 0.03) % 1.0;

      final baseX = progress * size.width;
      final baseY = progress * size.height * 0.5;

      // Add some randomness to particle positions
      final waveY = math.sin(progress * 3 * math.pi + i * 0.5) * 30;
      final waveX = math.cos(progress * 2 * math.pi + i * 0.3) * 20;

      final x = baseX + waveX;
      final y = baseY + waveY;

      final radius = 0.8 + math.sin((progress + i * 0.2) * 5 * math.pi) * 0.4;
      final opacity = math.sin(progress * math.pi) * 0.7;

      particlePaint.color = Colors.cyan.shade100.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is WavePainter &&
        oldDelegate.animationValue != animationValue;
  }
}
