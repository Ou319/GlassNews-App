import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_flutter_news/controler/news_controller.dart';
import 'package:app_flutter_news/controler/category_news_controller.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:app_flutter_news/compenent/news_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final NewsController ctrl;
  late final CategoryNewsController categories;

  @override
  void initState() {
    super.initState();
    ctrl = Get.put(NewsController(), permanent: true);
    categories = Get.put(CategoryNewsController(), permanent: true);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('News (test)')),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: categories.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = categories.categories[index];
                return GestureDetector(
                  onTap: () => categories.fetchForCategory(cat),
                  child: Obx(() {
                    final bool selected = categories.selectedCategory.value == cat;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Text(
                        cat[0].toUpperCase() + cat.substring(1),
                        style: TextStyle(color: selected ? Colors.white : Colors.black),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          Expanded(
            child: GetX<CategoryNewsController>(
              init: categories,
              builder: (c) {
              final selected = c.selectedCategory.value;
              final list = c.categoryToArticles[selected] ?? const [];
              if (c.loading.value && list.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (c.error.isNotEmpty) {
                return Center(child: Text('Error: ${c.error}'));
              }
              if (list.isEmpty) {
                if (ctrl.loading.value) return const Center(child: CircularProgressIndicator());
                if (ctrl.error.isNotEmpty) return Center(child: Text('Error: ${ctrl.error}'));
                final a = ctrl.article.value;
                if (a == null) return const Center(child: Text('No article'));
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.title ?? 'Untitled', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(a.description ?? 'No description'),
                      const SizedBox(height: 12),
                      if (a.urlToImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            a.urlToImage!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => Container(
                              height: 180,
                              width: double.infinity,
                              color: Colors.black12,
                              alignment: Alignment.center,
                              child: const Icon(Icons.broken_image, color: Colors.grey),
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
              if (items.isEmpty) return const Center(child: Text('No articles'));
              return Padding(
                padding: const EdgeInsets.all(16),
                child: CardSwiper(
                  cardsCount: items.length,
                  isLoop: true,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  cardBuilder: (context, index, __, ___) => NewsCard(
                    article: items[index],
                    cardIndex: index,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}