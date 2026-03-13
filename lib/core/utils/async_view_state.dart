enum AsyncViewStatus { idle, loading, success, error }

class AsyncViewState<T> {
  final AsyncViewStatus status;
  final T? data;
  final String? errorMessage;

  const AsyncViewState._({
    required this.status,
    this.data,
    this.errorMessage,
  });

  const AsyncViewState.idle() : this._(status: AsyncViewStatus.idle);

  const AsyncViewState.loading() : this._(status: AsyncViewStatus.loading);

  const AsyncViewState.success(T data)
      : this._(status: AsyncViewStatus.success, data: data);

  const AsyncViewState.error(String message)
      : this._(status: AsyncViewStatus.error, errorMessage: message);

  bool get isIdle => status == AsyncViewStatus.idle;
  bool get isLoading => status == AsyncViewStatus.loading;
  bool get isSuccess => status == AsyncViewStatus.success;
  bool get isError => status == AsyncViewStatus.error;

  R when<R>({
    required R Function() idle,
    required R Function() loading,
    required R Function(T data) success,
    required R Function(String message) error,
  }) {
    return switch (status) {
      AsyncViewStatus.idle => idle(),
      AsyncViewStatus.loading => loading(),
      AsyncViewStatus.success => success(data as T),
      AsyncViewStatus.error => error(errorMessage ?? 'Error desconocido'),
    };
  }

  R maybeWhen<R>({
    R Function()? idle,
    R Function()? loading,
    R Function(T data)? success,
    R Function(String message)? error,
    required R Function() orElse,
  }) {
    return switch (status) {
      AsyncViewStatus.idle => idle?.call() ?? orElse(),
      AsyncViewStatus.loading => loading?.call() ?? orElse(),
      AsyncViewStatus.success => success?.call(data as T) ?? orElse(),
      AsyncViewStatus.error =>
        error?.call(errorMessage ?? 'Error desconocido') ?? orElse(),
    };
  }
}
