<h1 align="center">resultX</h1>

<br />

  <p align="center">
    A Future Aware Result class to grcefully handle success and error and their Futures without the need to await on each step. It focuses on functional usage and method chaining to handle the results.
    <br />
    <!-- Put the link for the documentation here -->
    <a href="https://pub.dev/documentation/resultx/latest/"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <!-- Disable unused links with with comments -->
    <a href="https://github.com/fahidsarker/dart_results/issues">Report Bug</a>
    ·
    <a href="https://github.com/fahidsarker/dart_results/pulls">Request Feature</a>
  </p>

<br>

<div align='center'>

[![Pub Points](https://img.shields.io/pub/points/resultx?label=pub%20points&style=plastic)](https://pub.dev/packages/resultx/score)
[![Pub Points](https://img.shields.io/pub/v/resultx)](https://img.shields.io/pub/v/resultx)
[![Pub Points](https://img.shields.io/pub/dm/resultx)](https://img.shields.io/pub/dm/resultx)

</div>

<br>

# resultx

A dart `Future` aware, functional (FP) `result` package to handle success and error inspired by kotlin's `Result` class and `Either` class.

## Features

- A `Result` class that can be either a `Success` or an `Error`.
- Focuses on functional programing and handeling of Results instead of imperative programing.
- A `Future` aware `Result` class that can be either a `Success` or an `Error`.
  - `Feature aware` means you can keep on chaining callbacks and mapping methods `without` the need to `await` on each callback.
  - e.g. `asyncResult.mapSuccess((data) => data.length).mapSuccess((len) => len > 5)`
  - More example can be found below
- Fully typesafe - All the types are typed and checked at compile time.
- Supports `nullable` and `getOrThrow` methods or convert to `dart` record `(data, error)` using `.flat()` method.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  results: ^1.0.2 # add the latest version
```

## Usage

### _Creating a Result_

A `Result<S, E>` can be either a `Success` or an `Error`. A `Success` is a result that contains a value of type `S` and an error of type `E`. An `Error` is a result that contains an error of type `E`.

Example:

```dart
Result<User, String> getUser([bool success = true])  {
  if (!success) {
    return Error('Error getting user'); // or Result.error('Error getting user');
  }
  final user = User('Dart User', 30);
  return Success(user); // or Result.success(user);
}
```

or With Future:

```dart
// typedef FtrResult<S, E> = Future<Result<S, E>>;
FtrResult<User, String> getUser([bool success = true]) async {
  await Future.delayed(Duration(milliseconds: 10));
  if (!success) {
    return Error('Error getting user');
  }
  return Success(User('Dart User', 30));
}
```

### _Resolve a result or get a value_

When trying to get the value of a `Result`, we must tell the system how to handle the error. `.resolve()` is one of the ways to do that.

```dart
Result<int, String> getStatusCode([bool success = true]) {
  if (!success) {
    return Error('Error getting Status');
  }
  return Success(1);
}
// we must tell the system how to handle the error. Resolve is one of the ways
final statusCode = await getStatusCode().resolve(onError: (_) => -1).data;
print('Status code: $statusCode');
```

> `.resovle()` returns a `Success` class and hence you can directly call `.data` on it.

### _Use `when` to better handle the result_

`.when()` is a way to handle the result. It takes two functions as parameters, one for success and one for error. You can either return a value or do something else.

```dart
import 'package:resultx/resultx.dart';
await getUser().when(
    success: (user) => print('showWhenDemo :: Success Occured: $user'),
    error: (e) => print('showWhenDemo :: Error Occured: $e'),
);

// you can also return a value from when clause if needed
final res = await getUser(false).when(
    success: (user) => 'showWhenDemo :: Success Occured: $user',
    error: (e) => 'showWhenDemo :: Error Occured: $e',
  );
print(res);
```

### _Use `getOrThrow` to throw an error_

`.getOrThrow()` is a way to get the value of a `Success` class. If the result is an `Error` class, it will throw an error.

```dart
import 'package:resultx/resultx.dart';
try {
  final user = await getUser().getOrThrow();
  print('Success Occured: $user');
} catch (e) {
  print('Error Occured: $e');
}
```

### _Use the `flat()` method to get the data and error as a dart record_

You can use this to get the data and error as a dart record.

```dart
import 'package:resultx/resultx.dart';
final (user, error) = await getUser().flat();
print('User: $user, Error: $error');
```

### _Use the `.execute()` method when you dont care about the result_

Use `.execute()` to when you dont care about the result.

```dart
import 'package:resultx/resultx.dart';
// dont care if it succeeds or fails
await updateAnalytics().execute();
```

### _Use the `.nullable()` method to make it nullable_

Sometimes you want to make a `Result` nullable even if the original result was not nullable. You can use `.nullable()` to make it nullable first and handle other mappings on it.

```dart
import 'package:resultx/resultx.dart';
// ❌ this will result in compilation error as the getUser()
// returns a Result<User, String> and not a Result<User?, String>
final user = await getUser().resolve(onError: (_) => null).data;

// ✅ this will work as the .nullable converts the type to Result<User?, String>
final user = await getUser().nullable().resolve(onError: (_) => null).data;
print('User Unchanged: $user');
```

### _Chaining callbacks with the `onSuccess` and `onError` methods_

You can chain callbacks with the `onSuccess` and `onError` methods. No need to await on each callback.

```dart
import 'package:resultx/resultx.dart';
// chain as many callbacks as you want
// no need to call await on each callback
// results handle the futures internally
final user = await getUser()
    .onSuccess((user) => print('showCallBackDemo :: Success Occured: $user'))
    .onError((e) => print('showCallBackDemo :: Error Occured: $e'))
    .onSuccess(
    (user) => print('showCallBackDemo 2ndCallBack :: User : $user'),
    )
    .nullable()
    .resolve(onError: (_) => null)
    .data;
print('User : $user');
// Note how we used a single `await` on the `getUser()`
```

### _Mapping methods to to map the `data` and `error` of a `Result`_

you can use the methods `.mapSuccess` and `.mapError` to map the `data` and `error` of a `Result`.

```dart
import 'package:resultx/resultx.dart';
// no need of async or await. Simply map the value to something else
FtrResult<int, int> getStatusCode([bool success = true]) {
// getUser() returns a Result<User, String>
// we can map the data to int and error to int
  return getUser(success).mapSuccess((_) => 1).mapError((_) => -1);
}
```

### _Mapping methods to to map the `data` and `error` of a `Result` to another `Result`_

```dart
import 'package:resultx/resultx.dart';
FtrResult<bool, String> isUserActive(User user) async {
  await Future.delayed(Duration(milliseconds: 10));
  return Success(user.name.length > 5); // dummy
}
final user = await getUser()
      .mapOnSuccess(
        (user) => isUserActive(user).mapSuccess(
          (isActive) => UserWithActiveStatus(user.name, user.age, isActive),
        ),
      )
      .nullable()
      .resolve(onError: (_) => null)
      .data;

// Note how we used a single `await` on the `getUser()`
```

### _Future aware `Result` class_

Notice above that for every scenerio, we did not have to resolve a Future first to use `Results` methods. This is because `Results` was built with `Future` awareness in mind. You can use any methods available on Result class also on `Future<Result<S, E>>` class. without the need to `await` on each callback.

❌ Bad Example:

```dart
import 'package:resultx/resultx.dart';
// first await on Future
final userResult = await getUser();
// execute other methods
final userActiveResult = await userResult.mapOnSuccess(
        (user) => isUserActive(user).mapSuccess(
          (isActive) => UserWithActiveStatus(user.name, user.age, isActive),
        ),
      )

final userWithActiveNullable = await userActiveResult.nullable();
final userWithActive = await userWithActiveNullable.resolve(onError: (_) => null);
print('User : $userWithActive');
```

✅ Good Example:

```dart
import 'package:resultx/resultx.dart';
final user = await getUser()
      .mapOnSuccess(
        (user) => isUserActive(user).mapSuccess(
          (isActive) => UserWithActiveStatus(user.name, user.age, isActive),
        ),
      )
      .nullable()
      .resolve(onError: (_) => null)
      .data;
```

Happy Coding 😁
