import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/app/app_providers.dart';
import 'package:todo_app/features/settings/presentation/cubit/theme_cubit.dart';
import 'package:todo_app/global/routes/app_routes.dart';
import 'package:todo_app/global/theme/theme.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GoRouter _router = AppRoutes.router();

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: 'Todo App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: context.watch<ThemeCubit>().state.themeMode,
            debugShowCheckedModeBanner: false,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
