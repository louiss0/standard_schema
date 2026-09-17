# Enhanced Standard Schema for Dart

A type-safe Dart contract for interoperable validation libraries, based on
[Standard Schema V1](https://standardschema.dev/), designed by the creators of
Zod, Valibot, and ArkType.

This adaptation omits TypeScript's input-type extraction because Dart cannot
extract generic parameters from a concrete schema type. Output types remain
available through Dart's ordinary generic inference.

This package defines interfaces and result types only. Validation libraries can
implement `StandardSchema`, while consumers can accept any conforming schema
without depending on a particular validator.

## Features

- Generic output types
- Synchronous or asynchronous validation
- Structured validation paths and issues
- Optional vendor-specific validation options
- Optional issue codes and typed metadata

## Usage

```dart
import 'package:enhanced_standard_schema/enhanced_standard_schema.dart';

final class IntegerSchema implements StandardSchema<int> {
  @override
  StandardSchemaProps<int> get $standard => StandardSchemaProps<int>(
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

See [`example/enhanced_standard_schema_example.dart`](example/enhanced_standard_schema_example.dart)
for a complete schema example and
[`example/issues_example.dart`](example/issues_example.dart) for every issue
level. The [`example/zod_clone_example.dart`](example/zod_clone_example.dart)
example builds a small, fluent validator for strings, integers, doubles, arrays,
and maps on top of the contract.

## Implementing the contract

Implement `StandardSchema<Output>` and expose immutable
`StandardSchemaProps`. The `validate` callback receives an unknown value and
returns either `StandardSchemaSuccess<Output>` or
`StandardSchemaFailure<Output>`, directly or in a `Future`.

Choose an issue base class based on the information exposed by the validator:

- Extend `StandardSchemaIssue` for a message and optional validation path.
- Extend `HintedStandardSchemaIssue` to add an optional machine-readable code.
- Extend `DetailedStandardSchemaIssue<Metadata>` to add typed metadata, represented
  by a Dart record.

```dart
final class TypeMismatchIssue extends HintedStandardSchemaIssue {
  const TypeMismatchIssue({
    required super.message,
    super.path,
    super.code,
  });
}

typedef RangeMetadata = ({int actual, int maximum, int minimum});

final class RangeIssue extends DetailedStandardSchemaIssue<RangeMetadata> {
  const RangeIssue({
    required super.message,
    required super.metadata,
    super.path,
    super.code,
  });
}
```

## Validation paths

Paths preserve the difference between object properties and list positions. Use
`StandardSchemaPropertyKey` for string keys and `StandardSchemaListIndex` for
integer indices:

```dart
const path = <StandardSchemaPathElement>[
  StandardSchemaPropertyKey('items'),
  StandardSchemaListIndex(0),
  StandardSchemaPropertyKey('name'),
];
```

This distinction matters when traversing validated data. A map property named
`'0'` is not the same location as list index `0`, even though both may be
rendered as `/0` for display.

## Static type inference

Dart carries the validated type through `StandardSchema<Output>`. Generic
consumers infer the output type from the schema argument, while validation input
remains `Object?` until it has been checked:

```dart
Future<Output> parse<Output>(
  StandardSchema<Output> schema,
  Object? input,
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
