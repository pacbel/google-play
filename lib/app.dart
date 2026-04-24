import 'package:flutter/material.dart';
import 'features/crypto/presentation/pages/crypto_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4AF37),
          brightness: Brightness.dark,
          surface: const Color(0xFF2C343C),
          onSurface: const Color(0xFFC0C0C0),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF2C343C),
        fontFamily: 'sans-serif',
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      home: const CryptoPage(),
    );
  }
}
