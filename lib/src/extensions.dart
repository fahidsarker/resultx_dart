part of 'result.dart';

/// A convenience typedef for a Future that resolves to a [Result].
/// This represents an asynchronous operation that can either succeed with type [S] or fail with error type [E].
typedef FtrResult<S, E> = Future<Result<S, E>>;

/// A convenience typedef for a Future that resolves to a successful [Result].
/// This represents an asynchronous operation that is expected to succeed with type [S].
typedef FtrSuccess<S, E> = Future<Result<S, E>>;

/// A convenience typedef for a Future that resolves to an error [Result].
/// This represents an asynchronous operation that is expected to fail with error type [E].
typedef FtrError<S, E> = Future<Result<S, E>>;

/// Extension methods for [FtrResult] to provide convenient asynchronous operations.
/// This extension allows chaining operations on Future<Result> without explicit awaiting.
extension FtrResultExt<S, E> on FtrResult<S, E> {
  /// Asynchronously extracts the success value or throws an exception if the result is an error.
  ///
  /// Returns the success data of type [S] if the result is successful.
  /// Throws an [Exception] containing the error if the result is an error.
  Future<S> getOrThrow() async {
    return (await this).getOrThrow();
  }

  /// Asynchronously extracts the success value or returns null if the result is an error.
  ///
  /// Returns the success data of type [S] if the result is successful, or null if it's an error.
  Future<S?> getOrNull() async {
    return (await this).getOrNull();
  }

  /// Asynchronously converts the result to allow nullable success values.
  ///
  /// Returns a [FtrResult] where the success type is nullable [S?].
  FtrResult<S?, E> nullable() async {
    return (await this).nullable();
  }

  /// Asynchronously pattern matches on the result and executes the appropriate callback.
  ///
  /// Takes two required callbacks:
  /// - [success]: Called with the success data if the result is successful
  /// - [error]: Called with the error data if the result is an error
  ///
  /// Returns the value returned by the executed callback.
  Future<T> when<T>(
      {required T Function(S data) success,
      required T Function(E error) error}) async {
    return (await this).when(success: success, error: error);
  }

  /// Asynchronously transforms the success value using a mapper that returns a Result.
  ///
  /// If this result is successful, applies the [mapper] function to the success data
  /// and returns the result. The mapper can return either a sync or async Result.
  /// If this result is an error, returns the error unchanged.
  ///
  /// This is useful for chaining operations that might fail.
  FtrResult<S2, E> mapOnSuccess<S2>(
    FutureOr<Result<S2, E>> Function(S data) mapper,
  ) async {
    return switch (await this) {
      Success<S, E> sucs => await mapper(sucs.data),
      Error<S, E> err => Error(err.error),
    };
  }

  /// Asynchronously transforms the error value using a mapper that returns a Result.
  ///
  /// If this result is an error, applies the [mapper] function to the error data
  /// and returns the result. The mapper can return either a sync or async Result.
  /// If this result is successful, returns the success unchanged.
  ///
  /// This is useful for error recovery or transformation.
  FtrResult<S, E2> mapOnError<E2>(
    FutureOr<Result<S, E2>> Function(E err) mapper,
  ) async {
    return switch (await this) {
      Success<S, E> sucs => Success(sucs.data),
      Error<S, E> err => await mapper(err.error),
    };
  }

  /// Asynchronously executes a side effect if the result is successful.
  ///
  /// If this result is successful, calls the [onSuccess] callback with the success data.
  /// The result is returned unchanged for further chaining.
  /// If this result is an error, no callback is executed.
  FtrResult<S, E> onSuccess(void Function(S data) onSuccess) async {
    return (await this).onSuccess(onSuccess);
  }

  /// Asynchronously executes a side effect if the result is an error.
  ///
  /// If this result is an error, calls the [onError] callback with the error data.
  /// The result is returned unchanged for further chaining.
  /// If this result is successful, no callback is executed.
  FtrResult<S, E> onError(void Function(E error) onError) async {
    return (await this).onError(onError);
  }

  /// Asynchronously converts any error result into a successful result.
  ///
  /// If this result is successful, returns it as-is.
  /// If this result is an error, applies the [onError] function to convert
  /// the error into a success value, ensuring the result is always successful.
  Future<Success<S, E>> resolve({required S Function(E error) onError}) async {
    return (await this).resolve(onError: onError);
  }

  /// Asynchronously forces evaluation of the result without returning any value.
  ///
  /// This is useful when you want to ensure a Future<Result> is evaluated
  /// but don't need to handle the actual result value.
  Future<void> execute() async {
    return (await this).execute();
  }

  /// Asynchronously transforms the success value using a simple mapper function.
  ///
  /// If this result is successful, applies the [mapper] function to transform
  /// the success data to a new type [S2].
  /// If this result is an error, returns the error unchanged.
  FtrResult<S2, E> mapSuccess<S2>(S2 Function(S data) mapper) async {
    return (await this).mapSuccess(mapper);
  }

  /// Asynchronously transforms the error value using a simple mapper function.
  ///
  /// If this result is an error, applies the [mapper] function to transform
  /// the error data to a new type [E2].
  /// If this result is successful, returns the success unchanged.
  FtrResult<S, E2> mapError<E2>(E2 Function(E err) mapper) async {
    return (await this).mapError(mapper);
  }

  /// Asynchronously flattens the result into a tuple.
  ///
  /// Returns a tuple where:
  /// - If successful: (success_data, null)
  /// - If error: (null, error_data)
  Future<(S?, E?)> flat() async {
    return (await this).flat();
  }

  /// Asynchronously checks if this result represents a success.
  ///
  /// Returns true if the result is a [Success], false if it's an [Error].
  Future<bool> get isSuccess async => (await this) is Success<S, E>;

  /// Asynchronously checks if this result represents an error.
  ///
  /// Returns true if the result is an [Error], false if it's a [Success].
  Future<bool> get isError async => (await this) is Error<S, E>;
}

/// Extension methods for Future<Success> to provide convenient operations on successful results.
/// This extension allows direct access to success-specific operations without explicit awaiting.
extension FtrSuccessExt<S, E> on Future<Success<S, E>> {
  /// Asynchronously extracts the success data.
  ///
  /// Returns the wrapped success data of type [S].
  Future<S> get data async => (await this).data;

  /// Asynchronously transforms the success data using a mapper function.
  ///
  /// Applies the [mapper] function to the success data and returns the result.
  /// The mapper must return a type that extends [Result].
  Future<X> map<X extends Result>(
    X Function(S data) mapper,
  ) async {
    return (await this).map(mapper);
  }

  /// Asynchronously flattens the successful result into a tuple.
  ///
  /// Returns a tuple (success_data, null) since this is guaranteed to be successful.
  Future<(S, E?)> flat() async {
    return (await this).flat();
  }
}
