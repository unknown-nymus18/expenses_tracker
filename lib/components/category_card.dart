import 'package:expenses_app/services/firebase_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String category;
  final double totalAmount;
  final double? used;
  final Color color;
  final List<double>? dailySpending; // Weekly spending data (last 6 weeks)

  const CategoryCard({
    super.key,
    required this.color,
    required this.totalAmount,
    required this.category,
    required this.used,
    this.dailySpending,
  });

  @override
  Widget build(BuildContext context) {
    void deleteCategory() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete Category'),
            content: Text('Are you sure you want to delete this category?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  FirebaseService.deleteCategoryByName(category);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Category deleted'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 40,
            spreadRadius: 0,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with icon and percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.trending_up, color: Colors.black, size: 20),
                  SizedBox(width: 8),
                  Text(
                    category,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      used == null || totalAmount == 0
                          ? '0%'
                          : '${((totalAmount - used!) / totalAmount) * 100}%',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 4),
                  GestureDetector(
                    onTap: deleteCategory,
                    child: Icon(
                      Icons.delete,
                      color: const Color.fromARGB(255, 173, 30, 20),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // SizedBox(height: 16),

          // Total Amount
          Text(
            '\$${totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            style: TextStyle(
              color: Colors.black,
              fontSize: 70,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "-\$${used!.toStringAsFixed(0)}",
            style: TextStyle(color: Colors.black),
          ),

          Spacer(),

          // Simple line chart representation
          SizedBox(
            height: 40,
            child: CustomPaint(
              painter: SimpleChartPainter(
                dataPoints: dailySpending ?? [],
                color: Colors.black,
              ),
              size: Size(double.infinity, 40),
            ),
          ),
        ],
      ),
    );
  }
}

class SimpleChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color color;

  SimpleChartPainter({required this.dataPoints, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Debug output
    print('Chart painting - DataPoints: $dataPoints, Size: $size');

    if (dataPoints.isEmpty || size.width <= 0 || size.height <= 0) {
      // If no data, draw a flat line
      final paint = Paint()
        ..color = color.withOpacity(0.3)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        paint,
      );
      return;
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Find max value for scaling
    final maxValue = dataPoints.reduce((a, b) => a > b ? a : b);
    final minValue = dataPoints.reduce((a, b) => a < b ? a : b);

    print('Max: $maxValue, Min: $minValue');

    if (maxValue == 0) {
      // If all values are zero, draw a flat line at bottom
      final flatLinePaint = Paint()
        ..color = color.withOpacity(0.3)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(0, size.height - 5),
        Offset(size.width, size.height - 5),
        flatLinePaint,
      );
      print('All values are zero - drawing flat line');
      return;
    }

    // If all values are the same (but not zero), use a small range for visualization
    final valueRange = maxValue - minValue;
    final useFullScale = valueRange > 0;

    final path = Path();
    final pointSpacing = dataPoints.length > 1
        ? size.width / (dataPoints.length - 1)
        : size.width / 2;

    // Create path from real data points
    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * pointSpacing;

      double normalizedValue;
      if (useFullScale) {
        // Use the range of values for better visualization
        normalizedValue = (dataPoints[i] - minValue) / valueRange;
      } else {
        // All values are the same - draw in middle
        normalizedValue = 0.5;
      }

      final y = size.height - (normalizedValue * (size.height - 10)) - 5;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw dots at each data point
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * pointSpacing;

      double normalizedValue;
      if (useFullScale) {
        normalizedValue = (dataPoints[i] - minValue) / valueRange;
      } else {
        normalizedValue = 0.5;
      }

      final y = size.height - (normalizedValue * (size.height - 10)) - 5;
      canvas.drawCircle(Offset(x, y), 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(SimpleChartPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints || oldDelegate.color != color;
  }
}
