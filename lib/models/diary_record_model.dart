import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryRecordModel {
  final String? id;
  final String content;
  final DateTime createdAt;
  final List<String> tags;

  DiaryRecordModel({
    this.id,
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

  factory DiaryRecordModel.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return DiaryRecordModel(
      id: doc.id, // Зберігаємо унікальний ключ
      content: map['content'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      tags: List<String>.from(map['tags'] ?? []),
    );
  }
}