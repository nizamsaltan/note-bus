// ignore_for_file: must_be_immutable

import 'package:event/event.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:note_bus/main.dart';
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
  bool isMouseEnter = false;

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

  void onMouseEnter(PointerEnterEvent event) {
    setState(() {
      isMouseEnter = true;
    });
  }

  void onMouseExit(PointerExitEvent event) {
    setState(() {
      isMouseEnter = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      origin: -drawboardOffset,
      transform: drawboardTransform,
      child: Transform(
        transform: Matrix4.translationValues(
            widget.startPos.dx, widget.startPos.dy, 0),
        child: MouseRegion(
          onEnter: onMouseEnter,
          onExit: onMouseExit,
          child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: (widget.startPos.dx - widget.endPos.dx).abs(),
              height: (widget.startPos.dy - widget.endPos.dy).abs(),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: currentTheme.highlightColor.withOpacity(.5),
                    width: isMouseEnter ? 1.25 : 0.01,
                  ),
                  borderRadius: BorderRadius.circular(7)),
              child: Text(widget.text)),
        ),
      ),
    );
  }
}
