import 'dart:ui';
import 'package:flutter/material.dart';

class AHomeEmptyScreen extends StatefulWidget {
  final Function(String) onSendFirstMessage;

  const AHomeEmptyScreen({super.key, required this.onSendFirstMessage});

  @override
  State<AHomeEmptyScreen> createState() => _AHomeEmptyScreenState();
}

class _AHomeEmptyScreenState extends State<AHomeEmptyScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _handleFirstMessage(String text) {
    final messageText = text.trim();
    if (messageText.isEmpty) return;

    widget.onSendFirstMessage(messageText); 
    
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scaleX = size.width / 360;
    final double scaleY = size.height / 800;

    return Scaffold(
      backgroundColor: const Color(0xFF041219),
      body: Stack(
        children: [
          // ФОНОВИЙ БЛЮР-ГРАДІЄНТ
          Positioned(
            left: -17 * scaleX,
            top: -269 * scaleY,
            child: Opacity(
              opacity: 0.50,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
                child: Container(
                  width: 393 * scaleX,
                  height: 568 * scaleY,
                  decoration: const ShapeDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.65, 0.94),
                      end: Alignment(-0.02, 0.59),
                      colors: [Color(0xFF2BBCFF), Color(0xFF91FFA3), Color(0xFFFFCC00)],
                    ),
                    shape: OvalBorder(),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 40,
            right: 40,
            top: 252 * scaleY,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Привіт!',
                  style: TextStyle(
                    color: Color(0xFFF9FFFA),
                    fontSize: 24,
                    fontFamily: 'Tenor Sans',
                    fontWeight: FontWeight.w400,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Як справи?',
                  style: TextStyle(
                    color: Color(0xFFF9FFFA),
                    fontSize: 24,
                    fontFamily: 'Tenor Sans',
                    fontWeight: FontWeight.w400,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 20),
                
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF9FFFA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: Center(
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: _handleFirstMessage,
                      cursorColor: const Color(0xFF041219),
                      textAlignVertical: TextAlignVertical.center,
                      style: const TextStyle(
                        color: Color(0xFF041219),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Напиши ...',
                        hintStyle: TextStyle(
                          color: Color(0xFFBCC4C2),
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        suffixIcon: Icon(
                          Icons.edit_outlined,
                          color: Color(0xFFBCC4C2),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}