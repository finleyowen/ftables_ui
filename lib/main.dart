/// FTables UI main library
///
/// Defines the program entry point and the [MainApp] widget.
///
/// Copyright Finley Owen 2026. All rights reserved.
library;

import 'package:flutter/material.dart';
import 'package:fsheets/views/home.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomeView());
  }
}
