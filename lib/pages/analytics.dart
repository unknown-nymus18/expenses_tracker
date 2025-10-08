import 'package:expenses_app/components/functions.dart';
import 'package:expenses_app/components/labeled_chart.dart';
import 'package:expenses_app/models/HiveService.dart';
import 'package:expenses_app/models/budget_category.dart';
import 'package:expenses_app/models/monthly_budget.dart';
import 'package:expenses_app/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:expenses_app/components/donut_chart.dart';
import 'package:provider/provider.dart';

class Analytics extends StatefulWidget {
  const Analytics({super.key});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  ScrollController controller = ScrollController();
  List<BudgetCategory> budget = [];

  @override
  void initState() {
    super.initState();
    onScroll(controller, context);
    _loadBudgetData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when returning to this page
    _loadBudgetData();
  }

  void _loadBudgetData() {
    try {
      budget = HiveService.getAllMonthlyCategories();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      budget = [];
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    segments.add(
      ChartSegment(
        value: HiveService.amountLeftInBudget,
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
                    LabeledChart(segment: segment, totalAmount: totalAmount),
                ],
              ),
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
            SizedBox(height: 30),

            ...List.generate(
              50,
              (index) => ListTile(
                title: Text(
                  'Item $index',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
