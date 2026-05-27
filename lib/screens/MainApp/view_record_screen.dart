import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/diary_record_model.dart';

class ViewRecordScreen extends StatelessWidget {
  final DiaryRecordModel record;
  final VoidCallback onBack;
  final VoidCallback onEdit;

  const ViewRecordScreen({
    super.key,
    required this.record,
    required this.onBack,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scaleX = size.width / 360;
    final double scaleY = size.height / 800;

    String formattedDate = DateFormat('dd.MM.yyyy').format(record.createdAt);

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [

          Positioned(
            left: 9 * scaleX,
            top: 116 * scaleY,
            child: Opacity(
              opacity: 0.50,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 80.0, sigmaY: 80.0),
                child: Container(
                  width: 341 * scaleX,
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
            left: 30 * scaleX,
            right: 30 * scaleX,
            top: 100 * scaleY,
            bottom: 0,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                color: Color(0xFFF9FFFA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Шапка: Запис + Дата
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Запис',
                              style: TextStyle(
                                color: Color(0xFF041219),
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                color: Color(0xFF041219),
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Теги
                        const Text(
                          'Теги:',
                          style: TextStyle(
                            color: Color(0xFF041219),
                            fontSize: 16,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: record.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4B895E),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(width: 1, color: Color(0xFFBCC4C2))),
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          record.content,
                          style: const TextStyle(
                            color: Color(0xFF041219),
                            fontSize: 16,
                            fontFamily: 'Inter',
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 20 * scaleX,
            top: 40 * scaleY,
            right: 20 * scaleX,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFF9FFFA), size: 22),
                  onPressed: onBack,
                ),
                const Text(
                  'Щоденник',
                  style: TextStyle(
                    color: Color(0xFFF9FFFA),
                    fontSize: 24,
                    fontFamily: 'Tenor Sans',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.help_outline, color: Color(0xFFF9FFFA), size: 24),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          Positioned(
            right: 15 * scaleX,
            bottom: 20,
            child: GestureDetector(
              onTap: onEdit,
              child: Container(
                width: 72,
                height: 72,
                padding: const EdgeInsets.all(1.5),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2BBBFF), Color(0xFF91FFA4), Color(0xFFFFCC00)],
                  ),
                  boxShadow: [
                    BoxShadow(color: Color(0x3F041319), blurRadius: 20, offset: Offset(0, 2)),
                  ],
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF041219),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.edit, color: Colors.white, size: 32),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}