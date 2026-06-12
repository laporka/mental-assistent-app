import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:test_app/models/user_data.dart';
import '../../widgets/dynamic_glow_button.dart'; 
import 'fourth_screen_meet.dart';

class ANameScreen extends StatefulWidget {
  const ANameScreen({super.key});

  @override
  State<ANameScreen> createState() => _ANameScreenState();
}

class _ANameScreenState extends State<ANameScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isButtonActive = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    final bool isNotEmpty = _nameController.text.trim().isNotEmpty;
    if (isNotEmpty != _isButtonActive) {
      setState(() {
        _isButtonActive = isNotEmpty;
      });
    }
  }

  void _submitName(String value) {
    final userName = value.trim(); 
    
    if (userName.isNotEmpty) {
      UserData.userName = userName;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ASixthScreen(), 
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scaleX = size.width / 360;
    final double scaleY = size.height / 800;

    return Scaffold(
      backgroundColor: const Color(0xFF041219),
      resizeToAvoidBottomInset: true, 
      body: Stack(
        children: [
          Positioned(
            left: -17 * scaleX,
            top: -416 * scaleY,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 120.0, sigmaY: 120.0),
              child: Container(
                width: 393 * scaleX,
                height: 577 * scaleY,
                decoration: const ShapeDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(1.00, 0.66),
                    end: Alignment(-0.05, 0.69),
                    colors: [
                      Color(0xFF2BBBFF), 
                      Color(0xFF91FFA3), 
                      Color(0xFFFFCC00)
                    ],
                  ),
                  shape: OvalBorder(),
                ),
              ),
            ),
          ),

          Positioned(
            left: 40,
            top: 100 * scaleY,
            child: SizedBox(
              width: 280,
              child: const Text(
                'І найголовніше,\nяк тебе звати?',
                style: TextStyle(
                  color: Color(0xFFF9FFFA),
                  fontSize: 24,
                  fontFamily: 'Tenor Sans',
                  fontWeight: FontWeight.w400,
                  height: 1.1,
                ),
              ),
            ),
          ),

          Positioned(
            left: 40,
            right: 40,
            bottom: 150 * scaleY,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              decoration: ShapeDecoration(
                color: const Color(0xFFF9FFFA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: TextField(
                controller: _nameController,
                autofocus: true, 
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.words,
                onSubmitted: _submitName,
                cursorColor: const Color(0xFF041219),
                style: const TextStyle(
                  color: Color(0xFF041219),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  hintText: "Ввести ім'я",
                  hintStyle: TextStyle(
                    color: Color(0xFFBCC4C2),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  suffixIcon: Icon(
                    Icons.edit_outlined,
                    color: Color(0xFFBCC4C2),
                    size: 20,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Column(
              children: [
                DynamicGlowButton(
                  text: 'Продовжити далі',
                  isActive: _isButtonActive,
                  onTap: () => _submitName(_nameController.text),
                ),
                const SizedBox(height: 20),
                const Opacity(
                  opacity: 0.70,
                  child: Text(
                    'Це завжди можна змінити у профілі',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFF9FFFA),
                      fontSize: 13,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w300,
                      height: 1,
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