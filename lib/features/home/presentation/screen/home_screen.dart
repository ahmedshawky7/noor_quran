import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:noor_quran/core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  final Widget child;
  const HomeScreen({super.key, required this.child});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        backgroundColor: const Color(
          0xfff8f3e8,
        ), // نفس لون خلفية ورقة المصحف لخلق تناغم بصري
        indicatorColor: AppTheme.accentColor.withOpacity(0.15), // هالة خضراء خفيفة حول الأيقونة النشطة

        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/bookmarks');
              break;
            case 2:
              context.go('/azkar');
              break;
            case 3:
              context.go('/hadith');
              break;
            case 4:
              context.go('/khatma');
              break;
          }
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home, color: Theme.of(context).primaryColor),
            label:
            'الرئيسية', // تحويل التسميات للعربية ليتناسق مع واجهة التطبيق العربية بالكامل
          ),
          NavigationDestination(
            icon: Icon(
              Icons.bookmark_border,
              color: Theme.of(context).primaryColor,
            ),
            selectedIcon: Icon(
              Icons.bookmark,
              color: Theme.of(context).primaryColor,
            ),
            label: 'العلامات',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.volunteer_activism_outlined,
              color: Theme.of(context).primaryColor,
            ),
            label: 'الأذكار',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.history_edu,
              color: Theme.of(context).primaryColor,
            ),
            label: 'الأحاديث',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.brightness_auto,
              color: Theme.of(context).primaryColor,
            ),
            label: 'الخاتمة',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/ai-assistant'),
        child: const Icon(Icons.assistant),
      ),
    );
  }
}