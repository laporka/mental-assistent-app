class DailyTaskItem {
  final String id;
  final String type;
  final String title;
  final String subtitle;
  final String time;
  final int colorValue;
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