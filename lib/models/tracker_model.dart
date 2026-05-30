import 'package:cloud_firestore/cloud_firestore.dart';

class TrackerModel {
  final String? id; 
  final String title; 
  final String category; 
  final int colorValue; 
  
  final bool isLimitedCourse; 
  final int? courseDuration; 
  final String? courseDurationType; 
  
  final bool isDaily; 
  final List<int> selectedDays; 
  
  final bool isIntervalTime;
  final int? intervalValue;
  final String? intervalType;
  final String? intervalStart;
  final String? intervalEnd;
  final List<String> reminderTimes;
  
  final String note; 
  final DateTime createdAt; 

  TrackerModel({
    this.id,
    required this.title,
    required this.category,
    required this.colorValue,
    required this.isLimitedCourse,
    this.courseDuration,
    this.courseDurationType,
    required this.isDaily,
    required this.selectedDays,
    required this.isIntervalTime,
    this.intervalValue,
    this.intervalType,
    this.intervalStart,
    this.intervalEnd,
    required this.reminderTimes,
    required this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'colorValue': colorValue,
      'isLimitedCourse': isLimitedCourse,
      'courseDuration': courseDuration,
      'courseDurationType': courseDurationType,
      'isDaily': isDaily,
      'selectedDays': selectedDays,
      'isIntervalTime': isIntervalTime,
      'intervalValue': intervalValue,
      'intervalType': intervalType,
      'intervalStart': intervalStart,
      'intervalEnd': intervalEnd,
      'reminderTimes': reminderTimes,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory TrackerModel.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return TrackerModel(
      id: doc.id,
      title: map['title'] ?? '',
      category: map['category'] ?? 'Інше',
      colorValue: map['colorValue'] ?? 0xFF4B895E,
      isLimitedCourse: map['isLimitedCourse'] ?? false,
      courseDuration: map['courseDuration'],
      courseDurationType: map['courseDurationType'],
      isDaily: map['isDaily'] ?? true,
      selectedDays: List<int>.from(map['selectedDays'] ?? []),
      isIntervalTime: map['isIntervalTime'] ?? false,
      intervalValue: map['intervalValue'],
      intervalType: map['intervalType'],
      intervalStart: map['intervalStart'],
      intervalEnd: map['intervalEnd'],
      reminderTimes: List<String>.from(map['reminderTimes'] ?? []),
      note: map['note'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}