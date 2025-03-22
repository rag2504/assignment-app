import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/add_order_screen.dart';
import 'screens/view_orders_screen.dart';
import 'screens/customer_stats_screen.dart';
import 'screens/reports_page.dart'; // Import ReportsPage

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable debug banner
      title: 'Admin App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: HomeScreen(),
      routes: {
        '/addOrder': (context) => AddOrderScreen(),
        '/viewOrders': (context) => ViewOrdersScreen(),
        '/customerStats': (context) => CustomerStatsScreen(),
        '/reports': (context) => ReportsPage(), // Add route for ReportsPage
      },
    );
  }
}