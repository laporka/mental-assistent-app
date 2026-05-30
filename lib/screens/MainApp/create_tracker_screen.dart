import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/tracker_model.dart';
// import '../widgets/loading_helper.dart'; 

class CreateTrackerScreen extends StatefulWidget {
  final VoidCallback onCancel;
  final Function(TrackerModel) onCreate; 

  const CreateTrackerScreen({
    super.key,
    required this.onCancel,
    required this.onCreate,
  });

  @override
  State<CreateTrackerScreen> createState() => _CreateTrackerScreenState();
}

class _CreateTrackerScreenState extends State<CreateTrackerScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final List<String> _categories = ['Ліки', 'Вітаміни', 'Вода', 'Інше'];
  String _selectedCategory = 'Ліки';

  final List<int> _colors = [
    0xFF2BBBFF, 0xFFFFCC00, 0xFF2BFFD5, 0xFFCC00FF, 0xFF91FFA4, 0xFFFF5093,
    0xFF0037FF, 0xFF9FFF2B, 0xFFFF5C2B, 0xFFFFFB91, 0xFFBD8DFF, 0xFFFF9F40,
    0xFF5D5FEF, 0xFFFF5C5C
  ];
  late int _selectedColor;

  bool _isLimitedCourse = false;
  final TextEditingController _courseDurationController = TextEditingController(text: '30');
  String _courseDurationType = 'День';

  bool _isDaily = true;
  final List<int> _selectedDays = []; 
  final List<String> _dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд'];

  // --- ЗМІННІ ЧАСУ ПРИЙОМУ ---
  bool _isIntervalTime = false; 
  final TextEditingController _intervalValueController = TextEditingController(text: '2');
  String _intervalType = 'Год';
  String _intervalStart = '08:00';
  String _intervalEnd = '20:00';
  
  // СПИСОК ЧАСУ (Спочатку порожній, як ти просив)
  List<String> _reminderTimes = []; 

  @override
  void initState() {
    super.initState();
    _selectedColor = _colors[2]; 
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _courseDurationController.dispose();
    _intervalValueController.dispose();
    super.dispose();
  }

  void _handleCreate() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Введіть назву трекера')));
      return;
    }

    final newTracker = TrackerModel(
      title: _titleController.text.trim(),
      category: _selectedCategory,
      colorValue: _selectedColor,
      isLimitedCourse: _isLimitedCourse,
      courseDuration: _isLimitedCourse ? int.tryParse(_courseDurationController.text) : null,
      courseDurationType: _isLimitedCourse ? _courseDurationType : null,
      isDaily: _isDaily,
      selectedDays: _isDaily ? [] : _selectedDays,
      isIntervalTime: _isIntervalTime,
      intervalValue: _isIntervalTime ? int.tryParse(_intervalValueController.text) : null,
      intervalType: _isIntervalTime ? _intervalType : null,
      intervalStart: _isIntervalTime ? _intervalStart : null,
      intervalEnd: _isIntervalTime ? _intervalEnd : null,
      reminderTimes: _isIntervalTime ? [] : _reminderTimes,
      note: _noteController.text.trim(),
      createdAt: DateTime.now(),
    );

    widget.onCreate(newTracker);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF041219),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 40 + MediaQuery.of(context).padding.top, bottom: 24, left: 20, right: 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF333F44), width: 1)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: widget.onCancel,
                  child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFF9FFFA), size: 24),
                ),
                const Expanded(
                  child: Text(
                    'Новий трекер',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 24, fontFamily: 'Tenor Sans'),
                  ),
                ),
                const SizedBox(width: 24), 
              ],
            ),
          ),

          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(left: 40, right: 40, top: 32, bottom: 120),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Назва', 'Про що нагадувати, або назва ліків/вітамінів'),
                        const SizedBox(height: 16),
                        _buildTitleInput(),

                        const SizedBox(height: 32),
                        _buildSectionTitle('Категорія', null),
                        const SizedBox(height: 16),
                        _buildCategories(),

                        const SizedBox(height: 32),
                        _buildSectionTitle('Колір маркера', null),
                        const SizedBox(height: 16),
                        _buildColorPalette(),

                        const SizedBox(height: 32),
                        _buildSectionTitle('Курс', null),
                        const SizedBox(height: 16),
                        _buildCourseSettings(),

                        const SizedBox(height: 32),
                        if (!_isIntervalTime) ...[
                          _buildSectionTitle('Інтервал', null),
                          const SizedBox(height: 16),
                          _buildIntervalSettings(),
                          const SizedBox(height: 32),
                        ],

                        _buildSectionTitle('Час прийому', null),
                        const SizedBox(height: 16),
                        _buildTimeReminders(),

                        const SizedBox(height: 32),
                        _buildSectionTitle('Додати нотатку', 'Опис або додаткова інформація'),
                        const SizedBox(height: 16),
                        _buildNoteInput(),
                      ],
                    ),
                  ),
                ),
                
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: widget.onCancel,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF041219),
                                border: Border.all(color: const Color(0x7FFAFFFB), width: 1.5),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              alignment: Alignment.center,
                              child: const Text('Скасувати', style: TextStyle(color: Color(0xFFFAFFFB), fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: _handleCreate,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF04131A),
                                border: Border.all(color: const Color(0xFF2BBBFF), width: 1.5),
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: const [BoxShadow(color: Color(0x3F041319), blurRadius: 20, offset: Offset(0, 2))],
                              ),
                              alignment: Alignment.center,
                              child: const Text('Створити', style: TextStyle(color: Color(0xFFFAFFFB), fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ],
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

  // --- БЛОКИ ІНТЕРФЕЙСУ ---

  Widget _buildSectionTitle(String title, String? subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Color(0xFFF9FFFA), fontSize: 20, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: Color(0xFFBCC4C2), fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w300)),
        ]
      ],
    );
  }

  Widget _buildTitleInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFF9FFFA), borderRadius: BorderRadius.circular(50)),
      child: TextField(
        controller: _titleController,
        style: const TextStyle(color: Color(0xFF04131A), fontSize: 16, fontFamily: 'Inter'),
        decoration: const InputDecoration(border: InputBorder.none, hintText: 'Введіть назву'),
      ),
    );
  }

  Widget _buildCategories() {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: _categories.map((cat) {
        final isSel = _selectedCategory == cat;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = cat;
              if (cat == 'Ліки' || cat == 'Вітаміни') _isIntervalTime = false;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: isSel ? const Color(0xFF91FFA4) : const Color(0xFF274E3C), borderRadius: BorderRadius.circular(100)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(cat, style: TextStyle(color: isSel ? const Color(0xFF041219) : const Color(0xFFF9FFFA), fontSize: 16, fontFamily: 'Inter')),
                if (isSel) ...[const SizedBox(width: 8), const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF041219))]
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorPalette() {
    return Wrap(
      spacing: 12, runSpacing: 12,
      children: _colors.map((color) {
        final isSel = _selectedColor == color;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: Color(color), shape: BoxShape.circle, border: isSel ? Border.all(color: const Color(0xFFF9FFFA), width: 2) : null),
            child: isSel ? const Icon(Icons.check, color: Color(0xFF041219), size: 16) : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCourseSettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1D2A30), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Обмежений курс', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 16)),
                  SizedBox(height: 4),
                  Text('Наприклад, 30 днів', style: TextStyle(color: Color(0xFFBCC4C2), fontSize: 12)),
                ],
              ),
              Switch(
                value: _isLimitedCourse, onChanged: (val) => setState(() => _isLimitedCourse = val),
                activeColor: const Color(0xFF91FFA4), activeTrackColor: const Color(0xFF274E3C),
                inactiveThumbColor: const Color(0xFFBCC4C2), inactiveTrackColor: const Color(0xFF333F44),
              ),
            ],
          ),
          if (_isLimitedCourse) ...[
            const SizedBox(height: 16), const Divider(color: Color(0xFF333F44)), const SizedBox(height: 16),
            const Text('Тривалість курсу', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48, decoration: const BoxDecoration(color: Color(0xFF28353B), borderRadius: BorderRadius.horizontal(left: Radius.circular(12))),
                    child: TextField(
                      controller: _courseDurationController, keyboardType: TextInputType.number, textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF91FFA4), fontSize: 16), decoration: const InputDecoration(border: InputBorder.none),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 48, padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: const BoxDecoration(color: Color(0xFF333F44), borderRadius: BorderRadius.horizontal(right: Radius.circular(12))),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _courseDurationType, dropdownColor: const Color(0xFF333F44),
                        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF91FFA4)), style: const TextStyle(color: Color(0xFF91FFA4), fontSize: 16),
                        onChanged: (val) => setState(() => _courseDurationType = val!),
                        items: ['День', 'Тиждень', 'Місяць'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildIntervalSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isDaily = true),
                child: Container(
                  height: 48, alignment: Alignment.center,
                  decoration: BoxDecoration(color: _isDaily ? const Color(0xFF1D2A30) : const Color(0xFF333F44), borderRadius: const BorderRadius.horizontal(left: Radius.circular(12))),
                  child: Text('Щодня', style: TextStyle(color: _isDaily ? const Color(0xFF91FFA4) : const Color(0xFFF9FFFA), fontSize: 16)),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isDaily = false),
                child: Container(
                  height: 48, alignment: Alignment.center,
                  decoration: BoxDecoration(color: !_isDaily ? const Color(0xFF1D2A30) : const Color(0xFF333F44), borderRadius: const BorderRadius.horizontal(right: Radius.circular(12))),
                  child: Text('Дні тижня', style: TextStyle(color: !_isDaily ? const Color(0xFF91FFA4) : const Color(0xFFF9FFFA), fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
        if (!_isDaily) ...[
          const SizedBox(height: 16),
          const Text('Виберіть дні', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 16)), 
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final dayIndex = i + 1;
              final isSel = _selectedDays.contains(dayIndex);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSel) _selectedDays.remove(dayIndex);
                    else _selectedDays.add(dayIndex);
                  });
                },
                child: Container(
                  width: 36, height: 36, alignment: Alignment.center,
                  decoration: BoxDecoration(color: isSel ? const Color(0x3F91FFA4) : Colors.transparent, shape: BoxShape.circle),
                  child: Text(_dayNames[i], style: TextStyle(color: isSel ? const Color(0xFF91FFA4) : const Color(0xFFF9FFFA), fontSize: 14)),
                ),
              );
            }),
          )
        ]
      ],
    );
  }

  Widget _buildTimeReminders() {
    final bool canShowInterval = _selectedCategory == 'Вода' || _selectedCategory == 'Інше';
    String daysText = 'Щодня';
    if (!_isDaily && _selectedDays.isNotEmpty) {
      final sortedDays = List<int>.from(_selectedDays)..sort();
      daysText = sortedDays.map((d) => _dayNames[d - 1]).join(', ');
    } else if (!_isDaily && _selectedDays.isEmpty) {
      daysText = 'Дні не вибрано';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (canShowInterval) ...[
          Container(
            decoration: BoxDecoration(color: const Color(0xFF1D2A30), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isIntervalTime = true),
                    child: Container(
                      height: 48, alignment: Alignment.center,
                      decoration: BoxDecoration(color: _isIntervalTime ? const Color(0xFF333F44) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
                      child: const Text('Інтервальний', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 14)),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isIntervalTime = false),
                    child: Container(
                      height: 48, alignment: Alignment.center,
                      decoration: BoxDecoration(color: !_isIntervalTime ? const Color(0xFF333F44) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
                      child: const Text('Фіксований', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        if (_isIntervalTime)
          _buildIntervalTimeUI()
        else
          Column(
            children: [
              ..._reminderTimes.asMap().entries.map((entry) {
                int idx = entry.key;
                String time = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  // ГРАДІЄНТНА РАМКА ЗЛІВА ДЛЯ ЧАСУ
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Color(0xFF2BBBFF), Color(0xFF91FFA3), Color(0xFFFFCC00)],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 3.0), 
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1D2A30), 
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12), bottomRight: Radius.circular(12),
                          topLeft: Radius.circular(10), bottomLeft: Radius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(time, style: const TextStyle(color: Color(0xFFF9FFFA), fontSize: 24, fontFamily: 'Inter')),
                              const SizedBox(height: 4),
                              Text(daysText, style: const TextStyle(color: Color(0xFFBCC4C2), fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w300)),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _reminderTimes.removeAt(idx)),
                            child: const Icon(Icons.close, color: Color(0xFFBCC4C2)),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }),
              GestureDetector(
                onTap: () => _showCustomTimePicker(
                  title: 'Встановити час',
                  showDays: true,
                  initialTime: DateTime.now(),
                  onConfirm: (time, newIsDaily, newDays) {
                    setState(() {
                      if (!_reminderTimes.contains(time)) _reminderTimes.add(time);
                      _isDaily = newIsDaily;
                      _selectedDays.clear();
                      _selectedDays.addAll(newDays);
                    });
                  }
                ), 
                child: Container(
                  width: double.infinity, padding: const EdgeInsets.all(16), alignment: Alignment.center,
                  decoration: BoxDecoration(color: const Color(0xFF1D2A30), borderRadius: BorderRadius.circular(12)),
                  child: const Text('+ Додати час прийому', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 16, fontFamily: 'Inter')),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildIntervalTimeUI() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1D2A30), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Кожні', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40, decoration: const BoxDecoration(color: Color(0xFF28353B), borderRadius: BorderRadius.horizontal(left: Radius.circular(8))),
                  child: TextField(
                    controller: _intervalValueController, keyboardType: TextInputType.number, textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF91FFA4), fontSize: 16), decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 40, padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(color: Color(0xFF333F44), borderRadius: BorderRadius.horizontal(right: Radius.circular(8))),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _intervalType, dropdownColor: const Color(0xFF333F44),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF91FFA4)), style: const TextStyle(color: Color(0xFF91FFA4), fontSize: 16),
                      onChanged: (val) => setState(() => _intervalType = val!),
                      items: ['Год', 'Хв'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Проміжок', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showCustomTimePicker(
                    title: 'Початок', showDays: false, initialTime: DateTime.now(),
                    onConfirm: (time, _, __) => setState(() => _intervalStart = time)
                  ),
                  child: Container(height: 40, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFF28353B), borderRadius: BorderRadius.circular(8)), child: Text(_intervalStart, style: const TextStyle(color: Color(0xFF91FFA4), fontSize: 16))),
                ),
              ),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('-', style: TextStyle(color: Color(0xFF91FFA4), fontSize: 16))),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showCustomTimePicker(
                    title: 'Кінець', showDays: false, initialTime: DateTime.now(),
                    onConfirm: (time, _, __) => setState(() => _intervalEnd = time)
                  ),
                  child: Container(height: 40, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFF28353B), borderRadius: BorderRadius.circular(8)), child: Text(_intervalEnd, style: const TextStyle(color: Color(0xFF91FFA4), fontSize: 16))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- КАСТОМНИЙ ВЕЛИКИЙ ЕКРАН ВИБОРУ ЧАСУ ---
  void _showCustomTimePicker({
    required String title,
    required bool showDays,
    required DateTime initialTime,
    required Function(String time, bool isDaily, List<int> days) onConfirm,
  }) {
    DateTime tempTime = initialTime;
    bool tempIsDaily = _isDaily;
    List<int> tempDays = List.from(_selectedDays);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            String daysText = 'Щодня';
            if (!tempIsDaily && tempDays.isNotEmpty) {
              final sortedDays = List<int>.from(tempDays)..sort();
              daysText = sortedDays.map((d) => _dayNames[d - 1]).join(', ');
            } else if (!tempIsDaily && tempDays.isEmpty) {
              daysText = 'Не вибрано';
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.85, 
              decoration: const BoxDecoration(
                color: Color(0xFF041219),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Декоративна червонувата лінія зверху
                  Container(height: 1, width: double.infinity, color: const Color(0xFFE27B58).withOpacity(0.4)),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(title, style: const TextStyle(color: Color(0xFFF9FFFA), fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 24),

                  // Барабан часу
                  SizedBox(
                    height: 200,
                    child: CupertinoTheme(
                      data: const CupertinoThemeData(
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle: TextStyle(color: Color(0xFF91FFA4), fontSize: 32),
                        ),
                      ),
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        use24hFormat: true,
                        initialDateTime: tempTime,
                        onDateTimeChanged: (t) => tempTime = t,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Вибір днів (відображається тільки якщо showDays == true)
                  if (showDays) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Встановити день', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(text: 'Кожн. ', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 14)),
                                TextSpan(text: daysText, style: const TextStyle(color: Color(0xFF91FFA4), fontSize: 14)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(7, (i) {
                              final dayIndex = i + 1;
                              final isSel = !tempIsDaily && tempDays.contains(dayIndex);
                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    tempIsDaily = false;
                                    if (isSel) {
                                      tempDays.remove(dayIndex);
                                      if (tempDays.isEmpty) tempIsDaily = true;
                                    } else {
                                      tempDays.add(dayIndex);
                                    }
                                  });
                                },
                                child: Container(
                                  width: 36, height: 36, alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSel ? const Color(0xFF274E3C) : Colors.transparent,
                                    shape: BoxShape.circle
                                  ),
                                  child: Text(_dayNames[i], style: TextStyle(color: isSel ? const Color(0xFF91FFA4) : const Color(0xFFF9FFFA), fontSize: 14, fontWeight: isSel ? FontWeight.w600 : FontWeight.w400)),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Нижні круглі кнопки
                  Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 64, height: 64,
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFF9FFFA).withOpacity(0.5), width: 1)),
                            child: const Icon(Icons.close, color: Color(0xFFF9FFFA), size: 28),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            final formattedTime = '${tempTime.hour.toString().padLeft(2, '0')}:${tempTime.minute.toString().padLeft(2, '0')}';
                            onConfirm(formattedTime, tempIsDaily, tempDays);
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 64, height: 64, padding: const EdgeInsets.all(1.5),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF2BBBFF), Color(0xFF91FFA3), Color(0xFFFFCC00)]),
                            ),
                            child: Container(
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF041219)),
                              child: const Icon(Icons.check, color: Color(0xFF91FFA4), size: 28),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNoteInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF9FFFA), borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: _noteController, maxLines: 3,
        style: const TextStyle(color: Color(0xFF04131A), fontSize: 16),
        decoration: const InputDecoration(border: InputBorder.none, hintText: 'Напиши нотатку...', hintStyle: TextStyle(color: Color(0xFFBCC4C2))),
      ),
    );
  }
}