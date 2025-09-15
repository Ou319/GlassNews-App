import 'package:get/get.dart';
import 'package:app_flutter_news/data/news_api_service.dart';
import 'package:app_flutter_news/model/news_models.dart';

class CategoryNewsController extends GetxController {
  final NewsApiService _api = NewsApiService();

  final List<String> categories = const [
    'general',
    'business',
    'entertainment',
    'health',
    'science',
    'sports',
    'technology',
  ];

  final RxString selectedCategory = 'general'.obs;
  final RxString country = 'us'.obs;
  final RxBool loading = false.obs;
  final RxString error = ''.obs;
  final RxMap<String, List<Article>> categoryToArticles = <String, List<Article>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchForCategory(selectedCategory.value);
  }

  Future<void> fetchForCategory(String category) async {
    if (loading.value) return;
    selectedCategory.value = category;
    // Use cached if exists
    if (categoryToArticles[category]?.isNotEmpty == true) return;

    loading.value = true;
    error.value = '';
    try {
      final res = await _api.fetchTopHeadlines(
        category: category,
        country: country.value,
        pageSize: 20,
      );
      categoryToArticles[category] = res.articles;
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  void updateCountry(String value) {
    if (country.value == value) return;
    country.value = value;
    categoryToArticles.clear();
    fetchForCategory(selectedCategory.value);
  }
}


