import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
        backgroundColor: const Color(0xfff8f3e8), // نفس لون خلفية ورقة المصحف لخلق تناغم بصري
        indicatorColor: const Color(0xff1a472a).withOpacity(0.15), // هالة خضراء خفيفة حول الأيقونة النشطة
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          switch (index) {
            case 0: context.go('/'); break;
            case 1: context.go('/bookmarks'); break;
            case 2: context.go('/azkar'); break;
            case 3: context.go('/hadith'); break;
            case 4: context.go('/khatma'); break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book, color: Color(0xff1a472a)),
            label: 'القرآن', // تحويل التسميات للعربية ليتناسق مع واجهة التطبيق العربية بالكامل
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border, color: Color(0xff1a472a)),
            selectedIcon: Icon(Icons.bookmark, color: Color(0xff1a472a)),
            label: 'العلامات',
          ),
          NavigationDestination(
            icon: Icon(Icons.volunteer_activism_outlined, color: Color(0xff1a472a)),
            label: 'الأذكار',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_edu, color: Color(0xff1a472a)),
            label: 'الأحاديث',
          ),
          NavigationDestination(
            icon: Icon(Icons.brightness_auto, color: Color(0xff1a472a)),
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