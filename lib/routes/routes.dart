import 'package:flutter/material.dart';
import 'package:metatris_game_package/pages/eye_tracking/eye_tracking_results_page.dart';

import '../pages/game_page.dart';
import '../pages/home_page.dart';
import '../pages/tutorial_pages/tutorial_page1.dart';
import '../pages/tutorial_pages/tutorial_page2.dart';
import '../pages/tutorial_pages/tutorial_page3.dart';
import '../pages/tutorial_pages/tutorial_page4.dart';
import '../pages/tutorial_pages/tutorial_page5.dart';
import '../pages/tutorial_pages/tutorial_page6.dart';
import '../pages/tutorial_pages/tutorial_page7.dart';
import '../pages/tutorial_pages/tutorial_page8.dart';
import '../pages/tutorial_pages/tutorial_page9.dart';
import '../pages/tutorial_pages/tutorial_page10.dart';
import '../pages/tutorial_pages/tutorial_page11.dart';
import '../pages/tutorial_pages/tutorial_page12.dart';

class RouteManager {
  static const String homePage = '/';
  static const String gamePage = '/game_page';
  static const String eyeTrackingPage = '/eye_tracking_page';
  static const String tutorialPage1 = '/tutorial_page1';
  static const String tutorialPage2 = '/tutorial_page2';
  static const String tutorialPage3 = '/tutorial_page3';
  static const String tutorialPage4 = '/tutorial_page4';
  static const String tutorialPage5 = '/tutorial_page5';
  static const String tutorialPage6 = '/tutorial_page6';
  static const String tutorialPage7 = '/tutorial_page7';
  static const String tutorialPage8 = '/tutorial_page8';
  static const String tutorialPage9 = '/tutorial_page9';
  static const String tutorialPage10 = '/tutorial_page10';
  static const String tutorialPage11 = '/tutorial_page11';
  static const String tutorialPage12 = '/tutorial_page12';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homePage:
        return MaterialPageRoute(
          builder: (context) => const MyHomePage(),
        );
      case gamePage:
        return MaterialPageRoute(
          builder: (context) => const GamePage(),
        );
      case eyeTrackingPage:
        return MaterialPageRoute(
          builder: (context) => const EyeTrackingResultsPage(),
        );
      case tutorialPage1:
        return MaterialPageRoute(
          builder: (context) => const TutorialPage1(),
        );
      case tutorialPage2:
        return MaterialPageRoute(
          builder: (context) => const TutorialPage2(),
        );
      case tutorialPage3:
        return MaterialPageRoute(
          builder: (context) => const TutorialPage3(),
        );
      case tutorialPage4:
        return MaterialPageRoute(
          builder: (context) => const TutorialPage4(),
        );
      case tutorialPage5:
        return MaterialPageRoute(
          builder: (context) => const TutorialPage5(),
        );
      case tutorialPage6:
        return MaterialPageRoute(
          builder: (context) => const TutorialPage6(),
        );
      case tutorialPage7:
        return MaterialPageRoute(
          builder: (context) => const TutorialPage7(),
        );
      case tutorialPage8:
        return MaterialPageRoute(
          builder: (context) => const TutorialPage8(),
        );
      case tutorialPage9:
        return MaterialPageRoute(
          builder: (context) => const TutorialPage9(),
        );
      case tutorialPage10:
        return MaterialPageRoute(
          builder: (context) => const TutorialPage10(),
        );
      case tutorialPage11:
        return MaterialPageRoute(
          builder: (context) => const TutorialPage11(),
        );
      case tutorialPage12:
        return MaterialPageRoute(
          builder: (context) => const TutorialPage12(),
        );

      default:
        throw const FormatException('Route not found! Check routes again!');
    }
  }
}
