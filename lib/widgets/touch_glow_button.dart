import 'package:flutter/material.dart';

class TouchGlowButton extends StatefulWidget {
  final VoidCallback onTap;
  final String text;

  const TouchGlowButton({super.key, required this.onTap, required this.text});

  @override
  State<TouchGlowButton> createState() => _TouchGlowButtonState();
}

class _TouchGlowButtonState extends State<TouchGlowButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          gradient: _isPressed
              ? const LinearGradient(
                  colors: [Color(0xFF2BBBFF), Color(0xFF91FFA3), Color(0xFFFFCC00)],
                )
              : const LinearGradient(
                  colors: [Color(0xFF354246), Color(0xFF354246)],
                ),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: Color(0xFF91FFA3),
                    blurRadius: 15,
                    spreadRadius: 1,
                    offset: Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 64),
          decoration: BoxDecoration(
            color: const Color(0xFF041219),
            borderRadius: BorderRadius.circular(48),
          ),
          child: Text(
            widget.text,
            style: const TextStyle(
              color: Color(0xFFF9FFFA),
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
