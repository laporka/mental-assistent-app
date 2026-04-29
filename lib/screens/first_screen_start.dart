import 'package:flutter/material.dart';
import 'dart:ui';
import 'second_screen_hello.dart';

class FirstScreenStart extends StatelessWidget {
  const FirstScreenStart({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF041219),
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            // Градієнтна куля з blur
            Positioned(
              left: -17,
              top: size.height * 0.47,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(
                  width: 393,
                  height: 577,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment(-0.6, 1.0),
                      end: Alignment(0.4, -1.0),
                      colors: [
                        Color(0xFF2BBCFF),
                        Color(0xFF91FFA4),
                        Color(0xFFFFCC00),
                      ],
                      stops: [0.19, 0.55, 0.90],
                    ),
                  ),
                ),
              ),
            ),

            // Текст
            Positioned(
              left: 74,
              top: size.height * 0.35,
              child: const Text(
                'Iris\nМентальний\nАсистент',
                style: TextStyle(
                  fontFamily: 'Playfair',
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFAFFFB),
                  height: 1.1,
                ),
              ),
            ),

            // Кнопка з градієнтним бордером
            Positioned(
              left: 74,
              bottom: size.height * 0.10,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const AFirstScreen()),
                  );
                },
                child: CustomPaint(
                  painter: _GradientBorderPainter(),
                  child: Container(
                    width: 211,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF04131A),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Center(
                      child: Text(
                        'Розпочати',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFFAFFFB),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final radius = Radius.circular(50);
    final rRect = RRect.fromRectAndRadius(rect, radius);

    // Градієнт бордер: 0px top, 2px right, 4px bottom, 0px left
    final gradient = const LinearGradient(
      begin: Alignment(1.0, 0.5),
      end: Alignment(-1.0, -0.5),
      colors: [
        Color(0xFF2BBCFF),
        Color(0xFF91FFA4),
        Color(0xFFFFCC00),
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}