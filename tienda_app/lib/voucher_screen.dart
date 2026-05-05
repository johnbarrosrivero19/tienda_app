import 'package:flutter/material.dart';

class VoucherScreen extends StatelessWidget {

  final String tipo;
  final String destinatario;
  final double monto;
  final String referencia;
  final DateTime fecha;

  const VoucherScreen({
    super.key,
    required this.tipo,
    required this.destinatario,
    required this.monto,
    required this.referencia,
    required this.fecha,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Comprobante"),
        backgroundColor: Colors.green,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const Icon(Icons.check_circle, color: Colors.green, size: 80),

            const SizedBox(height: 20),

            Text(
              "$tipo realizado con éxito",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            _item("Tipo", tipo),
            _item("Destinatario", destinatario),
            _item("Monto", "\$${monto.toStringAsFixed(0)}"),
            _item("Referencia", referencia),
            _item("Fecha", fecha.toString()),

            const Spacer(),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Finalizar"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(valor),
        ],
      ),
    );
  }
}