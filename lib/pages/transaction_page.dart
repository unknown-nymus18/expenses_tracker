import 'package:expenses_app/models/transaction.dart';
import 'package:flutter/material.dart';

class TransactionDetails extends StatelessWidget {
  final List<Transaction> transactions;
  const TransactionDetails({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Hero(
        tag: 'transaction-page',
        child: Center(child: Column(children: [Text("Transaction Page")])),
      ),
    );
  }
}
