import 'package:flutter/material.dart';
import 'package:control_gastos_personales/styles/text_style.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        title: const Text(
          'Control de Gastos',
          style: AppTextStyles.tituloPantalla,
        ),
      ),
      body: const Center(
        child: Text(
          'No hay transacciones aún.',
          style: TextStyle(fontSize: 18)
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

