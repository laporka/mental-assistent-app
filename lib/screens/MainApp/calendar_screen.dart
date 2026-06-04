import 'dart:ui';
import 'package:flutter/material.dart';
import '../../widgets/dynamic_glow_button.dart';
import '../../widgets/loading_helper.dart';
import '../../widgets/save_tracker.dart';
import '../../widgets/save_goal.dart';
import 'create_tracker_screen.dart';
import 'create_goal_screen.dart';
import 'goal_type_selection_screen.dart';

class CalendarHomeScreen extends StatefulWidget {
  const CalendarHomeScreen({super.key});

  @override
  State<CalendarHomeScreen> createState() => _CalendarHomeScreenState();
}

class _CalendarHomeScreenState extends State<CalendarHomeScreen> {
  bool _isSelectingType = false;
  bool _isCreatingTracker = false;
  bool _isCreatingGoal = false;
  bool _isCalendarExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (_isCreatingTracker) {
      return CreateTrackerScreen(
        onCancel: () => setState(() => _isCreatingTracker = false),
        onCreate: (newTracker) async {
          bool success = await saveTrackerToFirebase(
            context: context,
            tracker: newTracker,
          );
          if (success && mounted) {
            setState(() => _isCreatingTracker = false);
          }
        },
      );
    }

    if (_isCreatingGoal) {
      return CreateGoalScreen(
        onCancel: () => setState(() => _isCreatingGoal = false),
        onCreate: (newGoal) async {
          bool success = await saveGoalToFirebase(
            context: context,
            goal: newGoal,
          );
          if (success && mounted) {
            setState(() => _isCreatingGoal = false);
          }
        },
      );
    }

    if (_isSelectingType) {
      return GoalTypeSelectionScreen(
        onCancel: () => setState(() => _isSelectingType = false),
        onNext: (int selectedType) {
          if (selectedType == 0) {
            setState(() {
              _isSelectingType = false;
              _isCreatingGoal = true;
            });
          } else {
            setState(() {
              _isSelectingType = false;
              _isCreatingTracker = true;
            });
          }
        },
      );
    }

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
                      colors: [Color(0xFFFFCC00), Color(0xFF91FFA4), Color(0xFF2BBCFF)],
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
            child: _CalendarWidget(
              isExpanded: _isCalendarExpanded,
              onToggleExpand: () =>
                  setState(() => _isCalendarExpanded = !_isCalendarExpanded),
            ),
          ),

          Positioned(
            top: 340,
            left: 40,
            right: 40,
            child: AnimatedOpacity(
              opacity: _isCalendarExpanded ? 0 : 1,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: _isCalendarExpanded,
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
                  await Future.delayed(const Duration(milliseconds: 500));
                  if (context.mounted) {
                    LoadingHelper.hide(context);
                    setState(() => _isSelectingType = true);
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
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  const _CalendarWidget({
    required this.isExpanded,
    required this.onToggleExpand,
  });

  @override
  State<_CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<_CalendarWidget> {
  late DateTime _weekStart;
  late DateTime _monthStart;
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
    final ws = now.subtract(Duration(days: now.weekday - 1));
    _weekStart = DateTime(ws.year, ws.month, ws.day);
    _monthStart = DateTime(now.year, now.month, 1);
  }

  @override
  void didUpdateWidget(_CalendarWidget old) {
    super.didUpdateWidget(old);
    if (!old.isExpanded && widget.isExpanded) {
      // When expanding, sync month to the week currently shown
      _monthStart = DateTime(_weekStart.year, _weekStart.month, 1);
    }
  }

  void _prev() => setState(() {
        _direction = -1;
        if (widget.isExpanded) {
          _monthStart = DateTime(_monthStart.year, _monthStart.month - 1, 1);
        } else {
          _weekStart = _weekStart.subtract(const Duration(days: 7));
        }
      });

  void _next() => setState(() {
        _direction = 1;
        if (widget.isExpanded) {
          _monthStart = DateTime(_monthStart.year, _monthStart.month + 1, 1);
        } else {
          _weekStart = _weekStart.add(const Duration(days: 7));
        }
      });

  List<DateTime> _buildWeekDays() =>
      List.generate(7, (i) => _weekStart.add(Duration(days: i)));

  List<DateTime> _buildMonthDays() {
    final firstDay = DateTime(_monthStart.year, _monthStart.month, 1);
    final lastDay = DateTime(_monthStart.year, _monthStart.month + 1, 0);

    final days = <DateTime>[];
    // Pad from previous month
    for (int i = firstDay.weekday - 1; i > 0; i--) {
      days.add(firstDay.subtract(Duration(days: i)));
    }
    // Current month
    for (int d = 1; d <= lastDay.day; d++) {
      days.add(DateTime(_monthStart.year, _monthStart.month, d));
    }
    // Pad to fill last row
    final target = days.length <= 35 ? 35 : 42;
    int extra = 1;
    while (days.length < target) {
      days.add(lastDay.add(Duration(days: extra++)));
    }
    return days;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isToday(DateTime d) => _isSameDay(d, DateTime.now());

  @override
  Widget build(BuildContext context) {
    final displayMonth = widget.isExpanded ? _monthStart : _weekStart;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFFFB).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Header row: < Month / Year >
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
                    _months[displayMonth.month - 1],
                    style: const TextStyle(
                      color: Color(0xFFF9FFFA),
                      fontSize: 18,
                      fontFamily: 'Tenor Sans',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    '${displayMonth.year}',
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

          // Day-name row
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
            child: widget.isExpanded
                ? _buildGrid(_buildMonthDays(),
                    key: ValueKey('month-$_monthStart'),
                    inMonthCheck: (d) => d.month == _monthStart.month)
                : _buildGrid(_buildWeekDays(),
                    key: ValueKey('week-$_weekStart'),
                    inMonthCheck: (d) => d.month == _weekStart.month),
          ),

          // Expand / collapse arrow
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: GestureDetector(
                onTap: widget.onToggleExpand,
                child: AnimatedRotation(
                  turns: widget.isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFFF9FFFA),
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(
    List<DateTime> days, {
    required Key key,
    required bool Function(DateTime) inMonthCheck,
  }) {
    final rows = <Widget>[];
    for (int r = 0; r < days.length ~/ 7; r++) {
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          7,
          (c) => _buildCell(days[r * 7 + c], inMonth: inMonthCheck(days[r * 7 + c])),
        ),
      ));
    }
    return Column(key: key, children: rows);
  }

  Widget _buildCell(DateTime date, {required bool inMonth}) {
    final selected = _isSameDay(date, _selectedDate);
    final today = _isToday(date);
    final highlighted = selected || today;

    return GestureDetector(
      onTap: () => setState(() => _selectedDate = date),
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: highlighted
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
              color: inMonth ? const Color(0xFFF9FFFA) : const Color(0xFF4A6670),
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
