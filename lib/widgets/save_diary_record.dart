import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/diary_record_model.dart';
import 'loading_helper.dart';

Future<bool> saveDiaryRecordToFirebase({
  required BuildContext context,
  required String content,
  required DateTime createdAt,
  required List<String> tags,
}) async {
  
  if (content.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Нотатка не може бути порожньою')),
    );
    return false;
  }

  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return false;

  LoadingHelper.show(context);

  try {
    final newRecord = DiaryRecordModel(
      content: content.trim(),
      createdAt: createdAt,
      tags: tags,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('diary')
        .add(newRecord.toMap());

    if (context.mounted) {
      LoadingHelper.hide(context);
    }
    return true;
    
  } catch (e) {
    if (context.mounted) {
      LoadingHelper.hide(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка збереження: $e')),
      );
    }
    return false;
  }
}