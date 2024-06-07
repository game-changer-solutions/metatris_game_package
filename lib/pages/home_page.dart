import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:metatris_game_package/init.dart';
import 'package:metatris_game_package/main.dart';
import 'package:metatris_game_package/pages/helper/helper.dart';
import 'package:metatris_game_package/pages/helper/language_constants.dart';
import 'package:metatris_game_package/pages/tutorial_pages/tutorial_page11.dart';
import '../routes/routes.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    InitApp.initializeApp(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Image(
            image: AssetImage("assets/images/metatris_logo.png"),
            width: 100,
            height: 50,
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
                      MaterialStateProperty.all<Color>(Colors.lightBlueAccent)),
              child: Text(translation(context).changeLanguage,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20)),
            )
        ],
      ),
      body: Container(
        color: Colors.black,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Image(
                      image: AssetImage("assets/images/metatris_logo.png")),
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: AppLocalizations.of(context)!.localeName == "ar"
                      ? const EdgeInsets.only(right: 20)
                      : const EdgeInsets.only(left: 20),
                  child: SizedBox(
                    width: 230,
                    child: Column(
                      children: [
                        Transform.scale(
                          scale: 1.5,
                          child: SwitchListTile(
                              inactiveTrackColor: Colors.grey,
                              title: Text(
                                translation(context).showBar,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                              value: showIndicator,
                              onChanged: (newValue) {
                                setState(() {
                                  showIndicator = newValue;
                                });
                              }),
                        ),
                        Transform.scale(
                          scale: 1.5,
                          child: SwitchListTile(
                              inactiveTrackColor: Colors.grey,
                              title: Text(
                                translation(context).showScore,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                              value: showScore,
                              onChanged: (newValue) {
                                setState(() {
                                  showScore = newValue;
                                });
                              }),
                        ),
                        Transform.scale(
                          scale: 1.5,
                          child: SwitchListTile(
                              inactiveTrackColor: Colors.grey,
                              title: Text(
                                translation(context).eyeTracking,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                              value: useEyeTracking,
                              onChanged: (newValue) {
                                setState(() {
                                  useEyeTracking = newValue;
                                });
                              }),
                        ),
                      ],
                    ),
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
                          Navigator.of(context)
                              .pushNamed(RouteManager.gamePage);
                        }
                      } else {
                        // if (storagePermission) {
                        tutorialMode = false;
                        Navigator.of(context).pushNamed(RouteManager.gamePage);
                        // }
                      }
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        translation(context).play,
                        style: const TextStyle(fontSize: 40),
                      ),
                      const Icon(
                        Icons.play_arrow,
                        size: 40,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(RouteManager.tutorialPage1);
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
                // if (integrationInitialized)
                //   Column(
                //     children: [
                //       const SizedBox(height: 10),
                //       OutlinedButton(
                //         onPressed: () {
                //           Navigator.of(context).pop();
                //           Navigator.of(context).pop();
                //         },
                //         style: OutlinedButton.styleFrom(
                //           shape: const RoundedRectangleBorder(
                //             borderRadius: BorderRadius.all(Radius.circular(5)),
                //           ),
                //           side: BorderSide(
                //               color:
                //                   integrationInitialized && primaryColor != null
                //                       ? primaryColor!
                //                       : Colors.blue),
                //         ),
                //         child: Row(
                //           mainAxisSize: MainAxisSize.min,
                //           children: <Widget>[
                //             Text(
                //               translation(context).exit,
                //               style: const TextStyle(fontSize: 20),
                //             ),
                //             const SizedBox(
                //               width: 5,
                //             ),
                //             const Icon(
                //               Icons.exit_to_app,
                //               size: 20,
                //             )
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
