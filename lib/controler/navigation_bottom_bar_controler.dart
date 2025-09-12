import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationBottomBarController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void onPageChanged(int index) {
    if (index != currentIndex.value) {
      currentIndex.value = index;
    }
  }

  void onTap(int index, {Duration? duration, Curve? curve}) {
    if (index == currentIndex.value) return;
    currentIndex.value = index;
  }
}