import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test("Testing String.trim behaviour", () {
    expect("\nhello\n".trim(), "hello");
    expect("\n\n\nhello\n\n\n".trim(), "hello");
    expect("  hello   ".trim(), "hello");
    expect("\t\n hello \n\t".trim(), "hello");
    expect(
      """
      hello
    """
          .trim(),
      equals("hello"),
    );
  });
}
