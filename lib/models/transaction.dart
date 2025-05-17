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

  Map<String, dynamic> toMap() {
    return {
      'tittle': title,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'isIncome': isIncome,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      title: map['title'],
      category: map['category'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      isIncome: map['isIncome'],
    );
  }

}

final List<Transaction> sampleTransactions = [
  Transaction(
    title: 'Supermercado',
    amount: 45.90,
    date: DateTime.now().subtract(const Duration(days: 1)),
    category: 'Alimentos',
    isIncome: false,
  ),
  Transaction(
    title: 'Sueldo',
    amount: 1200.00,
    date: DateTime.now().subtract(const Duration(days: 3)),
    category: 'Trabajo',
    isIncome: true,
  ),
  Transaction(
    title: 'Cine',
    amount: 20.00,
    date: DateTime.now().subtract(const Duration(days: 2)),
    category: 'Entretenimiento',
    isIncome: false,
  ),
];
