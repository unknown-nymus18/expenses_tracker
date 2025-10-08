import 'dart:ui';

import 'package:hive/hive.dart';
part 'budget_category.g.dart';

@HiveType(typeId: 1)
class BudgetCategory {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int colorValue;

  @HiveField(3)
  double budgetAmount;

  @HiveField(4)
  double spent;

  BudgetCategory({
    required this.id,
    required this.name,
    Color? color,
    int? colorValue,
    required this.budgetAmount,
    this.spent = 0.0,
  }) : colorValue = colorValue ?? color?.value ?? 0xFF000000;

  // Named constructor for when you have a Color
  BudgetCategory.withColor({
    required this.id,
    required this.name,
    required Color color,
    required this.budgetAmount,
    this.spent = 0.0,
  }) : colorValue = color.value;

  // Getter to convert int back to Color
  Color get color => Color(colorValue);

  double get remainingAmount => budgetAmount - spent;
  double get spentPercentage =>
      budgetAmount > 0 ? (spent / budgetAmount) * 100 : 0;

  bool get isOverBudget => spent > budgetAmount;
}
