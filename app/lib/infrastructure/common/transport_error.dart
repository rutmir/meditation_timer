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
