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
      await _dbHelper.applyPendingInterest();
      _categories = await _dbHelper.readAllCategories();

      bool categoriesUpdated = false;
      if (!_categories.any((category) => category.name.toLowerCase() == 'acciones')) {
        FinancialCategory? otrosActivos;
        try {
          otrosActivos = _categories.firstWhere((category) => category.name.toLowerCase() == 'otros activos');
        } catch (_) {
          otrosActivos = null;
        }

        var nextOrder = 1;
        for (final category in _categories) {
          if (category.order >= nextOrder) {
            nextOrder = category.order + 1;
          }
        }

        final accionesOrder = otrosActivos?.order ?? nextOrder;

        await _dbHelper.createCategory(
          FinancialCategory(
            name: 'Acciones',
            icon: 'show_chart',
            color: 'FF5DADE2',
            order: accionesOrder,
          ),
        );

        if (otrosActivos != null && otrosActivos.order <= accionesOrder) {
          await _dbHelper.updateCategory(
            otrosActivos.copyWith(order: accionesOrder + 1),
          );
        }

        categoriesUpdated = true;
      }

      if (categoriesUpdated) {
        _categories = await _dbHelper.readAllCategories();
      }
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
      await _dbHelper.applyPendingInterest();
      final savedTransaction = await _dbHelper.createTransaction(transaction);
      await _applyTransactionToSubcategory(savedTransaction);
      await loadData();
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(FinancialTransaction transaction) async {
    try {
      await _dbHelper.applyPendingInterest();
      FinancialTransaction? previous;
      try {
        previous = _transactions.firstWhere((t) => t.id == transaction.id);
      } catch (_) {
        if (transaction.id != null) {
          previous = await _dbHelper.readTransaction(transaction.id!);
        }
      }

      if (previous != null) {
        await _applyTransactionToSubcategory(previous, reverse: true);
      }

      await _dbHelper.updateTransaction(transaction);
      await _applyTransactionToSubcategory(transaction);
      await loadData();
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _dbHelper.applyPendingInterest();
      FinancialTransaction? existing;
      try {
        existing = _transactions.firstWhere((t) => t.id == id);
      } catch (_) {
        existing = await _dbHelper.readTransaction(id);
      }

      if (existing != null) {
        await _applyTransactionToSubcategory(existing, reverse: true);
      }

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
      await _dbHelper.applyPendingInterest();
      await _dbHelper.createSubcategory(subcategory);
      await loadData();
    } catch (e) {
      debugPrint('Error adding subcategory: $e');
      rethrow;
    }
  }

  Future<void> updateSubcategory(Subcategory subcategory) async {
    try {
      await _dbHelper.applyPendingInterest();
      await _dbHelper.updateSubcategory(subcategory);
      await loadData();
    } catch (e) {
      debugPrint('Error updating subcategory: $e');
      rethrow;
    }
  }

  Future<void> deleteSubcategory(int id) async {
    try {
      await _dbHelper.applyPendingInterest();
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
  Future<void> _applyTransactionToSubcategory(
    FinancialTransaction transaction, {
    bool reverse = false,
  }) async {
    final subcategoryId = transaction.subcategoryId;
    if (subcategoryId == null) {
      return;
    }

    final target = await _dbHelper.readSubcategory(subcategoryId);
    if (target == null) {
      return;
    }

    final direction = transaction.type == 'income' ? 1.0 : -1.0;
    final effectiveDelta = (reverse ? -1.0 : 1.0) * direction * transaction.amount;

    bool updatedInterestFlag = target.isInterestBearing;
    double updatedInterestRate = target.interestRate;
    DateTime? updatedLastApplied = target.lastInterestApplied;

    if (!reverse && transaction.type == 'income' && transaction.isInterestBearing && transaction.interestRate > 0) {
      updatedInterestFlag = true;
      updatedInterestRate = transaction.interestRate;
      updatedLastApplied = DateTime.now();
    }

    final updated = target.copyWith(
      balance: target.balance + effectiveDelta,
      isInterestBearing: updatedInterestFlag,
      interestRate: updatedInterestRate,
      lastInterestApplied: updatedLastApplied,
    );
    await _dbHelper.updateSubcategory(updated);
  }
}
