import 'package:flutter/material.dart';

import 'core/navigation/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi App de Gastos',
      theme: AppTheme.light,
      routes: AppRoutes.routes,
      home: const HomeScreen(),
    );
  }
}
