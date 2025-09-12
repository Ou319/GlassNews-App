import 'package:app_flutter_news/routes/route_const.dart';
import 'package:app_flutter_news/view/spalsch_screen/splasch_screen.dart';
import 'package:app_flutter_news/view/navigation_bottom_bar/navigation_bottom_bar.dart';
import 'package:app_flutter_news/view/home/home_page.dart';
import 'package:app_flutter_news/view/search/search_page.dart';
import 'package:app_flutter_news/view/save/save_page.dart';
import 'package:app_flutter_news/view/setting/setting_page.dart';
import 'package:app_flutter_news/constants/app_strings.dart';
import 'package:flutter/material.dart';



class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConst.splash:
        return MaterialPageRoute(builder: (_) => SplaschScreen());

      case RouteConst.navigation:
        return MaterialPageRoute(builder: (_) => const NavigationBottomBar());

      case RouteConst.home:
        return MaterialPageRoute(builder: (_) => const HomePage());

      case RouteConst.search:
        return MaterialPageRoute(builder: (_) => const SearchPage());

      case RouteConst.save:
        return MaterialPageRoute(builder: (_) => const SavePage());

      case RouteConst.setting:
        return MaterialPageRoute(builder: (_) => const SettingPage());

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.errorTitle),
          backgroundColor: Colors.red,
        ),
        body: const Center(
          child: Text(
            AppStrings.errorRouteNotFound,
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      ),
    );
  }
}
