# 📖 نور القران--Noor Quran

تطبيق إسلامي متكامل مبني بـ **Flutter**، يجمع بين المصحف الشريف ومواقيت الصلاة والقبلة والأذكار والتفسير في تجربة عربية سلسة.

**المستودع:** [github.com/ahmedshawky7/noor_quran](https://github.com/ahmedshawky7/noor_quran)

---

## ✨ المميزات

| الميزة | الوصف |
|--------|--------|
| 📕 **المصحف** | عرض صفحات المصحف بخطوط **QCF** عالية الجودة، مع قائمة سور والانتقال السريع |
| 🕌 **مواقيت الصلاة** | حساب أوقات الصلاة حسب الموقع، مع تنبيهات وصوت الأذان |
| 🧭 **القبلة** | بوصلة القبلة باستخدام الجيروسكوب والموقع |
| 📿 **الأذكار** | أذكار الصباح والمساء وغيرها |
| 📚 **التفسير** | تفسير ميسر للآيات (تفسير الميسر) |
| 🏠 **لوحة التحكم** | متابعة آخر قراءة وملخص اليوم |
| ⚙️ **الإعدادات** | تخصيص صوت الأذان، الإشعارات، والمظهر |

---

## 📱 الشاشات الرئيسية

```
┌─────────────┬─────────────┬─────────────┬─────────────┐
│  الرئيسية   │   الصلاة    │   المصحف    │   الأذكار   │
│  Dashboard  │   Prayer    │   Mushaf    │   Adhkar    │
└─────────────┴─────────────┴─────────────┴─────────────┘
         + القبلة (Qibla)  +  الإعدادات (Settings)
```

---

## 🏗️ هيكل المشروع

```
lib/
├── app/
│   ├── app.dart                 # QalamApp + QalamShell
│   └── app_dependencies.dart    # Dependency setup
│
├── core/
│   ├── theme/                   # الثيم (Dark theme)
│   └── widgets/                 # Bottom Navigation وغيرها
│
├── features/
│   ├── dashboard/               # لوحة التحكم
│   ├── mushaf/                  # المصحف (Clean Architecture)
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── prayer/                  # مواقيت الصلاة
│   ├── qibla/                   # القبلة
│   ├── adhkar/                  # الأذكار
│   ├── tafsir/                  # التفسير
│   ├── worship/                 # منطق العبادة المشترك
│   └── settings/                # الإعدادات
│
└── main.dart
```

بعض الـ Features (مثل **mushaf**) مبنية بهندسة **Clean Architecture** (Domain / Data / Presentation).

---

## 🛠️ التقنيات المستخدمة

| الحزمة | الاستخدام |
|--------|-----------|
| [qcf_quran_plus](https://pub.dev/packages/qcf_quran_plus) | عرض المصحف بخطوط مجمع الملك فهد (QCF) |
| just_audio | تشغيل صوت الأذان |
| adhan_dart | حساب مواقيت الصلاة |
| geolocator | تحديد الموقع |
| flutter_compass | بوصلة القبلة |
| hijri | التقويم الهجري |
| shared_preferences | حفظ الإعدادات وآخر صفحة |
| share_plus | مشاركة المحتوى |
| path_provider | مسارات الملفات المحلية |

---

## 📦 التثبيت والتشغيل

### المتطلبات
- Flutter SDK **3.13+**
- Dart **3.2+**

### الخطوات

```bash
# 1. استنساخ المشروع
git clone https://github.com/ahmedshawky7/noor_quran.git
cd noor_quran

# 2. تثبيت الحزم
flutter pub get

# 3. تشغيل التطبيق
flutter run
```

### الأصول (Assets)

```yaml
# في pubspec.yaml
flutter:
  assets:
    - assets/audio/adhan/
    - assets/tafsir/tafsir_muyassar_source.json
```

---

## 🚀 نقطة الدخول

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تحميل خطوط QCF مبكراً لتجنب التأخير عند فتح المصحف
  await QcfFontLoader.setupFontsAtStartup(onProgress: (_) {});

  final dependencies = await AppDependencies.create();
  runApp(QalamApp(dependencies: dependencies));
}
```

---

## 📁 أهم الملفات

| الملف | الوصف |
|-------|--------|
| `lib/app/app.dart` | الواجهة الرئيسية والتنقل بين التبويبات |
| `lib/app/app_dependencies.dart` | تهيئة الـ Controllers والـ Repositories |
| `lib/features/mushaf/` | منطق وعرض المصحف |
| `lib/features/prayer/` | مواقيت الصلاة |
| `lib/features/qibla/` | بوصلة القبلة |
| `lib/features/tafsir/` | التفسير الميسر |
| `assets/audio/adhan/` | ملفات صوت الأذان |
| `assets/tafsir/` | ملف التفسير JSON |

---

## 🔐 الصلاحيات المطلوبة

| الصلاحية | السبب |
|----------|--------|
| **الموقع (Location)** | حساب مواقيت الصلاة واتجاه القبلة |
| **الإشعارات** | تنبيهات أوقات الصلاة |
| **التخزين** | حفظ الإعدادات وآخر قراءة |

---

## 🤝 المساهمة

مرحب بأي مساهمة لتحسين التطبيق:

1. Fork المستودع
2. أنشئ Branch جديد  
   `git checkout -b feature/your-feature`
3. Commit التغييرات  
   `git commit -m "Add: your feature"`
4. Push  
   `git push origin feature/your-feature`
5. افتح **Pull Request**

---

## 📄 الترخيص

هذا المشروع مفتوح المصدر. يمكنك استخدامه وتعديله بحرية.

---

<div align="center">

**جعل الله هذا العمل في ميزان حسناتكم**

<sub>Built with ❤️ using Flutter</sub>

<br>

[![GitHub](https://img.shields.io/badge/GitHub-ahmedshawky7%2Fnoor__quran-blue?logo=github)](https://github.com/ahmedshawky7/noor_quran)

</div>
