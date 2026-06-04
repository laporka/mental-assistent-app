import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/goal_model.dart';

class CreateGoalScreen extends StatefulWidget {
  final VoidCallback onCancel;
  final Function(GoalModel) onCreate;

  const CreateGoalScreen({
    super.key,
    required this.onCancel,
    required this.onCreate,
  });

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _periodDurationController =
      TextEditingController(text: '30');

  final List<String> _categories = [
    'Здоров\'я', 'Спорт', 'Навчання', 'Кар\'єра', 'Творчість', 'Дозвілля', 'Інше'
  ];
  String _selectedCategory = 'Здоров\'я';

  final List<int> _colors = [
    0xFF2BBBFF, 0xFFFFCC00, 0xFF2BFFD5, 0xFFCC00FF, 0xFF91FFA4, 0xFFFF5093,
    0xFF0037FF, 0xFF9FFF2B, 0xFFFF5C2B, 0xFFFFFB91, 0xFFBD8DFF, 0xFFFF9F40,
    0xFF5D5FEF, 0xFFFF5C5C,
  ];
  late int _selectedColor;

  // 'none' | 'period' | 'date'
  String _deadlineType = 'none';
  String _periodDurationType = 'День';
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  bool _isDaily = true;
  final List<int> _selectedDays = [];
  final List<String> _dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд'];

  final List<String> _reminderTimes = [];

  @override
  void initState() {
    super.initState();
    _selectedColor = _colors[4]; // green default
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _periodDurationController.dispose();
    super.dispose();
  }

  void _handleCreate() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введіть назву цілі')),
      );
      return;
    }

    final goal = GoalModel(
      title: _titleController.text.trim(),
      category: _selectedCategory,
      colorValue: _selectedColor,
      deadlineType: _deadlineType,
      periodDuration: _deadlineType == 'period'
          ? int.tryParse(_periodDurationController.text)
          : null,
      periodDurationType:
          _deadlineType == 'period' ? _periodDurationType : null,
      endDate: _deadlineType == 'date' ? _endDate : null,
      isDaily: _isDaily,
      selectedDays: _isDaily ? [] : _selectedDays,
      reminderTimes: _reminderTimes,
      note: _noteController.text.trim(),
      createdAt: DateTime.now(),
    );

    widget.onCreate(goal);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF041219),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(
              top: 40 + MediaQuery.of(context).padding.top,
              bottom: 24,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF333F44), width: 1)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: widget.onCancel,
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: Color(0xFFF9FFFA), size: 24),
                ),
                const Expanded(
                  child: Text(
                    'Нова Ціль',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFFF9FFFA),
                        fontSize: 24,
                        fontFamily: 'Tenor Sans'),
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
                    padding: const EdgeInsets.only(
                        left: 40, right: 40, top: 32, bottom: 120),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Назва', 'Якої цілі хочете досягти?'),
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
                        _buildSectionTitle('Термін цілі', null),
                        const SizedBox(height: 16),
                        _buildDeadlineSettings(),

                        const SizedBox(height: 32),
                        _buildSectionTitle('Графік', null),
                        const SizedBox(height: 16),
                        _buildSchedule(),

                        const SizedBox(height: 32),
                        _buildSectionTitle('Час прийому', null),
                        const SizedBox(height: 16),
                        _buildTimeReminders(),

                        const SizedBox(height: 32),
                        _buildSectionTitle(
                            'Додати нотатку', 'Опис або додаткова інформація'),
                        const SizedBox(height: 16),
                        _buildNoteInput(),
                      ],
                    ),
                  ),
                ),

                // Bottom buttons
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: widget.onCancel,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF041219),
                                border: Border.all(
                                    color: const Color(0x7FFAFFFB), width: 1.5),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              alignment: Alignment.center,
                              child: const Text('Скасувати',
                                  style: TextStyle(
                                      color: Color(0xFFFAFFFB),
                                      fontSize: 18,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600)),
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
                                border: Border.all(
                                    color: const Color(0xFF91FFA4), width: 1.5),
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Color(0x3F041319),
                                      blurRadius: 20,
                                      offset: Offset(0, 2))
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Text('Створити',
                                  style: TextStyle(
                                      color: Color(0xFFFAFFFB),
                                      fontSize: 18,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600)),
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

  // ── UI helpers ──────────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title, String? subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Color(0xFFF9FFFA),
                fontSize: 20,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600)),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(subtitle,
              style: const TextStyle(
                  color: Color(0xFFBCC4C2),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w300)),
        ]
      ],
    );
  }

  Widget _buildTitleInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
          color: const Color(0xFFF9FFFA),
          borderRadius: BorderRadius.circular(50)),
      child: TextField(
        controller: _titleController,
        style: const TextStyle(
            color: Color(0xFF04131A), fontSize: 16, fontFamily: 'Inter'),
        decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Ранкова пробіжка',
            hintStyle: TextStyle(color: Color(0xFF8A9A95))),
      ),
    );
  }

  Widget _buildCategories() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((cat) {
        final isSel = _selectedCategory == cat;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
                color: isSel
                    ? const Color(0xFF91FFA4)
                    : const Color(0xFF274E3C),
                borderRadius: BorderRadius.circular(100)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(cat,
                    style: TextStyle(
                        color: isSel
                            ? const Color(0xFF041219)
                            : const Color(0xFFF9FFFA),
                        fontSize: 16,
                        fontFamily: 'Inter')),
                if (isSel) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check,
                      size: 16, color: Color(0xFF041219))
                ]
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorPalette() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _colors.map((color) {
        final isSel = _selectedColor == color;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                color: Color(color),
                shape: BoxShape.circle,
                border: isSel
                    ? Border.all(color: const Color(0xFFF9FFFA), width: 2)
                    : null),
            child: isSel
                ? const Icon(Icons.check, color: Color(0xFF041219), size: 16)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDeadlineSettings() {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFF1D2A30),
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildDeadlineRow(
            type: 'none',
            title: 'Без обмежень',
            subtitle: 'Постійна звичка',
          ),
          _buildDivider(),
          _buildDeadlineRow(
            type: 'period',
            title: 'Протягом періоду',
            subtitle: 'Наприклад, 42 дня',
            expandedChild: _deadlineType == 'period'
                ? _buildPeriodInput()
                : null,
          ),
          _buildDivider(),
          _buildDeadlineRow(
            type: 'date',
            title: 'Кінцева дата',
            subtitle: _deadlineType == 'date'
                ? 'До ${_endDate.day.toString().padLeft(2, '0')}.${_endDate.month.toString().padLeft(2, '0')} (${_endDate.difference(DateTime.now()).inDays} днів)'
                : 'Наприклад, до 30.05 (30 днів)',
            expandedChild: _deadlineType == 'date'
                ? _buildDatePicker()
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineRow({
    required String type,
    required String title,
    required String subtitle,
    Widget? expandedChild,
  }) {
    final isOn = _deadlineType == type;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Color(0xFFF9FFFA), fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Color(0xFFBCC4C2), fontSize: 12)),
                ],
              ),
              Switch(
                value: isOn,
                onChanged: (_) =>
                    setState(() => _deadlineType = isOn ? 'none' : type),
                activeThumbColor: const Color(0xFF91FFA4),
                activeTrackColor: const Color(0xFF274E3C),
                inactiveThumbColor: const Color(0xFFBCC4C2),
                inactiveTrackColor: const Color(0xFF333F44),
              ),
            ],
          ),
          if (expandedChild != null) ...[
            const SizedBox(height: 12),
            expandedChild,
          ],
        ],
      ),
    );
  }

  Widget _buildPeriodInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Тривалість',
            style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: const BoxDecoration(
                    color: Color(0xFF28353B),
                    borderRadius:
                        BorderRadius.horizontal(left: Radius.circular(12))),
                child: TextField(
                  controller: _periodDurationController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Color(0xFF91FFA4), fontSize: 16),
                  decoration:
                      const InputDecoration(border: InputBorder.none),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                    color: Color(0xFF333F44),
                    borderRadius:
                        BorderRadius.horizontal(right: Radius.circular(12))),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _periodDurationType,
                    dropdownColor: const Color(0xFF333F44),
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: Color(0xFF91FFA4)),
                    style: const TextStyle(
                        color: Color(0xFF91FFA4), fontSize: 16),
                    onChanged: (val) =>
                        setState(() => _periodDurationType = val!),
                    items: ['День', 'Тиждень', 'Місяць']
                        .map((e) =>
                            DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _endDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 3650)),
          builder: (context, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF91FFA4),
                onPrimary: Color(0xFF041219),
                surface: Color(0xFF1D2A30),
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _endDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            color: const Color(0xFF28353B),
            borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_endDate.day.toString().padLeft(2, '0')}.${_endDate.month.toString().padLeft(2, '0')}.${_endDate.year}',
              style: const TextStyle(
                  color: Color(0xFF91FFA4),
                  fontSize: 16,
                  fontFamily: 'Inter'),
            ),
            const Icon(Icons.calendar_today_outlined,
                color: Color(0xFF91FFA4), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isDaily = true),
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: _isDaily
                          ? const Color(0xFF1D2A30)
                          : const Color(0xFF333F44),
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(12))),
                  child: Text('Щодня',
                      style: TextStyle(
                          color: _isDaily
                              ? const Color(0xFF91FFA4)
                              : const Color(0xFFF9FFFA),
                          fontSize: 16)),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isDaily = false),
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: !_isDaily
                          ? const Color(0xFF1D2A30)
                          : const Color(0xFF333F44),
                      borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(12))),
                  child: Text('Дні тижня',
                      style: TextStyle(
                          color: !_isDaily
                              ? const Color(0xFF91FFA4)
                              : const Color(0xFFF9FFFA),
                          fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
        if (!_isDaily) ...[
          const SizedBox(height: 16),
          const Text('Виберіть дні',
              style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final dayIndex = i + 1;
              final isSel = _selectedDays.contains(dayIndex);
              return GestureDetector(
                onTap: () => setState(() {
                  if (isSel) {
                    _selectedDays.remove(dayIndex);
                  } else {
                    _selectedDays.add(dayIndex);
                  }
                }),
                child: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: isSel
                          ? const Color(0x3F91FFA4)
                          : Colors.transparent,
                      shape: BoxShape.circle),
                  child: Text(_dayNames[i],
                      style: TextStyle(
                          color: isSel
                              ? const Color(0xFF91FFA4)
                              : const Color(0xFFF9FFFA),
                          fontSize: 14)),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildTimeReminders() {
    String daysText = 'Щодня';
    if (!_isDaily && _selectedDays.isNotEmpty) {
      final sorted = List<int>.from(_selectedDays)..sort();
      daysText = sorted.map((d) => _dayNames[d - 1]).join(', ');
    } else if (!_isDaily && _selectedDays.isEmpty) {
      daysText = 'Дні не вибрано';
    }

    return Column(
      children: [
        ..._reminderTimes.asMap().entries.map((entry) {
          final idx = entry.key;
          final time = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2BBBFF), Color(0xFF91FFA3), Color(0xFFFFCC00)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 3),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF1D2A30),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(time,
                            style: const TextStyle(
                                color: Color(0xFFF9FFFA),
                                fontSize: 24,
                                fontFamily: 'Inter')),
                        const SizedBox(height: 4),
                        Text(daysText,
                            style: const TextStyle(
                                color: Color(0xFFBCC4C2),
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w300)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _reminderTimes.removeAt(idx)),
                      child: const Icon(Icons.close,
                          color: Color(0xFFBCC4C2)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        GestureDetector(
          onTap: () => _showTimePicker(
            onConfirm: (time, newIsDaily, newDays) {
              setState(() {
                if (!_reminderTimes.contains(time)) {
                  _reminderTimes.add(time);
                }
                _isDaily = newIsDaily;
                _selectedDays.clear();
                _selectedDays.addAll(newDays);
              });
            },
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: const Color(0xFF1D2A30),
                borderRadius: BorderRadius.circular(12)),
            child: const Text('+ Додати час прийому',
                style: TextStyle(
                    color: Color(0xFFF9FFFA),
                    fontSize: 16,
                    fontFamily: 'Inter')),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFFF9FFFA),
          borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: _noteController,
        maxLines: 3,
        style: const TextStyle(color: Color(0xFF04131A), fontSize: 16),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Наприклад: Я хочу створити звичку бігати кожен ранок',
          hintStyle: TextStyle(color: Color(0xFFBCC4C2)),
        ),
      ),
    );
  }

  Widget _buildDivider() => const Divider(
        height: 1,
        thickness: 1,
        color: Color(0xFF333F44),
        indent: 16,
        endIndent: 16,
      );

  void _showTimePicker({
    required Function(String time, bool isDaily, List<int> days) onConfirm,
  }) {
    DateTime tempTime = DateTime.now();
    bool tempIsDaily = _isDaily;
    List<int> tempDays = List.from(_selectedDays);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          String daysText = 'Щодня';
          if (!tempIsDaily && tempDays.isNotEmpty) {
            final sorted = List<int>.from(tempDays)..sort();
            daysText = sorted.map((d) => _dayNames[d - 1]).join(', ');
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
                Container(
                    height: 1,
                    width: double.infinity,
                    color: const Color(0xFFE27B58).withValues(alpha: 0.4)),
                const SizedBox(height: 32),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text('Встановити час',
                      style: TextStyle(
                          color: Color(0xFFF9FFFA),
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: CupertinoTheme(
                    data: const CupertinoThemeData(
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: TextStyle(
                            color: Color(0xFF91FFA4), fontSize: 32),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Встановити день',
                          style: TextStyle(
                              color: Color(0xFFF9FFFA),
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text.rich(TextSpan(children: [
                        const TextSpan(
                            text: 'Кожн. ',
                            style: TextStyle(
                                color: Color(0xFFF9FFFA), fontSize: 14)),
                        TextSpan(
                            text: daysText,
                            style: const TextStyle(
                                color: Color(0xFF91FFA4), fontSize: 14)),
                      ])),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (i) {
                          final dayIndex = i + 1;
                          final isSel =
                              !tempIsDaily && tempDays.contains(dayIndex);
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
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: isSel
                                      ? const Color(0xFF274E3C)
                                      : Colors.transparent,
                                  shape: BoxShape.circle),
                              child: Text(_dayNames[i],
                                  style: TextStyle(
                                      color: isSel
                                          ? const Color(0xFF91FFA4)
                                          : const Color(0xFFF9FFFA),
                                      fontSize: 14,
                                      fontWeight: isSel
                                          ? FontWeight.w600
                                          : FontWeight.w400)),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: const Color(0xFFF9FFFA)
                                      .withValues(alpha: 0.5),
                                  width: 1)),
                          child: const Icon(Icons.close,
                              color: Color(0xFFF9FFFA), size: 28),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          final formatted =
                              '${tempTime.hour.toString().padLeft(2, '0')}:${tempTime.minute.toString().padLeft(2, '0')}';
                          onConfirm(formatted, tempIsDaily, tempDays);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 64,
                          height: 64,
                          padding: const EdgeInsets.all(1.5),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [
                                Color(0xFF2BBBFF),
                                Color(0xFF91FFA3),
                                Color(0xFFFFCC00)
                              ],
                            ),
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF041219)),
                            child: const Icon(Icons.check,
                                color: Color(0xFF91FFA4), size: 28),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}
