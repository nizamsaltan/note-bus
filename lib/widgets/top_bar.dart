import 'package:flutter/material.dart';
import 'package:note_bus/main.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

import '../tools/save_project.dart';
import '../utils/app_theme.dart';

Offset _containerOffset = const Offset(0, 0);
Widget? _currentPanel;

class TopBar extends StatefulWidget {
  const TopBar({super.key});

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  @override
  Widget build(BuildContext context) {
    // Add color for debug
    // ignore: sized_box_for_whitespace
    return Container(
      width: 150,
      child: MouseRegion(
        onExit: (event) {
          setState(() {
            _currentPanel = null;
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              topBarButton('File', () => null, [
                PanelButton(
                  text: 'Save File',
                  onPressed: () => ProjectSaver.instance.saveFile(),
                ),
                PanelButton(
                  text: 'Load File',
                  onPressed: () => ProjectSaver.instance.loadFile(),
                ),
                PanelButton(
                  text: 'Capture Image',
                  onPressed: () => ProjectSaver.instance.capturePng(),
                ),
              ]),
              topBarButton(
                  'Edit', () => null, [Text('data', style: lowerTextStyle)]),
            ]),
            const SizedBox(height: 5),
            panel()
          ],
        ),
      ),
    );
  }

  Widget topBarButton(
      String name, Function() onPressed, List<Widget> children) {
    final GlobalKey widgetKey = GlobalKey();

    return MouseRegion(
      onEnter: (value) => setState(() {
        _containerOffset = getOffsetOfWidget(widgetKey);
        _currentPanel = MouseRegion(
          onExit: (event) {
            setState(() {
              _currentPanel = null;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        );
      }),
      child: Column(
        key: widgetKey,
        children: [
          TextButton(
            onPressed: onPressed,
            child: Text(name, style: lowerTextStyle),
          ),
        ],
      ),
    );
  }

  Widget panel() {
    return Container(
      transform: Matrix4.translation(
        vector.Vector3(_containerOffset.dx, 0, 0),
      ),
      decoration: BoxDecoration(
        color: currentTheme.secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: _currentPanel,
    );
  }
}

Offset getOffsetOfWidget(GlobalKey widgetKey) {
  final RenderBox renderBox =
      widgetKey.currentContext?.findRenderObject() as RenderBox;
  final Offset offset = renderBox.localToGlobal(Offset.zero);
  return offset;
}

// ignore: must_be_immutable
class PanelButton extends StatefulWidget {
  String text;
  Function() onPressed;
  PanelButton({super.key, required this.text, required this.onPressed});

  @override
  State<PanelButton> createState() => _PanelButtonState();
}

class _PanelButtonState extends State<PanelButton> {
  bool isHover = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: SizedBox(
        height: 25,
        width: 150,
        child: InkWell(
          onHover: (value) => setState(() => isHover = value),
          onTap: widget.onPressed,
          child: AnimatedContainer(
            decoration: BoxDecoration(
                color: isHover
                    ? const Color.fromARGB(255, 160, 160, 160)
                    : const Color.fromARGB(255, 175, 175, 175),
                borderRadius: BorderRadius.circular(5)),
            duration: const Duration(milliseconds: 200),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(widget.text, style: lowerTextStyle),
                )),
          ),
        ),
      ),
    );
  }
}
