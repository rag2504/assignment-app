import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/customer_form_screen.dart';
import 'screens/financial_screen.dart';
import 'screens/writer_screen.dart';
import 'utils/constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/addCustomer': (context) => CustomerFormScreen(),
        '/financialDetails': (context) => FinancialScreen(),
        '/writerDetails': (context) => WriterScreen(),
      },
    );
  }
}
