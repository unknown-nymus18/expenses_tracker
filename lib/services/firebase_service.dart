import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expenses_app/models/monthly_budget.dart';
import 'package:expenses_app/models/budget_category.dart';
import 'package:expenses_app/models/transaction.dart' as models;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FirebaseService {
  static final FirebaseAuth auth = FirebaseAuth.instance;

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static User? getCurrentUser() {
    return auth.currentUser;
  }

  static String? getCurrentUserName() {
    return auth.currentUser?.displayName;
  }

  static String? get userId => auth.currentUser?.uid;

  Future<void> createUserContainer() async {
    _firestore.collection('users').doc(auth.currentUser?.uid).set({
      'uid': auth.currentUser?.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'email': auth.currentUser?.email,
      'name': auth.currentUser?.displayName,
    });
  }

  Future<void> deleteUserContainer() async {
    await _firestore.collection('users').doc(auth.currentUser?.uid).delete();
  }

  Future<void> signUp(String email, String password, String name) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update the user's display name
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();

      if (auth.currentUser != null) {
        await createUserContainer();
      } else {}
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  /// Update user's display name
  static Future<void> updateUserName(String name) async {
    try {
      await auth.currentUser?.updateDisplayName(name);
      await auth.currentUser?.reload();

      // Update Firestore user document
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'name': name,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Update name error: $e');
      rethrow;
    }
  }

  /// Save or update a monthly budget to Firestore
  static Future<void> saveMonthlyBudget(MonthlyBudget budget) async {
    if (userId == null) throw Exception('User not authenticated');

    final monthKey = DateFormat('yyyy-MM').format(budget.month);

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .doc(monthKey)
        .set({
          'id': budget.id,
          'month': Timestamp.fromDate(budget.month),
          'totalIncome': budget.totalIncome,
          'createdAt': Timestamp.fromDate(budget.createdAt),
          'categories': budget.categories
              .map(
                (cat) => {
                  'id': cat.id,
                  'name': cat.name,
                  'colorValue': cat.colorValue,
                  'budgetAmount': cat.budgetAmount,
                  'spent': cat.spent,
                },
              )
              .toList(),
        });
  }

  /// Get current month's budget as a stream
  static Stream<MonthlyBudget?> getCurrentMonthBudgetStream() {
    if (userId == null) {
      print('⚠️ getCurrentMonthBudgetStream: User not authenticated');
      return Stream.value(null);
    }

    try {
      final now = DateTime.now();
      final monthKey = DateFormat('yyyy-MM').format(now);

      return _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(monthKey)
          .snapshots()
          .asyncMap((snapshot) async {
            try {
              if (!snapshot.exists) {
                print('📅 Creating default budget for stream: $monthKey');

                // Create default budget with categories on first access
                final defaultBudget = MonthlyBudget(
                  id: monthKey,
                  month: now,
                  totalIncome: 0.0,
                  categories: getDefaultCategories(),
                  createdAt: now,
                );

                try {
                  await saveMonthlyBudget(defaultBudget);
                  print('✅ Default budget created successfully in stream');
                } catch (saveError) {
                  print('❌ Error saving budget in stream: $saveError');
                }

                return defaultBudget;
              }
              return _budgetFromFirestore(snapshot);
            } catch (e) {
              print('❌ Error processing budget snapshot: $e');
              // Return default budget to prevent stream from breaking
              return MonthlyBudget(
                id: monthKey,
                month: now,
                totalIncome: 0.0,
                categories: getDefaultCategories(),
                createdAt: now,
              );
            }
          })
          .handleError((error) {
            print('❌ Stream error in getCurrentMonthBudgetStream: $error');
          });
    } catch (e) {
      print('❌ Error setting up budget stream: $e');
      // Return a stream with default budget
      return Stream.value(
        MonthlyBudget(
          id: DateFormat('yyyy-MM').format(DateTime.now()),
          month: DateTime.now(),
          totalIncome: 0.0,
          categories: getDefaultCategories(),
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  /// Get current month's budget once
  static Future<MonthlyBudget?> getCurrentMonthBudget() async {
    if (userId == null) {
      print('⚠️ getCurrentMonthBudget: User not authenticated');
      return null;
    }

    try {
      final now = DateTime.now();
      final monthKey = DateFormat('yyyy-MM').format(now);

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(monthKey)
          .get();

      if (!snapshot.exists) {
        print('📅 Creating default budget for $monthKey');

        // Create default budget with categories on first access
        final defaultBudget = MonthlyBudget(
          id: monthKey,
          month: now,
          totalIncome: 0.0,
          categories: getDefaultCategories(),
          createdAt: now,
        );

        try {
          await saveMonthlyBudget(defaultBudget);
          print('✅ Default budget created successfully');
          return defaultBudget;
        } catch (saveError) {
          print('❌ Error saving default budget: $saveError');
          // Return the budget anyway so the app doesn't crash
          return defaultBudget;
        }
      }

      return _budgetFromFirestore(snapshot);
    } catch (e, stackTrace) {
      print('❌ Error in getCurrentMonthBudget: $e');
      print('Stack trace: $stackTrace');

      // Return a minimal default budget to prevent crash
      return MonthlyBudget(
        id: DateFormat('yyyy-MM').format(DateTime.now()),
        month: DateTime.now(),
        totalIncome: 0.0,
        categories: getDefaultCategories(),
        createdAt: DateTime.now(),
      );
    }
  }

  /// Get all budgets as a stream
  static Stream<List<MonthlyBudget>> getAllBudgetsStream() {
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .orderBy('month', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => _budgetFromFirestore(doc)).toList();
        });
  }

  /// Update category budget amount with validation
  static Future<Map<String, dynamic>> updateCategoryBudget(
    String categoryId,
    double amount,
  ) async {
    final budget = await getCurrentMonthBudget();
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
    await saveMonthlyBudget(budget);

    return {
      'success': true,
      'message': 'Budget updated successfully',
      'remainingIncome': budget.totalIncome - newTotalBudgeted,
      'totalBudgeted': newTotalBudgeted,
    };
  }

  /// Add monthly income to current month's budget
  static Future<void> addMonthlyIncome(double amount) async {
    final budget = await getCurrentMonthBudget();
    if (budget != null) {
      budget.totalIncome += amount;
      await saveMonthlyBudget(budget);
    }
  }

  /// Get amount left in budget (unallocated income)
  static Future<double> getAmountLeftInBudget() async {
    final budget = await getCurrentMonthBudget();
    if (budget == null) return 0.0;
    return budget.totalIncome -
        budget.categories.fold(
          0.0,
          (sum, category) => sum + category.budgetAmount,
        );
  }

  /// Check if current month has a budget
  static Future<bool> hasCurrentMonthBudget() async {
    final budget = await getCurrentMonthBudget();
    return budget != null;
  }

  /// Get default categories
  static List<BudgetCategory> getDefaultCategories() {
    return [
      BudgetCategory(
        id: 'food',
        name: 'Food',
        color: const Color.fromRGBO(170, 205, 186, 1),
        budgetAmount: 0,
      ),
      BudgetCategory(
        id: 'transport',
        name: 'Transport',
        color: const Color.fromRGBO(248, 210, 209, 1),
        budgetAmount: 0,
      ),
      BudgetCategory(
        id: 'entertainment',
        name: 'Entertainment',
        color: const Color.fromRGBO(255, 215, 142, 1),
        budgetAmount: 0,
      ),
      BudgetCategory(
        id: 'savings',
        name: 'Savings',
        color: const Color.fromRGBO(104, 108, 72, 1),
        budgetAmount: 0,
      ),
    ];
  }

  // ============ FIRESTORE TRANSACTION METHODS ============

  /// Add a transaction and update category spent amount
  static Future<void> addTransaction(models.Transaction transaction) async {
    if (userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(transaction.id)
        .set({
          'id': transaction.id,
          'title': transaction.title,
          'amount': transaction.amount,
          'category': transaction.category,
          'createdAt': Timestamp.fromDate(transaction.createdAt),
          'description': transaction.description,
        });

    // Update category spent amount
    await _updateCategorySpentAmount(
      transaction.category,
      transaction.amount,
      isAdding: true,
    );
  }

  /// Make a transaction with budget validation
  static Future<Map<String, dynamic>> makeTransaction(
    models.Transaction transaction,
  ) async {
    final budget = await getCurrentMonthBudget();
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
    final newSpentAmount = category.spent + transaction.amount;

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
        'transactionAmount': transaction.amount,
      };
    }

    // Proceed with transaction if budget allows
    await addTransaction(transaction);

    return {
      'success': true,
      'message': 'Transaction added successfully',
      'remainingBudget': category.budgetAmount - newSpentAmount,
    };
  }

  /// Update an existing transaction
  static Future<void> updateTransaction(models.Transaction transaction) async {
    if (userId == null) throw Exception('User not authenticated');

    // Get old transaction to adjust spent amount
    final oldSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(transaction.id)
        .get();

    if (oldSnapshot.exists) {
      final oldData = oldSnapshot.data()!;
      final oldAmount = (oldData['amount'] as num).toDouble();
      final oldCategory = oldData['category'] as String;

      // Subtract old amount from old category
      await _updateCategorySpentAmount(oldCategory, oldAmount, isAdding: false);
    }

    // Update transaction document
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(transaction.id)
        .update({
          'title': transaction.title,
          'amount': transaction.amount,
          'category': transaction.category,
          'description': transaction.description,
        });

    // Add new amount to new category
    await _updateCategorySpentAmount(
      transaction.category,
      transaction.amount,
      isAdding: true,
    );
  }

  /// Delete a transaction and update category spent amount
  static Future<void> deleteTransaction(String transactionId) async {
    if (userId == null) throw Exception('User not authenticated');

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(transactionId)
        .get();

    if (snapshot.exists) {
      final data = snapshot.data()!;
      final amount = (data['amount'] as num).toDouble();
      final category = data['category'] as String;

      // Subtract amount from category
      await _updateCategorySpentAmount(category, amount, isAdding: false);

      // Delete transaction
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transactionId)
          .delete();
    }
  }

  static Stream<String> getUserCardNumberStream() {
    if (userId == null) return Stream.value("");

    return _firestore.collection('users').doc(userId).snapshots().map((
      snapshot,
    ) {
      return snapshot.data()?['cardNumber'] ?? "";
    });
  }

  static Future<void> updateUserCardNumber(String cardNumber) async {
    if (userId == null) throw Exception('User not authenticated');

    await _firestore.collection('users').doc(userId).update({
      'cardNumber': cardNumber,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get all transactions as a stream
  static Stream<List<models.Transaction>> getAllTransactionsStream() {
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => _transactionFromFirestore(doc))
              .toList();
        });
  }

  /// Get filtered transactions as a stream
  static Stream<List<models.Transaction>> getFilteredTransactionsStream({
    DateTime? date,
    double? minPrice,
  }) {
    if (userId == null) return Stream.value([]);

    // Use client-side filtering to avoid Firestore index requirements
    return getAllTransactionsStream().map((transactions) {
      return transactions.where((transaction) {
        // Filter by date if provided
        if (date != null) {
          final startOfDay = DateTime(date.year, date.month, date.day);
          final endOfDay = DateTime(
            date.year,
            date.month,
            date.day,
            23,
            59,
            59,
          );
          final isInDateRange =
              transaction.createdAt.isAfter(
                startOfDay.subtract(Duration(seconds: 1)),
              ) &&
              transaction.createdAt.isBefore(
                endOfDay.add(Duration(seconds: 1)),
              );
          if (!isInDateRange) return false;
        }

        // Filter by minimum price if provided
        if (minPrice != null) {
          if (transaction.amount < minPrice) return false;
        }

        return true;
      }).toList();
    });
  }

  static Stream<List<models.Transaction>>
  getTransactionsForCurrentMonthStream() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return getTransactionsByDateStream(startOfMonth, endOfMonth);
  }

  /// Get transactions by date range as a stream
  static Stream<List<models.Transaction>> getTransactionsByDateStream(
    DateTime startDate,
    DateTime endDate,
  ) {
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        )
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => _transactionFromFirestore(doc))
              .toList();
        });
  }

  /// Get current month's transactions as a stream
  static Stream<List<models.Transaction>> getCurrentMonthTransactionsStream() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return getTransactionsByDateStream(startOfMonth, endOfMonth);
  }

  // ============ HELPER METHODS ============

  /// Update category spent amount in the budget
  static Future<void> _updateCategorySpentAmount(
    String categoryId,
    double amount, {
    required bool isAdding,
  }) async {
    final budget = await getCurrentMonthBudget();
    if (budget == null) return;

    final categoryIndex = budget.categories.indexWhere(
      (cat) => cat.id == categoryId,
    );

    if (categoryIndex != -1) {
      if (isAdding) {
        budget.categories[categoryIndex].spent += amount;
      } else {
        budget.categories[categoryIndex].spent -= amount;
        if (budget.categories[categoryIndex].spent < 0) {
          budget.categories[categoryIndex].spent = 0;
        }
      }
      await saveMonthlyBudget(budget);
    }
  }

  /// Convert Firestore document to MonthlyBudget
  static MonthlyBudget _budgetFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MonthlyBudget(
      id: data['id'] as String,
      month: (data['month'] as Timestamp).toDate(),
      totalIncome: (data['totalIncome'] as num).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      categories: (data['categories'] as List)
          .map(
            (cat) => BudgetCategory(
              id: cat['id'] as String,
              name: cat['name'] as String,
              colorValue: cat['colorValue'] as int,
              budgetAmount: (cat['budgetAmount'] as num).toDouble(),
              spent: (cat['spent'] as num).toDouble(),
            ),
          )
          .toList(),
    );
  }

  /// Convert Firestore document to Transaction
  static models.Transaction _transactionFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Handle both String and Number amount types (for migration)
    double amount;
    final amountData = data['amount'];
    if (amountData is String) {
      amount = double.tryParse(amountData) ?? 0.0;
    } else if (amountData is num) {
      amount = amountData.toDouble();
    } else {
      amount = 0.0;
    }

    return models.Transaction(
      id: data['id'] as String,
      title: data['title'] as String,
      amount: amount,
      category: data['category'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      description: data['description'] as String?,
    );
  }

  /// Delete all user data from Firestore
  static Future<void> deleteAllUserData() async {
    if (userId == null) throw Exception('User not authenticated');

    // Delete all transactions
    final transactionsSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .get();

    for (var doc in transactionsSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete all budgets
    final budgetsSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .get();

    for (var doc in budgetsSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// Migrate all Hive data to Firestore for the current user
  static Future<void> migrateHiveDataToFirestore({
    required List<MonthlyBudget> hiveBudgets,
    required List<models.Transaction> hiveTransactions,
  }) async {
    if (userId == null) throw Exception('User not authenticated');

    print(
      'Starting migration of ${hiveBudgets.length} budgets and ${hiveTransactions.length} transactions...',
    );

    // Migrate budgets
    for (var budget in hiveBudgets) {
      try {
        await saveMonthlyBudget(budget);
        print(
          'Migrated budget for ${DateFormat('yyyy-MM').format(budget.month)}',
        );
      } catch (e) {
        print('Error migrating budget ${budget.id}: $e');
      }
    }

    // Migrate transactions
    for (var transaction in hiveTransactions) {
      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .doc(transaction.id)
            .set({
              'id': transaction.id,
              'title': transaction.title,
              'amount': transaction.amount,
              'category': transaction.category,
              'createdAt': Timestamp.fromDate(transaction.createdAt),
              'description': transaction.description,
            });
        print('Migrated transaction: ${transaction.title}');
      } catch (e) {
        print('Error migrating transaction ${transaction.id}: $e');
      }
    }

    print('Migration completed!');
  }

  static Future<void> deleteUserData() async {
    if (userId == null) {
      return;
    }

    try {
      final userDoc = _firestore.collection('users').doc(userId);

      // Delete all transactions
      final transactionsSnapshot = await userDoc
          .collection('transactions')
          .get();
      for (var doc in transactionsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete all budgets
      final budgetsSnapshot = await userDoc.collection('budgets').get();
      for (var doc in budgetsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete the main user document
      await userDoc.delete();
    } catch (e) {
      print('Error deleting user data: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> deleteAccount() async {
    if (userId == null) {
      return {'success': false, 'message': 'User not authenticated'};
    }

    try {
      await deleteUserData();
      await auth.currentUser?.delete();
      await signOut();
      return {'success': true, 'message': 'Account deleted successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Error deleting account: $e'};
    }
  }
}
