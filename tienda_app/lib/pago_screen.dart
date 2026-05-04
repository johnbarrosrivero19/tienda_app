import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; //  

import 'providers/banco_provider.dart';
import 'firebase_service.dart';

class PagoScreen extends StatefulWidget {
  const PagoScreen({super.key});

  @override
  State<PagoScreen> createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {

  String servicio = "Luz";

  final TextEditingController referenciaController = TextEditingController();
  final TextEditingController montoController = TextEditingController();

  bool cargando = false;

  //  FORMATO MONEDA
  String formatearMoneda(double valor) {
    final formato = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    return formato.format(valor);
  }

  void realizarPago() async {

    final banco = context.read<BancoProvider>();
    double? monto = double.tryParse(montoController.text);

    //  VALIDACIONES
    if (monto == null || monto <= 0) {
      _error("Monto inválido");
      return;
    }

    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(montoController.text)) {
      _error("Máximo 2 decimales");
      return;
    }

    if (monto > banco.saldo) {
      _error("Saldo insuficiente");
      return;
    }

    //  CONFIRMACIÓN PRO
    bool? confirmar = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text("Confirmar pago"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Servicio: $servicio"),
            const SizedBox(height: 10),
            Text(
              formatearMoneda(monto),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Confirmar"),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => cargando = true);

    try {
      //  ESTADO LOCAL
      banco.pagar(monto, servicio);

      //  FIREBASE
      final service = FirebaseService();
      await service.guardarMovimiento(
        tipo: "Pago",
        destinatario: servicio,
        monto: monto,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pago de $servicio realizado ✔")),
      );

      Navigator.pop(context);

    } catch (e) {
      _error("Error en el pago");
    }

    setState(() => cargando = false);
  }

  void _error(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
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

                  // 💰 FORMATO APLICADO
                  Text(
                    formatearMoneda(banco.saldo),
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

            //  FORMULARIO
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
                      onPressed: cargando ? null : realizarPago,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: cargando
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
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