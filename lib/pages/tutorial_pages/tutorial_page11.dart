import 'package:flutter/material.dart';
import 'package:metatris_game_package/pages/helper/language_constants.dart';

import '../../routes/routes.dart';
import 'widgets/tutorial_pages_appbar.dart';
import 'widgets/tutorial_pages_next_button.dart';

bool tutorialMode = false;

class TutorialPage11 extends StatelessWidget {
  const TutorialPage11({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const TutorialPagesAppBar(),
      floatingActionButton: TutorialPagesNextButton(
          name: translation(context).go, routeName: RouteManager.gamePage),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                translation(context).readyForAPractice,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 70),
              Text(
                translation(context).tryAndSeeHowMany,
                style: const TextStyle(
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
