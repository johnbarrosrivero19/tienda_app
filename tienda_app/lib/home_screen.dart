import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/banco_provider.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'transferencia_screen.dart';
import 'movimientos_screen.dart';
import 'pago_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool verSaldo = true;
  String nombreUsuario = "Cargando...";

  @override
  void initState() {
    super.initState();
    obtenerUsuario();
  }

  void obtenerUsuario() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        var doc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();

        setState(() {
          nombreUsuario = doc['nombre'];
        });
      }
    } catch (e) {
      setState(() {
        nombreUsuario = "Usuario";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final banco = context.watch<BancoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Banco JB"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //  SALUDO
            Text(
              "Hola, $nombreUsuario",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            //  TARJETA PRO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.indigo],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 12,
                    color: Colors.black26,
                    offset: Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Banco JB",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.credit_card, color: Colors.white),
                    ],
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "**** **** **** 1234",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Saldo disponible",
                        style: TextStyle(color: Colors.white70),
                      ),
                      IconButton(
                        icon: Icon(
                          verSaldo
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            verSaldo = !verSaldo;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    verSaldo
                        ? "\$ ${banco.saldo.toStringAsFixed(0)}"
                        : "******",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Válido hasta 12/28",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            //  ACCIONES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                botonAccion(Icons.send, "Transferir"),
                botonAccion(Icons.receipt, "Pagar"),
                botonAccion(Icons.list, "Movimientos"),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              "Últimos movimientos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            //  LISTA PRO
            banco.movimientos.isEmpty
                ? const Center(child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("No hay movimientos aún"),
                  ))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: banco.movimientos.length,
                    itemBuilder: (context, index) {

                      final movimiento = banco.movimientos[index];
                      final esGasto = movimiento.contains("-");

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                esGasto ? Colors.red.shade100 : Colors.green.shade100,
                            child: Icon(
                              esGasto
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: esGasto ? Colors.red : Colors.green,
                            ),
                          ),
                          title: const Text("Movimiento"),
                          subtitle: Text(movimiento),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget botonAccion(IconData icono, String texto) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (texto == "Transferir") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransferenciaScreen(),
                ),
              );
            } else if (texto == "Pagar") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PagoScreen()),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MovimientosScreen(),
                ),
              );
            }
          },
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(icono, color: Colors.blue),
          ),
        ),
        const SizedBox(height: 8),
        Text(texto),
      ],
    );
  }
}
