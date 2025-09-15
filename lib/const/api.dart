import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConst {
  static String get baseUrl => dotenv.env['NEWSAPI_BASE_URL'] ?? 'https://newsapi.org/v2';
  static String get apiKey => dotenv.env['NEWSAPI_KEY'] ?? '';
}


