import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/tracker_model.dart';
import 'loading_helper.dart';
import '../services/notification_service.dart';

Future<bool> saveTrackerToFirebase({
  required BuildContext context,
  required TrackerModel tracker,
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
    final docRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('trackers') 
        .add(tracker.toMap());

    List<String> timesToGenerate = [];
    
    if (tracker.isIntervalTime && tracker.intervalStart != null && tracker.intervalEnd != null) {
      int startH = int.parse(tracker.intervalStart!.split(':')[0]);
      int endH = int.parse(tracker.intervalEnd!.split(':')[0]);
      int step = tracker.intervalValue ?? 2; 
      for (int h = startH; h <= endH; h += step) {
        timesToGenerate.add('${h.toString().padLeft(2, '0')}:00');
      }
    } else {
      timesToGenerate = tracker.reminderTimes;
    }

    for (String time in timesToGenerate) {
      List<String> parts = time.split(':');
      if (parts.length == 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        
        int notificationId = '${docRef.id}_$time'.hashCode.abs();

        await NotificationService().scheduleDailyReminder(
          id: notificationId,
          title: 'Час готуватися! ⏳', // Оновлений заголовок
          body: 'За 10 хвилин: ${tracker.title}', // Оновлений текст
          hour: hour,
          minute: minute,
        );
      }
    }

    if (context.mounted) {
      LoadingHelper.hide(context);
    }
    return true;
    
  } catch (e) {
    if (context.mounted) {
      LoadingHelper.hide(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка збереження трекера: $e')),
      );
    }
    return false;
  }
}