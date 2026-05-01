import 'package:flutter/material.dart';

class PagoScreen extends StatefulWidget {
  final double saldo;

  const PagoScreen({super.key, required this.saldo});

  @override
  State<PagoScreen> createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {

  String servicio = "Luz";
  final TextEditingController referenciaController = TextEditingController();
  final TextEditingController montoController = TextEditingController();

  void realizarPago() {

    double? monto = double.tryParse(montoController.text);

    if (monto == null || monto <= 0) {
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Pago de $servicio realizado ✔")),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context, {
        "saldo": nuevoSaldo,
        "movimiento": "Pago $servicio -\$${monto.toStringAsFixed(0)}"
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pagar servicios"),
        backgroundColor: Colors.orange,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            Text(
              "Saldo: \$${widget.saldo.toStringAsFixed(0)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // 🔽 SERVICIO
            DropdownButtonFormField(
              value: servicio,
              items: const [
                DropdownMenuItem(value: "Luz", child: Text("Luz")),
                DropdownMenuItem(value: "Agua", child: Text("Agua")),
                DropdownMenuItem(value: "Internet", child: Text("Internet")),
              ],
              onChanged: (value) {
                setState(() {
                  servicio = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: "Servicio",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // 🔢 REFERENCIA
            TextField(
              controller: referenciaController,
              decoration: const InputDecoration(
                labelText: "Referencia (opcional)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // 💰 MONTO
            TextField(
              controller: montoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Monto",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: realizarPago,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text("Pagar"),
            ),
          ],
        ),
      ),
    );
  }
}