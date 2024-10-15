import 'package:flutter/material.dart';
import 'package:metatris_game_package/routes/routes.dart';

import '../../../init.dart';
import '../../helper/language_constants.dart';

class TutorialPagesNextButton extends StatelessWidget {
  final String? name;
  final String routeName;

  const TutorialPagesNextButton({
    super.key,
    this.name,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // if (routeName == RouteManager.homePage) {
        //   Navigator.of(context)
        //       .pushNamedAndRemoveUntil(routeName, (route) => false);
        // } else {
        //   Navigator.of(context).pushNamed(routeName);
        // }
        if (routeName == RouteManager.homePage) {
          if (integrationInitialized) {
            Navigator.popUntil(
                context, ModalRoute.withName("/metatris_home_page"));
          } else {
            Navigator.of(context).pushNamedAndRemoveUntil(
                RouteManager.homePage, (route) => false);
          }
        } else {
          // Navigator.of(context).pushNamed(routeName);
          Navigator.of(context).push(
            RouteManager.generateRoute(
              RouteSettings(name: routeName),
            ),
          );
        }
      },
      child: Text(
        name ?? translation(context).next,
        style: const TextStyle(
          fontSize: 22,
          color: Colors.white,
        ),
      ),
    );
  }
}
