import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static const String apiUrl = "https://66d56529f5859a704265e791.mockapi.io/orders";

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<List<Order>> getOrders() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Order.fromMap(item)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<int> insertOrder(Order order) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(order.toMap()),
    );

    if (response.statusCode == 201) {
      return Order.fromMap(json.decode(response.body)).id!;
    } else {
      throw Exception('Failed to create order');
    }
  }

  Future<int> updateOrder(Order order) async {
    final response = await http.put(
      Uri.parse('$apiUrl/${order.id}'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(order.toMap()),
    );

    if (response.statusCode == 200) {
      return order.id!;
    } else {
      throw Exception('Failed to update order');
    }
  }

  Future<void> markOrderAsCompleted(int id, bool isCompleted) async {
    final response = await http.put(
      Uri.parse('$apiUrl/$id'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'isCompleted': isCompleted}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark order as completed');
    }
  }

  Future<Order?> getOrderById(int id) async {
    final response = await http.get(Uri.parse('$apiUrl/$id'));

    if (response.statusCode == 200) {
      return Order.fromMap(json.decode(response.body));
    } else {
      return null;
    }
  }

  Future<int> deleteOrder(int id) async {
    final response = await http.delete(Uri.parse('$apiUrl/$id'));

    if (response.statusCode == 200) {
      return id;
    } else {
      throw Exception('Failed to delete order');
    }
  }
}