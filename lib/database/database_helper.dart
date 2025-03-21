import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/customer_model.dart';
import '../models/order_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'assignment.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        orderDate TEXT,
        dueDate TEXT,
        projectType TEXT,
        totalAmount REAL,
        advancePaid REAL,
        balanceAmount REAL,
        paymentMode TEXT,
        receivedBy TEXT,
        writerAssigned TEXT,
        customerContact TEXT,
        writerContact TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  customerName TEXT,
  orderDate TEXT,
  dueDate TEXT,
  customerContact TEXT,
  projectType TEXT,
  totalAmount REAL,
  advancePaid REAL,
  balanceAmount REAL,
  paymentMode TEXT,
  receivedBy TEXT,
  writerAssigned TEXT
)

    ''');
  }

  Future<List<Customer>> getCustomers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('customers');
    return List.generate(maps.length, (i) {
      return Customer.fromMap(maps[i]);
    });
  }

  Future<int> insertCustomer(Customer customer) async {
    final db = await database;
    return await db.insert('customers', customer.toMap());
  }

  Future<List<Order>> getOrders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('orders');
    return List.generate(maps.length, (i) {
      return Order.fromMap(maps[i]);
    });
  }

  Future<int> insertOrder(Order order) async {
    final db = await database;
    return await db.insert('orders', order.toMap());
  }

  Future<int> deleteOrder(int id) async {
    final db = await database;
    return await db.delete('orders', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateOrder(Order order) async {
    final db = await database;
    return await db.update('orders', order.toMap(), where: 'id = ?', whereArgs: [order.id]);
  }
}