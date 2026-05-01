import 'package:flutter/material.dart';

class TransferenciaScreen extends StatefulWidget {
  final double saldo;

  const TransferenciaScreen({super.key, required this.saldo});

  @override
  State<TransferenciaScreen> createState() => _TransferenciaScreenState();
}

class _TransferenciaScreenState extends State<TransferenciaScreen> {

  final TextEditingController montoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transferencia"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            Text(
              "Saldo disponible: \$ ${widget.saldo.toStringAsFixed(0)}",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: montoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Monto a transferir",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                double monto = double.tryParse(montoController.text) ?? 0;

                if (monto <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Monto inválido")),
                  );
                  return;
                }

                if (monto > widget.saldo) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Saldo insuficiente")),
                  );
                  return;
                }

                double nuevoSaldo = widget.saldo - monto;

                Navigator.pop(context, nuevoSaldo);
              },
              child: const Text("Transferir"),
            )
          ],
        ),
      ),
    );
  }
}