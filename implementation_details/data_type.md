# FSheets Data Types

See [source code](../lib/logic/data_type.dart)  
See [tests](../tests/data_type.dart)  

In this repository, FSheets data types are implemented as wrappers around Dart data types. They inherit from the abstract `DataType<T>` class, where `T` is the Dart type that the FSheets type wraps around. The `DataType<T>` class and its subclasses are responsible for validating input.


## Built-in types

Currently, TodoBetter provides the following concrete subclasses of `DataType<T>` (note that `NumericDataType<T extends num>` is an abstract subclass of `DataType<T>`):
- `IntegerDataType extends NumericDataType<int>`
- `DoubleDataType extends NumericDataType<double>`
- `StringDataType extends DataType<String>`

## Nullability and existence checking

Any data type can be made nullable in the application. Nullability and existence checking are
handled in the base `DataType<T>` class (although this behaviour is overridden by in the `StringDataType` class).

## Type checking

Type checking is performed by attempting to parse the data type from the input. The `DataType<T>` class has an abstract `T? Function(String) parseFn` getter that subclasses should override to return a function like `int.tryParse` or `double.tryParse`.

## Range checking

Concrete subclasses of `NumericDataType<T extends num>` can store a min and max value (of type `T`) and perform range checks on input. The `StringDataType` class can store a min and max length (of type `int`) and perform range checks on input.

## Textual representation

The application has a system for encoding and decoding information about schemas from text, including parsing data types from text and converting them into text using the application's schema textual representation.

## Important note for nullable string types

The application **does not** differentiate between null and "" (empty string). 

So, the data type represented by `str?<5, 10>` will accept an empty string, or a string with length in range [5, 10]. It won't accept a string with length in range [1, 4] or length > 11.

If a string type is non-nullable, and no minimum length is set (or the minimum length is set to 0), the behaviour will be equivalent to the minimum length being set to 1.

So, the data types `str?<, 10>`, `str<, 10>`, `str?<1, 10>` are all equivalent (but not to `str<1, 10>` or `str?<2, 10>`)

The application **does** differentiate between null and 0 for numeric data types.