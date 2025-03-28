import 'package:flutter/material.dart';
import 'customer_stats_screen.dart'; // Import the new screen
import 'reports_page.dart'; // Import ReportsPage

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildActionButton("Add Order", Icons.add_shopping_cart, Colors.purple, () {
                Navigator.pushNamed(context, '/addOrder');
              }),

              SizedBox(height: 10),

              _buildActionButton("View Orders", Icons.view_list, Colors.blue, () {
                Navigator.pushNamed(context, '/viewOrders');
              }),

              SizedBox(height: 10),

              _buildActionButton("Customer Stats", Icons.people, Colors.teal, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CustomerStatsScreen()),
                );
              }),

              SizedBox(height: 10),

              _buildActionButton("Reports", Icons.analytics, Colors.indigo, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReportsPage()),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(text, style: TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}