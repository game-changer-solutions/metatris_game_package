import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'ع'**
  String get changeLanguage;

  /// No description provided for @metatris.
  ///
  /// In en, this message translates to:
  /// **'METATRIS'**
  String get metatris;

  /// No description provided for @showBar.
  ///
  /// In en, this message translates to:
  /// **'Show Bar'**
  String get showBar;

  /// No description provided for @showScore.
  ///
  /// In en, this message translates to:
  /// **'Show Score'**
  String get showScore;

  /// No description provided for @eyeTracking.
  ///
  /// In en, this message translates to:
  /// **'Eye Tracking'**
  String get eyeTracking;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Enter Username'**
  String get username;

  /// No description provided for @usernameRequiredField.
  ///
  /// In en, this message translates to:
  /// **'Please Enter a Username!'**
  String get usernameRequiredField;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @tutorial.
  ///
  /// In en, this message translates to:
  /// **'Tutorial'**
  String get tutorial;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @go.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get go;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score:'**
  String get score;

  /// No description provided for @tetrises.
  ///
  /// In en, this message translates to:
  /// **'Tetrises'**
  String get tetrises;

  /// No description provided for @lines.
  ///
  /// In en, this message translates to:
  /// **'Lines'**
  String get lines;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @games.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get games;

  /// No description provided for @nextBlock.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextBlock;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get gameOver;

  /// No description provided for @endScore.
  ///
  /// In en, this message translates to:
  /// **'End Score:'**
  String get endScore;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @viewEyeTrackingResults.
  ///
  /// In en, this message translates to:
  /// **'View Eye Tracking Results'**
  String get viewEyeTrackingResults;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @welcomeToTheMetatris.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the Metatris\nGame!'**
  String get welcomeToTheMetatris;

  /// No description provided for @hereWeWillExplain.
  ///
  /// In en, this message translates to:
  /// **'Here we will explain how to play\nthis fun and exciting game.'**
  String get hereWeWillExplain;

  /// No description provided for @gameBlocksWillFall.
  ///
  /// In en, this message translates to:
  /// **'Game blocks will fall one at\na time from the top.'**
  String get gameBlocksWillFall;

  /// No description provided for @fitTheBlocksTogether.
  ///
  /// In en, this message translates to:
  /// **'Fit the blocks together to\nmake lines (without spaces if\nyou can!)going across.'**
  String get fitTheBlocksTogether;

  /// No description provided for @tapThe.
  ///
  /// In en, this message translates to:
  /// **'Tap the '**
  String get tapThe;

  /// No description provided for @arrowKeys.
  ///
  /// In en, this message translates to:
  /// **'arrow keys'**
  String get arrowKeys;

  /// No description provided for @toMoveTheBlocksLeftAndRight.
  ///
  /// In en, this message translates to:
  /// **' (or on the Keyboard) to move\nthe blocks left and right or\npress down to drop faster.'**
  String get toMoveTheBlocksLeftAndRight;

  /// No description provided for @rotationKeys.
  ///
  /// In en, this message translates to:
  /// **'rotation keys'**
  String get rotationKeys;

  /// No description provided for @toTurnTheBlocksAround.
  ///
  /// In en, this message translates to:
  /// **' to\nturn the blocks around\nclockwise (\"arrow up\" on the keyboard) and\ncounterclockwise (\"right shift\" on the keyboard).'**
  String get toTurnTheBlocksAround;

  /// No description provided for @whenYouMakeALine.
  ///
  /// In en, this message translates to:
  /// **'When you make a line the\nentire stack goes down.'**
  String get whenYouMakeALine;

  /// No description provided for @ifYourStackReaches.
  ///
  /// In en, this message translates to:
  /// **'If your stack reaches the very\ntop you lose the game.'**
  String get ifYourStackReaches;

  /// No description provided for @theGameWillIncrease.
  ///
  /// In en, this message translates to:
  /// **'The game will increase in speed as\nyou get better with blocks falling\nfaster and faster.'**
  String get theGameWillIncrease;

  /// No description provided for @scoringATetris.
  ///
  /// In en, this message translates to:
  /// **'Scoring a Tetris is an advanced\nmove and you get more points!'**
  String get scoringATetris;

  /// No description provided for @useTheLongBar.
  ///
  /// In en, this message translates to:
  /// **'Use the long bar to clear four lines\nat once and score a \"tetris\"'**
  String get useTheLongBar;

  /// No description provided for @youMightOnlySeeYourScore.
  ///
  /// In en, this message translates to:
  /// **'You might only\nsee your score and stats.'**
  String get youMightOnlySeeYourScore;

  /// No description provided for @useThisInformationToMotivate.
  ///
  /// In en, this message translates to:
  /// **'Use this information to\nmotivate yourself: '**
  String get useThisInformationToMotivate;

  /// No description provided for @tryAndGetHigher.
  ///
  /// In en, this message translates to:
  /// **'try and get\nhigher and higher scores!'**
  String get tryAndGetHigher;

  /// No description provided for @youMightSeeAGreen.
  ///
  /// In en, this message translates to:
  /// **'You might see a\ngreen and red moving bar.'**
  String get youMightSeeAGreen;

  /// No description provided for @thisBarTellsYou.
  ///
  /// In en, this message translates to:
  /// **'This bar tells you how well you are\nplaying. '**
  String get thisBarTellsYou;

  /// No description provided for @ifYouAreInTheGreen.
  ///
  /// In en, this message translates to:
  /// **'If you are in the green you\nare doing well.'**
  String get ifYouAreInTheGreen;

  /// No description provided for @bothThe.
  ///
  /// In en, this message translates to:
  /// **'Both the '**
  String get bothThe;

  /// No description provided for @scoreWithSmallLetters.
  ///
  /// In en, this message translates to:
  /// **'score'**
  String get scoreWithSmallLetters;

  /// No description provided for @andThe.
  ///
  /// In en, this message translates to:
  /// **' and\nthe '**
  String get andThe;

  /// No description provided for @bar.
  ///
  /// In en, this message translates to:
  /// **'bar'**
  String get bar;

  /// No description provided for @willBeOnTheScreen.
  ///
  /// In en, this message translates to:
  /// **' will be on the screen.'**
  String get willBeOnTheScreen;

  /// No description provided for @focusOnYourScoreBut.
  ///
  /// In en, this message translates to:
  /// **'Focus on your score but use the bar\nto help guide how you\'re playing.'**
  String get focusOnYourScoreBut;

  /// No description provided for @readyForAPractice.
  ///
  /// In en, this message translates to:
  /// **'Ready for a\npractice run?'**
  String get readyForAPractice;

  /// No description provided for @tryAndSeeHowMany.
  ///
  /// In en, this message translates to:
  /// **'Try and see how\nmany lines you can\nclear in 30 seconds.'**
  String get tryAndSeeHowMany;

  /// No description provided for @haveFun.
  ///
  /// In en, this message translates to:
  /// **'Have Fun!!'**
  String get haveFun;

  /// No description provided for @thereIsNoPointInPlaying.
  ///
  /// In en, this message translates to:
  /// **'There\'s no point in\nplaying a game if\nyou are not having\nfun'**
  String get thereIsNoPointInPlaying;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @scoreDetails.
  ///
  /// In en, this message translates to:
  /// **'Score Details'**
  String get scoreDetails;

  /// No description provided for @indicatorValue.
  ///
  /// In en, this message translates to:
  /// **'Indicator Value'**
  String get indicatorValue;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
