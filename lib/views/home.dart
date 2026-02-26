/// Home view library
///
/// Defines the [HomeView] class and its state.
///
/// Copyright Finley Owen 2026. All rights reserved.
library;

import 'package:flutter/material.dart';
import 'package:fsheets/components/app_scaffold.dart';
import 'package:fsheets/components/util.dart';
import 'package:fsheets/logic/ffi.dart';
import 'package:fsheets/views/spreadsheet_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<StatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _schemaController = TextEditingController(
    text: "",
  );
  bool isValid = true;
  String errorMsg = "";

  @override
  Widget build(BuildContext context) => AppScaffold(
    body: Column(
      spacing: 20,
      children: [
        PaddedRow(
          padding: EdgeInsetsGeometry.symmetric(vertical: 20, horizontal: 0),
          children: [
            Text(
              "BetterSheets",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ],
        ),
        TextField(
          controller: _schemaController,
          decoration: InputDecoration(
            labelText: "Spreadsheet schema",
            hintText: "// enter DDL statements, e.g 'tab T(a: int);'",
          ),
          maxLines: null,
        ),
        Row(
          children: [
            FloatingActionButton.extended(
              label: Text("Generate form"),
              icon: Icon(Icons.arrow_forward),
              onPressed: () {
                try {
                  final schema = parseSchema(_schemaController.text);

                  setState(() {
                    isValid = true;
                  });
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SpreadsheetView(schema: schema),
                    ),
                  );
                } catch (e) {
                  setState(() {
                    errorMsg = e.toString();
                    isValid = false;
                  });
                }
              },
            ),
          ],
        ),
        if (!isValid) Row(children: [Text(errorMsg)]),
      ],
    ),
  );
}
