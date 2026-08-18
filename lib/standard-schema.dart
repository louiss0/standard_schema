import 'dart:async';

/// The contract by which authors must implement validation types
abstract interface class StandardSchema<Input, Output> {
  StandardSchemaProps<Input, Output> get $standard;
}

typedef Unknown = Object?;

/// The validation props that must be used
final class StandardSchemaProps<Input, Output> {
  const StandardSchemaProps({
    required this.vendor,
    required this.validate,
    this.types,
  });

  /// Standard Schema V1.
  int get version => 1;

  /// The name of the library that's used
  final String vendor;

  /// The function used to validate the input
  final FutureOr<StandardSchemaResult<Output>> Function(
    Unknown value, [
    StandardSchemaOptions? options,
  ])
  validate;

  final StandardSchemaTypes<Input, Output>? types;
}

/// Result returned from validation.
sealed class StandardSchemaResult<Output> {
  const StandardSchemaResult();
}

/// Validation succeeded.
final class StandardSchemaSuccess<Output> extends StandardSchemaResult<Output> {
  const StandardSchemaSuccess(this.value);

  /// The typed output value.
  final Output value;
}

/// Validation failed.
final class StandardSchemaFailure<Output> extends StandardSchemaResult<Output> {
  const StandardSchemaFailure(this.issues);

  /// The issues produced during validation.
  final List<StandardSchemaIssue> issues;
}

/// Validation options.
final class StandardSchemaOptions {
  const StandardSchemaOptions({this.libraryOptions});

  /// Explicit support for vendor-specific parameters.
  final Map<String, Unknown>? libraryOptions;
}

/// A validation issue.
sealed class StandardSchemaIssue {
  const StandardSchemaIssue({required this.message, this.path});

  /// Human-readable error message.
  final String message;

  /// Location of the error, if applicable.
  final List<StandardSchemaPathElement>? path;
}

/// An issue that dictates what kind of problem exists
abstract class HintedStandardSchemaIssue extends StandardSchemaIssue {
  const HintedStandardSchemaIssue({
    required super.message,
    super.path,
    this.code,
  });

  /// A unique error code, if applicable.
  final String? code;
}

/// An issue that dictates what kind of problem exists with additional metadata.
abstract class DetailedStandardSchemaIssue<Metadata extends Record>
    extends HintedStandardSchemaIssue {
  const DetailedStandardSchemaIssue({
    required super.message,
    super.path,
    super.code,
    required this.metadata,
  });

  final Metadata metadata;
}

sealed class StandardSchemaPathElement {
  const StandardSchemaPathElement();
}

final class StandardSchemaPropertyKey extends StandardSchemaPathElement {
  const StandardSchemaPropertyKey(this.key);

  final String key;
}

/// An explicit Standard Schema path segment.
final class StandardSchemaPathSegment extends StandardSchemaPathElement {
  const StandardSchemaPathSegment(this.key);

  final String key;
}

abstract interface class StandardSchemaTypes<Input, Output> {
  Input get input;

  Output get output;
}
