import 'package:flutter/material.dart';
import 'package:todo_app/app/app_providers.dart';
import 'package:todo_app/global/routes/app_routes.dart';
import 'package:todo_app/global/theme/theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      child: MaterialApp.router(
        title: 'Todo App',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRoutes.router(),
      ),
    );
  }
}
