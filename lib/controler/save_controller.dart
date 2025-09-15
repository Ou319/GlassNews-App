import 'package:get/get.dart';
import 'package:app_flutter_news/model/news_models.dart';
import 'package:app_flutter_news/servise/save_service.dart';

class SaveController extends GetxController {
  final SaveService _service = SaveService();

  final RxList<Article> savedArticles = <Article>[].obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    savedArticles.value = await _service.getSavedArticles();
  }

  Future<void> toggleSave(Article article) async {
    final isAlreadySaved = savedArticles.any((a) => a.url == article.url && a.title == article.title);
    if (isAlreadySaved) {
      await _service.removeArticle(article);
    } else {
      await _service.saveArticle(article);
    }
    await _load();
  }

  bool isSavedSync(Article article) {
    return savedArticles.any((a) => a.url == article.url && a.title == article.title);
  }
}


