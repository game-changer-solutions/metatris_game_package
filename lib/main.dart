import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metatris_game_package/pages/helper/helper.dart';
import 'package:metatris_game_package/pages/helper/language_constants.dart';

import 'routes/routes.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) => {setLocale(locale)});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Metatris',
      debugShowCheckedModeBanner: false,
      initialRoute: RouteManager.homePage,
      onGenerateRoute: RouteManager.generateRoute,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: integrationInitialized && localName != null
          ? Locale(localName!)
          : _locale,
      theme: ThemeData(
          useMaterial3: false,
          colorScheme: integrationInitialized && primaryColor != null
              ? ColorScheme.fromSeed(seedColor: primaryColor!)
              : null),
      darkTheme: ThemeData.dark(useMaterial3: false),
      themeMode: integrationInitialized && themeMode != null
          ? themeMode
          : ThemeMode.light,
    );
  }
}
