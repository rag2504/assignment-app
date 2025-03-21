import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/customer_model.dart';

class WriterScreen extends StatefulWidget {
  @override
  _WriterScreenState createState() => _WriterScreenState();
}

class _WriterScreenState extends State<WriterScreen> {
  List<Customer> writerOrders = [];

  @override
  void initState() {
    super.initState();
    _fetchWriterOrders();
  }

  Future<void> _fetchWriterOrders() async {
    final dbHelper = DatabaseHelper();
    final customers = await dbHelper.getCustomers(); // ✅ FIXED
    setState(() {
      writerOrders = customers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Writer Orders")),
      body: writerOrders.isEmpty
          ? Center(child: Text("No orders assigned to writers yet."))
          : ListView.builder(
        itemCount: writerOrders.length,
        itemBuilder: (context, index) {
          final order = writerOrders[index];
          return Card(
            child: ListTile(
              title: Text("Writer: ${order.writerAssigned}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Order Type: ${order.projectType}"),
                  Text("Total Amount: ₹${order.totalAmount}"),
                  Text("Advance Paid: ₹${order.advancePaid}"),
                  Text("Balance Amount: ₹${order.balanceAmount}"),
                  Text("Writer Contact: ${order.writerContact}"),
                  Text("Order Date: ${order.orderDate}"),
                  Text("Due Date: ${order.dueDate}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
