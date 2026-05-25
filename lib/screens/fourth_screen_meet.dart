import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/loading_helper.dart';
import '../models/user_data.dart';
import '../widgets/main_navigation_screen.dart';
import '../widgets/save_user_to_firebase.dart';

class ASixthScreen extends StatelessWidget {

  const ASixthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scaleX = size.width / 360;
    final double scaleY = size.height / 800;

    return Scaffold(
      backgroundColor: const Color(0xFF041219),
      body: Stack(
        children: [
          // Gradient glow
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

          // "Приємно познайомитися"
          Positioned(
            left: 40,
            top: 100 * scaleY,
            width: 280 * scaleX,
            child: const Text(
              'Приємно\nпознайомитися',
              style: TextStyle(
                color: Color(0xFFF9FFFA),
                fontSize: 24,
                fontFamily: 'Tenor Sans',
                fontWeight: FontWeight.w400,
                height: 1,
              ),
            ),
          ),

          // User name
          Positioned(
            left: 263 * scaleX,
            top: 176 * scaleY,
            child: Text(
              UserData.userName,
              style: const TextStyle(
                color: Color(0xFFF9FFFA),
                fontSize: 24,
                fontFamily: 'Tenor Sans',
                fontWeight: FontWeight.w400,
                height: 1,
              ),
            ),
          ),

          // Fingerprint button
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  LoadingHelper.show(context);
                  await saveUserToFirebase();
                  if (!context.mounted) return; 

                  LoadingHelper.hide(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainNavigationScreen(),
                    ),
                  );
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
    );
  }
}