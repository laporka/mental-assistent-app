import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/save_diary_record.dart';

class CreateRecordScreen extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onSaveSuccess;

  const CreateRecordScreen({
    super.key,
    required this.onCancel,
    required this.onSaveSuccess,
  });

  @override
  State<CreateRecordScreen> createState() => _CreateRecordScreenState();
}

class _CreateRecordScreenState extends State<CreateRecordScreen> {
  final TextEditingController _contentController = TextEditingController();
  final DateTime _currentDate = DateTime.now();
  
  bool _isTagsVisible = false;
  final List<String> _selectedTags = [];
  
  final List<String> _suggestedTags = ['Особисте', 'Робота', 'Ідея', 'Навчання']; 

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    bool success = await saveDiaryRecordToFirebase(
      context: context,
      content: _contentController.text,
      createdAt: _currentDate,
      tags: _selectedTags,
    );

    if (success && mounted) {
      widget.onSaveSuccess();
    }
  }

  void _showCreateTagDialog() {
    TextEditingController tagController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF9FFFA),
        title: const Text(
          'Новий тег',
          style: TextStyle(color: Color(0xFF041219), fontFamily: 'Inter'),
        ),
        content: TextField(
          controller: tagController,
          cursorColor: const Color(0xFF4B895E),
          decoration: const InputDecoration(
            hintText: 'Введіть назву',
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF4B895E)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Скасувати', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              final newTag = tagController.text.trim();
              if (newTag.isNotEmpty && !_suggestedTags.contains(newTag)) {
                setState(() {
                  _suggestedTags.add(newTag);
                  _selectedTags.add(newTag);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Додати', style: TextStyle(color: Color(0xFF4B895E))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scaleX = size.width / 360;
    final double scaleY = size.height / 800;

    String formattedDate = DateFormat('dd.MM.yyyy').format(_currentDate);

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
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
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
                            const Text(
                              'Запис',
                              style: TextStyle(
                                color: Color(0xFF041219),
                                fontSize: 16,
                                fontFamily: 'Inter',
                              ),
                            ),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                color: Color(0xFF041219),
                                fontSize: 16,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            const Text(
                              'Додати теги:',
                              style: TextStyle(
                                color: Color(0xFF041219),
                                fontSize: 16,
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isTagsVisible = !_isTagsVisible;
                                });
                              },
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4B895E),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isTagsVisible ? Icons.remove : Icons.add, 
                                  color: Colors.white, 
                                  size: 16
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        if (_isTagsVisible) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: [
                              ..._suggestedTags.map((tag) {
                                final isSelected = _selectedTags.contains(tag);
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedTags.remove(tag);
                                      } else {
                                        _selectedTags.add(tag);
                                      }
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
                                        Text(
                                          tag,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                        if (isSelected) ...[
                                          const SizedBox(width: 4),
                                          const Icon(Icons.check, color: Colors.white, size: 14),
                                        ]
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              
                              GestureDetector(
                                onTap: _showCreateTagDialog,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border.all(color: const Color(0xFF333F44)),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    '#Створити новий тег',
                                    style: TextStyle(
                                      color: Color(0xFF333F44),
                                      fontSize: 13,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(width: 1, color: Color(0xFFBCC4C2)),
                        ),
                      ),
                      child: TextField(
                        controller: _contentController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        style: const TextStyle(
                          color: Color(0xFF041219),
                          fontSize: 16,
                          fontFamily: 'Inter',
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Напиши свою нотатку',
                          hintStyle: TextStyle(color: Color(0xFFBCC4C2)),
                          border: InputBorder.none,
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
                  onPressed: widget.onCancel, 
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
            left: 15 * scaleX,
            bottom: 20,       
            child: GestureDetector(
              onTap: widget.onCancel,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF041219),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2BBBFF), width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3F041319),
                      blurRadius: 20,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
          ),
          Positioned(
            right: 15 * scaleX, 
            bottom: 20,        
            child: GestureDetector(
              onTap: _handleSave,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF041219),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2BBBFF), width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3F041319),
                      blurRadius: 20,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.check, color: Color(0xFF91FFA4), size: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}