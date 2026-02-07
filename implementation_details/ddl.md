# BetterSheets DDL

BetterSheets has its own Data Definition Language or DDL for representing schemas with text. The application can parse schemas from the textual representation and convert schemas to the textual representation.

## Data Types

General formula:

BetterSheets supports the basic types `int`, `double`, and `str`. Each of these can be made nullable by appending a question mark (e.g., `int?`). The ranges of teh data types may also be restricted by adding optional minimum and maximum values in angled brackets, separated by a mandatory semicolon and an optional space, e.g., `int<5;10>`, `int<5;>`, `int<;10>`, `double<5.0;10.0>`. For the string type, the range provided applies to the length of the string rather than its value, e.g., `str<5;5>` is equivalent to `CHAR(5)` in MySQL.

## Column Schemas


## Constraint Schemas

## Table Schemas