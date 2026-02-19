import 'package:flutter/material.dart';
import 'package:fsheets/components/app_scaffold.dart';
import 'package:fsheets/components/typed_text_field.dart';
import 'package:fsheets/components/util.dart';
import 'package:fsheets/logic/data_type.dart';
import 'package:fsheets/logic/ffi.dart';
import 'package:fsheets/views/table_form.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<StatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController schemaController = TextEditingController();
  bool isValid = true;

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
        StringTextField(
          controller: schemaController,
          dataType: StringDataType(nullable: false),
          labelText: "Table schema",
        ),
        Row(
          children: [
            FloatingActionButton.extended(
              label: Text("Generate form"),
              icon: Icon(Icons.arrow_forward),
              onPressed: () {
                try {
                  final schema = parseSchema(schemaController.text);
                  final tableSchema = schema.tables.elementAt(0);

                  setState(() {
                    isValid = true;
                  });
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TableFormView(schema: tableSchema),
                    ),
                  );
                } catch (e) {
                  setState(() {
                    isValid = false;
                  });
                }
              },
            ),
          ],
        ),
        if (!isValid) Row(children: [Text("Invalid!")]),
      ],
    ),
  );
}
