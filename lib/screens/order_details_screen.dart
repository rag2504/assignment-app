import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../database/database_helper.dart';
import 'package:intl/intl.dart';
import 'add_order_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Order order;

  const OrderDetailsScreen({Key? key, required this.order}) : super(key: key);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late Order _order;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  void _editOrder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddOrderScreen(order: _order),
      ),
    ).then((result) {
      if (result == true) {
        _refreshOrderData();
      }
    });
  }

  Future<void> _refreshOrderData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dbHelper = DatabaseHelper();
      final updatedOrder = await dbHelper.getOrderById(_order.id!);

      if (updatedOrder != null) {
        setState(() {
          _order = updatedOrder;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error refreshing order data: $e"))
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleOrderStatus() async {
    final dbHelper = DatabaseHelper();
    final updatedOrder = Order(
      id: _order.id,
      orderDate: _order.orderDate,
      dueDate: _order.dueDate,
      customerName: _order.customerName,
      customerContact: _order.customerContact,
      projectType: _order.projectType,
      totalAmount: _order.totalAmount,
      advancePaid: _order.advancePaid,
      balanceAmount: _order.balanceAmount,
      paymentMode: _order.paymentMode,
      receivedBy: _order.receivedBy,
      writerAssigned: _order.writerAssigned,
      pages: _order.pages,
      isCompleted: !(_order.isCompleted ?? false),
    );

    await dbHelper.updateOrder(updatedOrder);
    _refreshOrderData();

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
            (_order.isCompleted ?? false) ? "Order reopened" : "Order marked as completed"
        ))
    );
  }

  Future<void> _deleteOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete this order? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("CANCEL"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("DELETE", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final dbHelper = DatabaseHelper();
        await dbHelper.deleteOrder(_order.id!);

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Order deleted successfully"))
        );

        Navigator.pop(context, true); // Return true to indicate the order was deleted
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error deleting order: $e"))
        );
      }
    }
  }

  bool _isOverdue(String dueDateStr) {
    if (dueDateStr.isEmpty) return false;
    try {
      final dueDate = DateTime.parse(dueDateStr);
      return dueDate.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = _order.isCompleted ?? false;
    final bool isOverdue = _isOverdue(_order.dueDate) && !isCompleted;

    return Scaffold(
      appBar: AppBar(
        title: Text("Order Details"),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editOrder,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteOrder,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              color: isCompleted ? Colors.green : (isOverdue ? Colors.red : Colors.orange),
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Text(
                  isCompleted ? "COMPLETED" : (isOverdue ? "OVERDUE" : "PENDING"),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            // Customer Information
            Card(
              margin: EdgeInsets.all(16),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Customer Information",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    Divider(),
                    _buildInfoRow(Icons.person, "Name", _order.customerName),
                    SizedBox(height: 12),
                    _buildInfoRow(Icons.phone, "Contact", _order.customerContact),
                  ],
                ),
              ),
            ),

            // Order Information
            Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order Information",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    Divider(),
                    _buildInfoRow(Icons.assignment, "Project Type", _order.projectType),
                    SizedBox(height: 12),
                    _buildInfoRow(Icons.date_range, "Order Date", _order.orderDate),
                    SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.event_available,
                      "Due Date",
                      _order.dueDate.isEmpty ? "Not set" : _order.dueDate,
                      textColor: isOverdue ? Colors.red : null,
                    ),
                    SizedBox(height: 12),
                    _buildInfoRow(Icons.description, "Pages", "${_order.pages}"),
                    SizedBox(height: 12),
                    _buildInfoRow(Icons.person_outline, "Writer Assigned", _order.writerAssigned),
                  ],
                ),
              ),
            ),

            // Payment Information
            Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Payment Information",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    Divider(),
                    _buildInfoRow(
                      Icons.monetization_on,
                      "Total Amount",
                      "₹${_order.totalAmount.toStringAsFixed(2)}",
                      valueStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.arrow_downward,
                      "Advance Paid",
                      "₹${_order.advancePaid.toStringAsFixed(2)}",
                    ),
                    SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.arrow_upward,
                      "Balance Due",
                      "₹${_order.balanceAmount.toStringAsFixed(2)}",
                      textColor: _order.balanceAmount > 0 ? Colors.red : Colors.green,
                      valueStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildInfoRow(Icons.payment, "Payment Mode", _order.paymentMode),
                    SizedBox(height: 12),
                    _buildInfoRow(Icons.person_pin, "Received By", _order.receivedBy),
                  ],
                ),
              ),
            ),

            // Action Buttons
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(isCompleted ? Icons.refresh : Icons.check_circle),
                      label: Text(isCompleted ? "REOPEN ORDER" : "MARK AS COMPLETED"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCompleted ? Colors.orange : Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _toggleOrderStatus,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? textColor, TextStyle? valueStyle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: valueStyle ?? TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}