/// Schema logic library
library;

import 'dart:collection';
import 'package:bettersheets_ui/logic/data_type.dart';

const columnSchemaRegExpSource =
    r"^([a-zA-Z][a-zA-Z0-9_]+): ([^ =\n]+)( = .+)?$";

const String stringLiteralRegExpSource = r'^"([^"]+)"$';

String? parseStringLiteral(String val) {
  if (RegExp(stringLiteralRegExpSource).hasMatch(val)) {
    return val.substring(1, val.length - 1);
  }
  return null;
}

/// A table schema stores information about a table, including the table name,
/// column schemas, and constraint schemas.
class TableSchema {
  final String tableName;
  final HashMap<String, ColumnSchema> _columns;
  final List<ConstraintSchema>? constraints;

  Iterable<MapEntry<String, ColumnSchema>> get columns => _columns.entries;

  const TableSchema({
    required this.tableName,
    required HashMap<String, ColumnSchema<dynamic>> columns,
    this.constraints,
  }) : _columns = columns;
}

/// Abstract parent class of [UniqueConstraintSchema] and [FKConstraintSchema].
abstract class ConstraintSchema {
  final List<String> columns;

  const ConstraintSchema({required this.columns});
}

/// A unique constraint schema stores information about a unique constraint,
/// including the rows that form the identifying key. Parent class of
/// [PKConstraintSchema].
class UniqueConstraintSchema extends ConstraintSchema {
  const UniqueConstraintSchema({required super.columns});
}

/// A foreign key constraint schema stores information about a foreign key,
/// including the columns it applies to and the table and columns it references.
class FKConstraintSchema extends ConstraintSchema {
  final TableSchema referencesTable;
  final List<ColumnSchema> referencesColumns;

  const FKConstraintSchema({
    required super.columns,
    required this.referencesTable,
    required this.referencesColumns,
  });
}

/// A primary key constraint schema stores information about a primary key,
/// including the columns it applies to.
class PKConstraintSchema extends UniqueConstraintSchema {
  const PKConstraintSchema({required super.columns});
}

/// A column schema stores information about a column, including its name, the
/// type of data it stores and its nullability, and the default value if
/// applicable.
class ColumnSchema<T> {
  final String columnName;
  final DataType<T> dataType;
  final T? defaultValue;

  ColumnSchema({
    required this.columnName,
    required this.dataType,
    this.defaultValue,
  });

  static ColumnSchema? fromString(String input) {
    // extract information from the column schema using a RegExp
    final columnSchemaRe = RegExp(columnSchemaRegExpSource);
    final columnSchemaMatch = columnSchemaRe.firstMatch(input);

    if (columnSchemaMatch == null) {
      return null;
    }

    final columnName = columnSchemaMatch.group(1);
    final dtypeStr = columnSchemaMatch.group(2);
    final defaultStr = columnSchemaMatch.group(3)?.substring(3);

    if (columnName == null || dtypeStr == null) {
      return null;
    }

    final dataType = DataType.fromString(dtypeStr);
    if (dataType == null) {
      return null;
    }

    // parse the default value
    dynamic defaultValue;
    if (defaultStr != null) {
      if (dataType is StringDataType) {
        // string literals need to be handled differently when parsing a schema
        // because they need to be inside quotes.
        defaultValue = parseStringLiteral(defaultStr);
      } else {
        defaultValue = dataType.parseFn(defaultStr);
      }
      if (defaultValue == null) {
        // defaultStr != null but defaultValue == null means a defaultValue was
        // provided but it could not be parsed
        return null;
      }
    }

    return ColumnSchema(
      columnName: columnName,
      dataType: dataType,
      defaultValue: defaultValue,
    );
  }

  @override
  String toString() => defaultValue == null
      ? "$columnName: $dataType"
      : defaultValue is String
      ? "$columnName: $dataType = \"$defaultValue\""
      : "$columnName: $dataType = $defaultValue";
}
