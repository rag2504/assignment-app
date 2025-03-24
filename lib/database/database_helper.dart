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
    try {
      final response = await http.get(Uri.parse(apiUrl));
      print('Fetching orders: ${response.statusCode}, ${response.body}');
      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        return body.map((dynamic item) => Order.fromMap(item)).toList();
      } else {
        print('Failed to load orders: ${response.statusCode}');
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      print('Error fetching orders: $e');
      throw Exception('Error fetching orders: $e');
    }
  }

  Future<int> insertOrder(Order order) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(order.toMap()),
      );
      print('Inserting order: ${response.statusCode}, ${response.body}');
      if (response.statusCode == 201) {
        return Order.fromMap(json.decode(response.body)).id!;
      } else {
        print('Failed to create order: ${response.statusCode}');
        throw Exception('Failed to create order');
      }
    } catch (e) {
      print('Error inserting order: $e');
      throw Exception('Error inserting order: $e');
    }
  }

  Future<int> updateOrder(Order order) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/${order.id}'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(order.toMap()),
      );
      print('Updating order: ${response.statusCode}, ${response.body}');
      if (response.statusCode == 200) {
        return order.id!;
      } else {
        print('Failed to update order: ${response.statusCode}');
        throw Exception('Failed to update order');
      }
    } catch (e) {
      print('Error updating order: $e');
      throw Exception('Error updating order: $e');
    }
  }

  Future<void> markOrderAsCompleted(int id, bool isCompleted) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({'isCompleted': isCompleted}),
      );
      print('Marking order as completed: ${response.statusCode}, ${response.body}');
      if (response.statusCode != 200) {
        print('Failed to mark order as completed: ${response.statusCode}');
        throw Exception('Failed to mark order as completed');
      }
    } catch (e) {
      print('Error marking order as completed: $e');
      throw Exception('Error marking order as completed: $e');
    }
  }

  Future<Order?> getOrderById(int id) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/$id'));
      print('Fetching order by ID: ${response.statusCode}, ${response.body}');
      if (response.statusCode == 200) {
        return Order.fromMap(json.decode(response.body));
      } else {
        print('Failed to fetch order by ID: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching order by ID: $e');
      throw Exception('Error fetching order by ID: $e');
    }
  }

  Future<int> deleteOrder(int id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));
      print('Deleting order: ${response.statusCode}, ${response.body}');
      if (response.statusCode == 200) {
        return id;
      } else {
        print('Failed to delete order: ${response.statusCode}');
        throw Exception('Failed to delete order');
      }
    } catch (e) {
      print('Error deleting order: $e');
      throw Exception('Error deleting order: $e');
    }
  }
}