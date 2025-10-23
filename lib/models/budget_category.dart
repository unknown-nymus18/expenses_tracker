import 'dart:ui';

class BudgetCategory {
  String id;
  String name;
  int colorValue;
  double budgetAmount;
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
