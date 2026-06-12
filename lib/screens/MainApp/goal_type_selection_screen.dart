import 'dart:ui';
import 'package:flutter/material.dart';

class GoalTypeSelectionScreen extends StatefulWidget {
  final VoidCallback onCancel;
  final Function(int) onNext; 

  const GoalTypeSelectionScreen({
    super.key,
    required this.onCancel,
    required this.onNext,
  });

  @override
  State<GoalTypeSelectionScreen> createState() => _GoalTypeSelectionScreenState();
}

class _GoalTypeSelectionScreenState extends State<GoalTypeSelectionScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scaleX = size.width / 360;
    final double scaleY = size.height / 800;

    return Scaffold(
      backgroundColor: const Color(0xFF041219),
      body: Container(
        width: size.width,
        height: size.height,
        color: const Color(0xFF041219),
        child: Stack(
          children: [
            Positioned(
              left: -17 * scaleX,
              top: -193 * scaleY,
              child: Opacity(
                opacity: 0.20,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 90.0, sigmaY: 90.0),
                  child: Container(
                    width: 393 * scaleX,
                    height: 568 * scaleY,
                    decoration: const ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0.60, 0.83),
                        end: Alignment(0.00, 0.18),
                        colors: [Color(0xFF2BBCFF), Color(0xFF91FFA4), Color(0xFFFFCC00)],
                      ),
                      shape: OvalBorder(),
                    ),
                  ),
                ),
              ),
            ),

            Positioned.fill(
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight, // Розтягує на весь екран
                        ),
                        child: IntrinsicHeight(
                          child: Padding(
                            // Використовуємо фіксовані надійні відступи від країв екрана
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                
                                // ЗАГОЛОВКИ
                                const Text(
                                  'Що хочеш додати?',
                                  style: TextStyle(
                                    color: Color(0xFFF9FFFA),
                                    fontSize: 32,
                                    fontFamily: 'Tenor Sans',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Обери тип — форма буде різною',
                                  style: TextStyle(
                                    color: const Color(0xFFF9FFFA).withOpacity(0.7),
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                
                                const SizedBox(height: 40),

                                _buildSelectionCard(
                                  index: 0,
                                  icon: Icons.track_changes_rounded,
                                  title: 'Ціль',
                                  subtitle1: 'Намір з прогресом і дедлайном',
                                  subtitle2: 'Бігати, читати, вчитися',
                                ),
                                const SizedBox(height: 20),
                                _buildSelectionCard(
                                  index: 1,
                                  icon: Icons.notifications_active_outlined,
                                  title: 'Трекер',
                                  subtitle1: 'Регулярна дія без фінішу',
                                  subtitle2: 'Ліки, вода, вітаміни',
                                ),
                                const Spacer(),
                                const SizedBox(height: 32),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: widget.onCancel,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: const Color(0xFFF9FFFA).withOpacity(0.6), width: 1),
                                            borderRadius: BorderRadius.circular(50),
                                          ),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'Скасувати',
                                            style: TextStyle(
                                              color: Color(0xFFF9FFFA),
                                              fontSize: 18,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => widget.onNext(_selectedIndex),
                                        child: Container(
                                          padding: const EdgeInsets.all(1.5),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(50),
                                            gradient: const LinearGradient(
                                              begin: Alignment.topRight,
                                              end: Alignment.bottomLeft,
                                              colors: [Color(0xFF2BBBFF), Color(0xFF91FFA3), Color(0xFFFFCC00)],
                                            ),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF041219),
                                              borderRadius: BorderRadius.circular(49),
                                            ),
                                            alignment: Alignment.center,
                                            child: const Text(
                                              'Далі',
                                              style: TextStyle(
                                                color: Color(0xFFF9FFFA), 
                                                fontSize: 18,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle1,
    required String subtitle2,
  }) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.only(
          left: isSelected ? 1.5 : 1.0, 
          bottom: isSelected ? 1.5 : 1.0,
          top: 1.0, 
          right: 1.0,
        ), 
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Color(0xFF2BBBFF), Color(0xFF91FFA3), Color(0xFFFFCC00)],
                )
              : null,
          color: isSelected ? null : const Color(0xFF333F44), 
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF041219), 
            borderRadius: BorderRadius.circular(19),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF2BBBFF).withOpacity(0.15),
                        const Color(0xFF91FFA3).withOpacity(0.15),
                        const Color(0xFFFFCC00).withOpacity(0.15),
                      ],
                    )
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF91FFA3) : const Color(0xFF333F44),
                      width: 1.5,
                    ),
                    color: isSelected ? const Color(0x1991FFA3) : Colors.transparent,
                  ),
                  child: Icon(
                    isSelected ? Icons.check : icon, 
                    color: isSelected ? const Color(0xFF91FFA3) : const Color(0xFFBCC4C2),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        // ЗАХИСТ ВІД СИСТЕМНОГО ЗБІЛЬШЕННЯ ШРИФТІВ
                        textScaler: TextScaler.noScaling, 
                        style: const TextStyle(
                          color: Color(0xFFF9FFFA),
                          fontSize: 22,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle1,
                        textScaler: TextScaler.noScaling, // ЗАХИСТ
                        style: const TextStyle(
                          color: Color(0xFFF9FFFA),
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle2,
                        textScaler: TextScaler.noScaling, // ЗАХИСТ
                        style: TextStyle(
                          color: const Color(0xFFF9FFFA).withOpacity(0.5),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}