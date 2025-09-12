import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_flutter_news/controler/news_controller.dart';
import 'package:app_flutter_news/controler/category_news_controller.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:app_flutter_news/compenent/news_card.dart';
import 'package:app_flutter_news/compenent/modern_loading.dart';
import 'package:app_flutter_news/constants/app_strings.dart';
import 'package:app_flutter_news/constants/app_sizes.dart';
import 'package:app_flutter_news/view/setting/setting_page.dart';
import 'package:page_transition/page_transition.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final NewsController ctrl;
  late final CategoryNewsController categories;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  String? _animatingCategory;

  @override
  void initState() {
    super.initState();
    ctrl = Get.put(NewsController(), permanent: true);
    categories = Get.put(CategoryNewsController(), permanent: true);
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: AppSizes.animationMedium),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Start from right
      end: Offset.zero, // End at normal position
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOutCubic,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _onCategorySelected(String category) {
    if (categories.selectedCategory.value == category) return;
    
    setState(() {
      _animatingCategory = category;
    });
    
    _slideController.forward().then((_) {
      categories.fetchForCategory(category);
      _slideController.reset();
      setState(() {
        _animatingCategory = null;
      });
    });
  }

  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: AppSizes.settingsPageTransition),
        reverseDuration: const Duration(milliseconds: AppSizes.settingsPageReverse),
        child: const SettingPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact header
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.spacingXL, AppSizes.spacingS, AppSizes.spacingXL, AppSizes.spacingS),
              child: Row(
        children: [
                  // Logo with Z
                  Container(
                    width: AppSizes.containerXS,
                    height: AppSizes.containerXS,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        AppStrings.appLogo,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: AppSizes.fontSizeL,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingS),
                  const Text(
                    AppStrings.appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppSizes.fontSizeXXL,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // Menu button
                  GestureDetector(
                    onTap: () => _openSettings(context),
                    child: Container(
                      width: AppSizes.containerXS,
                      height: AppSizes.containerXS,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.apps,
                        color: Colors.white,
                        size: AppSizes.fontSizeL,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.spacingL),

            // Compact categories
            SizedBox(
              height: AppSizes.headerHeight,
              child: Obx(() {
                final selected = categories.selectedCategory.value;
                final categoryList = List<String>.from(categories.categories);
                
                // Reorder categories to put selected first
                if (categoryList.contains(selected) && categoryList.first != selected) {
                  categoryList.remove(selected);
                  categoryList.insert(0, selected);
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingXL),
                  scrollDirection: Axis.horizontal,
                  itemCount: categoryList.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppSizes.spacingXXL),
                  itemBuilder: (context, index) {
                    final cat = categoryList[index];
                    final display = _getCategoryDisplayName(cat);
                    final bool isSelected = selected == cat;

                    return GestureDetector(
                      onTap: () => _onCategorySelected(cat),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: AppSizes.animationFast),
                        curve: Curves.easeOutCubic,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[500],
                          fontSize: isSelected ? AppSizes.fontSizeL : AppSizes.fontSizeM,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        child: Text(display),
                      ),
                    );
                  },
                );
              }),
            ),

            const SizedBox(height: AppSizes.spacingS),

            // Content area
          Expanded(
            child: GetX<CategoryNewsController>(
              init: categories,
              builder: (c) {
              final selected = c.selectedCategory.value;
              final list = c.categoryToArticles[selected] ?? const [];
                  
              if (c.loading.value && list.isEmpty) {
                return ModernLoading(
                      message: AppStrings.loadingCategoryNews.replaceAll('{category}', selected),
                      color: Colors.white,
                );
              }
                  
              if (c.error.isNotEmpty) {
                    return Center(
                      child: Text(
                        '${AppStrings.errorPrefix}${c.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  
              if (list.isEmpty) {
                if (ctrl.loading.value) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(AppSizes.spacingL, 0, AppSizes.spacingL, AppSizes.spacingXL),
                      child: CardSwiper(
                      cardsCount: 3,
                      isLoop: false,
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingXS, vertical: AppSizes.spacingS),
                      cardBuilder: (context, index, __, ___) => const NewsSkeletonCard(),
                    ),
                  );
                }
                    
                    if (ctrl.error.isNotEmpty) {
                      return Center(
                        child: Text(
                          '${AppStrings.errorPrefix}${ctrl.error}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    
                final a = ctrl.article.value;
                    if (a == null) {
                      return const Center(
                        child: Text(
                          AppStrings.noArticlesAvailable,
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(AppSizes.spacingL, 0, AppSizes.spacingL, AppSizes.spacingXL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.title ?? AppStrings.untitledArticle,
                            style: const TextStyle(
                              fontSize: AppSizes.fontSizeXXL,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: AppSizes.spacingS),
                          Text(
                            a.description ?? AppStrings.noDescription,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: AppSizes.spacingM),
                          if (a.urlToImage != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppSizes.radiusM),
                              child: Image.network(
                                a.urlToImage!,
                                height: AppSizes.imageHeightM,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) => Container(
                                  height: AppSizes.imageHeightM,
                                  width: double.infinity,
                                  color: Colors.grey[800],
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
              }
                  
              final items = list.isNotEmpty
                  ? list
                  : (ctrl.article.value != null ? [ctrl.article.value!] : const <dynamic>[]);
                  
                  if (items.isEmpty) {
                    return const Center(
                      child: Text(
                        AppStrings.noArticlesAvailable,
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(13, 0, 13, AppSizes.spacingXL),
                child: CardSwiper(
                  cardsCount: items.length,
                  isLoop: true,
                      padding: EdgeInsets.zero,
                      cardBuilder: (context, index, __, ___) => SizedBox.expand(
                        child: NewsCard(
                    article: items[index],
                    cardIndex: index,
                    category: selected,
                        ),
                  ),
                ),
              );
                },
              ),
          ),
        ],
        ),
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category.toLowerCase()) {
      case 'general':
        return AppStrings.trendingCategory;
      case 'health':
        return AppStrings.healthCategory;
      case 'sports':
        return AppStrings.sportsCategory;
      case 'business':
        return AppStrings.financeCategory;
      case 'technology':
        return AppStrings.techCategory;
      case 'entertainment':
        return AppStrings.entertainmentCategory;
      case 'science':
        return AppStrings.scienceCategory;
      default:
        return category[0].toUpperCase() + category.substring(1);
    }
  }
}