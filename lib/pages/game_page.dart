// ignore_for_file: body_might_complete_normally_catch_error
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:backendless_sdk/backendless_sdk.dart' as bkl;
import 'package:collection/collection.dart';
import 'package:csv/csv.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:metatris_game_package/blocks/Iblock.dart';
import 'package:metatris_game_package/blocks/Lblock.dart';
import 'package:metatris_game_package/blocks/alivePoints.dart';
import 'package:metatris_game_package/blocks/block.dart';
import 'package:metatris_game_package/models/eye_tracking_data.dart';
import 'package:metatris_game_package/models/games.dart';
import 'package:metatris_game_package/models/sessions.dart';
import 'package:metatris_game_package/pages/eye_tracking/eye_tracking.dart';
import 'package:metatris_game_package/pages/helper/helper.dart';
import 'package:metatris_game_package/pages/helper/language_constants.dart';
import 'package:metatris_game_package/pages/tutorial_pages/tutorial_page11.dart';
import 'package:metatris_game_package/routes/routes.dart';

import '../blocks/Jblock.dart';
import '../blocks/SQblock.dart';
import '../blocks/Sblock.dart';
import '../blocks/Tblock.dart';
import '../blocks/Zblock.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import 'home_page.dart';

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
  const GamePage({Key? key}) : super(key: key);

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
  Map<String, List<double>> averages = {
    "pits": [],
    "rotations": [],
    "proportion_of_user_drops": [],
    "minimum_rotation_difference": [],
    "minimum_translation_difference": [],
    "maximum_differences": [],
    "initial_latency": [],
    "drop_latency": [],
    "response_latency": [],
    "max_well": [],
    "deep_wells": [],
    "cumulative_wells": [],
    "column_transitions": [],
    "row_transitions": [],
    "landing_height": [],
    "matches": [],
    "delta_max_height": [],
    "delta_pits": [],
    "pit_depth": [],
    "lumped_pits": [],
    "pit_rows": [],
    "max_height": [],
    "min_height": [],
    "wells": [],
    "avg_lat": [],
    "cd_9": [],
    "mean_height": [],
    "pattern_div": [],
    "total_movements": [],
    "weighted_cells": [],
    "jaggedness": [],
    "indicator_value": [],
  };

  // Tutorial mode variables
  int tutorialModeTime = 30;

  bool enableEyeTracking = false;

  ScreenshotController screenshotController = ScreenshotController();

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
            Navigator.of(context).popAndPushNamed(RouteManager.tutorialPage12);
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
            if (isAboveOldBlock(Ydistance: 0)) {
              currentBlock!.move(MoveDir.right);
              currentBlock!.movementNum--;
            }
            break;
          case LastButtonPressed.right:
            currentBlock!.move(MoveDir.right);
            if (isAboveOldBlock(Ydistance: 0)) {
              currentBlock!.move(MoveDir.left);
              currentBlock!.movementNum--;
            }
            break;
          case LastButtonPressed.rotateLeft:
            currentBlock!.rotateLeft();
            if (isAboveOldBlock(Ydistance: 0) ||
                currentBlock!.isAtBottom() ||
                currentBlock!.name == "SQBlock") {
              currentBlock!.rotateRight();
              currentBlock!.movementNum--;
            }
            break;
          case LastButtonPressed.rotateRight:
            currentBlock!.rotateRight();
            if (isAboveOldBlock(Ydistance: 0) ||
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

  bool isAboveOldBlock({int Ydistance = 1}) {
    bool value = false;
    for (var oldPoint in alivePoints) {
      if (oldPoint.checkIfPointsCollide(currentBlock!.points,
          Ydistance: Ydistance)) {
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
      print("*" * 20);
      print("Level: $level");
      print("*" * 20);
      print("*" * 20);
      print("Game Speed: $gameSpeed");
      print("*" * 20);
    } else if (lines % 10 == 0 && level > 20) {
      setState(() {
        gameSpeed = (gameSpeed * 0.5).round();
        tempGameSpeed = (tempGameSpeed * 0.5).round();
      });
      timer.cancel();
      runGameTimer();
      print("*" * 20);
      print("Level: $level");
      print("*" * 20);
      print("*" * 20);
      print("Game Speed: $gameSpeed");
      print("*" * 20);
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
      print("key presses time dif: $times");
      avg_lat = times.average;
    } catch (e) {
      avg_lat = 0;
    }
    print("average_lat: $avg_lat");
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
    print("indValue: $indValue");
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
    print("weighted_cell (%): $weightedCell");
    pattern_div = (row_transitions + column_transitions) / 2;
    print("row_transitions: $row_transitions");
    print("column_transitions: $column_transitions");
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

    // TODO: Not work
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

    print("PD" * 22);
    print(
        "$pit_depth || $pitDepthList || $pitsGroupCounter || $lumped_pits || $pit_rows");
    print("PD" * 22);

    List<String> wellXTemp = [];
    for (var well in wells) {
      wellXTemp.add("${well.x}");
    }
    List<String> pitsXTemp = [];
    for (var pit in pits) {
      pitsXTemp.add("${pit.x}");
    }
    print("T" * 22);
    print(pitsXTemp);
    print("T" * 22);
    print("E" * 22);
    print(wellXTemp);
    print("E" * 22);
    Map<dynamic, int> wellsMap = {};
    for (var x in wellXTemp) {
      wellsMap[x] = !wellsMap.containsKey(x) ? (1) : (wellsMap[x]! + 1);
    }
    print("W" * 50);
    print((wellsMap.values).toList());
    deep_wells = (wellsMap.values).toList().where((item) => item >= 3).length;
    try {
      max_well = (wellsMap.values).toList().reduce(max);
    } catch (e) {
      print(e);
    }
    List<num> cumulativeWellsTemp = [];
    (wellsMap.values).toList().forEach((element) {
      cumulativeWellsTemp.add((pow(element, 2) + element) / 2);
    });
    cumulative_wells = cumulativeWellsTemp.average;
    print(
        "$max_well || $deep_wells || $cumulative_wells || $cumulativeWellsTemp");
    print("W" * 50);

    pits_num = pits.length;
    wells_num = wells.length;
    print("Pits num: $pits_num, Wells num: $wells_num");
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
    Map<String, int> Cds = {};
    for (int i = 1; i <= boardWidth; i++) {
      Cds["columns $i-${i + 1 > boardWidth ? boardWidth : i + 1}"] =
          (mainPoints[i == boardWidth ? boardWidth - 1 : i] - mainPoints[i - 1])
              .abs();
    }
    cd_9 = Cds["columns 9-10"]!;
    cd_1 = Cds["columns 1-2"]!;
    cd_7 = Cds["columns 7-8"]!;
    cd_8 = Cds["columns 8-9"]!;
    cd_2 = Cds["columns 2-3"]!;
    print("Columns dif: $Cds");
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
    print(
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
    print("jaggedness: $jaggedness");
  }

  void changeBorderColorAndSize() {
    if (currentBlock!.movementNum < 5) {
      setState(() {
        blocksContainerBorderColor = Colors.green;
      });
      HapticFeedback.lightImpact();
      print("vibrate1");
      Future.delayed(const Duration(milliseconds: 200), () {
        HapticFeedback.lightImpact();
        print("vibrate2");
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

  void fillAveragesMap() {
    averages["pits"]!.add(pits_num.toDouble());
    averages["rotations"]!.add(currentBlock!.rotateNum.toDouble());
    averages["proportion_of_user_drops"]!
        .add(currentBlock!.proportion_of_user_drops);
    averages["minimum_rotation_difference"]!
        .add(minimumRotationsDif.toDouble());
    averages["minimum_translation_difference"]!
        .add(minimumTranslationsDif.toDouble());
    averages["maximum_differences"]!.add(maximum_differences.toDouble());
    averages["initial_latency"]!.add(currentBlock!.initial_latency.toDouble());
    averages["drop_latency"]!.add(currentBlock!.drop_latency.toDouble());
    averages["response_latency"]!
        .add(currentBlock!.response_latency.toDouble());
    averages["max_well"]!.add(max_well.toDouble());
    averages["deep_wells"]!.add(deep_wells.toDouble());
    averages["cumulative_wells"]!.add(cumulative_wells);
    averages["column_transitions"]!.add(column_transitions.toDouble());
    averages["row_transitions"]!.add(row_transitions.toDouble());
    averages["landing_height"]!.add(landing_height.toDouble());
    averages["matches"]!.add(currentBlock!.matches.toDouble());
    averages["delta_max_height"]!.add(delta_max_height.toDouble());
    averages["delta_pits"]!.add(delta_pits.toDouble());
    averages["pit_depth"]!.add(pit_depth);
    averages["lumped_pits"]!.add(lumped_pits);
    averages["pit_rows"]!.add(pit_rows.toDouble());
    averages["max_height"]!.add(maxHeight.toDouble());
    averages["min_height"]!.add(minHeight.toDouble());
    averages["wells"]!.add(wells_num.toDouble());
    averages["avg_lat"]!.add(avg_lat);
    averages["cd_9"]!.add(cd_9.toDouble());
    averages["mean_height"]!.add(meanHeight);
    averages["pattern_div"]!.add(pattern_div);
    averages["total_movements"]!.add(total_movements.toDouble());
    averages["weighted_cells"]!.add(weighted_cells_avg);
    averages["jaggedness"]!.add(jaggedness.toDouble());
    averages["indicator_value"]!.add(indValue);
  }

  void sendSessionData() async {
    await bkl.Backendless.data
        .of("TetrisSessions")
        .save(TetrisSessions(
          pits: pits_num,
          tetrises: tetrises,
          score: score,
          level: level,
          lines: lines,
          game: game,
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
          assigned_username: usernameInput.text,
        ).toJson())
        .catchError((error, stackTrace) {
      print("Error: ${error.toString()}");
      // showSnackBar(context, "Server Error: ${error.toString()}");
    });
    // showSnackBar(context, "Session created!");
  }

  Map<String, List<Map<String, int>>> eyeCoordinatesToJson(eyeCoordinates) {
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

  Future<String?> writeAndUploadEyeTrackingCsvFile(
      List<Map<String, int>> points) async {
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

    Directory appDocDirectory = await getApplicationDocumentsDirectory();

    File f = File(appDocDirectory.path +
        "/eye_tracking_data_${usernameInput.text}_${DateTime.now().toString().replaceAll(" ", "_").replaceAll(":", "-")}.csv");

    f.writeAsStringSync(csv);

    String? fileUrl;
    try {
      fileUrl =
          await bkl.Backendless.files.upload(f, "Tetris/eye_tracking_data");
    } catch (e) {
      fileUrl = "";
      print(e);
    }

    f.delete();

    return fileUrl;
  }

  Future<String?> uploadEyeTrackingData() async {
    String? eyeTrackingObjId;
    if (useEyeTracking) {
      Map<String, List<Map<String, int>>> eyeCoordinatesJSON =
          eyeCoordinatesToJson(eyeCoordinates);

      String? fileReference = await writeAndUploadEyeTrackingCsvFile(
          eyeCoordinatesJSON["Eye Coordinates"]!);

      Map<dynamic, dynamic>? eyeTrackingObjJson;

      try {
        eyeTrackingObjJson = await bkl.Backendless.data
            .of("TetrisEyeTrackingData")
            .save(TetrisEyeTrackingData(
                    eye_tracking_data_csv_file: fileReference!,
                    assigned_username: usernameInput.text)
                .toJson())
            .catchError((error, stackTrace) {
          print("Error: ${error.toString()}");
          // showSnackBar(context, "Server Error: ${error.toString()}");
        });
      } catch (e) {
        print(e);
      }

      eyeTrackingObjId =
          eyeTrackingObjJson == null ? null : eyeTrackingObjJson["objectId"];
    }
    return eyeTrackingObjId;
  }

  void sendAverages() async {
    String? eyeTrackingObjId = await uploadEyeTrackingData();

    Map<dynamic, dynamic>? tetrisGamesObjJson = await bkl.Backendless.data
        .of("TetrisGames")
        .save(TetrisGames(
          avg_pits: averages["pits"]!.average,
          total_tetrises: tetrises,
          final_score: score,
          level_reached: level,
          total_lines_cleared: lines,
          game: game,
          avg_rotations: averages["rotations"]!.average,
          avg_proportion_of_user_drops:
              averages["proportion_of_user_drops"]!.average,
          avg_minimum_rotation_difference:
              averages["minimum_rotation_difference"]!.average,
          avg_minimum_translation_difference:
              averages["minimum_translation_difference"]!.average,
          avg_maximum_differences: averages["maximum_differences"]!.average,
          avg_initial_latency: averages["initial_latency"]!.average,
          avg_drop_latency: averages["drop_latency"]!.average,
          avg_response_latency: averages["response_latency"]!.average,
          avg_max_well: averages["max_well"]!.average,
          avg_deep_wells: averages["deep_wells"]!.average,
          avg_cumulative_wells: averages["cumulative_wells"]!.average,
          avg_column_transitions: averages["column_transitions"]!.average,
          avg_row_transitions: averages["row_transitions"]!.average,
          avg_landing_height: averages["landing_height"]!.average,
          avg_matches: averages["matches"]!.average,
          avg_delta_max_height: averages["delta_max_height"]!.average,
          avg_delta_pits: averages["delta_pits"]!.average,
          avg_pit_depth: averages["pit_depth"]!.average,
          avg_lumped_pits: averages["lumped_pits"]!.average,
          avg_pit_rows: averages["pit_rows"]!.average,
          avg_max_height: averages["max_height"]!.average,
          avg_min_height: averages["min_height"]!.average,
          avg_wells: averages["wells"]!.average,
          avg_lat: averages["avg_lat"]!.average,
          avg_cd_9: averages["cd_9"]!.average,
          avg_mean_height: averages["mean_height"]!.average,
          avg_pattern_div: averages["pattern_div"]!.average,
          avg_total_movements: averages["total_movements"]!.average,
          avg_weighted_cells: averages["weighted_cells"]!.average,
          avg_jaggedness: averages["jaggedness"]!.average,
          avg_indicator_value: averages["indicator_value"]!.average,
          elapsed_time: timestamp,
          assigned_username: usernameInput.text,
        ).toJson())
        .catchError((error, stackTrace) {
      print("Error: ${error.toString()}");
      // showSnackBar(context, "Server Error: ${error.toString()}");
    });

    if (eyeTrackingObjId != null) {
      await bkl.Backendless.data.of("TetrisGames").addRelation(
          tetrisGamesObjJson!["objectId"], "eye_tracking_data",
          childrenObjectIds: [eyeTrackingObjId]);
    }

    // showSnackBar(context, "Game created!");
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
      print("*" * 20);
      print(
          "${currentBlock!.onDropDownY1} || ${currentBlock!.onDropDownY2} || ${currentBlock!.rotateNum} || ${currentBlock!.translationNum} || ${currentBlock!.proportion_of_user_drops}");
      print("*" * 20);
    } else {
      currentBlock!.proportion_of_user_drops =
          ((currentBlock!.onDropDownY1 - currentBlock!.onDropDownY2) /
                  boardHeight)
              .abs();
      print("*" * 20);
      print(
          "${currentBlock!.onDropDownY1} || ${currentBlock!.onDropDownY2} || ${currentBlock!.rotateNum} || ${currentBlock!.translationNum} || ${currentBlock!.proportion_of_user_drops}");
      print("*" * 20);
    }
  }

  void calcMinTransDif() {
    int optimalTranslations =
        (rotationCenterX - currentBlock!.rotationCenter.x).abs();
    minimumTranslationsDif =
        (currentBlock!.translationNum - optimalTranslations).abs();
    print("=" * 20);
    print(
        "$minimumTranslationsDif || $rotationCenterX || ${currentBlock!.rotationCenter.x} || $optimalTranslations");
    print("=" * 20);
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
      int RNum = 0;
      int LNum = 0;
      for (var i = 0; i < currentBlock!.rotatePattern.length; i++) {
        if (currentBlock!.rotatePattern[i] == "R") {
          RNum++;
        } else {
          LNum++;
        }
      }
      minimumRotationsDif =
          currentBlock!.rotateNum - (((RNum - LNum).abs()) % 4);
    }
    print("/" * 20);
    print("$minimumRotationsDif");
    print("/" * 20);
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

      if (useEyeTracking) {
        screenshotController.capture().then((Uint8List? image) {
          //Capture Done
          setState(() {
            screenshotImage = image;
            gameOver = true;
          });
        }).catchError((onError) {
          print(onError);
        });
      }

      setState(() {
        gameOver = true;
      });

      try {
        if (!tutorialMode) {
          sendAverages();
        }
      } catch (e) {
        print("$e");
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
      print("Q" * 30);
      print("$delta_max_height");
      print("Q" * 30);
      getPitsAndWells();
      delta_pits = (pitsNumTemp - pits_num).abs();
      print("DP" * 30);
      print("$delta_pits");
      print("DP" * 30);
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
      print("|" * 20);
      print(
          "${currentBlock!.response_latency} | ${currentBlock!.drop_latency} | ${currentBlock!.initial_latency}");
      print("|" * 20);

      changeIndData();

      // send data
      fillAveragesMap();
      try {
        if (!tutorialMode) {
          sendSessionData();
        }
      } catch (e) {
        print("$e");
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
        child: getTetrisPoint(currentBlock!.color),
        left: point.x * pointSize,
        top: point.y * pointSize,
      );
      visiblePoints.add(newPoint);
    }

    // Old Blocks
    for (var point in alivePoints) {
      Positioned newPoint = Positioned(
        child: getTetrisPoint(point.color),
        left: point.x * pointSize,
        top: point.y * pointSize,
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
        child: getTetrisPoint(nextBlock!.color),
        left: (point.x < 0 || point.y > 0)
            ? (point.x + 1) * pointSize
            : point.x * pointSize,
        top: (point.y < 0 || point.x > 0)
            ? (point.y + 1) * pointSize
            : point.y * pointSize,
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
    averages = {
      "pits": [],
      "rotations": [],
      "proportion_of_user_drops": [],
      "minimum_rotation_difference": [],
      "minimum_translation_difference": [],
      "maximum_differences": [],
      "initial_latency": [],
      "drop_latency": [],
      "response_latency": [],
      "max_well": [],
      "deep_wells": [],
      "cumulative_wells": [],
      "column_transitions": [],
      "row_transitions": [],
      "landing_height": [],
      "matches": [],
      "delta_max_height": [],
      "delta_pits": [],
      "pit_depth": [],
      "lumped_pits": [],
      "pit_rows": [],
      "max_height": [],
      "min_height": [],
      "wells": [],
      "avg_lat": [],
      "cd_9": [],
      "mean_height": [],
      "pattern_div": [],
      "total_movements": [],
      "weighted_cells": [],
      "jaggedness": [],
      "indicator_value": [],
    };
    eyeCoordinates.clear();
    enableEyeTracking = true;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double screenWidth = size.width;
    // double screenHeight = MediaQuery.of(context).size.height;

    // double userInputFieldPadding = 190.0;

    width = (screenWidth / 6) * 3;
    height = width * 2.0;
    // height = screenHeight - userInputFieldPadding;
    // width = height / 2.0;
    pointSize = height / boardHeight;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(35),
        child: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
            ),
            onPressed: () async {
              try {
                timer.cancel();
                timestampTimer.cancel();
                setState(() {
                  enableEyeTracking = false;
                  eyeCoordinates.clear();
                });
              } catch (e) {
                print("$e");
              }
              Navigator.pop(context);
            },
          ),
          title: Row(children: [
            const Image(
              image: AssetImage("assets/images/metatris_logo.png"),
              width: 75,
              height: 35,
            ),
            Text(
              translation(context).metatris,
            ),
          ]),
        ),
      ),
      body: Screenshot(
        controller: screenshotController,
        child: Container(
          color: Colors.black,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                tutorialMode
                    ? Padding(
                        padding: const EdgeInsets.all(3.0),
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
                      )
                    : Container(),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text(
                    showScore ? "${translation(context).score} $score" : "",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          showScore
                              ? Column(
                                  children: [
                                    const SizedBox(height: 20),
                                    Padding(
                                      padding: const EdgeInsets.all(3.0),
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
                                    const SizedBox(
                                      height: 40,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(3.0),
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
                                    const SizedBox(
                                      height: 40,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(3.0),
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
                                    const SizedBox(
                                      height: 40,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(3.0),
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
                                )
                              : Container(),
                          const SizedBox(
                            width: 10,
                          ),
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: blocksContainerBorderColor ??
                                        Colors.white,
                                    width: 3),
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(1),
                                width: width,
                                height: height,
                                child: gameOver
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                                alivePoints.removeWhere(
                                                    (element) => true);
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
                                              ),
                                            ),
                                          ),
                                          !tutorialMode && useEyeTracking
                                              ? OutlinedButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pushNamed(RouteManager
                                                            .eyeTrackingPage);
                                                  },
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                    shape:
                                                        const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5)),
                                                    ),
                                                    side: const BorderSide(
                                                        color: Colors.blue),
                                                  ),
                                                  child: Text(
                                                    translation(context)
                                                        .viewEyeTrackingResults,
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                )
                                              : Container(),
                                        ],
                                      )
                                    : drawTetrisBlocks(),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            children: [
                              Container(
                                width: screenWidth / 5,
                                // height: 150,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  border: Border.all(color: Colors.transparent),
                                ),
                                child: Column(children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(3.0),
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
                                  Center(
                                    child: SizedBox(
                                      width: screenWidth / 5,
                                      height: pointSize * 3,
                                      child: gameOver
                                          ? Container()
                                          : drawNextBlocks(),
                                    ),
                                  ),
                                ]),
                              ),
                              const SizedBox(
                                height: 60,
                              ),
                              showIndicator
                                  ? SizedBox(
                                      width: screenWidth / 5,
                                      height: 200,
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
                                          roundedEdges:
                                              const Radius.circular(10),
                                          selectedGradientColor:
                                              const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.grey,
                                              Colors.transparent
                                            ],
                                          ),
                                          unselectedGradientColor:
                                              LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: indColor,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
                              const SizedBox(height: 20),
                            ],
                          ),
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
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(3.0),
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
                                          performAction =
                                              LastButtonPressed.left;
                                          checkForUserInput(null);
                                          performAction =
                                              LastButtonPressed.none;
                                        });
                                      }
                                    },
                                    child: const Icon(
                                      Icons.arrow_left,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(65, 45)),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(3.0),
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
                                          performAction =
                                              LastButtonPressed.right;
                                          checkForUserInput(null);
                                          performAction =
                                              LastButtonPressed.none;
                                        });
                                      }
                                    },
                                    child: const Icon(
                                      Icons.arrow_right,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(65, 45)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 40),
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
                                child: const Icon(
                                  Icons.arrow_drop_down,
                                ),
                                style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(65, 45)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 93, top: 3, left: 3, right: 3),
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
                                if (!gameOver) {
                                  setState(() {
                                    enableEyeTracking = true;
                                  });
                                }
                              }
                            });
                          },
                          child: Text(
                            startButton == "Start"
                                ? translation(context).start
                                : translation(context).stop,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            backgroundColor: Colors.red,
                            minimumSize: const Size(70, 70),
                          ),
                        ),
                      ),
                      enableEyeTracking ? const EyeTracking() : Container(),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 93, top: 3, left: 3, right: 3),
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
                          child: const Icon(
                            Icons.rotate_left,
                          ),
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size(65, 45)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 93, top: 3, left: 3, right: 3),
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
                          child: const Icon(
                            Icons.rotate_right,
                          ),
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size(65, 45)),
                        ),
                      ),
                    ],
                  ),
                )
              ]),
        ),
      ),
    );
  }

  void _onDropDownHoldingCancel() {
    if (startButton == "Stop") {
      setState(() {
        print("GameSpeed: $gameSpeed // tempGameSpeed: $tempGameSpeed");
        timer.cancel();
        gameSpeed = tempGameSpeed;
        runGameTimer();
      });
      dropDownHolding = false;
      currentBlock!.onDropDownY2 = currentBlock!.rotationCenter.y;
    }
  }
}
