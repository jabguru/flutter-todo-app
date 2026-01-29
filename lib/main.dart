import 'package:flutter/material.dart';
import 'package:todo_app/app/app_providers.dart';
import 'package:todo_app/features/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:todo_app/global/routes/app_routes.dart';
import 'package:todo_app/global/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    AuthenticationBloc? authBloc;
    return AppProviders(
      child: MaterialApp.router(
        title: 'Todo App',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRoutes.router(authBloc),
      ),
    );
  }
}
