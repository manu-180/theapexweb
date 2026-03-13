sealed class AppException implements Exception {
  final String message;
  final String? code;
  final Object? cause;

  const AppException(this.message, {this.code, this.cause});

  @override
  String toString() => '$runtimeType: $message';
}

/// Supabase client null or infrastructure unavailable.
class InfrastructureException extends AppException {
  const InfrastructureException(super.message, {super.code, super.cause});
}

/// Invalid input data that should have been caught by the UI.
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code, super.cause});
}

/// External provider (Resend, Twilio, MercadoPago) failed.
class ProviderException extends AppException {
  const ProviderException(super.message, {super.code, super.cause});
}
