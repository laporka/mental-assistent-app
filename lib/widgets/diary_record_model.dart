import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryRecordModel {
  final String content;
  final DateTime createdAt;
  final List<String> tags;

  DiaryRecordModel({
    required this.content,
    required this.createdAt,
    required this.tags,
  });

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'tags': tags,
    };
  }

  // ДОДАЙ ЦЕЙ БЛОК: Метод для читання даних з Firebase
  factory DiaryRecordModel.fromMap(Map<String, dynamic> map) {
    return DiaryRecordModel(
      content: map['content'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      tags: List<String>.from(map['tags'] ?? []),
    );
  }
}