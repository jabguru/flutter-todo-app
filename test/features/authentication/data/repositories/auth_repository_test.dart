import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/core/network/error/api_error.dart';
import 'package:todo_app/core/network/error/failures.dart';
import 'package:todo_app/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:todo_app/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:todo_app/features/authentication/data/models/auth_response/auth_response.dart';
import 'package:todo_app/features/authentication/data/models/login_credentials/login_credentials.dart';
import 'package:todo_app/features/authentication/data/models/user/user.dart';
import 'package:todo_app/features/authentication/data/repositories/auth_repository.dart';

class MockAuthRemoteDataSource extends Mock
    implements AuthenticationRemoteDataSource {}

class MockAuthLocalDataSource extends Mock
    implements AuthenticationLocalDataSource {}

class FakeUser extends Fake implements User {}

class FakeLoginCredentials extends Fake implements LoginCredentials {}

void main() {
  late AuthenticationRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late bool tokenUpdated;
  late bool tokenCleared;

  setUpAll(() {
    registerFallbackValue(FakeUser());
    registerFallbackValue(FakeLoginCredentials());
  });

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    tokenUpdated = false;
    tokenCleared = false;

    repository = AuthenticationRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      onTokenUpdate: (token) => tokenUpdated = true,
      onTokenClear: () => tokenCleared = true,
    );
  });

  group('AuthenticationRepository', () {
    const testUsername = 'emilys';
    const testPassword = 'emilyspass';
    const testUser = User(
      id: 1,
      username: 'emilys',
      email: 'emily.johnson@x.dummyjson.com',
      firstName: 'Emily',
      lastName: 'Johnson',
      gender: 'female',
      image: 'https://dummyjson.com/icon/emilys/128',
    );
    final testAuthResponse = AuthResponse(
      accessToken: 'test_access_token',
      refreshToken: 'test_refresh_token',
      id: 1,
      username: 'emilys',
      email: 'emily.johnson@x.dummyjson.com',
      firstName: 'Emily',
      lastName: 'Johnson',
      gender: 'female',
      image: 'https://dummyjson.com/icon/emilys/128',
    );

    group('login', () {
      test('should return AuthResponse when login is successful', () async {
        // Arrange
        when(
          () => mockRemoteDataSource.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => testAuthResponse);
        when(
          () => mockLocalDataSource.saveAuthToken(any()),
        ).thenAnswer((_) async => {});
        when(
          () => mockLocalDataSource.saveRefreshToken(any()),
        ).thenAnswer((_) async => {});
        when(
          () => mockLocalDataSource.saveUser(any()),
        ).thenAnswer((_) async => {});
        when(
          () => mockLocalDataSource.saveLoginCredentials(any()),
        ).thenAnswer((_) async => {});

        // Act
        final result = await repository.login(
          username: testUsername,
          password: testPassword,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold((failure) => fail('Should not return failure'), (
          authResponse,
        ) {
          expect(authResponse, testAuthResponse);
          expect(authResponse.username, testUsername);
        });
        expect(tokenUpdated, true);
        verify(
          () => mockLocalDataSource.saveAuthToken('test_access_token'),
        ).called(1);
        verify(
          () => mockLocalDataSource.saveRefreshToken('test_refresh_token'),
        ).called(1);
        verify(() => mockLocalDataSource.saveUser(any())).called(1);
        verify(() => mockLocalDataSource.saveLoginCredentials(any())).called(1);
      });

      test('should return Failure when login fails with ApiError', () async {
        // Arrange
        when(
          () => mockRemoteDataSource.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          ),
        ).thenThrow(
          ApiError(errorCode: '401', errorMessage: 'Invalid credentials'),
        );

        // Act
        final result = await repository.login(
          username: testUsername,
          password: testPassword,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<Failure>());
          expect(failure.message, 'Invalid credentials');
        }, (_) => fail('Should not return success'));
        expect(tokenUpdated, false);
        verifyNever(() => mockLocalDataSource.saveAuthToken(any()));
      });

      test(
        'should return Failure when login fails with generic exception',
        () async {
          // Arrange
          when(
            () => mockRemoteDataSource.login(
              username: any(named: 'username'),
              password: any(named: 'password'),
            ),
          ).thenThrow(Exception('Network error'));

          // Act
          final result = await repository.login(
            username: testUsername,
            password: testPassword,
          );

          // Assert
          expect(result.isLeft(), true);
          result.fold((failure) {
            expect(failure, isA<Failure>());
            expect(failure.message, isNotEmpty);
          }, (_) => fail('Should not return success'));
        },
      );
    });

    group('getCurrentUser', () {
      test('should return User and cache it when successful', () async {
        // Arrange
        when(
          () => mockRemoteDataSource.getCurrentUser(),
        ).thenAnswer((_) async => testUser);
        when(
          () => mockLocalDataSource.saveUser(any()),
        ).thenAnswer((_) async => {});

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result.isRight(), true);
        result.fold((failure) => fail('Should not return failure'), (user) {
          expect(user, testUser);
          expect(user.username, 'emilys');
        });
        verify(() => mockLocalDataSource.saveUser(testUser)).called(1);
      });

      test('should return Failure when getCurrentUser fails', () async {
        // Arrange
        when(
          () => mockRemoteDataSource.getCurrentUser(),
        ).thenThrow(ApiError(errorMessage: 'Unauthorized'));

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<Failure>());
          expect(failure.message, 'Unauthorized');
        }, (_) => fail('Should not return success'));
        verifyNever(() => mockLocalDataSource.saveUser(any()));
      });
    });

    group('isAuthenticated', () {
      test('should return true when auth token exists', () async {
        // Arrange
        when(
          () => mockLocalDataSource.getAuthToken(),
        ).thenAnswer((_) async => 'valid_token');

        // Act
        final result = await repository.isAuthenticated();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (isAuth) => expect(isAuth, true),
        );
      });

      test('should return false when auth token is null', () async {
        // Arrange
        when(
          () => mockLocalDataSource.getAuthToken(),
        ).thenAnswer((_) async => null);

        // Act
        final result = await repository.isAuthenticated();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (isAuth) => expect(isAuth, false),
        );
      });

      test('should return false when auth token is empty', () async {
        // Arrange
        when(
          () => mockLocalDataSource.getAuthToken(),
        ).thenAnswer((_) async => '');

        // Act
        final result = await repository.isAuthenticated();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (isAuth) => expect(isAuth, false),
        );
      });
    });

    group('getCachedUser', () {
      test('should return cached User when available', () async {
        // Arrange
        when(
          () => mockLocalDataSource.getUser(),
        ).thenAnswer((_) async => testUser);

        // Act
        final result = await repository.getCachedUser();

        // Assert
        expect(result.isRight(), true);
        result.fold((failure) => fail('Should not return failure'), (user) {
          expect(user, testUser);
          expect(user?.username, 'emilys');
        });
      });

      test('should return null when no cached user', () async {
        // Arrange
        when(() => mockLocalDataSource.getUser()).thenAnswer((_) async => null);

        // Act
        final result = await repository.getCachedUser();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (user) => expect(user, isNull),
        );
      });
    });

    group('logout', () {
      test('should clear auth data and call onTokenClear', () async {
        // Arrange
        when(
          () => mockLocalDataSource.clearAuthData(),
        ).thenAnswer((_) async => {});

        // Act
        final result = await repository.logout();

        // Assert
        expect(result.isRight(), true);
        expect(tokenCleared, true);
        verify(() => mockLocalDataSource.clearAuthData()).called(1);
      });

      test('should return Failure when clearAuthData fails', () async {
        // Arrange
        when(
          () => mockLocalDataSource.clearAuthData(),
        ).thenThrow(Exception('Failed to clear data'));

        // Act
        final result = await repository.logout();

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<Failure>());
        }, (_) => fail('Should not return success'));
      });
    });
  });
}
