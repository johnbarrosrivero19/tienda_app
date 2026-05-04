import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; 

class MovimientosScreen extends StatelessWidget {
  const MovimientosScreen({super.key});

  //  FORMATO MONEDA
  String formatearMoneda(double valor) {
    final formato = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    return formato.format(valor);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Movimientos"),
      ),

      body: user == null
          ? const Center(child: Text("Usuario no autenticado"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('usuarios')
                  .doc(user.uid)
                  .collection('movimientos')
                  .orderBy('fecha', descending: true)
                  .snapshots(),

              builder: (context, snapshot) {

                //  LOADING
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                //  ERROR
                if (snapshot.hasError) {
                  return const Center(child: Text("Error al cargar datos"));
                }

                // 📭 VACÍO
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No hay movimientos aún",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                final movimientos = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: movimientos.length,
                  itemBuilder: (context, index) {

                    final data = movimientos[index];

                    //  SEGURO (evita crash si falta algo)
                    String tipo = data['tipo'] ?? "Movimiento";
                    double monto = (data['monto'] as num?)?.toDouble() ?? 0;

                    bool esSalida =
                        tipo == "Transferencia" || tipo == "Pago";

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 3,

                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),

                        leading: CircleAvatar(
                          backgroundColor: esSalida
                              ? Colors.red.shade100
                              : Colors.green.shade100,
                          child: Icon(
                            esSalida
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: esSalida ? Colors.red : Colors.green,
                          ),
                        ),

                        title: Text(
                          tipo,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        subtitle: Text(
                          data['destinatario'] ?? "Sin destinatario",
                        ),

                        //  AQUÍ ESTÁ LA MEJORA CLAVE
                        trailing: Text(
                          "${esSalida ? '-' : '+'}${formatearMoneda(monto)}",
                          style: TextStyle(
                            color: esSalida ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}