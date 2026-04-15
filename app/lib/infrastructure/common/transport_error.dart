import './app_error.dart';

class TransportError extends AppError {
  final Uri? uri;
  TransportError([super.message, this.uri]);
}

// http errors ------------------------------

class BadRequestError extends TransportError {
  BadRequestError([super.message, super.uri]);
}

class ForbiddenError extends TransportError {
  ForbiddenError([super.message, super.uri]);
}

class UnauthorizedRequestError extends TransportError {
  UnauthorizedRequestError([super.message, super.uri]);
}

class InternalServerError extends TransportError {
  InternalServerError([super.message, super.uri]);
}

class NotFoundError extends TransportError {
  NotFoundError([super.message, super.uri]);
}

/// 402 Payment Required — wallet doesn't hold enough ROEX.
class PaymentRequiredError extends TransportError {
  /// Minimum ROEX token units the wallet must hold (ui amount, 6 decimals).
  final double requiredRoex;
  /// Current ROEX/USD price used for the calculation.
  final double priceUsd;

  PaymentRequiredError({
    required this.requiredRoex,
    required this.priceUsd,
    Uri? uri,
  }) : super('payment required', uri);
}

class UnsupportedMediaTypeError extends TransportError {
  UnsupportedMediaTypeError([super.message, super.uri]);
}

// --------------------------

class BadDataFormatError extends TransportError {
  BadDataFormatError([super.message, super.uri]);
}

class NoConnectionError extends TransportError {
  NoConnectionError([super.message, super.uri]);
}
