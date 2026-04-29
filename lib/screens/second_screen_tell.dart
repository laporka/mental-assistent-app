import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AThirdScreen extends StatelessWidget {
  const AThirdScreen({super.key});

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
            Positioned(
              left: -size.width * 0.1,
              top: -size.height * 0.4,
              child: Container(
                width: size.width * 1.2,
                height: size.height * 0.8,
                decoration: const ShapeDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.19, 0.81),
                    end: Alignment(1.00, 0.81),
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

            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 90.0, sigmaY: 90.0),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),

            const Positioned(
              left: 40,
              top: 120, 
              child: SizedBox(
                width: 280,
                child: Text(
                  'Будь ласка розкажіть більше про себе ....',
                  style: TextStyle(
                    color: Color(0xFFF9FFFA),
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    // TODO: Навігація на наступний екран
                  },
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
            ),
          ],
        ),
      ),
    );
  }
}