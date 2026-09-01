import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class QalamBottomNavigation extends StatelessWidget {
  const QalamBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  static const _items = <_QalamNavigationItem>[
    _QalamNavigationItem('الرئيسية', Icons.home_outlined),
    _QalamNavigationItem('الصلاة', Icons.access_time_outlined),
    _QalamNavigationItem('القرآن', Icons.menu_book_outlined),
    _QalamNavigationItem('الأذكار', Icons.auto_awesome_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: const BoxDecoration(
          color: Color(0xEE101514),
          border: Border(top: BorderSide(color: AppColors.border)),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Row(
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final selected = index == currentIndex;
            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF0B493E) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.icon, color: selected ? AppColors.emeraldLight : AppColors.textMuted),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: selected ? AppColors.emeraldLight : AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _QalamNavigationItem {
  const _QalamNavigationItem(this.label, this.icon);

  final String label;
  final IconData icon;
}
