import 'package:flutter/material.dart';
import 'package:app_flutter_news/compenent/safe_glassify.dart';
import 'package:app_flutter_news/constants/app_strings.dart';
import 'package:app_flutter_news/constants/app_sizes.dart';

class SplaschScreen extends StatefulWidget {
  const SplaschScreen({super.key});

  @override
  State<SplaschScreen> createState() => _SplaschScreenState();
}

class _SplaschScreenState extends State<SplaschScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FrostedGlass(
          borderRadius: AppSizes.radiusCircle,
          blur: AppSizes.blurL,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingXXL, vertical: AppSizes.spacingL),
          child: const Text(
            AppStrings.splashTitle,
            style: TextStyle(
              fontSize: AppSizes.fontSizeHuge,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
