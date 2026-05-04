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

  //  IMPORTANTE: liberar memoria
  @override
  void dispose() {
    cuentaController.dispose();
    nombreController.dispose();
    montoController.dispose();
    super.dispose();
  }

  void realizarTransferencia() async {

    final banco = context.read<BancoProvider>();

    String cuenta = cuentaController.text.trim();
    String nombre = nombreController.text.trim();
    double? monto = double.tryParse(montoController.text);

    // VALIDACIONES
    if (cuenta.length < 6 || int.tryParse(cuenta) == null) {
      _error("Cuenta inválida (mínimo 6 dígitos)");
      return;
    }

    if (nombre.length < 3) {
      _error("Nombre inválido");
      return;
    }

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
      //  LOCAL
      banco.transferir(monto, nombre);

      //  FIREBASE
      final service = FirebaseService();
      await service.guardarMovimiento(
        tipo: "Transferencia",
        destinatario: nombre,
        monto: monto,
      );

      //  LIMPIAR CAMPOS (UX PRO)
      cuentaController.clear();
      nombreController.clear();
      montoController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Transferencia exitosa ✔")),
      );

      Navigator.pop(context);

    } catch (e) {
      if (!mounted) return;
      _error("Error en la transacción");
    }

    if (mounted) {
      setState(() => cargando = false);
    }
  }

  void _error(String mensaje) {
    if (!mounted) return;
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
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Saldo disponible",
                      style: TextStyle(color: Colors.white70)),
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
                    decoration: _inputDecoration("Monto"),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: cargando ? null : realizarTransferencia,
                      child: cargando
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Transferir"),
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