import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/core/network/error/failures.dart';
import 'package:todo_app/features/authentication/data/models/auth_response/auth_response.dart';
import 'package:todo_app/features/authentication/data/models/user/user.dart';
import 'package:todo_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:todo_app/features/authentication/presentation/bloc/authentication_bloc.dart';

class MockAuthRepository extends Mock implements AuthenticationRepository {}

void main() {
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  group('AuthenticationBloc', () {
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

    test('initial state is AuthenticationInitial', () {
      final bloc = AuthenticationBloc(repository: mockRepository);
      expect(bloc.state, AuthenticationInitial());
      bloc.close();
    });

    group('LoginEvent', () {
      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [LoginLoading, LoginSuccess] when login is successful',
        build: () {
          when(
            () => mockRepository.login(
              username: any(named: 'username'),
              password: any(named: 'password'),
            ),
          ).thenAnswer((_) async => Right(testAuthResponse));
          return AuthenticationBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(
          const LoginEvent(username: 'emilys', password: 'emilyspass'),
        ),
        expect: () => [
          LoginLoading(),
          isA<LoginSuccess>()
              .having(
                (state) => state.authResponse.username,
                'username',
                'emilys',
              )
              .having(
                (state) => state.authResponse.accessToken,
                'access token',
                'test_access_token',
              ),
        ],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [LoginLoading, LoginError] when login fails',
        build: () {
          when(
            () => mockRepository.login(
              username: any(named: 'username'),
              password: any(named: 'password'),
            ),
          ).thenAnswer(
            (_) async => Left(Failure(message: 'Invalid credentials')),
          );
          return AuthenticationBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(
          const LoginEvent(username: 'emilys', password: 'wrongpass'),
        ),
        expect: () => [
          LoginLoading(),
          const LoginError(message: 'Invalid credentials'),
        ],
      );
    });

    group('CheckAuthenticationStatusEvent', () {
      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [AuthenticationLoading, AuthenticationAuthenticated] when user is authenticated',
        build: () {
          when(
            () => mockRepository.isAuthenticated(),
          ).thenAnswer((_) async => const Right(true));
          when(
            () => mockRepository.getCachedUser(),
          ).thenAnswer((_) async => const Right(testUser));
          return AuthenticationBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(const CheckAuthenticationStatusEvent()),
        expect: () => [
          AuthenticationLoading(),
          isA<AuthenticationAuthenticated>()
              .having((state) => state.user.username, 'username', 'emilys')
              .having((state) => state.user.id, 'id', 1),
        ],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [AuthenticationLoading, AuthenticationUnauthenticated] when user is not authenticated',
        build: () {
          when(
            () => mockRepository.isAuthenticated(),
          ).thenAnswer((_) async => const Right(false));
          return AuthenticationBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(const CheckAuthenticationStatusEvent()),
        expect: () => [
          AuthenticationLoading(),
          AuthenticationUnauthenticated(),
        ],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [AuthenticationLoading, AuthenticationUnauthenticated] when isAuthenticated fails',
        build: () {
          when(
            () => mockRepository.isAuthenticated(),
          ).thenAnswer((_) async => Left(Failure(message: 'Storage error')));
          return AuthenticationBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(const CheckAuthenticationStatusEvent()),
        expect: () => [
          AuthenticationLoading(),
          AuthenticationUnauthenticated(),
        ],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [AuthenticationLoading, AuthenticationUnauthenticated] when authenticated but no cached user',
        build: () {
          when(
            () => mockRepository.isAuthenticated(),
          ).thenAnswer((_) async => const Right(true));
          when(
            () => mockRepository.getCachedUser(),
          ).thenAnswer((_) async => const Right(null));
          return AuthenticationBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(const CheckAuthenticationStatusEvent()),
        expect: () => [
          AuthenticationLoading(),
          AuthenticationUnauthenticated(),
        ],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [AuthenticationLoading, AuthenticationUnauthenticated] when authenticated but getCachedUser fails',
        build: () {
          when(
            () => mockRepository.isAuthenticated(),
          ).thenAnswer((_) async => const Right(true));
          when(
            () => mockRepository.getCachedUser(),
          ).thenAnswer((_) async => Left(Failure(message: 'No user found')));
          return AuthenticationBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(const CheckAuthenticationStatusEvent()),
        expect: () => [
          AuthenticationLoading(),
          AuthenticationUnauthenticated(),
        ],
      );
    });

    group('LogoutEvent', () {
      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [AuthenticationLoading, LogoutSuccess] when logout is successful',
        build: () {
          when(
            () => mockRepository.logout(),
          ).thenAnswer((_) async => const Right(null));
          return AuthenticationBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(const LogoutEvent()),
        expect: () => [AuthenticationLoading(), LogoutSuccess()],
        verify: (_) {
          verify(() => mockRepository.logout()).called(1);
        },
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [AuthenticationLoading, AuthenticationError] when logout fails',
        build: () {
          when(
            () => mockRepository.logout(),
          ).thenAnswer((_) async => Left(Failure(message: 'Logout failed')));
          return AuthenticationBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(const LogoutEvent()),
        expect: () => [
          AuthenticationLoading(),
          const AuthenticationError(message: 'Logout failed'),
        ],
      );
    });

    group('GetCurrentUserEvent', () {
      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [AuthenticationLoading, AuthenticationAuthenticated] when getCurrentUser is successful',
        build: () {
          when(
            () => mockRepository.getCurrentUser(),
          ).thenAnswer((_) async => const Right(testUser));
          return AuthenticationBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(const GetCurrentUserEvent()),
        expect: () => [
          AuthenticationLoading(),
          isA<AuthenticationAuthenticated>()
              .having((state) => state.user.username, 'username', 'emilys')
              .having(
                (state) => state.user.email,
                'email',
                'emily.johnson@x.dummyjson.com',
              ),
        ],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [AuthenticationLoading, AuthenticationError] when getCurrentUser fails',
        build: () {
          when(() => mockRepository.getCurrentUser()).thenAnswer(
            (_) async => Left(Failure(message: 'Failed to fetch user')),
          );
          return AuthenticationBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(const GetCurrentUserEvent()),
        expect: () => [
          AuthenticationLoading(),
          const AuthenticationError(message: 'Failed to fetch user'),
        ],
      );
    });
  });
}
