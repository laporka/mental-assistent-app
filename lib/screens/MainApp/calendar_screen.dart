import 'dart:ui';
import 'package:flutter/material.dart';
import '../../widgets/dynamic_glow_button.dart';
import '../../widgets/loading_helper.dart';


class CalendarHomeScreen extends StatelessWidget {
  const CalendarHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scaleX = size.width / 360;
    final double scaleY = size.height / 800;

    return Container(
      width: size.width,
      height: size.height,
      color: const Color(0xFF041219),
      child: Stack(
        children: [
          Positioned(
            left: -(363 * scaleX - 50),
            top: -(577 * scaleY - 450),
            child: Opacity(
              opacity: 0.5,
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
          ),

          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Center(
                  child: Text(
                    'Календар',
                    style: TextStyle(
                      color: Color(0xFFF9FFFA),
                      fontSize: 24,
                      fontFamily: 'Tenor Sans',
                      fontWeight: FontWeight.w400,
                      height: 1,
                    ),
                  ),
                ),
                Positioned(
                  right: 40,
                  child: GestureDetector(
                    onTap: () {},
                    child: const Text(
                      '?',
                      style: TextStyle(
                        color: Color(0xFFF9FFFA),
                        fontSize: 24,
                        fontFamily: 'Tenor Sans',
                        fontWeight: FontWeight.w400,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: const _CalendarWidget(),
          ),

          Positioned(
            top: 340,
            left: 40,
            right: 40,
            child: const Text(
              'Тут живе твій ритм\nПостав ціль і стеж за прогресом\nДодай нагадування щоб не забути',
              style: TextStyle(
                color: Color(0xFFF9FFFA),
                fontSize: 28,
                fontFamily: 'Tenor Sans',
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
          ),

          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: DynamicGlowButton(
                text: 'Створити першу ціль',
                isActive: true,
                onTap: () async {
                  LoadingHelper.show(context);

                  await Future.delayed(const Duration(milliseconds: 1500));

                  if (context.mounted) {
                    LoadingHelper.hide(context);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Тут відкриється екран створення цілі!')),
                    );
                    
                    // Коли екран буде готовий, розкоментуєш це:
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => const GoalCreateScreen()),
                    // );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarWidget extends StatefulWidget {
  const _CalendarWidget();

  @override
  State<_CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<_CalendarWidget> {
  late DateTime _weekStart;
  DateTime _selectedDate = DateTime.now();
  int _direction = 1;

  static const _months = [
    'Січень', 'Лютий', 'Березень', 'Квітень',
    'Травень', 'Червень', 'Липень', 'Серпень',
    'Вересень', 'Жовтень', 'Листопад', 'Грудень',
  ];
  static const _days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _weekStart = now.subtract(Duration(days: now.weekday - 1));
    _weekStart = DateTime(_weekStart.year, _weekStart.month, _weekStart.day);
  }

  void _prev() => setState(() {
        _direction = -1;
        _weekStart = _weekStart.subtract(const Duration(days: 7));
      });

  void _next() => setState(() {
        _direction = 1;
        _weekStart = _weekStart.add(const Duration(days: 7));
      });

  List<DateTime> _buildDays() =>
      List.generate(7, (i) => _weekStart.add(Duration(days: i)));

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final days = _buildDays();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFFFB).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _prev,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.chevron_left, color: Color(0xFFF9FFFA), size: 22),
                ),
              ),
              Column(
                children: [
                  Text(
                    _months[_weekStart.month - 1],
                    style: const TextStyle(
                      color: Color(0xFFF9FFFA),
                      fontSize: 18,
                      fontFamily: 'Tenor Sans',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    '${_weekStart.year}',
                    style: const TextStyle(
                      color: Color(0xFFF9FFFA),
                      fontSize: 13,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _next,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.chevron_right, color: Color(0xFFF9FFFA), size: 22),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Day name row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _days
                .map((d) => SizedBox(
                      width: 36,
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            color: Color(0xFFF9FFFA),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),

          const SizedBox(height: 4),

          // Grid with slide+fade animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, anim) {
              final offset = Tween<Offset>(
                begin: Offset(_direction.toDouble() * 0.3, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut));
              return SlideTransition(
                position: offset,
                child: FadeTransition(opacity: anim, child: child),
              );
            },
            child: _buildGrid(days),
          ),

          // Chevron down
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: GestureDetector(
                onTap: () {},
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFFF9FFFA),
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<DateTime> days) {
    final rows = <Widget>[];
    for (int r = 0; r < days.length ~/ 7; r++) {
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (c) => _buildCell(days[r * 7 + c])),
      ));
    }
    return Column(key: ValueKey(_weekStart), children: rows);
  }

  Widget _buildCell(DateTime date) {
    final inMonth = date.month == _weekStart.month;
    final selected = _isSameDay(date, _selectedDate);

    return GestureDetector(
      onTap: () => setState(() => _selectedDate = date),
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: selected
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFF1A3D2B),
                border: Border.all(color: const Color(0xFF91FFA4), width: 1.5),
              )
            : null,
        child: Center(
          child: Text(
            '${date.day}',
            style: TextStyle(
              color: inMonth
                  ? const Color(0xFFF9FFFA)
                  : const Color(0xFF4A6670),
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}