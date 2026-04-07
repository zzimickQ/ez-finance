import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server error occurred'});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache error occurred'});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Network error occurred'});
}

class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Authentication error occurred'});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message = 'Unauthorized'});
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure({super.message = 'Forbidden'});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'Not found'});
}

class ValidationFailure extends Failure {
  final Map<String, String>? errors;

  const ValidationFailure({super.message = 'Validation error', this.errors});

  @override
  List<Object?> get props => [message, errors];
}
