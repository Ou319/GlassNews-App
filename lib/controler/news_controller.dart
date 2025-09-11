import 'dart:math';
import 'package:get/get.dart';
import 'package:app_flutter_news/data/news_api_service.dart';
import 'package:app_flutter_news/model/news_models.dart';

class NewsController extends GetxController {
  final NewsApiService _api = NewsApiService();

  final RxBool loading = false.obs;
  final Rxn<Article> article = Rxn<Article>();
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRandomBitcoin();
  }

  Future<void> fetchRandomBitcoin() async {
    loading.value = true;
    error.value = '';
    article.value = null;
    try {
      final res = await _api.fetchEverything(query: 'bitcoin', sortBy: 'publishedAt', pageSize: 20, language: 'en');
      if (res.articles.isEmpty) {
        error.value = 'No articles';
      } else {
        final a = res.articles[Random().nextInt(res.articles.length)];
        article.value = a;
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }
}


