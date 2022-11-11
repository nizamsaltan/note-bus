import 'package:flutter/widgets.dart';

class SquareSketch {
  Offset start;
  Offset end;
  Color color;
  double size;
  bool fill;

  bool isDeleted = false;

  SquareSketch(this.start, this.end, this.color, this.size, this.fill);
}
