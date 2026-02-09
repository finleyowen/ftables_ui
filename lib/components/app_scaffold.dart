/// App scaffold module
library;

import "package:flutter/material.dart";

class AppScaffold extends StatelessWidget {
  final Widget? body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const AppScaffold({
    super.key,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Padding(padding: EdgeInsetsGeometry.all(10), child: body),
    floatingActionButton: floatingActionButton,
    floatingActionButtonLocation: floatingActionButtonLocation,
  );
}
