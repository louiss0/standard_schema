# Standard Schema for Dart

A type-safe Dart contract for interoperable validation libraries, based on
[Standard Schema V1](https://standardschema.dev/).

This package defines interfaces and result types only. Validation libraries can
implement `StandardSchema`, while consumers can accept any conforming schema
without depending on a particular validator.

## Features

- Generic input and output types
- Synchronous or asynchronous validation
- Structured validation paths and issues
- Optional vendor-specific validation options
- Optional issue codes and typed metadata

## Usage

```dart
import 'package:standard_schema/standard_schema.dart';

final class IntegerSchema implements StandardSchema<Object?, int> {
  @override
  StandardSchemaProps<Object?, int> get $standard =>
      StandardSchemaProps<Object?, int>(
        vendor: 'example',
        validate: (value, [options]) {
          if (value is int) {
            return StandardSchemaSuccess(value);
          }

          return const StandardSchemaFailure([
            BasicIssue(message: 'Expected an integer.'),
          ]);
        },
      );
}

final class BasicIssue extends StandardSchemaIssue {
  const BasicIssue({required super.message, super.path});
}

Future<void> main() async {
  final result = await IntegerSchema().$standard.validate(42);

  switch (result) {
    case StandardSchemaSuccess(value: final value):
      print(value);
    case StandardSchemaFailure(issues: final issues):
      print(issues.first.message);
  }
}
```

See [`example/standard_schema_example.dart`](example/standard_schema_example.dart)
for a complete example.

## Implementing the contract

Implement `StandardSchema<Input, Output>` and expose immutable
`StandardSchemaProps`. The `validate` callback receives an unknown value and
returns either `StandardSchemaSuccess<Output>` or
`StandardSchemaFailure<Output>`, directly or in a `Future`.

Use `HintedStandardSchemaIssue` when consumers need a machine-readable code,
and `DetailedStandardSchemaIssue` when a validator also exposes typed metadata.

## Static type inference

Dart carries the schema types directly through `StandardSchema<Input, Output>`.
Generic consumers can infer both types from the schema argument:

```dart
Future<Output> parse<Input, Output>(
  StandardSchema<Input, Output> schema,
  Input input,
) async {
  final result = await schema.$standard.validate(input);

  return switch (result) {
    StandardSchemaSuccess(value: final output) => output,
    StandardSchemaFailure(issues: final issues) =>
      throw FormatException(issues.first.message),
  };
}

final int value = await parse(IntegerSchema(), 42);
```

Unlike TypeScript, Dart cannot extract a generic parameter into a type alias from
a schema type. The generic `Input` and `Output` parameters are therefore the
Dart equivalent of Standard Schema's `Types`, `InferInput`, and `InferOutput`.
