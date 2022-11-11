import 'package:flutter/material.dart';
import 'package:note_bus/main.dart';

AppTheme whiteTheme = AppTheme(
  const Color.fromARGB(255, 214, 214, 219),
  const Color.fromARGB(255, 185, 185, 185),
  const Color.fromARGB(255, 43, 45, 46),
  const Color.fromARGB(255, 43, 45, 46),
);

class AppTheme {
  final Color backgroundColor;
  final Color highlightColor;
  final Color secondaryBackgroundColor;
  Color currentPenColor;

  AppTheme(
    this.backgroundColor,
    this.secondaryBackgroundColor,
    this.highlightColor,
    this.currentPenColor,
  );
}

// Text styles

final TextStyle standartTextStyle = TextStyle(
  fontSize: 20,
  fontFamily: 'Apercu',
  fontWeight: FontWeight.w500,
  color: currentTheme.highlightColor,
);

final TextStyle lowerTextStyle = TextStyle(
  fontSize: 16,
  fontFamily: 'Apercu',
  fontWeight: FontWeight.w500,
  color: currentTheme.highlightColor,
);
