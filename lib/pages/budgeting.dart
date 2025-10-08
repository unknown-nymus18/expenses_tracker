import 'dart:ui';
import 'package:expenses_app/components/functions.dart';
import 'package:expenses_app/models/budget_category.dart';
import 'package:expenses_app/models/HiveService.dart';
import 'package:expenses_app/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BudgetingPage extends StatefulWidget {
  const BudgetingPage({super.key});

  @override
  State<BudgetingPage> createState() => _BudgetingPageState();
}

class _BudgetingPageState extends State<BudgetingPage> {
  ScrollController controller = ScrollController();
  List<BudgetCategory> categories = [];
  double totalIncome = 0.0;

  @override
  void initState() {
    super.initState();
    onScroll(controller, context);
    _loadBudgetData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBudgetData();
  }

  void _loadBudgetData() {
    try {
      final currentBudget = HiveService.getCurrentMonthBudget();
      if (currentBudget != null) {
        categories = currentBudget.categories;
        totalIncome = currentBudget.totalIncome;
      } else {
        categories = [];
        totalIncome = 0.0;
      }
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error loading budget data: $e');
      categories = [];
      totalIncome = 0.0;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _showAddIncomeDialog() {
    final TextEditingController incomeController = TextEditingController();

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Dialog(
            backgroundColor: Provider.of<ThemeProvider>(
              context,
            ).themeData.colorScheme.surface.withOpacity(0.95),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Set Monthly Income",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Provider.of<ThemeProvider>(
                        context,
                      ).themeData.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: incomeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Monthly Income',
                      prefixText: '\$',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Provider.of<ThemeProvider>(
                        context,
                      ).themeData.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Cancel"),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          final income = double.tryParse(incomeController.text);
                          if (income != null && income > 0) {
                            _updateIncome(income);
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Provider.of<ThemeProvider>(
                            context,
                          ).themeData.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Save",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditBudgetDialog(BudgetCategory category) {
    final TextEditingController budgetController = TextEditingController(
      text: category.budgetAmount.toString(),
    );

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Dialog(
            backgroundColor: Provider.of<ThemeProvider>(
              context,
            ).themeData.colorScheme.surface.withOpacity(0.95),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Category Header with Icon and Color
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: category.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.category,
                          color: category.color,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Provider.of<ThemeProvider>(
                                  context,
                                ).themeData.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              "Category Budget",
                              style: TextStyle(
                                fontSize: 12,
                                color: category.color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: budgetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Budget Amount',
                      prefixText: '\$',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Provider.of<ThemeProvider>(
                        context,
                      ).themeData.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Cancel"),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          final budget = double.tryParse(budgetController.text);
                          if (budget != null && budget >= 0) {
                            _updateCategoryBudget(category.id, budget);
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: category.color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Save",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _updateIncome(double income) async {
    try {
      final currentBudget = HiveService.getCurrentMonthBudget();
      if (currentBudget != null) {
        // Calculate current total budgeted amount
        double currentTotalBudgeted = currentBudget.categories.fold(
          0.0,
          (sum, category) => sum + category.budgetAmount,
        );

        // Check if new income is less than current budgets
        if (income < currentTotalBudgeted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Income Warning'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New income (\$${income.toStringAsFixed(2)}) is less than currently budgeted amount (\$${currentTotalBudgeted.toStringAsFixed(2)}).',
                  ),
                  SizedBox(height: 10),
                  Text(
                    'You may need to adjust your category budgets.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _proceedWithIncomeUpdate(income);
                  },
                  child: Text('Continue Anyway'),
                ),
              ],
            ),
          );
        } else {
          _proceedWithIncomeUpdate(income);
        }
      }
    } catch (e) {
      print('Error updating income: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating income: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _proceedWithIncomeUpdate(double income) async {
    try {
      final currentBudget = HiveService.getCurrentMonthBudget();
      if (currentBudget != null) {
        currentBudget.totalIncome = income;
        await currentBudget.save();
        _loadBudgetData();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Income updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error updating income: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating income: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateCategoryBudget(String categoryId, double amount) async {
    try {
      final result = await HiveService.updateCategoryBudget(categoryId, amount);

      if (result['success']) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        _loadBudgetData();
      } else {
        // Show budget limit exceeded dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Budget Limit Exceeded'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result['message']),
                SizedBox(height: 10),
                Text(
                  'Available for ${result['category']}: \$${result['availableAmount'].toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Total Income: \$${result['totalIncome'].toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  'Currently Budgeted: \$${result['currentBudgeted'].toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error updating category budget: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating budget: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  double get totalBudgeted {
    return categories.fold(0, (sum, category) => sum + category.budgetAmount);
  }

  double get remainingBudget {
    return totalIncome - totalBudgeted;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      child: Column(
        children: [
          SizedBox(height: 70),

          // Income Card
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Provider.of<ThemeProvider>(
                    context,
                  ).themeData.colorScheme.primary,
                  Provider.of<ThemeProvider>(
                    context,
                  ).themeData.colorScheme.primary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Provider.of<ThemeProvider>(
                    context,
                  ).themeData.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Monthly Income',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    IconButton(
                      onPressed: _showAddIncomeDialog,
                      icon: Icon(Icons.edit, color: Colors.white, size: 20),
                    ),
                  ],
                ),
                Text(
                  '\$${totalIncome.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'), (Match m) => '${m[1]},')}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Remaining: \$${remainingBudget.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'), (Match m) => '${m[1]},')}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 30),

          // Categories Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Budget Categories',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Provider.of<ThemeProvider>(
                      context,
                    ).themeData.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '\$${totalBudgeted.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Provider.of<ThemeProvider>(
                      context,
                    ).themeData.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Categories List
          if (categories.isEmpty)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No budget categories available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create a monthly budget to get started',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            ...categories.map(
              (category) => Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Provider.of<ThemeProvider>(
                    context,
                  ).themeData.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: category.color.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: category.color.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: category.color.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.category,
                      color: category.color,
                      size: 24,
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          category.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Provider.of<ThemeProvider>(
                              context,
                            ).themeData.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: category.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: category.color.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'BUDGET',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: category.color,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Budget: \$${category.budgetAmount.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Spent: \$${category.spent.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: category.budgetAmount > 0
                            ? (category.spent / category.budgetAmount).clamp(
                                0.0,
                                1.0,
                              )
                            : 0.0,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          category.isOverBudget ? Colors.red : category.color,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    onPressed: () => _showEditBudgetDialog(category),
                    icon: Icon(Icons.edit, color: category.color),
                  ),
                ),
              ),
            ),

          SizedBox(height: 100),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
