import 'dart:ui';
import 'package:expenses_app/components/transaction_tile.dart';
import 'package:expenses_app/models/transaction.dart';
import 'package:expenses_app/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionDetails extends StatelessWidget {
  final List<Transaction> transactions;
  const TransactionDetails({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode();

    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
        elevation: 0,
        centerTitle: true,
      ),
      body: transactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: themeProvider.themeData.colorScheme.primary
                        .withOpacity(0.3),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No Transactions Today",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: themeProvider.themeData.colorScheme.onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Your transactions will appear here",
                    style: TextStyle(
                      fontSize: 14,
                      color: themeProvider.themeData.colorScheme.onSurface
                          .withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, i) {
                return TransactionTile(
                  transaction: transactions[i],
                  isDark: isDark,
                  colorScheme: themeProvider.themeData.colorScheme,
                );
              },
            ),
    );
  }
}
