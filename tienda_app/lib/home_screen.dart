import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  bool verSaldo = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Banco JB"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pop(context); // volver al login
            },
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [

            // 👤 Saludo
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Hola, Usuario 👋",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 20),

            // 💳 Tarjeta saldo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Saldo disponible",
                        style: TextStyle(color: Colors.white70),
                      ),
                      IconButton(
                        icon: Icon(
                          verSaldo ? Icons.visibility : Icons.visibility_off,
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

                  const SizedBox(height: 10),

                  Text(
                    verSaldo ? "\$ 5,000,000" : "******",
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

            // ⚙️ Acciones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                botonAccion(Icons.send, "Transferir"),
                botonAccion(Icons.receipt, "Pagar"),
                botonAccion(Icons.account_balance, "Cuenta"),
              ],
            ),

            const SizedBox(height: 30),

            // 📄 Movimientos
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Últimos movimientos",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    leading: Icon(Icons.arrow_downward, color: Colors.green),
                    title: Text("Ingreso"),
                    subtitle: Text("Salario"),
                    trailing: Text("+\$2,000,000"),
                  ),
                  ListTile(
                    leading: Icon(Icons.arrow_upward, color: Colors.red),
                    title: Text("Pago"),
                    subtitle: Text("Servicios"),
                    trailing: Text("-\$200,000"),
                  ),
                  ListTile(
                    leading: Icon(Icons.arrow_upward, color: Colors.red),
                    title: Text("Transferencia"),
                    subtitle: Text("A Juan"),
                    trailing: Text("-\$150,000"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Botones funcionales
  Widget botonAccion(IconData icono, String texto) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("$texto en construcción")),
            );
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