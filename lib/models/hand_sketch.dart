import 'package:flutter/material.dart';
import 'package:note_bus/tools/save_project.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

class HandSketch {
  final List<Point> points;
  final double size;
  Color color;
  bool delete = false;

  HandSketch(this.points, this.color, this.size);

  factory HandSketch.fromJson(Map<String, dynamic> json) {
    double size = json['size'];
    Color color = hexToColor(json['color']);
    List<Point> points = getPoints(json['x'], json['y'], json['p']);

    return HandSketch(points, color, size);
  }

  Map<String, dynamic> toJson() => {
        'size': size,
        'color': color.toString(),
        'x': getPointAttrs(points, 0),
        'y': getPointAttrs(points, 1),
        'p': getPointAttrs(points, 2),
      };

  List<double> pointsX = [];
  List<double> pointsY = [];
  List<double> pointsP = [];

  void initializePoints() {
    pointsP.clear();
    pointsX.clear();
    pointsY.clear();
    for (var i = 0; i < points.length; i++) {
      pointsX.add(points[i].x);
      pointsY.add(points[i].y);
      pointsP.add(points[i].p);
    }
  }
}

List<Point> getPoints(List<dynamic> x, List<dynamic> y, List<dynamic> p) {
  List<Point> myPoints = [];
  for (var i = 0; i < x.length; i++) {
    Point newPoint = Point(x[i], y[i], p[i]);
    myPoints.add(newPoint);
  }
  return myPoints;
}

List<double> getPointAttrs(List<Point> attr, int which) {
  List<double> newAttr = [];
  switch (which) {
    case 0: // X
      for (var i = 0; i < attr.length; i++) {
        newAttr.add(attr[i].x);
      }
      break;
    case 1: // Y
      for (var i = 0; i < attr.length; i++) {
        newAttr.add(attr[i].y);
      }
      break;
    case 2: // P
      for (var i = 0; i < attr.length; i++) {
        newAttr.add(attr[i].p);
      }
      break;
    default:
  }

  return newAttr;
}
