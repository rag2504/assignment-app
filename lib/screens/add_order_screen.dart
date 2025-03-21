import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/order_model.dart';

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
  final _projectTypeController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _advancePaidController = TextEditingController();
  final _balanceAmountController = TextEditingController();
  final _paymentModeController = TextEditingController();
  final _receivedByController = TextEditingController();
  final _writerAssignedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.order != null) {
      _orderDateController.text = widget.order!.orderDate;
      _dueDateController.text = widget.order!.dueDate;
      _customerNameController.text = widget.order!.customerName;
      _customerContactController.text = widget.order!.customerContact;
      _projectTypeController.text = widget.order!.projectType;
      _totalAmountController.text = widget.order!.totalAmount.toString();
      _advancePaidController.text = widget.order!.advancePaid.toString();
      _balanceAmountController.text = widget.order!.balanceAmount.toString();
      _paymentModeController.text = widget.order!.paymentMode;
      _receivedByController.text = widget.order!.receivedBy;
      _writerAssignedController.text = widget.order!.writerAssigned;
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.toLocal().toString().split(' ')[0];
      });
    }
  }

  Future<void> _saveOrder() async {
    if (_formKey.currentState!.validate()) {
      final order = Order(
        id: widget.order?.id,
        orderDate: _orderDateController.text,
        dueDate: _dueDateController.text,
        customerName: _customerNameController.text,
        customerContact: _customerContactController.text,
        projectType: _projectTypeController.text,
        totalAmount: double.parse(_totalAmountController.text),
        advancePaid: double.parse(_advancePaidController.text),
        balanceAmount: double.parse(_totalAmountController.text) - double.parse(_advancePaidController.text),
        paymentMode: _paymentModeController.text,
        receivedBy: _receivedByController.text,
        writerAssigned: _writerAssignedController.text,
      );

      print("Saving order: ${order.toMap()}");

      int result;
      if (widget.order == null) {
        result = await DatabaseHelper().insertOrder(order);
        print("Insert result: $result");
      } else {
        result = await DatabaseHelper().updateOrder(order);
        print("Update result: $result");
      }

      if (result > 0) {
        Navigator.pop(context, true);
      } else {
        print("Failed to save order");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.order == null ? "Add Order" : "Edit Order")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _orderDateController,
                  decoration: InputDecoration(
                    labelText: "Order Date",
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(_orderDateController),
                    ),
                  ),
                  readOnly: true,
                ),
                TextFormField(
                  controller: _dueDateController,
                  decoration: InputDecoration(
                    labelText: "Due Date",
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(_dueDateController),
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? "Required" : null,
                  readOnly: true,
                ),
                TextFormField(
                  controller: _customerNameController,
                  decoration: InputDecoration(labelText: "Customer Name"),
                  validator: (value) => value!.isEmpty ? "Required" : null,
                ),
                TextFormField(
                  controller: _customerContactController,
                  decoration: InputDecoration(labelText: "Customer Contact"),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value!.isEmpty ? "Required" : null,
                ),
                TextFormField(
                  controller: _projectTypeController,
                  decoration: InputDecoration(labelText: "Order Type"),
                  validator: (value) => value!.isEmpty ? "Required" : null,
                ),
                TextFormField(
                  controller: _totalAmountController,
                  decoration: InputDecoration(labelText: "Total Amount"),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? "Required" : null,
                  onChanged: (value) {
                    if (_advancePaidController.text.isNotEmpty) {
                      _balanceAmountController.text = (double.parse(value) - double.parse(_advancePaidController.text)).toString();
                    }
                  },
                ),
                TextFormField(
                  controller: _advancePaidController,
                  decoration: InputDecoration(labelText: "Advance Paid"),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? "Required" : null,
                  onChanged: (value) {
                    if (_totalAmountController.text.isNotEmpty) {
                      _balanceAmountController.text = (double.parse(_totalAmountController.text) - double.parse(value)).toString();
                    }
                  },
                ),
                TextFormField(
                  controller: _balanceAmountController,
                  decoration: InputDecoration(labelText: "Remaining Amount"),
                  readOnly: true,
                ),
                TextFormField(
                  controller: _paymentModeController,
                  decoration: InputDecoration(labelText: "Payment Mode (Cash/Online)"),
                  validator: (value) => value!.isEmpty ? "Required" : null,
                ),
                TextFormField(
                  controller: _receivedByController,
                  decoration: InputDecoration(labelText: "Received By"),
                  validator: (value) => value!.isEmpty ? "Required" : null,
                ),
                TextFormField(
                  controller: _writerAssignedController,
                  decoration: InputDecoration(labelText: "Order Given To (Writer Name)"),
                  validator: (value) => value!.isEmpty ? "Required" : null,
                ),
                SizedBox(height: 20),
                ElevatedButton(onPressed: _saveOrder, child: Text("Save")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}