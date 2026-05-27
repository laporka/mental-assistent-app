import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/diary_record_model.dart';

class AllRecordsScreen extends StatelessWidget {
  final VoidCallback onCreateNew;
  final Function(DiaryRecordModel) onRecordTap;

  const AllRecordsScreen({
    super.key, 
    required this.onCreateNew,
    required this.onRecordTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scaleX = size.width / 360;
    final double scaleY = size.height / 800;

    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          Positioned(
            left: -17 * scaleX,
            top: -193 * scaleY,
            child: Opacity(
              opacity: 0.20,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 90.0, sigmaY: 90.0),
                child: Container(
                  width: 393 * scaleX,
                  height: 568 * scaleY,
                  decoration: const ShapeDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.60, 0.83),
                      end: Alignment(0.00, 0.18),
                      colors: [Color(0xFF2BBCFF), Color(0xFF91FFA4), Color(0xFFFFCC00)],
                    ),
                    shape: OvalBorder(),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            top: 90 * scaleY, 
            bottom: 0,
            child: uid == null
                ? const Center(child: Text("Помилка авторизації", style: TextStyle(color: Colors.white)))
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('diary')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFF2BBBFF)));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            "У вас ще немає записів.",
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        );
                      }

                      final docs = snapshot.data!.docs;

                      return ListView.builder(
                        padding: EdgeInsets.only(
                          left: 40 * scaleX,
                          right: 40 * scaleX,
                          bottom: 120 * scaleY,
                        ),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          final record = DiaryRecordModel.fromMap(data);

                          return GestureDetector(
                            onTap: () => onRecordTap(record),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: _buildRecordCard(record),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),

          Positioned(
            left: 20 * scaleX,
            top: 40 * scaleY,
            right: 20 * scaleX,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Щоденник',
                  style: TextStyle(
                    color: Color(0xFFF9FFFA),
                    fontSize: 24,
                    fontFamily: 'Tenor Sans',
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            right: 20 * scaleX, 
            bottom: 30 * scaleY, 
            child: GestureDetector(
              onTap: onCreateNew,
              child: Container(
                width: 72, 
                height: 72,
                padding: const EdgeInsets.all(1.5), 
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2BBBFF), Color(0xFF91FFA3), Color(0xFFFFCC00)],
                  ),
                  boxShadow: [
                    BoxShadow(color: Color(0x3F041319), blurRadius: 20, offset: Offset(0, 2))
                  ],
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF041219),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.add, color: Colors.white, size: 32), 
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(DiaryRecordModel record) {
    String dateStr = DateFormat('dd.MM.yyyy').format(record.createdAt);
    String timeStr = DateFormat('HH:mm').format(record.createdAt);

    return Container(
      padding: const EdgeInsets.only(left: 1.5, bottom: 1.5), 
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF2BBBFF), Color(0xFF91FFA3), Color(0xFFFFCC00)],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF041219), 
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0x19FAFFFB), 
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateStr,
                    style: const TextStyle(
                      color: Color(0xFFF9FFFA),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    timeStr,
                    style: const TextStyle(
                      color: Color(0xFFF9FFFA),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              Text(
                record.content,
                style: const TextStyle(
                  color: Color(0xFFF9FFFA),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
              
              if (record.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: record.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4B895E),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Color(0xFFF9FFFA),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}