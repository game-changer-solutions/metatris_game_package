import 'package:flutter/material.dart';
import 'package:metatris_game_package/pages/eye_tracking/eye_tracking.dart';

import 'package:metatris_game_package/pages/game_page.dart';

import '../helper/language_constants.dart';

class EyeTrackingResultsPage extends StatefulWidget {
  const EyeTrackingResultsPage({Key? key}) : super(key: key);

  @override
  State<EyeTrackingResultsPage> createState() => _EyeTrackingResultsPageState();
}

class _EyeTrackingResultsPageState extends State<EyeTrackingResultsPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
          ),
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
        title: Row(children: [
          const Image(
            image: AssetImage("assets/images/metatris_logo.png"),
            width: 100,
            height: 50,
          ),
          Text(
            translation(context).metatris,
          ),
        ]),
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(image: MemoryImage(screenshotImage!))),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: CustomPaint(
            painter: ResultsPainter(eyeCoordinates),
          ),
        ),
      ),
    );
  }
}

class ResultsPainter extends CustomPainter {
  final List<Offset> marks;
  const ResultsPainter(this.marks);

  @override
  void paint(Canvas canvas, Size size) async {
    for (var mark in marks) {
      canvas.drawCircle(
          mark,
          15,
          Paint()
            ..style = PaintingStyle.fill
            // ..strokeWidth = 1.0
            ..color = const Color.fromARGB(100, 76, 175, 79));
      print("Eye Coordinates: $mark");
    }
  }

  @override
  bool shouldRepaint(ResultsPainter oldDelegate) {
    return true;
  }
}
