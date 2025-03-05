import 'package:ai_nutritionist/config/theme.dart';
import 'package:ai_nutritionist/home.dart';
import 'package:ai_nutritionist/settings.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      theme: ThemeData.from(colorScheme: lightColorScheme),
      darkTheme: ThemeData.from(colorScheme: darkColorScheme),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
