/// Data type logic library
library;

const String intTypeName = "int";
const String doubleTypeName = "double";
const String stringTypeName = "str";

const String dtypeRegExpSource = r"^([a-zA-Z][a-zA-Z0-9_]+)(\?)?(<[^>\n]*>)?$";
const String intArgsRegExpSource = r"^<(\-?[0-9]+)?, ?(\-?[0-9]+)?>$";
const String doubleArgsRegExpSource = r"^<(\-?[0-9\.]+)?, ?(\-?[0-9\.]+)?>$";

/// Enum representing the possible outcomes of an existence check.
enum NullState { legallyNull, illegallyNull, notNull }

/// A BetterSheets data type is implemented as a wrapper around a Dart type [T].
///
/// The abstract [DataType] class defines information about a BetterSheets
/// data type.
abstract class DataType<T> {
  /// Boolean indicating whether the data type is required (`nullable == false`)
  /// or optional (`nullable == true`).
  final bool nullable;

  /// Constructor
  const DataType({required this.nullable});

  /// Getter to a function to parse this data type.
  ///
  /// **Example**: the [IntegerDataType] class, which extends the [DataType]
  /// class through the [NumericDataType] class, has the parse function
  /// [int.tryParse].
  ///
  /// **Note**: This is implemented as an abstract getter to a function rather
  /// than an abstract method because the [parseFn] doesn't need to accept the
  /// data type (`this`) as a parameter and Dart doesn't support abstract static
  /// methods.
  T? Function(String) get parseFn;

  /// Getter to get the name of this data type as a String.
  String get typeName;

  static DataType? fromString(String input) {
    final typeRe = RegExp(dtypeRegExpSource);
    final typeMatch = typeRe.firstMatch(input);

    if (typeMatch == null) {
      return null;
    }

    var typeName = typeMatch.group(1);
    if (typeName == null) {
      return null;
    }

    final questionMark = typeMatch.group(2);
    final nullable = questionMark == "?";

    final typeInfo = typeMatch.group(3);

    switch (typeName) {
      // parse integer type
      case intTypeName:
        if (typeInfo != null) {
          final intArgsRe = RegExp(intArgsRegExpSource);
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
          final doubleArgsRe = RegExp(doubleArgsRegExpSource);
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
          final strArgsRe = RegExp(intArgsRegExpSource);
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

  /// Method to perform the existence checking stage of input validation.
  ///
  /// Returns a `NullState` indicating the outcome of the existence check.
  NullState existsChcek(String? input) {
    if (input == null || input.isEmpty || input.toLowerCase() == "null") {
      if (nullable) {
        // null and nullable
        return NullState.legallyNull;
      }
      // null and not nullable
      return NullState.illegallyNull;
    }
    // not null
    return NullState.notNull;
  }

  /// Abstract method to range-check a value of type `T`.
  ///
  /// **Note**:  This is implemented as an abstract method because the
  /// `rangeCheck` method does need to accept the data type as a parameter,
  /// since the child classes store range information as instance variables.
  String? rangeCheck(T val);

  String? validate(String? input) {
    // existence check
    switch (existsChcek(input)) {
      case NullState.illegallyNull:
        return "This value is required!";
      case NullState.legallyNull:
        return null; // exit the function
      case NullState.notNull:
        break; // don't exit the function
    }

    // type check; note the input == null case is handled in existence checking
    T? val = parseFn(input!);
    if (val == null) {
      return "Can't parse $T from $input";
    }

    // range check
    String? res = rangeCheck(val as T);
    if (res != null) {
      return res;
    }

    // all done
    return null;
  }

  @override
  String toString() => "$typeName${nullable ? "?" : ""}";

  @override
  bool operator ==(Object other) =>
      (other is DataType &&
      typeName == other.typeName &&
      nullable == other.nullable);

  @override
  int get hashCode => Object.hash(nullable, parseFn, typeName);
}

/// The BetterSheets string data type is a wrapper around Dart's [String] type.
class StringDataType extends DataType<String> {
  // Minimum length of strings accepted by the data type.
  final int? minLen;
  // Maximum length of strings accepted by the data type.
  final int? maxLen;

  const StringDataType({required super.nullable, this.minLen, this.maxLen});

  @override
  String get typeName => stringTypeName;

  /// Parse function that accepts
  @override
  String? Function(String) get parseFn => ((val) => val);

  // handle null slightly differently from other data types
  @override
  NullState existsChcek(String? input) {
    if (input == null || input.isEmpty || input.toLowerCase() == "null") {
      // NOTE: BetterSheets does not differentiate between null and "" (empty
      // string).
      if (nullable || minLen == 0) {
        // null and nullable
        return NullState.legallyNull;
      }
      // null and not nullable
      return NullState.illegallyNull;
    }
    // not null
    return NullState.notNull;
  }

  @override
  String? rangeCheck(String val) {
    bool invalidLeft = (minLen != null && val.length < minLen!);
    bool invalidRight = (maxLen != null && val.length > maxLen!);

    if (invalidLeft || invalidRight) {
      return "Length ${val.length} of value '$val' not in range [${minLen ?? "-inf"}, ${maxLen ?? "inf"}]";
    }

    return null;
  }

  @override
  String toString() => (minLen == null && maxLen == null)
      ? super.toString()
      : "${super.toString()}<${minLen ?? ""},${maxLen ?? ""}>";
}

/// Implements functionality shared between concrete numeric data types
/// available in BetterSheets.
///
/// The abstract [NumericDataType] class has a type parameter [T] that extends
/// the [num] class. It is the Dart data type that this BetterSheets data type
/// wraps around.
abstract class NumericDataType<T extends num> extends DataType<T> {
  /// The minimum value accepted by the data type.
  final T? min;

  /// The maximum value accepted by the data type.
  final T? max;

  const NumericDataType({required super.nullable, this.min, this.max});

  @override
  String? rangeCheck(T val) {
    bool invalidLeft = (min != null && val < min!);
    bool invalidRight = (max != null && val > max!);

    if (invalidLeft || invalidRight) {
      return "Value $val not in range [${min ?? "-inf"}, ${max ?? "inf"}]";
    }

    return null;
  }

  @override
  String toString() => (min == null && max == null)
      ? super.toString()
      : "${super.toString()}<${min ?? ""},${max ?? ""}>";
}

/// The BetterSheets integer data type is a wrapper around Dart's [int] type.
class IntegerDataType extends NumericDataType<int> {
  const IntegerDataType({required super.nullable, super.min, super.max});

  @override
  String get typeName => intTypeName;

  @override
  int? Function(String) get parseFn => int.tryParse;

  @override
  bool operator ==(Object other) =>
      (other is IntegerDataType && min == other.min && max == other.max);

  @override
  int get hashCode => Object.hash(super.hashCode, min, max);
}

/// The BetterSheets double data type is a wrapper around Dart's [double] type.
class DoubleDataType extends NumericDataType<double> {
  const DoubleDataType({required super.nullable, super.min, super.max});

  @override
  String get typeName => doubleTypeName;

  @override
  double? Function(String) get parseFn => double.tryParse;
}
