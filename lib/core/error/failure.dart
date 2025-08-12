import 'package:equatable/equatable.dart';

import 'error_context.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// General failures
class ServerFailure extends Failure {
  final ErrorContext context;
  const ServerFailure(super.message, this.context);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class UnauthorizedFailure extends ServerFailure {
    const UnauthorizedFailure(super.message, super.context);
}

class NotFoundFailure extends ServerFailure {
  const NotFoundFailure(super.message, super.context);
}
