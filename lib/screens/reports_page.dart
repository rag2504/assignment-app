import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database/database_helper.dart';
import 'package:intl/intl.dart';

class ReportsPage extends StatefulWidget {
  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final TextEditingController _pinController = TextEditingController();
  bool _isAuthenticated = false;
  final String _correctPin = '2523'; // Fixed PIN

  int _totalOrders = 0;
  double _totalAmountTillDate = 0;
  double _totalAmountThisMonth = 0;
  int _totalCustomers = 0;
  int _uniqueCustomers = 0;

  DateTime _selectedStartDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _selectedEndDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (_isAuthenticated) {
      _fetchReportsData();
    }
  }

  Future<void> _fetchReportsData() async {
    final dbHelper = DatabaseHelper();
    final orders = await dbHelper.getOrders();

    setState(() {
      _totalOrders = orders.length;
      _totalAmountTillDate = orders.fold(0, (sum, order) => sum + order.totalAmount);
      _totalAmountThisMonth = orders
          .where((order) {
        final orderDate = DateTime.parse(order.orderDate);
        final now = DateTime.now();
        return orderDate.year == now.year && orderDate.month == now.month;
      })
          .fold(0, (sum, order) => sum + order.totalAmount);
      _totalCustomers = orders.map((order) => order.customerName).toSet().length;
      _uniqueCustomers = orders.map((order) => order.customerContact).toSet().length;
    });
  }

  void _authenticate() {
    if (_pinController.text == _correctPin) {
      setState(() {
        _isAuthenticated = true;
        _fetchReportsData();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Incorrect PIN")));
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      initialDateRange: DateTimeRange(start: _selectedStartDate, end: _selectedEndDate),
    );
    if (picked != null && picked != DateTimeRange(start: _selectedStartDate, end: _selectedEndDate)) {
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
        _fetchReportsData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reports"),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: _isAuthenticated ? _buildReportsPage() : _buildPinEntryPage(),
    );
  }

  Widget _buildPinEntryPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _pinController,
            decoration: InputDecoration(
              labelText: 'Enter PIN',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true,
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _authenticate,
            child: Text('Submit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateRangePicker(),
          SizedBox(height: 20),
          _buildReportCard("Total Amount Till Date", _totalAmountTillDate.toStringAsFixed(2)),
          SizedBox(height: 10),
          _buildReportCard("Total Amount This Month", _totalAmountThisMonth.toStringAsFixed(2)),
          SizedBox(height: 10),
          _buildReportCard("Total Orders", _totalOrders.toString()),
          SizedBox(height: 10),
          _buildReportCard("Total Customers", _totalCustomers.toString()),
          SizedBox(height: 10),
          _buildReportCard("Unique Customers", _uniqueCustomers.toString()),
          SizedBox(height: 20),
          _buildBarChart(),
        ],
      ),
    );
  }

  Widget _buildDateRangePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Select Date Range:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ElevatedButton.icon(
          onPressed: () => _selectDateRange(context),
          icon: Icon(Icons.calendar_today),
          label: Text("${DateFormat('yyyy-MM-dd').format(_selectedStartDate)} - ${DateFormat('yyyy-MM-dd').format(_selectedEndDate)}"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildReportCard(String title, String value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Monthly Revenue",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            SizedBox(height: 20),
            Container(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 10000,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTextStyles: (context, value) => const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                      margin: 16,
                      getTitles: (double value) {
                        switch (value.toInt()) {
                          case 0:
                            return 'Jan';
                          case 1:
                            return 'Feb';
                          case 2:
                            return 'Mar';
                          case 3:
                            return 'Apr';
                          case 4:
                            return 'May';
                          case 5:
                            return 'Jun';
                          case 6:
                            return 'Jul';
                          case 7:
                            return 'Aug';
                          case 8:
                            return 'Sep';
                          case 9:
                            return 'Oct';
                          case 10:
                            return 'Nov';
                          case 11:
                            return 'Dec';
                          default:
                            return '';
                        }
                      },
                    ),
                    leftTitles: SideTitles(showTitles: false),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(y: 8000, colors: [Colors.lightBlueAccent, Colors.greenAccent])]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(y: 6000, colors: [Colors.lightBlueAccent, Colors.greenAccent])]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(y: 9000, colors: [Colors.lightBlueAccent, Colors.greenAccent])]),
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(y: 7000, colors: [Colors.lightBlueAccent, Colors.greenAccent])]),
                    BarChartGroupData(x: 4, barRods: [BarChartRodData(y: 5000, colors: [Colors.lightBlueAccent, Colors.greenAccent])]),
                    BarChartGroupData(x: 5, barRods: [BarChartRodData(y: 8000, colors: [Colors.lightBlueAccent, Colors.greenAccent])]),
                    BarChartGroupData(x: 6, barRods: [BarChartRodData(y: 3000, colors: [Colors.lightBlueAccent, Colors.greenAccent])]),
                    BarChartGroupData(x: 7, barRods: [BarChartRodData(y: 4000, colors: [Colors.lightBlueAccent, Colors.greenAccent])]),
                    BarChartGroupData(x: 8, barRods: [BarChartRodData(y: 7000, colors: [Colors.lightBlueAccent, Colors.greenAccent])]),
                    BarChartGroupData(x: 9, barRods: [BarChartRodData(y: 6000, colors: [Colors.lightBlueAccent, Colors.greenAccent])]),
                    BarChartGroupData(x: 10, barRods: [BarChartRodData(y: 5000, colors: [Colors.lightBlueAccent, Colors.greenAccent])]),
                    BarChartGroupData(x: 11, barRods: [BarChartRodData(y: 9000, colors: [Colors.lightBlueAccent, Colors.greenAccent])]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}