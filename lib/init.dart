import 'package:backendless_sdk/backendless_sdk.dart';
import 'package:flutter/material.dart';

// Initialization Variables
bool integrationInitialized = false;
String? username;
String? userId;
String? researchId;
String? localName;
ThemeMode? themeMode;
Color? primaryColor;

class InitApp {
  static const String apiKeyAndroid = '20CE2D9E-0741-4C02-85D6-A8EE096E8443';
  static const String apiKeyiOS = '9014B01E-141B-478F-ABF6-25E01AD02CA1';
  static const String apiKeyJS = '42EA9536-AFCF-44F9-8212-C1B9154B124F';
  static const String appID = '1B87CFC9-DC13-690E-FFA2-F557A5EF0E00';

  static void initializeApp(BuildContext context) async {
    String result = "OK";
    Backendless.setUrl('https://api.backendless.com');
    await Backendless.initApp(
      applicationId: appID,
      iosApiKey: apiKeyiOS,
      androidApiKey: apiKeyAndroid,
      jsApiKey: apiKeyJS,
    ).onError((error, stackTrace) {
      result = error.toString();
    });
    debugPrint(result);
  }

  static void initIntegration({
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
}
