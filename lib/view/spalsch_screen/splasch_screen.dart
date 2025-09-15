import 'package:flutter/material.dart';
import 'package:app_flutter_news/constants/app_strings.dart';
import 'package:app_flutter_news/constants/app_sizes.dart';
import 'package:app_flutter_news/view/navigation_bottom_bar/navigation_bottom_bar.dart';
import 'dart:io';

class SplaschScreen extends StatefulWidget {
  const SplaschScreen({super.key});

  @override
  State<SplaschScreen> createState() => _SplaschScreenState();
}

class _SplaschScreenState extends State<SplaschScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  bool? _hasConnection; // null = unknown, true/false after check

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();

    _checkConnectionAndProceed();
  }

  Future<void> _checkConnectionAndProceed() async {
    try {
      _hasConnection = null;
      setState(() {});
      final result = await InternetAddress.lookup('example.com').timeout(const Duration(seconds: 3));
      final ok = result.isNotEmpty && result.first.rawAddress.isNotEmpty;
      _hasConnection = ok;
    } catch (_) {
      _hasConnection = false;
    }
    if (!mounted) return;
    setState(() {});
    if (_hasConnection == true) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const NavigationBottomBar()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ScaleTransition(
          scale: _scale,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App logo: white circle with Z
              const _LogoCircle(),
              const SizedBox(height: AppSizes.spacingXL),
              const Text(
                'Glass News',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppSizes.fontSizeXXXL,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppSizes.spacingXL),
              if (_hasConnection == false)
                Column(
                  children: [
                    Text(
                      "You're offline. Please check your internet connection.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withOpacity(0.85)),
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    ElevatedButton(
                      onPressed: _checkConnectionAndProceed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.18),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                )
              else if (_hasConnection == null)
                const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoCircle extends StatelessWidget {
  const _LogoCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          'Z',
          style: TextStyle(
            color: Colors.black,
            fontSize: 64,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
