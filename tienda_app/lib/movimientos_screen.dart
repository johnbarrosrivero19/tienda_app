import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MovimientosScreen extends StatelessWidget {
  const MovimientosScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Movimientos"),
        backgroundColor: Colors.blue,
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

                // 🔄 Cargando
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // ❌ Error
                if (snapshot.hasError) {
                  return const Center(child: Text("Error al cargar datos"));
                }

                // 📭 Sin datos
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No hay movimientos aún"),
                  );
                }

                final movimientos = snapshot.data!.docs;

                // 📋 Lista dinámica
                return ListView.builder(
                  itemCount: movimientos.length,
                  itemBuilder: (context, index) {

                    final data = movimientos[index];

                    String tipo = data['tipo'];
                    double monto = (data['monto'] as num).toDouble();

                    bool esSalida = tipo == "Transferencia" || tipo == "Pago";

                    return ListTile(
                      leading: Icon(
                        esSalida
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: esSalida ? Colors.red : Colors.green,
                      ),

                      title: Text(tipo),

                      subtitle: Text(
                        data['destinatario'] ?? "Sin destinatario",
                      ),

                      trailing: Text(
                        "${esSalida ? '-' : '+'}\$${monto.toStringAsFixed(0)}",
                        style: TextStyle(
                          color: esSalida ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
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