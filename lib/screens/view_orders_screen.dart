import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/order_model.dart';
import 'add_order_screen.dart';

class ViewOrdersScreen extends StatefulWidget {
  @override
  _ViewOrdersScreenState createState() => _ViewOrdersScreenState();
}

class _ViewOrdersScreenState extends State<ViewOrdersScreen> {
  List<Order> orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final dbHelper = DatabaseHelper();
    final fetchedOrders = await dbHelper.getOrders();
    setState(() {
      orders = fetchedOrders;
    });
  }

  Future<void> _deleteOrder(int id) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.deleteOrder(id);
    _fetchOrders();
  }

  void _editOrder(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddOrderScreen(order: order),
      ),
    ).then((_) => _fetchOrders());
  }

  void _viewOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Order Details"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Order Date: ${order.orderDate}"),
              Text("Due Date: ${order.dueDate}"),
              Text("Customer Name: ${order.customerName}"),
              Text("Customer Contact: ${order.customerContact}"),
              Text("Order Type: ${order.projectType}"),
              Text("Total Amount: ${order.totalAmount}"),
              Text("Advance Paid: ${order.advancePaid}"),
              Text("Remaining Amount: ${order.balanceAmount}"),
              Text("Payment Mode: ${order.paymentMode}"),
              Text("Received By: ${order.receivedBy}"),
              Text("Order Given To (Writer): ${order.writerAssigned}"),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Close")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("View Orders")),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            child: ListTile(
              title: Text(order.customerName),
              subtitle: Text("Pending Amount: ${order.balanceAmount}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: Icon(Icons.visibility), onPressed: () => _viewOrderDetails(order)),
                  IconButton(icon: Icon(Icons.edit), onPressed: () => _editOrder(order)),
                  IconButton(icon: Icon(Icons.delete), onPressed: () => _deleteOrder(order.id!)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}