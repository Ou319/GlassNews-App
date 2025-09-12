import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_flutter_news/constants/app_strings.dart';
import 'package:app_flutter_news/constants/app_sizes.dart';
import 'package:app_flutter_news/compenent/search_news_card.dart';
import 'package:app_flutter_news/controler/search_controller.dart' as search;
import 'package:app_flutter_news/model/news_models.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  late search.SearchController searchController;

  @override
  void initState() {
    super.initState();
    searchController = Get.put(search.SearchController(), permanent: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            
            // News Cards Stack
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
                  
                  if (controller.searchResults.isEmpty) {
                    return Center(
                      child: Text(
                        AppStrings.noSearchResults,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  
                  return RefreshIndicator(
                    onRefresh: () => controller.refreshNews(),
                    color: Colors.white,
                    backgroundColor: Colors.black,
                    child: _buildNewsStack(controller.searchResults),
                  );
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
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: AppSizes.containerS,
              height: AppSizes.containerS,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: AppSizes.iconL,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spacingL),
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
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(AppSizes.searchBarRadius),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
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
              color: Colors.grey[400],
              fontSize: AppSizes.fontSizeL,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey[400],
              size: AppSizes.searchIconSize,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      searchController.clearSearch();
                    },
                    child: Icon(
                      Icons.clear,
                      color: Colors.grey[400],
                      size: AppSizes.searchIconSize,
                    ),
                  )
                : null,
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

  Widget _buildNewsStack(List<Article> articles) {
    if (articles.isEmpty) {
      return const Center(
        child: Text(
          AppStrings.noSearchResults,
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spacingL, // Left padding
        AppSizes.spacingXL, // Top padding
        AppSizes.spacingL, // Right padding
        AppSizes.spacingXL, // Bottom padding
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight;
          final cardHeight = availableHeight * 0.8; // 80% of available height
          
          return Stack(
            children: articles.take(4).toList().asMap().entries.map((entry) {
              final index = entry.key;
              final article = entry.value;
              
              return Positioned(
                top: index * 8.0, // Smaller offset so you can see all cards
                left: 0,
                right: 0,
                child: Transform.scale(
                  scale: index == 0 ? 1.0 : 0.98, // Less scale difference so all cards are visible
                  child: Container(
                    height: cardHeight, // Use calculated height
                    margin: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 2.0,
                    ),
                    child: SearchNewsCard(
                      article: article,
                      cardIndex: index,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}