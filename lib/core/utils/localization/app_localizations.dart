import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar'),
  ];
  
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
  
  String get appName => locale.languageCode == 'ar' ? 'نور القرآن' : 'Noor Quran';
  String get quran => locale.languageCode == 'ar' ? 'القرآن' : 'Quran';
  String get hadith => locale.languageCode == 'ar' ? 'الحديث' : 'Hadith';
  String get azkar => locale.languageCode == 'ar' ? 'الأذكار' : 'Azkar';
  String get bookmarks => locale.languageCode == 'ar' ? 'المحفوظات' : 'Bookmarks';
  String get settings => locale.languageCode == 'ar' ? 'الإعدادات' : 'Settings';
  String get search => locale.languageCode == 'ar' ? 'بحث' : 'Search';
  String get khatma => locale.languageCode == 'ar' ? 'ختمة' : 'Khatma';
  String get aiAssistant => locale.languageCode == 'ar' ? 'المساعد الذكي' : 'AI Assistant';
  
  // Add more translations as needed
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}