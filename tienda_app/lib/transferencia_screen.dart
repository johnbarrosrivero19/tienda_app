import 'package:flutter/material.dart';

class TransferenciaScreen extends StatefulWidget {
  final double saldo;

  const TransferenciaScreen({super.key, required this.saldo});

  @override
  State<TransferenciaScreen> createState() => _TransferenciaScreenState();
}

class _TransferenciaScreenState extends State<TransferenciaScreen> {

  final TextEditingController cuentaController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController montoController = TextEditingController();

  void realizarTransferencia() {

    String cuenta = cuentaController.text;
    String nombre = nombreController.text;
    double? monto = double.tryParse(montoController.text);

    // 🔴 VALIDACIONES
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

    if (monto > widget.saldo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saldo insuficiente")),
      );
      return;
    }

    double nuevoSaldo = widget.saldo - monto;

    //  MENSAJE DE ÉXITO
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Transferencia a $nombre realizada ✔"),
      ),
    );

    //  REGRESAR CON NUEVO SALDO
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context, nuevoSaldo);
    });
  }

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

            //  SALDO ACTUAL
            Text(
              "Saldo disponible: \$${widget.saldo.toStringAsFixed(0)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            //  CUENTA
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

            // 👤 NOMBRE
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

            //  MONTO
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

            //  BOTÓN
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