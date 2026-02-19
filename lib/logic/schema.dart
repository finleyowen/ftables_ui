/// Schema logic library
library;

import 'package:fsheets/logic/data_type.dart';

class SpreadsheetSchema {
  final String spreadsheetName;
  final List<TableSchema> tables;

  const SpreadsheetSchema({
    required this.spreadsheetName,
    required this.tables,
  });

  factory SpreadsheetSchema.fromJson(Map<String, dynamic> json) =>
      SpreadsheetSchema(
        spreadsheetName: json['ss_name'],
        tables: (json['tables'] as List<dynamic>)
            .map(
              (tableJson) =>
                  TableSchema.fromJson(tableJson as Map<String, dynamic>),
            )
            .toList(),
      );

  @override
  String toString() => tables.join(";\n");
}

/// A table schema stores information about a table, including the table name,
/// column schemas, and constraint schemas.
class TableSchema {
  final String tableName;
  final List<ColumnSchema> columns;
  final List<ConstraintSchema>? constraints;

  const TableSchema({
    required this.tableName,
    required this.columns,
    this.constraints,
  });

  factory TableSchema.fromJson(Map<String, dynamic> json) => TableSchema(
    tableName: json['table_name'] as String,
    columns: (json['columns'] as List<dynamic>)
        .map(
          (columnJson) =>
              ColumnSchema.fromJson(columnJson as Map<String, dynamic>),
        )
        .toList(),
  );

  @override
  String toString() =>
      "$tableName(${columns.join(",")}${constraints != null ? ",${constraints!.join(",")}" : ""})";
}

/// Abstract parent class of [UniqueConstraintSchema] and [FKConstraintSchema].
abstract class ConstraintSchema {
  final List<String> columns;

  const ConstraintSchema({required this.columns});

  /// Convert a constraint schema to a string using the FSheets schema
  /// syntax.
  @override
  String toString() => "(${columns.join(";")})";
}

/// A unique constraint schema stores information about a unique constraint,
/// including the rows that form the identifying key. Parent class of
/// [PKConstraintSchema].
class UniqueConstraintSchema extends ConstraintSchema {
  const UniqueConstraintSchema({required super.columns});

  @override
  String toString() => "@${super.toString()}";
}

/// A foreign key constraint schema stores information about a foreign key,
/// including the columns it applies to and the table and columns it references.
class FKConstraintSchema extends ConstraintSchema {
  final String referencesTable;
  final List<String> referencesColumns;

  const FKConstraintSchema({
    required super.columns,
    required this.referencesTable,
    required this.referencesColumns,
  });

  @override
  String toString() =>
      "#${super.toString()}&$referencesTable(${referencesColumns.join(";")})";
}

/// A primary key constraint schema stores information about a primary key,
/// including the columns it applies to.
class PKConstraintSchema extends UniqueConstraintSchema {
  const PKConstraintSchema({required super.columns});

  @override
  String toString() => "!${super.toString()}";
}

/// A column schema stores information about a column, including its name, the
/// type of data it stores and its nullability, and the default value if
/// applicable.
class ColumnSchema<T> {
  final String columnName;
  final DataType<T> columnType;
  final T? defaultValue;

  ColumnSchema({
    required this.columnName,
    required this.columnType,
    this.defaultValue,
  });

  static ColumnSchema fromJson(Map<String, dynamic> json) => ColumnSchema(
    columnName: json["column_name"],
    columnType: DataType.fromJson(json["column_type"]),
    defaultValue: json["default_value"],
  );

  /// Convert a column schema to a string using the FSheets schema
  /// syntax.
  @override
  String toString() => defaultValue == null
      ? "$columnName:$columnType"
      : defaultValue is String
      ? "$columnName:$columnType=\"$defaultValue\""
      : "$columnName:$columnType=$defaultValue";
}
