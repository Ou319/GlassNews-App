import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_flutter_news/constants/app_strings.dart';
import 'package:app_flutter_news/constants/app_sizes.dart';
import 'package:app_flutter_news/compenent/news_card.dart';
import 'package:app_flutter_news/controler/search_controller.dart' as search;
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:lottie/lottie.dart';
import 'package:app_flutter_news/compenent/news_filter_button.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  late search.SearchController searchController;
  final CardSwiperController _swiperController = CardSwiperController();

  @override
  void initState() {
    super.initState();
    searchController = Get.put(search.SearchController(), permanent: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _swiperController.dispose();
    super.dispose();
  }

  Widget _buildDropdown({required String label, required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            dropdownColor: const Color(0xFF1E1E1E),
            underline: const SizedBox.shrink(),
            iconEnabledColor: Colors.white,
            style: const TextStyle(color: Colors.white),
            items: items
                .map((e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(e.toUpperCase()),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Search Bar
            _buildSearchBar(),
            
            // Reels
            Expanded(
              child: GetX<search.SearchController>(
                builder: (controller) {
                  if (controller.loading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    );
                  }
                  
                  if (controller.error.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${AppStrings.errorPrefix}${controller.error}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: AppSizes.spacingL),
                          ElevatedButton(
                            onPressed: () => controller.refreshNews(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  // Show search prompt if no search has been performed
                  if (controller.searchQuery.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 190,
                            child: LottieBuilder.network(
                              'https://lottie.host/d1fd23f8-662d-42e0-a4e3-6c9c7829f6f2/iCwMxOEwBE.json',
                              repeat: true,
                              frameRate: FrameRate.max,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.search,
                            size: 80,
                            color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSizes.spacingXL),
                          Text(
                            'Search for news articles',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: AppSizes.spacingM),
                          Text(
                            'Type something to get started',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  if (controller.searchResults.isEmpty) {
                    return Center(
                      child: Text(
                        AppStrings.noSearchResults,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  
                  return _buildReelsView(controller);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spacingXL),
      child: Row(
        children: [
          Text(
            AppStrings.searchTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: AppSizes.fontSizeXXXL,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingXL),
      child: Container(
        height: AppSizes.searchBarHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(AppSizes.searchBarRadius),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          onChanged: (value) {
            // Search as user types with faster debounce for better responsiveness
            Future.delayed(const Duration(milliseconds: 300), () {
              if (_searchController.text == value) {
                searchController.searchNews(value);
              }
            });
          },
          decoration: InputDecoration(
            hintText: AppStrings.searchPlaceholder,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: AppSizes.fontSizeL,
            ),
            prefixIcon: SizedBox(
              width: AppSizes.searchIconSize,
              height: AppSizes.searchIconSize,
              child: Center(
                child: LottieBuilder.network(
                  'https://lottie.host/d1fd23f8-662d-42e0-a4e3-6c9c7829f6f2/iCwMxOEwBE.json',
                  repeat: true,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
              Icons.search,
              color: Colors.white.withOpacity(0.7),
              size: AppSizes.searchIconSize,
            ),
                ),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Filter button on the right inside input
                NewsFilterButton(
                  builder: (ctx) {
                    return GetX<search.SearchController>(
                      builder: (c) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDropdown(
                            label: 'Language',
                            value: c.language.value,
                            items: const ['en','ar','fr','es','de','it','ru','zh'],
                            onChanged: (v) { if (v!=null) c.updateLanguage(v); },
                          ),
                          const SizedBox(height: 12),
                          _buildDropdown(
                            label: 'Country',
                            value: c.country.value,
                            items: const ['us','gb','fr','de','in','ca','au','jp'],
                            onChanged: (v) { if (v!=null) c.updateCountry(v); },
                          ),
                          const SizedBox(height: 12),
                          _buildDropdown(
                            label: 'Sort by',
                            value: c.sortBy.value,
                            items: const ['publishedAt','relevancy','popularity'],
                            onChanged: (v) { if (v!=null) c.updateSortBy(v); },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_searchController.text.trim().isNotEmpty) {
                                      c.searchNews(_searchController.text.trim());
                                    } else {
                                      // Apply country to top headlines
                                      c.fetchInitialNews();
                                    }
                                    Navigator.of(ctx).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(0.18),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Apply'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton(
                                onPressed: () {
                                  c.updateLanguage('en');
                                  c.updateCountry('us');
                                  c.updateSortBy('publishedAt');
                                  Navigator.of(ctx).pop();
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Reset'),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      searchController.clearSearch();
                    },
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                      Icons.clear,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacingL,
              vertical: AppSizes.spacingM,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReelsView(search.SearchController controller) {
    return CardSwiper(
      controller: _swiperController,
      cardsCount: controller.searchResults.length,
      onSwipe: (previousIndex, currentIndex, direction) {
        if (currentIndex != null) {
          controller.goToArticle(currentIndex);
        }
        return true;
      },
      cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
        final article = controller.searchResults[index];
        return _buildOptimizedNewsCard(article, index);
      },
      isLoop: false,
      allowedSwipeDirection: const AllowedSwipeDirection.only(
        up: true,
        down: true,
        left: true,
        right: true,
      ),
      threshold: 50,
      backCardOffset: const Offset(0, 0),
      scale: 1.0,
    );
  }

  Widget _buildOptimizedNewsCard(article, int index) {
    return GestureDetector(
      onTap: () {
        _showCardDetails(article);
      },
      child: NewsCard(
        article: article,
        cardIndex: index,
        ),
      );
    }

  void _showCardDetails(article) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Article image
                    if (article.urlToImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          article.urlToImage!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.blue.withOpacity(0.8), Colors.purple.withOpacity(0.8)],
                                ),
                              ),
                              child: const Center(
                                child: Icon(Icons.image_not_supported, color: Colors.white, size: 50),
                              ),
                            );
                          },
                        ),
                      ),
                    
                    const SizedBox(height: 20),
                    
                    // Title
                    Text(
                      article.title ?? 'No Title',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Source and time
                    Row(
                      children: [
                        if (article.source?.name != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              article.source!.name!,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Text(
                          _formatTime(article.publishedAt),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Description
                    Text(
                      article.description ?? 'No description available',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Action buttons
                    Row(
                      children: [
                        _buildDetailActionButton(Icons.favorite_border, 'Like'),
                        const SizedBox(width: 20),
                        _buildDetailActionButton(Icons.bookmark_border, 'Save'),
                        const SizedBox(width: 20),
                        _buildDetailActionButton(Icons.share_outlined, 'Share'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailActionButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown time';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}