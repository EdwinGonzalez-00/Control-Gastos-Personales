class Transaction {
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final bool isIncome;

  Transaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.isIncome,
  });
}