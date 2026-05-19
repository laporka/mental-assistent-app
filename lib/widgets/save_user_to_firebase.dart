import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


Future<void> saveUserToFirebase() async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
    String uid = userCredential.user!.uid;

    print('Анонімний вхід успішний! UID: $uid');

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': UserData.userName,
      'hardest_things': UserData.hardestThings,
      'interests': UserData.interests,
      'created_at': FieldValue.serverTimestamp(),
    });

    print('Дані успішно збережено в Firebase! 🚀');
  } catch (e) {
    print('Помилка авторизації або збереження: $e');
  }
}