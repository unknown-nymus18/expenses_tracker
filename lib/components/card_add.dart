import 'package:flutter/material.dart';

class CardAdd extends StatelessWidget {
  final Color color;
  final Function()? onPressed;
  final String text;
  const CardAdd({
    super.key,
    required this.onPressed,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(25),
      margin: EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/images/credit-card-add.png",
              width: 26,
              height: 26,
            ),
            SizedBox(height: 8),
            Column(
              children: [
                for (var line in text.split(' '))
                  Text(
                    line,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
