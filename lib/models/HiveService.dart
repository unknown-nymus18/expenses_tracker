import 'package:expenses_app/models/budget_category.dart';
import 'package:expenses_app/models/monthly_budget.dart';
import 'package:expenses_app/models/transaction.dart';
import 'package:expenses_app/models/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class HiveService {
  static final String _budgetBoxName = 'budgets';
  static final String _transactionBoxName = 'transactions';
  static final String _settingsBoxName = 'settings';

  static get amountLeftInBudget {
    final budget = getCurrentMonthBudget();
    if (budget == null) return 0.0;
    return budget.totalIncome -
        budget.categories.fold(
          0.0,
          (sum, category) => sum + category.budgetAmount,
        );
  }

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(MonthlyBudgetAdapter());
    Hive.registerAdapter(BudgetCategoryAdapter());
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(SettingsStateAdapter());

    await Hive.openBox<MonthlyBudget>(_budgetBoxName);
    await Hive.openBox<Transaction>(_transactionBoxName);
    await Hive.openBox<SettingsState>(_settingsBoxName);

    // Initialize default settings if none exist
    if (_settingsBox.isEmpty) {
      final defaultSettings = SettingsState(isDarkMode: false, fontSize: 14);
      await _settingsBox.put('settings', defaultSettings);
    }

    if (!hasCurrentMonthBudget) {
      final now = DateTime.now();
      final newBudget = MonthlyBudget(
        id: now.toIso8601String(),
        month: DateTime(now.year, now.month),
        totalIncome: 0.0,
        createdAt: DateTime.now(),
        categories: getDefaultCategories(),
      );
      await saveMonthlyBudget(newBudget);
    }
  }

  static Future<void> clearAllData() async {
    try {
      // Clear all data from boxes except settings
      await _budgetBox.clear();
      await _transactionBox.clear();

      // Optionally, recreate default budget for current month
      final now = DateTime.now();
      final newBudget = MonthlyBudget(
        id: now.toIso8601String(),
        month: DateTime(now.year, now.month),
        totalIncome: 0.0,
        createdAt: DateTime.now(),
        categories: getDefaultCategories(),
      );
      await saveMonthlyBudget(newBudget);
    } catch (e) {
      print('Error clearing data: $e');
      rethrow;
    }
  }

  // Alternative: Delete everything including the boxes themselves and reinitialize
  static Future<void> deleteAllData() async {
    try {
      // Delete boxes from disk (except settings)
      await _budgetBox.deleteFromDisk();
      await _transactionBox.deleteFromDisk();

      // Reinitialize the boxes so the app continues to work
      await Hive.openBox<MonthlyBudget>(_budgetBoxName);
      await Hive.openBox<Transaction>(_transactionBoxName);

      // Create a fresh default budget
      final now = DateTime.now();
      final newBudget = MonthlyBudget(
        id: now.toIso8601String(),
        month: DateTime(now.year, now.month),
        totalIncome: 0.0,
        createdAt: DateTime.now(),
        categories: getDefaultCategories(),
      );
      await saveMonthlyBudget(newBudget);
    } catch (e) {
      print('Error deleting data: $e');
      rethrow;
    }
  }

  static Box<MonthlyBudget> get _budgetBox =>
      Hive.box<MonthlyBudget>(_budgetBoxName);

  static Box<Transaction> get _transactionBox =>
      Hive.box<Transaction>(_transactionBoxName);

  static Box<SettingsState> get _settingsBox =>
      Hive.box<SettingsState>(_settingsBoxName);

  static MonthlyBudget? getCurrentMonthBudget() {
    final now = DateTime.now();
    final budgets = _budgetBox.values.where(
      (budgets) =>
          budgets.month.year == now.year && budgets.month.month == now.month,
    );
    return budgets.isNotEmpty ? budgets.first : null;
  }

  static Future<void> saveMonthlyBudget(MonthlyBudget budget) async {
    await _budgetBox.put(budget.id, budget);
  }

  static Future<Map<String, dynamic>> updateCategoryBudget(
    String categoryId,
    double amount,
  ) async {
    final budget = getCurrentMonthBudget();
    if (budget == null) {
      return {'success': false, 'message': 'No budget found for current month'};
    }

    final categoryIndex = budget.categories.indexWhere(
      (cat) => cat.id == categoryId,
    );

    if (categoryIndex == -1) {
      return {'success': false, 'message': 'Category not found'};
    }

    // Calculate current total budgeted amount (excluding the category being updated)
    double currentTotalBudgeted = 0.0;
    for (int i = 0; i < budget.categories.length; i++) {
      if (i != categoryIndex) {
        currentTotalBudgeted += budget.categories[i].budgetAmount;
      }
    }

    // Calculate what the new total would be with the updated category
    double newTotalBudgeted = currentTotalBudgeted + amount;

    // Check if new total exceeds income
    if (newTotalBudgeted > budget.totalIncome) {
      double availableAmount = budget.totalIncome - currentTotalBudgeted;
      return {
        'success': false,
        'message':
            'Budget exceeds available income by \$${(newTotalBudgeted - budget.totalIncome).toStringAsFixed(2)}',
        'totalIncome': budget.totalIncome,
        'currentBudgeted': currentTotalBudgeted,
        'requestedAmount': amount,
        'availableAmount': availableAmount,
        'category': budget.categories[categoryIndex].name,
      };
    }

    // Update the budget if within income limits
    budget.categories[categoryIndex].budgetAmount = amount;
    await budget.save();

    return {
      'success': true,
      'message': 'Budget updated successfully',
      'remainingIncome': budget.totalIncome - newTotalBudgeted,
      'totalBudgeted': newTotalBudgeted,
    };
  }

  static Future<void> addTransaction(Transaction transaction) async {
    await _transactionBox.put(transaction.id, transaction);

    final budget = getCurrentMonthBudget();
    if (budget != null) {
      final categoryIndex = budget.categories.indexWhere(
        (cat) => cat.id == transaction.category,
      );
      if (categoryIndex != -1) {
        budget.categories[categoryIndex].spent += double.parse(
          transaction.amount,
        );
        await budget.save();
      }
    }
  }

  static List<Transaction> getAllTransactions() {
    return _transactionBox.values.toList();
  }

  static List<Transaction> getCurrentMonthTransactions() {
    final now = DateTime.now();
    return _transactionBox.values
        .where(
          (transaction) =>
              transaction.createdAt.year == now.year &&
              transaction.createdAt.month == now.month,
        )
        .toList();
  }

  static List<BudgetCategory> getDefaultCategories() {
    return [
      BudgetCategory(
        id: 'food',
        name: 'Food',
        color: Color.fromRGBO(170, 205, 186, 1),
        budgetAmount: 0,
      ),
      BudgetCategory(
        id: 'transport',
        name: 'Transport',
        color: Color.fromRGBO(248, 210, 209, 1),
        budgetAmount: 0,
      ),
      BudgetCategory(
        id: 'entertainment',
        name: 'Entertainment',
        color: Color.fromRGBO(255, 215, 142, 1),
        budgetAmount: 0,
      ),
      BudgetCategory(
        id: 'savings',
        name: 'Savings',
        color: Color.fromRGBO(104, 108, 72, 1),
        budgetAmount: 0,
      ),
    ];
  }

  static bool get hasCurrentMonthBudget {
    return getCurrentMonthBudget() != null;
  }

  static List<MonthlyBudget> getAllMonthlyBudgets() {
    return _budgetBox.values.toList();
  }

  static List<BudgetCategory> getAllMonthlyCategories() {
    return _budgetBox.values.expand((budget) => budget.categories).toList();
  }

  static addMonthlyIncome(double amount) async {
    final budget = getCurrentMonthBudget();
    if (budget != null) {
      budget.totalIncome += amount;
      await budget.save();
    }
  }

  static Future<Map<String, dynamic>> makeTransaction(
    Transaction transaction,
  ) async {
    final budget = getCurrentMonthBudget();
    if (budget == null) {
      return {'success': false, 'message': 'No budget found for current month'};
    }

    final categoryIndex = budget.categories.indexWhere(
      (cat) => cat.id == transaction.category,
    );

    if (categoryIndex == -1) {
      return {'success': false, 'message': 'Category not found'};
    }

    final category = budget.categories[categoryIndex];
    final transactionAmount = double.tryParse(transaction.amount) ?? 0.0;
    final newSpentAmount = category.spent + transactionAmount;

    // Check if budget is set for this category
    if (category.budgetAmount <= 0) {
      return {
        'success': false,
        'message':
            'No budget set for ${category.name}. Please set a budget before making transactions.',
        'category': category.name,
        'needsBudget': true,
      };
    }

    // Check if transaction would exceed budget
    if (newSpentAmount > category.budgetAmount) {
      final overAmount = newSpentAmount - category.budgetAmount;
      return {
        'success': false,
        'message':
            'Transaction would exceed budget by \$${overAmount.toStringAsFixed(2)}',
        'category': category.name,
        'currentSpent': category.spent,
        'budgetAmount': category.budgetAmount,
        'transactionAmount': transactionAmount,
      };
    }

    // Proceed with transaction if budget allows
    await _transactionBox.put(transaction.id, transaction);
    budget.categories[categoryIndex].spent = newSpentAmount;
    await budget.save();

    return {
      'success': true,
      'message': 'Transaction added successfully',
      'remainingBudget': category.budgetAmount - newSpentAmount,
    };
  }

  static void deleteTransaction(String transactionId) async {
    final transaction = _transactionBox.get(transactionId);
    if (transaction != null) {
      final budget = getCurrentMonthBudget();
      if (budget != null) {
        final categoryIndex = budget.categories.indexWhere(
          (cat) => cat.id == transaction.category,
        );
        if (categoryIndex != -1) {
          final transactionAmount = double.tryParse(transaction.amount) ?? 0.0;
          budget.categories[categoryIndex].spent -= transactionAmount;
          if (budget.categories[categoryIndex].spent < 0) {
            budget.categories[categoryIndex].spent = 0;
          }
          await budget.save();
        }
      }
      await _transactionBox.delete(transactionId);
    }
  }

  static Listenable get transactionListenable => _transactionBox.listenable();

  // Settings management
  static SettingsState? getSettings() {
    return _settingsBox.get('settings');
  }

  static Future<void> updateDarkMode(bool isDarkMode) async {
    final settings = getSettings();
    if (settings != null) {
      settings.isDarkMode = isDarkMode;
      await _settingsBox.put('settings', settings);
    }
  }

  static Future<void> updateFontSize(int fontSize) async {
    final settings = getSettings();
    if (settings != null) {
      settings.fontSize = fontSize;
      await _settingsBox.put('settings', settings);
    }
  }

  static Listenable get settingsListenable => _settingsBox.listenable();
}
