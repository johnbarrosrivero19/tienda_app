import 'package:flutter/material.dart';

class MovimientosScreen extends StatelessWidget {
  const MovimientosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Movimientos"),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.arrow_downward, color: Colors.green),
            title: Text("Ingreso"),
            subtitle: Text("Salario"),
            trailing: Text("+\$2,000,000"),
          ),
          ListTile(
            leading: Icon(Icons.arrow_upward, color: Colors.red),
            title: Text("Pago"),
            subtitle: Text("Servicios"),
            trailing: Text("-\$200,000"),
          ),
        ],
      ),
    );
  }
}