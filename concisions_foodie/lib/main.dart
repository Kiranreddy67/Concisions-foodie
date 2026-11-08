import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens.dart';
import 'state.dart';

void main() => runApp(ChangeNotifierProvider(
    create: (_) => AppState(), child: const FoodieApp()));

ThemeData buildTheme(Brightness b) {
  final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF3E7B27), brightness: b, secondary: const Color(0xFFE4572E));
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: b == Brightness.light ? const Color(0xFFF1F6EC) : null,
    cardTheme: CardThemeData(
        elevation: 0,
        color: b == Brightness.light ? Colors.white : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
    inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
    filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
            minimumSize: const Size(48, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
    textTheme: const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        titleLarge: TextStyle(fontWeight: FontWeight.w700)),
  );
}

class FoodieApp extends StatelessWidget {
  const FoodieApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = context.select<AppState, bool>((s) => s.dark);
    return MaterialApp(
      title: 'Concisions Foodie',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      onGenerateRoute: (s) {
        final Widget page = switch (s.name) {
          '/' => const Splash(),
          '/login' => const Login(),
          '/home' => const Shell(),
          '/add' => const AddFood(),
          '/food' => FoodDetail(food: s.arguments as Food),
          _ => const Splash(),
        };
        return PageRouteBuilder(
          settings: s,
          pageBuilder: (_, __, ___) => page,
          transitionDuration: const Duration(milliseconds: 350),
          transitionsBuilder: (_, a, __, child) => FadeTransition(
              opacity: a,
              child: SlideTransition(
                  position: Tween(begin: const Offset(0, .04), end: Offset.zero)
                      .animate(CurvedAnimation(parent: a, curve: Curves.easeOut)),
                  child: child)),
        );
      },
    );
  }
}
