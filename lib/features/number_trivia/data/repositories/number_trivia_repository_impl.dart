import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:latihan_clean_architecture/core/error/failures.dart';
import 'package:latihan_clean_architecture/core/error/exeptions.dart';
import 'package:latihan_clean_architecture/core/network/network_info.dart';
import 'package:latihan_clean_architecture/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:latihan_clean_architecture/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:latihan_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:latihan_clean_architecture/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import '../models/number_travia_model.dart';

typedef Future<NumberTriviaModel> _ConcreteOrRandomChooser();

class NumberTriviaRepositoryImpl implements NumberTriviaRepository {
  final NumberTriviaLocalDataSource localDataSource;
  final NumberTriviaRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  NumberTriviaRepositoryImpl(
      {required this.remoteDataSource,
      required this.localDataSource,
      required this.networkInfo});

  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(
    int number,
  ) {
    return _getTrivia(() {
      return remoteDataSource.getConcreteNumberTrivia(number);
    });
  }

  @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia() async {
    return _getTrivia(() => remoteDataSource.getRandomNumberTrivia());
  }

  ///Handle With Height Order Function
  Future<Either<Failure, NumberTrivia>> _getTrivia(
      _ConcreteOrRandomChooser getConcreteOrRandom) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteTrivia = await getConcreteOrRandom();
        localDataSource.cacheNumberTrivia(remoteTrivia);
        return Right(remoteTrivia);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localTrivia = await localDataSource.getLastNumberTrivia();
        return Right(localTrivia);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
}
