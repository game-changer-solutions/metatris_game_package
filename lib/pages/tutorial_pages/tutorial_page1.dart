import 'package:flutter/material.dart';
import 'package:metatris_game_package/pages/helper/language_constants.dart';

import '../../routes/routes.dart';
import 'widgets/tutorial_pages_appbar.dart';
import 'widgets/tutorial_pages_next_button.dart';

class TutorialPage1 extends StatelessWidget {
  const TutorialPage1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const TutorialPagesAppBar(),
      floatingActionButton:
          const TutorialPagesNextButton(routeName: RouteManager.tutorialPage2),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              translation(context).welcomeToTheMetatris,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 70),
            Text(
              translation(context).hereWeWillExplain,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
