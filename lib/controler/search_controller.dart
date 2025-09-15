import 'package:get/get.dart';
import 'package:app_flutter_news/data/news_api_service.dart';
import 'package:app_flutter_news/model/news_models.dart';

class SearchController extends GetxController {
  final NewsApiService _api = NewsApiService();

  final RxBool loading = false.obs;
  final RxString error = ''.obs;
  final RxList<Article> searchResults = <Article>[].obs;
  final RxString searchQuery = ''.obs;
  final RxInt currentArticleIndex = 0.obs;
  // Filters
  final RxString language = 'en'.obs; // for /everything
  final RxString country = 'us'.obs; // for /top-headlines
  final RxString sortBy = 'publishedAt'.obs; // publishedAt | relevancy | popularity

  @override
  void onInit() {
    super.onInit();
    // Load initial news so the Search page isn't empty
    fetchInitialNews();
  }

  Future<void> fetchInitialNews() async {
    loading.value = true;
    error.value = '';
    try {
      // Fetch trending news from API
      final res = await _api.fetchTopHeadlines(
        country: country.value,
        pageSize: 10,
      );
      
      // Use articles directly
      searchResults.value = res.articles;
    } catch (e) {
      // Fallback to sample data if API fails
      final sampleArticles = [
        Article(
          title: "Demand for Indian generic drugs...",
          description: "The demand for Indian generic drugs has shot up in China amid the massive...",
          urlToImage: "https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400",
          publishedAt: DateTime.now(),
          source: ArticleSource(id: "sample", name: "Sample News"),
          author: "Sample Author",
          url: "https://example.com",
          content: "Sample content",
        ),
        Article(
          title: "Novak Djokovic, Nick Kyrgios To Play...",
          description: "Tennis stars Novak Djokovic and Nick Kyrgios are set to play an exhibition match...",
          urlToImage: "https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=400",
          publishedAt: DateTime.now(),
          source: ArticleSource(id: "sample", name: "Sample News"),
          author: "Sample Author",
          url: "https://example.com",
          content: "Sample content",
        ),
        Article(
          title: "Apple Hiring Workers for Retail Stores Across...",
          description: "Apple is expanding its retail presence by hiring workers across multiple locations...",
          urlToImage: "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400",
          publishedAt: DateTime.now(),
          source: ArticleSource(id: "sample", name: "Sample News"),
          author: "Sample Author",
          url: "https://example.com",
          content: "Sample content",
        ),
        Article(
          title: "Facebook owner Meta remove",
          description: "Meta, the parent company of Facebook, has announced the removal of...",
          urlToImage: "https://images.unsplash.com/photo-1611224923853-80b023f02d71?w=400",
          publishedAt: DateTime.now(),
          source: ArticleSource(id: "sample", name: "Sample News"),
          author: "Sample Author",
          url: "https://example.com",
          content: "Sample content",
        ),
      ];
      
      searchResults.value = sampleArticles;
    } finally {
      loading.value = false;
    }
  }

  Future<void> searchNews(String query) async {
    if (query.trim().isEmpty) {
      searchQuery.value = '';
      searchResults.clear();
      return;
    }

    loading.value = true;
    error.value = '';
    searchQuery.value = query;
    currentArticleIndex.value = 0; // Reset to first article
    
    try {
      final res = await _api.fetchEverything(
        query: query,
        language: language.value,
        sortBy: sortBy.value,
        pageSize: 10, // More articles for better scrolling experience
      );
      
      // Use articles directly
      searchResults.value = res.articles;
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  void updateLanguage(String value) { language.value = value; }
  void updateCountry(String value) { country.value = value; }
  void updateSortBy(String value) { sortBy.value = value; }

  void clearSearch() {
    searchQuery.value = '';
    searchResults.clear();
  }

  Future<void> refreshNews() async {
    await fetchInitialNews();
  }

  void nextArticle() {
    if (currentArticleIndex.value < searchResults.length - 1) {
      currentArticleIndex.value++;
    }
  }

  void previousArticle() {
    if (currentArticleIndex.value > 0) {
      currentArticleIndex.value--;
    }
  }

  void goToArticle(int index) {
    if (index >= 0 && index < searchResults.length) {
      currentArticleIndex.value = index;
    }
  }
}
