import 'package:cloud_firestore/cloud_firestore.dart';

class GoalModel {
  final String? id;
  final String title;
  final String category;
  final int colorValue;

  // 'none' | 'period' | 'date'
  final String deadlineType;
  final int? periodDuration;
  final String? periodDurationType;
  final DateTime? endDate;

  final bool isDaily;
  final List<int> selectedDays;
  final List<String> reminderTimes;
  final String note;
  final DateTime createdAt;

  GoalModel({
    this.id,
    required this.title,
    required this.category,
    required this.colorValue,
    required this.deadlineType,
    this.periodDuration,
    this.periodDurationType,
    this.endDate,
    required this.isDaily,
    required this.selectedDays,
    required this.reminderTimes,
    required this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'colorValue': colorValue,
      'deadlineType': deadlineType,
      'periodDuration': periodDuration,
      'periodDurationType': periodDurationType,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'isDaily': isDaily,
      'selectedDays': selectedDays,
      'reminderTimes': reminderTimes,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory GoalModel.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return GoalModel(
      id: doc.id,
      title: map['title'] ?? '',
      category: map['category'] ?? 'Інше',
      colorValue: map['colorValue'] ?? 0xFF91FFA4,
      deadlineType: map['deadlineType'] ?? 'none',
      periodDuration: map['periodDuration'],
      periodDurationType: map['periodDurationType'],
      endDate: map['endDate'] != null ? (map['endDate'] as Timestamp).toDate() : null,
      isDaily: map['isDaily'] ?? true,
      selectedDays: List<int>.from(map['selectedDays'] ?? []),
      reminderTimes: List<String>.from(map['reminderTimes'] ?? []),
      note: map['note'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
