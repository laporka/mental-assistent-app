import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../widgets/loading_helper.dart';
import '../../../widgets/dynamic_glow_button.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _editingField = ''; 
  List<String> _currentTagsToEdit = [];
  List<String> _availableTagsToEdit = [];
  String _editorTitle = '';

  String get _registrationDate {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.metadata.creationTime != null) {
      return DateFormat('dd.MM.yyyy').format(user.metadata.creationTime!);
    }
    return "Невідомо";
  }

  void _openEditor(String field, String title, List<String> currentTags, List<String> availableTags) {
    setState(() {
      _editingField = field;
      _editorTitle = title;
      _currentTagsToEdit = List.from(currentTags);
      _availableTagsToEdit = availableTags;
    });
  }

  void _closeEditor() {
    setState(() {
      _editingField = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scaleX = size.width / 360;
    final double scaleY = size.height / 800;
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF041219),
        body: Center(child: Text("Помилка авторизації", style: TextStyle(color: Colors.white))),
      );
    }

    if (_editingField == 'interests' || _editingField == 'hardest_things') {
      return ProfileTagsEditor(
        title: _editorTitle,
        firestoreField: _editingField,
        initialTags: _currentTagsToEdit,
        availableTags: _availableTagsToEdit,
        onCancel: _closeEditor,
        onSaveSuccess: _closeEditor,
      );
    }

    if (_editingField == 'notifications') {
      return NotificationsSettingsView(onBack: _closeEditor);
    }

    if (_editingField == 'privacy') {
      return PrivacySettingsView(onBack: _closeEditor);
    }

    if (_editingField == 'integrations') {
      return IntegrationsSettingsView(onBack: _closeEditor);
    }

    if (_editingField == 'about') {
      return AboutAppView(onBack: _closeEditor);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF041219),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2BBBFF)));
          }

          String userName = "Користувач";
          List<String> interests = [];
          List<String> hardestThings = [];

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>?;
            if (data != null) {
              userName = data['name'] ?? userName;
              if (data['interests'] != null) interests = List<String>.from(data['interests']);
              if (data['hardest_things'] != null) hardestThings = List<String>.from(data['hardest_things']);
            }
          }

          return Stack(
            children: [
              Positioned(
                left: -94 * scaleX, top: -252 * scaleY,
                child: Opacity(
                  opacity: 0.50,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 80.0, sigmaY: 80.0),
                    child: Container(
                      width: 322 * scaleX, height: 467 * scaleY,
                      decoration: const ShapeDecoration(
                        gradient: LinearGradient(begin: Alignment(0.65, 0.94), end: Alignment(-0.02, 0.59), colors: [Color(0xFF2BBBFF), Color(0xFF91FFA3), Color(0xFFFFCC00)]),
                        shape: OvalBorder(),
                      ),
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 24), 
                            const Text('Профіль', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 24, fontFamily: 'Tenor Sans')),
                            Container(
                              width: 24, height: 24,
                              decoration: const BoxDecoration(color: Color(0xFF04131A), shape: BoxShape.circle),
                              child: const Center(child: Icon(Icons.question_mark_rounded, color: Color(0xFFF9FFFA), size: 16)),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        Container(width: double.infinity, height: 1, color: const Color(0xFF333F44).withValues(alpha: 0.5)),
                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Container(
                              width: 64, height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF4B895E), width: 1.5),
                                color: const Color(0xFF4B895E).withValues(alpha: 0.2),
                              ),
                              child: const Center(child: Icon(Icons.person, color: Color(0xFF4B895E), size: 40)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(userName, style: const TextStyle(color: Color(0xFFF9FFFA), fontSize: 24, fontFamily: 'Tenor Sans'), overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text('Разом з Iris з $_registrationDate', style: const TextStyle(color: Color(0xFFBCC4C2), fontSize: 13, fontFamily: 'Inter')),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 40),

                        _buildSectionHeader(
                          title: 'Мої інтереси', 
                          actionText: 'Змінити', 
                          onActionTap: () => _openEditor('interests', 'Мої інтереси', interests, ['Фільми', 'Музика', 'Книги', 'Наука', 'Ігри', 'Малювання', 'Мистецтво', 'Природа', 'Подорожі', 'Спорт', 'Технології']),
                        ),
                        const SizedBox(height: 16),
                        if (interests.isEmpty) const Text('Ще не обрано жодного інтересу', style: TextStyle(color: Color(0xFFBCC4C2), fontSize: 14, fontFamily: 'Inter'))
                        else ...[
                          _buildTagsWrap(interests),
                          const SizedBox(height: 8),
                          if (interests.length > 5) const Align(alignment: Alignment.centerRight, child: Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFF9FFFA))),
                        ],
                        const SizedBox(height: 24),

                        _buildSectionHeader(
                          title: 'Зараз найважче', 
                          actionText: 'Змінити', 
                          onActionTap: () => _openEditor('hardest_things', 'Що зараз найважче?', hardestThings, ['Тривога', 'Самотність', 'Стрес', 'Панічні атаки', 'ПТСР', 'Втома', 'Труднощі зі сном', 'Нічого конкретного']),
                        ),
                        const SizedBox(height: 16),
                        if (hardestThings.isEmpty) const Text('Поки що нічого не вказано', style: TextStyle(color: Color(0xFFBCC4C2), fontSize: 14, fontFamily: 'Inter'))
                        else _buildTagsWrap(hardestThings),
                        
                        const SizedBox(height: 40),

                        const Text('Налаштування', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 20, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(color: const Color(0xFF1D2A30), borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            children: [
                              _buildSettingsTile(
                                iconPath: 'assets/icons/bell.svg', 
                                iconColor: const Color(0xFF91FFA4), 
                                title: 'Сповіщення', 
                                subtitle: 'Налаштування push', 
                                onTap: () => setState(() => _editingField = 'notifications')
                              ),
                              Container(height: 1, color: const Color(0xFF333F44), margin: const EdgeInsets.symmetric(horizontal: 16)),
                              _buildSettingsTile(
                                iconPath: 'assets/icons/user-lock.svg', 
                                iconColor: const Color(0xFF91FFA4), 
                                title: 'Приватність', 
                                subtitle: 'Дані та аналіз', 
                                onTap: () => setState(() => _editingField = 'privacy')
                              ),
                              Container(height: 1, color: const Color(0xFF333F44), margin: const EdgeInsets.symmetric(horizontal: 16)),
                              _buildSettingsTile(
                                iconPath: 'assets/icons/plug.svg', 
                                iconColor: const Color(0xFF91FFA4), 
                                title: 'Інтеграції', 
                                subtitle: 'API', 
                                onTap: () => setState(() => _editingField = 'integrations') 
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        const Text('Про додаток', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 20, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(color: const Color(0xFF1D2A30), borderRadius: BorderRadius.circular(20)),
                          child: _buildSettingsTile(
                            iconPath: 'assets/icons/awesome.svg', 
                            iconColor: const Color(0xFF91FFA4), 
                            title: 'Iris', 
                            subtitle: 'Бета-версія', 
                            onTap: () => setState(() => _editingField = 'about') // ПІДКЛЮЧЕНО
                          ),
                        ),

                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required String actionText, required VoidCallback onActionTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(title, style: const TextStyle(color: Color(0xFFF9FFFA), fontSize: 20, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
        GestureDetector(
          onTap: onActionTap,
          child: Padding(padding: const EdgeInsets.only(left: 10, bottom: 2, top: 10), child: Text(actionText, style: const TextStyle(color: Color(0xFFBCC4C2), fontSize: 14, fontFamily: 'Inter'))),
        ),
      ],
    );
  }

  Widget _buildTagsWrap(List<String> tags) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFF4B895E), borderRadius: BorderRadius.circular(100)),
          child: Text(tag, style: const TextStyle(color: Color(0xFFF9FFFA), fontSize: 13, fontFamily: 'Inter')),
        );
      }).toList(),
    );
  }

  Widget _buildSettingsTile({required String iconPath, required Color iconColor, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: const BoxDecoration(color: Color(0xFF27363D), shape: BoxShape.circle),
              child: Center(child: SvgPicture.asset(iconPath, width: 20, height: 20, colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn))),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFFF9FFFA), fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Color(0xFFBCC4C2), fontSize: 12, fontFamily: 'Inter')),
              ],
            )
          ],
        ),
      ),
    );
  }
}




class AboutAppView extends StatelessWidget {
  final VoidCallback onBack;
  const AboutAppView({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scaleX = size.width / 360;
    final double scaleY = size.height / 800;

    return Scaffold(
      backgroundColor: const Color(0xFF041219),
      body: Stack(
        children: [
          Positioned(
            left: -120 * scaleX, top: -100 * scaleY,
            child: Opacity(
              opacity: 0.45,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 80.0, sigmaY: 80.0),
                child: Container(
                  width: 322 * scaleX, height: 467 * scaleY,
                  decoration: const ShapeDecoration(
                    gradient: LinearGradient(begin: Alignment(0.65, 0.94), end: Alignment(-0.02, 0.59), colors: [Color(0xFF2BBBFF), Color(0xFF91FFA3), Color(0xFFFFCC00)]),
                    shape: OvalBorder(),
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Важливо', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 36, fontFamily: 'Tenor Sans')),
                        const SizedBox(height: 8),
                        const Text('Бета-версія Iris', style: TextStyle(color: Color(0xFF91FFA4), fontSize: 20, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                        const SizedBox(height: 32),

                        const Text('Ми постійно вдосконалюємось.\nЗараз Iris — це\nекспериментальний інструмент.', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 16, fontFamily: 'Inter', height: 1.4, fontWeight: FontWeight.w400)),
                        const SizedBox(height: 24),
                        const Text('Будь ласка, прочитай кілька\nважливих моментів.', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 16, fontFamily: 'Inter', height: 1.4, fontWeight: FontWeight.w400)),
                        const SizedBox(height: 32),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32, height: 32,
                              decoration: const BoxDecoration(color: Color(0xFF27363D), shape: BoxShape.circle),
                              child: const Icon(Icons.close, color: Color(0xFFFFCC00), size: 18),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(fontSize: 15, fontFamily: 'Inter', height: 1.4),
                                  children: [
                                    TextSpan(text: 'Не діліться конфіденційною\nінформацією: ', style: TextStyle(color: Color(0xFFFFCC00))),
                                    TextSpan(text: 'паролями,\nданими банківських карток\nабо документами.', style: TextStyle(color: Color(0xFFF9FFFA))),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32, height: 32,
                              decoration: const BoxDecoration(color: Color(0xFF27363D), shape: BoxShape.circle),
                              child: const Icon(Icons.check, color: Color(0xFF91FFA4), size: 18),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(fontSize: 15, fontFamily: 'Inter', height: 1.4),
                                  children: [
                                    TextSpan(text: 'Давайте зосередимось на\nваших ', style: TextStyle(color: Color(0xFFF9FFFA))),
                                    TextSpan(text: 'почуттях та думках.', style: TextStyle(color: Color(0xFF91FFA4))),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),


                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Center(
                    child: DynamicGlowButton(
                      text: 'Зрозуміло',
                      isActive: true,
                      onTap: onBack,
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class IntegrationsSettingsView extends StatefulWidget {
  final VoidCallback onBack;
  const IntegrationsSettingsView({super.key, required this.onBack});

  @override
  State<IntegrationsSettingsView> createState() => _IntegrationsSettingsViewState();
}

class _IntegrationsSettingsViewState extends State<IntegrationsSettingsView> {
  final String _geminiKey = 'AQ.Ab***************************';
  final String _openAiKey = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF041219),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
              child: Row(
                children: [
                  GestureDetector(onTap: widget.onBack, child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFF9FFFA), size: 22)),
                  const Expanded(child: Text('Інтеграції', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 24, fontFamily: 'Tenor Sans'))),
                  const SizedBox(width: 22), 
                ],
              ),
            ),
            Container(width: double.infinity, height: 1, color: const Color(0xFF333F44).withValues(alpha: 0.5)),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('API-ключ', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFF1D2A30), borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Підключи власний ключ\nGemini або OpenAI', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w500, height: 1.3)),
                          const SizedBox(height: 8),
                          const Text('Iris буде використовувати його замість\nстандартного', style: TextStyle(color: Color(0xFFBCC4C2), fontSize: 12, fontFamily: 'Inter', height: 1.4)),
                          const SizedBox(height: 24),

                          const Text('Gemini API Key', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                          const SizedBox(height: 12),
                          _buildApiKeyField(value: _geminiKey, hintText: 'Gemini API Key', hasValue: _geminiKey.isNotEmpty),
                          const SizedBox(height: 24),

                          const Text('OpenAI API Key', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                          const SizedBox(height: 12),
                          _buildApiKeyField(value: _openAiKey, hintText: 'OpenAI API Key', hasValue: _openAiKey.isNotEmpty),

                          const SizedBox(height: 24),
                          const Text('Ключі зберігаються лише локально на\nпристрої', style: TextStyle(color: Color(0xFFBCC4C2), fontSize: 12, fontFamily: 'Inter', height: 1.4)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 120), 
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiKeyField({required String value, required String hintText, required bool hasValue}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: const Color(0xFF27363D), borderRadius: BorderRadius.circular(12)),
          child: Text(
            hasValue ? value : hintText,
            style: TextStyle(color: hasValue ? const Color(0xFF91FFA4) : const Color(0xFF4B895E), fontSize: 14, fontFamily: 'Inter'),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
        ),
        if (hasValue) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: const Color(0xFF27363D), borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Text('Змінити', style: TextStyle(color: Color(0xFF91FFA4), fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w500))),
            ),
          ),
        ]
      ],
    );
  }
}



class PrivacySettingsView extends StatefulWidget {
  final VoidCallback onBack;
  const PrivacySettingsView({super.key, required this.onBack});

  @override
  State<PrivacySettingsView> createState() => _PrivacySettingsViewState();
}

class _PrivacySettingsViewState extends State<PrivacySettingsView> {
  bool _activityAnalysis = true;
  bool _aiInsights = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF041219),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
              child: Row(
                children: [
                  GestureDetector(onTap: widget.onBack, child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFF9FFFA), size: 22)),
                  const Expanded(child: Text('Приватність', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 24, fontFamily: 'Tenor Sans'))),
                  const SizedBox(width: 22), 
                ],
              ),
            ),
            Container(width: double.infinity, height: 1, color: const Color(0xFF333F44).withValues(alpha: 0.5)),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Аналіз', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(color: const Color(0xFF1D2A30), borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        children: [
                          _buildSwitchTile(title: 'Аналіз активності', subtitle: 'Для проактивних повідомлень', value: _activityAnalysis, onChanged: (val) => setState(() => _activityAnalysis = val)),
                          Container(height: 1, color: const Color(0xFF333F44), margin: const EdgeInsets.symmetric(horizontal: 16)),
                          _buildSwitchTile(title: 'AI-інсайти зі щоденника', subtitle: 'Iris аналізує записи', value: _aiInsights, onChanged: (val) => setState(() => _aiInsights = val)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 120), 
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({required String title, required String subtitle, required bool value, required Function(bool) onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFFF9FFFA), fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Color(0xFFBCC4C2), fontSize: 12, fontFamily: 'Inter')),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF91FFA4), activeTrackColor: const Color(0xFF274E3C), inactiveThumbColor: const Color(0xFF91FFA4), inactiveTrackColor: const Color(0xFF333F44), trackOutlineColor: WidgetStateProperty.all(Colors.transparent)),
        ],
      ),
    );
  }
}



class NotificationsSettingsView extends StatefulWidget {
  final VoidCallback onBack;
  const NotificationsSettingsView({super.key, required this.onBack});

  @override
  State<NotificationsSettingsView> createState() => _NotificationsSettingsViewState();
}

class _NotificationsSettingsViewState extends State<NotificationsSettingsView> {
  bool _irisProactive = true;
  bool _trackersEnabled = true;
  bool _goalsEnabled = true;
  bool _dailyCheckInEnabled = true;
  bool _repeatReminderEnabled = true;
  bool _irisAskMissedEnabled = false; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF041219),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
              child: Row(
                children: [
                  GestureDetector(onTap: widget.onBack, child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFF9FFFA), size: 22)),
                  const Expanded(child: Text('Сповіщення', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 24, fontFamily: 'Tenor Sans'))),
                  const SizedBox(width: 22), 
                ],
              ),
            ),
            Container(width: double.infinity, height: 1, color: const Color(0xFF333F44).withValues(alpha: 0.5)), 

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Проактивність', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    _buildSettingsGroup([
                      _buildSwitchTile(title: 'Iris першою пише', subtitle: 'Проактивні повідомлення', value: _irisProactive, onChanged: (val) => setState(() => _irisProactive = val)),
                    ]),
                    const SizedBox(height: 32),

                    const Text('Нагадування', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    _buildSettingsGroup([
                      _buildSwitchTile(title: 'Трекери', subtitle: 'Push при настанні часу', value: _trackersEnabled, onChanged: (val) => setState(() => _trackersEnabled = val)),
                      _buildDivider(),
                      _buildSwitchTile(title: 'Цілі', subtitle: 'За 10 хв до часу виконання', value: _goalsEnabled, onChanged: (val) => setState(() => _goalsEnabled = val)),
                      _buildDivider(),
                      _buildSwitchTile(title: 'Щоденний чек-ін', subtitle: 'Щовечора о 21:00', value: _dailyCheckInEnabled, onChanged: (val) => setState(() => _dailyCheckInEnabled = val)),
                    ]),
                    const SizedBox(height: 32),

                    const Text('Пропуск', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    _buildSettingsGroup([
                      _buildSwitchTile(title: 'Повторне нагадування', subtitle: 'Через 2 год після пропуску', value: _repeatReminderEnabled, onChanged: (val) => setState(() => _repeatReminderEnabled = val)),
                      _buildDivider(),
                      _buildSwitchTile(title: 'Iris запитає про пропуск', subtitle: 'За 10 хв до часу виконання', value: _irisAskMissedEnabled, onChanged: (val) => setState(() => _irisAskMissedEnabled = val)),
                    ]),

                    const SizedBox(height: 120), 
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(decoration: BoxDecoration(color: const Color(0xFF1D2A30), borderRadius: BorderRadius.circular(20)), child: Column(children: children));
  }

  Widget _buildSwitchTile({required String title, required String subtitle, required bool value, required Function(bool) onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFFF9FFFA), fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Color(0xFFBCC4C2), fontSize: 12, fontFamily: 'Inter')),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF91FFA4), activeTrackColor: const Color(0xFF274E3C), inactiveThumbColor: const Color(0xFF91FFA4), inactiveTrackColor: const Color(0xFF333F44), trackOutlineColor: WidgetStateProperty.all(Colors.transparent)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: const Color(0xFF333F44), margin: const EdgeInsets.symmetric(horizontal: 16));
  }
}



class ProfileTagsEditor extends StatefulWidget {
  final String title;
  final String firestoreField;
  final List<String> initialTags;
  final List<String> availableTags;
  final VoidCallback onCancel;
  final VoidCallback onSaveSuccess;

  const ProfileTagsEditor({
    super.key, required this.title, required this.firestoreField,
    required this.initialTags, required this.availableTags,
    required this.onCancel, required this.onSaveSuccess,
  });

  @override
  State<ProfileTagsEditor> createState() => _ProfileTagsEditorState();
}

class _ProfileTagsEditorState extends State<ProfileTagsEditor> {
  late List<String> _selectedTags;

  @override
  void initState() {
    super.initState();
    _selectedTags = List.from(widget.initialTags);
  }

  Future<void> _save() async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    LoadingHelper.show(context);
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({widget.firestoreField: _selectedTags});
      if (mounted) { LoadingHelper.hide(context); widget.onSaveSuccess(); }
    } catch (e) {
      if (mounted) { LoadingHelper.hide(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Помилка: $e'))); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF041219),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 40, bottom: 120, left: 24, right: 24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: const TextStyle(color: Color(0xFFF9FFFA), fontSize: 22, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                    const SizedBox(height: 32),
                    Wrap(
                      spacing: 12, runSpacing: 16,
                      children: widget.availableTags.map((tag) {
                        final isSelected = _selectedTags.contains(tag);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (tag == 'Нічого конкретного') {
                                if (isSelected) _selectedTags.remove(tag);
                                else { _selectedTags.clear(); _selectedTags.add(tag); }
                              } else {
                                if (isSelected) _selectedTags.remove(tag);
                                else { _selectedTags.remove('Нічого конкретного'); _selectedTags.add(tag); }
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(color: isSelected ? const Color(0xFF91FFA4) : const Color(0xFF283B31), borderRadius: BorderRadius.circular(30)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(tag, style: TextStyle(color: isSelected ? const Color(0xFF041219) : const Color(0xFFF9FFFA), fontSize: 15, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                                if (isSelected) ...[const SizedBox(width: 8), const Icon(Icons.check, color: Color(0xFF041219), size: 18)]
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: widget.onCancel,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: const Color(0xFF041219), border: Border.all(color: const Color(0x7FFAFFFB), width: 1.5), borderRadius: BorderRadius.circular(50)),
                          alignment: Alignment.center,
                          child: const Text('Скасувати', style: TextStyle(color: Color(0xFFFAFFFB), fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: _save,
                        child: Container(
                          padding: const EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2BBBFF), Color(0xFF91FFA4), Color(0xFFFFCC00)]),
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: const [BoxShadow(color: Color(0x3F041319), blurRadius: 20, offset: Offset(0, 2))],
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14.5), 
                            decoration: BoxDecoration(color: const Color(0xFF04131A), borderRadius: BorderRadius.circular(50)),
                            alignment: Alignment.center,
                            child: const Text('Зберегти', style: TextStyle(color: Color(0xFFFAFFFB), fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                          ),
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
    );
  }
}