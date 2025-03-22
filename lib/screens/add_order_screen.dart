import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/order_model.dart';
import 'package:intl/intl.dart';

class AddOrderScreen extends StatefulWidget {
  final Order? order;

  AddOrderScreen({this.order});

  @override
  _AddOrderScreenState createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orderDateController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _customerContactController = TextEditingController();
  String? _selectedProjectType;
  final _totalAmountController = TextEditingController();
  final _advancePaidController = TextEditingController();
  final _balanceAmountController = TextEditingController();
  final _pagesController = TextEditingController();
  String? _selectedPaymentMode;
  String? _selectedReceivedBy;
  final _writerAssignedController = TextEditingController();

  final _dateFormat = DateFormat('yyyy-MM-dd');
  final _projectTypes = ['Assignment', 'Journal', 'Book Completion', 'PPT/Word', 'Other'];
  final _paymentModes = ['Cash', 'Online'];
  final _receivedByOptions = ['Rag', 'Zeel'];

  @override
  void initState() {
    super.initState();
    if (widget.order != null) {
      _orderDateController.text = widget.order!.orderDate;
      _dueDateController.text = widget.order!.dueDate;
      _customerNameController.text = widget.order!.customerName;
      _customerContactController.text = widget.order!.customerContact;
      _selectedProjectType = widget.order!.projectType;
      _totalAmountController.text = widget.order!.totalAmount.toString();
      _advancePaidController.text = widget.order!.advancePaid.toString();
      _balanceAmountController.text = widget.order!.balanceAmount.toString();
      _pagesController.text = widget.order!.pages.toString();
      _selectedPaymentMode = widget.order!.paymentMode;
      _selectedReceivedBy = widget.order!.receivedBy;
      _writerAssignedController.text = widget.order!.writerAssigned;
    } else {
      // Set today's date as default for new orders
      _orderDateController.text = _dateFormat.format(DateTime.now());
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.text.isNotEmpty
          ? DateTime.parse(controller.text)
          : DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade800,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = _dateFormat.format(picked);
      });
    }
  }

  Future<void> _saveOrder() async {
    try {
      if (_formKey.currentState!.validate()) {
        double totalAmount;
        double advancePaid;
        int pages;

        try {
          totalAmount = double.parse(_totalAmountController.text);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Invalid total amount format"))
          );
          return;
        }

        try {
          advancePaid = double.parse(_advancePaidController.text);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Invalid advance amount format"))
          );
          return;
        }

        try {
          pages = int.parse(_pagesController.text);
        } catch (e) {
          pages = 0; // Default to 0 if empty or invalid
        }

        final order = Order(
          id: widget.order?.id,
          orderDate: _orderDateController.text,
          dueDate: _dueDateController.text,
          customerName: _customerNameController.text,
          customerContact: _customerContactController.text,
          projectType: _selectedProjectType ?? _projectTypes[0],
          totalAmount: totalAmount,
          advancePaid: advancePaid,
          balanceAmount: totalAmount - advancePaid,
          paymentMode: _selectedPaymentMode ?? _paymentModes[0],
          receivedBy: _selectedReceivedBy ?? _receivedByOptions[0],
          writerAssigned: _writerAssignedController.text,
          pages: pages,
          isCompleted: widget.order?.isCompleted ?? false, // Add this line
        );

        int result;
        if (widget.order == null) {
          result = await DatabaseHelper().insertOrder(order);
        } else {
          result = await DatabaseHelper().updateOrder(order);
        }

        if (result > 0) {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to save order"))
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"))
      );
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    Widget? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: Colors.blue.shade800) : null,
          suffixIcon: suffix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
          ),
          filled: true,
          fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    String? value,
    required void Function(String?) onChanged,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: Colors.blue.shade800) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
        icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade800),
        validator: (value) => (value == null || value.isEmpty) ? "Required" : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.order == null ? "Add New Order" : "Edit Order",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
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
                      Divider(height: 24, thickness: 1),

                      // Order Date
                      _buildInputField(
                        controller: _orderDateController,
                        label: "Order Date",
                        icon: Icons.calendar_today,
                        readOnly: true,
                        onTap: () => _selectDate(_orderDateController),
                        validator: (value) => value!.isEmpty ? "Required" : null,
                      ),

                      // Due Date
                      _buildInputField(
                        controller: _dueDateController,
                        label: "Due Date",
                        icon: Icons.event,
                        readOnly: true,
                        onTap: () => _selectDate(_dueDateController),
                      ),

                      SizedBox(height: 16),
                      Text(
                        "Customer Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      Divider(height: 24, thickness: 1),

                      // Customer Name
                      _buildInputField(
                        controller: _customerNameController,
                        label: "Customer Name",
                        icon: Icons.person,
                        validator: (value) => value!.isEmpty ? "Required" : null,
                      ),

                      // Customer Contact
                      _buildInputField(
                        controller: _customerContactController,
                        label: "Customer Contact",
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),

                      SizedBox(height: 16),
                      Text(
                        "Order Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      Divider(height: 24, thickness: 1),

                      // Order Type
                      _buildDropdown(
                        label: "Order Type",
                        items: _projectTypes,
                        value: _selectedProjectType,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedProjectType = newValue;
                          });
                        },
                        icon: Icons.category,
                      ),

                      // Pages
                      _buildInputField(
                        controller: _pagesController,
                        label: "Pages",
                        icon: Icons.file_copy,
                        keyboardType: TextInputType.number,
                      ),

                      SizedBox(height: 16),
                      Text(
                        "Payment Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      Divider(height: 24, thickness: 1),

                      // Total Amount
                      _buildInputField(
                        controller: _totalAmountController,
                        label: "Total Amount",
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? "Required" : null,
                        onChanged: (value) {
                          if (_advancePaidController.text.isNotEmpty && value.isNotEmpty) {
                            try {
                              double total = double.parse(value);
                              double advance = double.parse(_advancePaidController.text);
                              setState(() {
                                _balanceAmountController.text = (total - advance).toStringAsFixed(2);
                              });
                            } catch (_) {}
                          }
                        },
                      ),

                      // Advance Paid
                      _buildInputField(
                        controller: _advancePaidController,
                        label: "Advance Paid",
                        icon: Icons.payments,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          if (_totalAmountController.text.isNotEmpty && value.isNotEmpty) {
                            try {
                              double total = double.parse(_totalAmountController.text);
                              double advance = double.parse(value);
                              setState(() {
                                _balanceAmountController.text = (total - advance).toStringAsFixed(2);
                              });
                            } catch (_) {}
                          }
                        },
                      ),

                      // Balance Amount
                      _buildInputField(
                        controller: _balanceAmountController,
                        label: "Remaining Amount",
                        icon: Icons.account_balance_wallet,
                        readOnly: true,
                      ),

                      // Payment Mode
                      _buildDropdown(
                        label: "Payment Mode",
                        items: _paymentModes,
                        value: _selectedPaymentMode,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedPaymentMode = newValue;
                          });
                        },
                        icon: Icons.payment,
                      ),

                      SizedBox(height: 16),
                      Text(
                        "Assignment Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      Divider(height: 24, thickness: 1),

                      // Received By
                      _buildDropdown(
                        label: "Received By",
                        items: _receivedByOptions,
                        value: _selectedReceivedBy,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedReceivedBy = newValue;
                          });
                        },
                        icon: Icons.person_outline,
                      ),

                      // Writer Assigned
                      _buildInputField(
                        controller: _writerAssignedController,
                        label: "Order Given To (Writer Name)",
                        icon: Icons.assignment_ind,
                      ),

                      SizedBox(height: 32),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _saveOrder,
                          child: Text(
                            "SAVE ORDER",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade800,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}