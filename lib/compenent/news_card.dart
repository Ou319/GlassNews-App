import 'package:flutter/material.dart';
import 'package:app_flutter_news/model/news_models.dart';
import 'package:app_flutter_news/constants/app_strings.dart';
import 'package:app_flutter_news/constants/app_sizes.dart';

class NewsCard extends StatelessWidget {
  const NewsCard({super.key, required this.article, this.cardIndex = 0, this.category, this.height});

  final Article article;
  final int cardIndex;
  final String? category;
  final double? height;

  // Modern color palette
  static const List<Color> _cardColors = [
    Color(0xFFFFF8E7), // Cream
    Color(0xFFE8F4FD), // Light Blue
    Color(0xFFF0F9FF), // Sky Blue
    Color(0xFFFFE4E6), // Light Pink
    Color(0xFFE6FFFA), // Mint
    Color(0xFFFFF0F5), // Lavender Blush
    Color(0xFFEDF2FF), // Periwinkle
    Color(0xFFF7FAFC), // Cool Gray
  ];

  Color _getCardColor() {
    // Use a combination of article title hash and cardIndex for consistent but varied colors
    final hash = (article.title?.hashCode ?? 0) + cardIndex;
    return _cardColors[hash.abs() % _cardColors.length];
  }

  double _getCardRotation() {
    // Better rotation system: current card straight, others with subtle rotation
    if (cardIndex == 0) return 0.0; // Current card - no rotation
    
    // More subtle rotations for background cards
    final rotations = [-AppSizes.rotationM, AppSizes.rotationS, -AppSizes.rotationL, 0.014, -0.01, 0.016];
    return rotations[(cardIndex - 1) % rotations.length];
  }

  Color _getCategoryColor() {
    if (category == null) return const Color(0xFFFF6B35); // Default orange
    
    final categoryColors = {
      'general': const Color(0xFF4CAF50),     // Green
      'business': const Color(0xFF2196F3),    // Blue
      'entertainment': const Color(0xFFE91E63), // Pink
      'health': const Color(0xFF00BCD4),      // Cyan
      'science': const Color(0xFF9C27B0),     // Purple
      'sports': const Color(0xFFFF9800),      // Orange
      'technology': const Color(0xFF607D8B),  // Blue Grey
    };
    
    return categoryColors[category] ?? const Color(0xFFFF6B35);
  }

  String _getCategoryDisplayName() {
    if (category == null) return AppStrings.hotBadge;
    return category![0].toUpperCase() + category!.substring(1);
  }

  String _formatTimeAgo() {
    if (article.publishedAt == null) return AppStrings.justNow;
    
    final now = DateTime.now();
    final diff = now.difference(article.publishedAt!);
    
    if (diff.inMinutes < 1) return AppStrings.justNow;
    if (diff.inMinutes < 60) return AppStrings.minutesAgo.replaceAll('{minutes}', diff.inMinutes.toString());
    if (diff.inHours < 24) return AppStrings.hoursAgo.replaceAll('{hours}', diff.inHours.toString());
    if (diff.inDays < 7) return AppStrings.daysAgo.replaceAll('{days}', diff.inDays.toString());
    return AppStrings.weeksAgo.replaceAll('{weeks}', (diff.inDays ~/ 7).toString());
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = _getCardColor();
    final rotation = _getCardRotation();

    return Transform.rotate(
      angle: rotation,
      child: Container(
        margin: EdgeInsets.zero,
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusXXXL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(AppSizes.opacityS),
              blurRadius: AppSizes.blurL,
              spreadRadius: AppSizes.shadowSpread,
              offset: const Offset(0, AppSizes.shadowOffset),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(AppSizes.opacityS),
              blurRadius: AppSizes.blurS,
              spreadRadius: AppSizes.shadowSpread,
              offset: const Offset(0, AppSizes.shadowOffset),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main content area
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
        child: Padding(
                    padding: const EdgeInsets.all(AppSizes.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category badge and time
              Row(
                children: [
                  Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingM, vertical: AppSizes.spacingXS),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(),
                                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: Text(
                      _getCategoryDisplayName(),
                      style: const TextStyle(
                        color: Colors.white,
                                  fontSize: AppSizes.fontSizeS,
                        fontWeight: FontWeight.bold,
                                  letterSpacing: AppSizes.letterSpacingS,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.access_time,
                              size: AppSizes.iconS,
                              color: Colors.black.withOpacity(AppSizes.opacityL),
                  ),
                            const SizedBox(width: AppSizes.spacingXS),
                  Text(
                    _formatTimeAgo(),
                    style: TextStyle(
                                color: Colors.black.withOpacity(AppSizes.opacityL),
                                fontSize: AppSizes.fontSizeS,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                (article.title ?? 'Untitled').trim(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Time indicator
              Text(
                _formatTimeAgo(),
                style: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              // Publisher info and follow button
              if (article.source?.name != null) ...[
                Row(
                  children: [
                    // Publisher avatar
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.newspaper,
                        size: 18,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Published by',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          article.source!.name!,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

                        // Description (compact) - takes remaining space
              if (article.description != null) ...[
                          Expanded(
                            child: Text(
                              article.description!.trim(),
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    color: Colors.black.withOpacity(0.7),
                    fontWeight: FontWeight.w400,
                  ),
                              maxLines: 8,
                  overflow: TextOverflow.ellipsis,
                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Small action buttons in bottom-right corner
            _CompactActionButtons(),
          ],
        ),
      ),
    );
  }
}

class _CompactActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: AppSizes.spacingL,
      right: AppSizes.spacingL,
          child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacingM,
          vertical: AppSizes.spacingS,
        ),
            decoration: BoxDecoration(
          color: Colors.white.withOpacity(AppSizes.opacityXL),
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
              boxShadow: [
                BoxShadow(
              color: Colors.black.withOpacity(AppSizes.opacityS),
              blurRadius: AppSizes.blurM,
              spreadRadius: AppSizes.shadowSpread,
              offset: const Offset(0, AppSizes.shadowOffset),
                ),
              ],
            ),
                          child: Row(
          mainAxisSize: MainAxisSize.min,
                children: [
            _CompactActionButton(
                    icon: Icons.thumb_up_outlined,
                    onTap: () {
                      // Handle like
                    },
                  ),
            const SizedBox(width: AppSizes.spacingM),
            _CompactActionButton(
                    icon: Icons.bookmark_border,
                    onTap: () {
                      // Handle bookmark
                    },
                  ),
            const SizedBox(width: AppSizes.spacingM),
            _CompactActionButton(
                    icon: Icons.share_outlined,
                    onTap: () {
                      // Handle share
                    },
                  ),
                ],
                          ),
              ),
    );
  }
}

class _CompactActionButton extends StatelessWidget {
  const _CompactActionButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSizes.containerXS,
        height: AppSizes.containerXS,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
          color: Colors.transparent,
        ),
        child: Icon(
          icon,
          size: AppSizes.iconL,
          color: Colors.black.withOpacity(AppSizes.opacityL),
        ),
      ),
    );
  }
}