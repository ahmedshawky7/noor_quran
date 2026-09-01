import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_surface.dart';
import '../worship_controller.dart';

class WorshipLoadingOrError extends StatelessWidget {
  const WorshipLoadingOrError({super.key, required this.controller});

  final WorshipController controller;

  @override
  Widget build(BuildContext context) {
    final isLoading = controller.isLoading;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AppSurface(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (isLoading)
              const CircularProgressIndicator(color: AppColors.emeraldLight)
            else
              const Icon(Icons.location_off_outlined, color: AppColors.gold, size: 38),
            const SizedBox(height: 18),
            Text(
              isLoading ? 'يجري حساب المواقيت والقبلة من موقع الجهاز…' : 'نحتاج إلى موقعك لحساب البيانات الحقيقية',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 9),
            Text(
              isLoading ? 'يتم كل الحساب على جهازك.' : (controller.errorMessage ?? ''),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, height: 1.5),
            ),
            if (!isLoading) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: controller.refreshLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('تفعيل الموقع'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.emerald, foregroundColor: AppColors.background),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}
