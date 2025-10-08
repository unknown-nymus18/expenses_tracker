import 'package:expenses_app/models/budget_category.dart';
import 'package:hive/hive.dart';

part 'monthly_budget.g.dart';

@HiveType(typeId: 0)
class MonthlyBudget extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime month;

  @HiveField(2)
  double totalIncome;

  @HiveField(3)
  List<BudgetCategory> categories;

  @HiveField(4)
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
