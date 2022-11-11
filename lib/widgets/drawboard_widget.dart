import 'dart:async';
import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:note_bus/models/arrow_model.dart';
import 'package:note_bus/models/square_model.dart';
import 'package:note_bus/tools/freesketch.dart';
import 'package:note_bus/main.dart';
import 'package:note_bus/models/enums.dart';
import 'package:note_bus/tools/save_project.dart';
import 'package:note_bus/utils/app_theme.dart';
import 'package:note_bus/widgets/control_widget.dart';
import 'package:note_bus/widgets/top_bar.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

import '../models/hand_sketch.dart';

class Drawboard extends StatefulWidget {
  const Drawboard({super.key});

  @override
  State<Drawboard> createState() => _DrawboardState();
}

List<HandSketch> drawboardSketches = [];
List<ArrowSketch> drawboardArrows = [];
List<SquareSketch> drawboardSquares = [];
Offset drawboardOffset = const Offset(0, 0);
double drawboardScale = 1;

final GlobalKey globalWidgetKey = GlobalKey();

class _DrawboardState extends State<Drawboard> {
  // Variables
  late HandSketch currentSketch;
  late ArrowSketch currentArrow;
  late SquareSketch currentSquare;
  bool isControllKeyPressing = false;
  bool showDrawboardScaleText = false;

  // Settings
  double touchPressure = 4; // Change it later on
  double ereaseSize = 15;
  double minDrawboardScale = .3;
  double maxDrawboardScale = 2;

  // ** Callbacks **

  void onPanStart(DragStartDetails details) {
    List<Point> x = [];
    x.add(
      Point(details.globalPosition.dx / drawboardScale - drawboardOffset.dx,
          details.globalPosition.dy / drawboardScale - drawboardOffset.dy, 2),
    );
    switch (currentMode) {
      case EditMode.pen:
        currentSketch =
            HandSketch(x, currentTheme.currentPenColor, touchPressure);
        drawboardSketches.add(currentSketch);
        break;
      case EditMode.erase:
        break;
      case EditMode.arrow:
        Offset offset = Offset(x.first.x, x.first.y);
        currentArrow = ArrowSketch(
            offset, offset, currentTheme.currentPenColor, touchPressure);
        drawboardArrows.add(currentArrow);
        break;
      case EditMode.square:
        Offset offset = Offset(x.first.x, x.first.y);
        currentSquare = SquareSketch(
            offset,
            offset,
            currentTheme.currentPenColor,
            touchPressure,
            false); // TODO: Fix here
        drawboardSquares.add(currentSquare);
        break;
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    double dx = details.globalPosition.dx;
    double dy = details.globalPosition.dy;
    switch (currentMode) {
      case EditMode.pen:
        addPointToCurrentSketch(dx, dy);
        break;
      case EditMode.erase:
        ereasePointSketch(dx, dy);
        break;

      case EditMode.arrow:
        updateCurrentArrowToOffset(dx, dy);
        break;
      case EditMode.square:
        updateCurrentSquareEndOffset(dx, dy);
        break;
    }
  }

  void onPanEnd(DragEndDetails details) {
    switch (currentMode) {
      case EditMode.pen:
        break;
      case EditMode.erase:
        detectDeletedShapes();
        break;
      case EditMode.arrow:
        break;
      case EditMode.square:
        break;
    }
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

  Offset getTouchOffset(double dx, double dy) {
    Offset touchOffset = Offset(
      dx / drawboardScale - drawboardOffset.dx,
      dy / drawboardScale - drawboardOffset.dy,
    );

    return touchOffset;
  }

  void addPointToCurrentSketch(double dx, double dy) {
    Offset touchOffset = getTouchOffset(dx, dy);
    setState(() {
      currentSketch.points
          .add(Point(touchOffset.dx, touchOffset.dy, touchPressure));
    });
  }

  void updateCurrentArrowToOffset(double dx, double dy) {
    Offset touchOffset = getTouchOffset(dx, dy);
    setState(() {
      currentArrow.to = touchOffset;
    });
  }

  void updateCurrentSquareEndOffset(double dx, double dy) {
    Offset touchOffset = getTouchOffset(dx, dy);
    setState(() {
      currentSquare.end = touchOffset;
    });
  }

  void ereasePointSketch(double dx, double dy) {
    Offset touchOffset = getTouchOffset(dx, dy);
    for (var i = 0; i < drawboardSketches.length; i++) {
      Path path = setPath(drawboardSketches[i].points, 15)!;
      if (path.contains(touchOffset)) {
        setState(() {
          drawboardSketches[i].color = Colors.black26;
          drawboardSketches[i].delete = true;
        });
      }
    }
  }

  void scaleDrawboard(double amount) {
    var targetScale = drawboardScale + amount;
    targetScale = targetScale.clamp(minDrawboardScale, maxDrawboardScale);

    setState(() {
      drawboardScale = targetScale;
      showDrawboardScaleText = true;
    });

    Timer(
        const Duration(seconds: 5),
        () => setState(() {
              showDrawboardScaleText = false;
            }));
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
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent && isControllKeyPressing) {
          if (event.scrollDelta.dy > 0) {
            scaleDrawboard(-.1);
          } else if (event.scrollDelta.dy < 0) {
            scaleDrawboard(.1);
          }
        }
      },
      onPointerDown: (event) {
        if (event.buttons != 1) {}
      },
      onPointerMove: (event) {
        if (event.buttons != 1) {
          setState(() {
            drawboardOffset += event.delta / drawboardScale;
          });
        }
      },
      child: RawKeyboardListener(
        autofocus: true,
        focusNode: FocusNode(),
        onKey: (value) {
          setState(() {
            isControllKeyPressing = value.isControlPressed;
            if (value.logicalKey == LogicalKeyboardKey.keyE) {
              setEditMode(EditMode.erase);
            }
            if (value.logicalKey == LogicalKeyboardKey.keyP) {
              setEditMode(EditMode.pen);
            }
            if (value.logicalKey == LogicalKeyboardKey.keyA) {
              setEditMode(EditMode.arrow);
            }
            if (value.logicalKey == LogicalKeyboardKey.keyS) {
              setEditMode(EditMode.square);
            }
          });
        },
        child: GestureDetector(
          onPanStart: onPanStart,
          onPanUpdate: onPanUpdate,
          onPanEnd: onPanEnd,
          child: RepaintBoundary(
            key: globalWidgetKey,
            child: Scaffold(
                backgroundColor: currentTheme.backgroundColor,
                body: Stack(
                  children: [
                    Transform(
                      origin: -drawboardOffset,
                      transform: Matrix4.translation(vector.Vector3(
                          drawboardOffset.dx, drawboardOffset.dy, 0))
                        ..scale(drawboardScale),
                      child: CustomPaint(
                        painter: StrokePainter(
                            handSketches: drawboardSketches,
                            arrowSketches: drawboardArrows,
                            squareSketches: drawboardSquares),
                      ),
                    ),
                    drawboardScaleText(),
                    const ControlWidget(),
                    const TopBar(),
                  ],
                )),
          ),
        ),
      ),
    );
  }

  Widget drawboardScaleText() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Align(
          alignment: Alignment.topCenter,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: showDrawboardScaleText ? 1 : 0,
            child: Container(
              decoration: BoxDecoration(
                  color: currentTheme.secondaryBackgroundColor,
                  borderRadius: BorderRadius.circular(5)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text((drawboardScale * 100).round().toString(),
                    style: standartTextStyle),
              ),
            ),
          )),
    );
  }
}
