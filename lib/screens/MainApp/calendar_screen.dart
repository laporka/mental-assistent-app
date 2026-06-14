import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/notification_service.dart';
import '../../widgets/loading_helper.dart';
import '../../widgets/save_tracker.dart';
import '../../widgets/save_goal.dart';
import 'create_tracker_screen.dart';
import 'create_goal_screen.dart';
import 'goal_type_selection_screen.dart';
import '../../models/daily_task_item.dart';
import '../../models/tracker_model.dart';
import '../../models/goal_model.dart';

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
  
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
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

    if (_isSelectingType) {
      return GoalTypeSelectionScreen(
        onCancel: () => setState(() => _isSelectingType = false),
        onNext: (int selectedType) {
          setState(() {
            _isSelectingType = false;
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

    return Container(
      width: size.width,
      height: size.height,
      color: const Color(0xFF041219),
      child: Stack(
        children: [
          Positioned(
            left: -(363 * scaleX - 50), top: -(577 * scaleY - 450),
            child: Opacity(
              opacity: 0.5,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 75.0, sigmaY: 75.0),
                child: Container(
                  width: 363 * scaleX, height: 577 * scaleY,
                  decoration: const ShapeDecoration(
                    gradient: LinearGradient(begin: Alignment(0.19, -0.03), end: Alignment(0.68, 0.81), colors: [Color(0xFFFFCC00), Color(0xFF91FFA4), Color(0xFF2BBCFF)]),
                    shape: OvalBorder(),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 60, left: 0, right: 0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Center(child: Text('Календар', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 24, fontFamily: 'Tenor Sans'))),
                Positioned(right: 40, child: GestureDetector(onTap: () {}, child: const Text('?', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 24, fontFamily: 'Tenor Sans')))),
              ],
            ),
          ),

          Positioned.fill(
            top: 120,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (uid != null)
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('trackers').snapshots(),
                      builder: (context, trackersSnapshot) {
                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('goals').snapshots(),
                          builder: (context, goalsSnapshot) {
                            
                            final trackerDocs = trackersSnapshot.data?.docs ?? [];
                            final goalDocs = goalsSnapshot.data?.docs ?? [];

                            // Вираховуємо задачі для вибраної дати
                            List<DailyTaskItem> dailyTasks = _parseDataForDate(_selectedDate, trackerDocs, goalDocs);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // КАЛЕНДАР (Тепер передаємо йому функцію для пошуку задач на будь-який день)
                                _CalendarWidget(
                                  isExpanded: _isCalendarExpanded,
                                  selectedDate: _selectedDate,
                                  onDateSelected: (date) => setState(() => _selectedDate = date),
                                  onToggleExpand: () => setState(() => _isCalendarExpanded = !_isCalendarExpanded),
                                  getTasksForDate: (date) => _parseDataForDate(date, trackerDocs, goalDocs),
                                ),
                                
                                const SizedBox(height: 32),

                                // ЗАДАЧІ АБО ПУСТИЙ СТАН
                                if (dailyTasks.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 40),
                                    child: AnimatedOpacity(
                                      opacity: _isCalendarExpanded ? 0 : 1, duration: const Duration(milliseconds: 200),
                                      child: IgnorePointer(
                                        ignoring: _isCalendarExpanded,
                                        child: const Text('Тут живе твій ритм\nПостав ціль і стеж за прогресом\nДодай нагадування щоб не забути', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 28, fontFamily: 'Tenor Sans', height: 1.2)),
                                      ),
                                    ),
                                  )
                                else ...[
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 40),
                                    child: Text('Задачі на сьогодні', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 20, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTasksList(dailyTasks),
                                ],

                                // ПРОГРЕС
                                if (trackerDocs.isNotEmpty || goalDocs.isNotEmpty) ...[
                                  const SizedBox(height: 32),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 40),
                                    child: Text('Прогрес', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 20, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildProgressSection(trackerDocs, goalDocs),
                                ],
                                const SizedBox(height: 120),
                              ],
                            );
                          },
                        );
                      }
                    ),
                ],
              ),
            ),
          ),

          Positioned(
            right: 20 * scaleX, bottom: 33,         
            child: GestureDetector(
              onTap: () => setState(() => _isSelectingType = true), 
              child: Container(
                width: 72, height: 72, padding: const EdgeInsets.all(1.5),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2BBBFF), Color(0xFF91FFA4), Color(0xFFFFCC00)]),
                  boxShadow: [BoxShadow(color: Color(0x3F041319), blurRadius: 20, offset: Offset(0, 2))],
                ),
                child: Container(
                  decoration: const BoxDecoration(color: Color(0xFF041219), shape: BoxShape.circle),
                  child: const Center(child: Icon(Icons.add, color: Color(0xFFF9FFFA), size: 32)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(List<DailyTaskItem> tasks) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(children: tasks.map((task) => _buildTaskCard(task)).toList()),
    );
  }

  Widget _buildTaskCard(DailyTaskItem task) {
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Трохи зменшили horizontal padding для крапок
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
              
              // Блок Галочка + Три крапки
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted ? const Color(0x33041219) : Colors.transparent,
                      border: Border.all(color: task.isCompleted ? Colors.transparent : const Color(0xFF333F44), width: task.isCompleted ? 0 : 1.5),
                    ),
                    child: task.isCompleted ? const Icon(Icons.check, color: Color(0xFF041219), size: 24) : null,
                  ),
                  const SizedBox(width: 4),
                  
                  // Меню з крапками
                  Theme(
                    data: Theme.of(context).copyWith(
                      cardColor: const Color(0xFF041319), // Фон випадаючого меню
                    ),
                    child: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: titleColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFF1D2A30)),
                      ),
                      onSelected: (value) {
                        if (value == 'delete') {
                          _showDeleteConfirmationDialog(task);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: Color(0xFFE27B58), size: 20),
                              SizedBox(width: 8),
                              Text('Видалити', style: TextStyle(color: Color(0xFFE27B58), fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(DailyTaskItem task) async {
    String confirmationText = '';
    
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final bool isMatch = confirmationText.trim().toLowerCase() == task.title.trim().toLowerCase();
            
            return AlertDialog(
              backgroundColor: const Color(0xFF1D2A30),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Видалення', style: TextStyle(color: Color(0xFFF9FFFA), fontFamily: 'Tenor Sans', fontSize: 24)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Color(0xFFBCC4C2), fontSize: 14, fontFamily: 'Inter', height: 1.4),
                      children: [
                        const TextSpan(text: 'Щоб видалити назавжди, введіть назву:\n'),
                        TextSpan(text: task.title, style: const TextStyle(color: Color(0xFFF9FFFA), fontWeight: FontWeight.bold, fontSize: 16)),
                      ]
                    )
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (val) => setState(() => confirmationText = val),
                    style: const TextStyle(color: Color(0xFFF9FFFA), fontSize: 16, fontFamily: 'Inter'),
                    decoration: InputDecoration(
                      hintText: 'Введіть назву',
                      hintStyle: const TextStyle(color: Color(0xFF4B895E), fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFF041219),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Скасувати', style: TextStyle(color: Color(0xFFBCC4C2), fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                ),
                TextButton(
                  onPressed: isMatch ? () => Navigator.of(context).pop(true) : null,
                  child: Text('Видалити', style: TextStyle(
                    color: isMatch ? const Color(0xFFE27B58) : const Color(0xFFE27B58).withOpacity(0.3), 
                    fontFamily: 'Inter', 
                    fontWeight: FontWeight.w600
                  )),
                ),
              ],
            );
          }
        );
      }
    );

    if (shouldDelete == true) {
      _deleteTask(task);
    }
  }

  Future<void> _deleteTask(DailyTaskItem task) async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    
    LoadingHelper.show(context);
    try {
      String collection = task.type == 'tracker' ? 'trackers' : 'goals';
      await FirebaseFirestore.instance.collection('users').doc(uid).collection(collection).doc(task.id).delete();

      String pureTime = task.time.split(' ')[0];
      await NotificationService().cancelReminder('${task.id}_$pureTime'.hashCode);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Помилка: $e')));
    } finally {
      if (mounted) LoadingHelper.hide(context);
    }
  }

  Widget _buildProgressSection(List<QueryDocumentSnapshot> trackerDocs, List<QueryDocumentSnapshot> goalDocs) {
    List<Widget> progressCards = [];

    for (var doc in trackerDocs) {
      final tracker = TrackerModel.fromFirestore(doc);
      final data = doc.data() as Map<String, dynamic>;
      List<String> completedLogs = List<String>.from(data['completedLogs'] ?? []);

      int durationDays = tracker.courseDuration ?? 30; 
      if (tracker.courseDurationType == 'Тиждень') durationDays *= 7;
      if (tracker.courseDurationType == 'Місяць') durationDays *= 30;

      int timesPerDay = tracker.isIntervalTime ? 4 : tracker.reminderTimes.length; 
      if (timesPerDay == 0) timesPerDay = 1;
      int totalExpected = durationDays * timesPerDay;
      
      double percentage = (completedLogs.length / totalExpected) * 100;
      if (percentage > 100) percentage = 100;

      String scheduleText = tracker.isDaily ? 'Щодня' : 'Дні тижня';
      if (!tracker.isIntervalTime && tracker.reminderTimes.isNotEmpty) scheduleText += '  ${tracker.reminderTimes.join(', ')}';
      
      final endDate = tracker.createdAt.add(Duration(days: durationDays - 1));
      String endText = 'до ${DateFormat('dd.02').format(endDate)}';

      progressCards.add(_buildProgressCard(title: tracker.title, percentage: percentage.toInt(), schedule: scheduleText, deadline: endText, colorValue: tracker.colorValue));
    }

    for (var doc in goalDocs) {
      final goal = GoalModel.fromFirestore(doc);
      final data = doc.data() as Map<String, dynamic>;
      List<String> completedLogs = List<String>.from(data['completedLogs'] ?? []);

      int durationDays = goal.periodDuration ?? 30;
      if (goal.periodDurationType == 'Тиждень') durationDays *= 7;
      if (goal.periodDurationType == 'Місяць') durationDays *= 30;

      int timesPerDay = goal.reminderTimes.isNotEmpty ? goal.reminderTimes.length : 1;
      int totalExpected = durationDays * timesPerDay;

      double percentage = (completedLogs.length / totalExpected) * 100;
      if (percentage > 100) percentage = 100;

      String scheduleText = goal.isDaily ? 'Щодня' : 'Дні тижня';
      if (goal.reminderTimes.isNotEmpty) scheduleText += '  ${goal.reminderTimes.join(', ')}';

      String endText = 'без фінішу';
      if (goal.deadlineType == 'date' && goal.endDate != null) endText = 'до ${DateFormat('dd.MM').format(goal.endDate!)}';
      else if (goal.deadlineType == 'period' && goal.periodDuration != null) {
        final end = goal.createdAt.add(Duration(days: durationDays - 1));
        endText = 'до ${DateFormat('dd.MM').format(end)}';
      }

      progressCards.add(_buildProgressCard(title: goal.title, percentage: percentage.toInt(), schedule: scheduleText, deadline: endText, colorValue: goal.colorValue));
    }

    return Padding(padding: const EdgeInsets.symmetric(horizontal: 40), child: Column(children: progressCards));
  }

  Widget _buildProgressCard({required String title, required int percentage, required String schedule, required String deadline, required int colorValue}) {
    final Color itemColor = Color(colorValue);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.only(left: 3), 
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: itemColor),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Color(0xFF1D2A30), borderRadius: BorderRadius.horizontal(right: Radius.circular(20), left: Radius.circular(17))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFFF9FFFA), fontSize: 20, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                Text('$percentage%', style: TextStyle(color: percentage == 100 ? const Color(0xFF91FFA4) : const Color(0xFFFFCC00), fontSize: 24, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(value: percentage / 100, minHeight: 4, backgroundColor: const Color(0xFF333F44), valueColor: AlwaysStoppedAnimation<Color>(itemColor)),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(schedule, style: const TextStyle(color: Color(0xFFBCC4C2), fontSize: 12, fontFamily: 'Inter')),
                Text(deadline, style: const TextStyle(color: Color(0xFFBCC4C2), fontSize: 12, fontFamily: 'Inter')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- ТЕПЕР ФУНКЦІЯ ПРИЙМАЄ ДАТУ ЯК АРГУМЕНТ ---
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

          tasks.add(DailyTaskItem(
            id: tracker.id!, type: 'tracker', title: tracker.title, subtitle: subtitle,
            time: timesToGenerate.length > 1 ? '$time (${i + 1})' : time, colorValue: tracker.colorValue, isCompleted: isCompleted,
          ));
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

          tasks.add(DailyTaskItem(
            id: goal.id!, type: 'goal', title: goal.title, subtitle: '',
            time: timesToGenerate.length > 1 ? '$time (${i + 1})' : time, colorValue: goal.colorValue, isCompleted: isCompleted,
          ));
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

    DocumentReference docRef = FirebaseFirestore.instance
        .collection('users').doc(uid)
        .collection(task.type == 'tracker' ? 'trackers' : 'goals').doc(task.id);

    LoadingHelper.show(context);

    try {
      if (task.isCompleted) {
        await docRef.update({'completedLogs': FieldValue.arrayRemove([uniqueLogKey])});
      } else {
        await docRef.update({'completedLogs': FieldValue.arrayUnion([uniqueLogKey])});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка оновлення: $e')),
        );
      }
    } finally {
      if (mounted) {
        LoadingHelper.hide(context);
      }
    }
  }
}

// --- ВІДЖЕТ КАЛЕНДАРЯ ІЗ КРАПОЧКАМИ ---
class _CalendarWidget extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  
  // Додано функцію, яка вертає задачі для конкретної дати
  final List<DailyTaskItem> Function(DateTime date) getTasksForDate;

  const _CalendarWidget({
    required this.isExpanded, required this.onToggleExpand, required this.selectedDate, required this.onDateSelected, required this.getTasksForDate,
  });

  @override
  State<_CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<_CalendarWidget> {
  late DateTime _weekStart;
  late DateTime _monthStart;
  int _direction = 1;

  static const _months = ['Січень', 'Лютий', 'Березень', 'Квітень', 'Травень', 'Червень', 'Липень', 'Серпень', 'Вересень', 'Жовтень', 'Листопад', 'Грудень'];
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
    if (!old.isExpanded && widget.isExpanded) _monthStart = DateTime(_weekStart.year, _weekStart.month, 1);
  }

  void _prev() => setState(() {
        _direction = -1;
        if (widget.isExpanded) _monthStart = DateTime(_monthStart.year, _monthStart.month - 1, 1);
        else _weekStart = _weekStart.subtract(const Duration(days: 7));
      });

  void _next() => setState(() {
        _direction = 1;
        if (widget.isExpanded) _monthStart = DateTime(_monthStart.year, _monthStart.month + 1, 1);
        else _weekStart = _weekStart.add(const Duration(days: 7));
      });

  List<DateTime> _buildWeekDays() => List.generate(7, (i) => _weekStart.add(Duration(days: i)));

  List<DateTime> _buildMonthDays() {
    final firstDay = DateTime(_monthStart.year, _monthStart.month, 1);
    final lastDay = DateTime(_monthStart.year, _monthStart.month + 1, 0);
    final days = <DateTime>[];
    for (int i = firstDay.weekday - 1; i > 0; i--) days.add(firstDay.subtract(Duration(days: i)));
    for (int d = 1; d <= lastDay.day; d++) days.add(DateTime(_monthStart.year, _monthStart.month, d));
    final target = days.length <= 35 ? 35 : 42;
    int extra = 1;
    while (days.length < target) days.add(lastDay.add(Duration(days: extra++)));
    return days;
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
  bool _isToday(DateTime d) => _isSameDay(d, DateTime.now());

  @override
  Widget build(BuildContext context) {
    final displayMonth = widget.isExpanded ? _monthStart : _weekStart;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 24), padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(color: const Color(0xFFFAFFFB).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(onTap: _prev, child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.chevron_left, color: Color(0xFFF9FFFA), size: 22))),
              Column(
                children: [
                  Text(_months[displayMonth.month - 1], style: const TextStyle(color: Color(0xFFF9FFFA), fontSize: 18, fontFamily: 'Tenor Sans')),
                  Text('${displayMonth.year}', style: const TextStyle(color: Color(0xFFF9FFFA), fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w300)),
                ],
              ),
              GestureDetector(onTap: _next, child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.chevron_right, color: Color(0xFFF9FFFA), size: 22))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _days.map((d) => SizedBox(width: 36, child: Center(child: Text(d, style: const TextStyle(color: Color(0xFFF9FFFA), fontSize: 14, fontFamily: 'Inter'))))).toList(),
          ),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, anim) {
              final offset = Tween<Offset>(begin: Offset(_direction.toDouble() * 0.3, 0), end: Offset.zero).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut));
              return SlideTransition(position: offset, child: FadeTransition(opacity: anim, child: child));
            },
            child: widget.isExpanded
                ? _buildGrid(_buildMonthDays(), key: ValueKey('month-$_monthStart'), inMonthCheck: (d) => d.month == _monthStart.month)
                : _buildGrid(_buildWeekDays(), key: ValueKey('week-$_weekStart'), inMonthCheck: (d) => d.month == _weekStart.month),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: GestureDetector(
                onTap: widget.onToggleExpand,
                child: AnimatedRotation(
                  turns: widget.isExpanded ? 0.5 : 0, duration: const Duration(milliseconds: 300),
                  child: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFF9FFFA), size: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<DateTime> days, {required Key key, required bool Function(DateTime) inMonthCheck}) {
    final rows = <Widget>[];
    for (int r = 0; r < days.length ~/ 7; r++) {
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (c) => _buildCell(days[r * 7 + c], inMonth: inMonthCheck(days[r * 7 + c]))),
      ));
    }
    return Column(key: key, children: rows);
  }

  Widget _buildCell(DateTime date, {required bool inMonth}) {
    final selected = _isSameDay(date, widget.selectedDate);
    final today = _isToday(date);
    final highlighted = selected || today;

    final tasksForDay = widget.getTasksForDate(date);
    
    // Групуємо по ID (щоб трекер, який п'ють 3 рази, давав лише одну крапочку)
    final Map<String, bool> taskCompletionMap = {};
    final Map<String, int> taskColorMap = {};

    for (var t in tasksForDay) {
      taskColorMap[t.id] = t.colorValue;
      if (!taskCompletionMap.containsKey(t.id)) {
        taskCompletionMap[t.id] = t.isCompleted;
      } else {
        // Якщо хоча б один прийом не виконано - загальна крапочка стає порожньою
        if (!t.isCompleted) taskCompletionMap[t.id] = false;
      }
    }

    // Беремо максимум 4 крапочки, щоб вони влізли під цифру
    final dotIds = taskCompletionMap.keys.take(4).toList();

    return GestureDetector(
      onTap: () => widget.onDateSelected(date),
      child: Container(
        width: 36, height: 36, margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: highlighted ? BoxDecoration(borderRadius: BorderRadius.circular(10), color: const Color(0xFF1A3D2B), border: Border.all(color: const Color(0xFF91FFA4), width: 1.5)) : null,
        
        // Використовуємо Stack, щоб крапочки не зміщували саму цифру дати
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text('${date.day}', style: TextStyle(color: inMonth ? const Color(0xFFF9FFFA) : const Color(0xFF4A6670), fontSize: 16, fontFamily: 'Inter')),
            
            if (dotIds.isNotEmpty)
              Positioned(
                bottom: 4, // Відступ від низу клітинки
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: dotIds.map((id) {
                    final isCompleted = taskCompletionMap[id]!;
                    final color = Color(taskColorMap[id]!);
                    
                    return Container(
                      width: 4, height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // Зафарбована, якщо виконано ВСІ пункти трекера. Порожня з рамкою - якщо ні.
                        color: isCompleted ? color : Colors.transparent,
                        border: Border.all(color: color, width: isCompleted ? 0 : 1),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}