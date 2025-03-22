import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/order_model.dart';
import 'add_order_screen.dart';
import 'order_details_screen.dart';
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
  final DateFormat displayDateFormat = DateFormat('dd/MM/yyyy');
  bool isLoading = true; // Add this line

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      isLoading = true; // Show the progress bar
    });

    try {
      final dbHelper = DatabaseHelper();
      final fetchedOrders = await dbHelper.getOrders();

      // Sort orders by newest first (most recently added first)
      fetchedOrders.sort((a, b) {
        // Assuming higher ID means more recently added
        return (b.id ?? 0).compareTo(a.id ?? 0);
      });

      setState(() {
        allOrders = fetchedOrders;
        _applyFilters();
        isLoading = false; // Hide the progress bar
      });

      // Debugging print statements
      print("Fetched orders: ${fetchedOrders.length}");
      for (var order in fetchedOrders) {
        print("Order ID: ${order.id}, Customer: ${order.customerName}");
      }
    } catch (e) {
      print("Error fetching orders: $e");
      // Optionally, show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching orders: $e"))
      );
      setState(() {
        isLoading = false; // Hide the progress bar on error
      });
    }
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
      balanceAmount: isCompleted ? 0.0 : order.balanceAmount, // Set balance to 0 when completed
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
            content: SingleChildScrollView(
              child: Column(
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

  String _formatDueDate(String dueDateStr) {
    if (dueDateStr.isEmpty) return 'Not set';
    try {
      final dueDate = DateTime.parse(dueDateStr);
      return displayDateFormat.format(dueDate);
    } catch (e) {
      return dueDateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Orders", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo.shade800,
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
          // Search and Filter Bar with improved design
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade800, Colors.indigo.shade600],
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
            padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
            margin: EdgeInsets.only(bottom: 10),
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
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                      _applyFilters();
                    });
                  },
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    OutlinedButton.icon(
                      icon: Icon(Icons.filter_list, color: Colors.white),
                      label: Text(
                        "Filter: $selectedDateFilter",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white70),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      onPressed: _showDateFilterDialog,
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${filteredOrders.length} orders",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Show progress bar while loading
          if (isLoading)
            Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else
          // Improved Empty State
            Expanded(
              child: filteredOrders.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.assignment_late, size: 64, color: Colors.grey.shade500),
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
                      "Try changing your filters or add a new order",
                      style: TextStyle(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    if (searchQuery.isNotEmpty || selectedDateFilter != 'All')
                      ElevatedButton.icon(
                        icon: Icon(Icons.restart_alt),
                        label: Text("Clear Filters"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade600,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            searchQuery = '';
                            selectedDateFilter = 'All';
                            _applyFilters();
                          });
                        },
                      ),
                  ],
                ),
              )
              // Redesigned Order List
                  : ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = filteredOrders[index];
                  final bool isCompleted = order.isCompleted ?? false;
                  final bool isOverdue = _isOverdue(order.dueDate) && !isCompleted;

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
                        onTap: () => _viewOrderDetails(order),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: isCompleted ? Colors.green.shade50 : isOverdue ? Colors.red.shade50 : Colors.indigo.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      isCompleted ? Icons.check_circle : isOverdue ? Icons.error : Icons.assignment,
                                      color: isCompleted ? Colors.green : isOverdue ? Colors.red : Colors.indigo,
                                      size: 28,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order.customerName,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black.withOpacity(0.8),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "${order.pages} pages",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isCompleted ? Colors.green.shade50 : isOverdue ? Colors.red.shade50 : Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isCompleted ? Colors.green.shade200 : isOverdue ? Colors.red.shade200 : Colors.orange.shade200,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      isCompleted ? "Completed" : isOverdue ? "Overdue" : "In Progress",
                                      style: TextStyle(
                                        color: isCompleted ? Colors.green.shade800 : isOverdue ? Colors.red.shade800 : Colors.orange.shade800,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 14,
                                          color: isOverdue ? Colors.red : Colors.grey,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          "Due: ${order.dueDate.isEmpty ? 'Not set' : _formatDueDate(order.dueDate)}",
                                          style: TextStyle(
                                            color: isOverdue ? Colors.red : Colors.grey.shade700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(Icons.person_outline, size: 14, color: Colors.grey),
                                        SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            order.writerAssigned.isEmpty ? "No writer" : order.writerAssigned,
                                            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Divider(),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Total: ₹${order.totalAmount.toStringAsFixed(0)}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.indigo.shade800,
                                        ),
                                      ),
                                      if (order.balanceAmount > 0 && !isCompleted)
                                        Text(
                                          "Due: ₹${order.balanceAmount.toStringAsFixed(0)}",
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      if (isCompleted)
                                        Text(
                                          "Fully Paid",
                                          style: TextStyle(
                                            color: Colors.green.shade700,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      // Status toggle button with improved design
                                      if (!isCompleted)
                                        ElevatedButton(
                                          onPressed: () => _toggleOrderStatus(order, true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green.shade100,
                                            foregroundColor: Colors.green.shade800,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          ),
                                          child: Text(
                                            "Mark Complete",
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      if (isCompleted)
                                        OutlinedButton(
                                          onPressed: () => _toggleOrderStatus(order, false),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.indigo.shade800,
                                            side: BorderSide(color: Colors.indigo.shade200),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          ),
                                          child: Text(
                                            "Reopen",
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      SizedBox(width: 8),
                                      // Actions menu
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: PopupMenuButton(
                                          icon: Icon(Icons.more_vert, color: Colors.grey.shade700),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              value: 1,
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit, color: Colors.indigo),
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
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
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