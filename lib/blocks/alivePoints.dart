import 'package:flutter/material.dart';
import 'point.dart';

class AlivePoint extends Point {
  Color color;
  AlivePoint(int x, int y, this.color) : super(x, y);

  bool checkIfPointsCollide(List<Point> pointList, {int yDistance = 1}) {
    bool value = false;
    for (var pointToCheck in pointList) {
      if ((pointToCheck.x == x && pointToCheck.y == y - yDistance)) {
        value = true;
      }
    }
    return value;
  }
}
