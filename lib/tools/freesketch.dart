import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import '../models/hand_sketch.dart';

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
