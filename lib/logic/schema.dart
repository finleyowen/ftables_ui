/// Schema logic library
library;

import 'package:fsheets/logic/data_type.dart';

const identReSource = r"[a-zA-Z][a-zA-Z0-9_]*";
const identListReSource = r"[a-zA-Z0-9; ]+";

const tableSchemaReSource = "($identListReSource)\\((.+)\\)";

const columnSchemaRegExpSource = "^($identReSource): ?([^=\\n]+)( ?= ?(.+))?\$";

const uniqueConstraintSchemaRegExpSource = "^@\\(($identListReSource)\\)\$";
const pkConstraintSchemaRegExpSource = "^!@\\(($identListReSource)\\)\$";

const fkConstraintSchemaRegExpSource =
    "#\\(($identListReSource)\\) ?&($identReSource)\\(($identListReSource)\\)";

const stringLiteralRegExpSource = r'^"([^"]+)"$';

String? parseStringLiteral(String s) {
  if (RegExp(stringLiteralRegExpSource).hasMatch(s)) {
    return s.substring(1, s.length - 1);
  }
  return null;
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

  /// Parse a table schema from a string using the application DDL if possible.
  static TableSchema? fromString(String tableStr) {
    final tableSchemaRe = RegExp(tableSchemaReSource);
    final tableSchemaMatch = tableSchemaRe.firstMatch(tableStr);

    final tableName = tableSchemaMatch?.group(1);
    final columnsConstraintsStr = tableSchemaMatch?.group(2);

    if (tableName == null || columnsConstraintsStr == null) {
      return null;
    }

    List<ColumnSchema> columns = [];
    List<ConstraintSchema> constraints = [];

    for (final columnConstraintStr in columnsConstraintsStr.split(",")) {
      final column = ColumnSchema.fromString(columnConstraintStr);
      if (column != null) {
        columns.add(column);
        continue;
      }
      final constraint = ConstraintSchema.fromString(columnConstraintStr);
      if (constraint != null) {
        constraints.add(constraint);
        continue;
      }
      if (column == null && constraint == null) {
        return null;
      }
    }

    return TableSchema(
      tableName: tableName,
      columns: columns,
      constraints: constraints.isEmpty ? null : constraints,
    );
  }

  @override
  String toString() =>
      "$tableName(${columns.join(",")}${constraints != null ? ",${constraints!.join(",")}" : ""})";
}

/// Abstract parent class of [UniqueConstraintSchema] and [FKConstraintSchema].
abstract class ConstraintSchema {
  final List<String> columns;

  const ConstraintSchema({required this.columns});

  static List<String>? _getColumnNames(String s) {
    final columns = s.split(";").map((columnName) => columnName.trim());
    final columnNameRe = RegExp(identReSource);
    for (final columnName in columns) {
      if (!columnNameRe.hasMatch(columnName)) {
        return null;
      }
    }
    return columns.toList();
  }

  /// Parse a constraint schema from a string using the application DDL if
  /// possible.
  static ConstraintSchema? fromString(String s) {
    if (s.startsWith("@")) {
      // unique
      final uniqueConstraintSchemaRe = RegExp(
        uniqueConstraintSchemaRegExpSource,
      );
      final columnsStr = uniqueConstraintSchemaRe.firstMatch(s)?.group(1);
      if (columnsStr == null) {
        return null;
      }
      final columns = _getColumnNames(columnsStr);
      if (columns == null) {
        return null;
      }
      return UniqueConstraintSchema(columns: columns);
    } else if (s.startsWith("!@")) {
      // pk
      final pkConstraintSchemaRe = RegExp(pkConstraintSchemaRegExpSource);
      final columnsStr = pkConstraintSchemaRe.firstMatch(s)?.group(1);
      if (columnsStr == null) {
        return null;
      }
      final columns = _getColumnNames(columnsStr);
      if (columns == null) {
        return null;
      }
      return PKConstraintSchema(columns: columns);
    } else if (s.startsWith("#")) {
      // fk
      final fkConstraintSchema = RegExp(fkConstraintSchemaRegExpSource);
      final fkConstraintSchemaMatch = fkConstraintSchema.firstMatch(s);

      final columnsStr = fkConstraintSchemaMatch?.group(1);
      if (columnsStr == null) {
        return null;
      }
      final columns = _getColumnNames(columnsStr);
      final referencesTable = fkConstraintSchemaMatch?.group(2);
      final referencesColumns = fkConstraintSchemaMatch?.group(3)?.split(";");

      if (columns == null ||
          referencesTable == null ||
          referencesColumns == null) {
        return null;
      }

      return FKConstraintSchema(
        columns: columns,
        referencesTable: referencesTable,
        referencesColumns: referencesColumns,
      );
    }
    return null;
  }

  /// Convert a constraint schema to a string using the BetterSheets schema
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

  /// Parse a column schema from a string using the application DDL if possible.
  static ColumnSchema? fromString(String s) {
    // extract information from the column schema using a RegExp
    final columnSchemaRe = RegExp(columnSchemaRegExpSource);
    final columnSchemaMatch = columnSchemaRe.firstMatch(s);

    if (columnSchemaMatch == null) {
      return null;
    }

    final columnName = columnSchemaMatch.group(1);
    final dtypeStr = columnSchemaMatch.group(2);
    late final String? defaultStr;

    // if the schema string has a ' ?= ?(.+)' group
    if (columnSchemaMatch.group(3) != null) {
      // get the expression after the ' ?= ?'
      defaultStr = columnSchemaMatch.group(4);
    } else {
      defaultStr = null;
    }

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

  /// Convert a column schema to a string using the BetterSheets schema
  /// syntax.
  @override
  String toString() => defaultValue == null
      ? "$columnName:$dataType"
      : defaultValue is String
      ? "$columnName:$dataType=\"$defaultValue\""
      : "$columnName:$dataType=$defaultValue";
}
