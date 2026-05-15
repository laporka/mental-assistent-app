import 'dart:ui';
import 'package:flutter/material.dart';

class FifthScreenLoading extends StatelessWidget {
  const FifthScreenLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scaleX = size.width / 360;
    final double scaleY = size.height / 800;

    final double ovalWidth = 350 * scaleX;
    final double ovalHeight = 480 * scaleY;
    const double protrude = 29;

    return Scaffold(
      backgroundColor: const Color(0xFF041219),
      body: Stack(
        children: [
          // Top oval — mostly hidden above, peeks 39px down
          Positioned(
            top: -(ovalHeight + protrude),
            left: 0,
            right: 0,
            child: Center(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 75, sigmaY: 75),
                child: Container(
                  width: ovalWidth,
                  height: ovalHeight,
                  decoration: const ShapeDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.0, 1.0),
                      end: Alignment(0.0, -1.0),
                      colors: [
                        Color(0xFF2BBCFF),
                        Color(0xFF91FFA4),
                        Color(0xFFFFCC00),
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                    shape: OvalBorder(),
                  ),
                ),
              ),
            ),
          ),

          // Bottom oval — mostly hidden below, peeks 39px up
          Positioned(
            bottom: -(ovalHeight + protrude),
            left: 0,
            right: 0,
            child: Center(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 75, sigmaY: 75),
                child: Container(
                  width: ovalWidth,
                  height: ovalHeight,
                  decoration: const ShapeDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.0, -1.0),
                      end: Alignment(0.0, 1.0),
                      colors: [
                        Color(0xFFFFCC00),
                        Color(0xFF91FFA4),
                        Color(0xFF2BBCFF),
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                    shape: OvalBorder(),
                  ),
                ),
              ),
            ),
          ),

          // Spinning loader — centred with gradient
          Center(
            child: SizedBox(
              width: 40,
              height: 40,
              child: ShaderMask(
                shaderCallback: (bounds) => const SweepGradient(
                  center: Alignment.center,
                  colors: [
                    Color(0xFF2BBCFF),
                    Color(0xFF91FFA4),
                    Color(0xFFFFCC00),
                    Color(0xFF2BBCFF),
                  ],
                  stops: [0.0, 0.4, 0.8, 1.0],
                ).createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
