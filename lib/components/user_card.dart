import 'package:expenses_app/models/HiveService.dart';
import 'package:expenses_app/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserCard extends StatelessWidget {
  const UserCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(12),
      height: 300,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(22),
            height: 150,
            decoration: BoxDecoration(
              color: Color.fromRGBO(203, 229, 250, 1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "James Doe",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Icon(
                        Icons.more_horiz,
                        color: Provider.of<ThemeProvider>(
                          context,
                        ).themeData.colorScheme.onSurface,
                        size: 50,
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "**** **** **** 1234",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      Text(
                        "\$${HiveService.getCurrentMonthBudget()!.totalIncome}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(22),
            height: 150,
            decoration: BoxDecoration(
              color: Color.fromRGBO(46, 48, 52, 1),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Balance",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    "\$${HiveService.getCurrentMonthBudget()!.remainingBudget}",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total week profit"),
                      Text(
                        "${(HiveService.getCurrentMonthBudget()!.remainingBudget / HiveService.getCurrentMonthBudget()!.totalIncome * 100).toStringAsFixed(2)}%",
                        style: TextStyle(
                          color: Color.fromRGBO(106, 210, 146, 1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
