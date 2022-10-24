import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:note_bus/freesketch.dart';
import 'package:note_bus/main.dart';
import 'package:note_bus/models/enums.dart';
import 'package:note_bus/save_project.dart';
import 'package:note_bus/widgets/control_widget.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

class Drawboard extends StatefulWidget {
  const Drawboard({super.key});

  @override
  State<Drawboard> createState() => _DrawboardState();
}

double touchPressure = 5; // Change it later on
List<HandSketch> drawboardSketches = [];

final GlobalKey globalWidgetKey = GlobalKey();

class _DrawboardState extends State<Drawboard> {
  late HandSketch currentShape;

  // ** Callbacks **

  void onPanStart(DragStartDetails details) {
    switch (currentMode) {
      case EditMode.pen:
        List<Point> x = [
          Point(details.globalPosition.dx, details.globalPosition.dy, 2)
        ];
        currentShape =
            HandSketch(x, currentTheme.currentPenColor, touchPressure);
        drawboardSketches.add(currentShape);
        break;
      case EditMode.erase:
        break;
      default:
        List<Point> x = [];
        currentShape =
            HandSketch(x, currentTheme.currentPenColor, touchPressure);
        drawboardSketches.add(currentShape);
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    switch (currentMode) {
      case EditMode.pen:
        setState(() {
          currentShape.points.add(
            Point(details.globalPosition.dx, details.globalPosition.dy, 2),
          );
        });
        break;
      case EditMode.erase:
        for (var i = 0; i < drawboardSketches.length; i++) {
          Path path = setPath(drawboardSketches[i].points, 15)!;
          if (path.contains(
              Offset(details.globalPosition.dx, details.globalPosition.dy))) {
            setState(() {
              drawboardSketches[i].color = Colors.black26;
              drawboardSketches[i].delete = true;
            });
          }
        }
        break;
      default:
        setState(
          () {
            currentShape.points.add(
              Point(details.globalPosition.dx, details.globalPosition.dy),
            );
          },
        );
    }
  }

  void onPanCancel() {
    //detectDeletedShapes();
  }

  void onPanEnd(DragEndDetails details) {
    detectDeletedShapes();
  }

  // ** Methods **

  void detectDeletedShapes() {
    setState(() {
      for (var element in List<HandSketch>.from(drawboardSketches)) {
        if (element.delete) {
          drawboardSketches.remove(element);
        }
      }
    });
  }

  // ** Build **

  @override
  void initState() {
    super.initState();
    ProjectSaver.onProjectLoaded.subscribe((args) {
      setState(() {
        drawboardSketches = drawboardSketches;
      });

      log('Loaded project succesfuly');
    });

    ProjectSaver.onProjectSaved.subscribe((args) {
      log('Project saved succesfuly');
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanCancel: onPanCancel,
      onPanEnd: onPanEnd,
      child: RepaintBoundary(
        key: globalWidgetKey,
        child: Scaffold(
            backgroundColor: currentTheme.backgroundColor,
            body: CustomPaint(
              painter: StrokePainter(shapes: drawboardSketches),
              child: Stack(children: [
                const ControlWidget(),
                Row(
                  children: [
                    TextButton(
                      onPressed: ProjectSaver.instance.capturePng,
                      child: Text('Capture Image',
                          style: TextStyle(color: Colors.grey[900])),
                    ),
                    TextButton(
                      onPressed: ProjectSaver.instance.saveFile,
                      child: Text(
                        'Save file',
                        style: TextStyle(color: Colors.grey[900]),
                      ),
                    ),
                    TextButton(
                      onPressed: ProjectSaver.instance.loadFile,
                      child: Text(
                        'Load file',
                        style: TextStyle(color: Colors.grey[900]),
                      ),
                    ),
                  ],
                )
              ]),
            )),
      ),
    );
  }
}
