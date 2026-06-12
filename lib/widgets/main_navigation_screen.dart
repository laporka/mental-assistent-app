import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../screens/MainApp/diary_screen.dart';
import '../screens/MainApp/calendar_screen.dart';
import 'chat_tab_wrapper.dart';

class HomeScreenPlaceholder extends StatelessWidget { const HomeScreenPlaceholder({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Головна Панель'))); }
class ProfileScreenPlaceholder extends StatelessWidget { const ProfileScreenPlaceholder({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Профіль'))); }

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scaleX = size.width / 360;

    final List<Widget> screens = [
      const HomeScreenPlaceholder(),
      const DiaryHomeScreen(),
      const ChatTabWrapper(),
      const CalendarHomeScreen(),
      const ProfileScreenPlaceholder(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF041219),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        width: size.width,
        padding: EdgeInsets.only(
          top: 24,
          left: 24 * scaleX,
          right: 24 * scaleX,
          bottom: 24 + MediaQuery.of(context).padding.bottom, 
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF1D2A30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildMenuButton(index: 0, iconPath: 'assets/icons/ic_round-home.svg'),
            _buildMenuButton(index: 1, iconPath: 'assets/icons/ic_baseline-mode.svg'),
            _buildMenuButton(index: 2, iconPath: 'assets/icons/ic_baseline-chat-bubble.svg'),
            _buildMenuButton(index: 3, iconPath: 'assets/icons/ic_baseline-calendar-today.svg'),
            _buildMenuButton(index: 4, iconPath: 'assets/icons/ic_sharp-person.svg'),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({required int index, required String iconPath}) {
    final bool isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isActive
              ? const LinearGradient(
                  begin: Alignment(1.00, 0.00),
                  end: Alignment(0.00, 1.00),
                  colors: [Color(0xFF2BBCFF), Color(0xFF91FFA4), Color(0xFFFFCC00)],
                )
              : null,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF91FFA4).withValues(alpha: 0.35),
                    blurRadius: 18,
                    spreadRadius: 1.5,
                  )
                ]
              : null,
        ),
        child: SvgPicture.asset(
          iconPath,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            isActive ? const Color(0xFF041219) : Colors.white,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}