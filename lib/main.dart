import 'package:flutter/material.dart';
import 'package:note_bus/widgets/drawboard_widget.dart';

import 'design/app_theme.dart';

AppTheme currentTheme = whiteTheme;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Drawboard(),
    );
  }
}
