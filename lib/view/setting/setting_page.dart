import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_flutter_news/constants/app_strings.dart';
import 'package:app_flutter_news/constants/app_sizes.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_flutter_news/controler/search_controller.dart' as search_ctrl;
import 'package:app_flutter_news/controler/category_news_controller.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage>
    with TickerProviderStateMixin {
  late AnimationController _circularController;
  late Animation<double> _circularAnimation;

  // Settings state
  String _language = 'en';
  String _country = 'us';
  bool _darkMode = true; // app uses dark backgrounds by default

  static const String _keyLanguage = 'settings_language';
  static const String _keyCountry = 'settings_country';
  static const String _keyDarkMode = 'settings_theme_dark';

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

    _loadSettings();
  }

  @override
  void dispose() {
    _circularController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _language = prefs.getString(_keyLanguage) ?? 'en';
      _country = prefs.getString(_keyCountry) ?? 'us';
      _darkMode = prefs.getBool(_keyDarkMode) ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, _language);
    await prefs.setString(_keyCountry, _country);
    await prefs.setBool(_keyDarkMode, _darkMode);
    // Apply to controllers so API calls use these defaults
    if (Get.isRegistered<search_ctrl.SearchController>()) {
      final s = Get.find<search_ctrl.SearchController>();
      s.updateLanguage(_language);
      s.updateCountry(_country);
      if (s.searchQuery.value.trim().isNotEmpty) {
        // ignore: discarded_futures
        s.searchNews(s.searchQuery.value);
      } else {
        // ignore: discarded_futures
        s.fetchInitialNews();
      }
    }
    if (Get.isRegistered<CategoryNewsController>()) {
      final c = Get.find<CategoryNewsController>();
      c.updateCountry(_country);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved')),
    );
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
          
          // Settings Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.spacingXL),
              child: ListView(
                children: [
                  _glassCard(child: _buildLanguageCountry()),
                  const SizedBox(height: AppSizes.spacingXL),
                  _glassCard(child: _buildThemeToggle()),
                  const SizedBox(height: AppSizes.spacingXL),
                  _glassCard(child: _buildAbout()),
                  const SizedBox(height: AppSizes.spacingXXL),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.18),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.spacingXL,
                          vertical: AppSizes.spacingM,
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
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

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacingXL),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCountry() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Localization',
          style: TextStyle(
            color: Colors.white,
            fontSize: AppSizes.fontSizeXL,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSizes.spacingL),
        Row(
          children: [
            Expanded(
              child: _dropdown(
                label: 'Language',
                value: _language,
                items: const ['en','ar','fr','es','de','it','ru','zh'],
                onChanged: (v) => setState(() => _language = v ?? 'en'),
              ),
            ),
            const SizedBox(width: AppSizes.spacingL),
            Expanded(
              child: _dropdown(
                label: 'Country',
                value: _country,
                items: const ['us','gb','fr','de','in','ca','au','jp'],
                onChanged: (v) => setState(() => _country = v ?? 'us'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeToggle() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Dark Mode',
            style: TextStyle(
              color: Colors.white,
              fontSize: AppSizes.fontSizeXL,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Switch(
          value: _darkMode,
          onChanged: (v) => setState(() => _darkMode = v),
        ),
      ],
    );
  }

  Widget _buildAbout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'About',
          style: TextStyle(
            color: Colors.white,
            fontSize: AppSizes.fontSizeXL,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: AppSizes.spacingM),
        Text(
          'Set your default country and language for news.\nChoose dark or light mode.\nYour preferences are saved on this device.',
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.85))),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            dropdownColor: const Color(0xFF1E1E1E),
            underline: const SizedBox.shrink(),
            iconEnabledColor: Colors.white,
            style: const TextStyle(color: Colors.white),
            items: items.map((e) => DropdownMenuItem<String>(value: e, child: Text(e.toUpperCase()))).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
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