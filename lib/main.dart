import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'screens/home_screen.dart';
import 'services/analytics_service.dart';
import 'services/ios_block_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ScrollRokApp());
}

class ScrollRokApp extends StatelessWidget {
  const ScrollRokApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme baseScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF00796B),
      brightness: Brightness.light,
    );

    return ChangeNotifierProvider<AppState>(
      create: (_) => AppState(
        iosBlockService: IOSBlockService(),
        analyticsService: AnalyticsService(),
      )..initialize(),
      child: MaterialApp(
        title: 'ScrollRok iOS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFF6F7FB),
          colorScheme: baseScheme.copyWith(
            primary: const Color(0xFF00796B),
            secondary: const Color(0xFF26A69A),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF6F7FB),
            foregroundColor: Colors.black87,
            centerTitle: false,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

