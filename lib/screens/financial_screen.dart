import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';


class FinancialScreen extends StatefulWidget {
  @override
  _FinancialScreenState createState() => _FinancialScreenState();
}

class _FinancialScreenState extends State<FinancialScreen> {
  double monthlyRevenue = 0.0;
  int monthlyOrders = 0;

  @override
  void initState() {
    super.initState();
    _fetchMonthlyFinancialData();
  }

  Future<void> _fetchMonthlyFinancialData() async {
    final dbHelper = DatabaseHelper();
    final customers = await dbHelper.getCustomers();
    String currentMonth = DateFormat('MM-yyyy').format(DateTime.now());

    final monthlyCustomers = customers.where((customer) {
      try {
        String orderMonth = DateFormat('MM-yyyy').format(
          DateFormat('dd-MM-yyyy').parse(customer.orderDate),
        );
        return orderMonth == currentMonth;
      } catch (e) {
        print("Date parsing error: ${customer.orderDate}");
        return false;
      }
    }).toList();

    setState(() {
      monthlyOrders = monthlyCustomers.length;
      monthlyRevenue = monthlyCustomers.fold(0, (sum, customer) => sum + customer.totalAmount);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Financial Summary")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                title: const Text("Total Orders This Month"),
                subtitle: Text("$monthlyOrders"),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text("Total Revenue This Month"),
                subtitle: Text("₹${monthlyRevenue.toStringAsFixed(2)}"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
