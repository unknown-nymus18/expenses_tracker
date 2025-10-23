import 'dart:ui';
import 'package:expenses_app/components/card_add.dart';
import 'package:expenses_app/components/functions.dart';
import 'package:expenses_app/components/order_tile.dart';
import 'package:expenses_app/components/user_card.dart';
import 'package:expenses_app/services/firebase_service.dart';
import 'package:expenses_app/models/transaction.dart';
import 'package:expenses_app/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Transactions extends StatefulWidget {
  const Transactions({super.key});

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  ScrollController controller = ScrollController();
  String? selectedCategoryId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    onScroll(controller, context);
  }

  void addIncome() {
    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: AlertDialog(
            title: Text('Add Income'),
            content: TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'Enter amount'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
              TextButton(
                onPressed: () async {
                  if (amountController.text.isNotEmpty) {
                    try {
                      double amount = double.parse(amountController.text);
                      await FirebaseService.addMonthlyIncome(amount);
                      Navigator.pop(context);
                      setState(() {});
                    } catch (e) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter a valid number')),
                      );
                    }
                  }
                },
                child: Text('Add income'),
              ),
            ],
          ),
        );
      },
    );
    setState(() {});
  }

  void addTransaction() {
    TextEditingController amountController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    selectedCategoryId = null;

    showDialog(
      context: context,
      builder: (context) {
        return StreamBuilder(
          stream: FirebaseService.getCurrentMonthBudgetStream(),
          builder: (context, budgetSnapshot) {
            final categories = budgetSnapshot.data?.categories ?? [];

            return StatefulBuilder(
              builder: (context, setDialogState) {
                return BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: AlertDialog(
                    title: Text('Add Transaction'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(hintText: 'Name'),
                        ),
                        TextField(
                          controller: amountController,
                          decoration: InputDecoration(hintText: 'Amount'),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: descriptionController,
                          decoration: InputDecoration(hintText: 'Description'),
                        ),
                        SizedBox(height: 10),
                        DropdownButton<String>(
                          hint: Text('Select Category'),
                          value: selectedCategoryId,
                          isExpanded: true,
                          items: categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category.id,
                              child: Text(category.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedCategoryId = value;
                            });
                          },
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Close'),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (amountController.text.isNotEmpty &&
                              descriptionController.text.isNotEmpty &&
                              selectedCategoryId != null &&
                              nameController.text.isNotEmpty) {
                            final result =
                                await FirebaseService.makeTransaction(
                                  Transaction(
                                    id: DateTime.now().millisecondsSinceEpoch
                                        .toString(),
                                    title: nameController.text,
                                    amount: amountController.text,
                                    category: selectedCategoryId!,
                                    createdAt: DateTime.now(),
                                    description: descriptionController.text,
                                  ),
                                );

                            Navigator.of(context).pop();

                            if (result['success']) {
                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['message']),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              setState(() {});
                            } else {
                              // Show budget warning/error
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    result['needsBudget'] == true
                                        ? 'Budget Required'
                                        : 'Budget Warning',
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(result['message']),
                                      if (result['needsBudget'] == true) ...[
                                        SizedBox(height: 10),
                                        Text(
                                          'Go to the Budgeting page to set a budget for ${result['category']} category.',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  actions: [
                                    if (result['needsBudget'] == true)
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          // Navigate to budgeting page
                                          // You might want to use your navigation logic here
                                        },
                                        child: Text('Set Budget'),
                                      ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please fill all fields'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: Text('Add Transaction'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      child: Column(
        children: [
          SizedBox(height: 50),
          Row(
            children: [
              Expanded(child: UserCard()),
              Column(
                spacing: 10,
                children: [
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: BoxBorder.all(
                        width: 2,
                        color: Provider.of<ThemeProvider>(
                          context,
                        ).themeData.colorScheme.primary,
                      ),
                    ),
                    child: IconButton(
                      onPressed: addTransaction,
                      icon: Icon(Icons.add),
                    ),
                  ),
                  CardAdd(
                    color: Color.fromRGBO(210, 249, 231, 1),
                    onPressed: addIncome,
                  ),
                  CardAdd(
                    color: Color.fromRGBO(255, 215, 142, 1),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Transactions",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          StreamBuilder<List<Transaction>>(
            stream: FirebaseService.getAllTransactionsStream(),
            builder: (context, snapshot) {
              final transactions = snapshot.data ?? [];

              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              if (transactions.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      'No transactions yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              return Column(
                children: List.generate(transactions.length, (index) {
                  final Transaction transaction = transactions[index];
                  return OrderTile(
                    onLongPress: () async {
                      await FirebaseService.deleteTransaction(transaction.id);
                    },
                    orderName: transaction.title,
                    price: transaction.amount.isEmpty
                        ? 0
                        : double.tryParse(transaction.amount) ?? 0,
                    date: transaction.createdAt,
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}
