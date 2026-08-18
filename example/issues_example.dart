import 'package:standard_schema/standard_schema.dart';

typedef RangeMetadata = ({int actual, int maximum, int minimum});

final class MissingValueIssue extends StandardSchemaIssue {
  const MissingValueIssue({required super.message, super.path});
}

final class TypeMismatchIssue extends HintedStandardSchemaIssue {
  const TypeMismatchIssue({
    required super.message,
    super.path,
    super.code,
  });
}

final class RangeIssue extends DetailedStandardSchemaIssue<RangeMetadata> {
  const RangeIssue({
    required super.message,
    required super.metadata,
    super.path,
    super.code,
  });
}

final class BoundedIntegerSchema implements StandardSchema<int> {
  BoundedIntegerSchema({required this.minimum, required this.maximum});

  final int minimum;
  final int maximum;

  @override
  late final StandardSchemaProps<int> $standard = StandardSchemaProps<int>(
    vendor: 'example',
    validate: (value, [options]) {
      if (value == null) {
        return const StandardSchemaFailure([
          MissingValueIssue(
            message: 'A value is required.',
            path: [StandardSchemaPropertyKey('value')],
          ),
        ]);
      }

      if (value is! int) {
        return const StandardSchemaFailure([
          TypeMismatchIssue(
            message: 'Expected an integer.',
            code: 'invalid_type',
            path: [StandardSchemaPathSegment('value')],
          ),
        ]);
      }

      if (value < minimum || value > maximum) {
        return StandardSchemaFailure([
          RangeIssue(
            message: 'The integer is outside the allowed range.',
            code: 'out_of_range',
            path: const [StandardSchemaPropertyKey('value')],
            metadata: (
              actual: value,
              maximum: maximum,
              minimum: minimum,
            ),
          ),
        ]);
      }

      return StandardSchemaSuccess(value);
    },
  );
}

Future<void> displayValidation(
  StandardSchema<int> schema,
  Object? value,
) async {
  final result = await schema.$standard.validate(value);

  switch (result) {
    case StandardSchemaSuccess(value: final output):
      print('Validated: $output');
    case StandardSchemaFailure(issues: final issues):
      for (final issue in issues) {
        switch (issue) {
          case RangeIssue(metadata: final details, code: final code):
            print(
              '$code: ${issue.message} '
              '(${details.actual} is not between '
              '${details.minimum} and ${details.maximum})',
            );
          case TypeMismatchIssue(code: final code):
            print('$code: ${issue.message}');
          case MissingValueIssue():
            print(issue.message);
          default:
            print(issue.message);
        }
      }
  }
}

Future<void> main() async {
  final schema = BoundedIntegerSchema(minimum: 1, maximum: 10);

  await displayValidation(schema, null);
  await displayValidation(schema, 'five');
  await displayValidation(schema, 20);
  await displayValidation(schema, 5);
}
