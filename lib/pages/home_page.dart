import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import '../init.dart';
import '../main.dart';
import 'helper/helper.dart';
import 'helper/language_constants.dart';
import 'tutorial_pages/tutorial_page11.dart';
import 'game_page.dart';
import 'tutorial_pages/tutorial_page1.dart';

final usernameInput = TextEditingController();
bool showIndicator = true;
bool showScore = true;
bool useEyeTracking = true;

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.android) {
      useEyeTracking = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Row(children: [
            Image(
              image: const AssetImage("assets/images/metatris_logo.png"),
              width: 100.spMin,
              height: 50.spMin,
            ),
            Text(translation(context).metatris,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
          ]),
          actions: [
            if (!integrationInitialized)
              ElevatedButton(
                onPressed: () async {
                  Locale locale = await setLocale(
                      translation(context).localeName == "en" ? "ar" : "en");
                  MyApp.setLocale(context, locale);
                },
                style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.lightBlueAccent)),
                child: Text(
                  translation(context).changeLanguage,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child:
                    Image(image: AssetImage("assets/images/metatris_logo.png")),
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SwitchListTile(
                        inactiveTrackColor: Colors.grey,
                        title: Text(
                          translation(context).showBar,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20),
                        ),
                        value: showIndicator,
                        onChanged: (newValue) {
                          setState(() {
                            showIndicator = newValue;
                          });
                        }),
                    SwitchListTile(
                        inactiveTrackColor: Colors.grey,
                        title: Text(
                          translation(context).showScore,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20),
                        ),
                        value: showScore,
                        onChanged: (newValue) {
                          setState(() {
                            showScore = newValue;
                          });
                        }),
                    if (defaultTargetPlatform == TargetPlatform.iOS ||
                        defaultTargetPlatform == TargetPlatform.android)
                      SwitchListTile(
                          inactiveTrackColor: Colors.grey,
                          title: Text(
                            translation(context).eyeTracking,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20),
                          ),
                          value: useEyeTracking,
                          onChanged: (newValue) {
                            setState(() {
                              useEyeTracking = newValue;
                            });
                          }),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              if (!integrationInitialized)
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: InputDecoration(
                      iconColor: Colors.white,
                      labelText: translation(context).username,
                      border: const OutlineInputBorder(),
                      enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                    controller: usernameInput,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (usernameInput.text == "" && (!integrationInitialized)) {
                    showSnackBar(
                        context, translation(context).usernameRequiredField);
                  } else {
                    // bool storagePermission = await getPermissionStatus(
                    //     context, Permission.manageExternalStorage, "Storage");
                    if (useEyeTracking) {
                      bool cameraPermission = await getPermissionStatus(
                          context, Permission.camera, "Camera");
                      // if (storagePermission && cameraPermission) {
                      if (cameraPermission) {
                        tutorialMode = false;
                        // Navigator.of(context)
                        //     .pushNamed(RouteManager.gamePage);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const GamePage(),
                          ),
                        );
                      }
                    } else {
                      // if (storagePermission) {
                      tutorialMode = false;
                      // Navigator.of(context).pushNamed(RouteManager.gamePage);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const GamePage(),
                        ),
                      );
                      // }
                    }
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      translation(context).play,
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    ),
                    const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () {
                  // Navigator.of(context).pushNamed(RouteManager.tutorialPage1);
                  tutorialMode = true;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TutorialPage1(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  side: BorderSide(
                      color: integrationInitialized && primaryColor != null
                          ? primaryColor!
                          : Colors.blue),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      translation(context).tutorial,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const Icon(
                      Icons.play_arrow_outlined,
                      size: 20,
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (integrationInitialized)
                Column(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        side: BorderSide(
                            color:
                                integrationInitialized && primaryColor != null
                                    ? primaryColor!
                                    : Colors.blue),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            translation(context).exit,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          const Icon(
                            Icons.exit_to_app,
                            size: 20,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
