import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/dynamic_glow_button.dart'; // Твій файл з кнопкою

class AFifthScreen extends StatefulWidget {
  const AFifthScreen({super.key});

  @override
  State<AFifthScreen> createState() => _AFifthScreenState();
}

class _AFifthScreenState extends State<AFifthScreen> {
  final Set<int> _selectedIndices = {};

  final List<String> _interests = [
    'Фільми', 'Музика', 'Книги', 'Спорт', 
    'Кулінарія', 'Природа', 'Малювання', 'Наука', 
    'Подорожі', 'Ігри', 'Танці', 'Мистецтво', 'Нічого зараз'
  ];

  Widget _buildInterestChip(int index, String text) {
    final isSelected = _selectedIndices.contains(index);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (index == _interests.length - 1) {
            _selectedIndices.clear();
            _selectedIndices.add(index);
          } else {
            _selectedIndices.remove(_interests.length - 1);
            if (isSelected) {
              _selectedIndices.remove(index);
            } else {
              _selectedIndices.add(index);
            }
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: isSelected ? const Color(0xFF91FFA3) : const Color(0xFF274E3C),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isSelected ? const Color(0xFF041219) : const Color(0xFFF9FFFA),
                fontSize: 18, // Трохи менше для кращого вкладання в ряди
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check_rounded, color: Color(0xFF041219), size: 18),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scaleX = size.width / 360;
    final scaleY = size.height / 800;
    final bool isActive = _selectedIndices.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF041219),
      body: Stack(
        children: [
          // --- 1. СЯЙВО (Новий градієнт: жовтий заповнює ліву частину) ---
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
                    // ТОЧНІ КООРДИНАТИ З ТВОГО ПЛАГІНА
                    begin: Alignment(1.06, 0.59),
                    end: Alignment(0.26, 0.93),
                    colors: [
                      Color(0xFF2BBBFF), 
                      Color(0xFF91FFA3), 
                      Color(0xFFFFCC00)
                    ],
                    // Налаштування для того, щоб жовтий був активнішим зліва
                    stops: [0.0, 0.4, 0.8],
                  ),
                  shape: OvalBorder(),
                ),
              ),
            ),
          ),

          Positioned(
            top: 100 * scaleY,
            left: 40,
            right: 40,
            bottom: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'А що тебе наповнює?',
                  style: TextStyle(
                    color: Color(0xFFF9FFFA),
                    fontSize: 24,
                    fontFamily: 'TenorSans',
                    fontWeight: FontWeight.w400,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 24),
                
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Wrap(
                      // alignment каже, як вирівнювати чіпи в одному рядку
                      alignment: WrapAlignment.start, 
                      // spacing — відстань між чіпами по горизонталі
                      spacing: 8, 
                      // runSpacing — відстань між рядами по вертикалі
                      runSpacing: 8, 
                      children: List.generate(
                        _interests.length,
                        (index) => _buildInterestChip(index, _interests[index]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Column(
              children: [
                DynamicGlowButton(
                  text: 'Продовжити далі',
                  isActive: isActive,
                  onTap: () {
                    // TODO Перехід далі
                  },
                ),
                const SizedBox(height: 20),
                const Opacity(
                  opacity: 0.70,
                  child: Text(
                    'Це завжди можна змінити у профілі',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFF9FFFA),
                      fontSize: 13,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w300,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}