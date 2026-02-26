/// Spreadsheet view module
///
/// Defines the [SpreadsheetView] and related components.
///
/// Copyright Finley Owen 2026. All rights reserved.
library;

import 'package:flutter/material.dart';
import 'package:fsheets/components/app_scaffold.dart';
import 'package:fsheets/components/typed_inputs.dart';
import 'package:fsheets/logic/schema.dart';
import 'package:fsheets/views/home.dart';

class SpreadsheetView extends StatelessWidget {
  final SpreadsheetSchema schema;
  late final ValueNotifier<int> openTableIndex = ValueNotifier(0);

  SpreadsheetView({super.key, required this.schema});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: openTableIndex,
      builder: (context, value, child) => AppScaffold(
        body: TableFormView(
          tableName: schema.tableNames[value],
          tableSchema: schema.tables[schema.tableNames[value]]!,
        ),
        drawer: SpreadsheetTableNav(
          schema: schema,
          openTableIndex: openTableIndex,
        ),
      ),
    );
  }
}

class SpreadsheetTableNav extends StatelessWidget {
  final SpreadsheetSchema schema;
  final ValueNotifier<int> openTableIndex;

  const SpreadsheetTableNav({
    super.key,
    required this.schema,
    required this.openTableIndex,
  });

  @override
  Widget build(BuildContext context) => NavigationDrawer(
    tilePadding: EdgeInsetsGeometry.directional(top: 20, start: 10, end: 10),
    selectedIndex: openTableIndex.value,
    onDestinationSelected: (value) {
      if (value < schema.tables.length) {
        openTableIndex.value = value;
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => HomeView()),
          (_) => false,
        );
      }
    },
    children: [
      Padding(
        padding: EdgeInsetsGeometry.all(10),
        child: Text(
          "Spreadsheet",
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
      ...schema.tables.entries.map(
        (entry) => NavigationDrawerDestination(
          icon: Icon(Icons.abc),
          label: Text(entry.key),
        ),
      ),
      Divider(),
      NavigationDrawerDestination(
        icon: Icon(Icons.close),
        label: Text("Close spreadsheet"),
      ),
    ],
  );
}

class TableFormView extends StatelessWidget {
  final TableSchema tableSchema;
  final String tableName;
  final formKey = GlobalKey<FormState>();

  TableFormView({
    super.key,
    required this.tableSchema,
    required this.tableName,
  });

  @override
  Widget build(BuildContext context) => Form(
    key: formKey,
    child: Column(
      spacing: 30,
      children: [
        Row(
          children: [
            Text(tableName, style: Theme.of(context).textTheme.headlineLarge),
          ],
        ),
        for (final columnName in tableSchema.columnNames)
          TypedTextField.fromColumnSchema(
            tableSchema.columns[columnName]!,
            columnName,
          )!,
        Row(
          children: [
            FloatingActionButton.extended(
              onPressed: () {
                if (formKey.currentState!.validate()) {}
              },
              label: Text("Validate"),
              icon: Icon(Icons.check),
            ),
          ],
        ),
      ],
    ),
  );
}
