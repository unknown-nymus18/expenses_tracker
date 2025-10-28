import 'package:expenses_app/components/functions.dart';
import 'package:expenses_app/components/labeled_chart.dart';
import 'package:expenses_app/components/line_chart.dart';
import 'package:expenses_app/components/loading_screen.dart';
import 'package:expenses_app/services/firebase_service.dart';
import 'package:expenses_app/models/monthly_budget.dart';
import 'package:expenses_app/models/transaction.dart' as models;
import 'package:expenses_app/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:expenses_app/components/donut_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class Analytics extends StatefulWidget {
  const Analytics({super.key});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    onScroll(controller, context);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MonthlyBudget?>(
      stream: FirebaseService.getCurrentMonthBudgetStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Analytics", style: TextStyle(color: Colors.white)),
              elevation: 0,
            ),
            body: Center(child: LoadingScreen()),
          );
        }

        final monthlyBudget = snapshot.data;
        final budget = monthlyBudget?.categories ?? [];

        if (budget.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Analytics", style: TextStyle(color: Colors.white)),
              elevation: 0,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No budget data available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add some budget categories to see analytics',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        final List<ChartSegment> segments = budget
            .where(
              (category) => category.spent >= 0,
            ) // Only include categories with spending
            .map(
              (category) => ChartSegment(
                value: category.budgetAmount,
                color: category.color,
                label: category.name,
              ),
            )
            .toList();

        final double totalBudgeted = budget.fold<double>(
          0,
          (sum, category) => sum + category.budgetAmount,
        );
        final double amountLeft =
            (monthlyBudget?.totalIncome ?? 0.0) - totalBudgeted;

        segments.add(
          ChartSegment(
            value: amountLeft > 0 ? amountLeft : 0,
            color: Colors.grey,
            label: "Amount left",
          ),
        );

        final double totalAmount = segments.fold(
          0,
          (sum, segment) => sum + segment.value,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text("Analytics", style: TextStyle(color: Colors.white)),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            controller: controller,
            child: Column(
              children: [
                SizedBox(height: 20),
                DonutChart(
                  totalAmount: totalAmount,
                  growthPercentage: '26%',
                  segments: segments,
                ),
                SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 14,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (var segment in segments)
                        LabeledChart(
                          segment: segment,
                          totalAmount: totalAmount,
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 25),

                // Line Chart for spending trends
                StreamBuilder<List<models.Transaction>>(
                  stream: FirebaseService.getCurrentMonthTransactionsStream(),
                  builder: (context, transactionSnapshot) {
                    if (!transactionSnapshot.hasData) {
                      return SizedBox.shrink();
                    }

                    final transactions = transactionSnapshot.data!;

                    // Group transactions by day and calculate daily spending
                    final Map<String, double> dailySpending = {};
                    for (var transaction in transactions) {
                      final dateKey = DateFormat(
                        'MMM dd',
                      ).format(transaction.createdAt);
                      dailySpending[dateKey] =
                          (dailySpending[dateKey] ?? 0) + transaction.amount;
                    }

                    // Get last 7 days of data
                    final now = DateTime.now();
                    final List<ChartDataPoint> chartData = [];
                    for (int i = 6; i >= 0; i--) {
                      final date = now.subtract(Duration(days: i));
                      final dateKey = DateFormat('MMM dd').format(date);
                      final dayLabel = DateFormat('EEE').format(date);
                      final spending = dailySpending[dateKey] ?? 0.0;
                      chartData.add(
                        ChartDataPoint(label: dayLabel, value: spending),
                      );
                    }

                    return SpendingLineChart(
                      dataPoints: chartData,
                      title: 'Weekly Spending Trend',
                    );
                  },
                ),
                SizedBox(height: 25),

                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Provider.of<ThemeProvider>(
                      context,
                    ).themeData.colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Breakdown',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      ...segments.map(
                        (segment) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: segment.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  segment.label,
                                  style: TextStyle(
                                    color: Provider.of<ThemeProvider>(
                                      context,
                                    ).themeData.colorScheme.onSurface,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Text(
                                '\$${segment.value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                style: TextStyle(
                                  color: Provider.of<ThemeProvider>(
                                    context,
                                  ).themeData.colorScheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 120),
              ],
            ),
          ),
        );
      },
    );
  }
}
