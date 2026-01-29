import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/core/storage/local_storage_exception.dart';
import 'package:todo_app/core/storage/secure_local_storage.dart';
import 'package:todo_app/core/storage/shared_pref_storage.dart';
import 'package:todo_app/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:todo_app/features/authentication/data/models/login_credentials/login_credentials.dart';
import 'package:todo_app/features/authentication/data/models/user/user.dart';

class MockSecureLocalStorage extends Mock implements SecureLocalStorage {}

class MockSharedPrefStorage extends Mock implements SharedPrefStorage {}

void main() {
  late AuthenticationLocalDataSourceImpl dataSource;
  late MockSecureLocalStorage mockSecureStorage;
  late MockSharedPrefStorage mockSharedPreferences;

  setUp(() {
    mockSecureStorage = MockSecureLocalStorage();
    mockSharedPreferences = MockSharedPrefStorage();
    dataSource = AuthenticationLocalDataSourceImpl(
      secureStorage: mockSecureStorage,
      sharedPreferences: mockSharedPreferences,
    );
  });

  group('AuthenticationLocalDataSource', () {
    const testToken = 'test_token_123';
    const testRefreshToken = 'test_refresh_token_456';
    const testUser = User(
      id: 1,
      username: 'emilys',
      email: 'emily.johnson@x.dummyjson.com',
      firstName: 'Emily',
      lastName: 'Johnson',
      gender: 'female',
      image: 'https://dummyjson.com/icon/emilys/128',
    );
    const testCredentials = LoginCredentials(
      username: 'emilys',
      password: 'emilyspass',
    );

    group('Auth Token', () {
      test('saveAuthToken should store token in secure storage', () async {
        // Arrange
        when(
          () => mockSecureStorage.put(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async => {});

        // Act
        await dataSource.saveAuthToken(testToken);

        // Assert
        verify(
          () => mockSecureStorage.put(key: 'AUTH_TOKEN_KEY', value: testToken),
        ).called(1);
      });

      test('getAuthToken should return token from secure storage', () async {
        // Arrange
        when(
          () => mockSecureStorage.get(any()),
        ).thenAnswer((_) async => testToken);

        // Act
        final result = await dataSource.getAuthToken();

        // Assert
        expect(result, testToken);
        verify(() => mockSecureStorage.get('AUTH_TOKEN_KEY')).called(1);
      });

      test('getAuthToken should return null on storage exception', () async {
        // Arrange
        when(
          () => mockSecureStorage.get(any()),
        ).thenThrow(const LocalStorageException('No token found'));

        // Act
        final result = await dataSource.getAuthToken();

        // Assert
        expect(result, isNull);
      });
    });

    group('Refresh Token', () {
      test('saveRefreshToken should store token in secure storage', () async {
        // Arrange
        when(
          () => mockSecureStorage.put(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async => {});

        // Act
        await dataSource.saveRefreshToken(testRefreshToken);

        // Assert
        verify(
          () => mockSecureStorage.put(
            key: 'REFRESH_TOKEN_KEY',
            value: testRefreshToken,
          ),
        ).called(1);
      });

      test('getRefreshToken should return token from secure storage', () async {
        // Arrange
        when(
          () => mockSecureStorage.get(any()),
        ).thenAnswer((_) async => testRefreshToken);

        // Act
        final result = await dataSource.getRefreshToken();

        // Assert
        expect(result, testRefreshToken);
        verify(() => mockSecureStorage.get('REFRESH_TOKEN_KEY')).called(1);
      });

      test('getRefreshToken should return null on storage exception', () async {
        // Arrange
        when(
          () => mockSecureStorage.get(any()),
        ).thenThrow(const LocalStorageException('No token found'));

        // Act
        final result = await dataSource.getRefreshToken();

        // Assert
        expect(result, isNull);
      });
    });

    group('User', () {
      test('saveUser should store user in shared preferences', () async {
        // Arrange
        when(
          () => mockSharedPreferences.put(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async => {});

        // Act
        await dataSource.saveUser(testUser);

        // Assert
        verify(
          () => mockSharedPreferences.put(
            key: 'USER_KEY',
            value: any(named: 'value'),
          ),
        ).called(1);
      });

      test('getUser should return user from shared preferences', () async {
        // Arrange
        final userJson = testUser.toJson();
        when(
          () => mockSharedPreferences.get(any()),
        ).thenAnswer((_) async => userJson);

        // Act
        final result = await dataSource.getUser();

        // Assert
        expect(result, isA<User>());
        expect(result?.id, testUser.id);
        expect(result?.username, testUser.username);
        verify(() => mockSharedPreferences.get('USER_KEY')).called(1);
      });

      test('getUser should return null on storage exception', () async {
        // Arrange
        when(
          () => mockSharedPreferences.get(any()),
        ).thenThrow(const LocalStorageException('No user found'));

        // Act
        final result = await dataSource.getUser();

        // Assert
        expect(result, isNull);
      });
    });

    group('Login Credentials', () {
      test(
        'saveLoginCredentials should store credentials in secure storage',
        () async {
          // Arrange
          when(
            () => mockSecureStorage.put(
              key: any(named: 'key'),
              value: any(named: 'value'),
            ),
          ).thenAnswer((_) async => {});

          // Act
          await dataSource.saveLoginCredentials(testCredentials);

          // Assert
          verify(
            () => mockSecureStorage.put(
              key: 'LOGIN_CREDENTIALS_KEY',
              value: any(named: 'value'),
            ),
          ).called(1);
        },
      );

      test(
        'getLoginCredentials should return credentials from secure storage',
        () async {
          // Arrange
          final credentialsJson = testCredentials.toJson();
          when(
            () => mockSecureStorage.get(any()),
          ).thenAnswer((_) async => credentialsJson);

          // Act
          final result = await dataSource.getLoginCredentials();

          // Assert
          expect(result, isA<LoginCredentials>());
          expect(result?.username, testCredentials.username);
          verify(
            () => mockSecureStorage.get('LOGIN_CREDENTIALS_KEY'),
          ).called(1);
        },
      );

      test(
        'getLoginCredentials should return null on storage exception',
        () async {
          // Arrange
          when(
            () => mockSecureStorage.get(any()),
          ).thenThrow(const LocalStorageException('No credentials found'));

          // Act
          final result = await dataSource.getLoginCredentials();

          // Assert
          expect(result, isNull);
        },
      );
    });

    group('clearAuthData', () {
      test(
        'should clear all auth data from secure and shared storage',
        () async {
          // Arrange
          when(
            () => mockSecureStorage.delete(any()),
          ).thenAnswer((_) async => {});
          when(
            () => mockSharedPreferences.delete(any()),
          ).thenAnswer((_) async => {});

          // Act
          await dataSource.clearAuthData();

          // Assert
          verify(
            () => mockSecureStorage.delete({
              'AUTH_TOKEN_KEY',
              'REFRESH_TOKEN_KEY',
              'LOGIN_CREDENTIALS_KEY',
            }),
          ).called(1);
          verify(() => mockSharedPreferences.delete({'USER_KEY'})).called(1);
        },
      );
    });
  });
}
