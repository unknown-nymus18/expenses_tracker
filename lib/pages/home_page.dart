import 'package:expenses_app/components/calendar.dart';
import 'package:expenses_app/components/category_card.dart';
import 'package:expenses_app/components/functions.dart';
import 'package:expenses_app/components/order_tile.dart';
import 'package:expenses_app/components/weekly_chart.dart';
import 'package:expenses_app/models/budget_category.dart';
import 'package:expenses_app/models/HiveService.dart';
import 'package:expenses_app/models/transaction.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController controller = ScrollController();
  List<BudgetCategory> categories = [];

  @override
  void initState() {
    super.initState();
    onScroll(controller, context);
    _loadCategories();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh categories when returning to this page
    _loadCategories();
  }

  void _loadCategories() {
    try {
      final currentBudget = HiveService.getCurrentMonthBudget();
      if (currentBudget != null) {
        categories = currentBudget.categories;
      } else {
        categories = []; // Empty if no budget for current month
      }
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error loading categories: $e');
      categories = [];
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    for (Transaction transaction in HiveService.getAllTransactions()) {
      print(
        'Transaction: ${transaction.title}, Amount: ${transaction.amount}, Date: ${transaction.createdAt}',
      );
    }
    return SingleChildScrollView(
      controller: controller,
      child: Column(
        children: [
          SizedBox(height: 70),
          SizedBox(
            height: 250,
            child: categories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No budget categories for this month',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : PageView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                        ), // Add spacing between cards
                        child: CategoryCard(
                          color: category.color,
                          category: category.name,
                          totalAmount: category.budgetAmount,
                          used: category.spent,
                        ),
                      );
                    },
                  ),
          ),
          SizedBox(height: 20),
          // Content-driven calendar - sizes itself based on content
          SizedBox(
            height: 500,
            width: 500,
            child: Calendar(highlightedDays: HiveService.getAllTransactions()),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsetsGeometry.only(left: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Last Orders",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          SizedBox(height: 20),
          ...List.generate(
            10,
            (index) => OrderTile(
              orderName: "Name",
              price: index.toDouble(),
              date: DateTime.now(),
            ),
          ),
          SizedBox(height: 150),
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
