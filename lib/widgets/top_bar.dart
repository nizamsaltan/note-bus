import 'package:flutter/material.dart';
import 'package:note_bus/main.dart';
import 'package:url_launcher/url_launcher.dart';
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
      width: 200,
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
                  text: 'Save file',
                  onPressed: () => ProjectSaver.instance.saveFile(),
                ),
                PanelButton(
                  text: 'Load file',
                  onPressed: () => ProjectSaver.instance.loadFile(),
                ),
                PanelButton(
                  text: 'Capture image',
                  onPressed: () => ProjectSaver.instance.capturePng(),
                ),
              ]),
              topBarButton('Edit', () => null,
                  [PanelButton(text: 'Edit Shortcuts', onPressed: () {})]),
              topBarButton('Help', () => null, [
                PanelButton(
                    text: 'Github 🧡',
                    onPressed: () => openURL('https://github.com/nizamsaltan')),
                PanelButton(
                    text: 'Source code',
                    onPressed: () =>
                        openURL('https://github.com/nizamsaltan/note-bus')),
                PanelButton(
                    text: 'Ask for feature',
                    onPressed: () => openURL(
                        'mailto:nizamsaltan@protonmail.com?subject=I want new feature for NoteBus!'))
              ])
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
        vector.Vector3(_containerOffset.dx + 5, 0, 0),
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
          child: Container(
            decoration: BoxDecoration(
                color: isHover
                    ? const Color.fromARGB(255, 160, 160, 160)
                    : const Color.fromARGB(255, 175, 175, 175),
                borderRadius: BorderRadius.circular(5)),
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

Future<void> openURL(String url) async {
  Uri uri = Uri.parse(url);
  if (!await launchUrl(uri)) {
    throw 'Could not launch $uri';
  }
}
