import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import 'add_order_screen.dart';
import '../database/database_helper.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final String customerName;
  final String customerContact;
  final List<Order> orders;

  CustomerDetailsScreen({
    required this.customerName,
    required this.customerContact,
    required this.orders,
  });

  @override
  _CustomerDetailsScreenState createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  List<Order> orders = [];
  double totalSpent = 0;
  int totalOrders = 0;
  int completedOrders = 0;

  @override
  void initState() {
    super.initState();
    orders = List.from(widget.orders);
    _calculateStatistics();
  }

  void _calculateStatistics() {
    totalOrders = orders.length;
    totalSpent = orders.fold(0, (sum, order) => sum + order.totalAmount);
    completedOrders = orders.where((order) => order.isCompleted ?? false).length;
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  Future<void> _addNewOrder() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddOrderScreen(
          prefillName: widget.customerName,
          prefillContact: widget.customerContact,
        ),
      ),
    );

    if (result == true) {
      // Order added, refresh data
      final dbHelper = DatabaseHelper();
      final allOrders = await dbHelper.getOrders();
      setState(() {
        orders = allOrders.where((order) =>
        order.customerName == widget.customerName &&
            order.customerContact == widget.customerContact
        ).toList();
        _calculateStatistics();
      });
    }
  }

  Future<void> _toggleOrderCompletion(Order order, int index) async {
    final dbHelper = DatabaseHelper();
    final updatedOrder = Order(
      id: order.id,
      customerName: order.customerName,
      customerContact: order.customerContact,
      projectType: order.projectType,
      totalAmount: order.totalAmount,
      orderDate: order.orderDate,
      dueDate: order.dueDate,
      advancePaid: order.advancePaid,
      balanceAmount: order.balanceAmount,
      paymentMode: order.paymentMode,
      receivedBy: order.receivedBy,
      writerAssigned: order.writerAssigned,
      pages: order.pages,
      isCompleted: !(order.isCompleted ?? false),
      details: order.details,
    );

    await dbHelper.updateOrder(updatedOrder);
    setState(() {
      orders[index] = updatedOrder;
      _calculateStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Customer Details", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Customer Info Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade800, Colors.teal.shade600],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(20, 10, 20, 25),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.customerName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(Icons.phone, size: 16, color: Colors.white.withOpacity(0.8)),
                              SizedBox(width: 6),
                              Text(
                                widget.customerContact,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard(
                      title: 'Total Spent',
                      value: '₹${totalSpent.toStringAsFixed(0)}',
                      icon: Icons.currency_rupee,
                    ),
                    _buildStatCard(
                      title: 'Orders',
                      value: totalOrders.toString(),
                      icon: Icons.shopping_bag_outlined,
                    ),
                    _buildStatCard(
                      title: 'Completed',
                      value: completedOrders.toString(),
                      icon: Icons.check_circle_outline,
                      color: Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Orders List Header
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  "Order History",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: orders.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildOrderCard(order, index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewOrder,
        backgroundColor: Colors.teal.shade600,
        icon: Icon(Icons.add_shopping_cart),
        label: Text("New Order"),
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, Color? color}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color ?? Colors.white, size: 22),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order, int index) {
    final isCompleted = order.isCompleted ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Show order details in a bottom sheet
            _showOrderDetails(order);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isCompleted ? Colors.green.shade50 : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isCompleted ? Icons.check_circle_outline : Icons.pending_actions,
                        color: isCompleted ? Colors.green : Colors.orange,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.projectType,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Ordered on ${_formatDate(order.orderDate)}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "₹${order.totalAmount.toStringAsFixed(0)}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                  ],
                ),
                if (order.details != null && order.details!.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Text(
                    order.details!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 12),
                Divider(),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Only show "Mark as Completed" button if not completed
                    if (!isCompleted)
                      ElevatedButton.icon(
                        onPressed: () => _toggleOrderCompletion(order, index),
                        icon: Icon(
                          Icons.check,
                          size: 18,
                        ),
                        label: Text("Mark as Completed"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade100,
                          foregroundColor: Colors.green.shade800,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    // For completed orders, show a different button
                    if (isCompleted)
                      ElevatedButton.icon(
                        onPressed: () {
                          // Show order details
                          _showOrderDetails(order);
                        },
                        icon: Icon(
                          Icons.receipt_long,
                          size: 18,
                        ),
                        label: Text("Order Details"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade100,
                          foregroundColor: Colors.teal.shade800,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "No orders found",
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Add your first order using the button below",
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Order Details",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close),
                        color: Colors.teal.shade800,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: (order.isCompleted ?? false) ? Colors.green.shade100 : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          (order.isCompleted ?? false) ? "Completed" : "In Progress",
                          style: TextStyle(
                            color: (order.isCompleted ?? false) ? Colors.green.shade800 : Colors.orange.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order information section
                    _buildSectionHeader("Project Information"),
                    _buildDetailItem("Project Type", order.projectType),
                    _buildDetailItem("Writer Assigned", order.writerAssigned),
                    _buildDetailItem("Pages", order.pages.toString()),

                    SizedBox(height: 24),
                    _buildSectionHeader("Order Timeline"),
                    _buildDetailItem("Order Placed", _formatDate(order.orderDate)),
                    _buildDetailItem("Due Date", _formatDate(order.dueDate)),

                    SizedBox(height: 24),
                    _buildSectionHeader("Payment Details"),
                    _buildDetailItem("Total Amount", "₹${order.totalAmount.toStringAsFixed(2)}"),
                    _buildDetailItem("Advance Paid", "₹${order.advancePaid.toStringAsFixed(2)}"),
                    _buildDetailItem("Balance Amount", "₹${order.balanceAmount.toStringAsFixed(2)}"),
                    _buildDetailItem("Payment Method", order.paymentMode),
                    _buildDetailItem("Received By", order.receivedBy),

                    SizedBox(height: 24),
                    _buildSectionHeader("Additional Information"),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order.details ?? "No additional details available",
                        style: TextStyle(
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action button
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade800,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text("Close", style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
          Divider(color: Colors.teal.shade100, thickness: 2),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}