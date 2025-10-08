import 'package:flutter/material.dart';

class CardAdd extends StatelessWidget {
  final Color color;
  final Function()? onPressed;
  const CardAdd({super.key, required this.onPressed, required this.color});

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
        child: Image.asset(
          "assets/images/credit-card-add.png",
          width: 26,
          height: 26,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
