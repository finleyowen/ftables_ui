/// DDL library
library;

import 'package:fsheets/logic/data_type.dart';
import 'package:fsheets/logic/schema.dart';

const identPat = r"[a-zA-Z][a-zA-Z0-9_]*";

const identListPat = r"[a-zA-Z0-9;\s\n\t]+";

const optWhiteSpacePat = r"[\s\n\t]*";

const dtypePat = "^($identPat)(\\?)?(<[^>\\n]*>)?\$";

const intArgsPat = "^<($intPat)?;$optWhiteSpacePat($intPat)?>\$";

const doubleArgsPat = "^<($doublePat)?;$optWhiteSpacePat($doublePat)?>\$";

const tableSchemaPat = "^($identListPat)$optWhiteSpacePat\\((.+)\\)\$";

const columnSchemaPat =
    "^($identPat):$optWhiteSpacePat([^=]+)($optWhiteSpacePat=$optWhiteSpacePat(.+))?\$";

const uniqueConstraintSchemaPat = "^@\\(($identListPat)\\)\$";

const pkConstraintSchemaPat = "^!@\\(($identListPat)\\)\$";

const fkConstraintSchemaPat =
    "#\\(($identListPat)\\) ?&($identPat)\\(($identListPat)\\)";

const stringLiteralPat = r'^"([^"]+)"$';

List<String>? _getIdents(String identList) {
  final idents = identList.split(";").map((columnName) => columnName.trim());
  final columnNameRe = RegExp(identPat);
  for (final columnName in idents) {
    if (!columnNameRe.hasMatch(columnName)) {
      return null;
    }
  }
  return idents.toList();
}

String? _parseStringLiteral(String s) {
  if (RegExp(stringLiteralPat).hasMatch(s)) {
    return s.substring(1, s.length - 1);
  }
  return null;
}

/// Parse a data type from a string using the application's DDL
DataType? parseDataType(String s) {
  {
    final typeRe = RegExp(dtypePat);
    final typeMatch = typeRe.firstMatch(s.trim());

    var typeName = typeMatch?.group(1);
    if (typeName == null) {
      return null;
    }

    final questionMark = typeMatch?.group(2);
    final nullable = questionMark == "?";

    final typeInfo = typeMatch?.group(3);

    switch (typeName) {
      // parse integer type
      case intTypeName:
        if (typeInfo != null) {
          final intArgsRe = RegExp(intArgsPat);
          final intArgsMatch = intArgsRe.firstMatch(typeInfo);

          if (intArgsMatch == null) {
            return null;
          }

          final minStr = intArgsMatch.group(1);
          final maxStr = intArgsMatch.group(2);

          late final int? min, max;

          try {
            min = minStr == null || minStr == "" ? null : int.parse(minStr);
            max = maxStr == null || minStr == "" ? null : int.parse(maxStr);
          } catch (err) {
            return null;
          }

          return IntegerDataType(nullable: nullable, min: min, max: max);
        }
        return IntegerDataType(nullable: nullable);
      // parse double type
      case doubleTypeName:
        if (typeInfo != null) {
          final doubleArgsRe = RegExp(doubleArgsPat);
          final doubleArgsMatch = doubleArgsRe.firstMatch(typeInfo);

          if (doubleArgsMatch == null) {
            return null;
          }

          final minStr = doubleArgsMatch.group(1);
          final maxStr = doubleArgsMatch.group(2);

          late final double? min, max;

          try {
            min = minStr == null || minStr == "" ? null : double.parse(minStr);
            max = maxStr == null || minStr == "" ? null : double.parse(maxStr);
          } catch (err) {
            return null;
          }

          return DoubleDataType(nullable: nullable, min: min, max: max);
        }
        return DoubleDataType(nullable: nullable);
      // parse string type
      case stringTypeName:
        if (typeInfo != null) {
          final strArgsRe = RegExp(intArgsPat);
          final strArgsMatch = strArgsRe.firstMatch(typeInfo);

          if (strArgsMatch == null) {
            return null;
          }

          final minLenStr = strArgsMatch.group(1);
          final maxLenStr = strArgsMatch.group(2);

          late final int? minLen, maxLen;

          try {
            minLen = minLenStr == null || minLenStr == ""
                ? null
                : int.parse(minLenStr);
            maxLen = maxLenStr == null || minLenStr == ""
                ? null
                : int.parse(maxLenStr);
          } catch (err) {
            return null;
          }

          return StringDataType(
            nullable: nullable,
            minLen: minLen,
            maxLen: maxLen,
          );
        }
        return StringDataType(nullable: nullable);
      // unrecognised type
      default:
        return null;
    }
  }
}

/// Parse a column schema from a string using the application's DDL
ColumnSchema? parseColumnSchema(String s) {
  {
    // extract information from the column schema using a RegExp
    final columnSchemaRe = RegExp(columnSchemaPat);
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

    final dataType = parseDataType(dtypeStr);
    if (dataType == null) {
      return null;
    }

    // parse the default value
    dynamic defaultValue;
    if (defaultStr != null) {
      if (dataType is StringDataType) {
        // string literals need to be handled differently when parsing a schema
        // because they need to be inside quotes.
        defaultValue = _parseStringLiteral(defaultStr);
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
}

/// Parse a constraint schema from a string using the application's DDL
ConstraintSchema? parseConstraintSchema(String s) {
  if (s.startsWith("@")) {
    // unique
    final uniqueConstraintSchemaRe = RegExp(uniqueConstraintSchemaPat);
    final columnsStr = uniqueConstraintSchemaRe.firstMatch(s)?.group(1);
    if (columnsStr == null) {
      return null;
    }
    final columns = _getIdents(columnsStr);
    if (columns == null) {
      return null;
    }
    return UniqueConstraintSchema(columns: columns);
  } else if (s.startsWith("!@")) {
    // pk
    final pkConstraintSchemaRe = RegExp(pkConstraintSchemaPat);
    final columnsStr = pkConstraintSchemaRe.firstMatch(s)?.group(1);
    if (columnsStr == null) {
      return null;
    }
    final columns = _getIdents(columnsStr);
    if (columns == null) {
      return null;
    }
    return PKConstraintSchema(columns: columns);
  } else if (s.startsWith("#")) {
    // fk
    final fkConstraintSchema = RegExp(fkConstraintSchemaPat);
    final fkConstraintSchemaMatch = fkConstraintSchema.firstMatch(s);

    final columnsStr = fkConstraintSchemaMatch?.group(1);
    if (columnsStr == null) {
      return null;
    }
    final columns = _getIdents(columnsStr);
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

/// Parse a table schema from a string using the application's DDL
TableSchema? parseTableSchema(String s) {
  {
    final tableSchemaRe = RegExp(tableSchemaPat);
    final tableSchemaMatch = tableSchemaRe.firstMatch(s);

    final tableName = tableSchemaMatch?.group(1);
    final columnsConstraintsStr = tableSchemaMatch?.group(2);

    if (tableName == null || columnsConstraintsStr == null) {
      return null;
    }

    List<ColumnSchema> columns = [];
    List<ConstraintSchema> constraints = [];

    for (final s2 in columnsConstraintsStr.split(",")) {
      final s3 = s2.trim();
      final column = parseColumnSchema(s3);
      if (column != null) {
        columns.add(column);
        continue;
      }
      final constraint = parseConstraintSchema(s3);
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
}
