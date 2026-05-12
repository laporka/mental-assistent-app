import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:test_app/screens/third_screen_interests.dart';
import '../widgets/dynamic_glow_button.dart'; // Наша винесена кнопка
// import 'next_screen.dart'; // Підключи наступний екран

class AFourthScreen extends StatefulWidget {
  const AFourthScreen({super.key});

  @override
  State<AFourthScreen> createState() => _AFourthScreenState();
}

class _AFourthScreenState extends State<AFourthScreen> {
  final Set<int> _selectedIndices = {};

  final List<String> _options = [
    'Тривога',
    'Самотність',
    'Стрес',
    'Панічні атаки',
    'ПТСР',
    'Втома',
    'Труднощі зі сном',
    'Нічого конкретного',
  ];

  Widget _buildChip(int index, String text) {
    final isSelected = _selectedIndices.contains(index);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (index == _options.length - 1) {
            _selectedIndices.clear();
            _selectedIndices.add(index);
          } else {
            _selectedIndices.remove(_options.length - 1);
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
          // Тільки зелена замальовка для вибраного, темно-зелена для неактивного
          color: isSelected ? const Color(0xFF91FFA3) : const Color(0xFF274E3C),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isSelected ? const Color(0xFF041219) : const Color(0xFFF9FFFA),
                fontSize: 20,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check_rounded, color: Color(0xFF041219), size: 20),
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
                    begin: Alignment(-0.8, -0.6), 
                    end: Alignment(0.8, 0.6),
                    colors: [
                      Color(0xFF2BBBFF),
                      Color(0xFF91FFA3),
                      Color(0xFF91FFA3),
                      Color(0xFFFFCC00),
                    ],
                    stops: [0.0, 0.3, 0.85, 1.0], 
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
                  'Що зараз найважче?',
                  style: TextStyle(
                    color: Color(0xFFF9FFFA),
                    fontSize: 24,
                    fontFamily: 'Tenor Sans',
                    fontWeight: FontWeight.w400,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Можна обрати кілька',
                  style: TextStyle(
                    color: Color(0xFFC9D0CE),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 28),
                
                // Інтерактивний прокручуваний список
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        _options.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildChip(index, _options[index]),
                        ),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AFifthScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Opacity(
                  opacity: 0.70,
                  child: Text(
                    'Ці відповіді не є діагнозом\nВони допомагають мені зрозуміти тебе',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFF9FFFA),
                      fontSize: 13,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w300,
                      height: 1.2,
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