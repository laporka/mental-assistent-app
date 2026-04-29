import 'package:flutter/material.dart';
import 'dart:ui';
import 'first_screen_start.dart';

class FirstScreenSplash extends StatefulWidget {
  const FirstScreenSplash({super.key});

  @override
  State<FirstScreenSplash> createState() => _FirstScreenSplashState();
}

class _FirstScreenSplashState extends State<FirstScreenSplash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const FirstScreenStart()),
        );
      }
    });
  }

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
            // Та сама куля що і в first_screen_start
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
          ],
        ),
      ),
    );
  }
}