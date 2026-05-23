import 'package:dio/dio.dart';

class QuranApiService {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> fetchQuran() async {
    final response = await _dio.get(
      'https://api.alquran.cloud/v1/quran/quran-uthmani',
    );

    return response.data;
  }
}