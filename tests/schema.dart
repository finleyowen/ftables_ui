import 'package:bettersheets_ui/logic/schema.dart';
import 'package:test/test.dart';

void expectMapToColumnSchema(String s) {
  expect(ColumnSchema.fromString(s).toString(), equals(s));
}

void main() {
  test("Column schema to string test", () {
    expectMapToColumnSchema("myColumn: int<0,5>");
    expectMapToColumnSchema("myColumn: int<0,5> = 2");
    expectMapToColumnSchema("my_column: double<-100.5,100.5> = 10.5");
    expectMapToColumnSchema("my_column: double?<-100.5,100.5>");
    expectMapToColumnSchema("my_column: str<,10> = \"my string\"");
  });
}
