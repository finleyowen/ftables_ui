/// App scaffold module
///
/// Defines the [AppScaffold] widget that leverages and behaves similarly to
/// [Scaffold], but is customised for the application.
///
/// Copyright Finley Owen 2026. All rights reserved.
library;

import "package:flutter/material.dart";

class AppScaffold extends StatelessWidget {
  final Widget? body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;

  const AppScaffold({
    super.key,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 800),
        child: Padding(padding: EdgeInsetsGeometry.all(20), child: body),
      ),
    ),
    floatingActionButton: floatingActionButton,
    floatingActionButtonLocation: floatingActionButtonLocation,
    drawer: drawer,
  );
}
