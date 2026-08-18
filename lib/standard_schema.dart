import 'dart:async';

/// A validator-independent contract for a schema with [Input] and [Output]
/// types.
abstract interface class StandardSchema<Output> {
  /// The properties used by consumers to identify and invoke this schema.
  StandardSchemaProps<Output> get $standard;
}

/// A value whose type is not known before validation.
typedef Unknown = Object?;

/// The properties exposed by a [StandardSchema] implementation.
final class StandardSchemaProps<Output> {
  /// Creates immutable properties for a schema supplied by [vendor].
  const StandardSchemaProps({
    required this.vendor,
    required this.validate,
  });

  /// The implemented Standard Schema version.
  int get version => 1;

  /// The name of the validation library.
  final String vendor;

  /// Validates an unknown value with optional vendor-specific options.
  final FutureOr<StandardSchemaResult<Output>> Function(
    Unknown value, [
    StandardSchemaOptions? options,
  ]) validate;
}

/// Result returned from validation.
sealed class StandardSchemaResult<Output> {
  /// Creates a validation result.
  const StandardSchemaResult();
}

/// A successful validation result.
final class StandardSchemaSuccess<Output> extends StandardSchemaResult<Output> {
  /// Creates a successful result containing [value].
  const StandardSchemaSuccess(this.value);

  /// The typed output value.
  final Output value;
}

/// A failed validation result.
final class StandardSchemaFailure<Output> extends StandardSchemaResult<Output> {
  /// Creates a failed result containing one or more [issues].
  const StandardSchemaFailure(this.issues);

  /// The issues produced during validation.
  final List<StandardSchemaIssue> issues;
}

/// Options passed to a schema during validation.
final class StandardSchemaOptions<Options extends Record> {
  /// Creates validation options with optional vendor-specific values.
  const StandardSchemaOptions({this.libraryOptions});

  /// Explicit support for vendor-specific parameters.
  final Options? libraryOptions;
}

/// A validation issue that libraries can extend with their own issue type.
abstract class StandardSchemaIssue {
  /// Creates an issue with a human-readable [message] and optional [path].
  const StandardSchemaIssue({required this.message, this.path});

  /// Human-readable error message.
  final String message;

  /// Location of the error, if applicable.
  final List<StandardSchemaPathElement>? path;
}

/// A validation issue with an optional machine-readable [code].
abstract class HintedStandardSchemaIssue extends StandardSchemaIssue {
  /// Creates a hinted issue.
  const HintedStandardSchemaIssue({
    required super.message,
    super.path,
    this.code,
  });

  /// A unique error code, if applicable.
  final String? code;
}

/// A hinted issue with typed, vendor-specific [metadata].
abstract class DetailedStandardSchemaIssue<Metadata extends Record>
    extends HintedStandardSchemaIssue {
  /// Creates a detailed issue.
  const DetailedStandardSchemaIssue({
    required super.message,
    super.path,
    super.code,
    required this.metadata,
  });

  /// Additional structured information about the issue.
  final Metadata metadata;
}

/// An element identifying one location within a validation path.
sealed class StandardSchemaPathElement {
  /// Creates a validation path element.
  const StandardSchemaPathElement();
}

/// A direct property key in a validation path.
final class StandardSchemaPropertyKey extends StandardSchemaPathElement {
  /// Creates a property-key element for [key].
  const StandardSchemaPropertyKey(this.key);

  /// The property name.
  final String key;
}

/// An explicit Standard Schema path segment.
final class StandardSchemaPathSegment extends StandardSchemaPathElement {
  /// Creates an explicit path segment for [key].
  const StandardSchemaPathSegment(this.key);

  /// The key represented by this path segment.
  final String key;
}
