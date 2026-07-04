/// Common type aliases used across the application.
library;

/// JSON object type.
typedef JSON = Map<String, dynamic>;

/// JSON list type.
typedef JSONList = List<Map<String, dynamic>>;

/// Generic async callback.
typedef AsyncCallback = Future<void> Function();

/// Generic value callback.
typedef ValueCallback<T> = void Function(T value);

/// Generic async value callback.
typedef AsyncValueCallback<T> = Future<void> Function(T value);

/// Predicate function.
typedef Predicate<T> = bool Function(T value);
