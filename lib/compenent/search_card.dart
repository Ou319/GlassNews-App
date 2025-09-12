import 'package:flutter/material.dart';
import 'package:app_flutter_news/constants/app_strings.dart';
import 'package:app_flutter_news/constants/app_sizes.dart';

class SearchCard extends StatelessWidget {
  const SearchCard({
    super.key,
    required this.title,
    required this.description,
    required this.color,
    this.isTop = false,
    this.offset = 0.0,
  });

  final String title;
  final String description;
  final Color color;
  final bool isTop;
  final double offset;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, offset),
      child: Transform.scale(
        scale: isTop ? 1.0 : AppSizes.stackedCardScale,
        child: Container(
          height: AppSizes.searchCardHeight,
          margin: const EdgeInsets.symmetric(
            horizontal: AppSizes.searchCardMargin,
            vertical: AppSizes.spacingS,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(AppSizes.opacityS),
                blurRadius: AppSizes.blurM,
                spreadRadius: AppSizes.shadowSpread,
                offset: const Offset(0, AppSizes.shadowOffset),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacingXL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: AppSizes.fontSizeXL,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: AppSizes.lineHeightS,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSizes.spacingM),
                Expanded(
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: AppSizes.fontSizeM,
                      color: Colors.black87,
                      height: AppSizes.lineHeightM,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
