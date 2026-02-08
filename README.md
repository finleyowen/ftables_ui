# FSheets UI

User interface for FSheets, the spreadsheet application that is better.

## Motivation

Traditional spreadsheet applications like (e.g., Microsoft Excel, Google Sheets, Apple Numbers) are as limited in the structure they enforce as they are in the flexibility they permit. While these applications certainly have many appropriate use cases, it's arguable that in many of these use cases, an even more suitable solution would be one that more closely resembles a Relational Database Management System (RDBMS). Here are some reasons why traditional spreadsheet applications might not be suitable for many use cases that they are commonly applied to in practice:

- Data validation as an afterthought: These applications do have data validation features, but they aren't as reliable as they could be, which sometimes results in the applications making assumptions about data that the user might not expect, e.g., '1/10' being parsed as '1-Oct' (or '10-Jan').
- Replication of formulae and formatting: When you apply the same formatting or formula to multiple cells in a spreadsheet, information about the formatting or formula can be copied around the spreadsheet, leading to unnecessarily duplicated data and spreadsheets that occupy more space in memory and storage than they optimally could. Most of these applications have ways of managing this issue either internally or by the user, but again these aren't always reliable.
- The macro-formula gap: The fact that formaulae and macros are achieved using completely separate systems without consistency, though they accomplish similar things. Many formulae could be rewritten as macros and vice versa (not to say they should be).
- Security, security, security: Excel macros are known to pose serious cybersecurity risks (as documented by [cyber.gov.au](http://cyber.gov.au/sites/default/files/2023-03/PROTECT%20-%20Microsoft%20Office%20Macro%20Security%20%28October%202021%29.pdf)).

## Implementation details

See [implementation details](./implementation_details/CONTENTS.md).