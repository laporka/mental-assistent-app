import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../models/daily_task_item.dart';
import '../../models/tracker_model.dart';
import '../../models/goal_model.dart';
import '../../models/diary_record_model.dart';
import '../../widgets/loading_helper.dart';

import '../../widgets/save_tracker.dart';
import '../../widgets/save_goal.dart';
import 'create_tracker_screen.dart';
import 'create_goal_screen.dart';
import 'goal_type_selection_screen.dart';
import 'create_record_screen.dart';


class HomeScreen extends StatefulWidget {
  final Function(String) onNavigateToChat;
  
  const HomeScreen({super.key, required this.onNavigateToChat});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _chatController = TextEditingController();
  
  String? _dailyQuote;
  bool _isLoadingQuote = false;

  Stream<QuerySnapshot>? _trackersStream;
  Stream<QuerySnapshot>? _goalsStream;
  Stream<QuerySnapshot>? _diaryStream;

  bool _isSelectingGoalType = false;
  bool _isCreatingTracker = false;
  bool _isCreatingGoal = false;
  bool _isCreatingRecord = false;

  @override
  void initState() {
    super.initState();
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _trackersStream = FirebaseFirestore.instance.collection('users').doc(uid).collection('trackers').snapshots();
      _goalsStream = FirebaseFirestore.instance.collection('users').doc(uid).collection('goals').snapshots();
      _diaryStream = FirebaseFirestore.instance.collection('users').doc(uid).collection('diary').orderBy('createdAt', descending: true).limit(1).snapshots();
    }
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  Future<void> _fetchDailyQuote() async {
    setState(() => _isLoadingQuote = true);
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('chatWithMentalCoach');
      final result = await callable.call({
        'text': 'Згенеруй одне коротке, надихаюче побажання або мотиваційну думку на сьогодні. 1-2 речення. Без привітань, тільки сам текст.',
        'history': [],
      });
      
      if (mounted) setState(() => _dailyQuote = result.data['response'] as String);
    } catch (e) {
      if (mounted) setState(() => _dailyQuote = "Навіть маленький крок — це рух. Головне — що ти йдеш."); 
    } finally {
      if (mounted) setState(() => _isLoadingQuote = false);
    }
  }

  void _submitMessage() {
    final text = _chatController.text.trim();
    if (text.isNotEmpty) {
      widget.onNavigateToChat(text);
      _chatController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCreatingRecord) {
      return CreateRecordScreen(
        onCancel: () => setState(() => _isCreatingRecord = false),
        onSaveSuccess: () => setState(() => _isCreatingRecord = false),
      );
    }

    if (_isCreatingTracker) {
      return CreateTrackerScreen(
        onCancel: () => setState(() => _isCreatingTracker = false),
        onCreate: (newTracker) async {
          bool success = await saveTrackerToFirebase(context: context, tracker: newTracker);
          if (success && mounted) setState(() => _isCreatingTracker = false);
        },
      );
    }

    if (_isCreatingGoal) {
      return CreateGoalScreen(
        onCancel: () => setState(() => _isCreatingGoal = false),
        onCreate: (newGoal) async {
          bool success = await saveGoalToFirebase(context: context, goal: newGoal);
          if (success && mounted) setState(() => _isCreatingGoal = false);
        },
      );
    }

    if (_isSelectingGoalType) {
      return GoalTypeSelectionScreen(
        onCancel: () => setState(() => _isSelectingGoalType = false),
        onNext: (int selectedType) {
          setState(() {
            _isSelectingGoalType = false;
            if (selectedType == 0) _isCreatingGoal = true;
            else _isCreatingTracker = true;
          });
        },
      );
    }

    final size = MediaQuery.of(context).size;
    final double scaleX = size.width / 360;
    final double scaleY = size.height / 800;
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF041219),
      body: Stack(
        children: [
          Positioned(
            left: -94 * scaleX,
            top: -252 * scaleY,
            child: Opacity(
              opacity: 0.50,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 80.0, sigmaY: 80.0),
                child: Container(
                  width: 322 * scaleX,
                  height: 467 * scaleY,
                  decoration: const ShapeDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.65, 0.94),
                      end: Alignment(-0.02, 0.59),
                      colors: [Color(0xFF2BBBFF), Color(0xFF91FFA3), Color(0xFFFFCC00)],
                    ),
                    shape: OvalBorder(),
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 24, height: 24,
                        decoration: const BoxDecoration(color: Color(0xFF04131A), shape: BoxShape.circle),
                        child: const Center(child: Icon(Icons.question_mark_rounded, color: Color(0xFFF9FFFA), size: 16)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Привіт! \nЯк ти сьогодні?',
                      style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 24, fontFamily: 'Tenor Sans', fontWeight: FontWeight.w400, height: 1.2),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFF9FFFA),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                      child: TextField(
                        controller: _chatController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _submitMessage(),
                        style: const TextStyle(color: Color(0xFF041219), fontSize: 16, fontFamily: 'Inter'),
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Привіт! Я ...',
                          hintStyle: const TextStyle(color: Color(0xFFBCC4C2), fontSize: 16, fontFamily: 'Inter'),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), 
                          suffixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                          suffixIcon: GestureDetector(
                            onTap: _submitMessage,
                            child: const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(Icons.send_rounded, color: Color(0xFFBCC4C2), size: 20),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildDailyQuoteSection(),
                    const SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Тиждень', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 20, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                        Text(_getFormattedMonthYear(_selectedDate), style: const TextStyle(color: Color(0xFFBCC4C2), fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w400)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (uid != null && _trackersStream != null && _goalsStream != null)
                      StreamBuilder<QuerySnapshot>(
                        stream: _trackersStream,
                        builder: (context, trackersSnapshot) {
                          return StreamBuilder<QuerySnapshot>(
                            stream: _goalsStream,
                            builder: (context, goalsSnapshot) {
                              if (trackersSnapshot.connectionState == ConnectionState.waiting || goalsSnapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator(color: Color(0xFF2BBBFF)));
                              }

                              final trackerDocs = trackersSnapshot.data?.docs ?? [];
                              final goalDocs = goalsSnapshot.data?.docs ?? [];
                              List<DailyTaskItem> dailyTasks = _parseDataForDate(_selectedDate, trackerDocs, goalDocs);

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDynamicWeeklyCalendar(trackerDocs, goalDocs),
                                  const SizedBox(height: 32),
                                  const Text('Задачі на сьогодні', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 20, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 16),
                                  
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder: (Widget child, Animation<double> animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SlideTransition(
                                          position: Tween<Offset>(begin: const Offset(0.0, 0.05), end: Offset.zero).animate(animation),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      key: ValueKey<String>(_selectedDate.toIso8601String()),
                                      width: double.infinity,
                                      child: dailyTasks.isEmpty
                                          ? const Text('На цей день задач немає. Відпочивай!', style: TextStyle(color: Color(0xFFBCC4C2), fontSize: 16, fontFamily: 'Inter'))
                                          : Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: dailyTasks.map((task) => _buildHomeTaskCard(task)).toList(),
                                            ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      ),
                    const SizedBox(height: 32),

                    const Text('Останій запис щоденника', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 20, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    
                    if (uid != null && _diaryStream != null)
                      StreamBuilder<QuerySnapshot>(
                        stream: _diaryStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF2BBBFF)));
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Text('У вас ще немає записів у щоденнику.', style: TextStyle(color: Color(0xFFBCC4C2), fontSize: 16, fontFamily: 'Inter'));
                          return _buildHomeDiaryCard(DiaryRecordModel.fromFirestore(snapshot.data!.docs.first));
                        },
                      ),

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            right: 20 * scaleX,
            bottom: 33,
            child: _HomeExpandableFab(
              onCreateGoal: () => setState(() => _isSelectingGoalType = true),
              onCreateRecord: () => setState(() => _isCreatingRecord = true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicWeeklyCalendar(List<QueryDocumentSnapshot> trackerDocs, List<QueryDocumentSnapshot> goalDocs) {
    final days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд'];
    final today = DateTime.now();
    DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    List<DateTime> weekDates = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        DateTime date = weekDates[index];
        bool isSelected = date.year == _selectedDate.year && date.month == _selectedDate.month && date.day == _selectedDate.day;
        bool isToday = date.year == today.year && date.month == today.month && date.day == today.day;

        final tasksForDay = _parseDataForDate(date, trackerDocs, goalDocs);
        final Map<String, bool> taskCompletionMap = {};
        final Map<String, int> taskColorMap = {};

        for (var t in tasksForDay) {
          taskColorMap[t.id] = t.colorValue;
          if (!taskCompletionMap.containsKey(t.id)) taskCompletionMap[t.id] = t.isCompleted;
          else if (!t.isCompleted) taskCompletionMap[t.id] = false;
        }
        final dotIds = taskCompletionMap.keys.take(4).toList();

        return GestureDetector(
          onTap: () => setState(() => _selectedDate = date),
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: [
              Text(days[index], style: const TextStyle(color: Color(0xFFF9FFFA), fontSize: 14, fontFamily: 'Inter')),
              const SizedBox(height: 12),
              Container(
                width: 36, height: 36,
                decoration: isSelected 
                    ? BoxDecoration(
                        color: const Color(0x1991FFA4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF91FFA4), width: 1.5),
                      )
                    : null,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      '${date.day}',
                      style: TextStyle(color: isSelected || isToday ? const Color(0xFFF9FFFA) : const Color(0xFFBCC4C2), fontSize: 14, fontFamily: 'Inter'),
                    ),
                    if (dotIds.isNotEmpty)
                      Positioned(
                        bottom: 4,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: dotIds.map((id) {
                            final isCompleted = taskCompletionMap[id]!;
                            final color = Color(taskColorMap[id]!);
                            return Container(
                              width: 4, height: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 1.5),
                              decoration: BoxDecoration(shape: BoxShape.circle, color: isCompleted ? color : Colors.transparent, border: Border.all(color: color, width: isCompleted ? 0 : 1)),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  String _getFormattedMonthYear(DateTime date) {
    const months = ['Січень', 'Лютий', 'Березень', 'Квітень', 'Травень', 'Червень', 'Липень', 'Серпень', 'Вересень', 'Жовтень', 'Листопад', 'Грудень'];
    return '${months[date.month - 1]} ${date.year}';
  }

  Widget _buildDailyQuoteSection() {
    if (_dailyQuote != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(color: const Color(0x19FAFFFB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        child: Text(_dailyQuote!, style: const TextStyle(color: Color(0xFFF9FFFA), fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w400, height: 1.4)),
      );
    }

    return GestureDetector(
      onTap: _isLoadingQuote ? null : _fetchDailyQuote,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: ShapeDecoration(color: const Color(0x19FAFFFB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoadingQuote)
              const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Color(0xFF91FFA4), strokeWidth: 2))
            else ...[
              const Icon(Icons.auto_awesome, color: Color(0xFF91FFA4), size: 28),
              const SizedBox(width: 12),
              const Text('Отримай\nпобажання дня', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w500, height: 1.2)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTaskCard(DailyTaskItem task) {
    final Color itemColor = Color(task.colorValue);
    final Color titleColor = task.isCompleted ? const Color(0xFF041219) : const Color(0xFFF9FFFA);
    final Color subtitleColor = task.isCompleted ? const Color(0x99041219) : const Color(0xFFBCC4C2);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: task.isCompleted ? EdgeInsets.zero : const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: task.isCompleted
            ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2BBBFF), Color(0xFF91FFA4), Color(0xFFFFCC00)])
            : LinearGradient(colors: [itemColor, itemColor]), 
      ),
      child: GestureDetector(
        onTap: () => _toggleTaskCompletion(task), 
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: task.isCompleted ? Colors.transparent : const Color(0xFF1D2A30),
            borderRadius: task.isCompleted ? BorderRadius.circular(20) : const BorderRadius.horizontal(right: Radius.circular(20), left: Radius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.time, style: TextStyle(color: subtitleColor, fontSize: 12, fontFamily: 'Inter')),
                    const SizedBox(height: 4),
                    Text(task.title, style: TextStyle(color: titleColor, fontSize: 20, fontFamily: 'Inter', fontWeight: FontWeight.w400)),
                    if (task.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(task.subtitle, style: TextStyle(color: subtitleColor, fontSize: 12, fontFamily: 'Inter')),
                    ]
                  ],
                ),
              ),
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isCompleted ? const Color(0x33041219) : Colors.transparent,
                  border: Border.all(color: task.isCompleted ? Colors.transparent : const Color(0xFF333F44), width: task.isCompleted ? 0 : 1.5),
                ),
                child: task.isCompleted ? const Icon(Icons.check, color: Color(0xFF041219), size: 24) : null,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeDiaryCard(DiaryRecordModel record) {
    String dateStr = DateFormat('dd.MM.yyyy').format(record.createdAt);
    String timeStr = DateFormat('HH:mm').format(record.createdAt);

    return Container(
      padding: const EdgeInsets.only(left: 1.5, bottom: 1.5), 
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF2BBBFF), Color(0xFF91FFA3), Color(0xFFFFCC00)]),
      ),
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFF041219), borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0x19FAFFFB), borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dateStr, style: const TextStyle(color: Color(0xFFF9FFFA), fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w300)),
                  Text(timeStr, style: const TextStyle(color: Color(0xFFF9FFFA), fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w300)),
                ],
              ),
              const SizedBox(height: 12),
              Text(record.content, maxLines: 4, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFF9FFFA), fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w400, height: 1.4)),
              if (record.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: record.tags.take(4).map((tag) { 
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF4B895E), borderRadius: BorderRadius.circular(100)),
                      child: Text(tag, style: const TextStyle(color: Color(0xFFF9FFFA), fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w300)),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<DailyTaskItem> _parseDataForDate(DateTime targetDate, List<QueryDocumentSnapshot> trackerDocs, List<QueryDocumentSnapshot> goalDocs) {
    List<DailyTaskItem> tasks = [];
    String dateKey = DateFormat('yyyy-MM-dd').format(targetDate);

    for (var doc in trackerDocs) {
      final tracker = TrackerModel.fromFirestore(doc);
      final data = doc.data() as Map<String, dynamic>;
      bool isActiveToday = tracker.isDaily || tracker.selectedDays.contains(targetDate.weekday);
      final createdDateOnly = DateTime(tracker.createdAt.year, tracker.createdAt.month, tracker.createdAt.day);
      final targetDateOnly = DateTime(targetDate.year, targetDate.month, targetDate.day);
      if (targetDateOnly.isBefore(createdDateOnly)) isActiveToday = false;

      if (isActiveToday && tracker.isLimitedCourse && tracker.courseDuration != null) {
        int durationInDays = tracker.courseDuration!;
        if (tracker.courseDurationType == 'Тиждень') durationInDays *= 7;
        if (tracker.courseDurationType == 'Місяць') durationInDays *= 30; 
        final end = createdDateOnly.add(Duration(days: durationInDays - 1));
        if (targetDateOnly.isAfter(end)) isActiveToday = false;
      }

      if (isActiveToday) {
        List<String> completedLogs = List<String>.from(data['completedLogs'] ?? []);
        List<String> timesToGenerate = [];
        if (tracker.isIntervalTime && tracker.intervalStart != null && tracker.intervalEnd != null) {
          int startH = int.parse(tracker.intervalStart!.split(':')[0]);
          int endH = int.parse(tracker.intervalEnd!.split(':')[0]);
          int step = tracker.intervalValue ?? 2; 
          for (int h = startH; h <= endH; h += step) timesToGenerate.add('${h.toString().padLeft(2, '0')}:00');
        } else {
          timesToGenerate = tracker.reminderTimes;
        }

        for (int i = 0; i < timesToGenerate.length; i++) {
          String time = timesToGenerate[i];
          String uniqueLogKey = '${dateKey}_$time'; 
          bool isCompleted = completedLogs.contains(uniqueLogKey);
          String subtitle = tracker.isIntervalTime ? 'Кожні ${tracker.intervalValue} год' : '${timesToGenerate.length} рази в день';
          tasks.add(DailyTaskItem(id: tracker.id!, type: 'tracker', title: tracker.title, subtitle: subtitle, time: timesToGenerate.length > 1 ? '$time (${i + 1})' : time, colorValue: tracker.colorValue, isCompleted: isCompleted));
        }
      }
    }

    for (var doc in goalDocs) {
      final goal = GoalModel.fromFirestore(doc);
      final data = doc.data() as Map<String, dynamic>;
      bool isActiveToday = goal.isDaily || goal.selectedDays.contains(targetDate.weekday);
      final createdDateOnly = DateTime(goal.createdAt.year, goal.createdAt.month, goal.createdAt.day);
      final targetDateOnly = DateTime(targetDate.year, targetDate.month, targetDate.day);
      if (targetDateOnly.isBefore(createdDateOnly)) isActiveToday = false;

      if (isActiveToday) {
        if (goal.deadlineType == 'date' && goal.endDate != null) {
          final end = DateTime(goal.endDate!.year, goal.endDate!.month, goal.endDate!.day);
          if (targetDateOnly.isAfter(end)) isActiveToday = false;
        } else if (goal.deadlineType == 'period' && goal.periodDuration != null) {
          int durationInDays = goal.periodDuration!;
          if (goal.periodDurationType == 'Тиждень') durationInDays *= 7;
          if (goal.periodDurationType == 'Місяць') durationInDays *= 30; 
          final end = createdDateOnly.add(Duration(days: durationInDays - 1));
          if (targetDateOnly.isAfter(end)) isActiveToday = false;
        }
      }

      if (isActiveToday) {
        List<String> completedLogs = List<String>.from(data['completedLogs'] ?? []);
        List<String> timesToGenerate = goal.reminderTimes.isNotEmpty ? goal.reminderTimes : ['09:00'];
        for (int i = 0; i < timesToGenerate.length; i++) {
          String time = timesToGenerate[i];
          String uniqueLogKey = '${dateKey}_$time'; 
          bool isCompleted = completedLogs.contains(uniqueLogKey);
          tasks.add(DailyTaskItem(id: goal.id!, type: 'goal', title: goal.title, subtitle: '', time: timesToGenerate.length > 1 ? '$time (${i + 1})' : time, colorValue: goal.colorValue, isCompleted: isCompleted));
        }
      }
    }

    tasks.sort((a, b) => a.time.compareTo(b.time));
    return tasks;
  }

  Future<void> _toggleTaskCompletion(DailyTaskItem task) async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    String pureTime = task.time.split(' ')[0]; 
    String dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    String uniqueLogKey = '${dateKey}_$pureTime';
    DocumentReference docRef = FirebaseFirestore.instance.collection('users').doc(uid).collection(task.type == 'tracker' ? 'trackers' : 'goals').doc(task.id);
    LoadingHelper.show(context);
    try {
      if (task.isCompleted) await docRef.update({'completedLogs': FieldValue.arrayRemove([uniqueLogKey])});
      else await docRef.update({'completedLogs': FieldValue.arrayUnion([uniqueLogKey])});
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Помилка оновлення: $e')));
    } finally {
      if (mounted) LoadingHelper.hide(context);
    }
  }
}

class _HomeExpandableFab extends StatefulWidget {
  final VoidCallback onCreateRecord;
  final VoidCallback onCreateGoal;

  const _HomeExpandableFab({required this.onCreateRecord, required this.onCreateGoal});

  @override
  State<_HomeExpandableFab> createState() => _HomeExpandableFabState();
}

class _HomeExpandableFabState extends State<_HomeExpandableFab> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _expandAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) _controller.forward();
      else _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: FadeTransition(
            opacity: _expandAnimation,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildSubButton(
                title: 'Щоденник',
                icon: Icons.edit,
                onTap: () {
                  _toggle();
                  widget.onCreateRecord();
                },
              ),
            ),
          ),
        ),
        
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: FadeTransition(
            opacity: _expandAnimation,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildSubButton(
                title: 'Задача',
                icon: Icons.notifications_active_outlined,
                onTap: () {
                  _toggle();
                  widget.onCreateGoal();
                },
              ),
            ),
          ),
        ),

        GestureDetector(
          onTap: _toggle,
          child: Container(
            width: 72, height: 72, padding: const EdgeInsets.all(1.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2BBBFF), Color(0xFF91FFA4), Color(0xFFFFCC00)]),
              boxShadow: [BoxShadow(color: Color(0x3F041319), blurRadius: 20, offset: Offset(0, 2))],
            ),
            child: Container(
              decoration: const BoxDecoration(color: Color(0xFF041219), shape: BoxShape.circle),
              child: Center(
                child: AnimatedRotation(
                  turns: _isOpen ? 0.125 : 0, 
                  duration: const Duration(milliseconds: 250),
                  child: const Icon(Icons.add, color: Colors.white, size: 32),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubButton({required String title, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2BBBFF), Color(0xFF91FFA4), Color(0xFFFFCC00)], // Наш фірмовий градієнт
          ),
          boxShadow: const [BoxShadow(color: Color(0x3F041319), blurRadius: 10, offset: Offset(0, 2))],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF041219),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFFF9FFFA), size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Color(0xFFF9FFFA), fontSize: 14, fontFamily: 'Inter')),
            ],
          ),
        ),
      ),
    );
  }
}