import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:control_gastos_personales/models/transaction.dart';
import 'package:control_gastos_personales/styles/text_style.dart';
import 'package:control_gastos_personales/widgets/build_stat_card.dart';

class StatisticsScreen extends StatefulWidget {
  final List<Transaction> transactions;
  const StatisticsScreen({super.key, required this.transactions});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late DateTime _selectedMonth;
  double _incomeTotal = 0;
  double _expenseTotal = 0;
  Map<String, List<Transaction>> subcategoryGroups = {};

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _calculateTotals();
  }

  void _calculateTotals() {
    final m = _selectedMonth.month;
    final y = _selectedMonth.year;

    final monthTx = widget.transactions.where(
      (tx) => tx.date.month == m && tx.date.year == y,
    ).toList();

    _incomeTotal = monthTx.where((tx) => tx.isIncome).fold(0.0, (s, tx) => s + tx.amount);
    _expenseTotal = monthTx.where((tx) => !tx.isIncome).fold(0.0, (s, tx) => s + tx.amount);

    setState(() {
      subcategoryGroups = groupBy(monthTx, (tx) => tx.category);
    });
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
      helpText: 'Selecciona mes',
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
        _calculateTotals();
      });
    }
  }

  double _maxAmount() {
    if (subcategoryGroups.isEmpty) return 0;
    return subcategoryGroups.values
            .map((txList) => txList.fold(0.0, (sum, tx) => sum + tx.amount))
            .fold<double>(0.0, (prev, amount) => amount > prev ? amount : prev) *
        1.2;
  }

  Widget _getCategoryTitle(double value, TitleMeta meta) {
    final keys = subcategoryGroups.keys.toList();
    if (value.toInt() < 0 || value.toInt() >= keys.length) {
      return const SizedBox.shrink();
    }
    final category = keys[value.toInt()];
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        category,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 10,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxY = _maxAmount();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FD),
      appBar: AppBar(
        title: const Text('Estadísticas', style: AppTextStyles.tituloPantalla),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            tooltip: 'Cambiar mes',
            icon: const Icon(Icons.date_range_rounded),
            onPressed: _pickMonth,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.bar_chart, color: Colors.black87),
                SizedBox(width: 6),
                Text(
                  'Transacciones del mes',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Verifica si hay datos
            if (subcategoryGroups.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bar_chart, size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'Sin transacciones este mes',
                        style: TextStyle(fontSize: 16, fontFamily: 'Montserrat'),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              SizedBox(
                height: 260,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: subcategoryGroups.length * 80,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceBetween,
                        maxY: maxY,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: _getCategoryTitle,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: false),
                        barGroups: _buildBarGroups(),   
                        ),
                      ),
                    ),
                  ),
                ),
                
              const SizedBox(height: 24),

              // Tarjetas de resumen
              Row(
                children: [
                  buildStatCard(
                    label: 'Ingresos',
                    amount: _incomeTotal,
                    color: Colors.green,
                    bgColor: Colors.green[100]!,
                  ),
                  const SizedBox(width: 12),
                  buildStatCard(
                    label: 'Gastos',
                    amount: _expenseTotal,
                    color: Colors.red,
                    bgColor: Colors.red[100]!,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Lista de categorías
              Expanded(
                child: ListView(
                  children: subcategoryGroups.entries.map((entry) {
                    final subcategory = entry.key;
                    final total = entry.value.fold(0.0, (sum, tx) => sum + tx.amount);
                    final isIncome = entry.value.first.isIncome;

                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: isIncome ? Colors.green[50] : Colors.red[50],
                      child: ListTile(
                        leading: Icon(
                          isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                          color: isIncome ? Colors.green : Colors.red,
                        ),
                        title: Text(
                          subcategory,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: isIncome ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    final keys = subcategoryGroups.keys.toList();
    return List.generate(keys.length, (index) {
      final txList = subcategoryGroups[keys[index]]!;
      final total = txList.fold(0.0, (sum, tx) => sum + tx.amount);
      final isIncome = txList.first.isIncome;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: total,
            width: 22,
            borderRadius: BorderRadius.circular(6),
            color: isIncome ? Colors.green : Colors.redAccent,
            gradient: LinearGradient(
              colors: isIncome
                  ? [Colors.green.shade400, Colors.green.shade700]
                  : [Colors.red.shade300, Colors.red.shade600],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ],
      );
    });
  }
}
