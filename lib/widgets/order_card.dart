import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  final String customerName;
  final String orderDate;
  final String dueDate;
  final double totalAmount;
  final String paymentStatus;

  const OrderCard({
    Key? key,
    required this.customerName,
    required this.orderDate,
    required this.dueDate,
    required this.totalAmount,
    required this.paymentStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: ListTile(
        title: Text(customerName, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order Date: $orderDate"),
            Text("Due Date: $dueDate"),
            Text("Total Amount: ₹$totalAmount"),
            Text("Payment: $paymentStatus"),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16.0),
      ),
    );
  }
}
