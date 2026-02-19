import 'dart:convert';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:fsheets/logic/schema.dart';

typedef CompileSchemaNative = Pointer<Utf8> Function(Pointer<Utf8>);
typedef CompileSchemaDart = Pointer<Utf8> Function(Pointer<Utf8>);

typedef FreeStringNative = Void Function(Pointer<Utf8>);
typedef FreeStringDart = void Function(Pointer<Utf8>);

final dylib = DynamicLibrary.open("ftables_ffi/target/release/ftable_ffi.dll");

final compileSchema = dylib
    .lookupFunction<CompileSchemaNative, CompileSchemaDart>("compile_schema");
final freeStr = dylib.lookupFunction<FreeStringNative, FreeStringDart>(
  "free_str",
);

SpreadsheetSchema parseSchema(String s) {
  final sPtr = s.toNativeUtf8();
  final jsonPtr = compileSchema(sPtr);

  final jsonStr = jsonPtr.toDartString();

  calloc.free(sPtr);
  freeStr(jsonPtr);

  final json = jsonDecode(jsonStr);

  return SpreadsheetSchema.fromJson(json);
}

void main() {
  final schema = parseSchema(
    "table T1(a: int);table T2(b: dbl);table T3(c: str);",
  );

  print(schema.toString());
}
