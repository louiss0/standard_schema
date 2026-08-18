import 'package:enhanced_standard_schema/enhanced_standard_schema.dart';
import 'package:test/test.dart';

import '../example/zod_clone_example.dart';

void main() {
  group('Zod clone example', () {
    test('applies string rules', () {
      final schema = Z.string().min(3).max(5).regex(RegExp(r'^[a-z]+$'));

      expect(schema.validate('dart'), isA<StandardSchemaSuccess<String>>());
      expect(schema.validate('D'), isA<StandardSchemaFailure<String>>());
    });

    test('applies integer rules', () {
      final schema = Z.int().min(2).max(10).multipleOf(2);

      expect(schema.validate(4), isA<StandardSchemaSuccess<int>>());
      expect(schema.validate(3), isA<StandardSchemaFailure<int>>());
    });

    test('applies double rules', () {
      final schema = Z.double().positive().max(5).finite();

      expect(schema.validate(4.5), isA<StandardSchemaSuccess<double>>());
      expect(
        schema.validate(double.infinity),
        isA<StandardSchemaFailure<double>>(),
      );
    });

    test('validates array elements and rules', () {
      final schema = Z.array(Z.string().nonempty()).min(1).unique();

      expect(
        schema.validate(['dart', 'schema']),
        isA<StandardSchemaSuccess<List<String>>>(),
      );
      expect(
        schema.validate(['dart', 'dart']),
        isA<StandardSchemaFailure<List<String>>>(),
      );
      expect(
        schema.validate(['dart', 1]),
        isA<StandardSchemaFailure<List<String>>>(),
      );
    });

    test('validates map keys, values, and rules', () {
      final schema =
          Z.map(Z.string().nonempty(), Z.int().positive()).nonempty();

      expect(
        schema.validate({'dart': 3}),
        isA<StandardSchemaSuccess<Map<String, int>>>(),
      );
      expect(
        schema.validate({'dart': -1}),
        isA<StandardSchemaFailure<Map<String, int>>>(),
      );
      expect(
        schema.validate({1: 3}),
        isA<StandardSchemaFailure<Map<String, int>>>(),
      );
    });
  });
}
