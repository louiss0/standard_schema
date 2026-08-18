import 'dart:async';

import 'package:enhanced_standard_schema/enhanced_standard_schema.dart';
import 'package:test/test.dart';

void main() {
  group('StandardSchemaProps', () {
    test('exposes Standard Schema version and vendor', () {
      final properties = StandardSchemaProps<int>(
        vendor: 'example',
        validate: (value, [options]) => const StandardSchemaSuccess(1),
      );

      expect(properties.version, 1);
      expect(properties.vendor, 'example');
    });

    test('supports synchronous validation', () {
      final properties = StandardSchemaProps<int>(
        vendor: 'example',
        validate: (value, [options]) => const StandardSchemaSuccess(1),
      );

      expect(
        properties.validate(null),
        isA<StandardSchemaSuccess<int>>(),
      );
    });

    test('supports asynchronous validation', () async {
      final properties = StandardSchemaProps<int>(
        vendor: 'example',
        validate: (value, [options]) async => const StandardSchemaSuccess(1),
      );

      expect(properties.validate(null),
          isA<FutureOr<StandardSchemaResult<int>>>());
      await expectLater(
        properties.validate(null),
        completion(isA<StandardSchemaSuccess<int>>()),
      );
    });
  });

  test('preserves typed vendor options', () {
    const options = StandardSchemaOptions<(bool,)>(libraryOptions: (true,));

    expect(options.libraryOptions, (true,));
  });

  test('preserves detailed issue data', () {
    const issue = TestIssue(
      message: 'Invalid value.',
      path: [StandardSchemaPropertyKey('name')],
      code: 'invalid',
      metadata: (expected: 'integer'),
    );

    expect(issue.message, 'Invalid value.');
    expect(issue.code, 'invalid');
    expect(issue.metadata.expected, 'integer');
    expect(issue.path, hasLength(1));
  });
}

final class TestIssue extends DetailedStandardSchemaIssue<({String expected})> {
  const TestIssue({
    required super.message,
    required super.path,
    required super.code,
    required super.metadata,
  });
}
