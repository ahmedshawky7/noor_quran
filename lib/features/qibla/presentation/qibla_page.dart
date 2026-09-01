import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/qalam_header.dart';
import '../../worship/domain/entities/worship_snapshot.dart';
import '../../worship/presentation/widgets/worship_loading_or_error.dart';
import '../../worship/presentation/worship_controller.dart';

class QiblaPage extends StatelessWidget {
  const QiblaPage({super.key, required this.worshipController, this.onExit});

  final WorshipController worshipController;
  final VoidCallback? onExit;

  @override
  Widget build(BuildContext context) {
    return SafeArea(bottom: false, child: Column(children: [
      QalamHeader(
        leading: onExit == null
            ? null
            : IconButton(
                onPressed: onExit,
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.emeraldLight),
                tooltip: 'رجوع',
              ),
        trailing: IconButton(
          onPressed: worshipController.refreshLocation,
          icon: const Icon(Icons.refresh, color: AppColors.emeraldLight),
          tooltip: 'تحديث الموقع',
        ),
      ),
      Expanded(child: AnimatedBuilder(animation: worshipController, builder: (context, _) {
        final snapshot = worshipController.snapshot;
        if (snapshot == null) return WorshipLoadingOrError(controller: worshipController);
        return _QiblaBody(snapshot: snapshot);
      })),
    ]));
  }
}

class _QiblaBody extends StatelessWidget {
  const _QiblaBody({required this.snapshot});
  final WorshipSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, compass) {
        final heading = compass.data?.heading;
        final relativeAngle = heading == null ? snapshot.qiblaBearingDegrees : (snapshot.qiblaBearingDegrees - heading + 360) % 360;
        return Padding(padding: const EdgeInsets.fromLTRB(24, 48, 24, 20), child: Column(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), decoration: BoxDecoration(color: const Color(0xFF0C1413), borderRadius: BorderRadius.circular(25), border: Border.all(color: AppColors.border)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.location_on_outlined, color: AppColors.gold), const SizedBox(width: 8), Text(_coordinates(snapshot), textDirection: TextDirection.ltr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))])),
          const SizedBox(height: 25),
          Text('${snapshot.qiblaBearingDegrees.toStringAsFixed(0)}°', textDirection: TextDirection.ltr, style: const TextStyle(color: AppColors.emeraldLight, fontSize: 34, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('${snapshot.distanceToMakkahKm.toStringAsFixed(0)} كم إلى مكة', textDirection: TextDirection.rtl, style: const TextStyle(color: AppColors.textPrimary, fontSize: 21)),
          const SizedBox(height: 8),
          Text(heading == null ? 'تعذر قراءة مستشعر البوصلة؛ اتبع الاتجاه الرقمي.' : 'وجّه الهاتف حتى تتطابق الإبرة مع العلامة.', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          const Spacer(),
          AspectRatio(aspectRatio: 1, child: CustomPaint(painter: _CompassPainter(angle: relativeAngle))),
          const Spacer(flex: 2),
        ]));
      },
    );
  }
}

class _CompassPainter extends CustomPainter { const _CompassPainter({required this.angle}); final double angle; @override void paint(Canvas canvas, Size size) { final center = Offset(size.width / 2, size.height / 2); final radius = size.shortestSide / 2 - 8; final outer = Paint()..color = AppColors.border..style = PaintingStyle.stroke..strokeWidth = 2; canvas.drawCircle(center, radius, outer); final divisionPaint = Paint()..color = const Color(0xFF293030)..strokeWidth = 1; for (var i = 0; i < 72; i++) { final radians = i * (math.pi * 2 / 72); final major = i % 9 == 0; final start = Offset(center.dx + math.cos(radians) * (radius - (major ? 24 : 10)), center.dy + math.sin(radians) * (radius - (major ? 24 : 10))); final end = Offset(center.dx + math.cos(radians) * radius, center.dy + math.sin(radians) * radius); canvas.drawLine(start, end, divisionPaint); } final needleAngle = (angle - 90) * math.pi / 180; final tip = Offset(center.dx + math.cos(needleAngle) * radius * .66, center.dy + math.sin(needleAngle) * radius * .66); final tail = Offset(center.dx - math.cos(needleAngle) * radius * .38, center.dy - math.sin(needleAngle) * radius * .38); final needle = Paint()..color = AppColors.gold; final tailPaint = Paint()..color = const Color(0xFF30343A); canvas.drawLine(center, tip, needle..strokeWidth = 9..strokeCap = StrokeCap.round); canvas.drawLine(center, tail, tailPaint..strokeWidth = 9..strokeCap = StrokeCap.round); canvas.drawCircle(center, 17, Paint()..color = AppColors.background); canvas.drawCircle(center, 12, Paint()..color = AppColors.gold); canvas.drawCircle(center, 7, Paint()..color = AppColors.background); } @override bool shouldRepaint(covariant _CompassPainter oldDelegate) => oldDelegate.angle != angle; }
String _coordinates(WorshipSnapshot value) => '${value.location.latitude.toStringAsFixed(4)}، ${value.location.longitude.toStringAsFixed(4)}';
