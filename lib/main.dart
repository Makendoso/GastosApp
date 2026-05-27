import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app.dart';
import 'data/providers/finance_providers.dart';
import 'data/services/local_finance_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  final localFinanceService = await LocalFinanceService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        localFinanceServiceProvider.overrideWithValue(localFinanceService),
      ],
      child: const FinanceApp(),
    ),
  );
}
