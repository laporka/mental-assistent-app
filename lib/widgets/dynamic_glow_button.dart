import 'package:flutter/material.dart';

class DynamicGlowButton extends StatefulWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;

  const DynamicGlowButton({
    super.key,
    required this.text,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<DynamicGlowButton> createState() => _DynamicGlowButtonState();
}

class _DynamicGlowButtonState extends State<DynamicGlowButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isActive ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.isActive ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: widget.isActive ? () => setState(() => _isPressed = false) : null,
      onTap: widget.isActive ? widget.onTap : null,
      
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          gradient: widget.isActive || _isPressed
              ? const LinearGradient(
                  colors: [Color(0xFF2BBBFF), Color(0xFF91FFA3), Color(0xFFFFCC00)],
                )
              : const LinearGradient(
                  colors: [Color(0xFF354246), Color(0xFF354246)],
                ),
          boxShadow: widget.isActive || _isPressed
              ? [
                  BoxShadow(
                    color: const Color(0xFF91FFA3).withOpacity(0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ]
              : [],
        ),
        child: Container(
          width: 280, // Фіксована ширина, як у макеті
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF041219),
            borderRadius: BorderRadius.circular(48),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.text,
            style: TextStyle(
              // Якщо активна - текст білий, якщо ні - сірий
              color: widget.isActive ? const Color(0xFFF9FFFA) : const Color(0xFFBCC4C2),
              fontSize: 20,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}