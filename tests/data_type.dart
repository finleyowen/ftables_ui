/// Data types logic tests
library;

import 'package:fsheets/logic/ddl.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void expectMapToDataType(String s) {
  expect(parseDataType(s).toString(), equals(s));
}

void expectParseToDataType(String s) {
  expect(parseDataType(s), isNotNull);
}

void expectNotParseToDataType(String s) {
  expect(parseDataType(s), isNull);
}

void main() {
  test("DataType to/from String test", () {
    expectMapToDataType("int<1;5>");
    expectMapToDataType("int<1;>");
    expectMapToDataType("int<;5>");
    expectMapToDataType("int?<1;5>");
    expectMapToDataType("int?<;5>");
    expectMapToDataType("int?<1;>");
    expectMapToDataType("double<1.0;5.0>");
    expectMapToDataType("double<1.0;>");
    expectMapToDataType("double<;5.0>");
    expectMapToDataType("double?<1.0;5.0>");
    expectMapToDataType("double?<;5.0>");
    expectMapToDataType("double?<1.0;>");
    expectMapToDataType("double?<1.05;7.85>");
    expectMapToDataType("double?<1.01;7.99>");
    expectMapToDataType("str<1;5>");
    expectMapToDataType("str<1;>");
    expectMapToDataType("str<;5>");
    expectMapToDataType("str?<1;5>");
    expectMapToDataType("str?<1;5>");

    expectParseToDataType("int<1; 5>");
    expectParseToDataType("str?<5; 5>");

    expectNotParseToDataType("int<1, 5>");
    expectNotParseToDataType("str?<5, 5>");
  });

  test("Integer validation tests", () {
    final dtype1 = parseDataType("int?<1;5>")!; // optional int in [1, 5]
    expect(dtype1.validate("1"), isNull);
    expect(dtype1.validate("5"), isNull);
    expect(dtype1.validate(""), isNull);
    expect(dtype1.validate(null), isNull);
    expect(dtype1.validate("1.0"), isNotNull); // type error
    expect(dtype1.validate("0"), isNotNull); // range error
    expect(dtype1.validate("6"), isNotNull); // range error again

    final dtype2 = parseDataType("int<1;5>")!; // mandatory int in [1, 5]
    expect(dtype2.validate("1"), isNull);
    expect(dtype2.validate("5"), isNull);
    expect(dtype2.validate(""), isNotNull); // fails existence check
    expect(dtype2.validate(null), isNotNull); // also fails existence check
    expect(dtype1.validate("1.0"), isNotNull); // type error
    expect(dtype1.validate("0"), isNotNull); // range error
    expect(dtype1.validate("6"), isNotNull); // range error again

    final dtype3 = parseDataType("int")!;
    expect(dtype3.validate("12"), isNull);
    expect(dtype3.validate("12209090"), isNull);

    expect(dtype3.validate("12209090.5"), isNotNull);
    expect(dtype3.validate("abcde"), isNotNull);
    expect(dtype3.validate("-120-24"), isNotNull);
    expect(dtype3.validate(""), isNotNull);
    expect(dtype3.validate(null), isNotNull);

    final dtype4 = parseDataType("int?")!;
    expect(dtype4.validate("12"), isNull);
    expect(dtype4.validate("12209090"), isNull);
    expect(dtype4.validate(""), isNull);
    expect(dtype4.validate(null), isNull);

    expect(dtype4.validate("12209090.5"), isNotNull);
    expect(dtype4.validate("abcde"), isNotNull);
    expect(dtype4.validate("-120-24"), isNotNull);
  });

  test("Double validation tests", () {
    final dtype1 = parseDataType(
      "double?<1.0; 5.0>",
    )!; // optional double in [1.0, 5.0]
    expect(dtype1.validate("1.0"), isNull);
    expect(dtype1.validate("5.0"), isNull);
    expect(dtype1.validate(""), isNull);
    expect(dtype1.validate(null), isNull);
    expect(dtype1.validate("a"), isNotNull); // type error
    expect(dtype1.validate("0.999999999999999"), isNotNull); // range error
    expect(
      dtype1.validate("5.000000000000001"),
      isNotNull,
    ); // range error again

    final dtype2 = parseDataType(
      "double<1.0;5.0>",
    )!; // mandatory double in [1, 5]
    expect(dtype2.validate("1"), isNull);
    expect(dtype2.validate("5"), isNull);
    expect(dtype2.validate("1.0"), isNull);
    expect(dtype2.validate("1.0"), isNull);
    expect(dtype2.validate(""), isNotNull); // fails existence check
    expect(dtype2.validate(null), isNotNull); // also fails existence check
    expect(dtype1.validate("a"), isNotNull); // type error
    expect(dtype1.validate("0.99999"), isNotNull); // range error
    expect(dtype1.validate("5.00001"), isNotNull); // range error again

    final dtype3 = parseDataType("double<;10>")!;
    expect(dtype3.validate("-100"), isNull);
    expect(dtype3.validate("10.01"), isNotNull); // range error
  });

  test("String validation tests", () {
    final dtype1 = parseDataType("str?<3;5>")!;
    expect(dtype1.validate("abc"), isNull);
    expect(dtype1.validate("abcd"), isNull);
    expect(dtype1.validate("abcde"), isNull);
    expect(dtype1.validate(""), isNull);
    expect(dtype1.validate(null), isNull);

    expect(dtype1.validate("ab"), isNotNull);
    expect(dtype1.validate("abcdef"), isNotNull);

    final dtype2 = parseDataType("str<3;5>")!;
    expect(dtype2.validate("abc"), isNull);
    expect(dtype2.validate("abcd"), isNull);
    expect(dtype2.validate("abcde"), isNull);

    expect(dtype2.validate(""), isNotNull);
    expect(dtype2.validate(null), isNotNull);
    expect(dtype2.validate("ab"), isNotNull);
    expect(dtype2.validate("abcdef"), isNotNull);

    final dtype3 = parseDataType("str?<5; 5>")!;
    expect(dtype3.validate("abcde"), isNull);
    expect(dtype3.validate("00000"), isNull);
    expect(dtype3.validate(""), isNull);
    expect(dtype3.validate(null), isNull);

    expect(dtype3.validate("abcd"), isNotNull);
    expect(dtype3.validate("abcdef"), isNotNull);
  });
}
