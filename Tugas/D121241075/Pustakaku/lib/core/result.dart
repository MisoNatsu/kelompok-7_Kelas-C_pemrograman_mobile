/// Advanced Dart: sealed class + generics + pattern matching.
///
/// `Result<T>` dipakai oleh semua service agar error tidak dilempar
/// sembarangan ke UI. Karena class ini `sealed`, compiler memaksa
/// setiap `switch` menangani kedua kasus (Success & Failure).
sealed class Result<T> {
  const Result();

  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(String message, [Object? error]) = Failure<T>;

  bool get isSuccess => this is Success<T>;

  /// Mengubah data di dalam Success tanpa menyentuh Failure (seperti `map` pada Option/Either).
  Result<R> map<R>(R Function(T data) transform) => switch (this) {
        Success(:final data) => Result.success(transform(data)),
        Failure(:final message, :final error) => Result.failure(message, error),
      };

  /// Ekstrak nilai: `result.when(success: ..., failure: ...)`.
  R when<R>({
    required R Function(T data) success,
    required R Function(String message) failure,
  }) =>
      switch (this) {
        Success(:final data) => success(data),
        Failure(:final message) => failure(message),
      };

  /// Mengambil data atau nilai pengganti.
  T getOrElse(T fallback) =>
      switch (this) { Success(:final data) => data, Failure() => fallback };
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;

  @override
  String toString() => 'Success($data)';
}

final class Failure<T> extends Result<T> {
  const Failure(this.message, [this.error]);
  final String message;
  final Object? error;

  @override
  String toString() => 'Failure($message)';
}

/// Helper: membungkus Future apa pun menjadi Result, menerjemahkan exception
/// menjadi pesan yang ramah pengguna.
Future<Result<T>> guard<T>(
  Future<T> Function() task, {
  String Function(Object error)? onError,
}) async {
  try {
    return Result.success(await task());
  } catch (e) {
    return Result.failure(onError?.call(e) ?? e.toString(), e);
  }
}

/// Exception dengan pesan siap tampil (toString() hanya mengembalikan pesan,
/// sehingga `AsyncValue.error` di Riverpod bisa langsung ditampilkan).
final class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

extension ResultX<T> on Result<T> {
  /// Untuk dipakai di FutureProvider: data dikembalikan, Failure dilempar
  /// sebagai AppException agar menjadi AsyncError.
  T getOrThrow() => switch (this) {
        Success(:final data) => data,
        Failure(:final message) => throw AppException(message),
      };
}
