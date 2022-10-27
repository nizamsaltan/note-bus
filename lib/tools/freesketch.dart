import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:note_bus/models/arrow_model.dart';
import 'package:note_bus/models/square_model.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import '../models/hand_sketch.dart';

class StrokePainter extends CustomPainter {
  final List<HandSketch> handSketches;
  final List<ArrowSketch> arrowSketches;
  final List<SquareSketch> squareSketches;

  StrokePainter(
      {required this.handSketches,
      required this.arrowSketches,
      required this.squareSketches});

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

    // Arrows
    for (var element in arrowSketches) {
      canvas.drawLine(
          Offset(element.from.dx, element.from.dy),
          Offset(element.to.dx, element.to.dy),
          paintProperty
            ..color = element.color
            ..strokeWidth = element.size / 1.5);
    }

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
