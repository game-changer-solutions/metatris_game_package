import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:metatris_game_package/pages/helper/language_constants.dart';
import 'package:metatris_game_package/pages/home_page.dart';
import '../game_page.dart';
import '../../blocks/block.dart';
import '../../blocks/Iblock.dart';
import '../../blocks/Jblock.dart';
import '../../blocks/Lblock.dart';
import '../../blocks/Sblock.dart';
import '../../blocks/SQblock.dart';
import '../../blocks/Tblock.dart';
import '../../blocks/Zblock.dart';
import 'dart:math';

// Initialization Variables
bool integrationInitialized = false;
String? username;
String? userId;
String? researchId;
String? localName;
ThemeMode? themeMode;
Color? primaryColor;

initIntegration({
  String? newUsername,
  String? newUserId,
  String? newResearchId,
  String? newLocalName,
  ThemeMode? newThemeMode,
  Color? newPrimaryColor,
}) {
  username = newUsername;
  userId = newUserId;
  researchId = newResearchId;
  localName = newLocalName;
  themeMode = newThemeMode;
  primaryColor = newPrimaryColor;
  integrationInitialized = true;
}

Block? getRandomBlock() {
  int randomNum = Random().nextInt(7);
  switch (randomNum) {
    case 0:
      return IBlock(boardWidth);
    case 1:
      return JBlock(boardWidth);
    case 2:
      return LBlock(boardWidth);
    case 3:
      return SBlock(boardWidth);
    case 4:
      return SQBlock(boardWidth);
    case 5:
      return TBlock(boardWidth);
    case 6:
      return ZBlock(boardWidth);
    default:
      return null;
  }
}

Widget getTetrisPoint(Color color) {
  return Container(
    width: pointSize,
    height: pointSize,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.rectangle,
    ),
  );
}

Widget getGameOverText(int score, BuildContext context) {
  return Center(
    child: Text(
      "${translation(context).gameOver}${showScore ? "\n${translation(context).endScore}\n$score" : ""}",
      textAlign: TextAlign.center,
      style: TextStyle(
          color: integrationInitialized && primaryColor != null
              ? primaryColor
              : Colors.blue,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(
              color: Colors.black,
              blurRadius: 3,
              offset: Offset(2, 2),
            )
          ]),
    ),
  );
}

void showSnackBar(BuildContext context, String message) {
  final snackBar = SnackBar(
    duration: const Duration(milliseconds: 2500),
    elevation: 10,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
      topLeft: Radius.circular(5),
      topRight: Radius.circular(5),
    )),
    backgroundColor: Colors.red,
    content: Text(message),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Future<bool> getPermissionStatus(
    BuildContext context, Permission permission, String permissionName) async {
  PermissionStatus status = await permission.request();
  if (status == PermissionStatus.granted) {
    return true;
  } else {
    // Show dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'You need to give the $permissionName permission to the app. Please go to the app settings.',
                  style: const TextStyle(fontSize: 18),
                ),
                Align(
                  alignment: AlignmentDirectional.bottomEnd,
                  child: TextButton(
                    child: const Text(
                      'Go to App Settings',
                      style: TextStyle(color: Colors.lightBlue, fontSize: 18),
                    ),
                    onPressed: () {
                      openAppSettings();
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  return false;
}
