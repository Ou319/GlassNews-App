import 'package:flutter/material.dart';
import 'package:app_flutter_news/model/news_models.dart';
import 'package:app_flutter_news/constants/app_strings.dart';
import 'package:app_flutter_news/constants/app_sizes.dart';
import 'package:get/get.dart';
import 'package:app_flutter_news/controler/save_controller.dart';
import 'dart:ui';

class NewsCard extends StatefulWidget {
  const NewsCard({super.key, required this.article, this.cardIndex = 0, this.category, this.height});

  final Article article;
  final int cardIndex;
  final String? category;
  final double? height;



  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> with SingleTickerProviderStateMixin {
  late final SaveController _saveController;
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _saveController = Get.put(SaveController(), permanent: true);
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.25).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _getCategoryDisplayName() {
    if (widget.category == null) return AppStrings.hotBadge;
    return widget.category![0].toUpperCase() + widget.category!.substring(1);
  }

  Widget _buildGlassChip({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingM,
        vertical: AppSizes.spacingS,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: child,
    );
  }

  Widget _buildSaveButton() {
    final bool isSaved = _saveController.isSavedSync(widget.article);
    return GestureDetector(
      onTap: () async {
        await _animController.forward();
        await _animController.reverse();
        await _saveController.toggleSave(widget.article);
        setState(() {});
      },
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo() {
    if (widget.article.publishedAt == null) return AppStrings.justNow;
    
    final now = DateTime.now();
    final diff = now.difference(widget.article.publishedAt!);
    
    if (diff.inMinutes < 1) return AppStrings.justNow;
    if (diff.inMinutes < 60) return AppStrings.minutesAgo.replaceAll('{minutes}', diff.inMinutes.toString());
    if (diff.inHours < 24) return AppStrings.hoursAgo.replaceAll('{hours}', diff.inHours.toString());
    if (diff.inDays < 7) return AppStrings.daysAgo.replaceAll('{days}', diff.inDays.toString());
    return AppStrings.weeksAgo.replaceAll('{weeks}', (diff.inDays ~/ 7).toString());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusXXXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusXXXL),
        child: Stack(
          children: [
            // Background Image
            if (widget.article.urlToImage != null)
              Positioned.fill(
                child: Image.network(
                  widget.article.urlToImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue.withOpacity(0.8),
                            Colors.purple.withOpacity(0.8),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            
            // Glass Effect Overlay
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Content
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.spacingXL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row with category and time
                    Row(
                      children: [
                        _buildGlassChip(
                          child: Text(
                            _getCategoryDisplayName(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: AppSizes.fontSizeS,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        _buildGlassChip(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatTimeAgo(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: AppSizes.fontSizeS,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSizes.spacingXL),
                    
                    // Title
                    Text(
                      (widget.article.title ?? 'Untitled').trim(),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: AppSizes.spacingL),
                    
                    // Description
                    Text(
                      widget.article.description ?? 'No description available',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: Colors.white.withOpacity(0.9),
                        shadows: const [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const Spacer(),
                    
                    // Source info
                    if (widget.article.source?.name != null)
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.newspaper,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Published by',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  widget.article.source!.name!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black54,
                                        blurRadius: 4,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            
            // Save button only
            Positioned(
              right: AppSizes.spacingL,
              bottom: AppSizes.spacingXL,
              child: _buildSaveButton(),
            ),
          ],
        ),
      ),
    );
  }
}
