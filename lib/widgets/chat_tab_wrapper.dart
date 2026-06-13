import 'package:flutter/material.dart';
import '../screens/MainApp/mental_coach_chat_screen.dart';

class ChatTabWrapper extends StatelessWidget {
  const ChatTabWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const MentalCoachChatScreen(); // Теж const!
  }
}