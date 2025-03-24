import 'package:flutter/material.dart';
import 'customer_details_screen.dart';
import '../database/database_helper.dart';
import '../models/order_model.dart';
import 'package:intl/intl.dart';

class CustomerStatsScreen extends StatefulWidget {
  @override
  _CustomerStatsScreenState createState() => _CustomerStatsScreenState();
}

class _CustomerStatsScreenState extends State<CustomerStatsScreen> {
  List<CustomerStats> allCustomerStats = [];
  List<CustomerStats> filteredCustomerStats = [];
  String searchQuery = '';
  String selectedSortOption = 'Name A-Z';
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCustomerStats();
  }

  Future<void> _fetchCustomerStats() async {
    setState(() {
      isLoading = true;
    });

    try {
      final dbHelper = DatabaseHelper();
      final orders = await dbHelper.getOrders();
      Map<String, CustomerStats> statsMap = {};

      for (var order in orders) {
        print('Processing order: ${order.toMap()}');  // Log each order

        if (statsMap.containsKey(order.customerName)) {
          statsMap[order.customerName]!.orderCount++;
          statsMap[order.customerName]!.orders.add(order);
          statsMap[order.customerName]!.totalAmount += order.totalAmount;

          // Check for the most recent order
          DateTime? orderDate = _parseDate(order.orderDate);
          DateTime? latestDate = _parseDate(statsMap[order.customerName]!.lastOrderDate);
          if (orderDate != null && latestDate != null && orderDate.isAfter(latestDate)) {
            statsMap[order.customerName]!.lastOrderDate = order.orderDate;
          }

          // Check if any order is incomplete
          if (!(order.isCompleted ?? true)) {
            statsMap[order.customerName]!.hasActiveOrders = true;
          }
        } else {
          statsMap[order.customerName] = CustomerStats(
            customerName: order.customerName,
            customerContact: order.customerContact,
            orderCount: 1,
            totalAmount: order.totalAmount,
            orders: [order],
            lastOrderDate: order.orderDate,
            hasActiveOrders: !(order.isCompleted ?? true),
          );
        }
      }

      setState(() {
        allCustomerStats = statsMap.values.toList();
        _applySortAndFilter();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching customer stats: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  DateTime? _parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  void _applySortAndFilter() {
    List<CustomerStats> result = List.from(allCustomerStats);

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      result = result.where((customer) =>
      customer.customerName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          customer.customerContact.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }

    // Apply sorting
    switch (selectedSortOption) {
      case 'Name A-Z':
        result.sort((a, b) => a.customerName.compareTo(b.customerName));
        break;
      case 'Name Z-A':
        result.sort((a, b) => b.customerName.compareTo(a.customerName));
        break;
      case 'Most Orders':
        result.sort((a, b) => b.orderCount.compareTo(a.orderCount));
        break;
      case 'Highest Spending':
        result.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
        break;
      case 'Most Recent':
        result.sort((a, b) {
          DateTime? dateA = _parseDate(a.lastOrderDate);
          DateTime? dateB = _parseDate(b.lastOrderDate);
          if (dateA != null && dateB != null) {
            return dateB.compareTo(dateA);
          } else {
            return 0;
          }
        });
        break;
    }

    setState(() {
      filteredCustomerStats = result;
    });
  }

  Future<void> _showSortOptionsDialog() async {
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Sort Customers By"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...['Name A-Z', 'Name Z-A', 'Most Orders', 'Highest Spending', 'Most Recent']
                      .map((option) => RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: selectedSortOption,
                    onChanged: (value) {
                      setState(() {
                        selectedSortOption = value!;
                      });
                    },
                  ))
                      .toList(),
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
                  _applySortAndFilter();
                },
                child: Text("APPLY"),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(String dateStr) {
    DateTime? date = _parseDate(dateStr);
    if (date != null) {
      return DateFormat('dd/MM/yyyy').format(date);
    } else {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Customer Statistics", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and Filter Bar with improved design
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
            padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search by customer name or contact...",
                    hintStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.search, color: Colors.white70),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear, color: Colors.white70),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          searchQuery = '';
                          _applySortAndFilter();
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
                      _applySortAndFilter();
                    });
                  },
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    OutlinedButton.icon(
                      icon: Icon(Icons.sort, color: Colors.white),
                      label: Text(
                        "Sort: $selectedSortOption",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white70),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      onPressed: _showSortOptionsDialog,
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${filteredCustomerStats.length} customers",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Loading state
          if (isLoading)
            Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.teal.shade600,
                ),
              ),
            ),

          // Empty state
          if (!isLoading && filteredCustomerStats.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.people_alt_outlined, size: 64, color: Colors.grey.shade500),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "No customers found",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      searchQuery.isNotEmpty
                          ? "Try changing your search query"
                          : "Add orders to see customers here",
                      style: TextStyle(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    if (searchQuery.isNotEmpty)
                      ElevatedButton.icon(
                        icon: Icon(Icons.restart_alt),
                        label: Text("Clear Search"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade600,
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
                            _applySortAndFilter();
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),

          // Customer Stats List
          if (!isLoading && filteredCustomerStats.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: filteredCustomerStats.length,
                itemBuilder: (context, index) {
                  final customer = filteredCustomerStats[index];
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustomerDetailsScreen(
                                customerName: customer.customerName,
                                customerContact: customer.customerContact,
                                orders: customer.orders,
                              ),
                            ),
                          ).then((_) => _fetchCustomerStats());
                        },
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
                                      color: Colors.teal.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.teal,
                                      size: 28,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          customer.customerName,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black.withOpacity(0.8),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          customer.customerContact,
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
                                      color: customer.hasActiveOrders ? Colors.orange.shade50 : Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: customer.hasActiveOrders ? Colors.orange.shade200 : Colors.green.shade200,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      customer.hasActiveOrders ? "Active" : "Complete",
                                      style: TextStyle(
                                        color: customer.hasActiveOrders ? Colors.orange.shade800 : Colors.green.shade800,
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
                                        Icon(Icons.shopping_bag_outlined, size: 14, color: Colors.grey),
                                        SizedBox(width: 4),
                                        Text(
                                          "${customer.orderCount} ${customer.orderCount == 1 ? 'order' : 'orders'}",
                                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                        SizedBox(width: 4),
                                        Text(
                                          "Last: ${_formatDate(customer.lastOrderDate)}",
                                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
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
                                        "Total Spent",
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 13,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "₹${customer.totalAmount.toStringAsFixed(0)}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.teal.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CustomerDetailsScreen(
                                            customerName: customer.customerName,
                                            customerContact: customer.customerContact,
                                            orders: customer.orders,
                                          ),
                                        ),
                                      ).then((_) => _fetchCustomerStats());
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal.shade100,
                                      foregroundColor: Colors.teal.shade800,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    ),
                                    child: Text(
                                      "View Details",
                                      style: TextStyle(fontWeight: FontWeight.bold),
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
                },
              ),
            ),
        ],
      ),
    );
  }
}

class CustomerStats {
  final String customerName;
  final String customerContact;
  int orderCount;
  double totalAmount;
  List<Order> orders;
  String lastOrderDate;
  bool hasActiveOrders;

  CustomerStats({
    required this.customerName,
    required this.customerContact,
    required this.orderCount,
    required this.totalAmount,
    required this.orders,
    required this.lastOrderDate,
    required this.hasActiveOrders,
  });
}
