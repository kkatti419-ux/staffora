/// Result wrapper for handling success and error states
/// This is a common pattern in clean architecture
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  Result._({this.data, this.error, required this.isSuccess});

  /// Creates a successful result with data
  factory Result.success(T data) {
    return Result._(data: data, isSuccess: true);
  }

  /// Creates an error result with error message
  factory Result.error(String error) {
    return Result._(error: error, isSuccess: false);
  }

  /// Executes onSuccess callback if result is successful
  /// Otherwise executes onError callback
  R when<R>({
    required R Function(T data) onSuccess,
    required R Function(String error) onError,
  }) {
    if (isSuccess && data != null) {
      return onSuccess(data as T);
    } else {
      return onError(error ?? 'Unknown error');
    }
  }
}
