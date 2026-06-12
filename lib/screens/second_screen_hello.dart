import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'second_screen_help.dart';

class AFirstScreen extends StatelessWidget {
  const AFirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    final double scaleX = size.width / 360;
    final double scaleY = size.height / 800;

    return Scaffold(
      backgroundColor: const Color(0xFF041219),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ASecondScreen(),
            ),
          );
        },
        child: Stack(
          children: [
            Positioned(
              left: -17 * scaleX,
              top: -416 * scaleY,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 120.0, sigmaY: 120.0), 
                child: Container(
                  width: 393 * scaleX,
                  height: 577 * scaleY,
                  decoration: const ShapeDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.19, 0.81),
                      end: Alignment(0.68, -0.03),
                      colors: [
                        Color(0xFF2BBBFF), 
                        Color(0xFF91FFA3), 
                        Color(0xFFFFCC00)
                      ],
                    ),
                    shape: OvalBorder(),
                  ),
                ),
              ),
            ),

            Positioned(
              left: 40,
              top: 100 * scaleY, 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Вітаю! Я Iris',
                    style: TextStyle(
                      color: Color(0xFFF9FFFA),
                      fontSize: 24,
                      fontFamily: 'Tenor Sans',
                      fontWeight: FontWeight.w400,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Твій ментальний асистент',
                    style: TextStyle(
                      color: Color(0xFFC9D0CE),
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Opacity(
                      opacity: 0.80,
                      child: Text(
                        'Натисніть, щоб продовжити',
                        style: TextStyle(
                          color: Color(0xFFF9FFFA),
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w300,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Opacity(
                      opacity: 0.50,
                      child: SvgPicture.asset(
                        'assets/icons/ion_finger-print.svg',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}