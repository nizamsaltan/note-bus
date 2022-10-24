// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:note_bus/widgets/drawboard_widget.dart';
import 'package:note_bus/main.dart';
import 'package:note_bus/models/enums.dart';

class ControlWidget extends StatefulWidget {
  const ControlWidget({super.key});

  @override
  State<ControlWidget> createState() => _ControlWidgetState();
}

class _ControlWidgetState extends State<ControlWidget> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          height: 310,
          width: 50,
          decoration: BoxDecoration(
            color: currentTheme.secondaryBackgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ControlWidgetButton(
                  onPressed: (() {
                    setEditMode(EditMode.pen);
                  }),
                  child: Icon(FontAwesomeIcons.penToSquare,
                      color: currentTheme.highlightColor)),
              ControlWidgetButton(
                  onPressed: (() {
                    setEditMode(EditMode.erase);
                  }),
                  child: Icon(FontAwesomeIcons.eraser,
                      color: currentTheme.highlightColor)),
              ControlWidgetButton(
                  onPressed: (() {
                    drawboardSketches.clear();
                    setEditMode(EditMode.pen);
                  }),
                  child: Icon(FontAwesomeIcons.deleteLeft,
                      color: currentTheme.highlightColor)),
              ControlWidgetButton(
                  onPressed: (() {
                    currentTheme.currentPenColor = currentTheme.highlightColor;
                    setEditMode(EditMode.pen);
                  }),
                  child: colorContainer(currentTheme.highlightColor)),
              ControlWidgetButton(
                  onPressed: (() {
                    currentTheme.currentPenColor =
                        Color.fromARGB(255, 243, 80, 80);
                    setEditMode(EditMode.pen);
                  }),
                  child: colorContainer(Color.fromARGB(255, 243, 80, 80))),
              ControlWidgetButton(
                  onPressed: (() {
                    currentTheme.currentPenColor =
                        Color.fromARGB(255, 43, 102, 151);
                    setEditMode(EditMode.pen);
                  }),
                  child: colorContainer(Color.fromARGB(255, 43, 102, 151))),
            ],
          ),
        ),
      ),
    );
  }

  Widget colorContainer(Color color) {
    return Container(
      height: 20,
      width: 20,
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(3), color: color),
    );
  }
}

class ControlWidgetButton extends StatelessWidget {
  Widget child;
  Function() onPressed;
  ControlWidgetButton({
    super.key,
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: TextButton(
            onPressed: onPressed,
            child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: child)));
  }
}

void setEditMode(EditMode newMode) {
  currentMode = newMode;
}
