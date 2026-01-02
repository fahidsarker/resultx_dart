library results;

import 'dart:async';

part 'extensions.dart';

/// A sealed class representing the result of an operation that can either succeed or fail.
///
/// [Result] is a type-safe way to handle operations that might fail without using exceptions.
/// It can be either a [Success] containing data of type [S], or an [Error] containing an error of type [E].
///
/// This follows the Railway-oriented programming pattern and is similar to Rust's Result type.
///
/// Example:
/// ```dart
/// Result<String, String> divide(int a, int b) {
///   if (b == 0) {
///     return Error('Division by zero');
///   }
///   return Success((a / b).toString());
/// }
/// ```
sealed class Result<S, E> {
  const Result();

  /// Creates a successful result containing the given [data].
  ///
  /// This is a convenience factory constructor that wraps [data] in a [Success].
  ///
  /// Example:
  /// ```dart
  /// final result = Result.success('Hello World');
  /// print(result.isSuccess); // true
  /// ```
  static Result<S, E> success<S, E>(S data) => Success<S, E>(data);

  /// Creates an error result containing the given [error].
  ///
  /// This is a convenience factory constructor that wraps [error] in an [Error].
  ///
  /// Example:
  /// ```dart
  /// final result = Result.error('Something went wrong');
  /// print(result.isError); // true
  /// ```
  static Result<S, E> error<S, E>(E error) => Error<S, E>(error);

  /// Executes a function and wraps its result or any thrown exception in a [Result].
  ///
  /// If [fn] executes successfully, returns a [Success] containing the returned value.
  /// If [fn] throws any exception, returns an [Error] containing the thrown exception.
  ///
  /// This is useful for converting throwing code into Result-based error handling.
  ///
  /// Example:
  /// ```dart
  /// final result = Result.handle(() => int.parse('123'));
  /// // Returns Success(123)
  ///
  /// final errorResult = Result.handle(() => int.parse('abc'));
  /// // Returns Error(FormatException)
  /// ```
  static Result<S, dynamic> handle<S>(S Function() fn) {
    try {
      return Success<S, dynamic>(fn());
    } catch (e) {
      return Error<S, dynamic>(e);
    }
  }

  /// Awaits a [Future] and wraps its result or any thrown exception in a [Result].
  ///
  /// If [ftr] completes successfully, returns a [Success] containing the completed value.
  /// If [ftr] throws any exception or is rejected, returns an [Error] containing the exception.
  ///
  /// This is useful for converting Future-based async operations into Result-based error handling.
  ///
  /// Example:
  /// ```dart
  /// final result = await Result.future(http.get('https://api.example.com'));
  /// // Returns Success(response) or Error(exception)
  /// ```
  static Future<Result<S, dynamic>> future<S>(Future<S> ftr) async {
    try {
      return Success<S, dynamic>(await ftr);
    } catch (e) {
      return Error<S, dynamic>(e);
    }
  }

  /// Returns true if this result represents a successful operation.
  bool get isSuccess => this is Success<S, E>;

  /// Returns true if this result represents a failed operation.
  bool get isError => this is Error<S, E>;

  /// Converts this result to allow nullable success values.
  ///
  /// Returns a new [Result] where the success type is [S?] instead of [S].
  /// This is useful when you want to chain operations that might return null.
  Result<S?, E> nullable() {
    return when(
      success: (data) => Success(data),
      error: (err) => Error(err),
    );
  }

  /// Pattern matches on this result and executes the appropriate callback.
  ///
  /// This is the primary way to extract values from a [Result]. You must provide
  /// both callbacks to handle both success and error cases.
  ///
  /// - [success]: Called with the success data if this result is successful
  /// - [error]: Called with the error data if this result is an error
  ///
  /// Returns the value returned by the executed callback.
  T when<T>({
    required T Function(S data) success,
    required T Function(E error) error,
  }) {
    return switch (this) {
      Success<S, E> sucs => success(sucs.data),
      Error<S, E> err => error(err.error),
    };
  }

  /// Extracts the success value or throws an exception if this result is an error.
  ///
  /// Returns the success data of type [S] if this result is successful.
  /// Throws an [Exception] containing the error if this result is an error.
  ///
  /// Use this method when you're confident the result should be successful
  /// and want to fail fast if it's not.
  S getOrThrow() {
    return when(
      success: (data) => data,
      error: (err) => throw Exception(err),
    );
  }

  /// Extracts the success value or returns null if this result is an error.
  ///
  /// Returns the success data of type [S] if this result is successful,
  /// or null if this result is an error.
  ///
  /// This is useful when you want to handle errors by treating them as absence of value.
  S? getOrNull() {
    return when(
      success: (data) => data,
      error: (err) => null,
    );
  }

  /// Transforms the success value using a mapper function.
  ///
  /// If this result is successful, applies the [mapper] function to transform
  /// the success data to a new type [S2].
  /// If this result is an error, returns the error unchanged.
  ///
  /// This is useful for transforming successful values without affecting errors.
  Result<S2, E> mapSuccess<S2>(S2 Function(S data) mapper) {
    return switch (this) {
      Success<S, E> sucs => Success(mapper(sucs.data)),
      Error<S, E> err => Error(err.error),
    };
  }

  /// Transforms the success value using a mapper that returns a Result.
  ///
  /// If this result is successful, applies the [mapper] function to the success data.
  /// The mapper should return a new [Result] which allows for chaining operations that might fail.
  /// If this result is an error, returns the error unchanged.
  ///
  /// This is the monadic bind operation, useful for chaining fallible operations.
  Result<S2, E> mapOnSuccess<S2>(Result<S2, E> Function(S data) mapper) {
    return switch (this) {
      Success<S, E> sucs => mapper(sucs.data),
      Error<S, E> err => Error(err.error),
    };
  }

  /// Transforms the error value using a mapper function.
  ///
  /// If this result is an error, applies the [mapper] function to transform
  /// the error data to a new type [E2].
  /// If this result is successful, returns the success unchanged.
  ///
  /// This is useful for transforming error types without affecting successful values.
  Result<S, E2> mapError<E2>(E2 Function(E err) mapper) {
    return switch (this) {
      Success<S, E> sucs => Success(sucs.data),
      Error<S, E> err => Error(mapper(err.error)),
    };
  }

  /// Transforms the error value using a mapper that returns a Result.
  ///
  /// If this result is an error, applies the [mapper] function to the error data.
  /// The mapper should return a new [Result] which allows for error recovery or transformation.
  /// If this result is successful, returns the success unchanged.
  ///
  /// This is useful for error recovery scenarios where you want to potentially convert errors to successes.
  Result<S, E2> mapOnError<E2>(Result<S, E2> Function(E err) mapper) {
    return switch (this) {
      Success<S, E> sucs => Success(sucs.data),
      Error<S, E> err => mapper(err.error),
    };
  }

  /// Executes a side effect if this result is successful.
  ///
  /// If this result is successful, calls the [onSuccess] callback with the success data.
  /// The result is returned unchanged, allowing for method chaining.
  /// If this result is an error, no callback is executed.
  ///
  /// This is useful for logging, debugging, or other side effects.
  Result<S, E> onSuccess(void Function(S data) onSuccess) {
    final v = this;
    if (v is Success<S, E>) {
      onSuccess(v.data);
    }
    return this;
  }

  /// Executes a side effect if this result is an error.
  ///
  /// If this result is an error, calls the [onError] callback with the error data.
  /// The result is returned unchanged, allowing for method chaining.
  /// If this result is successful, no callback is executed.
  ///
  /// This is useful for logging errors, debugging, or other side effects.
  Result<S, E> onError(void Function(E error) onError) {
    final v = this;
    if (v is Error<S, E>) {
      onError(v.error);
    }
    return this;
  }

  /// Converts any error result into a successful result using a recovery function.
  ///
  /// If this result is successful, returns it as-is.
  /// If this result is an error, applies the [onError] function to convert
  /// the error into a success value.
  ///
  /// This ensures the returned result is always a [Success], making it useful
  /// when you want to provide fallback values for any errors.
  Success<S, E> resolve({required S Function(E error) onError}) {
    return switch (this) {
      Success<S, E> sucs => sucs,
      Error<S, E> err => Success(onError(err.error)),
    };
  }

  /// Forces evaluation of this result without returning any value.
  ///
  /// This method ensures the result is processed (calling the appropriate callbacks)
  /// but discards any return value. Useful when you want to trigger side effects
  /// or ensure lazy evaluation is completed.
  void execute() {
    when(success: (_) {}, error: (_) {});
  }

  /// Flattens this result into a tuple representation.
  ///
  /// Returns a tuple where:
  /// - If successful: (success_data, null)
  /// - If error: (null, error_data)
  ///
  /// This provides an alternative way to destructure results using pattern matching.
  (S?, E?) flat() {
    return when(success: (dta) => (dta, null), error: (e) => (null, e));
  }
}

/// Represents a successful result containing data of type [S].
///
/// This is one of the two concrete implementations of [Result], used when
/// an operation completes successfully and produces a value.
///
/// Example:
/// ```dart
/// final result = Success('Hello World');
/// print(result.data); // 'Hello World'
/// ```
class Success<S, E> extends Result<S, E> {
  /// The successful data wrapped by this result.
  final S data;

  /// Creates a new [Success] result containing the given [data].
  const Success(this.data);

  /// Transforms this success using a mapper function.
  ///
  /// Applies the [mapper] function to the wrapped data and returns the result.
  /// The mapper must return a type that extends [Result].
  ///
  /// This is useful for transforming successful values in a type-safe way.
  X map<X extends Result>(
    X Function(S data) mapper,
  ) {
    return mapper(data);
  }

  /// Returns a string representation of this successful result.
  ///
  /// Format: 'Success {data: <data_value>}'
  @override
  toString() {
    return 'Success {data: $data}';
  }

  /// Flattens this successful result into a tuple.
  ///
  /// Returns (data, null) since this is a successful result.
  @override
  (S, E?) flat() {
    return (data, null);
  }
}

/// Represents a failed result containing an error of type [E].
///
/// This is one of the two concrete implementations of [Result], used when
/// an operation fails and produces an error instead of a successful value.
///
/// Example:
/// ```dart
/// final result = Error('Something went wrong');
/// print(result.error); // 'Something went wrong'
/// ```
class Error<S, E> extends Result<S, E> {
  /// The error data wrapped by this result.
  final E error;

  /// Creates a new [Error] result containing the given [error].
  const Error(this.error);

  /// Transforms this error using a mapper function.
  ///
  /// Applies the [errorMapper] function to the wrapped error and returns the result.
  /// The mapper must return a type that extends [Result].
  ///
  /// This is useful for transforming or handling errors in a type-safe way.
  X map<X extends Result>(
    X Function(E error) errorMapper,
  ) {
    return errorMapper(error);
  }

  /// Returns a string representation of this error result.
  ///
  /// Format: 'Error {error: <error_value>}'
  @override
  toString() {
    return 'Error {error: $error}';
  }

  /// Flattens this error result into a tuple.
  ///
  /// Returns (null, error) since this is an error result.
  @override
  (S?, E) flat() {
    return (null, error);
  }
}
