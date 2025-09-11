import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/news_models.dart';
import 'package:app_flutter_news/const/api.dart';

class NewsApiService {
  static const String _baseUrl = ApiConst.baseUrl;
  String get _apiKey => ApiConst.apiKey;

  Uri _buildTopHeadlinesUri({
    String? country,
    String? category, // business, entertainment, general, health, science, sports, technology
    String? sources,
    String? q,
    int? page,
    int? pageSize,
  }) {
    final Map<String, String> params = {
      if (country != null) 'country': country,
      if (category != null) 'category': category,
      if (sources != null) 'sources': sources,
      if (q != null) 'q': q,
      if (page != null) 'page': '$page',
      if (pageSize != null) 'pageSize': '$pageSize',
    };
    return Uri.parse('$_baseUrl/top-headlines').replace(queryParameters: params);
  }

  Uri _buildEverythingUri({
    required String query,
    String? language,
    String? sortBy,
    int? page,
    int? pageSize,
    DateTime? from,
    DateTime? to,
  }) {
    final Map<String, String> params = {
      'q': query,
      if (language != null) 'language': language,
      if (sortBy != null) 'sortBy': sortBy,
      if (page != null) 'page': '$page',
      if (pageSize != null) 'pageSize': '$pageSize',
      if (from != null) 'from': from.toIso8601String(),
      if (to != null) 'to': to.toIso8601String(),
    };
    return Uri.parse('$_baseUrl/everything').replace(queryParameters: params);
  }

  Future<NewsResponse> fetchEverything({
    required String query,
    String? language,
    String? sortBy,
    int page = 1,
    int pageSize = 20,
    DateTime? from,
    DateTime? to,
  }) async {
    final uri = _buildEverythingUri(
      query: query,
      language: language,
      sortBy: sortBy,
      page: page,
      pageSize: pageSize,
      from: from,
      to: to,
    );
    final res = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'X-Api-Key': _apiKey,
      },
    );
    if (res.statusCode != 200) {
      throw Exception('NewsAPI error ${res.statusCode}: ${res.body}');
    }
    final Map<String, dynamic> jsonMap = json.decode(res.body) as Map<String, dynamic>;
    return NewsResponse.fromJson(jsonMap);
  }

  Future<NewsResponse> fetchTopHeadlines({
    String? country,
    String? category,
    String? sources,
    String? q,
    int page = 1,
    int pageSize = 20,
  }) async {
    final uri = _buildTopHeadlinesUri(
      country: country,
      category: category,
      sources: sources,
      q: q,
      page: page,
      pageSize: pageSize,
    );
    final res = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'X-Api-Key': _apiKey,
      },
    );
    if (res.statusCode != 200) {
      throw Exception('NewsAPI error ${res.statusCode}: ${res.body}');
    }
    final Map<String, dynamic> jsonMap = json.decode(res.body) as Map<String, dynamic>;
    return NewsResponse.fromJson(jsonMap);
  }
}


