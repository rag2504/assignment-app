import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int totalOrders = 0;
  double totalRevenue = 0.0;
  int pendingOrders = 0;

  @override
  void initState() {
    super.initState();
    _fetchFinancialData();
  }

  Future<void> _fetchFinancialData() async {
    final dbHelper = DatabaseHelper();
    final customers = await dbHelper.getCustomers(); // ✅ FIXED

    setState(() {
      totalOrders = customers.length;
      totalRevenue = customers.fold(0, (sum, customer) => sum + customer.totalAmount); // ✅ FIXED
      pendingOrders = customers.where((c) => c.balanceAmount > 0).length; // ✅ FIXED
    });
  }

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCard("Total Orders", totalOrders.toString(), Icons.assignment, Colors.blue),
            _buildStatCard("Total Revenue", "₹$totalRevenue", Icons.attach_money, Colors.green),
            _buildStatCard("Pending Orders", pendingOrders.toString(), Icons.pending, Colors.red),

            SizedBox(height: 20),

            _buildActionButton("Add Customer", Icons.person_add, Colors.purple, () {
              Navigator.pushNamed(context, '/addCustomer');
            }),

            SizedBox(height: 10),

            _buildActionButton("Financial Details", Icons.bar_chart, Colors.orange, () {
              Navigator.pushNamed(context, '/financialDetails');
            }),

            SizedBox(height: 10),

            _buildActionButton("Writer Details", Icons.edit, Colors.teal, () {
              Navigator.pushNamed(context, '/writerDetails');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
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
