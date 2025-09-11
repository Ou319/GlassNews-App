import 'dart:math';
import 'package:flutter/material.dart';
import 'package:app_flutter_news/model/news_models.dart';

class NewsCard extends StatelessWidget {
  const NewsCard({super.key, required this.article, this.cardIndex = 0});

  final Article article;
  final int cardIndex;

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
    // Slight rotation for stacked card effect
    final rotations = [-0.02, 0.015, -0.01, 0.025, -0.015];
    return rotations[cardIndex % rotations.length];
  }

  String _formatTimeAgo() {
    if (article.publishedAt == null) return 'Updated just now';
    
    final now = DateTime.now();
    final diff = now.difference(article.publishedAt!);
    
    if (diff.inMinutes < 1) return 'Updated just now';
    if (diff.inMinutes < 60) return 'Updated ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Updated ${diff.inHours}h ago';
    if (diff.inDays < 7) return 'Updated ${diff.inDays}d ago';
    return 'Updated ${diff.inDays ~/ 7}w ago';
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = _getCardColor();
    final rotation = _getCardRotation();

    return Transform.rotate(
      angle: rotation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LIVE badge and time
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4444),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.black.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTimeAgo(),
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                (article.title ?? 'Untitled').trim(),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  color: Colors.black87,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),

              // Time indicator
              Text(
                _formatTimeAgo(),
                style: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),

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
                    const Spacer(),
                    // Follow button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Follow',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // Description
              if (article.description != null) ...[
                Text(
                  article.description!.trim(),
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    color: Colors.black.withOpacity(0.8),
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
              ],

              const Spacer(),

              // Action buttons
              Row(
                children: [
                  _ActionButton(
                    icon: Icons.thumb_up_outlined,
                    onTap: () {
                      // Handle like
                    },
                  ),
                  const SizedBox(width: 16),
                  _ActionButton(
                    icon: Icons.bookmark_border,
                    onTap: () {
                      // Handle bookmark
                    },
                  ),
                  const Spacer(),
                  _ActionButton(
                    icon: Icons.share_outlined,
                    onTap: () {
                      // Handle share
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
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
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Icon(
          icon,
          size: 20,
          color: Colors.black.withOpacity(0.7),
        ),
      ),
    );
  }
}