import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/banco_provider.dart';

import 'firebase_service.dart';

class TransferenciaScreen extends StatefulWidget {
  const TransferenciaScreen({super.key});

  @override
  State<TransferenciaScreen> createState() => _TransferenciaScreenState();
}

class _TransferenciaScreenState extends State<TransferenciaScreen> {

  final TextEditingController cuentaController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController montoController = TextEditingController();

  bool cargando = false;

  void realizarTransferencia() async {

    final banco = context.read<BancoProvider>();

    String cuenta = cuentaController.text.trim();
    String nombre = nombreController.text.trim();
    double? monto = double.tryParse(montoController.text);

    //  VALIDACIÓN CUENTA
    if (cuenta.length < 6 || int.tryParse(cuenta) == null) {
      _error("Cuenta inválida (mínimo 6 dígitos)");
      return;
    }

    //  VALIDACIÓN NOMBRE
    if (nombre.length < 3) {
      _error("Nombre inválido");
      return;
    }

    //  VALIDACIÓN MONTO
    if (monto == null || monto <= 0) {
      _error("Monto inválido");
      return;
    }

    //  DECIMALES
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(montoController.text)) {
      _error("Máximo 2 decimales");
      return;
    }

    //  SALDO
    if (monto > banco.saldo) {
      _error("Saldo insuficiente");
      return;
    }

    //  CONFIRMACIÓN
    bool? confirmar = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmar transferencia"),
        content: Text("¿Enviar \$${monto.toStringAsFixed(0)} a $nombre?"),
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
      banco.transferir(monto, nombre);

      //  FIREBASE
      final service = FirebaseService();
      await service.guardarMovimiento(
        tipo: "Transferencia",
        destinatario: nombre,
        monto: monto,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Transferencia exitosa ✔")),
      );

      Navigator.pop(context);

    } catch (e) {
      _error("Error en la transacción");
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
        title: const Text("Transferencia"),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // CARD SALDO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.indigo],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
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

                  TextField(
                    controller: cuentaController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration("Número de cuenta"),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: nombreController,
                    decoration: _inputDecoration("Nombre del destinatario"),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: montoController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration("Monto a transferir"),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: cargando ? null : realizarTransferencia,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: cargando
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Transferir",
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