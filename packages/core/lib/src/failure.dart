import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No connection']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Request timed out']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Unauthorized']);
}

class ServerFailure extends Failure {
  const ServerFailure({
    required this.statusCode,
    String message = 'Server error',
  }) : super(message);

  final int statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

class ParsingFailure extends Failure {
  const ParsingFailure([super.message = 'Invalid response format']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Unknown error']);
}
