import 'package:expenses_app/models/budget_category.dart';

class MonthlyBudget {
  String id;
  DateTime month;
  double totalIncome;
  List<BudgetCategory> categories;
  DateTime createdAt;

  MonthlyBudget({
    required this.id,
    required this.month,
    required this.totalIncome,
    required this.createdAt,
    required this.categories,
  });

  double get totalBudgeted =>
      categories.fold(0, (sum, category) => sum + category.budgetAmount);

  double get remainingBudget => totalIncome - totalBudgeted;

  double get totalSpent =>
      categories.fold(0, (sum, category) => sum + category.spent);
}
