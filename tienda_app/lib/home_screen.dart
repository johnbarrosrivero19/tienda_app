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

  // 🔥 OBTENER USUARIO DESDE FIREBASE
  void obtenerUsuario() async {
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
  }

  @override
  Widget build(BuildContext context) {
    final banco = context.watch<BancoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Banco JB"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              Navigator.pop(context);
            },
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Hola, $nombreUsuario",
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 20),

            // TARJETA
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
                      Icon(Icons.account_balance, color: Colors.white),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "**** **** **** 1234",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 20),

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
                      )
                    ],
                  ),

                  const SizedBox(height: 5),

                  // SALDO DESDE PROVIDER
                  Text(
                    verSaldo
                        ? "\$ ${banco.saldo.toStringAsFixed(0)}"
                        : "******",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
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

            // BOTONES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                botonAccion(Icons.send, "Transferir"),
                botonAccion(Icons.receipt, "Pagar"),
                botonAccion(Icons.account_balance, "Cuenta"),
              ],
            ),

            const SizedBox(height: 30),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Últimos movimientos",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            // LISTA DESDE PROVIDER
            Expanded(
              child: banco.movimientos.isEmpty
                  ? const Center(
                      child: Text("No hay movimientos aún"),
                    )
                  : ListView.builder(
                      itemCount: banco.movimientos.length,
                      itemBuilder: (context, index) {

                        final movimiento = banco.movimientos[index];

                        return ListTile(
                          leading: Icon(
                            movimiento.contains("Transferencia")
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: movimiento.contains("-")
                                ? Colors.red
                                : Colors.green,
                          ),
                          title: const Text("Movimiento"),
                          subtitle: Text(movimiento),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // BOTONES
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
            }

            else if (texto == "Pagar") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PagoScreen(),
                ),
              );
            }

            else if (texto == "Cuenta") {
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
            backgroundColor: Colors.blue.shade100,
            child: Icon(icono, color: Colors.blue),
          ),
        ),
        const SizedBox(height: 8),
        Text(texto),
      ],
    );
  }
}