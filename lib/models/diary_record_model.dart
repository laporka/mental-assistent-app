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
}