import 'dart:ui';
import 'package:expenses_app/models/transaction.dart';
import 'package:expenses_app/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final bool isDark;
  final ColorScheme colorScheme;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.isDark,
    required this.colorScheme,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'entertainment':
        return Icons.movie;
      case 'shopping':
        return Icons.shopping_bag;
      case 'bills':
        return Icons.receipt;
      case 'health':
        return Icons.medical_services;
      case 'education':
        return Icons.school;
      case 'housing':
        return Icons.home;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Color.fromRGBO(170, 205, 186, 1); // Green
      case 'transport':
        return Color.fromRGBO(248, 210, 209, 1); // Pink
      case 'entertainment':
        return Color.fromRGBO(255, 215, 142, 1); // Yellow
      case 'savings':
        return Color.fromRGBO(104, 108, 72, 1); // Olive
      case 'bills':
        return Colors.red.shade400;
      case 'health':
        return Colors.teal.shade400;
      case 'education':
        return Colors.indigo.shade400;
      case 'housing':
        return Colors.brown.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(transaction.category);
    final amount = double.tryParse(transaction.amount) ?? 0.0;
    final formattedAmount = '\$${amount.toStringAsFixed(2)}';
    final date = transaction.createdAt;
    final formattedDate = DateFormat('MMM dd, yyyy').format(date);
    final formattedTime = DateFormat('hh:mm a').format(date);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  // Show transaction details
                  _showTransactionDetails(context);
                },
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Category Icon
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _getCategoryIcon(transaction.category),
                          color: categoryColor,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 16),

                      // Transaction Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              transaction.category,
                              style: TextStyle(
                                fontSize: 13,
                                color: categoryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (transaction.description?.isNotEmpty ??
                                false) ...[
                              SizedBox(height: 4),
                              Text(
                                transaction.description ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface.withOpacity(0.5),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: colorScheme.onSurface.withOpacity(0.4),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '$formattedDate • $formattedTime',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colorScheme.onSurface.withOpacity(
                                      0.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Amount
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            formattedAmount,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Expense',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: categoryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTransactionDetails(BuildContext context) {
    final amount = double.tryParse(transaction.amount) ?? 0.0;
    final formattedAmount = '\$${amount.toStringAsFixed(2)}';
    final date = transaction.createdAt;
    final formattedDate = DateFormat('EEEE, MMMM dd, yyyy').format(date);
    final formattedTime = DateFormat('hh:mm a').format(date);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Category Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(
                      transaction.category,
                    ).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _getCategoryIcon(transaction.category),
                    color: _getCategoryColor(transaction.category),
                    size: 40,
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Amount
              Center(
                child: Text(
                  formattedAmount,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),

              SizedBox(height: 8),

              // Title
              Center(
                child: Text(
                  transaction.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 24),
              Divider(),
              SizedBox(height: 16),

              // Details
              _buildDetailRow(
                icon: Icons.category,
                label: 'Category',
                value: transaction.category,
              ),
              SizedBox(height: 16),
              _buildDetailRow(
                icon: Icons.calendar_today,
                label: 'Date',
                value: formattedDate,
              ),
              SizedBox(height: 16),
              _buildDetailRow(
                icon: Icons.access_time,
                label: 'Time',
                value: formattedTime,
              ),

              if (transaction.description?.isNotEmpty ?? false) ...[
                SizedBox(height: 16),
                _buildDetailRow(
                  icon: Icons.description,
                  label: 'Description',
                  value: transaction.description ?? '',
                ),
              ],

              SizedBox(height: 24),

              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colorScheme.onSurface.withOpacity(0.6)),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
