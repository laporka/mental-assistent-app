import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'fifth_screen_loading.dart';

class SixthScreenDiary extends StatelessWidget {
  const SixthScreenDiary({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scaleX = size.width / 360;
    final double scaleY = size.height / 800;

    return Scaffold(
      backgroundColor: const Color(0xFF041219),
      body: Stack(
        children: [
          // Gradient glow — same as fourth screen
          Positioned(
            left: -17 * scaleX,
            top: -416 * scaleY,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 75.0, sigmaY: 75.0),
              child: Container(
                width: 363 * scaleX,
                height: 577 * scaleY,
                decoration: const ShapeDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.19, -0.03),
                    end: Alignment(0.68, 0.81),
                    colors: [
                      Color(0xFFFFCC00),
                      Color(0xFF91FFA4),
                      Color(0xFF2BBCFF),
                    ],
                  ),
                  shape: OvalBorder(),
                ),
              ),
            ),
          ),

          // Text — slightly above centre, adaptive width
          Positioned(
            top: size.height * 0.35,
            left: 40,
            right: 118,
            child: const Text(
              'Це твій щоденник в який ти можеш записувати усе що захочеш',
              style: TextStyle(
                color: Color(0xFFF9FFFA),
                fontSize: 24,
                fontFamily: 'Tenor Sans',
                fontWeight: FontWeight.w400,
                height: 1.1,
              ),
            ),
          ),

          // Pencil SVG — 40px from right, overlaps text
          Positioned(
            right: 40,
            top: size.height * 0.35 + 96,
            child: SvgPicture.asset(
              'assets/icons/pencil.svg',
              width: 88,
              height: 88,
            ),
          ),

          // Button — same style as "Продовжити далі" in first_screen_start
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FifthScreenLoading(),
                    ),
                  );
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.translate(
                      offset: const Offset(1, 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 64),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          gradient: const LinearGradient(
                            begin: Alignment(0.97, -0.23),
                            end: Alignment(-0.97, 0.23),
                            colors: [
                              Color(0xFF2BBCFF),
                              Color(0xFF91FFA4),
                              Color(0xFFFFCC00),
                            ],
                            stops: [0.0, 0.5, 1.0],
                          ),
                        ),
                        child: const Text(
                          'Зробити перший запис',
                          style: TextStyle(
                            color: Colors.transparent,
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 64),
                      decoration: BoxDecoration(
                        color: const Color(0xFF041219),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Text(
                        'Зробити перший запис',
                        style: TextStyle(
                          color: Color(0xFFF9FFFA),
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
