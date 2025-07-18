import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:rentify/core/error/failure.dart';

// Yeh ek template hai. Har feature ka usecase isko follow karega.
// Type -> Usecase ka success return type (e.g., UserEntity)
// Params -> Usecase ko diye janay walay parameters (e.g., email, password)
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// Jab kisi usecase mein koi parameter na dena ho.
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
