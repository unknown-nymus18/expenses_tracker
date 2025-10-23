import 'package:flutter/material.dart';
import 'package:expenses_app/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class SpendingLineChart extends StatelessWidget {
  final List<ChartDataPoint> dataPoints;
  final String title;

  const SpendingLineChart({
    super.key,
    required this.dataPoints,
    this.title = 'Spending Trend',
  });

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Provider.of<ThemeProvider>(
            context,
          ).themeData.colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No spending data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final maxValue = dataPoints
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);
    final minValue = dataPoints
        .map((e) => e.value)
        .reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;
    final adjustedMax = range == 0 ? maxValue + 100 : maxValue;
    final double adjustedMin = range == 0
        ? 0.0
        : (minValue - range * 0.1).clamp(0.0, double.infinity);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Provider.of<ThemeProvider>(
          context,
        ).themeData.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Provider.of<ThemeProvider>(
                context,
              ).themeData.colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: CustomPaint(
              size: Size(double.infinity, 200),
              painter: LineChartPainter(
                dataPoints: dataPoints,
                maxValue: adjustedMax,
                minValue: adjustedMin,
                lineColor: Provider.of<ThemeProvider>(
                  context,
                ).themeData.colorScheme.primary,
                gridColor: Provider.of<ThemeProvider>(
                  context,
                ).themeData.colorScheme.onSurface.withOpacity(0.1),
                textColor: Provider.of<ThemeProvider>(
                  context,
                ).themeData.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChartDataPoint {
  final String label;
  final double value;

  ChartDataPoint({required this.label, required this.value});
}

class LineChartPainter extends CustomPainter {
  final List<ChartDataPoint> dataPoints;
  final double maxValue;
  final double minValue;
  final Color lineColor;
  final Color gridColor;
  final Color textColor;

  LineChartPainter({
    required this.dataPoints,
    required this.maxValue,
    required this.minValue,
    required this.lineColor,
    required this.gridColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = lineColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Draw horizontal grid lines
    final gridLineCount = 5;
    for (int i = 0; i <= gridLineCount; i++) {
      final y = size.height * i / gridLineCount;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);

      // Draw Y-axis labels
      final value = maxValue - (maxValue - minValue) * i / gridLineCount;
      textPainter.text = TextSpan(
        text: '\$${value.toStringAsFixed(0)}',
        style: TextStyle(color: textColor, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(-textPainter.width - 5, y - textPainter.height / 2),
      );
    }

    final path = Path();
    final fillPath = Path();
    final spacing = size.width / (dataPoints.length - 1);

    // Calculate points
    final points = <Offset>[];
    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * spacing;
      final normalizedValue =
          (dataPoints[i].value - minValue) / (maxValue - minValue);
      final y = size.height - (normalizedValue * size.height);
      points.add(Offset(x, y));
    }

    // Draw line
    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      fillPath.moveTo(points.first.dx, size.height);
      fillPath.lineTo(points.first.dx, points.first.dy);

      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
        fillPath.lineTo(points[i].dx, points[i].dy);
      }

      // Complete fill path
      fillPath.lineTo(points.last.dx, size.height);
      fillPath.close();

      // Draw gradient fill
      canvas.drawPath(fillPath, fillPaint);

      // Draw line
      canvas.drawPath(path, paint);

      // Draw dots and labels
      for (int i = 0; i < points.length; i++) {
        // Draw dot
        canvas.drawCircle(points[i], 5, dotPaint);
        canvas.drawCircle(points[i], 3, Paint()..color = Colors.white);

        // Draw X-axis labels
        textPainter.text = TextSpan(
          text: dataPoints[i].label,
          style: TextStyle(color: textColor, fontSize: 11),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(points[i].dx - textPainter.width / 2, size.height + 10),
        );
      }
    }
  }

  @override
  bool shouldRepaint(LineChartPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.minValue != minValue;
  }
}
