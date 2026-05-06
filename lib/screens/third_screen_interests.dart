import 'dart:ui';
import 'package:flutter/material.dart';

import '../widgets/touch_glow_button.dart';

class AFifthScreen extends StatefulWidget {
  const AFifthScreen({super.key});

  @override
  State<AFifthScreen> createState() => _AFifthScreenState();
}

class _AFifthScreenState extends State<AFifthScreen> {
  final Set<int> _selectedIndices = {};

  final List<String> _interests = [
    'Фільми',
    'Книги',
    'Кулінарія',
    'Спорт',
    'Наука',
    'Танці',
    'Рибалка',
    'Походи',
    'Інше',
  ];

  Widget _buildChip(int index, String text) {
    final isSelected = _selectedIndices.contains(index);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedIndices.remove(index);
          } else {
            _selectedIndices.add(index);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF2BBBFF),
                    Color(0xFF91FFA3),
                    Color(0xFFFFCC00)
                  ],
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.05)
                  ],
                ),
          border: isSelected
              ? null
              : Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isSelected ? const Color(0xFF041219) : const Color(0xFFF9FFFA),
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 1,
              ),
            ),

            if (isSelected) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.check_rounded,
                size: 18,
                color: Color(0xFF041219),
              ),
            ],
          ],
        ),
      ),
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
              left: -size.width * 0.1,
              top: -size.height * 0.4,
              child: Container(
                width: size.width * 1.2,
                height: size.height * 0.8,
                decoration: const ShapeDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(1.06, 0.59),
                    end: Alignment(0.26, 0.93),
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

            // --- ЗАГОЛОВОК ---
            const Positioned(
              left: 40,
              top: 120,
              child: Text(
                'Чим ви цікавитись ?',
                style: TextStyle(
                  color: Color(0xFFF9FFFA),
                  fontSize: 24,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1,
                ),
              ),
            ),

            Positioned(
              left: 40,
              top: 170,
              bottom: 140,
              child: SizedBox(
                width: 280,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.start,
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(
                      _interests.length,
                      (index) => _buildChip(index, _interests[index]),
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
                child: TouchGlowButton(
                  text: 'Продовжити далі',
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => const AFifthScreen(),
                    //   ),
                    // );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}