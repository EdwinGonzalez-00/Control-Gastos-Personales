import 'package:control_gastos_personales/models/transaction.dart';

final List<Transaction> sampleTransactions = [
  Transaction(
    title: 'Supermercado',
    amount: 45.99,
    date: DateTime.now().subtract(const Duration(days: 1)),
    category: 'Comida',
    isIncome: false,
  ),
  Transaction(
    title: 'Sueldo', 
    amount: 1500.00, 
    date: DateTime.now().subtract(const Duration(days: 2)), 
    category: 'Trabajo', 
    isIncome: true,
  ),
  Transaction(
    title: 'Netflix', 
    amount: 13.99, 
    date: DateTime.now().subtract(const Duration(days: 3)), 
    category: 'Entretenimiento', 
    isIncome: false
    ),
];