import 'package:flutter/material.dart';
import 'package:app_flutter_news/constants/app_strings.dart';
import 'package:app_flutter_news/constants/app_sizes.dart';
import 'package:app_flutter_news/model/news_models.dart';

class SearchNewsCard extends StatelessWidget {
  final Article article;
  final int cardIndex;

  const SearchNewsCard({
    super.key,
    required this.article,
    required this.cardIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: _getCardColor(cardIndex),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Expanded(
              flex: 2,
              child: Text(
                article.title ?? AppStrings.untitledArticle,
                style: const TextStyle(
                  fontSize: AppSizes.fontSizeXL,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: AppSizes.spacingM),
            
            // Description
            Expanded(
              flex: 3,
              child: Text(
                article.description ?? AppStrings.noDescription,
                style: const TextStyle(
                  fontSize: AppSizes.fontSizeM,
                  color: Colors.black87,
                  height: 1.4,
                ),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCardColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFFF3CD); // Light yellow
      case 1:
        return const Color(0xFFFFE4E1); // Light pink
      case 2:
        return const Color(0xFFE6F3FF); // Light blue
      case 3:
        return const Color(0xFFF0E6FF); // Light purple
      default:
        return const Color(0xFFFFF3CD); // Default light yellow
    }
  }
}