import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import 'loading_helper.dart';

Future<bool> saveGoalToFirebase({
  required BuildContext context,
  required GoalModel goal,
}) async {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Помилка: Користувач не авторизований')),
    );
    return false;
  }

  LoadingHelper.show(context);

  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('goals')
        .add(goal.toMap());

    if (context.mounted) {
      LoadingHelper.hide(context);
    }
    return true;
  } catch (e) {
    if (context.mounted) {
      LoadingHelper.hide(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка збереження цілі: $e')),
      );
    }
    return false;
  }
}
