import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/adhan_audio_settings.dart';

class SharedPreferencesAdhanAudioRepository {
  const SharedPreferencesAdhanAudioRepository(this._preferences);

  final SharedPreferences _preferences;

  AdhanAudioSettings load() => AdhanAudioSettings(
              fajr: _read('fajr'),
      sunrise: _read('sunrise'),
      dhuhr: _read('dhuhr'),

        asr: _read('asr'),
        maghrib: _read('maghrib'),
        isha: _read('isha'),
      );

  Future<void> save(AdhanAudioSettings settings) async {
    await Future.wait([
      _preferences.setString('adhan_voice_fajr', settings.fajr),
      _preferences.setString('adhan_voice_sunrise', settings.sunrise),
      _preferences.setString('adhan_voice_dhuhr', settings.dhuhr),
      _preferences.setString('adhan_voice_asr', settings.asr),
      _preferences.setString('adhan_voice_maghrib', settings.maghrib),
      _preferences.setString('adhan_voice_isha', settings.isha),
    ]);
  }

  String _read(String prayer) => _preferences.getString('adhan_voice_$prayer') ?? 'ali_mulla';

  Future<File?> localFile(String voiceId) async {
    final root = await _cacheRoot();
    final file = File('${root.path}/$voiceId.mp3');
    return await file.exists() ? file : null;
  }

  Future<File> downloadVoice(AdhanVoice voice) async {
    final root = await _cacheRoot();
    final response = await http.get(Uri.parse(voice.previewUrl));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('تعذر تنزيل صوت الأذان (${response.statusCode})');
    }
    final file = File('${root.path}/${voice.id}.mp3');
    await file.writeAsBytes(response.bodyBytes, flush: true);
    return file;
  }

  Future<Directory> _cacheRoot() async {
    final supportDirectory = await getApplicationSupportDirectory();
    final directory = Directory('${supportDirectory.path}/adhan_audio_cache');
    if (!await directory.exists()) await directory.create(recursive: true);
    return directory;
  }
}
