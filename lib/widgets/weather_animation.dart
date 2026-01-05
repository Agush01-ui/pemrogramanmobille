import 'package:flutter/material.dart';
import 'dart:math';

/// =======================
/// 🌧️ RAIN ANIMATION
/// =======================
class RainAnimation extends StatelessWidget {
  const RainAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RainPainter(),
      size: const Size(double.infinity, 120),
    );
  }
}

class _RainPainter extends CustomPainter {
  final Random random = Random();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.4)
      ..strokeWidth = 2;

    for (int i = 0; i < 60; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawLine(Offset(x, y), Offset(x + 2, y + 10), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// =======================
/// ☀️ SUN ANIMATION
/// =======================
class SunAnimation extends StatefulWidget {
  const SunAnimation({super.key});

  @override
  State<SunAnimation> createState() => _SunAnimationState();
}

class _SunAnimationState extends State<SunAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: controller,
      child: const Icon(
        Icons.wb_sunny,
        size: 60,
        color: Colors.orangeAccent,
      ),
    );
  }
}
