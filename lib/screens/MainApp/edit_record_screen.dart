import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/diary_record_model.dart';
import '../../widgets/save_diary_record.dart';

class EditRecordScreen extends StatefulWidget {
  final DiaryRecordModel record;
  final VoidCallback onCancel;
  final VoidCallback onSaveSuccess;

  const EditRecordScreen({
    super.key,
    required this.record,
    required this.onCancel,
    required this.onSaveSuccess,
  });

  @override
  State<EditRecordScreen> createState() => _EditRecordScreenState();
}

class _EditRecordScreenState extends State<EditRecordScreen> {
  late TextEditingController _contentController;
  
  bool _isTagsVisible = false;
  late List<String> _selectedTags;
  late List<String> _originalTags;
  final List<String> _suggestedTags = ['Особисте', 'Робота', 'Ідея', 'Навчання'];

  @override
  void initState() {
    super.initState();
    // Підставляємо існуючий текст
    _contentController = TextEditingController(text: widget.record.content);
    // Копіюємо існуючі теги
    _selectedTags = List.from(widget.record.tags);
    _originalTags = List.from(widget.record.tags);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (widget.record.id == null) return;

    bool success = await updateDiaryRecordInFirebase(
      context: context,
      docId: widget.record.id!,
      content: _contentController.text,
      tags: _selectedTags,
    );

    if (success && mounted) {
      widget.onSaveSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scaleX = size.width / 360;
    final double scaleY = size.height / 800;

    String formattedDate = DateFormat('dd.MM.yyyy').format(widget.record.createdAt);

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          // 1. ФОН
          Positioned(
            left: 9 * scaleX, top: 116 * scaleY,
            child: Opacity(
              opacity: 0.50,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 80.0, sigmaY: 80.0),
                child: Container(
                  width: 341 * scaleX, height: 568 * scaleY,
                  decoration: const ShapeDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF2BBCFF), Color(0xFF91FFA4), Color(0xFFFFCC00)]),
                    shape: OvalBorder(),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 30 * scaleX, right: 30 * scaleX, top: 100 * scaleY, bottom: 0,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Запис', style: TextStyle(color: Color(0xFF041219), fontSize: 16, fontFamily: 'Inter')),
                            Text(formattedDate, style: const TextStyle(color: Color(0xFF041219), fontSize: 16, fontFamily: 'Inter')),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Блок тегів
                        Row(
                          children: [
                            const Text('Редагувати теги:', style: TextStyle(color: Color(0xFF041219), fontSize: 16, fontFamily: 'Inter')),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isTagsVisible = !_isTagsVisible;
                                  if (_isTagsVisible) {
                                    _originalTags = List.from(_selectedTags);
                                  }
                                });
                              },
                              child: Container(
                                width: 24, height: 24,
                                decoration: const BoxDecoration(color: Color(0xFF4B895E), shape: BoxShape.circle),
                                child: Icon(_isTagsVisible ? Icons.remove : Icons.add, color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                        
                        if (_isTagsVisible) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8.0, runSpacing: 8.0, 
                            children: [
                              ..._suggestedTags.map((tag) {
                                final isSelected = _selectedTags.contains(tag);
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) _selectedTags.remove(tag);
                                      else _selectedTags.add(tag);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF4B895E) : const Color(0xFF9BA6A1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(tag, style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Inter')),
                                        if (isSelected) ...[
                                          const SizedBox(width: 4),
                                          const Icon(Icons.check, color: Colors.white, size: 14),
                                        ]
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFF333F44)),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text('#Створити новий тег', style: TextStyle(color: Color(0xFF333F44), fontSize: 13, fontFamily: 'Inter')),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedTags = List.from(_originalTags);
                                    _isTagsVisible = false;
                                  });
                                },
                                child: Row(
                                  children: [
                                    const Icon(Icons.cancel_outlined, color: Color(0xFF041219), size: 18),
                                    const SizedBox(width: 6),
                                    const Text('Скасувати', style: TextStyle(color: Color(0xFF041219), fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _originalTags = List.from(_selectedTags);
                                    _isTagsVisible = false;
                                  });
                                },
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline, color: Color(0xFF4B895E), size: 18),
                                    const SizedBox(width: 6),
                                    const Text('Зберегти', style: TextStyle(color: Color(0xFF4B895E), fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ] else if (_selectedTags.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8, runSpacing: 8,
                            children: _selectedTags.map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFF4B895E), borderRadius: BorderRadius.circular(100)),
                                child: Text(tag, style: const TextStyle(color: Color(0xFFF9FFFA), fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w300)),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(width: 1, color: Color(0xFFBCC4C2))),
                      ),
                      child: TextField(
                        controller: _contentController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        style: const TextStyle(color: Color(0xFF041219), fontSize: 16, fontFamily: 'Inter', height: 1.4),
                        decoration: const InputDecoration(border: InputBorder.none),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 20 * scaleX, top: 40 * scaleY, right: 20 * scaleX,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFF9FFFA), size: 22), onPressed: widget.onCancel),
                const Text('Щоденник', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 24, fontFamily: 'Tenor Sans')),
                IconButton(icon: const Icon(Icons.help_outline, color: Color(0xFFF9FFFA), size: 24), onPressed: () {}),
              ],
            ),
          ),

          Positioned(
            left: 15 * scaleX, bottom: 20,       
            child: GestureDetector(
              onTap: widget.onCancel,
              child: Container(
                width: 72, height: 72, padding: const EdgeInsets.all(1.5), 
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2BBBFF), Color(0xFF91FFA3), Color(0xFFFFCC00)]),
                  boxShadow: [BoxShadow(color: Color(0x3F041319), blurRadius: 20, offset: Offset(0, 2))],
                ),
                child: Container(
                  decoration: const BoxDecoration(color: Color(0xFF041219), shape: BoxShape.circle),
                  child: const Center(child: Icon(Icons.close, color: Colors.white, size: 32)),
                ),
              ),
            ),
          ),
          Positioned(
            right: 15 * scaleX, bottom: 20,        
            child: GestureDetector(
              onTap: _handleUpdate,
              child: Container(
                width: 72, height: 72, padding: const EdgeInsets.all(1.5), 
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2BBBFF), Color(0xFF91FFA3), Color(0xFFFFCC00)]),
                  boxShadow: [BoxShadow(color: Color(0x3F041319), blurRadius: 20, offset: Offset(0, 2))],
                ),
                child: Container(
                  decoration: const BoxDecoration(color: Color(0xFF041219), shape: BoxShape.circle),
                  child: const Center(child: Icon(Icons.check, color: Color(0xFF91FFA4), size: 32)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}