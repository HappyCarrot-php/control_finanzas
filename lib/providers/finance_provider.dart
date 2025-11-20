import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../models/subcategory.dart';
import '../database/database_helper.dart';

class FinanceProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  List<FinancialCategory> _categories = [];
  List<FinancialTransaction> _transactions = [];
  List<Subcategory> _subcategories = [];
  Map<int, double> _categoryBalances = {};
  Map<int, double> _subcategoryBalances = {};
  double _totalBalance = 0.0;
  bool _isLoading = false;

  List<FinancialCategory> get categories => _categories;
  List<FinancialTransaction> get transactions => _transactions;
  List<Subcategory> get subcategories => _subcategories;
  Map<int, double> get categoryBalances => _categoryBalances;
  Map<int, double> get subcategoryBalances => _subcategoryBalances;
  double get totalBalance => _totalBalance;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _dbHelper.readAllCategories();
      _transactions = await _dbHelper.readAllTransactions();
      _subcategories = await _dbHelper.readAllSubcategories();
      _totalBalance = await _dbHelper.getTotalBalance();
      
      _categoryBalances = {};
      for (var category in _categories) {
        _categoryBalances[category.id!] = await _dbHelper.getCategoryBalance(category.id!);
      }

      _subcategoryBalances = {};
      for (var subcategory in _subcategories) {
        _subcategoryBalances[subcategory.id!] = subcategory.balance;
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(FinancialTransaction transaction) async {
    try {
      await _dbHelper.createTransaction(transaction);
      await loadData();
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(FinancialTransaction transaction) async {
    try {
      await _dbHelper.updateTransaction(transaction);
      await loadData();
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _dbHelper.deleteTransaction(id);
      await loadData();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      rethrow;
    }
  }

  List<FinancialTransaction> getTransactionsByCategory(int categoryId) {
    return _transactions.where((t) => t.categoryId == categoryId).toList();
  }

  double getCategoryBalance(int categoryId) {
    return _categoryBalances[categoryId] ?? 0.0;
  }

  // Métodos para subcategorías
  List<Subcategory> getSubcategoriesByCategory(int categoryId) {
    return _subcategories.where((s) => s.categoryId == categoryId).toList();
  }

  Future<void> addSubcategory(Subcategory subcategory) async {
    try {
      await _dbHelper.createSubcategory(subcategory);
      await loadData();
    } catch (e) {
      debugPrint('Error adding subcategory: $e');
      rethrow;
    }
  }

  Future<void> updateSubcategory(Subcategory subcategory) async {
    try {
      await _dbHelper.updateSubcategory(subcategory);
      await loadData();
    } catch (e) {
      debugPrint('Error updating subcategory: $e');
      rethrow;
    }
  }

  Future<void> deleteSubcategory(int id) async {
    try {
      await _dbHelper.deleteSubcategory(id);
      await loadData();
    } catch (e) {
      debugPrint('Error deleting subcategory: $e');
      rethrow;
    }
  }

  double getSubcategoryBalance(int subcategoryId) {
    return _subcategoryBalances[subcategoryId] ?? 0.0;
  }

  // Actualizar balance de subcategoría al agregar transacción
  Future<void> updateSubcategoryBalance(int subcategoryId, double amount, String type) async {
    try {
      final subcategory = _subcategories.firstWhere((s) => s.id == subcategoryId);
      final newBalance = type == 'income' 
          ? subcategory.balance + amount 
          : subcategory.balance - amount;
      
      await _dbHelper.updateSubcategory(subcategory.copyWith(balance: newBalance));
      await loadData();
    } catch (e) {
      debugPrint('Error updating subcategory balance: $e');
      rethrow;
    }
  }
}
