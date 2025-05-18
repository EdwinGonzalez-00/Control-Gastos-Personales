import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../styles/text_style.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction;

  const AddTransactionScreen({super.key, this.transaction});

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

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      final tx = widget.transaction!;
      _titleController.text = tx.title;
      _amountController.text = tx.amount.toString();
      _categoryController.text = tx.category;
      _selectedDate = tx.date;
      _selectedType = tx.isIncome ? 'Ingreso' : 'Gasto';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _presentDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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

    final editedTx = Transaction(
      title: _titleController.text.trim(),
      category: _categoryController.text.trim().isEmpty
          ? _selectedType
          : _categoryController.text.trim(),
      amount: double.parse(_amountController.text),
      date: _selectedDate!,
      isIncome: isIncome,
    );

    Navigator.pop(context, editedTx);
  }

  bool _hasUnsavedChanges() {
    final original = widget.transaction;

    final currentTitle = _titleController.text.trim();
    final currentAmount = _amountController.text.trim();
    final currentCategory = _categoryController.text.trim();
    final currentType = _selectedType;
    final currentDate = _selectedDate;

    if (original == null) {
      // Nueva transacción: basta con que haya algo escrito
      return currentTitle.isNotEmpty ||
          currentAmount.isNotEmpty ||
          currentCategory.isNotEmpty ||
          currentDate != null;
    } else {
      // Edición: compara con los valores originales
      return currentTitle != original.title ||
          currentCategory != original.category ||
          currentAmount != original.amount.toString() ||
          currentDate != original.date ||
          (original.isIncome ? 'Ingreso' : 'Gasto') != currentType;
    }
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final hasChanges = _hasUnsavedChanges();

        if (!hasChanges) return true;

        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('¿Salir sin guardar?'),
            content: const Text('Perderás los datos no guardados.'),
            actions: [
              TextButton(
                child: const Text('No'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('Sí'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        );

        return shouldExit ?? false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F7FD),
        appBar: AppBar(
          title: Text(
            widget.transaction == null ? 'Nueva Transacción' : 'Editar Transacción',
            style: AppTextStyles.tituloPantalla,
          ),
          backgroundColor: Colors.blueAccent,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
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
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Ingrese título' : null,
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
                        TextFormField(
                          controller: _categoryController,
                          decoration: _inputDecoration('Categoría (opcional)'),
                        ),
                        const SizedBox(height: 24),
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
      ),
    );
  }
}
