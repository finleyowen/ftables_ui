import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fsheets/logic/data_type.dart';

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
