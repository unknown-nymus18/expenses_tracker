import 'dart:ui';
import 'package:expenses_app/components/card_add.dart';
import 'package:expenses_app/components/functions.dart';
import 'package:expenses_app/components/loading_screen.dart';
import 'package:expenses_app/components/transaction_tile.dart';
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

  DateTime? filterDate;
  double? filterPrice;

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
                            // Parse amount as double
                            final amount = double.tryParse(
                              amountController.text,
                            );
                            if (amount == null || amount <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please enter a valid amount'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            final result =
                                await FirebaseService.makeTransaction(
                                  Transaction(
                                    id: DateTime.now().millisecondsSinceEpoch
                                        .toString(),
                                    title: nameController.text,
                                    amount: amount,
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

  void _selectDate() async {
    filterDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Provider.of<ThemeProvider>(context).isDarkMode()
                  ? Colors.grey[900]!
                  : Colors.grey[500]!,
              onPrimary: Provider.of<ThemeProvider>(context).isDarkMode()
                  ? Colors.black
                  : Colors.white,
              surface: Provider.of<ThemeProvider>(context).isDarkMode()
                  ? Colors.grey[700]!
                  : Colors.grey[200]!,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Provider.of<ThemeProvider>(
              context,
            ).themeData.scaffoldBackgroundColor,
          ),
          child: child!,
        );
      },
    );

    filter();
  }

  void _selectPrice() async {
    TextEditingController priceController = TextEditingController();
    priceController.text = filterPrice?.toString() ?? '';
    filterPrice = await showDialog<double>(
      context: context,
      builder: (context) {
        double? selectedPrice;
        return AlertDialog(
          title: Text('Select Price'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter minimum price:'),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  selectedPrice = double.tryParse(value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(selectedPrice);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
    filter();
  }

  void filter() {
    if (filterDate != null || filterPrice != null) {
      setState(() {});
    }
  }

  void showFilterDialogue() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Date Filter", style: TextStyle(fontSize: 24)),
              SizedBox(height: 20),
              MaterialButton(
                onPressed: _selectDate,
                color: Provider.of<ThemeProvider>(
                  context,
                ).themeData.colorScheme.primary,
                child: Text('Select Date'),
              ),
              SizedBox(height: 20),
              Text("Price Filter", style: TextStyle(fontSize: 24)),
              SizedBox(height: 20),
              MaterialButton(
                onPressed: _selectPrice,
                color: Provider.of<ThemeProvider>(
                  context,
                ).themeData.colorScheme.primary,
                child: Text('Select Minimum Price'),
              ),
              SizedBox(height: 20),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {});
              },
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () {
                filterDate = null;
                filterPrice = null;
                Navigator.of(context).pop();
                setState(() {});
              },
              child: Text('Clear Filters'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode();
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
                  GestureDetector(
                    onTap: addTransaction,
                    child: Container(
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
                      child: Column(
                        children: [
                          Icon(Icons.add),
                          Text("Add"),
                          Text("Transaction"),
                        ],
                      ),
                    ),
                  ),
                  CardAdd(
                    color: Color.fromRGBO(210, 249, 231, 1),
                    onPressed: addIncome,
                    text: "Add Income",
                  ),
                  // CardAdd(
                  //   color: Color.fromRGBO(255, 215, 142, 1),
                  //   onPressed: () {},
                  //   text: "Add Expense",
                  // ),
                ],
              ),
            ],
          ),
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Transactions",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: showFilterDialogue,
                    child: Row(
                      children: [
                        Text("Filter"),
                        SizedBox(width: 10),
                        Icon(Icons.filter_list),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          filterDate != null || filterPrice != null
              ? StreamBuilder<List<Transaction>>(
                  stream: FirebaseService.getFilteredTransactionsStream(
                    date: filterDate,
                    minPrice: filterPrice,
                  ),
                  builder: (context, snapshot) {
                    final transactions = snapshot.data ?? [];

                    if (snapshot.hasError) {
                      return Center(child: Text('Error loading transactions'));
                    }

                    if (!snapshot.hasData) {
                      return Center(child: LoadingScreen());
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
                      children: [
                        for (var transaction in transactions)
                          Padding(
                            padding: EdgeInsetsGeometry.all(12),
                            child: TransactionTile(
                              transaction: transaction,
                              isDark: isDark,
                              colorScheme: themeProvider.themeData.colorScheme,
                            ),
                          ),

                        ...[SizedBox(height: 120)],
                      ],
                    );
                  },
                )
              : StreamBuilder<List<Transaction>>(
                  stream: FirebaseService.getAllTransactionsStream(),
                  builder: (context, snapshot) {
                    final transactions = snapshot.data ?? [];

                    if (snapshot.hasError) {
                      return Center(child: Text('Error loading transactions'));
                    }

                    if (!snapshot.hasData) {
                      return Center(child: LoadingScreen());
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
                      children: [
                        for (var transaction in transactions)
                          Padding(
                            padding: EdgeInsetsGeometry.all(12),
                            child: TransactionTile(
                              transaction: transaction,
                              isDark: isDark,
                              colorScheme: themeProvider.themeData.colorScheme,
                            ),
                          ),

                        ...[SizedBox(height: 120)],
                      ],
                    );
                  },
                ),
        ],
      ),
    );
  }
}
