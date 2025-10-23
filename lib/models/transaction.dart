class Transaction {
  String id;
  String title;
  String amount;
  String category;
  DateTime createdAt;
  String? description;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.createdAt,
    this.description,
  });
}
