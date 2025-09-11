import 'package:flutter/material.dart';
import 'routes/route_generator.dart';
import 'routes/route_const.dart';
import 'package:get/get.dart';

/// Main entry point of the Flutter News App
void main() {
  runApp(const MyApp());
}

/// Root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // App title and theme configuration
      title: 'GlassNews App',
      debugShowCheckedModeBanner: false, // Remove debug banner
      
      // Theme configuration with glassmorphism colors
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF4A90E2),
        scaffoldBackgroundColor: const Color(0xFFE0F1FF),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4A90E2),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      
      // Initial route - starts with splash screen
      initialRoute: RouteConst.home,
      
      // Route generation using RouteGenerator
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
