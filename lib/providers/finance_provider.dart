import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _isBalanceHidden = false;

  static const _balanceVisibilityKey = 'finance_balance_hidden';

  FinanceProvider() {
    _loadBalanceVisibility();
  }

  List<FinancialCategory> get categories => _categories;
  List<FinancialTransaction> get transactions => _transactions;
  List<Subcategory> get subcategories => _subcategories;
  Map<int, double> get categoryBalances => _categoryBalances;
  Map<int, double> get subcategoryBalances => _subcategoryBalances;
  double get totalBalance => _totalBalance;
  bool get isLoading => _isLoading;
  bool get isBalanceHidden => _isBalanceHidden;

  Future<void> toggleBalanceVisibility() async {
    await setBalanceHidden(!_isBalanceHidden);
  }

  Future<void> setBalanceHidden(bool hidden) async {
    if (_isBalanceHidden == hidden) {
      return;
    }

    _isBalanceHidden = hidden;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_balanceVisibilityKey, hidden);
    } catch (e) {
      debugPrint('Error saving balance visibility: $e');
    }
  }

  Future<void> _loadBalanceVisibility() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hidden = prefs.getBool(_balanceVisibilityKey) ?? false;
      if (_isBalanceHidden != hidden) {
        _isBalanceHidden = hidden;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading balance visibility: $e');
    }
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _dbHelper.applyPendingInterest();
      _categories = await _dbHelper.readAllCategories();

      bool categoriesUpdated = false;
      final duplicateAcciones = _categories
          .where((category) => category.name.trim().toLowerCase() == 'acciones')
          .toList();
      if (duplicateAcciones.length > 1) {
        duplicateAcciones.sort((a, b) => a.order.compareTo(b.order));
        final duplicatesToRemove = duplicateAcciones
            .skip(1)
            .where((category) => category.id != null)
            .toList();
        if (duplicatesToRemove.isNotEmpty) {
          final idsToRemove = duplicatesToRemove.map((category) => category.id!).toSet();
          for (final duplicate in idsToRemove) {
            await _dbHelper.deleteCategory(duplicate);
          }
          _categories = _categories
              .where((category) => category.id == null || !idsToRemove.contains(category.id!))
              .toList();
          categoriesUpdated = true;
        }
      }
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
      // Siempre leer la transacción previa de la BD para evitar datos stale
      FinancialTransaction? previous;
      if (transaction.id != null) {
        previous = await _dbHelper.readTransaction(transaction.id!);
      }
      if (previous == null) {
        try {
          previous = _transactions.firstWhere((t) => t.id == transaction.id);
        } catch (_) {}
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
      // Siempre leer de la BD para evitar datos stale
      FinancialTransaction? existing = await _dbHelper.readTransaction(id);
      if (existing == null) {
        try {
          existing = _transactions.firstWhere((t) => t.id == id);
        } catch (_) {}
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

  Future<double> applyInterestForTransaction(
    FinancialTransaction transaction, {
    bool manual = false,
  }) async {
    if (transaction.subcategoryId == null) {
      return 0.0;
    }

    try {
      final applied = await _dbHelper.applyInterestForSubcategory(
        transaction.subcategoryId!,
        source: manual ? 'manual' : 'auto',
      );
      await loadData();
      return applied;
    } catch (e) {
      debugPrint('Error applying interest: $e');
      rethrow;
    }
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

    // Siempre leer de la BD para evitar datos desincronizados
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
      if (updatedLastApplied == null) {
        updatedLastApplied = DateTime.now();
      }
    }

    // Al revertir, no debemos desactivar el interés del movimiento
    // ya que puede haber otras transacciones que lo usan

    final updated = target.copyWith(
      balance: target.balance + effectiveDelta,
      isInterestBearing: updatedInterestFlag,
      interestRate: updatedInterestRate,
      lastInterestApplied: updatedLastApplied,
    );
    await _dbHelper.updateSubcategory(updated);
  }
}
