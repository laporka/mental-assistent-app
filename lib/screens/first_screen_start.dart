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
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AFirstScreen(),
            ),
          );
        },
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Stack(
            children: [
              Positioned(
                bottom: -size.height * 0.15,
                left: -size.width * 0.2,
                right: -size.width * 0.2,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                  child: Container(
                    height: size.height * 0.65,
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

              Positioned(
                top: size.height * 0.35,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 280,
                    child: const Text(
                      'Iris\nМентальний\nАсистент',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: 'Tenor Sans',
                        fontSize: 40,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFFAFFFB),
                        height: 1.1, 
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Center(
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
                            'Продовжити далі',
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
                          'Продовжити далі',
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
            ],
          ),
        ),
      ),
    );
  }
}