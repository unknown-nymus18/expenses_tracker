import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';

class DonutChart extends StatelessWidget {
  final double totalAmount;
  final String growthPercentage;
  final List<ChartSegment> segments;

  const DonutChart({
    super.key,
    required this.totalAmount,
    required this.growthPercentage,
    required this.segments,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(20),
      child: Stack(
        children: [
          // Chart without container shadow
          Center(
            child: Container(
              width: 300,
              height: 300,
              child: CustomPaint(painter: DonutChartPainter(segments)),
            ),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '\$${totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ..._buildDynamicLabels(),
        ],
      ),
    );
  }

  List<Widget> _buildDynamicLabels() {
    final List<Widget> labels = [];

    double total = segments.fold(0, (sum, segment) => sum + segment.value);
    if (total <= 0) return labels;

    double startAngle = -math.pi / 2;
    final gapAngle = 0.02;
    final chartCenter = Offset(150, 150);
    final labelRadius = 120;

    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final proportion = segment.value / total;
      final sweepAngle = (proportion * 2 * math.pi) - gapAngle;

      if (sweepAngle > 0.01) {
        final middleAngle = startAngle + sweepAngle / 2;

        final labelX = chartCenter.dx + labelRadius * math.cos(middleAngle);
        final labelY = chartCenter.dy + labelRadius * math.sin(middleAngle);

        labels.add(
          Positioned(
            left: labelX - 30,
            top: labelY - 15,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: segment.color, width: 1),
                  ),
                  child: Text(
                    '\$${segment.value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }

      startAngle += sweepAngle + gapAngle;
    }

    return labels;
  }
}

class ChartSegment {
  final double value;
  final Color color;
  final String label;

  ChartSegment({required this.value, required this.color, required this.label});
}

class DonutChartPainter extends CustomPainter {
  final List<ChartSegment> segments;

  DonutChartPainter(this.segments);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    final innerRadius = radius * 0.6;

    double total = segments.fold(0, (sum, segment) => sum + segment.value);

    if (total <= 0) return;

    double startAngle = -math.pi / 2;
    final gapAngle = 0.02;

    // First pass: Draw shadow for each segment
    double shadowStartAngle = -math.pi / 2;
    for (var segment in segments) {
      final proportion = segment.value / total;
      final sweepAngle = (proportion * 2 * math.pi) - gapAngle;

      if (sweepAngle > 0.01) {
        // Create shadow paint
        final shadowPaint = Paint()
          ..color = Colors.black.withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius - innerRadius
          ..strokeCap = StrokeCap.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8.0);

        // Draw shadow arc slightly offset
        canvas.drawArc(
          Rect.fromCircle(
            center: Offset(center.dx + 3, center.dy + 5), // Offset for shadow
            radius: innerRadius + (radius - innerRadius) / 2,
          ),
          shadowStartAngle,
          sweepAngle,
          false,
          shadowPaint,
        );
      }

      shadowStartAngle += sweepAngle + gapAngle;
    }

    // Second pass: Draw actual segments on top
    startAngle = -math.pi / 2;
    for (var segment in segments) {
      final proportion = segment.value / total;
      final sweepAngle = (proportion * 2 * math.pi) - gapAngle;

      if (sweepAngle > 0.01) {
        final paint = Paint()
          ..color = segment.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius - innerRadius
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(
          Rect.fromCircle(
            center: center,
            radius: innerRadius + (radius - innerRadius) / 2,
          ),
          startAngle,
          sweepAngle,
          false,
          paint,
        );
      }

      startAngle += sweepAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
