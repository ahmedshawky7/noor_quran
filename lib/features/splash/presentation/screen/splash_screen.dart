import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/di/injection.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // ١. شيل الـ native splash فوراً
    FlutterNativeSplash.remove();

    // ٢. initialize في background والـ splash بيظهر
    await getIt<AppConfig>().initialize();

    // ٣. شغل الـ sync بعد ما الـ DB يكون جاهز
    getIt<AppConfig>().startSync();

    // ٤. استنى minimum وقت
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xfff8f3e8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_rounded, size: 90, color: Color(0xff1a472a)),
            SizedBox(height: 25),
            Text(
              "نور القرآن",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: "Amiri",
                color: Color(0xff1a472a),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "القرآن الكريم والأذكار",
              style: TextStyle(color: Colors.black54, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}