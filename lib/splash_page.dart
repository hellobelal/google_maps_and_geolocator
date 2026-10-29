import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'app_logo.dart';
import 'main.dart';
import 'map_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _intro =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
        ..forward();
  late final AnimationController _loop =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))
        ..repeat();

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => const MapPage(),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
      ));
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = CurvedAnimation(parent: _intro, curve: Curves.elasticOut);
    final fade = CurvedAnimation(
        parent: _intro, curve: const Interval(0.4, 1, curve: Curves.easeIn));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.dark, AppColors.deep, AppColors.primary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // floating bubbles
            AnimatedBuilder(
              animation: _loop,
              builder: (_, __) => CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _BubblePainter(_loop.value),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // pulsing ripple + logo
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _loop,
                          builder: (_, __) {
                            final t = (_loop.value * 2) % 1;
                            return Container(
                              width: 140 + 100 * t,
                              height: 140 + 100 * t,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.5 * (1 - t)),
                                    width: 2),
                              ),
                            );
                          },
                        ),
                        ScaleTransition(
                            scale: scale, child: const AppLogo(size: 140)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: fade,
                    child: Column(
                      children: [
                        const Text('GeoTracker',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5)),
                        const SizedBox(height: 6),
                        Text('Track every step, live.',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 15)),
                        const SizedBox(height: 36),
                        const SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: AppColors.accent),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  final double t;
  _BubblePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 12; i++) {
      final seed = i * 0.083;
      final x = size.width * ((math.sin(i * 12.9898) * 0.5 + 0.5));
      final y = size.height * (1 - ((t + seed) % 1));
      final r = 6.0 + (i % 4) * 5;
      canvas.drawCircle(Offset(x, y), r,
          Paint()..color = Colors.white.withOpacity(0.06 + (i % 3) * 0.03));
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter old) => old.t != t;
}
