import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/match_provider.dart';
import 'screens/setup_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MatchProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = ThemeData.dark().textTheme;
    return MaterialApp(
      title: 'Ludo Stats Tracker',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.tealAccent,
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: baseTextTheme.copyWith(
          bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontSize: 18, color: Colors.white),
          bodyMedium: baseTextTheme.bodyMedium?.copyWith(fontSize: 18, color: Colors.white),
          titleLarge: baseTextTheme.titleLarge?.copyWith(fontSize: 20, color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.tealAccent,
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
      ),
      home: const SetupScreen(),
    );
  }
}
