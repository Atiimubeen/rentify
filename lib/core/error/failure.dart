import 'package:equatable/equatable.dart';

// Iska kaam UI ko batana hai ke koi masla hua hai
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// Server se related maslon ke liye
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

// Local data (cache) se related maslon ke liye
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}
