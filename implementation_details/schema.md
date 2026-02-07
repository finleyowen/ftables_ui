# BetterSheets Schemas

See [source code](../lib/logic/schema.dart)  
See [tests](../tests/schema.dart)  

Schemas or shcemata in BetterSheets define the structure of tables and columns in spreadsheets. They store information like the names of tables and columns, data types of columns, and constraints on tables.

## Column Schemas

A column schema stores information about a column including its name, data type, and default value.

## Constraint Schemas

A constraint schema stores infomration about a constraint in a table schema. BetterSheets supports three types of constraints:

- Unique constraints specify a subset of columns that form a unique key in the table
- Primary key constraints extend unique constraints specify a subset of columns that form a primary key in the table
- Foreign key constraints specify a subset of columns that form a primary key, as well as the the referenced table and columns

## Table Schemas

A table schema stores information about a table, including its name, column schemas, and constraint schemas.