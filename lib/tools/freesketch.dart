import 'package:flutter/material.dart';
import 'package:note_bus/models/arrow_model.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import '../models/hand_sketch.dart';

class StrokePainter extends CustomPainter {
  final List<HandSketch> handSketches;
  final List<ArrowSketch> arrowSketches;
  StrokePainter({required this.handSketches, required this.arrowSketches});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paintProperty = Paint()
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // Hand sketch
    for (var element in handSketches) {
      Path myPath = setPath(element.points, element.size)!;
      canvas.drawPath(
        myPath,
        paintProperty..color = element.color,
      );
    }

    // for (var i = 0; i < 1; i++) {
    //   var start = const Offset(0, 0);
    //   var end = const Offset(200, 450);
    //   var curvature = 1;

    //   List<Point> myPoints = [
    //     //   Point(start.dx, start.dy),
    //     //   Point(start.dx - curvature, start.dy - curvature),

    //     //   Point(end.dx - curvature, start.dy - curvature),
    //     //   Point(end.dx, start.dy),
    //     //   Point(end.dx - curvature, start.dy - curvature),

    //     //   Point(end.dx - curvature, end.dy - curvature),
    //     //   Point(end.dx, end.dy),
    //     //   Point(end.dx - curvature, end.dy - curvature),
    //     //   Point(end.dx, end.dy),

    //     //   Point(start.dx - curvature, end.dy - curvature),
    //     //   Point(start.dx, end.dy),
    //     //   Point(start.dx - curvature, end.dy - curvature),

    //     //   Point(start.dx - curvature, start.dy - curvature),
    //     //   Point(start.dx, start.dy),
    //     //   Point(start.dx + curvature, start.dy + curvature),

    //     const Point(0, 0),
    //     const Point(0, 199),
    //     const Point(0, 200),
    //     const Point(0, 201),
    //     const Point(199, 199),
    //     const Point(200, 200),
    //     const Point(199, 199),
    //     const Point(199, 0),
    //     const Point(200, 0),
    //     const Point(200, 0),

    //     // etc...
    //   ];

    //   Path path = setPath(myPoints, 5, simulatePressure: false, smoothing: 0)!;

    //   canvas.drawPath(path, paintProperty..color = Colors.black);
    // }

    // Arrows
    for (var element in arrowSketches) {
      canvas.drawLine(
          Offset(element.from.dx, element.from.dy),
          Offset(element.to.dx, element.to.dy),
          paintProperty
            ..color = element.color
            ..strokeWidth = element.size / 1.5);
    }
/*
    // Square
    for (var element in squareSketches) {
      canvas.drawRect(
          Rect.fromPoints(
            Offset(element.start.dx, element.start.dy),
            Offset(element.end.dx, element.end.dy),
          ),
          paintProperty
            ..style = element.fill ? PaintingStyle.fill : PaintingStyle.stroke
            ..strokeWidth = element.size / 1.5);
    }
  */
  }

  @override
  bool shouldRepaint(StrokePainter oldDelegate) {
    return true;
  }
}

Path? setPath(List<Point> points, double size,
    {bool simulatePressure = true, double smoothing = .5}) {
  // 1. Get the outline points from the input points
  final outlinePoints = getStroke(
    points,
    thinning: .5,
    size: size,
    simulatePressure: simulatePressure,
    smoothing: smoothing,
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
