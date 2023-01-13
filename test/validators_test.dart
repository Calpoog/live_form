import 'package:flutter_test/flutter_test.dart';
import 'package:live_form/src/validators.dart';

void main() {
  group('requiredString', () {
    test('has an error when empty', () {
      expect(requiredString(''), isNotNull);
    });

    test('has no error with any value', () {
      expect(requiredString('test'), isNull);
    });
  });

  group('minLengthString', () {
    final minLength = minLengthString(3);

    test('has an error when empty', () {
      expect(minLength(''), isNotNull);
    });

    test('has an error when less than 3', () {
      expect(minLength('xx'), isNotNull);
    });

    test('has no error when longer than 2', () {
      expect(minLength('test'), isNull);
    });
  });

  group('requiredField', () {
    test('has an error when null', () {
      expect(requiredField<int?>(null), isNotNull);
    });

    test('has no error with any value', () {
      expect(requiredField<int?>(1), isNull);
    });
  });
}
