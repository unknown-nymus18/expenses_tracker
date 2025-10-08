import 'package:expenses_app/components/donut_chart.dart';
import 'package:expenses_app/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LabeledChart extends StatelessWidget {
  final ChartSegment segment;
  final double totalAmount;
  const LabeledChart({
    super.key,
    required this.segment,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate percentage safely to avoid NaN
    final double percentage = totalAmount > 0
        ? (segment.value / totalAmount * 100)
        : 0;
    final double barWidth = totalAmount > 0
        ? (segment.value / totalAmount) * 100
        : 0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            segment.label,
            style: TextStyle(
              color: Provider.of<ThemeProvider>(
                context,
              ).themeData.colorScheme.onSurface,
              fontSize: 18,
            ),
          ),
          Text(
            "${percentage.toStringAsFixed(0)}%",
            style: TextStyle(fontSize: 25),
          ),
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  // color: segment.color,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Provider.of<ThemeProvider>(
                      context,
                    ).themeData.colorScheme.onSurface,
                    width: 1,
                  ),
                ),
                height: 10,
                width: 100,
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 500),
                width: barWidth.clamp(0.0, 100.0), // Clamp to prevent overflow
                height: 10,
                decoration: BoxDecoration(
                  color: segment.color,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
