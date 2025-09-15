import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_flutter_news/model/news_models.dart';

class SaveService {
  static const String _keySavedArticles = 'saved_articles_v1';

  Future<List<Article>> getSavedArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> rawList = prefs.getStringList(_keySavedArticles) ?? <String>[];
    return rawList
        .map((raw) => json.decode(raw) as Map<String, dynamic>)
        .map((map) => Article.fromJson(map))
        .toList();
  }

  Future<void> saveArticle(Article article) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Article> current = await getSavedArticles();

    final bool alreadySaved = current.any((a) => a.url == article.url && a.title == article.title);
    if (alreadySaved) return;

    current.insert(0, article);
    final serialized = current.map((a) => json.encode(a.toJson())).toList();
    await prefs.setStringList(_keySavedArticles, serialized);
  }

  Future<void> removeArticle(Article article) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Article> current = await getSavedArticles();
    current.removeWhere((a) => a.url == article.url && a.title == article.title);
    final serialized = current.map((a) => json.encode(a.toJson())).toList();
    await prefs.setStringList(_keySavedArticles, serialized);
  }

  Future<bool> isSaved(Article article) async {
    final List<Article> current = await getSavedArticles();
    return current.any((a) => a.url == article.url && a.title == article.title);
  }
}


