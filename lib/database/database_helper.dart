import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
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
    print("Initializing database at path: $path");
    return await openDatabase(path, version: 3, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    print("Creating tables...");
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
        writerAssigned TEXT,
        pages INTEGER,
        isCompleted INTEGER DEFAULT 0
      )
    ''');
    print("Orders table created.");
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print("Upgrading database from version $oldVersion to $newVersion...");
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE orders ADD COLUMN isCompleted INTEGER DEFAULT 0');
    }
  }

  Future<int> insertOrder(Order order) async {
    final db = await database;
    return await db.insert('orders', order.toMap());
  }

  Future<int> updateOrder(Order order) async {
    final db = await database;
    return await db.update('orders', order.toMap(), where: 'id = ?', whereArgs: [order.id]);
  }

  Future<void> markOrderAsCompleted(int id, bool isCompleted) async {
    final db = await database;
    await db.update(
      'orders',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Order?> getOrderById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    return Order.fromMap(maps.first);
  }

  Future<int> deleteOrder(int id) async {
    final db = await database;
    return await db.delete('orders', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Order>> getOrders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('orders');
    return List.generate(maps.length, (i) {
      return Order.fromMap(maps[i]);
    });
  }
}