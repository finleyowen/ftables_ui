# BetterSheets Data Types

See [source code](../lib/logic/data_type.dart)  

In this repository, BetterSheets data types are implemented as wrappers around Dart data types. They inherit from the abstract `DataType<T>` class, where `T` is the Dart type that the BetterSheets type wraps around. The `DataType<T>` class and its subclasses are responsible for validating input.


## Built-in types

Currently, TodoBetter provides the following concrete subclasses of `DataType<T>` (note that `NumericDataType<T extends num>` is an abstract child class of `DataType<T>`):
- `IntegerDataType extends NumericDataType<int>`
- `DoubleDataType extends NumericDataType<double>`
- `StringDataType extends DataType<String>`

## Nullability and existence checking

Any data type can be made nullable in BetterSheets. Nullability and existence checking are
handled in the base `DataType<T>` class (although this behaviour is overridden by in the `StringDataType` class). Some important notes about nullability in BetterSheets:

## Type checking

Type checking is performed by attempting to parse the data type from the input. The `DataType<T>` class has an abstract `T? Function(String) parseFn` getter that subclasses should override to return a function like `int.tryParse` or `double.tryParse`.

## Range checking

Concrete subclasses of `NumericDataType<T extends num>` can store a min and max value (of type `T`) and perform range checks on input. The `StringDataType` class can store a min and max length (of type `int`) and perform range checks on input.

## Textual representation

BetterSheets will have a system for encoding and decoding data type information into textual format. The following examples demonstrate the syntax of the BetterSheets data type textual representations. Note that there are no whitespaces anywhere in the textual representations of TodoBetter types (as a requirement).

Non-nullable integer data type with no range restrictions:
```
int
```

Nullable integer data type with no range restrictions:
```
int?
```

Non-nullable integer data type with minimum 0 (inclusive):
```
int<0,>
```

Non-nullable integer data type with no minimum, maximum 10 (inclusive):
```
int<,10>
```

Non-nullable integer data type with range [0, 10] (inclusive both sides):
```
int<0,10>
```

Nullable integer data type with range [0, 10] (inclusive both sides):
```
int?<0,10>
```

Nullable double data type with range [0.0, 10.0] (inclusive both sides):
```
double?<0.0, 10.0>
```

Nullable string data type with length in range [5, 10]:
```
str?<5, 10>
```

## Important note for nullable string types

BetterSheets **does not** differentiate between null and "" (empty string). 

So, the data type represented by `str?<5, 10>` will accept an empty string, or a string with length in range [5, 10]. It won't accept a string with length in range [1, 4] or length > 11.

If a string type is non-nullable, and no minimum length is set (or the minimum length is set to 0), the behaviour will be equivalent to the minimum length being set to 1.

So, the data types `str?<, 10>`, `str<, 10>`, `str?<1, 10>` are all equivalent (but not to `str<1, 10>` or `str?<2, 10>`)

BetterSheets **does** differentiate between null and 0 for numeric data types.