import 'package:standard_schema/standard_schema.dart';

final class IntegerSchema implements StandardSchema<int> {
  @override
  StandardSchemaProps<int> get $standard => StandardSchemaProps<int>(
        vendor: 'example',
        validate: (value, [options]) => value is int
            ? StandardSchemaSuccess(value)
            : const StandardSchemaFailure([
                BasicIssue(message: 'Expected an integer.'),
              ]),
      );
}

final class BasicIssue extends StandardSchemaIssue {
  const BasicIssue({required super.message, super.path});
}

Future<void> main() async {
  final result = await IntegerSchema().$standard.validate(42);

  switch (result) {
    case StandardSchemaSuccess(value: final value):
      print('Validated: $value');
    case StandardSchemaFailure(issues: final issues):
      print('Invalid: ${issues.first.message}');
  }
}
