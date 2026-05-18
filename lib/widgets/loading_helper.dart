import 'dart:ui';
import 'package:flutter/material.dart';

class LoadingHelper {
  static void show(BuildContext context) {
    // Отримуємо розміри екрана для правильного масштабування овалів
    final size = MediaQuery.of(context).size;
    final double scaleX = size.width / 360;
    final double scaleY = size.height / 800;

    final double ovalWidth = 350 * scaleX;
    final double ovalHeight = 480 * scaleY;
    const double protrude = 29;

    showDialog(
      context: context,
      barrierDismissible: false,
      // Робимо фон діалогу напівпрозорим фірмовим темним (щоб попередній екран ледь просвічувався)
      // Або можеш поставити .withOpacity(1.0), якщо хочеш повністю непрозорий фон
      barrierColor: const Color(0xFF041219).withOpacity(0.85),
      builder: (context) {
        // Material потрібен, щоб Stack займав весь екран поверх усього
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // --- 1. ВЕРХНІЙ ОВАЛ ---
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

              // --- 2. НИЖНІЙ ОВАЛ ---
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

              // --- 3. КРУТИЛКА ПО ЦЕНТРУ ---
              Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: ShaderMask(
                    // ВАЖЛИВО: SweepGradient БЕЗ слова const!
                    shaderCallback: (bounds) => SweepGradient(
                      center: Alignment.center,
                      colors: const [
                        Color(0xFF2BBCFF),
                        Color(0xFF91FFA4),
                        Color(0xFFFFCC00),
                        Color(0xFF2BBCFF),
                      ],
                      stops: const [0.0, 0.4, 0.8, 1.0],
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
      },
    );
  }

  // Функція, щоб СХОВАТИ екран завантаження
  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}