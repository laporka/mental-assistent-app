import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            double value = (_controller.value - delay) % 1.0;
            if (value < 0) value += 1.0;
            final offset = (value < 0.5) ? Curves.easeOut.transform(value * 2) : Curves.easeIn.transform((1 - value) * 2);

            return Transform.translate(
              offset: Offset(0, -5 * offset),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF2BBBFF), // Фірмовий блакитний
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}