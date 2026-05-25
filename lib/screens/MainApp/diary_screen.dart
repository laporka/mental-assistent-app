import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'create_record_screen.dart';
import 'all_records_screen.dart';

class DiaryHomeScreen extends StatefulWidget {
  const DiaryHomeScreen({super.key});

  @override
  State<DiaryHomeScreen> createState() => _DiaryHomeScreenState();
}

class _DiaryHomeScreenState extends State<DiaryHomeScreen> {

  bool _isCreating = false;

  @override
  Widget build(BuildContext context) {
    if (_isCreating) {
      return CreateRecordScreen(
        onCancel: () => setState(() => _isCreating = false),
        onSaveSuccess: () => setState(() => _isCreating = false),
      );
    }

    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(child: Text("Помилка авторизації", style: TextStyle(color: Colors.white)));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('diary')
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF2BBBFF)));
        }

        final hasRecords = snapshot.hasData && snapshot.data!.docs.isNotEmpty;

        if (hasRecords) {
          return AllRecordsScreen(
            onCreateNew: () => setState(() => _isCreating = true),
          );
        } else {
          return _buildEmptyState(context);
        }
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scaleX = size.width / 360;
    final double scaleY = size.height / 800;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
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
                      end: Alignment(0.07, 0.18),
                      colors: [
                        Color(0xFF2BBCFF), 
                        Color(0xFF91FFA4), 
                        Color(0xFFFFCC00)
                      ],
                    ),
                    shape: OvalBorder(),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 252 * scaleY,
            left: 40 * scaleX,
            right: 105 * scaleX,
            child: const Text(
              'Це твій щоденник в який ти можеш записувати усе що захочеш',
              style: TextStyle(
                color: Color(0xFFF9FFFA),
                fontSize: 24,
                fontFamily: 'Tenor Sans',
                fontWeight: FontWeight.w400,
                height: 1.15,
              ),
            ),
          ),

          Positioned(
            right: 40 * scaleX,
            top: 325 * scaleY,
            child: Opacity(
              opacity: 0.25, 
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2BBCFF), Color(0xFF91FFA4), Color(0xFFFFCC00)],
                ).createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: SvgPicture.asset(
                  'assets/icons/ic_baseline-mode.svg',
                  width: 88,
                  height: 88,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 30 * scaleY,
            left: 0,
            right: 0,
            child: Center(
              child: TouchGlowButton(
                text: 'Зробити перший запис',
                onTap: () {
                  setState(() => _isCreating = true);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
                  colors: [Color(0xFF2BBCFF), Color(0xFF91FFA3), Color(0xFFFFCC00)],
                )
              : const LinearGradient(
                  colors: [Color(0xFF354246), Color(0xFF354246)],
                ),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: const Color(0xFF91FFA3),
                    blurRadius: 15,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
          decoration: BoxDecoration(
            color: const Color(0xFF041219),
            borderRadius: BorderRadius.circular(48),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,        
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [
              Text(
                widget.text,
                style: const TextStyle(
                  color: Color(0xFFF9FFFA),
                  fontSize: 20,              
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600, 
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}