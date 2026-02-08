/// Main library
library;

import 'package:flutter/material.dart';
import 'package:fsheets/components/scaffold.dart';
import 'package:fsheets/components/typed_text_field.dart';
import 'package:fsheets/logic/data_type.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AppScaffold(body: Column(children: [TestForm()])),
    );
  }
}

// dev only
class TestForm extends StatefulWidget {
  const TestForm({super.key});

  @override
  State<StatefulWidget> createState() => _TestFormState();
}

class _TestFormState extends State<TestForm> {
  final GlobalKey<FormState> formKey = GlobalKey();
  bool isValid = false;

  @override
  Widget build(BuildContext context) => Form(
    key: formKey,
    child: Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        spacing: 20,
        children: [
          IntegerTextField(
            dataType: IntegerDataType(nullable: false),
            labelText: "Required int",
          ),
          IntegerTextField(
            dataType: IntegerDataType(nullable: false, min: 1, max: 5),
            labelText: "Required int in [1, 5]",
          ),
          DoubleTextField(
            dataType: DoubleDataType(nullable: false),
            labelText: "Required int",
          ),
          StringTextField(
            dataType: StringDataType(nullable: false, minLen: 5, maxLen: 5),
            labelText: "Required length 5 string",
          ),
          Row(
            spacing: 10,
            children: [
              FloatingActionButton.extended(
                label: Text("Validate"),
                onPressed: () {
                  setState(() {
                    isValid = formKey.currentState!.validate();
                  });
                },
              ),
            ],
          ),
          if (isValid) Row(children: [Text("Input valid!")]),
        ],
      ),
    ),
  );
}
