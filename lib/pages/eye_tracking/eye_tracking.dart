// ignore_for_file: unused_local_variable

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:learning_face_detection/learning_face_detection.dart';
import 'package:learning_input_image/learning_input_image.dart';
import 'package:metatris_game_package/pages/home_page.dart';
import 'package:metatris_game_package/pages/tutorial_pages/tutorial_page11.dart';

List<Offset> eyeCoordinates = [];

Size? originalSize;
InputImageRotation? rotation;

class EyeTracking extends StatefulWidget {
  const EyeTracking({Key? key}) : super(key: key);

  @override
  State<EyeTracking> createState() => _EyeTrackingState();
}

class _EyeTrackingState extends State<EyeTracking> {
  late Offset _leftEyeCenter;

  late Offset _rightEyeCenter;

  late Size _leftEyeSize;

  late Size _rightEyeSize;

  Size? size;

  final FaceDetector _detector = FaceDetector(
    mode: FaceDetectorMode.fast,
    detectLandmark: true,
    detectContour: true,
    enableClassification: true,
    enableTracking: true,
  );

  Future<void> _detectFaces(InputImage image) async {
    originalSize = image.metadata?.size;
    rotation = image.metadata?.rotation;
    List<Face?> faces = await _detector.detect(image);
    for (var face in faces) {
      if (face != null) {
        try {
          _calculateEyePosition(face, size!);
        } catch (e) {
          print(e);
        }
      }
    }
  }

  double transformX(double x, Size size, Size? originalSize) {
    final imageSize = originalSize ?? size;
    switch (rotation) {
      case InputImageRotation.ROTATION_90:
        return x * size.width / imageSize.height;
      case InputImageRotation.ROTATION_270:
        return size.width - x * size.width / imageSize.height;
      default:
        return x * size.width / imageSize.width;
    }
  }

  double transformY(double y, Size size, Size? originalSize) {
    final imageSize = originalSize ?? size;
    switch (rotation) {
      case InputImageRotation.ROTATION_90:
      case InputImageRotation.ROTATION_270:
        return y * size.height / imageSize.width;
      default:
        return y * size.height / imageSize.height;
    }
  }

  void _calculateEyeSizeAndCenter(Face face) {
    for (FaceContourType type in face.countours.keys) {
      FaceContour? contour = face.countours[type];

      if (contour != null) {
        if (type == FaceContourType.LEFT_EYE) {
          final minX = contour.points.map((e) => e.dx).reduce(min);
          final maxX = contour.points.map((e) => e.dx).reduce(max);
          final minY = contour.points.map((e) => e.dy).reduce(min);
          final maxY = contour.points.map((e) => e.dy).reduce(max);

          _leftEyeSize = Size(maxX - minX, maxY - minY);
          _leftEyeCenter = Offset(((minX + maxX) / 2) + 3, (minY + maxY) / 2);
        }
        if (type == FaceContourType.RIGHT_EYE) {
          final minX = contour.points.map((e) => e.dx).reduce(min);
          final maxX = contour.points.map((e) => e.dx).reduce(max);
          final minY = contour.points.map((e) => e.dy).reduce(min);
          final maxY = contour.points.map((e) => e.dy).reduce(max);
          _rightEyeSize = Size(maxX - minX, maxY - minY);
          _rightEyeCenter = Offset(((minX + maxX) / 2) + 3, (minY + maxY) / 2);
        }
      }
    }
  }

  void _calculateEyePosition(Face face, Size size) {
    final List<FaceLandmark?> landmarks = face.landmarks.values.toList();
    final double xLeftEye = landmarks
        .firstWhere((landmark) => landmark!.type == FaceLandmarkType.LEFT_EYE)!
        .point
        .dx;
    final double yLeftEye = landmarks
        .firstWhere((landmark) => landmark!.type == FaceLandmarkType.LEFT_EYE)!
        .point
        .dy;
    // print("leftEye: ($xLeftEye, $yLeftEye)");
    final double xRightEye = landmarks
        .firstWhere((landmark) => landmark!.type == FaceLandmarkType.RIGHT_EYE)!
        .point
        .dx;
    final double yRightEye = landmarks
        .firstWhere((landmark) => landmark!.type == FaceLandmarkType.RIGHT_EYE)!
        .point
        .dy;
    // print("rightEye: ($xRightEye, $yRightEye)");

    // final double eyeDistance = xRightEye - xLeftEye;
    // print("eyeDistance: $eyeDistance");

    // Calculate eye position relative to the screen
    final double xScreen = size.width;
    final double yScreen = size.height;

    _calculateEyeSizeAndCenter(face);

    final double xEye = ((xLeftEye + xRightEye) / 2) +
        ((xLeftEye - _leftEyeCenter.dx) * (xScreen / _leftEyeSize.width)) * 7.5;
    // ((xRightEye - rightEyeCenter.dx) * (xScreen / rightEyeSize.width)) *
    //     4;
    if (max((xLeftEye - _leftEyeCenter.dx), (xRightEye - _rightEyeCenter.dx))
            .abs() ==
        (xLeftEye - _leftEyeCenter.dx).abs()) {
      final double xEye = ((xLeftEye + xRightEye) / 2) +
          ((xLeftEye - _leftEyeCenter.dx) * (xScreen / _leftEyeSize.width)) *
              7.5;
    } else {
      final double xEye = ((xLeftEye + xRightEye) / 2) +
          ((xRightEye - _rightEyeCenter.dx) * (xScreen / _rightEyeSize.width)) *
              7.5;
    }
    final double yEye = ((yLeftEye + yRightEye) / 2) +
        ((yLeftEye - _leftEyeCenter.dy) * (yScreen / _leftEyeSize.height)) * 5;
    // ((yRightEye - rightEyeCenter.dy) * (yScreen / rightEyeSize.height)) *
    //     4;
    if (max((yLeftEye - _leftEyeCenter.dy), (yRightEye - _rightEyeCenter.dy))
            .abs() ==
        (yLeftEye - _leftEyeCenter.dy).abs()) {
      final double yEye = ((yLeftEye + yRightEye) / 2) +
          ((yLeftEye - _leftEyeCenter.dy) * (yScreen / _leftEyeSize.height)) *
              5;
    } else {
      final double yEye = ((yLeftEye + yRightEye) / 2) +
          ((yRightEye - _rightEyeCenter.dy) *
                  (yScreen / _rightEyeSize.height)) *
              5;
    }
    Offset eyeOffset =
        Offset(xEye.floor().toDouble().abs(), yEye.floor().toDouble().abs());
    eyeCoordinates.add(eyeOffset);
    print("X Coordinate: ${eyeOffset.dx}");
    print("Y Coordinate: ${eyeOffset.dy}");
    // for (var eyeCoordinate in eyeCoordinates) {
    //   canvas.drawCircle(
    //       Offset(
    //         transformX(offset.dx, size),
    //         transformY(offset.dy, size),
    //       ),
    //       15,
    //       Paint()
    //         ..style = PaintingStyle.fill
    //         // ..strokeWidth = 1.0
    //         ..color = const Color.fromARGB(107, 33, 149, 243));
    // }
    // final double xRelative = (xEye / xScreen);
    // final double yRelative = (yEye / yScreen);
  }

  @override
  void dispose() {
    _detector.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return !tutorialMode && useEyeTracking
        ? SizedBox(
            width: 0,
            height: 0,
            child: InputCameraView(
              title: 'Face Detection',
              cameraDefault: InputCameraType.front,
              onImage: _detectFaces,
              resolutionPreset: ResolutionPreset.low,
            ),
          )
        : Container();
  }
}
