import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/main_navigation_screen.dart';
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
    _startAppLogic();
  }

  Future<void> _startAppLogic() async {
    // Чекаємо фіксовані 2 секунди для красивої заставки
    await Future.delayed(const Duration(seconds: 2));

    final currentUser = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (currentUser == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const FirstScreenStart()),
      );
      return;
    }

    // СЦЕНАРІЙ 2: Користувач авторизований, йдемо в головне меню
    // (Нам не обов'язково перевіряти базу на сплеші, 
    // бо ChatTabWrapper всередині MainNavigationScreen 
    // сам чудово впорається з перевіркою колекції 'coach_chat')
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
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
          ],
        ),
      ),
    );
  }
}