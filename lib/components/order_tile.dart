import 'package:expenses_app/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderTile extends StatelessWidget {
  final String orderName;
  final double price;
  final DateTime date;

  final Function()? onLongPress;
  const OrderTile({
    super.key,
    required this.orderName,
    required this.price,
    required this.date,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.only(left: 12, right: 12, bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Provider.of<ThemeProvider>(
            context,
          ).themeData.colorScheme.primary,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: Colors.red),
                SizedBox(width: 12),
                Text(orderName),
              ],
            ),
            Text(price.toString()),
          ],
        ),
      ),
    );
  }
}
