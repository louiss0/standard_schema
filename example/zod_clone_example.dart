import 'package:standard_schema/standard_schema.dart';

typedef ZodRule<Value> = ({String code, String? Function(Value) validate});

abstract base class ZodSchema<Output>
    implements StandardSchema<Object?, Output> {
  ZodSchema(this.rules);

  final List<ZodRule<Output>> rules;

  @override
  late final StandardSchemaProps<Object?, Output> $standard =
      StandardSchemaProps<Object?, Output>(
    vendor: 'zod-clone',
    validate: (value, [options]) => validate(value),
  );

  StandardSchemaResult<Output> validate(Object? value);

  List<ZodIssue> getRuleIssues(Output value) => rules
      .map(
        (rule) => switch (rule.validate(value)) {
          final String message => ZodIssue(message: message, code: rule.code),
          null => null,
        },
      )
      .nonNulls
      .toList(growable: false);

  StandardSchemaResult<Output> getRuleResult(Output value) {
    final issues = getRuleIssues(value);
    return issues.isEmpty
        ? StandardSchemaSuccess(value)
        : StandardSchemaFailure(issues);
  }
}

final class ZodIssue extends HintedStandardSchemaIssue {
  const ZodIssue({required super.message, required super.code, super.path});

  ZodIssue at(String key) => ZodIssue(
        message: message,
        code: code,
        path: [StandardSchemaPathSegment(key), ...?path],
      );
}

abstract final class Z {
  static ZodString string() => ZodString();

  static ZodInt int() => ZodInt();

  static ZodDouble double() => ZodDouble();

  static ZodArray<Element> array<Element>(ZodSchema<Element> element) =>
      ZodArray(element);

  static ZodMap<Key, Value> map<Key, Value>(
    ZodSchema<Key> key,
    ZodSchema<Value> value,
  ) =>
      ZodMap(key, value);
}

final class ZodString extends ZodSchema<String> {
  ZodString([super.rules = const []]);

  ZodString min(int length) => ZodString([
        ...rules,
        (
          code: 'too_small',
          validate: (value) => value.length < length
              ? 'Expected at least $length characters.'
              : null,
        ),
      ]);

  ZodString max(int length) => ZodString([
        ...rules,
        (
          code: 'too_big',
          validate: (value) => value.length > length
              ? 'Expected at most $length characters.'
              : null,
        ),
      ]);

  ZodString nonempty() => ZodString([
        ...rules,
        (
          code: 'too_small',
          validate: (value) =>
              value.isEmpty ? 'Expected a non-empty string.' : null,
        ),
      ]);

  ZodString email() => ZodString([
        ...rules,
        (
          code: 'invalid_format',
          validate: (value) => RegExp(
                r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
              ).hasMatch(value)
                  ? null
                  : 'Expected an email address.',
        ),
      ]);

  ZodString regex(RegExp pattern) => ZodString([
        ...rules,
        (
          code: 'invalid_format',
          validate: (value) => pattern.hasMatch(value)
              ? null
              : 'String does not match the required pattern.',
        ),
      ]);

  @override
  StandardSchemaResult<String> validate(Object? value) => value is! String
      ? const StandardSchemaFailure([
          ZodIssue(message: 'Expected a string.', code: 'invalid_type'),
        ])
      : getRuleResult(value);
}

final class ZodInt extends ZodSchema<int> {
  ZodInt([super.rules = const []]);

  ZodInt min(int minimum) => ZodInt([
        ...rules,
        (
          code: 'too_small',
          validate: (value) => value < minimum
              ? 'Expected a value greater than or equal to $minimum.'
              : null,
        ),
      ]);

  ZodInt max(int maximum) => ZodInt([
        ...rules,
        (
          code: 'too_big',
          validate: (value) => value > maximum
              ? 'Expected a value less than or equal to $maximum.'
              : null,
        ),
      ]);

  ZodInt positive() => ZodInt([
        ...rules,
        (
          code: 'too_small',
          validate: (value) =>
              value <= 0 ? 'Expected a positive integer.' : null,
        ),
      ]);

  ZodInt negative() => ZodInt([
        ...rules,
        (
          code: 'too_big',
          validate: (value) =>
              value >= 0 ? 'Expected a negative integer.' : null,
        ),
      ]);

  ZodInt multipleOf(int divisor) => ZodInt([
        ...rules,
        (
          code: 'not_multiple_of',
          validate: (value) =>
              value % divisor == 0 ? null : 'Expected a multiple of $divisor.',
        ),
      ]);

  @override
  StandardSchemaResult<int> validate(Object? value) => value is! int
      ? const StandardSchemaFailure([
          ZodIssue(message: 'Expected an integer.', code: 'invalid_type'),
        ])
      : getRuleResult(value);
}

final class ZodDouble extends ZodSchema<double> {
  ZodDouble([super.rules = const []]);

  ZodDouble min(double minimum) => ZodDouble([
        ...rules,
        (
          code: 'too_small',
          validate: (value) => value < minimum
              ? 'Expected a value greater than or equal to $minimum.'
              : null,
        ),
      ]);

  ZodDouble max(double maximum) => ZodDouble([
        ...rules,
        (
          code: 'too_big',
          validate: (value) => value > maximum
              ? 'Expected a value less than or equal to $maximum.'
              : null,
        ),
      ]);

  ZodDouble positive() => ZodDouble([
        ...rules,
        (
          code: 'too_small',
          validate: (value) =>
              value <= 0 ? 'Expected a positive double.' : null,
        ),
      ]);

  ZodDouble negative() => ZodDouble([
        ...rules,
        (
          code: 'too_big',
          validate: (value) =>
              value >= 0 ? 'Expected a negative double.' : null,
        ),
      ]);

  ZodDouble finite() => ZodDouble([
        ...rules,
        (
          code: 'not_finite',
          validate: (value) =>
              value.isFinite ? null : 'Expected a finite double.',
        ),
      ]);

  @override
  StandardSchemaResult<double> validate(Object? value) => value is! double
      ? const StandardSchemaFailure([
          ZodIssue(message: 'Expected a double.', code: 'invalid_type'),
        ])
      : getRuleResult(value);
}

final class ZodArray<Element> extends ZodSchema<List<Element>> {
  ZodArray(this.element, [super.rules = const []]);

  final ZodSchema<Element> element;

  ZodArray<Element> min(int length) => ZodArray(element, [
        ...rules,
        (
          code: 'too_small',
          validate: (value) => value.length < length
              ? 'Expected at least $length elements.'
              : null,
        ),
      ]);

  ZodArray<Element> max(int length) => ZodArray(element, [
        ...rules,
        (
          code: 'too_big',
          validate: (value) => value.length > length
              ? 'Expected at most $length elements.'
              : null,
        ),
      ]);

  ZodArray<Element> nonempty() => ZodArray(element, [
        ...rules,
        (
          code: 'too_small',
          validate: (value) =>
              value.isEmpty ? 'Expected a non-empty array.' : null,
        ),
      ]);

  ZodArray<Element> length(int length) => ZodArray(element, [
        ...rules,
        (
          code: 'invalid_length',
          validate: (value) => value.length == length
              ? null
              : 'Expected exactly $length elements.',
        ),
      ]);

  ZodArray<Element> unique() => ZodArray(element, [
        ...rules,
        (
          code: 'not_unique',
          validate: (value) => value.toSet().length == value.length
              ? null
              : 'Expected unique elements.',
        ),
      ]);

  @override
  StandardSchemaResult<List<Element>> validate(Object? value) {
    if (value is! List) {
      return const StandardSchemaFailure([
        ZodIssue(message: 'Expected an array.', code: 'invalid_type'),
      ]);
    }

    final results = value.indexed
        .map((entry) => (entry.$1, element.validate(entry.$2)))
        .toList(growable: false);
    final issues = results
        .expand(
          (entry) => switch (entry.$2) {
            StandardSchemaSuccess() => const <ZodIssue>[],
            StandardSchemaFailure(issues: final issues) =>
              issues.cast<ZodIssue>().map((issue) => issue.at('${entry.$1}')),
          },
        )
        .toList(growable: false);

    if (issues.isNotEmpty) {
      return StandardSchemaFailure(issues);
    }

    final output = results
        .map((entry) => (entry.$2 as StandardSchemaSuccess<Element>).value)
        .toList(growable: false);
    return getRuleResult(output);
  }
}

final class ZodMap<Key, Value> extends ZodSchema<Map<Key, Value>> {
  ZodMap(this.key, this.value, [super.rules = const []]);

  final ZodSchema<Key> key;
  final ZodSchema<Value> value;

  ZodMap<Key, Value> min(int size) => ZodMap(key, value, [
        ...rules,
        (
          code: 'too_small',
          validate: (map) =>
              map.length < size ? 'Expected at least $size entries.' : null,
        ),
      ]);

  ZodMap<Key, Value> max(int size) => ZodMap(key, value, [
        ...rules,
        (
          code: 'too_big',
          validate: (map) =>
              map.length > size ? 'Expected at most $size entries.' : null,
        ),
      ]);

  ZodMap<Key, Value> nonempty() => ZodMap(key, value, [
        ...rules,
        (
          code: 'too_small',
          validate: (map) => map.isEmpty ? 'Expected a non-empty map.' : null,
        ),
      ]);

  ZodMap<Key, Value> length(int size) => ZodMap(key, value, [
        ...rules,
        (
          code: 'invalid_length',
          validate: (map) =>
              map.length == size ? null : 'Expected exactly $size entries.',
        ),
      ]);

  @override
  StandardSchemaResult<Map<Key, Value>> validate(Object? input) {
    if (input is! Map) {
      return const StandardSchemaFailure([
        ZodIssue(message: 'Expected a map.', code: 'invalid_type'),
      ]);
    }

    final results = input.entries
        .map(
          (entry) => (
            originalKey: entry.key,
            key: key.validate(entry.key),
            value: value.validate(entry.value),
          ),
        )
        .toList(growable: false);
    final issues = results.expand((entry) {
      final location = '${entry.originalKey}';
      final keyIssues = switch (entry.key) {
        StandardSchemaSuccess() => const <ZodIssue>[],
        StandardSchemaFailure(issues: final issues) => issues
            .cast<ZodIssue>()
            .map((issue) => issue.at(r'$key').at(location)),
      };
      final valueIssues = switch (entry.value) {
        StandardSchemaSuccess() => const <ZodIssue>[],
        StandardSchemaFailure(issues: final issues) =>
          issues.cast<ZodIssue>().map((issue) => issue.at(location)),
      };
      return [...keyIssues, ...valueIssues];
    }).toList(growable: false);

    if (issues.isNotEmpty) {
      return StandardSchemaFailure(issues);
    }

    final output = Map<Key, Value>.fromEntries(
      results.map(
        (entry) => MapEntry(
          (entry.key as StandardSchemaSuccess<Key>).value,
          (entry.value as StandardSchemaSuccess<Value>).value,
        ),
      ),
    );
    return getRuleResult(output);
  }
}

Future<void> main() async {
  final username = Z.string().min(3).max(20).regex(RegExp(r'^[a-z]+$'));
  final usernameResult = await username.$standard.validate('alice');
  switch (usernameResult) {
    case StandardSchemaSuccess(value: final value):
      print('Valid string: $value');
    case StandardSchemaFailure(issues: final issues):
      print('Invalid string: ${issues.first.message}');
  }

  final age = Z.int().min(18).max(120);
  final ageResult = await age.$standard.validate(30);
  switch (ageResult) {
    case StandardSchemaSuccess(value: final value):
      print('Valid int: $value');
    case StandardSchemaFailure(issues: final issues):
      print('Invalid int: ${issues.first.message}');
  }

  final rating = Z.double().min(0).max(5).finite();
  final ratingResult = await rating.$standard.validate(4.5);
  switch (ratingResult) {
    case StandardSchemaSuccess(value: final value):
      print('Valid double: $value');
    case StandardSchemaFailure(issues: final issues):
      print('Invalid double: ${issues.first.message}');
  }

  final tags = Z.array(Z.string().nonempty()).min(1).max(5).unique();
  final tagsResult = await tags.$standard.validate(['dart', 'schema']);
  switch (tagsResult) {
    case StandardSchemaSuccess(value: final value):
      print('Valid array: $value');
    case StandardSchemaFailure(issues: final issues):
      print('Invalid array: ${issues.first.message}');
  }

  final scores = Z.map(Z.string().nonempty(), Z.int().min(0)).nonempty().max(5);
  final scoresResult =
      await scores.$standard.validate({'quality': 10, 'speed': 9});
  switch (scoresResult) {
    case StandardSchemaSuccess(value: final value):
      print('Valid map: $value');
    case StandardSchemaFailure(issues: final issues):
      print('Invalid map: ${issues.first.message}');
  }
}
