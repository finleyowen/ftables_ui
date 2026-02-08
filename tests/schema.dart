import 'package:fsheets/logic/ddl.dart';
import 'package:test/test.dart';

void expectMapToColumnSchema(String s) {
  expect(parseColumnSchema(s).toString(), equals(s));
}

void expectParseToColumnSchema(String s) {
  expect(parseColumnSchema(s).toString(), isNotNull);
}

void expectMapToConstraintSchema(String s) {
  expect(parseConstraintSchema(s).toString(), equals(s));
}

void expectMapToTableSchema(String s) {
  expect(parseTableSchema(s).toString(), equals(s));
}

void expectParseToTableSchema(String s) {
  expect(parseTableSchema(s), isNotNull);
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
    expect(parseConstraintSchema("@(column1; column2)"), isNotNull);

    // pk
    expect(parseConstraintSchema("!@(column1; column2)"), isNotNull);

    // fk
    expect(
      parseConstraintSchema("#(column1; column2) &table1(column1; column2)"),
      isNotNull,
    );

    // invalid
    expect(parseConstraintSchema("@(column1, column2)"), isNull);
    expect(parseConstraintSchema("@(column1; column2; )"), isNull);
    expect(parseConstraintSchema("@()"), isNull);
    expect(parseConstraintSchema("@(;)"), isNull);

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

    expectParseToTableSchema("""person(
      id: int, 
      firstName: str, 
      surname: str,
      @(id)
    )""");

    expectParseToTableSchema("""animal(
      id: int,
      name: str?,
      owner_id: int?,
      #(owner_id)&person(id)
    )""");
  });
}
