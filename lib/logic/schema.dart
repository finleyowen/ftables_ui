/// Schema logic library
library;

import 'dart:collection';
import 'package:bettersheets_ui/logic/data_type.dart';

/// A table schema stores information about a table, including the table name,
/// column schemas, and constraint schemas.
class TableSchema {
  final String tableName;
  final HashMap<String, ColumnSchema> _columns;
  final List<ConstraintSchema>? constraints;

  ColumnSchema? getColumn(String columnName) => _columns[columnName];

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
/// type of data it stores and its nullability, the default value if applicable,
/// and the uniqueness of the column.
class ColumnSchema<T> {
  final String columnName;
  final DataType<T> dataType;
  final T? defaultValue;
  late final bool _unique;

  ColumnSchema({
    required this.columnName,
    required this.dataType,
    this.defaultValue,
    bool unique = false,
  }) {
    // call the 'unique' setter (might throw an ArgumentError)
    this.unique = unique;
  }

  bool get unique => _unique;

  set unique(bool val) {
    if (dataType is DoubleDataType) {
      throw ArgumentError("Data type $dataType cannot be unique!");
    }
  }
}
