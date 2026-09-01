import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class QalamHeader extends StatelessWidget {
  const QalamHeader({super.key, this.trailing, this.leading, this.onSettingsPressed});

  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          leading ??
              (onSettingsPressed == null
                  ? const Icon(Icons.settings_outlined, color: Color(0xFFD7D9EA), size: 29)
                  : IconButton(
                      onPressed: onSettingsPressed,
                      icon: const Icon(Icons.settings_outlined, color: Color(0xFFD7D9EA), size: 29),
                      tooltip: 'الإعدادات',
                    )),
          const Spacer(),
          const Text(
            'نور القران',
            style: TextStyle(
              color: AppColors.emerald,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          trailing ??
              const CircleAvatar(
                radius: 21,
                backgroundColor: AppColors.surfaceRaised,
                child: Icon(Icons.person_outline, color: Color(0xFFD7D9EA)),
              ),
        ],
      ),
    );
  }
}
