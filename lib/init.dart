import 'package:flutter/material.dart';

// Initialization Variables
bool integrationInitialized = false;
String? token;
int? researchId;
String? resultDisplayName;
String? kBaseUrl;
String? localName;
ThemeMode? themeMode;
Color? primaryColor;

class InitApp {
  static void initIntegration({
    String? newToken,
    int? newResearchId,
    String? newResultDisplayName,
    String? newBaseUrl,
    String? newLocalName,
    ThemeMode? newThemeMode,
    Color? newPrimaryColor,
  }) {
    token = newToken;
    researchId = newResearchId;
    resultDisplayName = newResultDisplayName;
    kBaseUrl = newBaseUrl;
    localName = newLocalName;
    themeMode = newThemeMode;
    primaryColor = newPrimaryColor;
    integrationInitialized = true;
  }
}
