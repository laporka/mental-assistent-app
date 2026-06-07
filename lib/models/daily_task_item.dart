class DailyTaskItem {
  final String id;
  final String type; // 'goal' або 'tracker'
  final String title;
  final String subtitle; // Наприклад: '3 рази в день'
  final String time; // '09:00' або '09:00 (1)'
  final int colorValue; // Колір для градієнта
  final bool isCompleted;

  DailyTaskItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.colorValue,
    required this.isCompleted,
  });
}