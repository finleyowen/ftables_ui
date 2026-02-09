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

  static TypedTextField? fromColumnSchema(ColumnSchema columnSchema) {
    switch (columnSchema.dataType) {
      case IntegerDataType _:
        return IntegerTextField(
          dataType: columnSchema.dataType as IntegerDataType,
          labelText: columnSchema.columnName,
          controller: TextEditingController(
            text: columnSchema.defaultValue != null
                ? columnSchema.defaultValue.toString()
                : "",
          ),
        );
      case DoubleDataType _:
        return DoubleTextField(
          dataType: columnSchema.dataType as DoubleDataType,
          labelText: columnSchema.columnName,
          controller: TextEditingController(
            text: columnSchema.defaultValue != null
                ? columnSchema.defaultValue.toString()
                : "",
          ),
        );
      case StringDataType _:
        return StringTextField(
          dataType: columnSchema.dataType as StringDataType,
          labelText: columnSchema.columnName,
          controller: TextEditingController(
            text: columnSchema.defaultValue != null
                ? columnSchema.defaultValue.toString()
                : "",
          ),
        );
    }
    return TypedTextField(dataType: columnSchema.dataType, labelText: "");
  }

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: labelText,
      hintText: dataType.toString(),
    ),
    validator: dataType.validate,
    inputFormatters: inputFormatters,
  );
}

class IntegerTextField extends TypedTextField<IntegerDataType> {
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

class DoubleTextField extends TypedTextField<DoubleDataType> {
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
