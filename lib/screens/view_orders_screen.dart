import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/order_model.dart';
import 'add_order_screen.dart';
import 'order_details_screen.dart'; // New import for the detailed view
import 'package:intl/intl.dart';

class ViewOrdersScreen extends StatefulWidget {
  @override
  _ViewOrdersScreenState createState() => _ViewOrdersScreenState();
}

class _ViewOrdersScreenState extends State<ViewOrdersScreen> {
  List<Order> allOrders = [];
  List<Order> filteredOrders = [];
  String searchQuery = '';
  String selectedDateFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final dbHelper = DatabaseHelper();
    final fetchedOrders = await dbHelper.getOrders();
    setState(() {
      allOrders = fetchedOrders;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Order> result = List.from(allOrders);

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      result = result.where((order) =>
      order.customerName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          order.customerContact.toLowerCase().contains(searchQuery.toLowerCase()) ||
          order.projectType.toLowerCase().contains(searchQuery.toLowerCase()) ||
          order.writerAssigned.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }

    // Apply date filter
    if (selectedDateFilter != 'All' && selectedDateFilter != 'Custom') {
      DateTime now = DateTime.now();
      DateTime startFilterDate;

      switch (selectedDateFilter) {
        case 'Last 7 Days':
          startFilterDate = now.subtract(Duration(days: 7));
          break;
        case 'This Month':
          startFilterDate = DateTime(now.year, now.month, 1);
          break;
        case 'Last Month':
          final lastMonth = now.month > 1 ? now.month - 1 : 12;
          final year = now.month > 1 ? now.year : now.year - 1;
          startFilterDate = DateTime(year, lastMonth, 1);
          final daysInMonth = DateUtils.getDaysInMonth(year, lastMonth);
          endDate = DateTime(year, lastMonth, daysInMonth);
          break;
        case 'Last 3 Months':
          startFilterDate = DateTime(now.year, now.month - 2, 1);
          break;
        case 'Last Year':
          startFilterDate = DateTime(now.year - 1, now.month, now.day);
          break;
        default:
          startFilterDate = DateTime(1900);
      }

      if (selectedDateFilter != 'Last Month') {
        endDate = now;
      }

      result = result.where((order) {
        try {
          final orderDate = DateTime.parse(order.orderDate);
          return orderDate.isAfter(startFilterDate) &&
              orderDate.isBefore(endDate!.add(Duration(days: 1)));
        } catch (e) {
          return false;
        }
      }).toList();
    } else if (selectedDateFilter == 'Custom' && startDate != null && endDate != null) {
      result = result.where((order) {
        try {
          final orderDate = DateTime.parse(order.orderDate);
          return orderDate.isAfter(startDate!) &&
              orderDate.isBefore(endDate!.add(Duration(days: 1)));
        } catch (e) {
          return false;
        }
      }).toList();
    }

    setState(() {
      filteredOrders = result;
    });
  }

  Future<void> _deleteOrder(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete this order?"),
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
      final dbHelper = DatabaseHelper();
      await dbHelper.deleteOrder(id);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Order deleted successfully"))
      );
      _fetchOrders();
    }
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(order: order),
      ),
    ).then((_) => _fetchOrders());
  }

  Future<void> _toggleOrderStatus(Order order, bool isCompleted) async {
    // This assumes you've added an 'isCompleted' field to your Order model
    // You'll need to update your database helper and model accordingly
    final dbHelper = DatabaseHelper();
    final updatedOrder = Order(
      id: order.id,
      orderDate: order.orderDate,
      dueDate: order.dueDate,
      customerName: order.customerName,
      customerContact: order.customerContact,
      projectType: order.projectType,
      totalAmount: order.totalAmount,
      advancePaid: order.advancePaid,
      balanceAmount: order.balanceAmount,
      paymentMode: order.paymentMode,
      receivedBy: order.receivedBy,
      writerAssigned: order.writerAssigned,
      pages: order.pages,
      isCompleted: isCompleted,
    );

    await dbHelper.updateOrder(updatedOrder);
    _fetchOrders();
  }

  Future<void> _showDateFilterDialog() async {
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Filter Orders by Date"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...['All', 'Last 7 Days', 'This Month', 'Last Month', 'Last 3 Months', 'Last Year', 'Custom']
                    .map((filter) => RadioListTile<String>(
                  title: Text(filter),
                  value: filter,
                  groupValue: selectedDateFilter,
                  onChanged: (value) {
                    setState(() {
                      selectedDateFilter = value!;
                    });
                  },
                ))
                    .toList(),
                if (selectedDateFilter == 'Custom')
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      children: [
                        OutlinedButton.icon(
                          icon: Icon(Icons.calendar_today),
                          label: Text(startDate == null
                              ? "Select Start Date"
                              : "Start: ${dateFormat.format(startDate!)}"),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                startDate = picked;
                              });
                            }
                          },
                        ),
                        SizedBox(height: 8),
                        OutlinedButton.icon(
                          icon: Icon(Icons.calendar_today),
                          label: Text(endDate == null
                              ? "Select End Date"
                              : "End: ${dateFormat.format(endDate!)}"),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: endDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                endDate = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("CANCEL"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _applyFilters();
                },
                child: Text("APPLY"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Orders"),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddOrderScreen()),
              ).then((_) => _fetchOrders());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            color: Colors.blue.shade800,
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search by name, contact, or writer...",
                    hintStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.search, color: Colors.white70),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear, color: Colors.white70),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          searchQuery = '';
                          _applyFilters();
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                      _applyFilters();
                    });
                  },
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    OutlinedButton.icon(
                      icon: Icon(Icons.filter_list, color: Colors.white),
                      label: Text(
                        "Filter: $selectedDateFilter",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: _showDateFilterDialog,
                    ),
                    Spacer(),
                    Text(
                      "${filteredOrders.length} orders",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Order List
          Expanded(
            child: filteredOrders.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_late, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No orders found",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  if (searchQuery.isNotEmpty || selectedDateFilter != 'All')
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          searchQuery = '';
                          selectedDateFilter = 'All';
                          _applyFilters();
                        });
                      },
                      child: Text("Clear Filters"),
                    ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                final bool isCompleted = order.isCompleted ?? false;

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isCompleted ? Colors.green.shade200 : Colors.orange.shade200,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.customerName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.assignment, size: 16, color: Colors.grey),
                                      SizedBox(width: 4),
                                      Text(
                                        order.projectType,
                                        style: TextStyle(color: Colors.grey.shade700),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                      SizedBox(width: 4),
                                      Text(
                                        "Due: ${order.dueDate.isEmpty ? 'Not set' : order.dueDate}",
                                        style: TextStyle(
                                          color: _isOverdue(order.dueDate) && !isCompleted
                                              ? Colors.red
                                              : Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isCompleted ? Colors.green.shade100 : Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isCompleted ? "Completed" : "Pending",
                                    style: TextStyle(
                                      color: isCompleted ? Colors.green.shade800 : Colors.orange.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "₹${order.totalAmount.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (order.balanceAmount > 0)
                                  Text(
                                    "Due: ₹${order.balanceAmount.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        Divider(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: Icon(Icons.visibility, size: 18),
                                label: Text("VIEW"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.blue.shade800,
                                  side: BorderSide(color: Colors.blue.shade200),
                                ),
                                onPressed: () => _viewOrderDetails(order),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: Icon(
                                    isCompleted ? Icons.refresh : Icons.check_circle,
                                    size: 18
                                ),
                                label: Text(isCompleted ? "REOPEN" : "COMPLETE"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isCompleted ? Colors.orange.shade800 : Colors.green.shade800,
                                  side: BorderSide(
                                    color: isCompleted ? Colors.orange.shade200 : Colors.green.shade200,
                                  ),
                                ),
                                onPressed: () => _toggleOrderStatus(order, !isCompleted),
                              ),
                            ),
                            PopupMenuButton(
                              icon: Icon(Icons.more_vert),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 1,
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, color: Colors.blue),
                                      SizedBox(width: 8),
                                      Text("Edit Order"),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 2,
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text("Delete Order"),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 1) {
                                  _editOrder(order);
                                } else if (value == 2) {
                                  _deleteOrder(order.id!);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddOrderScreen()),
          ).then((_) => _fetchOrders());
        },
        icon: Icon(Icons.add),
        label: Text("NEW ORDER"),
        backgroundColor: Colors.blue.shade800,
      ),
    );
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
}