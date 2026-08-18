import 'dart:async';

abstract interface class StandardSchemaV1<Input, Output> {
  /// Corresponds to the TypeScript `~standard` property.
  ///
  /// Dart identifiers cannot contain `~`, so this is exposed as `standard`.
  StandardSchemaV1Props<Input, Output> get standard;
}

final class StandardSchemaV1Props<Input, Output> {
  const StandardSchemaV1Props({
    required this.vendor,
    required this.validate,
    this.types,
  });

  /// Standard Schema V1.
  int get version => 1;

  final String vendor;

  final FutureOr<StandardSchemaResult<Output>> Function(
    Object? value, [
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
  final Map<String, Object?>? libraryOptions;
}

/// A validation issue.
final class StandardSchemaIssue {
  const StandardSchemaIssue({required this.message, this.path});

  /// Human-readable error message.
  final String message;

  /// Location of the error, if applicable.
  final List<StandardSchemaPathElement>? path;
}

/// A path can contain either a property key directly or a path segment.
///
/// TypeScript's:
///
/// ```ts
/// PropertyKey | PathSegment
/// ```
///
/// doesn't have a direct Dart equivalent, so a sealed type is useful.
sealed class StandardSchemaPathElement {
  const StandardSchemaPathElement();
}

/// A direct property key.
///
/// JavaScript's `PropertyKey` is `string | number | symbol`.
/// Dart generally uses String or int for object/list paths.
final class StandardSchemaPropertyKey extends StandardSchemaPathElement {
  const StandardSchemaPropertyKey(this.key);

  final Object key;
}

/// An explicit Standard Schema path segment.
final class StandardSchemaPathSegment extends StandardSchemaPathElement {
  const StandardSchemaPathSegment(this.key);

  final Object key;
}

/// Type metadata associated with a schema.
///
/// In TypeScript this allows `InferInput` and `InferOutput` to retrieve
/// compile-time types. Dart generics already carry these types directly.
abstract interface class StandardSchemaTypes<Input, Output> {
  Input get input;

  Output get output;
}
