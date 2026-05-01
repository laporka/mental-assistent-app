import 'dart:ui';
import 'package:flutter/material.dart';

// Змінюємо на StatefulWidget, щоб керувати станом вибору
class AFourthScreen extends StatefulWidget {
  const AFourthScreen({super.key});

  @override
  State<AFourthScreen> createState() => _AFourthScreenState();
}

class _AFourthScreenState extends State<AFourthScreen> {
  // Тут ми зберігаємо індекси тих кнопок, які вибрав користувач
  final Set<int> _selectedIndices = {};

  // Список твоїх опцій (можеш легко додавати або змінювати їх тут)
  final List<String> _symptoms = [
    'ПТСР',
    'Тривога',
    'Панічна атака',
    'Панічна атака',
    'Панічна атака',
    'Тривога',
    'Панічна атака',
    'Панічна атака',
  ];

  // Допоміжна функція для створення кожної окремої кнопки-чіпа
  Widget _buildChip(int index, String text) {
    final isSelected = _selectedIndices.contains(index);

    return GestureDetector(
      onTap: () {
        setState(() {
          // Якщо вже вибрано — знімаємо виділення, якщо ні — додаємо
          if (isSelected) {
            _selectedIndices.remove(index);
          } else {
            _selectedIndices.add(index);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200), // Плавна анімація кольору
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          // Якщо вибрано — яскравий градієнт, якщо ні — напівпрозорий темний фон
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
                // Зміна кольору тексту: темний для вибраного, білий для не вибраного
                color: isSelected ? const Color(0xFF041219) : const Color(0xFFF9FFFA),
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 1,
              ),
            ),
            // Показуємо галочку тільки якщо елемент вибрано
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
            // --- GLOW ЕФЕКТ (СЯЙВО) ---
            Positioned(
              left: -size.width * 0.1,
              top: -size.height * 0.4,
              child: Container(
                width: size.width * 1.2,
                height: size.height * 0.8,
                decoration: const ShapeDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-0.00, 0.61),
                    end: Alignment(0.54, 1.02),
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
                child: Container(color: Colors.transparent),
              ),
            ),

            // --- ЗАГОЛОВОК ---
            const Positioned(
              left: 40,
              top: 120,
              child: Text(
                'Що вас турбує?',
                style: TextStyle(
                  color: Color(0xFFF9FFFA),
                  fontSize: 24,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1,
                ),
              ),
            ),

            // --- ІНТЕРАКТИВНИЙ СПИСОК ОПЦІЙ ---
            Positioned(
              left: 40,
              top: 170, // Опустили трохи нижче заголовка
              bottom: 140, // Залишаємо місце для нижньої кнопки
              child: SingleChildScrollView(
                // Додаємо скрол, якщо елементів стане забагато
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    _symptoms.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildChip(index, _symptoms[index]),
                    ),
                  ),
                ),
              ),
            ),

            // --- КНОПКА "ПРОДОВЖИТИ ДАЛІ" ---
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    // TODO: Перехід далі. 
                    // Щоб отримати вибрані тексти, можна використати:
                    // final selectedSymptoms = _selectedIndices.map((i) => _symptoms[i]).toList();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 64,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF041219),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        width: 1,
                        color: const Color(0xFF354246),
                      ),
                      // Легка тінь для виділення кнопки
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Продовжити далі',
                      style: TextStyle(
                        color: Color(0xFFBCC4C2),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
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