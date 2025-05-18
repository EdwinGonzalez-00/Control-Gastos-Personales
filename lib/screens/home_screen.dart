import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:control_gastos_personales/models/transaction.dart';
import 'package:control_gastos_personales/screens/add_transaction_screen.dart';
import 'package:control_gastos_personales/screens/statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  double get _incomeTotal => _transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get _expenseTotal => _transactions
      .where((t) => !t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  void _addNewTransaction(Transaction tx) {
    setState(() {
      _transactions.add(tx);
      _transactions.sort((a, b) => b.date.compareTo(b.date));
    });
    _saveTransactions();
  }

  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final txList = _transactions.map((tx) => tx.toMap()).toList();
    prefs.setString('transactions', jsonEncode(txList));
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('transactions');

    if (jsonString != null) {
      final List decoded = jsonDecode(jsonString);
      final loadedTxs = 
          decoded.map((tx) => Transaction.fromMap(tx)).toList();

      setState(() {
        _transactions
          ..clear()
          ..addAll(loadedTxs.cast<Transaction>());
        _transactions.sort((a, b) => b.date.compareTo(a.date));  
      });
    } else {
      setState(() => _transactions..addAll(sampleTransactions));
    }
    
  }


  void _showTxOptions(int index) {
    final tx = _transactions[index];

    showDialog(
      context: context,
      barrierColor: Colors.black45,
      builder: (_) => Dialog(
        backgroundColor: const Color.fromARGB(164, 244, 244, 246).withValues(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(tx.title,
              textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      final editedTx = await Navigator.push<Transaction>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddTransactionScreen(
                            transaction: tx,
                          ),
                        ),
                      );
                      if (editedTx != null) {
                        setState(() {
                          _transactions[index] = editedTx;
                        });
                        _saveTransactions();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Transacción actualizada')),
                        );
                      }
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Editar'),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      setState(() => _transactions.removeAt(index));
                      _saveTransactions();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Transacción eliminada')),
                      );
                    },
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Eliminar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();
    final DateFormat df = DateFormat('MMMM', 'es_ES');

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FD),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    offset: const Offset(0, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                'Control de Gastos',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  // Ingresos/Gastos
                  Expanded(
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Text(
                              'Ingresos: \$${_incomeTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Gastos: \$${_expenseTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Fecha actual
                  Expanded(
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Text(DateFormat.EEEE('es_ES').format(hoy),
                                style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold)),
                            Text('${hoy.day}',
                                style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold)),
                            Text(df.format(hoy),
                                style: const TextStyle(fontFamily: 'Montserrat')),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ╔═════ Lista de Transacciones ═════╗
            Expanded(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  itemCount: _transactions.length,
                  itemBuilder: (ctx, i) {
                    final tx = _transactions[i];
                    return GestureDetector(
                      onTap: () => _showTxOptions(i),
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        color: const Color(0xFFF9FAFE),
                        child: ListTile(
                          leading: Icon(
                            tx.isIncome
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: tx.isIncome ? Colors.green : Colors.red,
                          ),
                          title: Text(tx.title,
                              style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            '${DateFormat('dd/MM/yyyy').format(tx.date)} • ${tx.category}',
                            style: const TextStyle(fontFamily: 'Montserrat'),
                          ),
                          trailing: Text(
                            '\$${tx.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: tx.isIncome ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            Container(
              height: 8,
              width: double.infinity,
              color: Colors.blue,
              margin: const EdgeInsets.only(top: 6),
            ),
          ],
        ),
      ),

      // ╔═════ Menú Flotante SpeedDial ═════╗
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: Colors.blue,
        overlayOpacity: 0.1,
        spacing: 10,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add),
            label: 'Nueva',
            onTap: () async {
              final tx = await Navigator.push<Transaction>(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddTransactionScreen()),
              );
              if (tx != null) {
                _addNewTransaction(tx);
                _saveTransactions();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transacción añadida')),
                );
              }
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.bar_chart),
            label: 'Estadísticas',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      StatisticsScreen(transactions: _transactions),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}