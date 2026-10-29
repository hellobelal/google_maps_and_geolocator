import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'main.dart';

/// App logo drawn fully in code (no image asset needed).
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _LogoPainter()),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final c = Offset(s.width / 2, s.height / 2);
    final r = s.width / 2;

    // background circle
    final bg = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.primary, AppColors.accent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawCircle(c, r, bg);

    // radar rings
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.015
      ..color = Colors.white.withOpacity(0.35);
    canvas.drawCircle(c, r * 0.85, ring);
    canvas.drawCircle(c, r * 0.62, ring);

    // route line
    final route = Path()
      ..moveTo(s.width * 0.18, s.height * 0.78)
      ..cubicTo(s.width * 0.3, s.height * 0.62, s.width * 0.42, s.height * 0.86,
          s.width * 0.5, s.height * 0.7);
    canvas.drawPath(
        route,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = s.width * 0.035
          ..color = Colors.white.withOpacity(0.8));

    // pin
    final pinR = s.width * 0.17;
    final pinC = Offset(s.width * 0.5, s.height * 0.40);
    final pin = Path()
      ..addOval(Rect.fromCircle(center: pinC, radius: pinR))
      ..moveTo(pinC.dx - pinR * 0.85, pinC.dy + pinR * 0.55)
      ..lineTo(pinC.dx, s.height * 0.74)
      ..lineTo(pinC.dx + pinR * 0.85, pinC.dy + pinR * 0.55)
      ..close();
    canvas.drawShadow(pin, Colors.black54, 6, true);
    canvas.drawPath(pin, Paint()..color = Colors.white);
    canvas.drawCircle(pinC, pinR * 0.45, Paint()..color = AppColors.deep);

    // small satellite dot
    final a = -math.pi / 4;
    canvas.drawCircle(
        Offset(c.dx + r * 0.85 * math.cos(a), c.dy + r * 0.85 * math.sin(a)),
        s.width * 0.04,
        Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
