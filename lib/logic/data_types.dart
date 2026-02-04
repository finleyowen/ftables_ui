/// Data types logic library
library;

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

  /// Abstract getter to a function to parse this data type.
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
}

/// The BetterSheets string data type is a wrapper around Dart's [String] type.
class StringDataType extends DataType<String> {
  // Minimum length of strings accepted by the data type.
  final int? minLen;
  // Maximum length of strings accepted by the data type.
  final int? maxLen;

  const StringDataType({required super.nullable, this.minLen, this.maxLen});

  /// Trivial 'parse' function; not actually used but needs to be defined as it
  /// overrides an abstract getter in the parent class
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
    bool invalidRight = (maxLen != null && val.length < maxLen!);

    if (invalidLeft || invalidRight) {
      return "Length ${val.length} of value '$val' not in range [${minLen ?? "-inf"}, ${maxLen ?? "inf"}]";
    }

    return null;
  }
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
    bool invalidRight = (max != null && val < max!);

    if (invalidLeft || invalidRight) {
      return "Value $val not in range [${min ?? "-inf"}, ${max ?? "inf"}]";
    }

    return null;
  }
}

/// The BetterSheets integer data type is a wrapper around Dart's [int] type.
class IntegerDataType extends NumericDataType<int> {
  const IntegerDataType({required super.nullable, super.min, super.max});

  @override
  int? Function(String) get parseFn => int.tryParse;
}

/// The BetterSheets double data type is a wrapper around Dart's [double] type.
class DoubleDataType extends NumericDataType<double> {
  const DoubleDataType({required super.nullable, super.min, super.max});

  @override
  double? Function(String) get parseFn => double.tryParse;
}
