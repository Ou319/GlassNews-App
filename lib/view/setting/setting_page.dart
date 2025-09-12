import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_flutter_news/constants/app_strings.dart';
import 'package:app_flutter_news/constants/app_sizes.dart';
import 'dart:math' as math;

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage>
    with TickerProviderStateMixin {
  late AnimationController _circularController;
  late Animation<double> _circularAnimation;

  @override
  void initState() {
    super.initState();
    _circularController = AnimationController(
      duration: const Duration(milliseconds: AppSizes.settingsCircularReveal),
      vsync: this,
    );
    
    _circularAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _circularController,
      curve: Curves.easeOutQuart,
    ));

    _circularController.forward();
  }

  @override
  void dispose() {
    _circularController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _circularAnimation,
        builder: (context, child) {
          return ClipPath(
            clipper: _CircularRevealClipper(
              progress: _circularAnimation.value,
            ),
            child: _buildContent(),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: Column(
        children: [
          // Header
          _buildHeader(),
          
          // Settings Content - Just Section Titles
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.spacingXL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(AppStrings.generalSettings),
                  const SizedBox(height: AppSizes.spacingXXL),
                  
                  _buildSectionTitle(AppStrings.appearanceSettings),
                  const SizedBox(height: AppSizes.spacingXXL),
                  
                  _buildSectionTitle(AppStrings.notificationsSettings),
                  const SizedBox(height: AppSizes.spacingXXL),
                  
                  _buildSectionTitle(AppStrings.aboutSettings),
                  const SizedBox(height: AppSizes.spacingXXL),
                  
                  _buildSectionTitle(AppStrings.accountSettings),
                  const SizedBox(height: AppSizes.spacingXXL),
                  
                  _buildSectionTitle(AppStrings.privacySettings),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingXL),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spacingL),
          Text(
            AppStrings.settingsTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: AppSizes.fontSizeXXXL,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingXL,
        vertical: AppSizes.spacingL,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: Colors.grey[700]!,
          width: 1,
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: AppSizes.fontSizeXL,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CircularRevealClipper extends CustomClipper<Path> {
  const _CircularRevealClipper({
    required this.progress,
  });

  final double progress;

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Calculate the radius for circular reveal
    final maxRadius = math.sqrt(
      math.pow(size.width / 2, 2) + math.pow(size.height / 2, 2),
    );
    
    final radius = maxRadius * progress;
    
    return Path()
      ..addOval(Rect.fromCircle(
        center: center,
        radius: radius,
      ));
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return oldClipper is _CircularRevealClipper &&
        oldClipper.progress != progress;
  }
}