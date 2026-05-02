import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/banco_provider.dart';

class TransferenciaScreen extends StatefulWidget {
  const TransferenciaScreen({super.key});

  @override
  State<TransferenciaScreen> createState() => _TransferenciaScreenState();
}

class _TransferenciaScreenState extends State<TransferenciaScreen> {

  final TextEditingController cuentaController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController montoController = TextEditingController();

  void realizarTransferencia() {

    final banco = context.read<BancoProvider>();

    String cuenta = cuentaController.text;
    String nombre = nombreController.text;
    double? monto = double.tryParse(montoController.text);

    // VALIDACIONES
    if (cuenta.isEmpty || nombre.isEmpty || monto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todos los campos son obligatorios")),
      );
      return;
    }

    if (monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Monto inválido")),
      );
      return;
    }

    if (monto > banco.saldo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saldo insuficiente")),
      );
      return;
    }

    // 🔥 USAR PROVIDER
    banco.transferir(monto, nombre);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Transferencia a $nombre realizada ✔")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    final banco = context.watch<BancoProvider>();

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
              "Saldo disponible: \$${banco.saldo.toStringAsFixed(0)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: cuentaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Número de cuenta",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: nombreController,
              decoration: InputDecoration(
                labelText: "Nombre del destinatario",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: montoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Monto a transferir",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: realizarTransferencia,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: const Text("Transferir"),
            ),
          ],
        ),
      ),
    );
  }
}