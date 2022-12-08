// ignore_for_file: must_be_immutable

import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:note_bus/widgets/drawboard_widget.dart';

class SquareWidget extends StatefulWidget {
  SquareWidget({
    super.key,
    required this.startPos,
    required this.endPos,
    required this.text,
  });

  void updateSquareValues(Offset startPos, Offset endPos) {
    this.startPos = startPos;
    this.endPos = endPos;
    updateSquareValuesEvent.broadcast();
  }

  Event updateSquareValuesEvent = Event();

  Offset startPos;
  Offset endPos;
  final String text;

  @override
  State<SquareWidget> createState() => _SquareWidgetState();
}

class _SquareWidgetState extends State<SquareWidget> {
  @override
  void initState() {
    widget.updateSquareValuesEvent.subscribe((args) {
      update();
    });
    super.initState();
  }

  void update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      origin: -drawboardOffset,
      transform: drawboardTransform,
      child: Container(
          transform: Matrix4.translationValues(
              widget.startPos.dx, widget.startPos.dy, 0),
          width: (widget.startPos.dx - widget.endPos.dx).abs(),
          height: (widget.startPos.dy - widget.endPos.dy).abs(),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.grey,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(7)),
          child: Text(widget.text)),
    );
  }
}
