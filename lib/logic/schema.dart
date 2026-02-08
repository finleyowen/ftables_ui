/// Schema logic library
library;

import 'package:fsheets/logic/data_type.dart';

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
  final DataType<T> dataType;
  final T? defaultValue;

  ColumnSchema({
    required this.columnName,
    required this.dataType,
    this.defaultValue,
  });

  /// Convert a column schema to a string using the FSheets schema
  /// syntax.
  @override
  String toString() => defaultValue == null
      ? "$columnName:$dataType"
      : defaultValue is String
      ? "$columnName:$dataType=\"$defaultValue\""
      : "$columnName:$dataType=$defaultValue";
}
