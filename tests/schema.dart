import 'package:fsheets/logic/schema.dart';
import 'package:test/test.dart';

void expectMapToColumnSchema(String s) {
  expect(ColumnSchema.fromString(s).toString(), equals(s));
}

void expectParseToColumnSchema(String s) {
  expect(ColumnSchema.fromString(s).toString(), isNotNull);
}

void expectMapToConstraintSchema(String s) {
  expect(ConstraintSchema.fromString(s).toString(), equals(s));
}

void expectMapToTableSchema(String s) {
  expect(TableSchema.fromString(s).toString(), equals(s));
}

void main() {
  test("Column schema string IO test", () {
    expectMapToColumnSchema("myColumn:int<0;5>");
    expectMapToColumnSchema("myColumn:int<0;5>=2");
    expectMapToColumnSchema("my_column:double<-100.5;100.5>=10.5");
    expectMapToColumnSchema("my_column:double?<-100.5;100.5>");
    expectMapToColumnSchema("my_column:str<;10>=\"my string\"");

    expectParseToColumnSchema("myColumn: int<0; 5>");
    expectParseToColumnSchema("myColumn: int?<0; 5> = 2");
    expectParseToColumnSchema("myColumn: int?<0; 5>=2");
  });

  test("Constraint schema string IO test", () {
    // unique
    expect(ConstraintSchema.fromString("@(column1; column2)"), isNotNull);

    // pk
    expect(ConstraintSchema.fromString("!@(column1; column2)"), isNotNull);

    // fk
    expect(
      ConstraintSchema.fromString(
        "#(column1; column2) &table1(column1; column2)",
      ),
      isNotNull,
    );

    // invalid
    expect(ConstraintSchema.fromString("@(column1, column2)"), isNull);
    expect(ConstraintSchema.fromString("@(column1; column2; )"), isNull);
    expect(ConstraintSchema.fromString("@()"), isNull);
    expect(ConstraintSchema.fromString("@(;)"), isNull);

    // like column schemas, constraint schemas will map to strings with the
    // optional whitespace omitted
    expectMapToConstraintSchema("@(column1;column2)");
    expectMapToConstraintSchema("!@(column1;column2)");
    expectMapToConstraintSchema("#(column1;column2)&table1(column1;column2)");
    expectMapToConstraintSchema("#(column1)&table1(column1)");
    expectMapToConstraintSchema("@(column1)");
  });

  test("Table schema IO string test", () {
    expectMapToTableSchema("person(id:int,firstName:str,surname:str)");
    expectMapToTableSchema("person(id:int,firstName:str,surname:str,@(id))");
    expectMapToTableSchema("person(id:int,firstName:str,surname:str,!@(id))");
    expectMapToTableSchema(
      "employee(id:int,department:str,!@(id),#(id)&person(id))",
    );
  });
}
