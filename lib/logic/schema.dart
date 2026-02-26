/// Schema logic library
library;

import 'dart:collection';

import 'package:fsheets/logic/data_type.dart';

class SpreadsheetSchema {
  final HashMap<String, TableSchema> tables;
  final List<String> tableNames;

  const SpreadsheetSchema({required this.tables, required this.tableNames});

  factory SpreadsheetSchema.fromJson(Map<String, dynamic> json) {
    final tables = (json["tables"] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, TableSchema.fromJson(v)),
    );
    final tableNames = (json["tables"] as Map<String, dynamic>).keys.toList();
    return SpreadsheetSchema(
      tables: HashMap.fromEntries(tables.entries),
      tableNames: tableNames,
    );
  }

  // todo
  @override
  String toString() => "";
}

/// A table schema stores information about a table, including the table name,
/// column schemas, and constraint schemas.
class TableSchema {
  final HashMap<String, ColumnSchema> columns;
  final List<String> columnNames;
  final List<ConstraintSchema>? constraints;

  const TableSchema({
    required this.columns,
    required this.columnNames,
    this.constraints,
  });

  factory TableSchema.fromJson(Map<String, dynamic> json) {
    final columns = json['columns'] as Map<String, dynamic>;
    return TableSchema(
      columns: HashMap.fromEntries(
        columns.map((k, v) => MapEntry(k, ColumnSchema.fromJson(v))).entries,
      ),
      columnNames: columns.keys.toList(),
    );
  }

  @override
  String toString() {
    // note columnStrs (column strings) vs columnsStr (columns string)
    final columnStrs = columns.keys.map(
      (columnName) => "$columnName: ${columns[columnName].toString()}",
    );
    final columnsStr = columnStrs.join(", ");
    return "($columnsStr)";
  }
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
  final DataType<T> columnType;
  final T? defaultValue;

  ColumnSchema({required this.columnType, this.defaultValue});

  static ColumnSchema fromJson(Map<String, dynamic> json) => ColumnSchema(
    columnType: DataType.fromJson(json["column_type"]),
    defaultValue: json["default_value"],
  );

  /// Convert a column schema to a string using the FSheets schema
  /// syntax.
  @override
  String toString() => defaultValue == null
      ? "$columnType"
      : defaultValue is String
      ? "$columnType=\"$defaultValue\""
      : "$columnType=$defaultValue";
}
