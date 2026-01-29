import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/core/network/endpoints.dart';
import 'package:todo_app/core/network/network_provider.dart';
import 'package:todo_app/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:todo_app/features/authentication/data/models/auth_response/auth_response.dart';
import 'package:todo_app/features/authentication/data/models/user/user.dart';

import '../../../../fixtures/fixture_helper.dart';

class MockNetworkProvider extends Mock implements NetworkProvider {}

class MockResponse extends Mock implements Response {}

void main() {
  late AuthenticationRemoteDataSourceImpl dataSource;
  late MockNetworkProvider mockNetworkProvider;

  setUp(() {
    mockNetworkProvider = MockNetworkProvider();
    dataSource = AuthenticationRemoteDataSourceImpl(mockNetworkProvider);
  });

  group('AuthenticationRemoteDataSource', () {
    group('login', () {
      test('should return AuthResponse when login is successful', () async {
        // Arrange
        final authResponseJson = FixtureHelper.loadJsonMap('auth_response');
        final response = MockResponse();
        when(() => response.data).thenReturn(authResponseJson);

        when(
          () => mockNetworkProvider.call(
            path: Endpoints.login,
            method: RequestMethod.post,
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => response);

        // Act
        final result = await dataSource.login(
          username: 'emilys',
          password: 'emilyspass',
        );

        // Assert
        expect(result, isA<AuthResponse>());
        expect(result.username, 'emilys');
        expect(result.email, 'emily.johnson@x.dummyjson.com');
        expect(result.accessToken, isNotEmpty);
        verify(
          () => mockNetworkProvider.call(
            path: Endpoints.login,
            method: RequestMethod.post,
            body: {
              'username': 'emilys',
              'password': 'emilyspass',
              'expiresInMins': 60,
            },
          ),
        ).called(1);
      });

      test('should trim username before sending', () async {
        // Arrange
        final authResponseJson = FixtureHelper.loadJsonMap('auth_response');
        final response = MockResponse();
        when(() => response.data).thenReturn(authResponseJson);

        when(
          () => mockNetworkProvider.call(
            path: Endpoints.login,
            method: RequestMethod.post,
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => response);

        // Act
        await dataSource.login(username: '  emilys  ', password: 'emilyspass');

        // Assert
        verify(
          () => mockNetworkProvider.call(
            path: Endpoints.login,
            method: RequestMethod.post,
            body: {
              'username': 'emilys',
              'password': 'emilyspass',
              'expiresInMins': 60,
            },
          ),
        ).called(1);
      });

      test('should use custom expiresInMins when provided', () async {
        // Arrange
        final authResponseJson = FixtureHelper.loadJsonMap('auth_response');
        final response = MockResponse();
        when(() => response.data).thenReturn(authResponseJson);

        when(
          () => mockNetworkProvider.call(
            path: Endpoints.login,
            method: RequestMethod.post,
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => response);

        // Act
        await dataSource.login(
          username: 'emilys',
          password: 'emilyspass',
          expiresInMins: 120,
        );

        // Assert
        verify(
          () => mockNetworkProvider.call(
            path: Endpoints.login,
            method: RequestMethod.post,
            body: {
              'username': 'emilys',
              'password': 'emilyspass',
              'expiresInMins': 120,
            },
          ),
        ).called(1);
      });
    });

    group('getCurrentUser', () {
      test('should return User when getCurrentUser is successful', () async {
        // Arrange
        final userJson = FixtureHelper.loadJsonMap('user');
        final response = MockResponse();
        when(() => response.data).thenReturn(userJson);

        when(
          () => mockNetworkProvider.call(
            path: Endpoints.currentUser,
            method: RequestMethod.get,
          ),
        ).thenAnswer((_) async => response);

        // Act
        final result = await dataSource.getCurrentUser();

        // Assert
        expect(result, isA<User>());
        expect(result.id, 1);
        expect(result.username, 'emilys');
        expect(result.email, 'emily.johnson@x.dummyjson.com');
        verify(
          () => mockNetworkProvider.call(
            path: Endpoints.currentUser,
            method: RequestMethod.get,
          ),
        ).called(1);
      });
    });
  });
}
