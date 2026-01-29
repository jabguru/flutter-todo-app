import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/core/network/network_provider.dart';
import 'package:todo_app/core/session/session_manager.dart';
import 'package:todo_app/core/storage/local_storage.dart';
import 'package:todo_app/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:todo_app/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:todo_app/features/authentication/data/repositories/auth_repository.dart';
import 'package:todo_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:todo_app/features/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:todo_app/features/todos/data/datasources/todos_local_data_source.dart';
import 'package:todo_app/features/todos/data/datasources/todos_remote_data_source.dart';
import 'package:todo_app/features/todos/data/repositories/todos_repository.dart';
import 'package:todo_app/features/todos/domain/repositories/todos_repository.dart';
import 'package:todo_app/features/todos/presentation/bloc/todos_bloc.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // SESSION MANAGER (ChangeNotifier for reactive UI)
        ChangeNotifierProvider<SessionManager>(
          create: (context) => SessionManager(),
        ),

        RepositoryProvider<NetworkProvider>(
          create: (context) => NetworkProviderImpl(isDebug: kDebugMode),
        ),

        // REPOSITORIES AND SERVICES
        RepositoryProvider<SharedPrefStorage>(
          create: (context) =>
              SharedPrefStorage(sharedPreferences: SharedPreferencesAsync()),
        ),
        RepositoryProvider<SecureLocalStorage>(
          create: (context) => SecureLocalStorage(
            storage: const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            ),
          ),
        ),
        RepositoryProvider<AuthenticationLocalDataSource>(
          create: (context) {
            final dataSource = AuthenticationLocalDataSourceImpl(
              secureStorage: context.read<SecureLocalStorage>(),
              sharedPreferences: context.read<SharedPrefStorage>(),
            )..getAuthToken();
            context.read<NetworkProvider>().updateTokenWithMethod(
              dataSource.getAuthToken(),
            );
            return dataSource;
          },
        ),

        RepositoryProvider<AuthenticationRemoteDataSource>(
          create: (context) => AuthenticationRemoteDataSourceImpl(
            context.read<NetworkProvider>(),
          ),
        ),
        RepositoryProvider<TodosLocalDataSource>(
          create: (context) => TodosLocalDataSourceImpl(
            sharedPreferences: context.read<SharedPrefStorage>(),
          ),
        ),
        RepositoryProvider<TodosRemoteDataSource>(
          create: (context) =>
              TodosRemoteDataSourceImpl(context.read<NetworkProvider>()),
        ),

        // Initialize repositories
        RepositoryProvider<AuthenticationRepository>(
          create: (context) => AuthenticationRepositoryImpl(
            remoteDataSource: context.read<AuthenticationRemoteDataSource>(),
            localDataSource: context.read<AuthenticationLocalDataSource>(),
            onTokenUpdate: (String token) {
              context.read<NetworkProvider>().updateToken(token);
              context.read<SessionManager>().setAuthToken(token);
            },
            onTokenClear: () {
              context.read<NetworkProvider>().clearToken();
              context.read<SessionManager>().clearSession();
            },
          ),
        ),

        RepositoryProvider<TodosRepository>(
          create: (context) => TodosRepositoryImpl(
            remoteDataSource: context.read<TodosRemoteDataSource>(),
            localDataSource: context.read<TodosLocalDataSource>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthenticationBloc(
              repository: context.read<AuthenticationRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) =>
                TodosBloc(repository: context.read<TodosRepository>()),
          ),
        ],
        child: child,
      ),
    );
  }
}
