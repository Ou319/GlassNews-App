import 'package:flutter/material.dart';
import 'package:app_flutter_news/compenent/safe_glassify.dart';

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
          borderRadius: 40,
          blur: 24,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: const Text(
            'Glass',
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
