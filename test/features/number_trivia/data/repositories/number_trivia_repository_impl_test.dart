import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latihan_clean_architecture/core/error/exeptions.dart';
import 'package:latihan_clean_architecture/core/error/failures.dart';
import 'package:latihan_clean_architecture/features/number_trivia/data/models/number_travia_model.dart';
import 'package:latihan_clean_architecture/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:latihan_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:mockito/mockito.dart';
import '../../../../helpers/test_helper.mocks.dart';

void main() {
  late NumberTriviaRepositoryImpl repositoryImpl;
  late MockNumberTriviaRemoteDataSource mockNumberTriviaRemoteDataSource;
  late MockNumberTriviaLocalDataSource mockNumberTriviaLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockNumberTriviaRemoteDataSource = MockNumberTriviaRemoteDataSource();
    mockNumberTriviaLocalDataSource = MockNumberTriviaLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repositoryImpl = NumberTriviaRepositoryImpl(
        remoteDataSource: mockNumberTriviaRemoteDataSource,
        localDataSource: mockNumberTriviaLocalDataSource,
        networkInfo: mockNetworkInfo);
  });

  void runTestOnline(Function body) {
    group('device is online', () {
      // This setUp applies only to the 'device is online' group
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });
      body();
    });
  }

  void runTestOffline(Function body) {
    group('device is offline', () {
      // This setUp applies only to the 'device is online' group
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
      body();
    });
  }

  group('getConcreteNumberTrivia', () {
    // DATA FOR THE MOCKS AND ASSERTIONS
    // We'll use these three variables throughout all the tests
    final tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel(number: tNumber, text: 'test trivia');
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test('should check if the device is online', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockNumberTriviaRemoteDataSource.getConcreteNumberTrivia(tNumber))
          .thenAnswer((_) async => tNumberTriviaModel);
      // act
      await repositoryImpl.getConcreteNumberTrivia(tNumber);
      // assert
      verify(mockNetworkInfo.isConnected);
    });

    runTestOnline(() {
      // This setUp applies only to the 'device is online' group
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test(
        'should return remote data when the call to remote data source is successful',
        () async {
          // arrange
          when(mockNumberTriviaRemoteDataSource
                  .getConcreteNumberTrivia(tNumber))
              .thenAnswer((_) async => tNumberTriviaModel);
          // act
          final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);
          // assert
          verify(mockNumberTriviaRemoteDataSource
              .getConcreteNumberTrivia(tNumber));
          expect(result, equals(Right(tNumberTrivia)));
        },
      );
      test(
        'should cache the data locally when the call to remote data source is successful',
        () async {
          // arrange
          /// uncomment when run test without run test group
          /// when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
          when(mockNumberTriviaRemoteDataSource
                  .getConcreteNumberTrivia(tNumber))
              .thenAnswer((_) async => tNumberTriviaModel);
          // act
          await repositoryImpl.getConcreteNumberTrivia(tNumber);
          // assert
          verify(mockNumberTriviaRemoteDataSource
              .getConcreteNumberTrivia(tNumber));
          verify(mockNumberTriviaLocalDataSource
              .cacheNumberTrivia(tNumberTriviaModel));
        },
      );

      test(
        'should return server failure when the call to remote data source is unsuccessful',
        () async {
          // arrange
          when(mockNumberTriviaRemoteDataSource
                  .getConcreteNumberTrivia(tNumber))
              .thenThrow(ServerException());
          // act
          final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);
          // assert
          verify(mockNumberTriviaRemoteDataSource
              .getConcreteNumberTrivia(tNumber));
          verifyZeroInteractions(mockNumberTriviaLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestOffline(() {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
      test('should return last locally cache data when the data is present',
          () async {
        // arrange
        when(mockNumberTriviaLocalDataSource.getLastNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        //act
        final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);
        //assert
        verifyZeroInteractions(mockNumberTriviaRemoteDataSource);
        verify(mockNumberTriviaLocalDataSource.getLastNumberTrivia());
        expect(result, Right(tNumberTrivia));
      });

      test('should return CacheFailure when there is no cached data present',
          () async {
        // arrange
        when(mockNumberTriviaLocalDataSource.getLastNumberTrivia())
            .thenThrow(CacheException());
        //act
        final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);
        //assert
        verifyZeroInteractions(mockNumberTriviaRemoteDataSource);
        verify(mockNumberTriviaLocalDataSource.getLastNumberTrivia());
        expect(result, Left(CacheFailure()));
      });
    });
  });

  group('getRandomNumberTrivia', () {
    // DATA FOR THE MOCKS AND ASSERTIONS
    // We'll use these three variables throughout all the tests
    final tNumberTriviaModel =
        NumberTriviaModel(number: 123, text: 'test trivia');
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test('should check if the device is online', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockNumberTriviaRemoteDataSource.getRandomNumberTrivia())
          .thenAnswer((_) async => tNumberTriviaModel);
      // act
      await repositoryImpl.getRandomNumberTrivia();
      // assert
      verify(mockNetworkInfo.isConnected);
    });

    runTestOnline(() {
      // This setUp applies only to the 'device is online' group
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test(
        'should return remote data when the call to remote data source is successful',
        () async {
          // arrange
          when(mockNumberTriviaRemoteDataSource.getRandomNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          // act
          final result = await repositoryImpl.getRandomNumberTrivia();
          // assert
          verify(mockNumberTriviaRemoteDataSource.getRandomNumberTrivia());
          expect(result, equals(Right(tNumberTrivia)));
        },
      );
      test(
        'should cache the data locally when the call to remote data source is successful',
        () async {
          // arrange
          /// uncomment when run test without run test group
          /// when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
          when(mockNumberTriviaRemoteDataSource.getRandomNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          // act
          await repositoryImpl.getRandomNumberTrivia();
          // assert
          verify(mockNumberTriviaRemoteDataSource.getRandomNumberTrivia());
          verify(mockNumberTriviaLocalDataSource
              .cacheNumberTrivia(tNumberTriviaModel));
        },
      );

      test(
        'should return server failure when the call to remote data source is unsuccessful',
        () async {
          // arrange
          when(mockNumberTriviaRemoteDataSource.getRandomNumberTrivia())
              .thenThrow(ServerException());
          // act
          final result = await repositoryImpl.getRandomNumberTrivia();
          // assert
          verify(mockNumberTriviaRemoteDataSource.getRandomNumberTrivia());
          verifyZeroInteractions(mockNumberTriviaLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestOffline(() {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
      test('should return last locally cache data when the data is present',
          () async {
        // arrange
        when(mockNumberTriviaLocalDataSource.getLastNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        //act
        final result = await repositoryImpl.getRandomNumberTrivia();
        //assert
        verifyZeroInteractions(mockNumberTriviaRemoteDataSource);
        verify(mockNumberTriviaLocalDataSource.getLastNumberTrivia());
        expect(result, Right(tNumberTrivia));
      });

      test('should return CacheFailure when there is no cached data present',
          () async {
        // arrange
        when(mockNumberTriviaLocalDataSource.getLastNumberTrivia())
            .thenThrow(CacheException());
        //act
        final result = await repositoryImpl.getRandomNumberTrivia();
        //assert
        verifyZeroInteractions(mockNumberTriviaRemoteDataSource);
        verify(mockNumberTriviaLocalDataSource.getLastNumberTrivia());
        expect(result, Left(CacheFailure()));
      });
    });
  });
}
