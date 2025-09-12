import 'package:flutter/material.dart';
import 'package:app_flutter_news/constants/app_strings.dart';

class SavePage extends StatelessWidget {
  const SavePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(AppStrings.saveLabel),
      ),
    );
  }
}