import 'dart:developer';

import 'package:flutter/material.dart';

class SquareSketch extends StatelessWidget {
  const SquareSketch({
    super.key,
    required this.offset,
    required this.text,
  });

  final double size = 100;
  final Offset offset;
  final String text;

  void onStart(DragStartDetails details) {
    log(details.toString());
  }

  void onUpdate(DragUpdateDetails details) {
    log(details.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: GestureDetector(
        onTap: () {
          log('message');
        },
        onPanStart: onStart,
        onPanUpdate: onUpdate,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.grey,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(7)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(text),
          ),
        ),
      ),
    );
  }
}
