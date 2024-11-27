// ignore_for_file: body_might_complete_normally_catch_error
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;
import 'package:collection/collection.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import '../blocks/Lblock.dart';
import '../blocks/Iblock.dart';
import '../blocks/alivePoints.dart';
import '../blocks/block.dart';
import '../models/games.dart';
import '../models/sessions.dart';
import 'eye_tracking/eye_tracking.dart';
import 'helper/helper.dart';
import 'helper/language_constants.dart';
import 'tutorial_pages/tutorial_page11.dart';
import '../blocks/Jblock.dart';
import '../blocks/SQblock.dart';
import '../blocks/Sblock.dart';
import '../blocks/Tblock.dart';
import '../blocks/Zblock.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import '../init.dart';
import 'eye_tracking/eye_tracking_results_page.dart';
import 'home_page.dart';
import 'tutorial_pages/tutorial_page12.dart';
import 'package:http/http.dart' as http;

enum LastButtonPressed { left, right, rotateLeft, rotateRight, none }

enum MoveDir { left, right, down }

// Global Variables
const int boardWidth = 10;
const int boardHeight = 20;
double pointSize = 20; // size in px
double width = boardWidth * pointSize;
double height = boardHeight * pointSize;

late Timer timer;
late Timer moveTimer;

Uint8List? screenshotImage;

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  LastButtonPressed performAction = LastButtonPressed.none;
  Block? currentBlock;
  Block? nextBlock;
  List<AlivePoint> alivePoints = [];
  List<Point> alivePointsXY = [];
  int score = 0;
  int tetrises = 0;
  int lines = 0;
  int game = 1;
  int level = 0;
  bool gameOver = false;
  Color? blocksContainerBorderColor;
  double meanHeight = 0;
  int maxHeight = 0;
  int delta_max_height = 0;
  int minHeight = 0;
  int maximum_differences = 0;
  int landing_height = 1;
  double pattern_div = 0;
  int column_transitions = 0;
  int row_transitions = 0;
  double weighted_cells_avg = 0;
  int pits_num = 0;
  int delta_pits = 0;
  double pit_depth = 0;
  double lumped_pits = 0;
  int pit_rows = 0;
  int wells_num = 0;
  int max_well = 0;
  int deep_wells = 0;
  double cumulative_wells = 0;
  int cd_9 = 0;
  int cd_1 = 0;
  int cd_7 = 0;
  int cd_8 = 0;
  int cd_2 = 0;
  int jaggedness = 0;
  double avg_lat = 0;
  double indValue = 0;
  List<Color> indColor = [
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.red,
  ];
  int total_movements = 0;
  int total_rotations = 0;
  int total_translations = 0;
  bool dropDownHolding = false;
  int rotationCenterX = 0;
  int minimumTranslationsDif = 0;
  int minimumRotationsDif = 0;
  List<DateTime> d_timer = [];
  List<int> mainPoints = []; // mainPoints => columns heights
  DateTime drawBlockDate = DateTime.utc(0);
  int gameSpeed = 1000; // speed in milliseconds
  int tempGameSpeed = 1000; // speed in milliseconds
  String startButton = "Start";
  int timestamp = 0;
  late Timer timestampTimer;

  // Tutorial mode variables
  int tutorialModeTime = 30;

  bool enableEyeTracking = false;

  ScreenshotController screenshotController = ScreenshotController();

  List<Session> sessions = [];

  String? resultId; // for research result relationship

  void startGame() {
    setState(() {
      currentBlock = getRandomBlock();
      rotationCenterX = currentBlock!.rotationCenter.x;
      nextBlock = getRandomBlock();
    });
    drawBlockDate = DateTime.now();
    runGameTimer();
    runTimestampTimer();
  }

  void runGameTimer() {
    timer = Timer.periodic(
      Duration(milliseconds: gameSpeed),
      onTimeTick,
    );
  }

  void runTimestampTimer() {
    timestampTimer = Timer.periodic(
      const Duration(seconds: 1),
      (tutorialTimer) {
        setState(
          () => timestamp++,
        );
        if (tutorialMode) {
          if (timestamp > tutorialModeTime) {
            tutorialTimer.cancel();
            timer.cancel();
            // Navigator.of(context).popAndPushNamed(RouteManager.tutorialPage12);
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const TutorialPage12(),
              ),
            );
          }
        }
      },
    );
  }

  void checkForUserInput(Timer? time) {
    if (performAction != LastButtonPressed.none) {
      setState(() {
        switch (performAction) {
          case LastButtonPressed.left:
            currentBlock!.move(MoveDir.left);
            if (isAboveOldBlock(yDistance: 0)) {
              currentBlock!.move(MoveDir.right);
              currentBlock!.movementNum--;
            }
            break;
          case LastButtonPressed.right:
            currentBlock!.move(MoveDir.right);
            if (isAboveOldBlock(yDistance: 0)) {
              currentBlock!.move(MoveDir.left);
              currentBlock!.movementNum--;
            }
            break;
          case LastButtonPressed.rotateLeft:
            currentBlock!.rotateLeft();
            if (isAboveOldBlock(yDistance: 0) ||
                currentBlock!.isAtBottom() ||
                currentBlock!.name == "SQBlock") {
              currentBlock!.rotateRight();
              currentBlock!.movementNum--;
            }
            break;
          case LastButtonPressed.rotateRight:
            currentBlock!.rotateRight();
            if (isAboveOldBlock(yDistance: 0) ||
                currentBlock!.isAtBottom() ||
                currentBlock!.name == "SQBlock") {
              currentBlock!.rotateLeft();
              currentBlock!.movementNum--;
            }
            break;
          default:
            break;
        }
        // performAction = LastButtonPressed.none;
      });
    }
  }

  void saveOldBlock() {
    for (var point in currentBlock!.points) {
      AlivePoint newPoint = AlivePoint(point.x, point.y, currentBlock!.color);
      setState(() {
        alivePoints.add(newPoint);
      });
    }
    for (var point in alivePoints) {
      setState(() {
        alivePointsXY.add(Point(point.x, point.y));
      });
    }
  }

  bool isAboveOldBlock({int yDistance = 1}) {
    bool value = false;
    for (var oldPoint in alivePoints) {
      if (oldPoint.checkIfPointsCollide(currentBlock!.points,
          yDistance: yDistance)) {
        value = true;
      }
    }
    return value;
  }

  void removeRow(int row) {
    setState(() {
      alivePoints.removeWhere((point) => point.y == row);
      for (var point in alivePoints) {
        if (point.y < row) {
          point.y += 1;
        }
      }
      lines++;
      level = (lines / 10).floor();
      levelUp();
    });
  }

  void levelUp() {
    if (lines % 10 == 0 && level < 20) {
      setState(() {
        gameSpeed -= 50; // 1000/boardHeight = 50
        tempGameSpeed -= 50; // 1000/boardHeight = 50
      });
      timer.cancel();
      runGameTimer();
      debugPrint("*" * 20);
      debugPrint("Level: $level");
      debugPrint("*" * 20);
      debugPrint("*" * 20);
      debugPrint("Game Speed: $gameSpeed");
      debugPrint("*" * 20);
    } else if (lines % 10 == 0 && level > 20) {
      setState(() {
        gameSpeed = (gameSpeed * 0.5).round();
        tempGameSpeed = (tempGameSpeed * 0.5).round();
      });
      timer.cancel();
      runGameTimer();
      debugPrint("*" * 20);
      debugPrint("Level: $level");
      debugPrint("*" * 20);
      debugPrint("*" * 20);
      debugPrint("Game Speed: $gameSpeed");
      debugPrint("*" * 20);
    }
  }

  void countTetrisesAndScore() {
    int fullLines = 0;
    for (var currentRow = 0; currentRow < boardHeight; currentRow++) {
      int counter = 0;
      for (var point in alivePoints) {
        if (point.y == currentRow) {
          counter++;
        }
      }
      if (counter >= boardWidth) {
        fullLines++;
      }
    }
    switch (fullLines) {
      case 1:
        setState(() {
          score += 40 * (level + 1);
        });
        break;
      case 2:
        setState(() {
          score += 100 * (level + 1);
        });
        break;
      case 3:
        setState(() {
          score += 300 * (level + 1);
        });
        break;
      case 4:
        setState(() {
          tetrises++;
          score += 1200 * (level + 1);
        });
        break;
      default:
    }
  }

  void removeFullRows() {
    for (var currentRow = 0; currentRow < boardHeight; currentRow++) {
      int counter = 0;
      for (var point in alivePoints) {
        if (point.y == currentRow) {
          counter++;
        }
      }
      if (counter >= boardWidth) {
        removeRow(currentRow);
      }
    }
  }

  void changeIndData() {
    try {
      d_timer.sort();
      List<int> times = [];
      for (var i = 0; i < d_timer.length; i++) {
        times.add(d_timer[i + 1 == d_timer.length ? d_timer.length - 1 : i + 1]
            .difference(d_timer[i])
            .inSeconds);
      }
      debugPrint("key presses time dif: $times");
      avg_lat = times.average;
    } catch (e) {
      avg_lat = 0;
    }
    debugPrint("average_lat: $avg_lat");
    indValue = 5 *
        ((pattern_div * 0.1251132) +
            (meanHeight * 0.05239681) +
            (maxHeight * 0.051240783) +
            (weighted_cells_avg * 0.050453956) +
            (minHeight * 0.050302274) +
            (row_transitions * 0.050216027) +
            (pits_num * 0.046309109) +
            (pit_rows * 0.046244674) +
            (landing_height * 0.045510476) +
            (column_transitions * 0.045442039) +
            (pit_depth * 0.04540702) +
            (lumped_pits * 0.045332779) -
            (cd_9 * 0.044794087) +
            (wells_num * 0.027048065) +
            (deep_wells * 0.026704079) +
            (max_well * 0.026626037) +
            (cumulative_wells * 0.026196003) -
            (currentBlock!.proportion_of_user_drops * 0.024190116) +
            (jaggedness * 0.022607458) +
            (maximum_differences * 0.019303867) +
            (cd_1 * 0.017928321) +
            (currentBlock!.response_latency * 0.015281085) +
            (currentBlock!.rotateNum * 0.012734505) +
            (minimumRotationsDif * 0.012548804) +
            (currentBlock!.drop_latency * 0.012471762) +
            (minimumTranslationsDif * 0.010394636) +
            (avg_lat * 0.010057253) -
            (currentBlock!.matches * 0.00962802) +
            (currentBlock!.translationNum * 0.009460329) +
            (delta_max_height * 0.00673225) -
            (currentBlock!.initial_latency * 0.006052482) +
            (delta_pits * 0.004095821) +
            (cd_7 * 0.000487464) +
            (cd_8 * 0.000467453) +
            (cd_2 * 0.00022092));

    if (indValue > 100) {
      indValue = 100;
    }

    if (indValue < 15) {
      HapticFeedback.lightImpact();
      indColor = [
        Colors.green,
        Colors.yellow,
        Colors.orange,
        Colors.red,
      ];
    } else if (indValue > 30 && indValue < 50) {
      indColor = [
        Colors.yellow,
        Colors.orange,
        Colors.red,
      ];
    } else if (indValue > 50 && indValue < 70) {
      indColor = [
        Colors.orange,
        Colors.red,
      ];
    } else if (indValue > 70 && indValue < 100) {
      indColor = [
        Colors.red,
        Colors.red,
      ];
    }
    debugPrint("indValue: $indValue");
  }

  void drawPattern() {
    // pattern row div
    List<List<int>> pattern = [];
    for (var y = boardHeight - 1; y >= 0; y--) {
      List<int> row = [];
      for (var x = 0; x < boardWidth; x++) {
        if (alivePointsXY.contains(Point(x, y))) {
          row.add(1);
        } else {
          row.add(0);
        }
      }
      pattern.add(row);
    }
    List<int> temp = [];
    for (var y = 0; y < pattern.length; y++) {
      for (int i = 0; i < pattern[y].length; i++) {
        temp.add(pattern[y][i] +
            pattern[y + 1 == pattern.length ? pattern.length - 1 : y + 1][i]);
      }
    }
    row_transitions = temp.where((item) => item == 1).length;

    // pattern column div
    List<List<int>> pattern2 = [];
    for (var x = 0; x < boardWidth; x++) {
      List<int> column = [];
      for (var y = boardHeight - 1; y >= 0; y--) {
        if (alivePointsXY.contains(Point(x, y))) {
          column.add(1);
        } else {
          column.add(0);
        }
      }
      pattern2.add(column);
    }
    List<int> temp2 = [];
    for (var y = 0; y < pattern2.length; y++) {
      for (int i = 0; i < pattern2[y].length; i++) {
        temp2.add(pattern2[y][i] +
            pattern2[y + 1 == pattern2.length ? pattern2.length - 1 : y + 1]
                [i]);
      }
    }
    column_transitions = temp2.where((item) => item == 1).length;

    // weighted_cell
    Map<String, double> weightedCell = {};
    for (var x = 0; x < pattern2.length; x++) {
      weightedCell["column ${x + 1}"] = mainPoints[x] == 0
          ? 0
          : (pattern2[x].where((item) => item == 1).length /
              mainPoints[x]); // mainPoints => columns heights
    }

    weighted_cells_avg = (weightedCell.values.toList()).average;
    debugPrint("weighted_cell (%): $weightedCell");
    pattern_div = (row_transitions + column_transitions) / 2;
    debugPrint("row_transitions: $row_transitions");
    debugPrint("column_transitions: $column_transitions");
  }

  bool isColumnEmpty(List<Point> list, int x, int y) {
    for (var i = 1; i < y; i++) {
      if (list.contains(Point(x, y - i))) {
        return false;
      }
    }
    return true;
  }

  void getPitsAndWells() {
    List<Point> pits = [];
    List<Point> wells = [];
    for (var x = 0; x < boardWidth; x++) {
      for (var y = boardHeight - 1; y >= 0; y--) {
        Point currentPoint = Point(x, y);
        if ((!alivePointsXY.contains(currentPoint)) &&
            (isColumnEmpty(alivePointsXY, x, y)) &&
            (alivePointsXY.contains(Point(x + 1, y)) ||
                alivePointsXY.contains(Point(x - 1, y))) &&
            ((y == boardHeight - 1) ||
                alivePointsXY.contains(Point(x, y + 1)) ||
                wells.contains(Point(x, y + 1)))) {
          wells.add(currentPoint);
        }
      }
    }

    List<double> pitDepthList = [];
    for (var x = 0; x < boardWidth; x++) {
      int pitCounter = 0;
      int pointCounter = 0;
      for (var y = 0; y < boardHeight; y++) {
        Point currentPoint = Point(x, y);
        if ((!alivePointsXY.contains(currentPoint)) &&
            (alivePointsXY.contains(Point(x, y - 1)) ||
                pits.contains(Point(x, y - 1))) &&
            (alivePointsXY.contains(Point(x + 1, y)) ||
                pits.contains(Point(x + 1, y)) ||
                (x == boardWidth - 1) ||
                ((!wells.contains(Point(x + 1, y))) &&
                    !isColumnEmpty(alivePointsXY, x + 1, y))) &&
            (alivePointsXY.contains(Point(x - 1, y)) ||
                pits.contains(Point(x - 1, y)) ||
                (x == 0) ||
                ((!wells.contains(Point(x - 1, y))) &&
                    !isColumnEmpty(alivePointsXY, x - 1, y)))) {
          pits.add(currentPoint);
          pitCounter++;
        }
        if (alivePointsXY.contains(currentPoint)) {
          pointCounter++;
        }
      }
      if (pointCounter == 0) {
        pitDepthList.add(0);
      } else {
        pitDepthList.add((pitCounter / pointCounter) * 1.25);
      }
    }

    pit_depth = pitDepthList.average;

    int pitsGroupCounter = 0;
    for (var i = 0; i < pits.length; i++) {
      num x = pits[i].x;
      num y = pits[i].y;
      if (pits.contains(Point(x + 1, y))) {
        pitsGroupCounter++;
      }
      if (pits.contains(Point(x - 1, y))) {
        pitsGroupCounter++;
      }
      if (pits.contains(Point(x, y + 1))) {
        pitsGroupCounter++;
      }
      if (pits.contains(Point(x, y - 1))) {
        pitsGroupCounter++;
      }
    }
    lumped_pits = 0;
    for (var i = 1; i <= pitsGroupCounter; i++) {
      lumped_pits += (1 / i);
    }

    pit_rows = 0;
    for (var y = boardHeight - 1; y >= 0; y--) {
      for (var x = 0; x < boardWidth; x++) {
        Point currentPoint = Point(x, y);
        if (pits.contains(currentPoint)) {
          pit_rows++;
          break;
        }
      }
    }

    debugPrint("PD" * 22);
    debugPrint(
        "$pit_depth || $pitDepthList || $pitsGroupCounter || $lumped_pits || $pit_rows");
    debugPrint("PD" * 22);

    List<String> wellXTemp = [];
    for (var well in wells) {
      wellXTemp.add("${well.x}");
    }
    List<String> pitsXTemp = [];
    for (var pit in pits) {
      pitsXTemp.add("${pit.x}");
    }
    debugPrint("T" * 22);
    debugPrint(pitsXTemp.toString());
    debugPrint("T" * 22);
    debugPrint("E" * 22);
    debugPrint(wellXTemp.toString());
    debugPrint("E" * 22);
    Map<dynamic, int> wellsMap = {};
    for (var x in wellXTemp) {
      wellsMap[x] = !wellsMap.containsKey(x) ? (1) : (wellsMap[x]! + 1);
    }
    debugPrint("W" * 50);
    debugPrint((wellsMap.values).toList().toString());
    deep_wells = (wellsMap.values).toList().where((item) => item >= 3).length;
    try {
      max_well = (wellsMap.values).toList().reduce(max);
    } catch (e) {
      log(e.toString());
    }
    List<num> cumulativeWellsTemp = [];
    (wellsMap.values).toList().forEach((element) {
      cumulativeWellsTemp.add((pow(element, 2) + element) / 2);
    });
    cumulative_wells = cumulativeWellsTemp.average;
    debugPrint(
        "$max_well || $deep_wells || $cumulative_wells || $cumulativeWellsTemp");
    debugPrint("W" * 50);

    pits_num = pits.length;
    wells_num = wells.length;
    debugPrint("Pits num: $pits_num, Wells num: $wells_num");
  }

  bool playerLost() {
    bool value = false;
    for (var point in alivePoints) {
      if (point.y <= 0) {
        value = true;
      }
    }
    return value;
  }

  void highestPoint() {
    Map<String, List<int>?> pointsY = {
      "1 column": [boardHeight],
      "2 column": [boardHeight],
      "3 column": [boardHeight],
      "4 column": [boardHeight],
      "5 column": [boardHeight],
      "6 column": [boardHeight],
      "7 column": [boardHeight],
      "8 column": [boardHeight],
      "9 column": [boardHeight],
      "10 column": [boardHeight],
    };
    for (var point in alivePoints) {
      switch (point.x) {
        case 0:
          pointsY["1 column"]!.add(point.y);
          break;
        case 1:
          pointsY["2 column"]!.add(point.y);
          break;
        case 2:
          pointsY["3 column"]!.add(point.y);
          break;
        case 3:
          pointsY["4 column"]!.add(point.y);
          break;
        case 4:
          pointsY["5 column"]!.add(point.y);
          break;
        case 5:
          pointsY["6 column"]!.add(point.y);
          break;
        case 6:
          pointsY["7 column"]!.add(point.y);
          break;
        case 7:
          pointsY["8 column"]!.add(point.y);
          break;
        case 8:
          pointsY["9 column"]!.add(point.y);
          break;
        case 9:
          pointsY["10 column"]!.add(point.y);
          break;
        default:
      }
    }
    mainPoints = [];
    for (var i = 1; i <= boardWidth; i++) {
      mainPoints.add(boardHeight - pointsY["$i column"]!.reduce(min));
    }
    Map<String, int> cds = {};
    for (int i = 1; i <= boardWidth; i++) {
      cds["columns $i-${i + 1 > boardWidth ? boardWidth : i + 1}"] =
          (mainPoints[i == boardWidth ? boardWidth - 1 : i] - mainPoints[i - 1])
              .abs();
    }
    cd_9 = cds["columns 9-10"]!;
    cd_1 = cds["columns 1-2"]!;
    cd_7 = cds["columns 7-8"]!;
    cd_8 = cds["columns 8-9"]!;
    cd_2 = cds["columns 2-3"]!;
    debugPrint("Columns dif: $cds");
    meanHeight = mainPoints.average;
    maxHeight = mainPoints.reduce(max);
    minHeight = mainPoints.reduce(min);
    maximum_differences = maxHeight - minHeight;
    // Calculate landing height and matches
    for (var oldPoint in alivePoints) {
      if (oldPoint.checkIfPointsCollide(currentBlock!.points)) {
        landing_height = 20 - oldPoint.y;
      }
    }
    debugPrint(
        "max height: $maxHeight min height: $minHeight mean height: $meanHeight maximum_differences: $maximum_differences landing height: $landing_height matches: ${currentBlock!.matches}");

    // jaggedness
    List<int> temp = [];
    for (var i = 0; i < boardWidth; i++) {
      temp.add(boardHeight - pointsY["${i + 1} column"]!.reduce(min));
    }
    jaggedness = 0;
    for (var i = 0; i < temp.length; i++) {
      jaggedness +=
          (temp[i + 1 == temp.length ? temp.length - 1 : i + 1] - temp[i])
              .abs();
    }
    debugPrint("jaggedness: $jaggedness");
  }

  void changeBorderColorAndSize() {
    if (currentBlock!.movementNum < 5) {
      setState(() {
        blocksContainerBorderColor = Colors.green;
      });
      HapticFeedback.lightImpact();
      debugPrint("vibrate1");
      Future.delayed(const Duration(milliseconds: 200), () {
        HapticFeedback.lightImpact();
        debugPrint("vibrate2");
      });
    } else if (currentBlock!.movementNum < 7) {
      setState(() {
        blocksContainerBorderColor = Colors.green;
      });
    } else if (currentBlock!.movementNum < 13) {
      setState(() {
        blocksContainerBorderColor = Colors.yellowAccent;
      });
    } else {
      setState(() {
        blocksContainerBorderColor = Colors.red.shade900;
      });
    }
  }

  void saveSessionData() {
    final Session session = Session(
      pits: pits_num,
      tetrises: tetrises,
      score: score,
      level: level,
      lines: lines,
      rotations: currentBlock!.rotateNum,
      proportion_of_user_drops: currentBlock!.proportion_of_user_drops,
      minimum_rotation_difference: minimumRotationsDif,
      minimum_translation_difference: minimumTranslationsDif,
      maximum_differences: maximum_differences,
      initial_latency: currentBlock!.initial_latency,
      drop_latency: currentBlock!.drop_latency,
      response_latency: currentBlock!.response_latency,
      max_well: max_well,
      deep_wells: deep_wells,
      cumulative_wells: cumulative_wells,
      column_transitions: column_transitions,
      row_transitions: row_transitions,
      landing_height: landing_height,
      matches: currentBlock!.matches,
      delta_max_height: delta_max_height,
      delta_pits: delta_pits,
      pit_depth: pit_depth,
      lumped_pits: lumped_pits,
      pit_rows: pit_rows,
      max_height: maxHeight,
      min_height: minHeight,
      wells: wells_num,
      avg_lat: avg_lat,
      cd_9: cd_9,
      mean_height: meanHeight,
      pattern_div: pattern_div,
      total_movements: total_movements,
      weighted_cells: weighted_cells_avg,
      jaggedness: jaggedness,
      indicator_value: indValue,
      timestamp: timestamp,
    );

    sessions.add(session);
  }

  Map<String, List<Map<String, int>>> eyeCoordinatesToJson(
      List<Offset> eyeCoordinates) {
    Map<String, List<Map<String, int>>> eyeCoordinatesJSON = {
      "Eye Coordinates": []
    };
    int timestamp = 1;
    for (var eyeCoordinate in eyeCoordinates) {
      eyeCoordinatesJSON["Eye Coordinates"]!.add({
        "X": eyeCoordinate.dx.toInt(),
        "Y": eyeCoordinate.dy.toInt(),
        "Timestamp": timestamp,
      });
      if (eyeCoordinatesJSON["Eye Coordinates"]!.length % 30 == 0) {
        timestamp++;
      }
    }
    return eyeCoordinatesJSON;
  }

  Future<File> writeEyeTrackingCsvFile(List<Map<String, int>> points) async {
    List<List<dynamic>> rows = [];

    List<dynamic> mainRow = [];
    mainRow.add("X");
    mainRow.add("Y");
    mainRow.add("Timestamp");
    mainRow.add("\n");
    rows.add(mainRow);

    for (var point in points) {
      List<dynamic> row = [];
      row.add(point["X"]);
      row.add(point["Y"]);
      row.add(point["Timestamp"]);
      row.add("\n");
      rows.add(row);
    }

    String csv = const ListToCsvConverter().convert(rows);

    Directory appCacheDirectory = await getApplicationCacheDirectory();

    File file = File("${appCacheDirectory.path}/eye_tracking_data.csv");

    file.writeAsStringSync(csv);

    return file;
  }

  void sendGameData() async {
    try {
      if (resultId == null) {
        var uri = Uri.parse('${kBaseUrl}results/bulk');
        var request = http.MultipartRequest('POST', uri);

        // Add authorization header
        request.headers['Authorization'] = 'Bearer $token';

        // Prepare the request body
        var requestBody = {
          "research": researchId,
        };

        // Convert the request body to JSON and add it to the request
        var jsonBody = json.encode(requestBody);
        request.fields['data'] = jsonBody;

        log(request.fields.toString());

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        log(response.body);
        var responseBody = json.decode(response.body);
        if (response.statusCode == 200) {
          resultId = responseBody["documentId"];
        } else {
          log("Error! ${responseBody["error"]["message"]} || Status Code: ${response.statusCode}");
        }
      }

      if (resultId != null) {
        File? eyeTrackingFile;
        if (useEyeTracking) {
          Map<String, List<Map<String, int>>> eyeCoordinatesJSON =
              eyeCoordinatesToJson(eyeCoordinates);

          eyeTrackingFile = await writeEyeTrackingCsvFile(
              eyeCoordinatesJSON["Eye Coordinates"]!);
        }

        final Game gameData = Game(
          game: game,
          resultId: resultId,
          sessions: sessions,
          eyeTrackingData: eyeTrackingFile,
        );

        var headers = {'Authorization': 'Bearer $token'};
        var request =
            http.MultipartRequest('POST', Uri.parse('${kBaseUrl}metatrises'));
        request.fields.addAll({'data': json.encode(gameData.toJson())});

        if (gameData.eyeTrackingData != null) {
          request.files.add(await http.MultipartFile.fromPath(
              'eyeTracking', gameData.eyeTrackingData!.path));
        }
        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();

        var responseBody = json.decode(await response.stream.bytesToString());
        log(responseBody.toString());
        if (response.statusCode == 200 || response.statusCode == 201) {
          log("Session Created Successfully");
        } else {
          log("Error! ${responseBody["error"]["message"]} || Status Code: ${response.statusCode}");
        }
        if (eyeTrackingFile != null) {
          eyeTrackingFile.delete();
        }
      }
    } catch (e) {
      log(e.toString());
    }
  }

  void calcTransitions() {
    total_rotations += currentBlock!.rotateNum;
    total_movements += currentBlock!.movementNum;
    total_translations += total_movements - total_rotations;
    currentBlock!.translationNum =
        currentBlock!.movementNum - currentBlock!.rotateNum;
    if (dropDownHolding) {
      currentBlock!.onDropDownY2 = currentBlock!.rotationCenter.y;
      currentBlock!.proportion_of_user_drops =
          ((currentBlock!.onDropDownY1 - currentBlock!.onDropDownY2) /
                  boardHeight)
              .abs();
      debugPrint("*" * 20);
      debugPrint(
          "${currentBlock!.onDropDownY1} || ${currentBlock!.onDropDownY2} || ${currentBlock!.rotateNum} || ${currentBlock!.translationNum} || ${currentBlock!.proportion_of_user_drops}");
      debugPrint("*" * 20);
    } else {
      currentBlock!.proportion_of_user_drops =
          ((currentBlock!.onDropDownY1 - currentBlock!.onDropDownY2) /
                  boardHeight)
              .abs();
      debugPrint("*" * 20);
      debugPrint(
          "${currentBlock!.onDropDownY1} || ${currentBlock!.onDropDownY2} || ${currentBlock!.rotateNum} || ${currentBlock!.translationNum} || ${currentBlock!.proportion_of_user_drops}");
      debugPrint("*" * 20);
    }
  }

  void calcMinTransDif() {
    int optimalTranslations =
        (rotationCenterX - currentBlock!.rotationCenter.x).abs();
    minimumTranslationsDif =
        (currentBlock!.translationNum - optimalTranslations).abs();
    debugPrint("=" * 20);
    debugPrint(
        "$minimumTranslationsDif || $rotationCenterX || ${currentBlock!.rotationCenter.x} || $optimalTranslations");
    debugPrint("=" * 20);
  }

  void calcMinRotationsDif() {
    if (currentBlock!.name == "IBlock" ||
        currentBlock!.name == "SBlock" ||
        currentBlock!.name == "ZBlock") {
      if (currentBlock!.rotateNum % 2 == 0) {
        minimumRotationsDif = currentBlock!.rotateNum;
      } else {
        minimumRotationsDif = currentBlock!.rotateNum - 1;
      }
    } else if (currentBlock!.name != "SQBlock") {
      int rNum = 0;
      int lNum = 0;
      for (var i = 0; i < currentBlock!.rotatePattern.length; i++) {
        if (currentBlock!.rotatePattern[i] == "R") {
          rNum++;
        } else {
          lNum++;
        }
      }
      minimumRotationsDif =
          currentBlock!.rotateNum - (((rNum - lNum).abs()) % 4);
    }
    debugPrint("/" * 20);
    debugPrint("$minimumRotationsDif");
    debugPrint("/" * 20);
  }

  void calcInitialLat() {
    if (currentBlock!.movementNum == 0 && currentBlock!.dropDownCounter == 0) {
      currentBlock!.initial_latency =
          DateTime.now().difference(drawBlockDate).inSeconds;
    }
  }

  // Calculate matches
  void calcMatches() {
    for (var point in currentBlock!.points) {
      if (alivePointsXY.contains(Point(point.x - 1, point.y))) {
        currentBlock!.matches++;
      }
      if (alivePointsXY.contains(Point(point.x + 1, point.y))) {
        currentBlock!.matches++;
      }
      if (alivePointsXY.contains(Point(point.x, point.y + 1))) {
        currentBlock!.matches++;
      }
    }
  }

  void onTimeTick(Timer time) async {
    if (currentBlock == null || gameOver) return;

    if (playerLost()) {
      setState(() {
        enableEyeTracking = false;
      });

      time.cancel();
      timestampTimer.cancel();

      if (useEyeTracking) {
        screenshotController.capture().then((Uint8List? image) {
          //Capture Done
          setState(() {
            screenshotImage = image;
            gameOver = true;
          });
        }).catchError((onError) {
          log(onError);
        });
      } else {
        setState(() {
          gameOver = true;
        });
      }

      // save game data
      if (!tutorialMode && integrationInitialized) {
        sendGameData();
      }
    }
    // Check if the current block is at the bottom or above an old block
    if (currentBlock!.isAtBottom() || isAboveOldBlock()) {
      if (showIndicator) {
        changeBorderColorAndSize();
      }

      // check if still holding drop down
      if (dropDownHolding) {
        _onDropDownHoldingCancel();
      }

      // Calculate matches
      calcMatches();
      // Save the block
      saveOldBlock();
      // Remove full rows
      int maxHeightTemp = maxHeight;
      int pitsNumTemp = pits_num;
      countTetrisesAndScore();
      removeFullRows();
      // calculate data
      highestPoint();
      delta_max_height = (maxHeightTemp - maxHeight).abs();
      debugPrint("Q" * 30);
      debugPrint("$delta_max_height");
      debugPrint("Q" * 30);
      getPitsAndWells();
      delta_pits = (pitsNumTemp - pits_num).abs();
      debugPrint("DP" * 30);
      debugPrint("$delta_pits");
      debugPrint("DP" * 30);
      drawPattern();
      calcTransitions();
      calcMinTransDif();
      calcMinRotationsDif();
      if (currentBlock!.movementNum == 0 &&
          currentBlock!.rotateNum == 0 &&
          currentBlock!.proportion_of_user_drops == 0) {
        currentBlock!.response_latency =
            DateTime.now().difference(drawBlockDate).inSeconds;
      }
      debugPrint("|" * 20);
      debugPrint(
          "${currentBlock!.response_latency} | ${currentBlock!.drop_latency} | ${currentBlock!.initial_latency}");
      debugPrint("|" * 20);

      changeIndData();

      // save session data
      if (!tutorialMode && integrationInitialized) {
        saveSessionData();
      }

      // Draw new block
      setState(() {
        currentBlock = nextBlock;
        rotationCenterX = currentBlock!.rotationCenter.x;
        nextBlock = getRandomBlock();
      });
      drawBlockDate = DateTime.now();
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          blocksContainerBorderColor = Colors.white;
        });
      });
    } else {
      setState(() {
        currentBlock!.move(MoveDir.down);
      });
      // checkForUserInput();
    }
  }

  Widget? drawTetrisBlocks() {
    if (currentBlock == null) return null;

    List<Positioned> visiblePoints = [];

    // Current Block
    for (var point in currentBlock!.points) {
      Positioned newPoint = Positioned(
        left: point.x * pointSize,
        top: point.y * pointSize,
        child: getTetrisPoint(currentBlock!.color),
      );
      visiblePoints.add(newPoint);
    }

    // Old Blocks
    for (var point in alivePoints) {
      Positioned newPoint = Positioned(
        left: point.x * pointSize,
        top: point.y * pointSize,
        child: getTetrisPoint(point.color),
      );
      visiblePoints.add(newPoint);
    }
    return Stack(
      alignment: Alignment.center,
      children: visiblePoints,
    );
  }

  Widget? drawNextBlocks() {
    if (nextBlock == null) return null;

    List<Positioned> visiblePoints = [];

    Block? nextBlockDisplay;
    const int nextBlockDisplayWidth = 5;

    switch (nextBlock!.name) {
      case "IBlock":
        nextBlockDisplay = IBlock(nextBlockDisplayWidth);
        break;
      case "JBlock":
        nextBlockDisplay = JBlock(nextBlockDisplayWidth);
        break;
      case "LBlock":
        nextBlockDisplay = LBlock(nextBlockDisplayWidth);
        break;
      case "SBlock":
        nextBlockDisplay = SBlock(nextBlockDisplayWidth);
        break;
      case "SQBlock":
        nextBlockDisplay = SQBlock(nextBlockDisplayWidth);
        break;
      case "TBlock":
        nextBlockDisplay = TBlock(nextBlockDisplayWidth);
        break;
      case "ZBlock":
        nextBlockDisplay = ZBlock(nextBlockDisplayWidth);
        break;
      default:
    }

    for (var point in nextBlockDisplay!.points) {
      Positioned newPoint = Positioned(
        left: (point.x < 0 || point.y > 0)
            ? (point.x + 1) * pointSize
            : point.x * pointSize,
        top: (point.y < 0 || point.x > 0)
            ? (point.y + 1) * pointSize
            : point.y * pointSize,
        child: getTetrisPoint(nextBlock!.color),
      );
      visiblePoints.add(newPoint);
    }
    return Stack(
      children: visiblePoints,
    );
  }

  void resetSomeVariables() {
    // reset some values
    gameOver = false;
    score = 0;
    lines = 0;
    tetrises = 0;
    level = 0;
    indValue = 0;
    gameSpeed = 1000; // speed in milliseconds
    tempGameSpeed = 1000; // speed in milliseconds
    if (!tutorialMode) {
      timestamp = 0;
    }
    indColor = [
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.red,
    ];

    eyeCoordinates.clear();
    if (useEyeTracking) {
      enableEyeTracking = true;
    }

    sessions.clear();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    // double screenWidth = size.width;
    double screenHeight = size.height;

    height = (screenHeight * 0.55).spMin;
    pointSize = (height / boardHeight);
    width = (pointSize * boardWidth);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          try {
            timer.cancel();
            timestampTimer.cancel();
            setState(() {
              enableEyeTracking = false;
              eyeCoordinates.clear();
            });
          } catch (e) {
            log("$e");
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
            ),
            onPressed: () {
              try {
                timer.cancel();
                timestampTimer.cancel();
                setState(() {
                  enableEyeTracking = false;
                  eyeCoordinates.clear();
                });
              } catch (e) {
                log("$e");
              }
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
        body: Screenshot(
          controller: screenshotController,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (tutorialMode)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "${tutorialModeTime - timestamp < 0 ? 0 : tutorialModeTime - timestamp}",
                    style: TextStyle(
                      color: tutorialModeTime - timestamp <= 10
                          ? Colors.red
                          : Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (showScore)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "${translation(context).score} $score",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.spMin,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (showScore)
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "${translation(context).tetrises}\n$tetrises",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            height: 30.spMin,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "${translation(context).lines}\n$lines",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            height: 30.spMin,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "${translation(context).level}\n$level",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            height: 30.spMin,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "${translation(context).games}\n$game",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: blocksContainerBorderColor ?? Colors.white,
                              width: 3),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(1),
                          width: width,
                          height: height,
                          child: gameOver
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    getGameOverText(score, context),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        resetSomeVariables();
                                        setState(() {
                                          game++;
                                          alivePoints
                                              .removeWhere((element) => true);
                                        });
                                        timer.cancel();
                                        timestampTimer.cancel();
                                        startGame();
                                      },
                                      child: Text(
                                        translation(context).tryAgain,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    !tutorialMode && useEyeTracking
                                        ? OutlinedButton(
                                            onPressed: () {
                                              // Navigator.of(context)
                                              //     .pushNamed(RouteManager
                                              //         .eyeTrackingPage);
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const EyeTrackingResultsPage(),
                                                ),
                                              );
                                            },
                                            style: OutlinedButton.styleFrom(
                                              shape:
                                                  const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5)),
                                              ),
                                              side: BorderSide(
                                                  color:
                                                      integrationInitialized &&
                                                              primaryColor !=
                                                                  null
                                                          ? primaryColor!
                                                          : Colors.blue),
                                            ),
                                            child: Text(
                                              translation(context)
                                                  .viewEyeTrackingResults,
                                              style:
                                                  const TextStyle(fontSize: 10),
                                            ),
                                          )
                                        : Container(),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    OutlinedButton(
                                      onPressed: () {
                                        try {
                                          timer.cancel();
                                          timestampTimer.cancel();
                                          setState(() {
                                            enableEyeTracking = false;
                                            eyeCoordinates.clear();
                                          });
                                        } catch (e) {
                                          log("$e");
                                        }
                                        Navigator.pop(context);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                        ),
                                        side: BorderSide(
                                            color: integrationInitialized &&
                                                    primaryColor != null
                                                ? primaryColor!
                                                : Colors.blue),
                                      ),
                                      child: Text(
                                        translation(context).exit,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    )
                                  ],
                                )
                              : drawTetrisBlocks(),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          // width: screenWidth / 5,
                          // height: 150,
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            border: Border.all(color: Colors.transparent),
                          ),
                          child: Column(children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    translation(context).nextBlock,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              width: (pointSize * 4),
                              height: (pointSize * 3),
                              child: gameOver ? Container() : drawNextBlocks(),
                            ),
                          ]),
                        ),
                        SizedBox(
                          height: 30.spMin,
                        ),
                        if (showIndicator)
                          SizedBox(
                            // width: screenWidth / 5,
                            height: 200.spMin,
                            child: Center(
                              // child: RotatedBox(
                              //   quarterTurns: -1,
                              child: StepProgressIndicator(
                                direction: Axis.vertical,
                                totalSteps: 100,
                                currentStep: indValue.round(),
                                size: 30,
                                padding: 0,
                                // selectedColor: Colors.yellow,
                                // unselectedColor: Colors.cyan,
                                roundedEdges: const Radius.circular(10),
                                selectedGradientColor: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Colors.grey, Colors.transparent],
                                ),
                                unselectedGradientColor: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: indColor,
                                ),
                              ),
                            ),
                          ),
                        SizedBox(height: 20.spMin),
                      ],
                    ),
                  ],
                ),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.all(8.0).copyWith(left: 0),
                              child: GestureDetector(
                                onTapDown: (details) {
                                  if (startButton == "Stop") {
                                    performAction = LastButtonPressed.left;
                                    d_timer.add(DateTime.now());
                                    calcInitialLat();
                                    moveTimer = Timer.periodic(
                                      const Duration(milliseconds: 50),
                                      checkForUserInput,
                                    );
                                  }
                                },
                                onTapCancel: () {
                                  moveTimer.cancel();
                                  performAction = LastButtonPressed.none;
                                },
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (startButton == "Stop") {
                                      d_timer.add(DateTime.now());
                                      calcInitialLat();
                                      setState(() {
                                        performAction = LastButtonPressed.left;
                                        checkForUserInput(null);
                                        performAction = LastButtonPressed.none;
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      minimumSize: Size(65.spMin, 45.spMin)),
                                  child: const Icon(
                                    Icons.arrow_left,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTapDown: (details) {
                                  if (startButton == "Stop") {
                                    performAction = LastButtonPressed.right;
                                    d_timer.add(DateTime.now());
                                    calcInitialLat();
                                    moveTimer = Timer.periodic(
                                      const Duration(milliseconds: 50),
                                      checkForUserInput,
                                    );
                                  }
                                },
                                onTapCancel: () {
                                  moveTimer.cancel();
                                  performAction = LastButtonPressed.none;
                                },
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (startButton == "Stop") {
                                      d_timer.add(DateTime.now());
                                      calcInitialLat();
                                      setState(() {
                                        performAction = LastButtonPressed.right;
                                        checkForUserInput(null);
                                        performAction = LastButtonPressed.none;
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      minimumSize: Size(65.spMin, 45.spMin)),
                                  child: const Icon(
                                    Icons.arrow_right,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTapDown: (details) {
                              if (startButton == "Stop") {
                                setState(() {
                                  tempGameSpeed = gameSpeed;
                                  timer.cancel();
                                  gameSpeed = 50;
                                  runGameTimer();
                                });
                                dropDownHolding = true;
                                currentBlock!.onDropDownY1 =
                                    currentBlock!.rotationCenter.y;
                                d_timer.add(DateTime.now());
                                calcInitialLat();
                                currentBlock!.dropDownCounter++;
                                if (currentBlock!.dropDownCounter == 1) {
                                  currentBlock!.drop_latency = DateTime.now()
                                      .difference(drawBlockDate)
                                      .inSeconds;
                                }
                              }
                            },
                            onTapCancel: dropDownHolding
                                ? () => _onDropDownHoldingCancel()
                                : null,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                  minimumSize: Size(65.spMin, 45.spMin)),
                              child: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (startButton == "Stop") {
                              startButton = "Start";
                              timer.cancel();
                              timestampTimer.cancel();
                              setState(() {
                                enableEyeTracking = false;
                              });
                            } else {
                              startButton = "Stop";
                              if (currentBlock == null) {
                                startGame();
                              } else {
                                runGameTimer();
                                runTimestampTimer();
                              }
                              // Start eye tracking
                              if (!gameOver && useEyeTracking) {
                                setState(() {
                                  enableEyeTracking = true;
                                });
                              }
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: Colors.red,
                          minimumSize: Size(70.spMin, 70.spMin),
                        ),
                        child: Text(
                          startButton == "Start"
                              ? translation(context).start
                              : translation(context).stop,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              if (startButton == "Stop") {
                                d_timer.add(DateTime.now());
                                calcInitialLat();
                                setState(() {
                                  performAction = LastButtonPressed.rotateLeft;
                                  checkForUserInput(null);
                                  performAction = LastButtonPressed.none;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                minimumSize: Size(65.spMin, 45.spMin)),
                            child: const Icon(
                              Icons.rotate_left,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0).copyWith(right: 0),
                          child: ElevatedButton(
                            onPressed: () {
                              if (startButton == "Stop") {
                                d_timer.add(DateTime.now());
                                calcInitialLat();
                                setState(() {
                                  performAction = LastButtonPressed.rotateRight;
                                  checkForUserInput(null);
                                  performAction = LastButtonPressed.none;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                minimumSize: Size(65.spMin, 45.spMin)),
                            child: const Icon(
                              Icons.rotate_right,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (enableEyeTracking) const EyeTracking(),
            ],
          ),
        ),
      ),
    );
  }

  void _onDropDownHoldingCancel() {
    if (startButton == "Stop") {
      setState(() {
        debugPrint("GameSpeed: $gameSpeed // tempGameSpeed: $tempGameSpeed");
        timer.cancel();
        gameSpeed = tempGameSpeed;
        runGameTimer();
      });
      dropDownHolding = false;
      currentBlock!.onDropDownY2 = currentBlock!.rotationCenter.y;
    }
  }
}
