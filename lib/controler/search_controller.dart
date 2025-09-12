import 'package:get/get.dart';
import 'package:app_flutter_news/data/news_api_service.dart';
import 'package:app_flutter_news/model/news_models.dart';

class SearchController extends GetxController {
  final NewsApiService _api = NewsApiService();

  final RxBool loading = false.obs;
  final RxString error = ''.obs;
  final RxList<Article> searchResults = <Article>[].obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Load some initial news for display
    fetchInitialNews();
  }

  Future<void> fetchInitialNews() async {
    loading.value = true;
    error.value = '';
    try {
      // Create sample articles that match the image design
      final sampleArticles = [
        Article(
          title: "Demand for Indian generic drugs...",
          description: "The demand for Indian generic drugs has shot up in China amid the massive...",
          urlToImage: null,
          publishedAt: DateTime.now(),
          source: ArticleSource(id: "sample", name: "Sample News"),
          author: "Sample Author",
          url: "https://example.com",
          content: "Sample content",
        ),
        Article(
          title: "Novak Djokovic, Nick Kyrgios To Play...",
          description: "Tennis stars Novak Djokovic and Nick Kyrgios are set to play an exhibition match...",
          urlToImage: null,
          publishedAt: DateTime.now(),
          source: ArticleSource(id: "sample", name: "Sample News"),
          author: "Sample Author",
          url: "https://example.com",
          content: "Sample content",
        ),
        Article(
          title: "Apple Hiring Workers for Retail Stores Across...",
          description: "Apple is expanding its retail presence by hiring workers across multiple locations...",
          urlToImage: null,
          publishedAt: DateTime.now(),
          source: ArticleSource(id: "sample", name: "Sample News"),
          author: "Sample Author",
          url: "https://example.com",
          content: "Sample content",
        ),
        Article(
          title: "Facebook owner Meta remove",
          description: "Meta, the parent company of Facebook, has announced the removal of...",
          urlToImage: null,
          publishedAt: DateTime.now(),
          source: ArticleSource(id: "sample", name: "Sample News"),
          author: "Sample Author",
          url: "https://example.com",
          content: "Sample content",
        ),
      ];
      
      searchResults.value = sampleArticles;
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  Future<void> searchNews(String query) async {
    if (query.trim().isEmpty) {
      fetchInitialNews();
      return;
    }

    loading.value = true;
    error.value = '';
    searchQuery.value = query;
    
    try {
      final res = await _api.fetchEverything(
        query: query,
        language: 'en',
        sortBy: 'publishedAt',
        pageSize: 4, // Exactly 4 cards like in the image
      );
      searchResults.value = res.articles.take(4).toList();
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  void clearSearch() {
    searchQuery.value = '';
    searchResults.clear();
    fetchInitialNews();
  }

  Future<void> refreshNews() async {
    await fetchInitialNews();
  }
}
