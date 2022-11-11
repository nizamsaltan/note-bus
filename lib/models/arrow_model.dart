import 'package:flutter/widgets.dart';

class ArrowSketch {
  Offset from;
  Offset to;
  Color color;
  double size;

  bool isDeleted = false;

  ArrowSketch(this.from, this.to, this.color, this.size);
}
