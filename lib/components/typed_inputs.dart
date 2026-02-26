/// Typed inputs module
///
/// Defines widgets that allow the application to recieve and validate input
/// of data types supported by FTables.
///
/// Many of these widgets extend the abstract class [TypedTextField] which is
/// also defined here.
///
/// Copyright Finley Owen 2026. All rights reserved.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fsheets/logic/data_type.dart';
import 'package:fsheets/logic/schema.dart';

class TypedTextField<T extends DataType> extends StatelessWidget {
  final T dataType;
  final String labelText;
  final TextEditingController? controller;

  List<TextInputFormatter>? get inputFormatters => null;

  const TypedTextField({
    super.key,
    required this.dataType,
    required this.labelText,
    this.controller,
  });

  static TypedTextField? fromColumnSchema(
    ColumnSchema columnSchema,
    String columnName,
  ) {
    switch (columnSchema.columnType) {
      case IntDataType _:
        return IntegerTextField(
          dataType: columnSchema.columnType as IntDataType,
          labelText: columnName,
          controller: TextEditingController(
            text: columnSchema.defaultValue != null
                ? columnSchema.defaultValue.toString()
                : "",
          ),
        );
      case DblDataType _:
        return DoubleTextField(
          dataType: columnSchema.columnType as DblDataType,
          labelText: columnName,
          controller: TextEditingController(
            text: columnSchema.defaultValue != null
                ? columnSchema.defaultValue.toString()
                : "",
          ),
        );
      case StringDataType _:
        return StringTextField(
          dataType: columnSchema.columnType as StringDataType,
          labelText: columnName,
          controller: TextEditingController(
            text: columnSchema.defaultValue != null
                ? columnSchema.defaultValue.toString()
                : "",
          ),
        );
    }
    return TypedTextField(dataType: columnSchema.columnType, labelText: "");
  }

  @override
  Widget build(BuildContext context) => Material(
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: dataType.toString(),
      ),
      validator: dataType.validate,
      inputFormatters: inputFormatters,
    ),
  );
}

class IntegerTextField extends TypedTextField<IntDataType> {
  const IntegerTextField({
    super.key,
    required super.dataType,
    required super.labelText,
    super.controller,
  });

  @override
  List<TextInputFormatter>? get inputFormatters => [
    FilteringTextInputFormatter(RegExp(r"[0-9\-]"), allow: true),
  ];
}

class DoubleTextField extends TypedTextField<DblDataType> {
  const DoubleTextField({
    super.key,
    required super.dataType,
    required super.labelText,
    super.controller,
  });

  @override
  List<TextInputFormatter>? get inputFormatters => [
    FilteringTextInputFormatter(RegExp(r"[0-9\.\-]"), allow: true),
  ];
}

class StringTextField extends TypedTextField<StringDataType> {
  const StringTextField({
    super.key,
    required super.dataType,
    required super.labelText,
    super.controller,
  });

  @override
  List<TextInputFormatter>? get inputFormatters => [
    LengthLimitingTextInputFormatter(dataType.maxLen),
  ];
}
