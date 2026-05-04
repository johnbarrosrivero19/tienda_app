import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/banco_provider.dart';

// 🔥 FIREBASE
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

    // VALIDACIONES
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
      // 🔥 1. DESCONTAR EN PROVIDER
      banco.pagar(monto, servicio);

      // 🔥 2. GUARDAR EN FIREBASE
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .collection('movimientos')
            .add({
          'tipo': 'Pago',
          'destinatario': servicio,
          'referencia': referenciaController.text,
          'monto': monto,
          'fecha': FieldValue.serverTimestamp(),
        });
      }

      // 🔥 3. MENSAJE
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
      appBar: AppBar(
        title: const Text("Pagar servicios"),
        backgroundColor: Colors.orange,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            Text(
              "Saldo disponible: \$${banco.saldo.toStringAsFixed(0)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 25),

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
              decoration: InputDecoration(
                labelText: "Servicio",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: referenciaController,
              decoration: InputDecoration(
                labelText: "Referencia (opcional)",
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
                labelText: "Monto",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: realizarPago,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: const Text("Pagar"),
            ),
          ],
        ),
      ),
    );
  }
}