import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:latihan_clean_architecture/core/error/failures.dart';
import 'package:latihan_clean_architecture/core/usecases/usecases.dart';
import 'package:latihan_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:latihan_clean_architecture/features/number_trivia/domain/repositories/number_trivia_repository.dart';

class GetConcreteNumberTrivia implements UseCase<NumberTrivia, Params> {
  final NumberTriviaRepository repository;

  GetConcreteNumberTrivia(this.repository);

  @override
  Future<Either<Failure, NumberTrivia>> call(Params params) async =>
      await repository.getConcreteNumberTrivia(params.number);
}

class Params extends Equatable {
  final int number;

  Params({required this.number});

  @override
  List<Object?> get props => [number];
}
