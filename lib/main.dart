import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/add_order_screen.dart';
import 'screens/view_orders_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Assignment App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: HomeScreen(),
      routes: {
        '/addOrder': (context) => AddOrderScreen(),
        '/viewOrders': (context) => ViewOrdersScreen(),
        // Add other routes here if needed
      },
    );
  }
}