import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/banco_provider.dart';

import 'firebase_service.dart'; //  NUEVO

class PagoScreen extends StatefulWidget {
  const PagoScreen({super.key});

  @override
  State<PagoScreen> createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {

  String servicio = "Luz";

  final TextEditingController referenciaController = TextEditingController();
  final TextEditingController montoController = TextEditingController();

  void realizarPago() async {
    final banco = context.read<BancoProvider>();
    double? monto = double.tryParse(montoController.text);

    if (monto == null || monto <= 0) {
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

    try {
      //  LÓGICA LOCAL
      banco.pagar(monto, servicio);

      //  FIREBASE DESDE SERVICE (ARQUITECTURA)
      final service = FirebaseService();
      await service.guardarMovimiento(
        tipo: "Pago",
        destinatario: servicio,
        monto: monto,
        referencia: referenciaController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pago de $servicio realizado ✔")),
      );

      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al procesar el pago")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final banco = context.watch<BancoProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Pagar servicios"),
        backgroundColor: Colors.orange,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            //  CARD SALDO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.orange, Colors.deepOrange],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Saldo disponible",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "\$${banco.saldo.toStringAsFixed(0)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // FORM
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black12,
                  )
                ],
              ),
              child: Column(
                children: [

                  DropdownButtonFormField<String>(
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
                    decoration: _inputDecoration("Servicio"),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: referenciaController,
                    decoration: _inputDecoration("Referencia (opcional)"),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: montoController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration("Monto"),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: realizarPago,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        "Pagar ahora",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}