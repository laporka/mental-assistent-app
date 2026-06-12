import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/MainApp/empty_main_home_screen.dart';
import '../screens/MainApp/mental_coach_chat_screen.dart';

class ChatTabWrapper extends StatefulWidget {
  const ChatTabWrapper({super.key});

  @override
  State<ChatTabWrapper> createState() => _ChatTabWrapperState();
}

class _ChatTabWrapperState extends State<ChatTabWrapper> {
  String? _pendingMessage;

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF041219),
        body: Center(child: Text('Помилка авторизації', style: TextStyle(color: Colors.white))),
      );
    }

    if (_pendingMessage != null) {
      return MentalCoachChatScreen(initialMessage: _pendingMessage);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('coach_chat')
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF041219),
            body: Center(child: CircularProgressIndicator(color: Color(0xFF2BBBFF))),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return AHomeEmptyScreen(
            onSendFirstMessage: (text) {
              setState(() {
                _pendingMessage = text; // Це змусить Wrapper миттєво переключити UI
              });
            },
          );
        } else {
          // 4. Якщо історія є -> малюємо повноцінний чат
          return const MentalCoachChatScreen();
        }
      },
    );
  }
}