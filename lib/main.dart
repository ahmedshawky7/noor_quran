import 'package:flutter/widgets.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

import 'app/app.dart';
import 'app/app_dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // يحمّل خطوط QCF مبكراً حتى لا تتأخر أول صفحة من المصحف.
  await QcfFontLoader.setupFontsAtStartup(
    onProgress: (_) {},
  );

  final dependencies = await AppDependencies.create();
  runApp(QalamApp(dependencies: dependencies));
}
