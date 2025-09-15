import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_flutter_news/constants/app_strings.dart';
import 'package:app_flutter_news/constants/app_sizes.dart';
import 'package:app_flutter_news/controler/save_controller.dart';
import 'package:app_flutter_news/model/news_models.dart';
import 'package:lottie/lottie.dart';

class SavePage extends StatefulWidget {
  const SavePage({super.key});

  @override
  State<SavePage> createState() => _SavePageState();
}

class _SavePageState extends State<SavePage> {
  late SaveController saveController;

  @override
  void initState() {
    super.initState();
    saveController = Get.put(SaveController(), permanent: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: Obx(() {
                final items = saveController.savedArticles;
                if (items.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacingXL,
                    vertical: AppSizes.spacingL,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSizes.spacingL),
                  itemBuilder: (context, index) {
                    final article = items[index];
                    return _SavedArticleTile(
                      article: article,
                      onToggleSave: () => saveController.toggleSave(article),
                    );
                  },
                );
              }),
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
        children: const [
          Text(
            'Saved News',
            style: TextStyle(
              color: Colors.white,
              fontSize: AppSizes.fontSizeXXXL,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            height: 190,
            child: LottieBuilder.network(
              'https://lottie.host/1df1758f-6249-4794-91ec-acea6c145961/uviavZL1mN.json',
              repeat: true,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.bookmark_border,
                size: 80,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacingXL),
          Text(
            'No saved news yet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          Text(
            'Tap the bookmark on any article to save it',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedArticleTile extends StatelessWidget {
  const _SavedArticleTile({required this.article, required this.onToggleSave});

  final Article article;
  final VoidCallback onToggleSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          onTap: () => _showDetails(context, article),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacingL),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildThumbnail(),
                const SizedBox(width: AppSizes.spacingL),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title ?? AppStrings.untitledArticle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: AppSizes.fontSizeL,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSizes.spacingS),
                      Text(
                        article.description ?? AppStrings.noDescription,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: AppSizes.fontSizeM,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSizes.spacingS),
                      Row(
                        children: [
                          if (article.source?.name != null)
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
                                ),
                                child: Text(
                                  article.source!.name!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500, height: 1.4, letterSpacing: 0.3),
                                ),
                              ),
                            ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.spacingL),
                IconButton(
                  onPressed: onToggleSave,
                  icon: const Icon(Icons.bookmark, color: Colors.white),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (article.urlToImage == null) {
      return _placeholderThumb();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      child: Image.network(
        article.urlToImage!,
        width: 96,
        height: 96,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholderThumb(),
      ),
    );
  }

  Widget _placeholderThumb() {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.6),
            Colors.purple.withOpacity(0.6),
          ],
        ),
      ),
      child: const Icon(Icons.image, color: Colors.white70),
    );
  }

  void _showDetails(BuildContext context, Article article) {
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
                    if (article.urlToImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          article.urlToImage!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      article.title ?? 'No Title',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (article.source?.name != null)
                      Text(
                        article.source!.name!,
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      article.description ?? 'No description available',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        height: 1.5,
                      ),
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
}
