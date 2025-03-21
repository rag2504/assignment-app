import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/customer_model.dart';

class CustomerFormScreen extends StatefulWidget {
  @override
  _CustomerFormScreenState createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _orderDateController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _projectTypeController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _advancePaidController = TextEditingController();
  final _paymentModeController = TextEditingController();
  final _receivedByController = TextEditingController();
  final _writerAssignedController = TextEditingController();
  final _customerContactController = TextEditingController();
  final _writerContactController = TextEditingController();

  Future<void> _saveCustomer() async {
    if (_formKey.currentState!.validate()) {
      final customer = Customer(
        name: _nameController.text,
        orderDate: _orderDateController.text,
        dueDate: _dueDateController.text,
        projectType: _projectTypeController.text,
        totalAmount: double.parse(_totalAmountController.text),
        advancePaid: double.parse(_advancePaidController.text),
        balanceAmount: double.parse(_totalAmountController.text) - double.parse(_advancePaidController.text),
        paymentMode: _paymentModeController.text,
        receivedBy: _receivedByController.text,
        writerAssigned: _writerAssignedController.text,
        customerContact: _customerContactController.text,
        writerContact: _writerContactController.text,
      );
      await DatabaseHelper().insertCustomer(customer);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Customer")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(controller: _nameController, decoration: InputDecoration(labelText: "Customer Name"), validator: (value) => value!.isEmpty ? "Required" : null),
                TextFormField(controller: _orderDateController, decoration: InputDecoration(labelText: "Order Date"), validator: (value) => value!.isEmpty ? "Required" : null),
                TextFormField(controller: _dueDateController, decoration: InputDecoration(labelText: "Due Date"), validator: (value) => value!.isEmpty ? "Required" : null),
                TextFormField(controller: _projectTypeController, decoration: InputDecoration(labelText: "Project Type"), validator: (value) => value!.isEmpty ? "Required" : null),
                TextFormField(controller: _totalAmountController, decoration: InputDecoration(labelText: "Total Amount"), keyboardType: TextInputType.number, validator: (value) => value!.isEmpty ? "Required" : null),
                TextFormField(controller: _advancePaidController, decoration: InputDecoration(labelText: "Advance Paid"), keyboardType: TextInputType.number, validator: (value) => value!.isEmpty ? "Required" : null),
                TextFormField(controller: _paymentModeController, decoration: InputDecoration(labelText: "Payment Mode (Cash/Online)"), validator: (value) => value!.isEmpty ? "Required" : null),
                TextFormField(controller: _receivedByController, decoration: InputDecoration(labelText: "Received By"), validator: (value) => value!.isEmpty ? "Required" : null),
                TextFormField(controller: _writerAssignedController, decoration: InputDecoration(labelText: "Writer Assigned"), validator: (value) => value!.isEmpty ? "Required" : null),
                TextFormField(controller: _customerContactController, decoration: InputDecoration(labelText: "Customer Contact"), keyboardType: TextInputType.phone, validator: (value) => value!.isEmpty ? "Required" : null),
                TextFormField(controller: _writerContactController, decoration: InputDecoration(labelText: "Writer Contact"), keyboardType: TextInputType.phone, validator: (value) => value!.isEmpty ? "Required" : null),
                SizedBox(height: 20),
                ElevatedButton(onPressed: _saveCustomer, child: Text("Save")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
