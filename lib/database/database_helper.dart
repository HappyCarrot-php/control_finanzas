import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../models/shopping_cart_item.dart';
import '../models/subcategory.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('chronowealth.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Agregar nuevas tablas sin modificar las existentes
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const textType = 'TEXT NOT NULL';
      const realType = 'REAL NOT NULL';

      // Tabla de gastos predefinidos (luz, agua, etc.)
      await db.execute('''
        CREATE TABLE IF NOT EXISTS expense_templates (
          id $idType,
          name $textType,
          icon $textType,
          color $textType,
          defaultAmount REAL,
          "order" INTEGER NOT NULL
        )
      ''');

      // Tabla de items del carrito de compras
      await db.execute('''
        CREATE TABLE IF NOT EXISTS shopping_cart_items (
          id $idType,
          productName $textType,
          price $realType,
          quantity INTEGER NOT NULL DEFAULT 1,
          dateAdded $textType,
          notes TEXT
        )
      ''');

      // Insertar gastos predefinidos
      await _insertDefaultExpenseTemplates(db);
    }

    if (oldVersion < 3) {
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const textType = 'TEXT NOT NULL';
      const intType = 'INTEGER NOT NULL';

      // Tabla de subcategorías (movimientos personalizados)
      await db.execute('''
        CREATE TABLE IF NOT EXISTS subcategories (
          id $idType,
          categoryId $intType,
          name $textType,
          balance REAL NOT NULL DEFAULT 0.0,
          icon TEXT,
          color TEXT,
          "order" $intType,
          createdDate $textType,
          FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE CASCADE
        )
      ''');

      // Agregar columna subcategoryId a transactions (nullable para compatibilidad)
      await db.execute('''
        ALTER TABLE transactions ADD COLUMN subcategoryId INTEGER
      ''');
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    await db.execute('''
      CREATE TABLE categories (
        id $idType,
        name $textType,
        icon $textType,
        color $textType,
        "order" $intType
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id $idType,
        categoryId $intType,
        subcategoryId INTEGER,
        amount $realType,
        description $textType,
        date $textType,
        type $textType,
        FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    // Tabla de gastos predefinidos
    await db.execute('''
      CREATE TABLE expense_templates (
        id $idType,
        name $textType,
        icon $textType,
        color $textType,
        defaultAmount REAL,
        "order" $intType
      )
    ''');

    // Tabla de items del carrito
    await db.execute('''
      CREATE TABLE shopping_cart_items (
        id $idType,
        productName $textType,
        price $realType,
        quantity $intType DEFAULT 1,
        dateAdded $textType,
        notes TEXT
      )
    ''');

    // Tabla de subcategorías (movimientos)
    await db.execute('''
      CREATE TABLE subcategories (
        id $idType,
        categoryId $intType,
        name $textType,
        balance REAL NOT NULL DEFAULT 0.0,
        icon TEXT,
        color TEXT,
        "order" $intType,
        createdDate $textType,
        FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    // Insertar datos predeterminados
    await _insertDefaultCategories(db);
    await _insertDefaultExpenseTemplates(db);
  }

  Future<void> _insertDefaultExpenseTemplates(Database db) async {
    final defaultExpenses = [
      {'name': 'Luz', 'icon': 'lightbulb', 'color': 'FFFFD700', 'defaultAmount': 500.0, 'order': 1},
      {'name': 'Agua', 'icon': 'water_drop', 'color': 'FF2196F3', 'defaultAmount': 200.0, 'order': 2},
      {'name': 'Gas', 'icon': 'local_fire_department', 'color': 'FFFF5722', 'defaultAmount': 300.0, 'order': 3},
      {'name': 'Internet', 'icon': 'wifi', 'color': 'FF9C27B0', 'defaultAmount': 400.0, 'order': 4},
      {'name': 'Teléfono', 'icon': 'phone', 'color': 'FF4CAF50', 'defaultAmount': 300.0, 'order': 5},
      {'name': 'Renta', 'icon': 'home', 'color': 'FF795548', 'defaultAmount': 5000.0, 'order': 6},
      {'name': 'Despensa', 'icon': 'shopping_cart', 'color': 'FFFF9800', 'defaultAmount': 0.0, 'order': 7},
      {'name': 'Transporte', 'icon': 'directions_car', 'color': 'FF607D8B', 'defaultAmount': 500.0, 'order': 8},
    ];

    for (var expense in defaultExpenses) {
      await db.insert('expense_templates', expense, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      {'name': 'Cuentas Bancarias', 'icon': 'account_balance', 'color': 'FF4A90E2', 'order': 1},
      {'name': 'Inversiones', 'icon': 'trending_up', 'color': 'FF50C878', 'order': 2},
      {'name': 'Criptomonedas', 'icon': 'currency_bitcoin', 'color': 'FFF7931A', 'order': 3},
      {'name': 'Trading', 'icon': 'show_chart', 'color': 'FFFF6B6B', 'order': 4},
      {'name': 'Préstamos', 'icon': 'handshake', 'color': 'FF9B59B6', 'order': 5},
      {'name': 'Propiedades', 'icon': 'home', 'color': 'FF34495E', 'order': 6},
      {'name': 'Efectivo', 'icon': 'payments', 'color': 'FF2ECC71', 'order': 7},
      {'name': 'Otros Activos', 'icon': 'inventory_2', 'color': 'FF95A5A6', 'order': 8},
    ];

    for (var category in defaultCategories) {
      await db.insert('categories', category);
    }
  }

  // CRUD para Categorías
  Future<FinancialCategory> createCategory(FinancialCategory category) async {
    final db = await database;
    final id = await db.insert('categories', category.toMap());
    return category.copyWith(id: id);
  }

  Future<List<FinancialCategory>> readAllCategories() async {
    final db = await database;
    const orderBy = '"order" ASC';
    final result = await db.query('categories', orderBy: orderBy);
    return result.map((json) => FinancialCategory.fromMap(json)).toList();
  }

  Future<FinancialCategory?> readCategory(int id) async {
    final db = await database;
    final maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return FinancialCategory.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> updateCategory(FinancialCategory category) async {
    final db = await database;
    return db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD para Subcategorías
  Future<Subcategory> createSubcategory(Subcategory subcategory) async {
    final db = await database;
    final id = await db.insert('subcategories', subcategory.toMap());
    return subcategory.copyWith(id: id);
  }

  Future<List<Subcategory>> readSubcategoriesByCategory(int categoryId) async {
    final db = await database;
    final result = await db.query(
      'subcategories',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: '"order" ASC',
    );
    return result.map((json) => Subcategory.fromMap(json)).toList();
  }

  Future<List<Subcategory>> readAllSubcategories() async {
    final db = await database;
    final result = await db.query('subcategories', orderBy: '"order" ASC');
    return result.map((json) => Subcategory.fromMap(json)).toList();
  }

  Future<Subcategory?> readSubcategory(int id) async {
    final db = await database;
    final maps = await db.query(
      'subcategories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Subcategory.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateSubcategory(Subcategory subcategory) async {
    final db = await database;
    return await db.update(
      'subcategories',
      subcategory.toMap(),
      where: 'id = ?',
      whereArgs: [subcategory.id],
    );
  }

  Future<int> deleteSubcategory(int id) async {
    final db = await database;
    return await db.delete(
      'subcategories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD para Transacciones
  Future<FinancialTransaction> createTransaction(FinancialTransaction transaction) async {
    final db = await database;
    final id = await db.insert('transactions', transaction.toMap());
    return transaction.copyWith(id: id);
  }

  Future<List<FinancialTransaction>> readAllTransactions() async {
    final db = await database;
    const orderBy = 'date DESC';
    final result = await db.query('transactions', orderBy: orderBy);
    return result.map((json) => FinancialTransaction.fromMap(json)).toList();
  }

  Future<List<FinancialTransaction>> readTransactionsByCategory(int categoryId) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'date DESC',
    );
    return result.map((json) => FinancialTransaction.fromMap(json)).toList();
  }

  Future<List<FinancialTransaction>> readTransactionsBySubcategory(int subcategoryId) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'subcategoryId = ?',
      whereArgs: [subcategoryId],
      orderBy: 'date DESC',
    );
    return result.map((json) => FinancialTransaction.fromMap(json)).toList();
  }

  Future<FinancialTransaction?> readTransaction(int id) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return FinancialTransaction.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> updateTransaction(FinancialTransaction transaction) async {
    final db = await database;
    return db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Obtener balance por categoría
  Future<double> getCategoryBalance(int categoryId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        SUM(CASE WHEN type = 'income' THEN amount ELSE -amount END) as balance
      FROM transactions
      WHERE categoryId = ?
    ''', [categoryId]);

    if (result.isNotEmpty && result.first['balance'] != null) {
      return result.first['balance'] as double;
    }
    return 0.0;
  }

  // Obtener balance total
  Future<double> getTotalBalance() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        SUM(CASE WHEN type = 'income' THEN amount ELSE -amount END) as balance
      FROM transactions
    ''');

    if (result.isNotEmpty && result.first['balance'] != null) {
      return result.first['balance'] as double;
    }
    return 0.0;
  }

  // CRUD para Shopping Cart Items
  Future<int> addCartItem(ShoppingCartItem item) async {
    final db = await database;
    return await db.insert('shopping_cart_items', item.toMap());
  }

  Future<List<ShoppingCartItem>> getAllCartItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('shopping_cart_items', orderBy: 'dateAdded DESC');
    return List.generate(maps.length, (i) => ShoppingCartItem.fromMap(maps[i]));
  }

  Future<int> updateCartItem(ShoppingCartItem item) async {
    final db = await database;
    return await db.update('shopping_cart_items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<int> deleteCartItem(int id) async {
    final db = await database;
    return await db.delete('shopping_cart_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> clearCart() async {
    final db = await database;
    return await db.delete('shopping_cart_items');
  }

  Future<double> getCartTotal() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(price * quantity) as total FROM shopping_cart_items');
    return (result.first['total'] as double?) ?? 0.0;
  }

  // CRUD para Expense Templates
  Future<List<Map<String, dynamic>>> getAllExpenseTemplates() async {
    final db = await database;
    return await db.query('expense_templates', orderBy: '"order" ASC');
  }

  Future<int> updateExpenseTemplate(int id, Map<String, dynamic> template) async {
    final db = await database;
    return await db.update('expense_templates', template, where: 'id = ?', whereArgs: [id]);
  }

  // Obtener estadísticas de gastos
  Future<double> getTotalExpenses({DateTime? startDate, DateTime? endDate}) async {
    final db = await database;
    String query = 'SELECT SUM(amount) as total FROM transactions WHERE type = "expense"';
    List<dynamic> args = [];

    if (startDate != null) {
      query += ' AND date >= ?';
      args.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      query += ' AND date <= ?';
      args.add(endDate.toIso8601String());
    }

    final result = await db.rawQuery(query, args);
    return (result.first['total'] as double?) ?? 0.0;
  }

  Future<double> getTotalIncome({DateTime? startDate, DateTime? endDate}) async {
    final db = await database;
    String query = 'SELECT SUM(amount) as total FROM transactions WHERE type = "income"';
    List<dynamic> args = [];

    if (startDate != null) {
      query += ' AND date >= ?';
      args.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      query += ' AND date <= ?';
      args.add(endDate.toIso8601String());
    }

    final result = await db.rawQuery(query, args);
    return (result.first['total'] as double?) ?? 0.0;
  }

  Future<List<Map<String, dynamic>>> getFrequentExpenses({int limit = 5}) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT description, COUNT(*) as frequency, AVG(amount) as avgAmount, SUM(amount) as totalAmount
      FROM transactions
      WHERE type = "expense"
      GROUP BY description
      ORDER BY frequency DESC
      LIMIT ?
    ''', [limit]);
  }

  Future<List<Map<String, dynamic>>> getExpensesByCategory({DateTime? startDate, DateTime? endDate}) async {
    final db = await database;
    String query = '''
      SELECT c.name, c.icon, c.color, SUM(t.amount) as total
      FROM transactions t
      JOIN categories c ON t.categoryId = c.id
      WHERE t.type = "expense"
    ''';
    List<dynamic> args = [];

    if (startDate != null) {
      query += ' AND t.date >= ?';
      args.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      query += ' AND t.date <= ?';
      args.add(endDate.toIso8601String());
    }

    query += ' GROUP BY c.id ORDER BY total DESC';

    return await db.rawQuery(query, args);
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
