import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationBottomBarController extends GetxController {
  final RxInt currentIndex = 0.obs;
  late final PageController pageController;

  @override
  void onInit() {
    pageController = PageController(initialPage: currentIndex.value);
    super.onInit();
  }

  void onPageChanged(int index) {
    if (index != currentIndex.value) {
      currentIndex.value = index;
    }
  }

  Future<void> onTap(int index, {Duration duration = const Duration(milliseconds: 320), Curve curve = Curves.easeInOutCubic}) async {
    if (index == currentIndex.value) return;
    currentIndex.value = index;
    await pageController.animateToPage(index, duration: duration, curve: curve);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

