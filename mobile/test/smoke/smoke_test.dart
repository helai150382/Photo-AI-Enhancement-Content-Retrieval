import 'package:flutter_test/flutter_test.dart';
import 'package:ai_photo_app/core/result.dart';

void main() {
  test('Ok 携带值', () {
    const Result<int> r = Ok<int>(42);
    expect(r, isA<Ok<int>>());
    expect((r as Ok<int>).value, 42);
  });

  test('Err 携带消息', () {
    const Result<int> r = Err<int>('boom');
    expect(r, isA<Err<int>>());
    expect((r as Err<int>).message, 'boom');
  });
}
