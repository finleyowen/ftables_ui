# FSheets DDL

See [source code](../lib/logic/data_type.dart)  

FSheets has its own Data Definition Language or DDL for representing schemas with text. The application can parse schemas from the textual representation and convert schemas to the textual representation.

## Data types

FSheets supports the basic types `int`, `double`, and `str`. Each of these can be made nullable by appending a question mark (e.g., `int?`). The ranges of teh data types may also be restricted by adding optional minimum and maximum values in angled brackets, separated by a mandatory semicolon and an optional space, e.g., `int<5;10>`, `int<5;>`, `int<;10>`, `double<5.0;10.0>`. For the string type, the range provided applies to the length of the string rather than its value, e.g., `str<5;5>` is equivalent to `CHAR(5)` in MySQL.

## Column schemas

General formula: `[column name]:[data type]=[default value]`

## Constraint schemas

### Unique constraint schemas

A unique constraint schema describes a subset of columns in a table that form a unique key.

Example: `@(column1;column2)`

### Primary key constraint schema

A primary constraint schema describe a subset of columns in a table that form its primary key..

Example: `!@(column1;column2)`

### Foreign key constraint schema

A foreign key constraint schema describes a subset of columns in a table that form its foreign key.

Example: `#(column1;column2)&table1(column1;column2)`

## Table schemas

Table schemas define the table name, the column and constraint schemas. 

Examples: 
```
person(id:int,firstName:str,surname:str,!@(id))
employee(id:int,department:str,!@(id),#(id)&person(id))
```