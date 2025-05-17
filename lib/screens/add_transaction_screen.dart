import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../styles/text_style.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction;
  const AddTransactionScreen({super.key, this.transaction});

//class AddTransactionScreen extends StatelessWidget {
 // final Transaction? transaction;

  //const AddTransactionScreen({Key? key, this.transaction}) : super(key: key);



  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedType = 'Ingreso';

  Future<void> _presentDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tienes que seleccionar una fecha')),
      );
      return;
    }

    final isIncome = _selectedType == 'Ingreso';

    final newTx = Transaction(
      title: _titleController.text.trim(),
      category: _categoryController.text.trim().isEmpty
          ? _selectedType
          : _categoryController.text.trim(),
      amount: double.parse(_amountController.text),
      date: _selectedDate!,
      isIncome: isIncome,
    );

    Navigator.pop(context, newTx);
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FD),
      appBar: AppBar(
        title: const Text('Nueva Transacción', style: AppTextStyles.tituloPantalla),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            // Tipo (Ingreso/Gasto)
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: _inputDecoration('Tipo'),
              items: const [
                DropdownMenuItem(value: 'Ingreso', child: Text('Ingreso')),
                DropdownMenuItem(value: 'Gasto', child: Text('Gasto')),
              ],
              onChanged: (val) => setState(() => _selectedType = val!),
            ),
            const SizedBox(height: 24),
            // Formulario principal dentro de un Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: _inputDecoration('Título'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Ingrese título' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        decoration: _inputDecoration('Monto'),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Ingrese monto';
                          if (double.tryParse(v) == null) return 'Monto inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Botón fecha
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _presentDatePicker,
                          child: Text(
                            _selectedDate == null
                                ? 'Ingresa fecha'
                                : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Categoría
                      TextFormField(
                        controller: _categoryController,
                        decoration: _inputDecoration('Categoría (opcional)'),
                      ),
                      const SizedBox(height: 24),
                      // Botón guardar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Guardar', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
