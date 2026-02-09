import 'package:flutter/material.dart';
import 'package:fsheets/components/app_scaffold.dart';
import 'package:fsheets/components/typed_text_field.dart';
import 'package:fsheets/logic/schema.dart';

class TableFormView extends StatelessWidget {
  final TableSchema schema;
  final formKey = GlobalKey<FormState>();

  TableFormView({super.key, required this.schema});

  @override
  Widget build(BuildContext context) => AppScaffold(
    body: Form(
      key: formKey,
      child: Column(
        spacing: 30,
        children: [
          Row(
            children: [
              Text(
                schema.tableName,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ],
          ),
          for (final column in schema.columns)
            TypedTextField.fromColumnSchema(column)!,
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
    ),
  );
}
