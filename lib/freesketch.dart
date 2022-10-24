import 'package:flutter/material.dart';
import 'package:note_bus/save_project.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

class StrokePainter extends CustomPainter {
  final List<HandSketch> shapes;

  StrokePainter({required this.shapes});

  @override
  void paint(Canvas canvas, Size size) {
    for (var element in shapes) {
      Paint paintProperty = Paint()
        ..color = element.color
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;
      Path myPath = setPath(element.points, element.size)!;
      canvas.drawPath(myPath, paintProperty);
    }
  }

  @override
  bool shouldRepaint(StrokePainter oldDelegate) {
    return true;
  }
}

Path? setPath(List<Point> points, double size) {
  // 1. Get the outline points from the input points
  final outlinePoints = getStroke(
    points,
    thinning: .5,
    size: size,
  );

  // 2. Render the points as a path
  final path = Path();

  if (outlinePoints.isEmpty) {
    // If the list is empty, don't do anything.
    return null;
  } else if (outlinePoints.length < 2) {
    // If the list only has one point, draw a dot.
    path.addOval(Rect.fromCircle(
        center: Offset(outlinePoints[0].x, outlinePoints[0].y), radius: 1));
  } else {
    // Otherwise, draw a line that connects each point with a bezier curve segment.
    path.moveTo(outlinePoints[0].x, outlinePoints[0].y);

    for (int i = 1; i < outlinePoints.length - 1; ++i) {
      final p0 = outlinePoints[i];
      final p1 = outlinePoints[i + 1];
      path.quadraticBezierTo(p0.x, p0.y, (p0.x + p1.x) / 2, (p0.y + p1.y) / 2);
    }
  }

  return path;
}

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
