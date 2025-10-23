import 'package:expenses_app/components/calendar.dart';
import 'package:expenses_app/components/category_card.dart';
import 'package:expenses_app/components/functions.dart';
import 'package:expenses_app/components/order_tile.dart';
import 'package:expenses_app/services/firebase_service.dart';
import 'package:expenses_app/models/transaction.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    onScroll(controller, context);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseService.getCurrentMonthBudgetStream(),
      builder: (context, budgetSnapshot) {
        final categories = budgetSnapshot.data?.categories ?? [];

        return StreamBuilder<List<Transaction>>(
          stream: FirebaseService.getAllTransactionsStream(),
          builder: (context, transactionsSnapshot) {
            final transactions = transactionsSnapshot.data ?? [];

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
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
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
                                ),
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
                  SizedBox(
                    height: 500,
                    width: 500,
                    child: Calendar(highlightedDays: transactions),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsetsGeometry.only(left: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Last Orders",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
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
          },
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
